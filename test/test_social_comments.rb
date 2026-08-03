# frozen_string_literal: true

# בדיקת הלוגיקה הטהורה של social_comments — חילוץ, חתימה, וחסימת הלולאה.
# מריצים בתוך הקונטיינר:
#   docker exec chatwoot-rails-1 ruby /app/test/test_social_comments.rb
# או מקומית עם ruby בלבד (אין תלות ב-Rails בחלק הזה).
#
# ponytail: assert-ים בלבד. אין framework, אין fixtures.

require 'json'
require 'openssl'

SECRET = 'test-secret'

# --- שכפול מינימלי של שתי הפונקציות הטהורות מהתוסף ---
# (הן חייבות להישאר זהות. אם משנים שם — משנים גם כאן.)

def extract_comments(payload)
  Array(payload['entry']).flat_map do |entry|
    page_id = entry['id'].to_s
    Array(entry['changes']).map do |change|
      next unless change['field'] == 'feed'

      v = change['value'] || {}
      next unless v['item'] == 'comment' && v['verb'] == 'add'
      next if v['comment_id'].to_s.empty? || v['message'].to_s.empty?

      {
        page_id: page_id,
        comment_id: v['comment_id'].to_s,
        parent_id: (v['parent_id'].to_s.empty? ? nil : v['parent_id'].to_s),
        from_id: v.dig('from', 'id').to_s,
        message: v['message'].to_s
      }
    end.compact
  end
end

def valid_signature?(raw, header, secret = SECRET)
  return false if header.nil? || header.empty?
  return false unless header.start_with?('sha256=')

  expected = OpenSSL::HMAC.hexdigest('SHA256', secret, raw)
  given = header.sub(/\Asha256=/, '')
  return false unless given.bytesize == expected.bytesize

  # השוואה בזמן קבוע — התוסף עצמו משתמש ב-ActiveSupport::SecurityUtils.secure_compare,
  # שאינו זמין ב-Ruby הנקי שהבדיקה רצה בו.
  given.bytes.zip(expected.bytes).reduce(0) { |acc, (a, b)| acc | (a ^ b) }.zero?
end

def own_comment?(c)
  c[:from_id] == c[:page_id]
end

# --- מטענים ---

PAGE = '2046307079006919'

def feed_payload(comment_id:, from_id:, message: 'שלום, כמה זה עולה?', verb: 'add', item: 'comment', parent: nil)
  {
    'object' => 'page',
    'entry' => [{
      'id' => PAGE,
      'changes' => [{
        'field' => 'feed',
        'value' => {
          'item' => item, 'verb' => verb,
          'comment_id' => comment_id, 'post_id' => "#{PAGE}_9999",
          'parent_id' => parent, 'message' => message,
          'from' => { 'id' => from_id, 'name' => 'בודק' }
        }.compact
      }]
    }]
  }
end

fails = 0
def check(label, cond)
  if cond
    puts "  ✅ #{label}"
  else
    puts "  🔴 #{label}"
    $fail_count += 1
  end
end
$fail_count = 0

puts "\n— חילוץ —"
c = extract_comments(feed_payload(comment_id: 'c1', from_id: 'u1'))
check('תגובה רגילה מחולצת', c.size == 1 && c[0][:comment_id] == 'c1')

check('לייק (verb=add, item=like) נדחה',
      extract_comments(feed_payload(comment_id: 'c2', from_id: 'u1', item: 'like')).empty?)

check('מחיקת תגובה (verb=remove) נדחית',
      extract_comments(feed_payload(comment_id: 'c3', from_id: 'u1', verb: 'remove')).empty?)

check('תגובה ריקה נדחית',
      extract_comments(feed_payload(comment_id: 'c4', from_id: 'u1', message: '')).empty?)

check('אירוע שאינו feed נדחה',
      extract_comments({ 'entry' => [{ 'id' => PAGE, 'changes' => [{ 'field' => 'messages', 'value' => {} }] }] }).empty?)

check('parent_id נשמר בתשובה לתגובה',
      extract_comments(feed_payload(comment_id: 'c5', from_id: 'u1', parent: 'c1'))[0][:parent_id] == 'c1')

check('parent_id ריק הופך ל-nil',
      extract_comments(feed_payload(comment_id: 'c6', from_id: 'u1'))[0][:parent_id].nil?)

puts "\n— חתימה —"
raw = JSON.generate(feed_payload(comment_id: 'c7', from_id: 'u1'))
good = 'sha256=' + OpenSSL::HMAC.hexdigest('SHA256', SECRET, raw)
check('חתימה תקינה מתקבלת',  valid_signature?(raw, good))
check('חתימה שגויה נדחית',    !valid_signature?(raw, 'sha256=' + ('0' * 64)))
check('חתימה חסרה נדחית',     !valid_signature?(raw, nil))
check('בלי קידומת sha256 נדחה', !valid_signature?(raw, OpenSSL::HMAC.hexdigest('SHA256', SECRET, raw)))
check('גוף ששונה נדחה',       !valid_signature?(raw + ' ', good))

puts "\n— ⭐ חסימת הלולאה האינסופית —"
own   = extract_comments(feed_payload(comment_id: 'c8', from_id: PAGE))[0]
other = extract_comments(feed_payload(comment_id: 'c9', from_id: 'u1'))[0]
check('תגובה מהדף עצמו מזוהה כשלנו', own_comment?(own))
check('תגובה מאדם אחר לא נחסמת',      !own_comment?(other))

puts "\n#{$fail_count.zero? ? '✅ כל הבדיקות עברו' : "🔴 #{$fail_count} בדיקות נכשלו"}"
exit($fail_count.zero? ? 0 : 1)
