# frozen_string_literal: true

# ============================================================
# Social Comments for Chatwoot
# Facebook Page post comments -> Chatwoot conversations, and back.
#
# Chatwoot supports Messenger DMs only. Two gaps in core:
#   1. facebookScopes.js does not request the comment permissions
#   2. channel/facebook_page.rb:53 does not subscribe to the `feed` field
# Neither file is edited. This middleware works around both.
#
# Flow:
#   Meta `feed` webhook -> intercepted here -> conversation in an API inbox
#   agent replies       -> Chatwoot outgoing webhook -> Graph API -> public reply
#
# Install: mount at /app/config/initializers/social_comments.rb (read-only)
# Created: 2026-08-03
# ============================================================

module SocialComments
  GRAPH = 'https://graph.facebook.com/v23.0'

  # תיבה מזוהה לפי page_id ששמור ב-additional_attributes של ערוץ ה-API.
  # ponytail: אין טבלה חדשה — source_id של ההודעה מחזיק את comment_id,
  # והוא כבר מאונדקס ב-Chatwoot.
  PAGE_KEY    = 'fb_page_id'
  TOKEN_KEY   = 'fb_page_token'

  module_function

  def app_secret
    ENV.fetch('FB_APP_SECRET', nil)
  end

  def internal_token
    ENV.fetch('SOCIAL_COMMENTS_TOKEN', nil)
  end

  # אימות הקוראים הפנימיים (מנוע ה-journeys, וה-webhook היוצא של Chatwoot).
  #
  # ⚠️ בניגוד ל-webhook הנכנס מ-Meta, לשתי הנקודות האלה אין חתימה לאמת מולה — הן
  # מקבלות פקודת *שליחה*. בלי השומר הזה כל מי שמגיע לשרת (וה-reverse proxy מעביר
  # הכול ל-Rails) יכול לשגר הודעה פרטית בפייסבוק בשם העסק או לפרסם תגובה ציבורית.
  #
  # fail-closed בכוונה: בלי סוד מוגדר אנחנו דוחים, לא פותחים. סוד חסר הוא תקלת
  # התקנה שצריך לצעוק עליה — לא סיבה להגיש נקודת שליחה פתוחה לאינטרנט.
  def internal_caller?(env)
    secret = internal_token
    if secret.blank?
      Rails.logger.error('[social-comments] SOCIAL_COMMENTS_TOKEN is not set — refusing send endpoints')
      return false
    end

    presented = env['HTTP_X_INTERNAL_TOKEN'].to_s
    return false if presented.empty?

    ActiveSupport::SecurityUtils.secure_compare(presented, secret)
  rescue StandardError
    false
  end

  # אימות חתימה של Meta. ללא זה כל אחד יכול להזריק שיחות לתיבות של לקוחות.
  def valid_signature?(raw_body, header)
    secret = app_secret
    return false if secret.blank? || header.blank?
    return false unless header.start_with?('sha256=')

    expected = OpenSSL::HMAC.hexdigest('SHA256', secret, raw_body)
    ActiveSupport::SecurityUtils.secure_compare(header.delete_prefix('sha256='), expected)
  rescue StandardError
    false
  end

  # מחלץ רק תגובות אמיתיות. מסנן לייקים, שיתופים, עריכות ומחיקות.
  def extract_comments(payload)
    Array(payload['entry']).flat_map do |entry|
      page_id = entry['id'].to_s
      Array(entry['changes']).map do |change|
        next unless change['field'] == 'feed'

        v = change['value'] || {}
        next unless v['item'] == 'comment' && v['verb'] == 'add'
        next if v['comment_id'].blank? || v['message'].blank?

        {
          page_id: page_id,
          comment_id: v['comment_id'].to_s,
          parent_id: v['parent_id'].to_s.presence,
          post_id: v['post_id'].to_s,
          from_id: v.dig('from', 'id').to_s,
          from_name: v.dig('from', 'name').presence || 'Facebook user',
          message: v['message'].to_s,
          permalink: v['permalink_url'].presence
        }
      end.compact
    end
  end

  def inbox_for(page_id)
    Channel::Api
      .where("additional_attributes ->> ? = ?", PAGE_KEY, page_id)
      .first&.inbox
  end

  def page_token(inbox)
    inbox.channel.additional_attributes[TOKEN_KEY].presence
  end

  # ⭐ המחסום שמונע לולאה אינסופית.
  # התשובה שאנחנו מפרסמים חוזרת אלינו כ-webhook. בלי הבדיקה הזו
  # היא יוצרת שיחה, שמייצרת תשובה, שחוזרת כ-webhook — בלי סוף.
  def own_comment?(comment)
    comment[:from_id] == comment[:page_id]
  end

  def already_seen?(inbox, comment_id)
    Message.where(inbox_id: inbox.id, source_id: comment_id).exists?
  end

  def find_or_create_contact(inbox, comment)
    ci = ContactInbox.find_by(inbox_id: inbox.id, source_id: comment[:from_id])
    return ci if ci

    contact = inbox.account.contacts.create!(name: comment[:from_name])
    ContactInbox.create!(inbox: inbox, contact: contact, source_id: comment[:from_id])
  end

  # תגובת שורש פותחת שיחה. תשובה לתגובה נכנסת לשיחה הקיימת.
  def find_or_create_conversation(inbox, contact_inbox, comment)
    if comment[:parent_id].present?
      parent = Message.find_by(inbox_id: inbox.id, source_id: comment[:parent_id])
      return parent.conversation if parent&.conversation
    end

    root = Message.find_by(inbox_id: inbox.id, source_id: comment[:post_id])
    return root.conversation if root&.conversation

    Conversation.create!(
      account_id: inbox.account_id,
      inbox_id: inbox.id,
      contact_id: contact_inbox.contact_id,
      contact_inbox_id: contact_inbox.id,
      additional_attributes: {
        'source' => 'facebook_comment',
        'post_id' => comment[:post_id],
        'permalink' => comment[:permalink]
      }.compact
    )
  end

  def ingest(comment)
    inbox = inbox_for(comment[:page_id])
    return :no_inbox unless inbox
    return :own      if own_comment?(comment)
    return :dup      if already_seen?(inbox, comment[:comment_id])

    contact_inbox = find_or_create_contact(inbox, comment)
    conversation  = find_or_create_conversation(inbox, contact_inbox, comment)

    conversation.messages.create!(
      account_id: inbox.account_id,
      inbox_id: inbox.id,
      message_type: :incoming,
      content: comment[:message],
      source_id: comment[:comment_id],
      sender: contact_inbox.contact
    )
    :ok
  rescue ActiveRecord::RecordNotUnique
    :dup
  end

  # שליחת הודעה פרטית למי שהגיב (Private Reply).
  # Meta: "Only one message can be sent to the person who commented",
  # "within 7 days from when the post or comment was created".
  # שתי המגבלות נבדקות גם אצלנו לפני הקריאה, כדי לא לבזבז מכסה על כישלון ודאי.
  def send_private_reply(inbox, comment_id, body)
    token   = page_token(inbox)
    page_id = inbox.channel.additional_attributes.to_h[PAGE_KEY]
    return [:no_token, nil] if token.blank? || page_id.blank?

    uri = URI("#{GRAPH}/#{page_id}/messages")
    res = Net::HTTP.post_form(
      uri,
      'recipient' => { comment_id: comment_id }.to_json,
      'message' => { text: body }.to_json,
      'messaging_type' => 'RESPONSE',
      'access_token' => token
    )
    json = JSON.parse(res.body) rescue {}
    return [:ok, json['message_id']] if res.is_a?(Net::HTTPSuccess) && json['message_id'].present?

    code = json.dig('error', 'code')
    sub  = json.dig('error', 'error_subcode')
    # 10 / 200 = מחוץ למדיניות ההודעות (בד"כ החלון נסגר או שכבר נשלחה הודעה)
    status = [10, 200].include?(code) ? :not_allowed : :error
    [status, json.dig('error', 'message')]
  rescue StandardError => e
    [:error, e.message]
  end

  # פרסום התשובה של הסוכן חזרה כתגובה פומבית.
  def publish_reply(inbox, parent_comment_id, body)
    token = page_token(inbox)
    return [:no_token, nil] if token.blank?

    # הטוקן ב-Authorization header ולא בגוף/ב-URL — לא נרשם בלוגים של פרוקסי.
    uri = URI("#{GRAPH}/#{parent_comment_id}/comments")
    req = Net::HTTP::Post.new(uri)
    req['Authorization'] = "Bearer #{token}"
    req.set_form_data('message' => body)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    json = JSON.parse(res.body) rescue {}

    return [:ok, json['id']] if res.is_a?(Net::HTTPSuccess) && json['id'].present?

    # 100 = התגובה נמחקה לפני שהספקנו לענות. אין טעם ב-retry.
    code = json.dig('error', 'code')
    [code == 100 ? :gone : :error, json.dig('error', 'message')]
  rescue StandardError => e
    [:error, e.message]
  end
