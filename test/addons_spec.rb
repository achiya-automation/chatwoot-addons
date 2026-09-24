# Integration checks for the four initializers, run inside a Chatwoot checkout
# (v4.x with SafeFetch) after copying initializers/*.rb into config/initializers:
#   bundle exec rspec /path/to/chatwoot-addons/test/addons_spec.rb
require 'rails_helper'

RSpec.describe 'Chatwoot addons' do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }

  around do |example|
    clean = -> { Dir.glob(BotFlowStore.storage_dir.join('*.json')).each { |f| File.delete(f) } }
    clean.call
    example.run
    clean.call
  end

  def node(name, data = {}, outputs = {})
    { 'name' => name, 'data' => data,
      'outputs' => outputs.transform_values { |ids| { 'connections' => Array(ids).map { |id| { 'node' => id.to_s } } } } }
  end

  def save_bot(nodes, options = {})
    BotFlowStore.save('name' => 'Test', 'active' => options.fetch(:active, true), 'account_id' => options.fetch(:account_id, account.id),
                      'inbox_ids' => [inbox.id], 'flow' => { 'drawflow' => { 'Home' => { 'data' => nodes } } })
  end

  def run_node(bot, id)
    fd = bot.dig('flow', 'drawflow', 'Home', 'data')
    BotEngine::ProcessJob.new.send(:exec_node, fd[id], fd, conversation, bot)
  end

  def incoming(content)
    create(:message, conversation: conversation, account: account, inbox: inbox, message_type: :incoming, content: content)
  end

  def fetched(body, content_type = 'application/json')
    SafeFetch::Result.new(tempfile: StringIO.new(body), filename: nil, content_type: content_type)
  end

  describe 'bot builder list page', type: :request do
    it 'keeps client-sent values out of the page and forces server-side fields' do
      xss = "'><img src=x onerror=alert(1)>"
      post '/bot-builder/api/bots',
           params: { name: 'x', active: xss, created_at: xss, account_id: account.id }.to_json,
           headers: { 'api-access-token' => admin.access_token.token, 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:success)
      expect(response.parsed_body['active']).to be(false)
      expect(response.parsed_body['created_at']).not_to include('<img')

      get '/bot-builder', headers: { 'api-access-token' => admin.access_token.token }
      expect(response.body).not_to include('<img src=x')
    end
  end

  describe 'bot engine' do
    it 'ignores a bot_state that the bot did not write' do
      bot = save_bot('1' => node('menu', { 'title' => 'Pick', 'opt1' => 'A' }, 'output_1' => 2),
                     '2' => node('add_label', { 'label_name' => 'forged' }))
      conversation.update!(custom_attributes: { 'bot_state' => { 'bot_id' => bot['id'], 'node_id' => '1',
                                                                 'waiting_for' => 'menu_choice', 'options_count' => 1 } })

      BotEngine::ProcessJob.perform_now(incoming('1').id)

      expect(conversation.reload.label_list).not_to include('forged')
      expect(conversation.custom_attributes['bot_state']).to be_nil
    end

    it 'continues from a menu the bot showed' do
      bot = save_bot('1' => node('menu', { 'title' => 'Pick', 'opt1' => 'A' }, 'output_1' => 2),
                     '2' => node('add_label', { 'label_name' => 'picked' }))
      run_node(bot, '1')

      BotEngine::ProcessJob.perform_now(incoming('1').id)

      expect(conversation.reload.label_list).to include('picked')
    end

    it 'does not resume a delayed step of a disabled bot or another account' do
      disabled = save_bot({ '2' => node('add_label', { 'label_name' => 'late' }) }, active: false)
      foreign = save_bot({ '2' => node('add_label', { 'label_name' => 'late' }) }, account_id: create(:account).id)

      BotEngine::DelayJob.perform_now(conversation.id, disabled['id'], '2')
      BotEngine::DelayJob.perform_now(conversation.id, foreign['id'], '2')

      expect(conversation.reload.label_list).not_to include('late')
    end

    it 'assigns only agents of the conversation account' do
      run_node(save_bot('1' => node('assign', { 'agent_id' => create(:user).id })), '1')
      expect(conversation.reload.assignee).to be_nil

      member = create(:user, account: account)
      run_node(save_bot('1' => node('assign', { 'agent_id' => member.id })), '1')
      expect(conversation.reload.assignee).to eq(member)
    end

    it 'sends webhooks through SafeFetch' do
      expect(SafeFetch).to receive(:fetch).with('https://hooks.example.com/x', hash_including(method: :post))

      run_node(save_bot('1' => node('webhook', { 'url' => 'https://hooks.example.com/x', 'method' => 'POST' })), '1')
    end

    it 'never reaches internal addresses' do
      with_modified_env SAFE_FETCH_ALLOW_PRIVATE_NETWORK: 'false' do
        run_node(save_bot('1' => node('webhook', { 'url' => 'http://127.0.0.1:3000/api/v1/profile' })), '1')
      end

      expect(a_request(:any, /127\.0\.0\.1/)).not_to have_been_made
    end

    it 'sends an image as one message that already carries the file' do
      allow(SafeFetch).to receive(:fetch).and_yield(fetched('png-bytes', 'image/png'))
      bot = save_bot('1' => node('image', { 'image_url' => 'https://cdn.example.com/pic.png', 'caption' => 'hi' }))

      expect { run_node(bot, '1') }.to change { conversation.messages.count }.by(1)
      expect(conversation.messages.last.attachments.count).to eq(1)
    end

    it 'splits A/B by the configured percentage' do
      nodes = ->(pct) { { '1' => node('ab_split', { 'split_a' => pct }, 'output_1' => 2, 'output_2' => 3),
                          '2' => node('add_label', { 'label_name' => 'a' }), '3' => node('add_label', { 'label_name' => 'b' }) } }
      run_node(save_bot(nodes.call('100')), '1')
      expect(conversation.reload.label_list).to eq(['a'])

      allow_any_instance_of(BotEngine::ProcessJob).to receive(:rand).and_return(99) # rubocop:disable RSpec/AnyInstance
      run_node(save_bot(nodes.call('60')), '1')
      expect(conversation.reload.label_list).to contain_exactly('a', 'b')
    end

    it 'jumps with goto and stops a goto loop' do
      run_node(save_bot('1' => node('goto_step', { 'target_node' => '2' }), '2' => node('add_label', { 'label_name' => 'jumped' })), '1')
      expect(conversation.reload.label_list).to include('jumped')

      loop_bot = save_bot('1' => node('goto_step', { 'target_node' => '2' }), '2' => node('goto_step', { 'target_node' => '1' }))
      expect { run_node(loop_bot, '1') }.not_to raise_error
    end

    it 'saves an API response into a variable and follows success or error' do
      allow(SafeFetch).to receive(:fetch).and_yield(fetched('{"ok":1}'))
      nodes = { '1' => node('api_action', { 'url' => 'https://api.example.com/x', 'method' => 'GET', 'save_response' => 'answer' },
                            'output_1' => 2, 'output_2' => 3),
                '2' => node('message', { 'message' => 'got {{answer}}' }),
                '3' => node('add_label', { 'label_name' => 'api_failed' }) }
      run_node(save_bot(nodes), '1')
      expect(conversation.messages.last.content).to eq('got {"ok":1}')

      allow(SafeFetch).to receive(:fetch).and_raise(SafeFetch::HttpError, '500 Internal Server Error')
      run_node(save_bot(nodes), '1')
      expect(conversation.reload.label_list).to include('api_failed')
    end

    it 'waits for a reply, stores it and continues' do
      bot = save_bot('1' => node('wait_reply', { 'variable' => 'city', 'timeout_seconds' => '60' }, 'output_1' => 2),
                     '2' => node('message', { 'message' => 'city={{city}}' }))
      run_node(bot, '1')

      BotEngine::ProcessJob.perform_now(incoming('Haifa').id)

      expect(conversation.messages.where(message_type: :outgoing).last.content).to eq('city=Haifa')
    end

    it 'follows the timeout branch when no reply arrived' do
      bot = save_bot('1' => node('wait_reply', { 'variable' => 'city', 'timeout_seconds' => '60', 'timeout_message' => 'still there?' },
                                 'output_2' => 3),
                     '3' => node('add_label', { 'label_name' => 'timed_out' }))
      run_node(bot, '1')
      started = conversation.reload.custom_attributes.dig('bot_state', 'started_at')

      BotEngine::WaitTimeoutJob.perform_now(conversation.id, bot['id'], '1', started)

      expect(conversation.reload.label_list).to include('timed_out')
      expect(conversation.messages.where(message_type: :outgoing).last.content).to eq('still there?')
    end

    it 'matches the city contact field the editor offers' do
      conversation.contact.update!(additional_attributes: { 'city' => 'Haifa' })
      run_node(save_bot('1' => node('condition', { 'check_type' => 'contact_field', 'attr_key' => 'city', 'check_value' => 'haifa' },
                                    'output_1' => 2),
                        '2' => node('add_label', { 'label_name' => 'in_haifa' })), '1')

      expect(conversation.reload.label_list).to include('in_haifa')
    end
  end

  describe 'campaign report' do
    let!(:campaign) { create(:campaign, account: account, title: 'Spring sale') }

    it 'is for account administrators only', type: :request do
      get '/campaign-report', headers: { 'api-access-token' => agent.access_token.token }
      expect(response.body).not_to include('Spring sale')

      get '/campaign-report', headers: { 'api-access-token' => admin.access_token.token }
      expect(response.body).to include('Spring sale')
    end

    it 'counts delivery statuses in one pass' do
      %i[delivered read failed].each do |status|
        create(:message, conversation: conversation, account: account, inbox: inbox, message_type: :outgoing,
                         status: status, content_attributes: { campaign_id: campaign.id })
      end
      create(:message, conversation: conversation, account: account, inbox: inbox, message_type: :outgoing,
                       content_attributes: { campaign_id: campaign.id + 1000 })

      stats = CampaignReportMiddleware.new(nil).send(:batch_campaign_stats, [campaign.id], [account.id])

      expect(stats[campaign.id]).to eq(total: 3, delivered: 2, read: 1, failed: 1)
    end
  end

  describe 'navigation widget' do
    let(:page) { ->(_env) { [200, { 'Content-Type' => 'text/html' }, ['<html><body>x</body></html>']] } }

    def body_for(path)
      _status, _headers, body = CustomNavWidgetMiddleware.new(page).call('PATH_INFO' => path)
      body.join
    end

    it 'appears on the agent dashboard only' do
      expect(body_for('/app/accounts/1/dashboard')).to include('data-custom-nav-style')
      expect(body_for('/widget')).not_to include('data-custom-nav-style')
      expect(body_for('/hc/help/articles/1')).not_to include('data-custom-nav-style')
    end
  end

  describe 'social comments' do
    let(:channel) { create(:channel_api, account: account) }
    let(:comments_inbox) { channel.inbox }

    it 'moves a legacy page token out of the inbox attributes' do
      channel.update!(additional_attributes: { 'fb_page_id' => 'page-1', 'fb_page_token' => 'token-1' })

      SocialComments.migrate_legacy_tokens!

      expect(channel.reload.additional_attributes).not_to have_key('fb_page_token')
      expect(SocialComments.page_token(comments_inbox)).to eq('token-1')
      expect(SocialComments.inbox_for('page-1')).to eq(comments_inbox)
    end

    it 'does not let another inbox claim a connected page' do
      SocialComments.register_page!(comments_inbox, 'page-1', 'token-1')
      channel.update!(additional_attributes: { 'fb_page_id' => 'page-1' })
      intruder = create(:channel_api, account: create(:account))
      intruder.update!(additional_attributes: { 'fb_page_id' => 'page-1' })

      expect(SocialComments.inbox_for('page-1')).to eq(comments_inbox)
      expect(SocialComments.page_token(intruder.inbox)).to be_nil
    end

    describe 'agent replies', type: :request do
      let(:commented) { create(:conversation, account: account, inbox: comments_inbox) }

      before do
        SocialComments.register_page!(comments_inbox, 'page-1', 'token-1')
        channel.update!(additional_attributes: { 'fb_page_id' => 'page-1' })
        create(:message, conversation: commented, account: account, inbox: comments_inbox, message_type: :incoming, source_id: 'comment-1')
      end

      def deliver(private: false, secret: channel.secret)
        payload = { event: 'message_created', message_type: 'outgoing', content: 'thanks', private: private,
                    conversation: { id: commented.display_id }, account: { id: account.id }, inbox: { id: comments_inbox.id } }.to_json
        ts = Time.now.to_i.to_s
        signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, "#{ts}.#{payload}")}"
        post '/social-comments/outgoing', params: payload,
                                          headers: { 'Content-Type' => 'application/json', 'X-Chatwoot-Signature' => signature,
                                                     'X-Chatwoot-Timestamp' => ts }
      end

      it 'publishes a signed reply under the comment of that conversation' do
        expect(SocialComments).to receive(:publish_reply).with(comments_inbox, 'comment-1', 'thanks').and_return([:ok, 'reply-1'])

        deliver

        expect(response).to have_http_status(:success)
      end

      it 'never publishes private notes' do
        expect(SocialComments).not_to receive(:publish_reply)

        deliver(private: true)
      end

      it 'rejects replies that Chatwoot did not sign' do
        expect(SocialComments).not_to receive(:publish_reply)

        deliver(secret: 'wrong')

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