end

# ------------------------------------------------------------

class SocialCommentsMiddleware
  OUTGOING_PATH = '/social-comments/outgoing'
  # מנוע ה-journeys קורא לכאן כדי לשלוח הודעה פרטית למי שהגיב.
  # הביצוע יושב כאן ולא במנוע כי ה-Page Token שמור בערוץ, ואין סיבה לשכפל אותו.
  PM_PATH       = '/social-comments/private-reply'
  # Chatwoot ממפה את ה-webhook של פייסבוק כאן:
  #   config/routes.rb:644  mount Facebook::Messenger::Server, at: 'bot'
  # מיירטים רק אותו — לא כל POST באפליקציה.
  INBOUND_PATH  = '/bot'

  def initialize(app)
    @app = app
  end

  def call(env)
    return handle_pm(env)       if env['PATH_INFO'] == PM_PATH && env['REQUEST_METHOD'] == 'POST'
    return handle_outgoing(env) if env['PATH_INFO'] == OUTGOING_PATH && env['REQUEST_METHOD'] == 'POST'
    return @app.call(env) unless env['REQUEST_METHOD'] == 'POST'
    return @app.call(env) unless env['PATH_INFO'].to_s.start_with?(INBOUND_PATH)

    raw = read_body(env)
    return @app.call(env) if raw.blank? || !raw.include?('"feed"')

    payload = JSON.parse(raw) rescue nil
    comments = payload ? SocialComments.extract_comments(payload) : []
    return @app.call(env) if comments.empty?

    unless SocialComments.valid_signature?(raw, env['HTTP_X_HUB_SIGNATURE_256'])
      Rails.logger.warn('[social-comments] rejected: bad signature')
      return [401, { 'Content-Type' => 'text/plain' }, ['invalid signature']]
    end

    comments.each do |c|
      result = SocialComments.ingest(c)
      # warn ולא info — Chatwoot רץ ב-RAILS_LOG_LEVEL=warn, ו-info נבלע.
      Rails.logger.warn("[social-comments] #{c[:comment_id]} -> #{result}")
    end

    [200, { 'Content-Type' => 'text/plain' }, ['ok']]
  rescue StandardError => e
    Rails.logger.error("[social-comments] #{e.class}: #{e.message}")
    @app.call(env)
  end

  private

  # קורא את הגוף ומחזיר אותו למקומו — אחרת Chatwoot יקבל stream ריק.
  def read_body(env)
    input = env['rack.input']
    return nil unless input

    raw = input.read
    input.rewind if input.respond_to?(:rewind)
    raw
  end

  # מנוע ה-journeys שולח לכאן: {conversation:{display_id}, account_id, text}.
  # אוכף את שתי מגבלות Meta לפני הקריאה — הודעה אחת לכל תגובה, וחלון 7 ימים.
  def handle_pm(env)
    return json(401, error: 'unauthorized') unless SocialComments.internal_caller?(env)

    data = JSON.parse(read_body(env).to_s) rescue {}
    display_id = data.dig('conversation', 'display_id')
    account_id = data['account_id']
    text       = data['text'].to_s
    return json(400, error: 'missing display_id/text') if display_id.blank? || text.blank?

    conversation = Conversation.find_by(display_id: display_id, account_id: account_id)
    return json(404, error: 'conversation not found') unless conversation

    inbox = conversation.inbox
    unless inbox.channel.is_a?(Channel::Api) && inbox.channel.additional_attributes[SocialComments::PAGE_KEY].present?
      return json(422, error: 'not a comments inbox')
    end

    attrs = conversation.additional_attributes.to_h
    return json(409, error: 'already sent', detail: attrs['pm_at']) if attrs['pm_sent']

    src = conversation.messages.where(message_type: :incoming).where.not(source_id: nil).order(:id).first
    return json(422, error: 'no source comment') unless src
    return json(410, error: 'window closed', detail: src.created_at) if src.created_at < 7.days.ago

    status, info = SocialComments.send_private_reply(inbox, src.source_id, text)
    Rails.logger.warn("[social-comments] pm #{src.source_id} -> #{status}")
    return json(502, error: status.to_s, detail: info) unless status == :ok

    conversation.update!(additional_attributes: attrs.merge('pm_sent' => true, 'pm_at' => Time.current.iso8601))
    conversation.messages.create!(
      message_type: :outgoing, content: text,
      account_id: conversation.account_id, inbox_id: inbox.id,
      content_attributes: { 'bot_response' => true, 'private_reply' => true, 'mid' => info }
    )
    json(200, status: 'ok', mid: info)
  rescue StandardError => e
    Rails.logger.error("[social-comments] pm #{e.class}: #{e.message}")
    json(500, error: 'internal')
  end

  # Chatwoot שולח לכאן כשסוכן עונה בתיבת התגובות.
  def handle_outgoing(env)
    return json(401, error: 'unauthorized') unless SocialComments.internal_caller?(env)

    raw = read_body(env)
    data = JSON.parse(raw.to_s) rescue {}

    return json(200, ignored: 'not an outgoing message') unless data['event'] == 'message_created' &&
                                                                data['message_type'] == 'outgoing'

    conversation_id = data.dig('conversation', 'id')
    body = data['content'].to_s
    return json(200, ignored: 'empty') if conversation_id.blank? || body.blank?

    # ה-webhook של Chatwoot נושא את החשבון. מצמצמים לפיו כשהוא קיים — אחרת
    # conversation_id לבדו הוא מפתח גלובלי, ותקלת הגדרה בחשבון אחד הייתה מפרסמת
    # תגובה בשם עמוד של חשבון אחר.
    account_id = data.dig('account', 'id') || data['account_id']
    scope = account_id.present? ? Conversation.where(account_id: account_id) : Conversation
    conversation = scope.find_by(id: conversation_id)
    return json(200, ignored: 'no conversation') unless conversation

    inbox = conversation.inbox
    return json(200, ignored: 'not a comments inbox') unless inbox.channel.is_a?(Channel::Api) &&
                                                             inbox.channel.additional_attributes[SocialComments::PAGE_KEY].present?

    parent = conversation.messages.where(message_type: :incoming).where.not(source_id: nil).order(:id).last
    return json(200, ignored: 'no parent comment') unless parent

    status, info = SocialComments.publish_reply(inbox, parent.source_id, body)
    Rails.logger.warn("[social-comments] reply #{parent.source_id} -> #{status}")

    # שומרים את מזהה התגובה שפרסמנו, כדי שהחזרה שלה כ-webhook תזוהה כשלנו
    if status == :ok && info.present?
      Message.where(id: data.dig('id')).update_all(source_id: info) rescue nil
    end

    json(200, status: status, detail: info)
  rescue StandardError => e
    Rails.logger.error("[social-comments] outgoing #{e.class}: #{e.message}")
    json(200, status: 'error')
  end

  def json(code, payload)
    [code, { 'Content-Type' => 'application/json' }, [payload.to_json]]
  end
end

Rails.application.config.middleware.use SocialCommentsMiddleware
