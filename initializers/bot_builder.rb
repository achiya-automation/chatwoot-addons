# frozen_string_literal: true
# encoding: utf-8

# Bot Builder - Visual Drag & Drop Bot Editor for Chatwoot
# Docker volume: /app/config/initializers/bot_builder.rb
# Access: /bot-builder (requires login)

module BotFlowStore
  class << self
    def storage_dir
      @storage_dir ||= Rails.root.join('storage', 'bot_flows').tap { |d| FileUtils.mkdir_p(d) }
    end

    def all
      Dir.glob(storage_dir.join('*.json')).map { |f| JSON.parse(File.read(f)) }
        .sort_by { |b| b['updated_at'] || '' }.reverse
    rescue StandardError; [] end

    def find(id)
      p = storage_dir.join("#{id}.json")
      p.exist? ? JSON.parse(File.read(p)) : nil
    rescue StandardError; nil end

    def save(d)
      d['id'] ||= "#{Time.now.to_i}#{rand(1000).to_s.rjust(3,'0')}"
      d['updated_at'] = Time.now.iso8601
      d['created_at'] ||= Time.now.iso8601
      File.write(storage_dir.join("#{d['id']}.json"), JSON.pretty_generate(d))
      d
    end

    def delete(id)
      p = storage_dir.join("#{id}.json")
      FileUtils.rm_f(p)
    end

    def active_for_inbox(inbox_id, account_id)
      all.select { |b| b['active'] && b['account_id'] == account_id && (b['inbox_ids'] || []).include?(inbox_id) }
    end
  end
end

class BotBuilderMiddleware
  def initialize(app); @app = app; end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path
    return @app.call(env) unless path.start_with?('/bot-builder')
    user = auth(req)
    return [302, {'Location'=>'/auth/sign_in','Content-Type'=>'text/html'}, ['Redirecting']] unless user
    handle(req, path, user)
  rescue => e
    Rails.logger.error("[BotBuilder] #{e.message}\n#{e.backtrace&.first(3)&.join("\n")}")
    [500, sh.merge('Content-Type'=>'text/html'), ["<h1>Error</h1>"]]
  end

  private

  def auth(req)
    w = req.env['warden']
    u = w&.user
    return u if u.is_a?(User)
    t = req.get_header('HTTP_API_ACCESS_TOKEN')
    return nil unless t.present?
    a = AccessToken.find_by(token: t)
    a&.owner.is_a?(User) ? a.owner : nil
  end

  def sh
    {'X-Frame-Options'=>'DENY','X-Content-Type-Options'=>'nosniff','Cache-Control'=>'no-store'}
  end

  def jr(data, s=200)
    [s, sh.merge('Content-Type'=>'application/json; charset=utf-8'), [data.to_json]]
  end

  def aids(user)
    user.account_ids rescue user.accounts.pluck(:id)
  end

  def handle(req, path, user)
    ac = aids(user)
    case path
    when '/bot-builder'
      return list_page(ac, user) if req.get?
    when '/bot-builder/new'
      return editor_page(nil, user) if req.get?
    when %r{^/bot-builder/(\w+)/edit$}
      return editor_page($1, user) if req.get?
    when '/bot-builder/api/bots'
      return jr(BotFlowStore.all.select{|b| ac.include?(b['account_id'])}) if req.get?
      if req.post?
        d = JSON.parse(req.body.read); d['account_id'] ||= ac.first
        return jr(BotFlowStore.save(d))
      end
    when %r{^/bot-builder/api/bots/(\w+)$}
      id=$1
      return jr(BotFlowStore.find(id)||{error:1}) if req.get?
      if req.request_method=='DELETE'
        BotFlowStore.delete(id); return jr({ok:1})
      end
    when %r{^/bot-builder/api/bots/(\w+)/toggle$}
      if req.post?
        b=BotFlowStore.find($1); return jr({error:1}) unless b
        b['active']=!b['active']; return jr(BotFlowStore.save(b))
      end
    when '/bot-builder/api/inboxes'
      return jr(Inbox.where(account_id:ac).map{|i|{id:i.id,name:i.name,channel_type:i.channel_type}}) if req.get?
    when '/bot-builder/api/agents'
      return jr(User.where(id:AccountUser.where(account_id:ac).select(:user_id)).map{|u|{id:u.id,name:u.available_name}}) if req.get?
    when '/bot-builder/api/labels'
      return jr(Label.where(account_id:ac).map{|l|{id:l.id,title:l.title}}) if req.get?
    when '/bot-builder/api/teams'
      return jr(Team.where(account_id:ac).map{|t|{id:t.id,name:t.name}}) if req.get?
    when '/bot-builder/api/custom_attributes'
      return jr(CustomAttributeDefinition.where(account_id:ac).map{|a|{id:a.id,key:a.attribute_key,name:a.attribute_display_name,type:a.attribute_display_type,model:a.attribute_model}}) if req.get?
    when '/bot-builder/api/contact_fields'
      return jr([{key:'name',label:"Name"},{key:'email',label:"Email"},{key:'phone_number',label:"Phone"},{key:'city',label:"City"},{key:'country',label:"Country"}]) if req.get?
    end
    [404, sh.merge('Content-Type'=>'application/json'), ['{"error":"not_found"}']]
  end

  def e(t); ERB::Util.html_escape(t.to_s); end

  def fab_html
    '<style>' \
    '.cw-fab{position:fixed;bottom:20px;right:20px;width:36px;height:36px;border-radius:8px;background:#FFFFFF;border:1px solid #EAEAEA;color:#80838D;display:flex;align-items:center;justify-content:center;cursor:pointer;z-index:9000;transition:background .15s,border-color .15s,color .15s;font-family:"Inter",-apple-system,system-ui,sans-serif;box-shadow:0 1px 4px rgba(0,0,0,.06)}' \
    '.cw-fab:hover{background:#F7F7F7;color:#1C2024;border-color:#E2E3E7}' \
    '.cw-fab svg{width:16px;height:16px;fill:currentColor}' \
    '.cw-fab-menu{position:fixed;bottom:64px;right:20px;background:rgba(255,255,255,.82);backdrop-filter:blur(20px) saturate(1.4);-webkit-backdrop-filter:blur(20px) saturate(1.4);border:1px solid rgba(0,0,0,.06);border-radius:14px;padding:4px;display:none;flex-direction:column;gap:1px;z-index:9001;min-width:170px;box-shadow:0 0 0 1px rgba(0,0,0,.03),0 4px 16px rgba(0,0,0,.08);font-family:"Inter",-apple-system,system-ui,sans-serif}' \
    '.cw-fab-menu.open{display:flex}' \
    '.cw-fab-link{display:flex;align-items:center;gap:10px;padding:8px 12px;border-radius:8px;color:#60646C;text-decoration:none;font-size:13px;font-weight:500;direction:ltr;transition:background .15s,color .15s}' \
    '.cw-fab-link:hover{background:rgba(99,102,241,.04);color:#1C2024}' \
    '.cw-fab-link svg{width:16px;height:16px;fill:currentColor;flex-shrink:0}' \
    '.cw-fab-sep{height:1px;background:#EAEAEA;margin:2px 8px}' \
    'body.dark .cw-fab{background:#2A2B33;border-color:#2E2D32;color:#B0B4BA;box-shadow:0 1px 4px rgba(0,0,0,.3)}' \
    'body.dark .cw-fab:hover{background:#353942;color:#EDEEF0;border-color:#444}' \
    'body.dark .cw-fab-menu{background:rgba(18,19,28,.82);backdrop-filter:blur(20px) saturate(1.4);-webkit-backdrop-filter:blur(20px) saturate(1.4);border-color:rgba(255,255,255,.08);box-shadow:0 0 0 1px rgba(255,255,255,.04),0 4px 16px rgba(0,0,0,.4)}' \
    'body.dark .cw-fab-link{color:#B0B4BA}' \
    'body.dark .cw-fab-link:hover{background:rgba(255,255,255,.04);color:#EDEEF0}' \
    'body.dark .cw-fab-sep{background:#1F1F25}' \
    '</style>' \
    '<div class="cw-fab" onclick="this.nextElementSibling.classList.toggle(\'open\')">' \
    '<svg viewBox="0 0 24 24"><path d="M4 6h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/></svg></div>' \
    '<div class="cw-fab-menu">' \
    '<a href="/bot-builder" class="cw-fab-link"><svg viewBox="0 0 24 24"><path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.07A7.001 7.001 0 0 1 7.07 19H6a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2zM9.5 16a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zm5 0a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z"/></svg>' \
    "Bot Builder</a>" \
    '<a href="/campaign-report" class="cw-fab-link"><svg viewBox="0 0 24 24"><path d="M3 3v18h18V3H3zm4 14H5v-6h2v6zm4 0H9V7h2v10zm4 0h-2v-8h2v8zm4 0h-2V5h2v12z"/></svg>' \
    "Campaign Report</a>" \
    '<div class="cw-fab-sep"></div>' \
    '<a href="/app" class="cw-fab-link"><svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>Chatwoot</a></div>'
  end

  def list_page(ac, user=nil)
    bots = BotFlowStore.all.select{|b| ac.include?(b['account_id'])}
    locale = begin; user&.account_users&.first&.account&.locale; rescue; nil end || 'en'
    [200, sh.merge('Content-Type'=>'text/html; charset=utf-8'), [list_html(bots, locale)]]
  end

  def list_html(bots, locale='en')
    active_count = bots.count{|b| b['active']}
    inactive_count = bots.length - active_count
    total_nodes = bots.sum{|b| begin; (b.dig('flow','drawflow','Home','data')||{}).keys.length; rescue; 0 end }

    rows = bots.map{|b|
      act = b['active']
      inb_names = begin; ids=b['inbox_ids']||[]; ids.empty? ? [] : Inbox.where(id:ids).pluck(:name); rescue; [] end
      inb_display = if inb_names.empty?
        "Not assigned"
      elsif inb_names.length <= 2
        inb_names.join(', ')
      else
        "#{inb_names[0..1].join(', ')} +#{inb_names.length - 2}"
      end
      upd = begin; Time.parse(b['updated_at']).in_time_zone('UTC').strftime('%d/%m/%Y %H:%M'); rescue; '-' end
      crt = begin; Time.parse(b['created_at']).in_time_zone('UTC').strftime('%d/%m/%Y'); rescue; '-' end
      nc = begin; (b.dig('flow','drawflow','Home','data')||{}).keys.length; rescue; 0 end
      "<div class='bc' data-name='#{e(b['name']||'')}' data-desc='#{e(b['description']||'')}' data-active='#{act}' data-updated='#{b['updated_at']||''}' data-created='#{b['created_at']||''}'>" \
      "<a href='/bot-builder/#{e(b['id'])}/edit' class='bc-link'>" \
      "<div class='bc-top'><div class='bc-info'><h3>#{e(b['name']||"Unnamed")}</h3>" \
      "#{"<p>#{e(b['description'])}</p>" if b['description'].to_s.strip.length > 0}" \
      "</div><span class='badge #{act ? "bg" : "bi"}'><span class='badge-dot #{act ? "dot-g" : "dot-n"}'></span>#{act ? "Active" : "Disabled"}</span></div>" \
      "<div class='bc-meta'><span><i class='ti ti-inbox'></i> #{e(inb_display)}</span>" \
      "<span><i class='ti ti-puzzle'></i> #{nc} nodes</span><span><i class='ti ti-clock'></i> #{upd}</span><span><i class='ti ti-calendar'></i> Created #{crt}</span></div>" \
      "</a>" \
      "<div class='bc-act'>" \
      "<button class='btn btn-sm bo' data-tid='#{e(b['id'])}'><i class='ti #{act ? 'ti-player-pause' : 'ti-player-play'}'></i> #{act ? "Disable" : "Enable"}</button>" \
      "<button class='btn btn-sm bd' data-did='#{e(b['id'])}'><i class='ti ti-trash'></i> Delete</button></div></div>"
    }.join

    empty = bots.empty? ? "<div class='empty'><div class='empty-icon'><i class='ti ti-robot'></i></div>" \
      "<h2>No Bots Yet</h2><p>Create your first bot with the visual drag-and-drop editor</p>" \
      "<a href='/bot-builder/new' class='btn bp' style='padding:14px 28px;font-size:16px'><i class='ti ti-plus' style='font-size:18px'></i> New Bot</a></div>" : ""

    stats_html = if bots.any?
      "<div class='stats-bar'>" \
      "<span class='stat-item' data-i18n='stat-active'><span class='stat-dot dot-g'></span>#{active_count} Active</span>" \
      "<span class='stat-sep'>\u00B7</span>" \
      "<span class='stat-item' data-i18n='stat-disabled'><span class='stat-dot dot-n'></span>#{inactive_count} Disabled</span>" \
      "<span class='stat-sep'>\u00B7</span>" \
      "<span class='stat-item'><i class='ti ti-puzzle' style='font-size:14px;vertical-align:middle;margin-right:4px'></i>#{total_nodes} total nodes</span>" \
      "</div>"
    else "" end

    filter_html = if bots.any?
      "<div class='filter-bar'>" \
      "<div class='search-wrap'><i class='ti ti-search'></i><input type='text' id='bot-search' placeholder='Search bots...' autocomplete='off'></div>" \
      "<div class='filter-chips'>" \
      "<button class='fchip active' data-filter='all'>All</button>" \
      "<button class='fchip' data-filter='active'>Active</button>" \
      "<button class='fchip' data-filter='inactive'>Disabled</button>" \
      "</div>" \
      "<select id='bot-sort' class='sort-select'>" \
      "<option value='updated'>Last updated</option>" \
      "<option value='name'>Name</option>" \
      "<option value='created'>Date created</option>" \
      "</select>" \
      "</div>"
    else "" end

    "<!DOCTYPE html><html dir='ltr' lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" \
    "<title>Bot Builder | Chatwoot</title>" \
    "<link href='https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap' rel='stylesheet'>" \
    "<link href='https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@3/dist/tabler-icons.min.css' rel='stylesheet'>" \
    "<style>" \
    ":root{--bg-app:#F8F9FB;--bg-card:#FFFFFF;--bg-surface:#FFFFFF;--border-weak:#E2E4E9;--border-strong:#D1D5DB;--text-12:#111827;--text-11:#4B5563;--text-10:#6B7280;--text-9:#9CA3AF;--btn-bg:#FFFFFF;--overlay:rgba(0,0,0,.08);--label-bg:#F3F4F6;--card-shadow:0 1px 3px rgba(0,0,0,.06),0 4px 12px rgba(0,0,0,.04);--card-hover-shadow:0 2px 8px rgba(0,0,0,.08),0 8px 24px rgba(0,0,0,.06)}" \
    "body.dark{--bg-app:#0F0F14;--bg-card:#1A1B24;--bg-surface:#111118;--border-weak:rgba(255,255,255,.06);--border-strong:rgba(255,255,255,.1);--text-12:#F1F2F6;--text-11:#A1A6B4;--text-10:#6B7280;--text-9:#4B5563;--btn-bg:#1C1E28;--overlay:rgba(0,0,0,.4);--label-bg:#1C1E28;--card-shadow:0 2px 8px rgba(0,0,0,.3),0 8px 24px rgba(0,0,0,.2);--card-hover-shadow:0 4px 12px rgba(0,0,0,.35),0 12px 36px rgba(0,0,0,.25)}" \
    "*{margin:0;padding:0;box-sizing:border-box;scrollbar-width:thin;scrollbar-color:var(--border-strong) transparent}" \
    "::-webkit-scrollbar{width:5px;height:5px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:var(--border-strong);border-radius:5px}::-webkit-scrollbar-thumb:hover{background:var(--text-10)}" \
    "body{font-family:'Inter',-apple-system,system-ui,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Tahoma,Arial,sans-serif;background:var(--bg-app);color:var(--text-12);margin:0;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;font-feature-settings:'cv02','cv03','cv04','cv11';text-rendering:optimizeLegibility}" \
    ".app-shell{display:flex;min-height:100vh}" \
    ".app-nav{width:56px;background:var(--bg-surface);border-left:1px solid var(--border-weak);display:flex;flex-direction:column;align-items:center;padding:12px 0;gap:4px;flex-shrink:0;position:sticky;top:0;height:100vh}" \
    ".app-nav a{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;color:var(--text-10);text-decoration:none;transition:background .15s ease,color .15s ease,box-shadow .2s ease;font-size:0;position:relative}" \
    ".app-nav a:hover{background:rgba(124,58,237,.04);color:var(--text-12)}" \
    ".app-nav a.active{color:#A78BFA;background:rgba(124,58,237,.08);box-shadow:0 0 16px rgba(124,58,237,.15)}" \
    ".app-nav a.active::before{content:'';position:absolute;left:-1px;top:6px;bottom:6px;width:3px;border-radius:0 3px 3px 0;background:linear-gradient(180deg,#7C3AED,#A78BFA)}" \
    ".app-nav .nav-sp{flex:1}" \
    ".app-nav .ti{font-size:20px}" \
    ".app-main{flex:1;overflow-y:auto;min-width:0}" \
    ".wrap{max-width:1200px;margin:0 auto;padding:32px 64px}" \
    ".page-hdr{display:flex;justify-content:space-between;align-items:flex-start;gap:16px;margin-bottom:24px}" \
    ".page-hdr h1{font-size:22px;font-weight:600;letter-spacing:-.03em;color:var(--text-12)}" \
    ".page-hdr p{font-size:14px;color:var(--text-11);margin-top:4px}" \
    ".btn{display:inline-flex;align-items:center;gap:6px;border-radius:10px;font-family:inherit;font-weight:500;font-size:14px;cursor:pointer;border:0;outline:1px solid transparent;transition:background .12s ease,color .12s ease,transform .1s;text-decoration:none}" \
    ".btn:active{transform:scale(.97)}" \
    ".btn-md{padding:8px 16px;height:40px}" \
    ".btn-sm{padding:6px 12px;height:32px;font-size:13px}" \
    ".bp{background:linear-gradient(135deg,#7C3AED,#6366F1);color:#fff;box-shadow:0 1px 3px rgba(124,58,237,.3),0 4px 12px rgba(124,58,237,.15)}.bp:hover{background:linear-gradient(135deg,#8B5CF6,#818CF8);box-shadow:0 2px 8px rgba(124,58,237,.35),0 6px 20px rgba(124,58,237,.2)}" \
    ".bo{background:var(--btn-bg);color:var(--text-12);outline:1px solid var(--border-weak)}.bo:hover{background:var(--label-bg)}" \
    ".bd{background:rgba(229,70,102,.08);color:rgb(229,70,102)}.bd:hover{background:rgba(229,70,102,.18)}" \
    ".btn .ti{vertical-align:middle;font-size:14px}" \
    "" \
    ".stats-bar{display:flex;align-items:center;gap:12px;padding:12px 16px;background:var(--bg-card);border:none;border-radius:14px;margin-bottom:16px;font-size:13px;color:var(--text-11);box-shadow:0 0 0 1px rgba(0,0,0,.03),0 1px 2px rgba(0,0,0,.04),0 4px 12px rgba(0,0,0,.04)}" \
    ".stat-item{display:flex;align-items:center;gap:6px}" \
    ".stat-sep{color:var(--border-strong);font-size:13px}" \
    ".stat-dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}" \
    ".dot-g{background:#12a594}" \
    ".dot-n{background:var(--text-10)}" \
    "" \
    ".filter-bar{display:flex;align-items:center;gap:12px;margin-bottom:20px;flex-wrap:wrap}" \
    ".search-wrap{position:relative;flex:1;min-width:200px;max-width:360px}" \
    ".search-wrap .ti{position:absolute;right:12px;top:50%;transform:translateY(-50%);font-size:16px;color:var(--text-9);pointer-events:none}" \
    ".search-wrap input{width:100%;background:var(--btn-bg);border:1px solid var(--border-weak);outline:none;border-radius:10px;padding:9px 36px 9px 12px;color:var(--text-12);font-family:inherit;font-size:14px;transition:border-color .15s,box-shadow .15s}" \
    ".search-wrap input:focus{border-color:#7C3AED;box-shadow:0 0 0 3px rgba(124,58,237,.1)}" \
    ".search-wrap input:hover{outline-color:var(--text-9)}" \
    ".search-wrap input::placeholder{color:var(--text-9)}" \
    ".filter-chips{display:flex;gap:4px}" \
    ".fchip{padding:6px 14px;border-radius:20px;border:1px solid var(--border-weak);background:transparent;color:var(--text-10);font-family:inherit;font-size:13px;font-weight:500;cursor:pointer;transition:border-color .15s,color .15s,background .15s}" \
    ".fchip:hover{border-color:var(--border-strong);color:var(--text-11)}" \
    ".fchip.active{background:rgba(124,58,237,.1);color:#7C3AED;border-color:rgba(124,58,237,.3)}" \
    ".sort-select{margin-right:auto;background:var(--btn-bg);border:1px solid var(--border-weak);border-radius:8px;padding:6px 12px;color:var(--text-11);font-family:inherit;font-size:13px;cursor:pointer;transition:border-color .15s}" \
    ".sort-select:hover{border-color:var(--border-strong)}" \
    ".sort-select:focus{outline:none;border-color:#7C3AED}" \
    ".sort-select option{background:var(--bg-card)}" \
    "" \
    ".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(380px,1fr));gap:16px}" \
    ".no-results{text-align:center;padding:48px 20px;color:var(--text-9);font-size:14px;display:none}" \
    ".bc{background:var(--bg-card);border-radius:16px;border:none;box-shadow:0 0 0 1px rgba(0,0,0,.03),0 1px 2px rgba(0,0,0,.04),0 4px 16px rgba(0,0,0,.06),0 12px 32px rgba(0,0,0,.04);transition:box-shadow .25s ease,transform .2s ease;overflow:hidden}" \
    ".bc:hover{box-shadow:0 0 0 1.5px rgba(124,58,237,.2),0 2px 4px rgba(0,0,0,.05),0 8px 24px rgba(0,0,0,.08),0 16px 40px rgba(0,0,0,.05);transform:translateY(-2px)}" \
    ".bc-link{display:block;padding:20px 24px 12px;text-decoration:none;color:inherit;cursor:pointer}" \
    ".bc-top{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px}" \
    ".bc-info h3{font-size:15px;font-weight:600;letter-spacing:-.01em;color:var(--text-12);margin-bottom:4px}.bc-info p{font-size:13px;color:var(--text-10);line-height:1.4}" \
    ".badge{padding:3px 10px;border-radius:20px;font-size:12px;font-weight:500;white-space:nowrap;border:1px solid;display:flex;align-items:center;gap:5px}" \
    ".badge-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}" \
    ".bg{background:rgba(18,165,148,.08);color:rgb(18,165,148);border-color:rgba(18,165,148,.2)}" \
    ".bi{background:rgba(139,141,152,.06);color:var(--text-9);border-color:rgba(139,141,152,.15)}" \
    ".bc-meta{display:flex;gap:16px;flex-wrap:wrap;font-size:13px;color:var(--text-9)}" \
    ".bc-meta .ti{font-size:14px;vertical-align:middle;margin-right:3px}" \
    ".bc-act{display:flex;gap:6px;padding:0 24px 16px;border-top:1px solid var(--border-weak);padding-top:12px}" \
    ".empty{text-align:center;padding:80px 20px}" \
    ".empty-icon{width:80px;height:80px;border-radius:24px;background:linear-gradient(135deg,rgba(124,58,237,.06),rgba(124,58,237,.03));border:1px solid rgba(124,58,237,.12);display:flex;align-items:center;justify-content:center;margin:0 auto 24px}" \
    ".empty-icon .ti{font-size:36px;color:#7C3AED}" \
    ".empty h2{font-size:20px;font-weight:600;color:var(--text-12);margin-bottom:8px;letter-spacing:-.02em}.empty p{color:var(--text-11);margin-bottom:24px;font-size:14px}" \
    ".toast{position:fixed;bottom:36px;left:50%;transform:translateX(-50%) translateY(100px);background:var(--bg-card);border:1px solid var(--border-weak);color:var(--text-12);padding:10px 22px;border-radius:100px;font-size:13px;font-weight:600;z-index:9999;transition:transform .35s cubic-bezier(.2,.8,.2,1);box-shadow:var(--card-hover-shadow);backdrop-filter:blur(16px) saturate(1.3);-webkit-backdrop-filter:blur(16px) saturate(1.3)}.toast.show{transform:translateX(-50%) translateY(0)}" \
    "@media(max-width:768px){.wrap{padding:16px}.app-nav{width:48px}.app-nav .ti{font-size:18px}.filter-bar{flex-direction:column;align-items:stretch}.search-wrap{max-width:100%}.sort-select{margin-right:0}}" \
    "</style></head><body>" \
    "<script>(function(){var s=null;try{var k=Object.keys(localStorage);for(var i=0;i<k.length;i++){if(k[i].indexOf('COLOR_SCHEME')!==-1){s=localStorage.getItem(k[i]);break}}}catch(e){}if(s==='dark'||(s!=='light'&&window.matchMedia('(prefers-color-scheme:dark)').matches))document.body.classList.add('dark')})()</script>" \
    "<div class='app-shell'>" \
    "<nav class='app-nav'><a href='/bot-builder' class='active' title='Bot Builder'><i class='ti ti-robot'></i></a><a href='/campaign-report' title='Campaign Report'><i class='ti ti-chart-bar'></i></a><div class='nav-sp'></div><a href='/app' title='Chatwoot'><i class='ti ti-layout-dashboard'></i></a></nav>" \
    "<div class='app-main'>" \
    "<div class='wrap'><div class='page-hdr'><div><h1>Bot Builder</h1><p>Manage automated bots for your inboxes</p></div><a href='/bot-builder/new' class='btn btn-md bp'><i class='ti ti-plus' style='font-size:16px'></i> New Bot</a></div>" \
    "#{stats_html}#{filter_html}" \
    "#{bots.empty? ? empty : "<div class='grid' id='bot-grid'>#{rows}</div><div class='no-results' id='no-results'><i class='ti ti-search-off' style='font-size:32px;display:block;margin-bottom:8px;opacity:.5'></i>No matching bots found</div>"}</div>" \
    "</div></div>" \
    "<div id='toast' class='toast'></div>" \
    "<script>" \
    "var _locale='#{locale}';" \
    "var _isHe=_locale==='he';" \
    "if(_isHe){document.documentElement.setAttribute('dir','rtl');document.documentElement.setAttribute('lang','he')}" \
    "(function(){if(!_isHe)return;" \
    "var h1=document.querySelector('.page-hdr h1');if(h1)h1.textContent='\\u05D1\\u05D5\\u05E0\\u05D4 \\u05D1\\u05D5\\u05D8\\u05D9\\u05DD';" \
    "var sub=document.querySelector('.page-hdr p');if(sub)sub.textContent='\\u05E0\\u05D4\\u05DC \\u05D1\\u05D5\\u05D8\\u05D9\\u05DD \\u05D0\\u05D5\\u05D8\\u05D5\\u05DE\\u05D8\\u05D9\\u05D9\\u05DD \\u05DC\\u05EA\\u05D9\\u05D1\\u05D5\\u05EA \\u05D4\\u05D3\\u05D5\\u05D0\\u05E8';" \
    "var nb=document.querySelector('.page-hdr .bp');if(nb)nb.innerHTML='<i class=\"ti ti-plus\" style=\"font-size:16px\"></i> \\u05D1\\u05D5\\u05D8 \\u05D7\\u05D3\\u05E9';" \
    "var si=document.querySelector('[data-i18n=\"stat-active\"]');if(si)si.innerHTML='<span class=\"stat-dot dot-g\"></span>'+si.textContent.match(/\\d+/)[0]+' \\u05E4\\u05E2\\u05D9\\u05DC\\u05D9\\u05DD';" \
    "var sd=document.querySelector('[data-i18n=\"stat-disabled\"]');if(sd)sd.innerHTML='<span class=\"stat-dot dot-n\"></span>'+sd.textContent.match(/\\d+/)[0]+' \\u05DE\\u05D5\\u05E9\\u05D1\\u05EA\\u05D9\\u05DD';" \
    "var se=document.getElementById('bot-search');if(se)se.placeholder='\\u05D7\\u05E4\\u05E9 \\u05D1\\u05D5\\u05D8\\u05D9\\u05DD...';" \
    "var so=document.getElementById('bot-sort');if(so){so.options[0].text='\\u05E2\\u05D3\\u05DB\\u05D5\\u05DF \\u05D0\\u05D7\\u05E8\\u05D5\\u05DF';so.options[1].text='\\u05E9\\u05DD';so.options[2].text='\\u05EA\\u05D0\\u05E8\\u05D9\\u05DA \\u05D9\\u05E6\\u05D9\\u05E8\\u05D4'}" \
    "var em=document.querySelector('.empty h2');if(em)em.textContent='\\u05D0\\u05D9\\u05DF \\u05D1\\u05D5\\u05D8\\u05D9\\u05DD \\u05E2\\u05D3\\u05D9\\u05D9\\u05DF';" \
    "var ep=document.querySelector('.empty p');if(ep)ep.textContent='\\u05E6\\u05D5\\u05E8 \\u05D0\\u05EA \\u05D4\\u05D1\\u05D5\\u05D8 \\u05D4\\u05E8\\u05D0\\u05E9\\u05D5\\u05DF \\u05E9\\u05DC\\u05DA \\u05E2\\u05DD \\u05D4\\u05E2\\u05D5\\u05E8\\u05DA \\u05D4\\u05D5\\u05D9\\u05D6\\u05D5\\u05D0\\u05DC\\u05D9';" \
    "var eb=document.querySelector('.empty .bp');if(eb)eb.innerHTML='<i class=\"ti ti-plus\" style=\"font-size:18px\"></i> \\u05D1\\u05D5\\u05D8 \\u05D7\\u05D3\\u05E9';" \
    "var nr=document.getElementById('no-results');if(nr)nr.innerHTML='<i class=\"ti ti-search-off\" style=\"font-size:32px;display:block;margin-bottom:8px;opacity:.5\"></i>\\u05DC\\u05D0 \\u05E0\\u05DE\\u05E6\\u05D0\\u05D5 \\u05D1\\u05D5\\u05D8\\u05D9\\u05DD \\u05EA\\u05D5\\u05D0\\u05DE\\u05D9\\u05DD';" \
    "})();" \
    "document.addEventListener('click',function(e){" \
    "if(e.target.closest('.bc-link'))return;" \
    "var t=e.target.closest('[data-tid]');if(t){e.preventDefault();e.stopPropagation();fetch('/bot-builder/api/bots/'+t.getAttribute('data-tid')+'/toggle',{method:'POST'}).then(function(r){if(r.ok)location.reload()});return}" \
    "var d=e.target.closest('[data-did]');if(d&&confirm(_isHe?'\\u05DC\\u05DE\\u05D7\\u05D5\\u05E7 \\u05D0\\u05EA \\u05D4\\u05D1\\u05D5\\u05D8?':'Delete this bot?')){e.preventDefault();e.stopPropagation();fetch('/bot-builder/api/bots/'+d.getAttribute('data-did'),{method:'DELETE'}).then(function(r){if(r.ok)location.reload()})}" \
    "});" \
    "var searchEl=document.getElementById('bot-search');" \
    "var grid=document.getElementById('bot-grid');" \
    "var noRes=document.getElementById('no-results');" \
    "var chips=document.querySelectorAll('.fchip');" \
    "var sortEl=document.getElementById('bot-sort');" \
    "var currentFilter='all';" \
    "function filterBots(){" \
    "if(!grid)return;" \
    "var q=(searchEl?searchEl.value:'').trim().toLowerCase();" \
    "var cards=grid.querySelectorAll('.bc');" \
    "var vis=0;" \
    "for(var i=0;i<cards.length;i++){" \
    "var c=cards[i];var name=(c.getAttribute('data-name')||'').toLowerCase();var desc=(c.getAttribute('data-desc')||'').toLowerCase();var isActive=c.getAttribute('data-active')==='true';" \
    "var matchSearch=!q||name.indexOf(q)!==-1||desc.indexOf(q)!==-1;" \
    "var matchFilter=currentFilter==='all'||(currentFilter==='active'&&isActive)||(currentFilter==='inactive'&&!isActive);" \
    "c.style.display=(matchSearch&&matchFilter)?'':'none';" \
    "if(matchSearch&&matchFilter)vis++;" \
    "}" \
    "if(noRes)noRes.style.display=vis===0?'block':'none';" \
    "}" \
    "function updChipCounts(){" \
    "if(!grid)return;var cards=grid.querySelectorAll('.bc');" \
    "var all=cards.length,act=0,inact=0;" \
    "for(var i=0;i<cards.length;i++){var a=cards[i].getAttribute('data-active')==='true';if(a)act++;else inact++}" \
    "chips.forEach(function(ch){var f=ch.getAttribute('data-filter');" \
    "var cnt=f==='all'?all:f==='active'?act:inact;" \
    "var lbl=f==='all'?(_isHe?'\\u05D4\\u05DB\\u05DC':'All'):f==='active'?(_isHe?'\\u05E4\\u05E2\\u05D9\\u05DC\\u05D9\\u05DD':'Active'):(_isHe?'\\u05DE\\u05D5\\u05E9\\u05D1\\u05EA\\u05D9\\u05DD':'Disabled');" \
    "ch.textContent=lbl+' ('+cnt+')';" \
    "})}" \
    "updChipCounts();" \
    "if(searchEl)searchEl.addEventListener('input',filterBots);" \
    "for(var i=0;i<chips.length;i++){chips[i].addEventListener('click',function(){" \
    "for(var j=0;j<chips.length;j++)chips[j].classList.remove('active');" \
    "this.classList.add('active');currentFilter=this.getAttribute('data-filter');filterBots();" \
    "})}" \
    "function doSort(v){" \
    "if(!grid)return;var cards=Array.from(grid.querySelectorAll('.bc'));" \
    "cards.sort(function(a,b){" \
    "if(v==='name')return(a.getAttribute('data-name')||'').localeCompare(b.getAttribute('data-name')||'');" \
    "if(v==='updated')return(b.getAttribute('data-updated')||'').localeCompare(a.getAttribute('data-updated')||'');" \
    "if(v==='created')return(b.getAttribute('data-created')||'').localeCompare(a.getAttribute('data-created')||'');" \
    "return 0;" \
    "});" \
    "cards.forEach(function(c){grid.appendChild(c)});" \
    "}" \
    "if(sortEl){" \
    "var sv=localStorage.getItem('bb-sort');if(sv){sortEl.value=sv;doSort(sv)}" \
    "sortEl.addEventListener('change',function(){var v=this.value;localStorage.setItem('bb-sort',v);doSort(v)});" \
    "}" \
    "</script></body></html>"
  end

  def editor_page(bot_id, user=nil)
    [200, sh.merge('Content-Type'=>'text/html; charset=utf-8'), [editor_html(bot_id, user)]]
  end

  def editor_html(bot_id, user=nil)
    bid_js = bot_id ? "\"#{e(bot_id)}\"" : 'null'
    locale = begin; user&.account_users&.first&.account&.locale; rescue; nil end || 'en'
    # Use single-quoted heredoc so Ruby doesn't interpret backslashes
    # All Hebrew text is actual UTF-8, emojis use HTML entities
    html = <<~'ENDHTML'
<!DOCTYPE html><html lang="en" dir="ltr"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Bot Editor | Chatwoot</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@3/dist/tabler-icons.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/drawflow@0.0.59/dist/drawflow.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/dagre@0.8.5/dist/dagre.min.js"></script>
<style>
/* === THEME VARIABLES (Premium v2) === */
:root{
--bg-app:#F8F9FB;--bg-shell:#FFFFFF;--bg-shell-border:#E2E4E9;--bg-canvas:#F0F1F5;
--canvas-dot:rgba(0,0,0,.08);
--text-primary:#111827;--text-secondary:#4B5563;--text-muted:#6B7280;--text-faint:#9CA3AF;
--bg-node:#FFFFFF;--node-border:rgba(0,0,0,.08);--node-border-hover:rgba(0,0,0,.14);
--node-inset:none;
--node-shadow:0 1px 2px rgba(0,0,0,.04),0 4px 16px rgba(0,0,0,.06),0 12px 40px rgba(0,0,0,.06);
--node-hover-shadow:0 2px 4px rgba(0,0,0,.05),0 8px 24px rgba(0,0,0,.08),0 20px 50px rgba(0,0,0,.07);
--summary-bg:#F3F4F6;--summary-text:#4B5563;
--input-bg:#F9FAFB;--input-border:#E2E4E9;--input-hover:#D1D5DB;--input-text:#111827;--input-placeholder:#9CA3AF;
--port-bg:#FFFFFF;
--wire-color:#94A3B8;--wire-opacity:.9;
--accent:#7C3AED;--accent-10:rgba(124,58,237,.1);--accent-18:rgba(124,58,237,.18);--accent-glow:rgba(124,58,237,.2);
--nav-bg:#FFFFFF;--nav-border:#E2E4E9;--nav-text:#9CA3AF;--nav-hover:rgba(0,0,0,.03);--nav-active-text:#7C3AED;--nav-active-bg:rgba(124,58,237,.06);--nav-indicator:linear-gradient(180deg,#7C3AED,#A78BFA);
--tb-bg:#FFFFFF;--tb-border:#E2E4E9;--tb-shadow:0 1px 0 rgba(0,0,0,.04);
--sidebar-bg:#FFFFFF;--sidebar-border:#E2E4E9;
--dn-hover:rgba(0,0,0,.03);
--toggle-color:#9CA3AF;--toggle-hover:#4B5563;--toggle-hover-bg:rgba(0,0,0,.04);
--na-bg:#FFFFFF;--na-border:rgba(0,0,0,.08);--na-hover:#F3F4F6;--na-shadow:0 2px 8px rgba(0,0,0,.1);
--olb-border:#E2E4E9;--olb-text:#9CA3AF;
--ctx-bg:#FFFFFF;--ctx-border:rgba(0,0,0,.08);--ctx-shadow:0 4px 12px rgba(0,0,0,.08),0 16px 40px rgba(0,0,0,.06);--ctx-hover:rgba(0,0,0,.04);--ctx-text:#111827;--ctx-key:#9CA3AF;--ctx-sep:#E2E4E9;
--scrollbar-thumb:#D1D5DB;--scrollbar-hover:#B0B4BA;
--note-bg:#FFFEF5;--note-border:rgba(202,138,4,.15);
--del-bg:rgba(220,38,38,.06);--del-hover:rgba(220,38,38,.1);--del-border:rgba(220,38,38,.12);
--conn-label:#6B7280;--header-border:#E2E4E9;
--status-bg:#FFFFFF;--status-border:#E2E4E9;--status-text:#6B7280;--status-sep:#D1D5DB;
--loading-bg:#F0F1F5;
--zoom-bg:#FFFFFF;--zoom-border:rgba(0,0,0,.08);--zoom-text:#6B7280;
--hint-bg:rgba(0,0,0,.04);--hint-text:#9CA3AF;
--minimap-bg:rgba(255,255,255,.95);--minimap-border:rgba(0,0,0,.08);
--snap-bg:#FFFFFF;--snap-border:rgba(0,0,0,.08);--snap-text:#9CA3AF;--snap-active-text:#7C3AED;--snap-active-border:rgba(124,58,237,.3);--snap-active-bg:rgba(124,58,237,.06);
--toast-ok-bg:rgba(16,185,129,.1);--toast-ok-text:#059669;--toast-ok-border:rgba(16,185,129,.2);
--toast-err-bg:rgba(239,68,68,.1);--toast-err-text:#DC2626;--toast-err-border:rgba(239,68,68,.2);
--kbd-bg:#F3F4F6;--kbd-text:#6B7280;--kbd-border:#E2E4E9;
--props-bg:#FFFFFF;--props-border:#E2E4E9;
--empty-icon-bg:rgba(124,58,237,.06);--empty-icon-border:rgba(124,58,237,.12);
--badge-bg:rgba(124,58,237,.06);--badge-text:#7C3AED;
--badge-green-bg:rgba(16,185,129,.06);--badge-green-text:#059669;
--search-bg:#F3F4F6;--search-border:#E2E4E9;--search-focus:#7C3AED;--search-hover:#D1D5DB;
--select-option-bg:#FFFFFF;
--drop-hover:rgba(124,58,237,.15);
--warning-text:#D97706;--success-text:#059669;--danger-text:#EF4444;
--delete-bg:rgba(229,70,102,.1);--delete-text:rgb(229,70,102);--delete-hover:rgba(229,70,102,.2);
--valid-text:#ff6b7a;--valid-bg:rgba(220,53,69,.08);--valid-hover:rgba(220,53,69,.15);
--nebula-a:rgba(124,58,237,.04);--nebula-b:rgba(59,130,246,.03);--nebula-c:rgba(236,72,153,.02);
}
body.dark{
--bg-app:#0F0F14;--bg-shell:#111118;--bg-shell-border:rgba(255,255,255,.06);--bg-canvas:#0A0B10;
--canvas-dot:rgba(255,255,255,.05);
--text-primary:#F1F2F6;--text-secondary:#A1A6B4;--text-muted:#6B7280;--text-faint:#4B5563;
--bg-node:#1E1F2A;--node-border:rgba(255,255,255,.08);--node-border-hover:rgba(255,255,255,.14);
--node-inset:none;
--node-shadow:0 1px 2px rgba(0,0,0,.2),0 4px 16px rgba(0,0,0,.25),0 12px 40px rgba(0,0,0,.2);
--node-hover-shadow:0 2px 4px rgba(0,0,0,.25),0 8px 24px rgba(0,0,0,.3),0 20px 50px rgba(0,0,0,.25);
--summary-bg:#1C1E28;--summary-text:#A1A6B4;
--input-bg:#1C1E28;--input-border:#262838;--input-hover:#3A3B52;--input-text:#F1F2F6;--input-placeholder:#4B5563;
--port-bg:rgba(20,21,30,.9);
--wire-color:#64748B;--wire-opacity:.8;
--accent:#8B5CF6;--accent-10:rgba(139,92,246,.12);--accent-18:rgba(139,92,246,.2);--accent-glow:rgba(139,92,246,.2);
--nav-bg:#0C0D14;--nav-border:rgba(255,255,255,.04);--nav-text:#4B5563;--nav-hover:rgba(255,255,255,.04);--nav-active-text:#A78BFA;--nav-active-bg:rgba(139,92,246,.08);--nav-indicator:linear-gradient(180deg,#7C3AED,#A78BFA);
--tb-bg:rgba(12,13,18,.72);--tb-border:rgba(255,255,255,.06);--tb-shadow:0 1px 0 rgba(0,0,0,.3),0 4px 16px rgba(0,0,0,.2);
--sidebar-bg:rgba(17,17,24,.92);--sidebar-border:rgba(255,255,255,.06);
--dn-hover:rgba(255,255,255,.04);
--toggle-color:#4B5563;--toggle-hover:#A1A6B4;--toggle-hover-bg:rgba(255,255,255,.06);
--na-bg:rgba(28,30,38,.95);--na-border:rgba(255,255,255,.08);--na-hover:rgba(255,255,255,.06);--na-shadow:0 2px 8px rgba(0,0,0,.3);
--olb-border:rgba(255,255,255,.06);--olb-text:#4B5563;
--ctx-bg:rgba(18,19,28,.82);--ctx-border:rgba(255,255,255,.08);--ctx-shadow:0 0 0 1px rgba(255,255,255,.04),0 4px 8px rgba(0,0,0,.2),0 12px 40px rgba(0,0,0,.35),0 24px 60px rgba(0,0,0,.25),inset 0 1px 0 rgba(255,255,255,.04);--ctx-hover:rgba(255,255,255,.06);--ctx-text:#F1F2F6;--ctx-key:#4B5563;--ctx-sep:rgba(255,255,255,.06);
--scrollbar-thumb:#2E2D32;--scrollbar-hover:#444;
--note-bg:#1E1D18;--note-border:rgba(202,138,4,.2);
--del-bg:rgba(239,68,68,.08);--del-hover:rgba(239,68,68,.15);--del-border:rgba(220,38,38,.15);
--conn-label:#4B5563;--header-border:rgba(255,255,255,.06);
--status-bg:#0F0F14;--status-border:rgba(255,255,255,.06);--status-text:#4B5563;--status-sep:#2E2D32;
--loading-bg:#0A0B10;
--zoom-bg:rgba(22,23,31,.9);--zoom-border:rgba(255,255,255,.08);--zoom-text:#A1A6B4;
--hint-bg:rgba(255,255,255,.04);--hint-text:#4B5563;
--minimap-bg:rgba(15,16,20,.85);--minimap-border:rgba(255,255,255,.06);
--snap-bg:rgba(22,23,31,.9);--snap-border:rgba(255,255,255,.08);--snap-text:#4B5563;--snap-active-text:#8B5CF6;--snap-active-border:rgba(139,92,246,.3);--snap-active-bg:rgba(139,92,246,.06);
--toast-ok-bg:rgba(16,185,129,.12);--toast-ok-text:#10B981;--toast-ok-border:rgba(16,185,129,.2);
--toast-err-bg:rgba(239,68,68,.12);--toast-err-text:#EF4444;--toast-err-border:rgba(239,68,68,.2);
--kbd-bg:#1C1E28;--kbd-text:#A1A6B4;--kbd-border:rgba(255,255,255,.06);
--props-bg:#111118;--props-border:rgba(255,255,255,.06);
--empty-icon-bg:rgba(139,92,246,.06);--empty-icon-border:rgba(139,92,246,.12);
--badge-bg:rgba(139,92,246,.08);--badge-text:#A78BFA;
--badge-green-bg:rgba(16,185,129,.08);--badge-green-text:#10B981;
--search-bg:#1C1E28;--search-border:rgba(255,255,255,.06);--search-focus:#8B5CF6;--search-hover:rgba(255,255,255,.12);
--select-option-bg:#16171F;
--drop-hover:rgba(139,92,246,.2);
--warning-text:#FBBF24;--success-text:#10B981;--danger-text:#FCA5A5;
--delete-bg:rgba(248,113,113,.12);--delete-text:#F87171;--delete-hover:rgba(248,113,113,.25);
--valid-text:#FCA5A5;--valid-bg:rgba(239,68,68,.12);--valid-hover:rgba(248,113,113,.2);
--nebula-a:rgba(139,92,246,.07);--nebula-b:rgba(59,130,246,.05);--nebula-c:rgba(236,72,153,.03);
}
*{margin:0;padding:0;box-sizing:border-box;scrollbar-width:thin;scrollbar-color:var(--scrollbar-thumb) transparent}
::-webkit-scrollbar{width:5px;height:5px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:var(--scrollbar-thumb);border-radius:5px}::-webkit-scrollbar-thumb:hover{background:var(--scrollbar-hover)}
body{font-family:'Inter',-apple-system,system-ui,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Tahoma,Arial,sans-serif;background:var(--bg-app);color:var(--text-primary);margin:0;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;font-feature-settings:'cv02','cv03','cv04','cv11';text-rendering:optimizeLegibility}
.app-shell{display:flex;height:100vh;overflow:hidden}
.app-nav{width:56px;background:var(--nav-bg);border-right:1px solid var(--nav-border);display:flex;flex-direction:column;align-items:center;padding:12px 0;gap:4px;flex-shrink:0;z-index:200}
.app-nav a{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;color:var(--nav-text);text-decoration:none;transition:background .15s ease,color .15s ease,box-shadow .2s ease;font-size:0;position:relative}
.app-nav a:hover{background:var(--nav-hover);color:var(--text-primary)}
.app-nav a.active{color:var(--nav-active-text);background:var(--nav-active-bg);box-shadow:0 0 16px var(--accent-glow)}
.app-nav a.active::before{content:'';position:absolute;left:-1px;top:6px;bottom:6px;width:3px;border-radius:0 3px 3px 0;background:var(--nav-indicator)}
.app-nav .nav-sp{flex:1}
.app-nav .ti{font-size:20px}
.app-main{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0;position:relative}
.tbtn .ti,.tb-logo .ti{font-size:16px;line-height:1;vertical-align:middle}
.nh .ti{font-size:15px;line-height:1}
.ctx-item .ti{font-size:16px}
.tb{background:var(--tb-bg);border:1px solid var(--tb-border);padding:8px 16px;display:flex;align-items:center;gap:10px;z-index:100;direction:ltr;height:48px;box-shadow:0 0 0 1px rgba(0,0,0,.03),0 2px 8px rgba(0,0,0,.06),0 8px 24px rgba(0,0,0,.04),inset 0 1px 0 rgba(255,255,255,.5);position:absolute;top:12px;left:50%;transform:translateX(-50%);width:auto;max-width:calc(100% - 24px);border-radius:16px;backdrop-filter:blur(20px) saturate(1.6);-webkit-backdrop-filter:blur(20px) saturate(1.6)}
.tb-logo{font-size:14px;font-weight:600;color:var(--text-primary);margin-right:12px;white-space:nowrap;display:flex;align-items:center;gap:6px;letter-spacing:-.02em}
.tb-logo .ti{background:linear-gradient(135deg,#7C3AED,#A78BFA);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
.tb-center{display:flex;align-items:center;gap:6px}
.tb-bot-name{background:transparent;border:none;border-bottom:1px dashed var(--text-faint);outline:none;color:var(--text-primary);font-family:inherit;font-size:14px;font-weight:500;text-align:center;padding:4px 10px;border-radius:6px 6px 0 0;min-width:140px;max-width:280px;direction:ltr;transition:background .15s,border-color .15s}
.tb-bot-name:hover{background:var(--nav-hover);border-color:var(--accent)}
.tb-bot-name:focus{background:var(--nav-hover);outline:1px solid var(--accent);box-shadow:0 0 0 3px var(--accent-10);border-color:transparent}
.tb-bot-name::placeholder{color:var(--text-faint);font-weight:400;font-style:italic}
.tb-group{display:flex;align-items:center;gap:2px}
.tb-divider{width:1px;height:24px;background:var(--tb-border);margin:0 6px;flex-shrink:0;opacity:.6}
.tb input[type="text"]{background:var(--search-bg);border:none;outline:1px solid var(--search-border);border-radius:8px;padding:6px 12px;color:var(--text-primary);font-family:inherit;font-size:14px;direction:ltr;transition:outline-color .15s ease}
.tb input[type="text"]:focus{outline-color:var(--accent)}
.tb input[type="text"]:hover{outline-color:var(--search-hover)}
.tb input::placeholder{color:var(--text-muted)}
.sp{flex:1}
.tbtn{display:inline-flex;align-items:center;gap:5px;padding:7px 13px;border-radius:10px;font-family:inherit;font-weight:500;font-size:13px;cursor:pointer;border:none;transition:background .12s ease,color .12s ease,opacity .2s ease;text-decoration:none;color:var(--text-secondary);background:transparent}
.tbtn:hover{background:var(--nav-hover);color:var(--text-primary)}
.tbtn:active{transform:scale(.97)}
.tbtn-save{background:linear-gradient(135deg,#7C3AED,#6366F1);color:#fff;padding:7px 18px;font-weight:600;border-radius:10px;box-shadow:0 1px 3px rgba(124,58,237,.3),0 4px 12px rgba(124,58,237,.15)}.tbtn-save:hover{background:linear-gradient(135deg,#8B5CF6,#818CF8);box-shadow:0 2px 8px rgba(124,58,237,.35),0 6px 20px rgba(124,58,237,.2)}
.tbtn-back{background:var(--search-bg);outline:1px solid var(--tb-border);border-radius:10px}

/* Layout: RTL flex = right sidebar first visually */
.layout{display:flex;flex-direction:row-reverse;flex:1;overflow:hidden;padding-top:72px}

/* Right sidebar = Collapsible node palette */
.side-nodes{width:52px;background:var(--sidebar-bg);border-left:1px solid var(--sidebar-border);overflow:hidden;flex-shrink:0;direction:ltr;transition:width 280ms cubic-bezier(.4,0,.2,1);display:flex;flex-direction:column}
.side-nodes.expanded{width:272px}
.nodes-toggle{width:100%;height:44px;display:flex;align-items:center;justify-content:center;cursor:pointer;color:var(--text-secondary);flex-shrink:0;border:none;border-bottom:1px solid var(--sidebar-border);background:transparent;transition:background .2s,transform .25s;font-size:16px;outline:none}
.side-nodes.expanded .nodes-toggle{transform:rotate(180deg)}
.nodes-toggle:hover{background:var(--nav-hover)}
.nodes-content{flex:1;overflow-y:auto;padding:8px 6px}
.side-nodes.expanded .nodes-content{padding:10px 12px}
.side-nodes h3{font-size:12px;text-transform:uppercase;letter-spacing:.5px;color:var(--text-secondary);margin-bottom:8px;font-weight:500;white-space:nowrap;overflow:hidden}
.side-nodes:not(.expanded) h3{display:none}
.sec{margin-bottom:12px}
.sec-t{font-size:10px;color:var(--text-faint);text-transform:uppercase;letter-spacing:.8px;font-weight:600;margin-bottom:8px;padding-bottom:6px;border-bottom:1px solid var(--sidebar-border);white-space:nowrap;overflow:hidden;padding-right:10px;border-right:3px solid var(--sec-color,#696E77)}
.side-nodes:not(.expanded) .sec-t{display:none}
.side-nodes:not(.expanded) .sec{border-right:2px solid var(--sec-color,#696E77);border-radius:0;margin-bottom:8px;padding-right:4px}
.side-nodes:not(.expanded) .node-search{display:none}
.dn{padding:8px 10px;margin-bottom:3px;border-radius:10px;cursor:grab;font-size:13px;font-weight:500;display:flex;align-items:center;gap:10px;transition:background .15s ease,box-shadow .15s ease;border:1px solid transparent;user-select:none;white-space:nowrap;overflow:hidden}
.side-nodes:not(.expanded) .dn{padding:8px;justify-content:center;width:38px;margin:0 auto 3px}
.side-nodes:not(.expanded) .dn-label{display:none}
.dn:hover{background:var(--dn-hover);border-color:var(--sidebar-border);box-shadow:0 1px 4px rgba(0,0,0,.04)}
.dn:active{cursor:grabbing;opacity:.7;box-shadow:0 2px 8px rgba(0,0,0,.08)}
.dn i{width:32px;height:32px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;font-style:normal}
.side-nodes:not(.expanded) .dn i{width:24px;height:24px;font-size:12px}
.dn-or i{background:rgba(255,107,53,.2)}.dn-or{background:rgba(255,107,53,.06)}
.dn-bl i{background:rgba(74,158,255,.2)}.dn-bl{background:rgba(74,158,255,.06)}
.dn-pu i{background:rgba(155,89,182,.2)}.dn-pu{background:rgba(155,89,182,.06)}
.dn-ye i{background:rgba(241,196,15,.2)}.dn-ye{background:rgba(241,196,15,.06)}
.dn-gr i{background:rgba(39,174,96,.2)}.dn-gr{background:rgba(39,174,96,.06)}
.dn-tl i{background:rgba(0,184,148,.2)}.dn-tl{background:rgba(0,184,148,.06)}
.dn-rd i{background:rgba(231,76,60,.2)}.dn-rd{background:rgba(231,76,60,.06)}
.dn-dl i{background:rgba(142,68,173,.2)}.dn-dl{background:rgba(142,68,173,.06)}
.dn-wb i{background:rgba(52,152,219,.2)}.dn-wb{background:rgba(52,152,219,.06)}
.dn-nt i{background:rgba(149,165,166,.2)}.dn-nt{background:rgba(149,165,166,.06)}
.dn-bt i{background:rgba(46,204,113,.2)}.dn-bt{background:rgba(46,204,113,.06)}
.dn-vi i{background:rgba(155,89,255,.2)}.dn-vi{background:rgba(155,89,255,.06)}

/* Left panel = Overlay settings */
.side-cfg{position:fixed;top:12px;left:12px;width:340px;height:calc(100vh - 24px);background:var(--sidebar-bg);backdrop-filter:blur(24px) saturate(1.5);-webkit-backdrop-filter:blur(24px) saturate(1.5);border:1px solid var(--sidebar-border);border-radius:16px;padding:20px;overflow-y:auto;direction:ltr;z-index:500;transform:translateX(-352px);transition:transform 280ms cubic-bezier(.4,0,.2,1);pointer-events:none;box-shadow:0 0 0 1px rgba(0,0,0,.03),4px 0 16px rgba(0,0,0,.06),8px 0 32px rgba(0,0,0,.04)}
.side-cfg.open{transform:translateX(0);pointer-events:auto}
.side-cfg-close{position:absolute;top:14px;left:14px;height:34px;padding:0 12px;border-radius:10px;background:transparent;border:1px solid var(--sidebar-border);color:var(--text-secondary);font-size:12px;font-weight:500;font-family:inherit;display:flex;align-items:center;gap:6px;cursor:pointer;transition:background .15s,color .15s}
.side-cfg-close:hover{background:var(--nav-hover);color:var(--text-primary)}
.side-cfg-close kbd{font-size:10px;padding:1px 5px;border-radius:5px;background:var(--kbd-bg);color:var(--text-faint);border:1px solid var(--sidebar-border);font-family:inherit}
.side-cfg h3{font-size:13px;color:var(--text-primary);font-weight:600;margin-bottom:12px;letter-spacing:-.01em}
.side-cfg label{display:block;font-size:14px;color:var(--text-secondary);margin-bottom:4px;font-weight:500}
.inbox-list{display:flex;flex-direction:column;gap:6px;margin-bottom:14px}
.inbox-item{display:flex;align-items:center;gap:8px;padding:10px 12px;border-radius:10px;background:var(--search-bg);cursor:pointer;transition:background .15s ease,border-color .15s ease;border:1px solid transparent}
.inbox-item:hover{background:var(--nav-hover)}
.inbox-item.sel{background:var(--accent-10);border-color:rgba(124,58,237,.2)}
.inbox-item input{accent-color:var(--accent);width:16px;height:16px}
.inbox-item span{font-size:13px;color:var(--text-secondary)}
.inbox-item small{font-size:10px;color:var(--text-faint);margin-right:auto}
.sr{display:flex;justify-content:space-between;padding:6px 0;border-bottom:1px solid var(--sidebar-border);font-size:13px}
.sr .lab{color:var(--text-muted)}.sr .val{color:var(--text-primary);font-weight:600}
.sep{height:1px;background:var(--sidebar-border);margin:14px 0}

/* Canvas - MUST be LTR */
.canvas{flex:1;position:relative;overflow:hidden;direction:ltr}
#drawflow{width:100%;height:100%;background-color:var(--bg-canvas);background-image:radial-gradient(circle at 15% 85%,var(--nebula-a,rgba(124,58,237,.04)) 0%,transparent 50%),radial-gradient(circle at 85% 15%,var(--nebula-b,rgba(59,130,246,.03)) 0%,transparent 50%),radial-gradient(circle at 50% 20%,var(--nebula-c,rgba(236,72,153,.02)) 0%,transparent 40%),radial-gradient(circle,var(--canvas-dot) 1px,transparent 1px);background-size:100% 100%,100% 100%,100% 100%,20px 20px}
.hint{position:absolute;top:80px;left:50%;transform:translateX(-50%);background:var(--hint-bg);color:var(--hint-text);padding:5px 14px;border-radius:8px;font-size:12px;z-index:10;pointer-events:none;direction:ltr;white-space:nowrap}
.zoom{position:absolute;bottom:16px;left:16px;display:flex;gap:4px;z-index:50}
.zb{width:32px;height:32px;border-radius:10px;background:var(--zoom-bg);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:0;outline:1px solid var(--zoom-border);color:var(--zoom-text);font-size:16px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:background .12s ease,color .12s ease;box-shadow:0 1px 3px rgba(0,0,0,.06),0 2px 8px rgba(0,0,0,.04)}.zb:hover{background:var(--nav-hover);color:var(--text-primary)}.zb:active{transform:scale(.97)}
.zb .ti{font-size:16px}.nodes-toggle .ti{font-size:16px}

/* Drawflow overrides - Glass Morphism cards */
.drawflow .drawflow-node{border-radius:12px;border:1px solid var(--node-border);background:var(--bg-node);width:320px;color:var(--text-primary);padding:0;box-shadow:var(--node-shadow);font-size:12px;transition:box-shadow .2s ease,border-color .15s ease;animation:nodeEnter .3s cubic-bezier(.16,1,.3,1) both}
.drawflow .drawflow-node:hover{box-shadow:var(--node-hover-shadow);border-color:var(--node-border-hover)}
.drawflow .drawflow-node.selected{background:var(--bg-node);border-color:var(--accent);box-shadow:var(--node-shadow)}
body.dark .drawflow .drawflow-node.selected{border-color:var(--accent);box-shadow:var(--node-shadow)}
.drawflow .drawflow-node .inputs,.drawflow .drawflow-node .outputs{pointer-events:auto}
.drawflow .drawflow-node .input,.drawflow .drawflow-node .output{width:10px;height:10px;border:2px solid var(--wire-color);background:var(--wire-color);cursor:crosshair;position:relative;z-index:5;border-radius:50%;transition:transform .15s ease,background .15s ease,border-color .15s ease,box-shadow .15s ease}
.drawflow .drawflow-node .input::before,.drawflow .drawflow-node .output::before{content:'';position:absolute;inset:-10px}
.drawflow .drawflow-node .input:hover,.drawflow .drawflow-node .output:hover{transform:scale(1.2);background:var(--accent);border-color:var(--accent);box-shadow:0 0 0 4px var(--accent-10)}

/* === CONNECTION WIRES === */
.drawflow .connection .main-path{stroke:var(--wire-color);stroke-width:2;opacity:var(--wire-opacity);fill:none;cursor:pointer;pointer-events:stroke;stroke-linecap:round;transition:opacity .15s ease,stroke-width .1s ease,stroke .1s ease}
.drawflow .connection .main-path:hover{opacity:1;stroke-width:2.5;stroke:var(--accent)}
.drawflow .drawflow-delete{background:var(--bg-node);color:var(--danger-text);border:1px solid var(--del-border);border-radius:50%;width:20px;height:20px;font-size:11px;line-height:18px;text-align:center;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.drawflow .drawflow-delete:hover{background:var(--del-hover);border-color:rgba(220,38,38,.3)}

/* Node styles - Glass headers with accent bar */
.nh{min-height:44px;padding:8px 14px;font-weight:600;font-size:13px;letter-spacing:-.01em;border-radius:11px 11px 0 0;display:flex;align-items:center;gap:10px;direction:ltr;position:relative;color:var(--text-primary);background:var(--bg-node);border-bottom:1px solid var(--node-border);flex-wrap:nowrap;flex-shrink:0}
.drawflow .drawflow-node .drawflow_content_node{padding:0;width:100%}
.nh i{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:15px;color:#fff;background:var(--nc-text,#7C3AED);flex-shrink:0}
.nh-text{display:flex;flex-direction:column;min-width:0;flex:1}
.nh-cat{font-size:10px;font-weight:400;color:var(--text-faint);letter-spacing:.3px;text-transform:uppercase;line-height:1.2}
.nh-title{font-size:13px;font-weight:600;color:var(--text-primary);line-height:1.3;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.nb{padding:10px 14px 12px;direction:ltr;border-top:none;background:transparent}
.nb label{display:block;font-size:11px;color:var(--text-muted);margin-bottom:4px;font-weight:500;letter-spacing:.2px;text-transform:uppercase}
.nb input,.nb select,.nb textarea{width:100%;background:var(--input-bg);border:1px solid var(--input-border);border-radius:8px;padding:7px 10px;color:var(--input-text);font-family:inherit;font-size:12px;margin-bottom:8px;direction:ltr;transition:border-color .15s ease,box-shadow .15s ease}
.nb select{appearance:none;-webkit-appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24'%3E%3Cpath fill='%239CA3AF' d='M7 10l5 5 5-5z'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:left 10px center;padding-left:28px}
.nb input:last-child,.nb select:last-child,.nb textarea:last-child{margin-bottom:0}
.nb input:focus,.nb select:focus,.nb textarea:focus{border-color:var(--accent);outline:none;box-shadow:0 0 0 2px var(--accent-10)}
.nb input:hover,.nb select:hover,.nb textarea:hover{border-color:var(--input-hover)}
.nb textarea{resize:vertical;min-height:56px}
.nb select option{background:var(--select-option-bg)}
.nb input::placeholder,.nb textarea::placeholder{color:var(--input-placeholder)}
.nh-or{--nc-tint:rgba(232,93,4,.12);--nc-text:#C2410C;--nc-icon-bg:rgba(232,93,4,.15);--nc-line:rgba(232,93,4,.12)}
.nh-bl{--nc-tint:rgba(37,99,235,.1);--nc-text:#1D4ED8;--nc-icon-bg:rgba(37,99,235,.14);--nc-line:rgba(37,99,235,.1)}
.nh-pu{--nc-tint:rgba(124,58,237,.1);--nc-text:#7C3AED;--nc-icon-bg:rgba(124,58,237,.14);--nc-line:rgba(124,58,237,.1)}
.nh-ye{--nc-tint:rgba(202,138,4,.1);--nc-text:#A16207;--nc-icon-bg:rgba(202,138,4,.14);--nc-line:rgba(202,138,4,.1)}
.nh-gr{--nc-tint:rgba(22,163,74,.1);--nc-text:#15803D;--nc-icon-bg:rgba(22,163,74,.14);--nc-line:rgba(22,163,74,.1)}
.nh-tl{--nc-tint:rgba(8,145,178,.1);--nc-text:#0E7490;--nc-icon-bg:rgba(8,145,178,.14);--nc-line:rgba(8,145,178,.1)}
.nh-rd{--nc-tint:rgba(220,38,38,.1);--nc-text:#DC2626;--nc-icon-bg:rgba(220,38,38,.14);--nc-line:rgba(220,38,38,.1)}
.nh-dl{--nc-tint:rgba(124,58,237,.1);--nc-text:#7C3AED;--nc-icon-bg:rgba(124,58,237,.14);--nc-line:rgba(124,58,237,.1)}
.nh-wb{--nc-tint:rgba(79,70,229,.1);--nc-text:#4338CA;--nc-icon-bg:rgba(79,70,229,.14);--nc-line:rgba(79,70,229,.1)}
.nh-nt{--nc-tint:rgba(180,83,9,.1);--nc-text:#B45309;--nc-icon-bg:rgba(180,83,9,.14);--nc-line:rgba(180,83,9,.1)}
.nh-at{--nc-tint:rgba(232,93,4,.12);--nc-text:#C2410C;--nc-icon-bg:rgba(232,93,4,.15);--nc-line:rgba(232,93,4,.12)}
.nh-im{--nc-tint:rgba(5,150,105,.1);--nc-text:#047857;--nc-icon-bg:rgba(5,150,105,.14);--nc-line:rgba(5,150,105,.1)}
.nh-bt{--nc-tint:rgba(13,148,136,.1);--nc-text:#0D9488;--nc-icon-bg:rgba(13,148,136,.14);--nc-line:rgba(13,148,136,.1)}
.nh-vi{--nc-tint:rgba(124,58,237,.1);--nc-text:#7C3AED;--nc-icon-bg:rgba(124,58,237,.14);--nc-line:rgba(124,58,237,.1)}
body.dark .nh-or{--nc-tint:rgba(251,146,60,.15);--nc-text:#FB923C;--nc-icon-bg:rgba(251,146,60,.22);--nc-line:rgba(251,146,60,.18)}
body.dark .nh-bl{--nc-tint:rgba(96,165,250,.15);--nc-text:#60A5FA;--nc-icon-bg:rgba(96,165,250,.22);--nc-line:rgba(96,165,250,.18)}
body.dark .nh-pu,body.dark .nh-dl,body.dark .nh-vi{--nc-tint:rgba(167,139,250,.15);--nc-text:#A78BFA;--nc-icon-bg:rgba(167,139,250,.22);--nc-line:rgba(167,139,250,.18)}
body.dark .nh-ye{--nc-tint:rgba(250,204,21,.13);--nc-text:#FACC15;--nc-icon-bg:rgba(250,204,21,.2);--nc-line:rgba(250,204,21,.15)}
body.dark .nh-gr{--nc-tint:rgba(74,222,128,.13);--nc-text:#4ADE80;--nc-icon-bg:rgba(74,222,128,.2);--nc-line:rgba(74,222,128,.15)}
body.dark .nh-tl{--nc-tint:rgba(34,211,238,.13);--nc-text:#22D3EE;--nc-icon-bg:rgba(34,211,238,.2);--nc-line:rgba(34,211,238,.15)}
body.dark .nh-rd{--nc-tint:rgba(248,113,113,.13);--nc-text:#F87171;--nc-icon-bg:rgba(248,113,113,.2);--nc-line:rgba(248,113,113,.15)}
body.dark .nh-wb{--nc-tint:rgba(129,140,248,.15);--nc-text:#818CF8;--nc-icon-bg:rgba(129,140,248,.22);--nc-line:rgba(129,140,248,.18)}
body.dark .nh-nt{--nc-tint:rgba(251,191,36,.13);--nc-text:#FBBF24;--nc-icon-bg:rgba(251,191,36,.2);--nc-line:rgba(251,191,36,.15)}
body.dark .nh-at{--nc-tint:rgba(251,146,60,.15);--nc-text:#FB923C;--nc-icon-bg:rgba(251,146,60,.22);--nc-line:rgba(251,146,60,.18)}
body.dark .nh-im{--nc-tint:rgba(52,211,153,.13);--nc-text:#34D399;--nc-icon-bg:rgba(52,211,153,.2);--nc-line:rgba(52,211,153,.15)}
body.dark .nh-bt{--nc-tint:rgba(45,212,191,.13);--nc-text:#2DD4BF;--nc-icon-bg:rgba(45,212,191,.2);--nc-line:rgba(45,212,191,.15)}
.dn.dn-selected{outline:2px solid var(--accent);outline-offset:-2px}
.olb{padding:6px 14px;direction:ltr;border-top:1px solid var(--node-border);background:transparent;border-radius:0 0 11px 11px}.olb div{font-size:11px;color:var(--olb-text);padding:3px 0;display:flex;align-items:center;gap:5px}
.olb-single{text-align:center}
.olb-next{display:flex;align-items:center;justify-content:center;gap:6px;font-size:11px;color:var(--accent);font-weight:500}
.olb-btn-label span{max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}

.toast{position:fixed;bottom:52px;left:50%;transform:translateX(-50%) translateY(100px);padding:10px 22px;border-radius:100px;font-size:13px;font-weight:600;z-index:9999;transition:transform .35s cubic-bezier(.2,.8,.2,1);direction:ltr;backdrop-filter:blur(16px) saturate(1.3);-webkit-backdrop-filter:blur(16px) saturate(1.3)}
.toast.show{transform:translateX(-50%) translateY(0)}
.toast-ok{background:var(--toast-ok-bg);color:var(--toast-ok-text);border:1px solid var(--toast-ok-border)}.toast-err{background:var(--toast-err-bg);color:var(--toast-err-text);border:1px solid var(--toast-err-border)}

/* === SAVE STATUS === */
.save-ind{font-size:11px;margin-left:8px;transition:opacity .3s}
.save-ind.dirty{color:var(--warning-text)}.save-ind.saved{color:var(--success-text)}

/* === NODE SEARCH === */
.node-search{width:100%;margin-bottom:10px;background:var(--search-bg);border:none;outline:1px solid var(--search-border);border-radius:8px;padding:7px 10px;color:var(--text-primary);font-family:inherit;font-size:14px;direction:ltr;transition:outline-color .15s ease}
.node-search:focus{outline-color:var(--search-focus)}
.node-search:hover{outline-color:var(--search-hover)}
.node-search::placeholder{color:var(--text-muted)}

/* === CONTEXT MENU === */
.ctx-menu{position:fixed;z-index:1000;background:var(--ctx-bg);backdrop-filter:blur(24px) saturate(1.5);-webkit-backdrop-filter:blur(24px) saturate(1.5);border:1px solid var(--ctx-border);border-radius:16px;padding:6px;min-width:200px;box-shadow:0 0 0 1px rgba(0,0,0,.03),0 4px 12px rgba(0,0,0,.08),0 16px 40px rgba(0,0,0,.06);display:block;opacity:0;transform:scale(.95) translateY(-6px);transform-origin:top right;transition:opacity .18s cubic-bezier(.2,.8,.2,1),transform .18s cubic-bezier(.2,.8,.2,1);pointer-events:none;direction:ltr}
.ctx-menu.open{opacity:1;transform:scale(1) translateY(0);pointer-events:auto}
.ctx-item{padding:8px 12px;font-size:13px;font-weight:500;letter-spacing:-.01em;color:var(--ctx-text);border-radius:10px;cursor:pointer;display:flex;align-items:center;gap:10px;transition:background .1s ease}
.ctx-item:hover{background:var(--ctx-hover)}
.ctx-item .ks{margin-right:auto;font-size:10px;font-weight:500;color:var(--ctx-key);direction:ltr;padding:2px 6px;border-radius:5px;background:var(--kbd-bg);border:1px solid var(--ctx-sep)}
.ctx-del{color:var(--danger-text)}
.ctx-item.ctx-disabled{opacity:.35;pointer-events:none}
.ctx-sep{height:1px;background:var(--ctx-sep);margin:4px 8px}

/* === DROP ZONE === */
.canvas.drop-hover #drawflow{box-shadow:inset 0 0 0 2px var(--drop-hover);transition:box-shadow .2s}
.node-actions{position:absolute;top:-34px;right:8px;display:flex;gap:4px;z-index:10;direction:ltr;opacity:0;transform:translateY(6px);transition:opacity .2s cubic-bezier(.2,.8,.2,1),transform .2s cubic-bezier(.2,.8,.2,1);pointer-events:none;padding-bottom:10px}
.drawflow .drawflow-node:hover .node-actions{opacity:1;transform:translateY(0);pointer-events:auto}
.drawflow .drawflow-node.selected .node-actions{opacity:1;transform:translateY(0);pointer-events:auto}
.node-actions .na-btn{width:26px;height:26px;border-radius:7px;display:flex;align-items:center;justify-content:center;cursor:pointer;border:1px solid var(--na-border);font-size:12px;background:var(--na-bg);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);box-shadow:0 1px 4px rgba(0,0,0,.08);transition:background .12s ease,transform .12s ease}
.node-actions .na-btn:hover{background:var(--na-hover);transform:scale(1.06)}
.node-actions .na-btn.na-del{color:var(--danger-text)}.node-actions .na-btn.na-del:hover{background:var(--del-bg)}
.node-actions .na-btn.na-dup{color:var(--text-muted)}
.canvas-empty{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);text-align:center;pointer-events:none;z-index:5;direction:ltr;transition:opacity .4s cubic-bezier(.2,.8,.2,1)}
.canvas-empty.hidden{opacity:0;pointer-events:none}
.canvas-empty-icon{width:80px;height:80px;border-radius:24px;background:linear-gradient(135deg,var(--empty-icon-bg),rgba(124,58,237,.04));border:1px solid var(--empty-icon-border);display:flex;align-items:center;justify-content:center;margin:0 auto 24px}
.canvas-empty-icon .ti{font-size:34px;color:var(--accent)}
.canvas-empty h3{font-size:18px;font-weight:600;color:var(--text-primary);margin-bottom:12px;letter-spacing:-.02em}
.canvas-empty p{font-size:13px;color:var(--text-muted);line-height:1.7;max-width:400px;margin:0 auto}
.empty-steps{text-align:left;display:inline-block;font-size:13px;color:var(--text-secondary);line-height:2.4;margin:16px auto 12px}
.empty-steps div{padding:2px 0}
.empty-steps strong{color:var(--accent);font-weight:600}
.canvas-empty kbd{display:inline-block;padding:2px 7px;border-radius:5px;background:var(--kbd-bg);color:var(--text-secondary);font-family:'SF Mono','Fira Code',monospace;font-size:10.5px;border:1px solid var(--kbd-border);box-shadow:0 1px 0 var(--kbd-border);vertical-align:baseline}

/* === ZOOM DISPLAY === */
.zoom-pct{font-size:13px;font-weight:500;color:var(--zoom-text);min-width:42px;text-align:center;background:var(--search-bg);border-radius:8px;padding:5px 6px;user-select:none;font-variant-numeric:tabular-nums}

/* === CONNECTION SELECTION (overridden in PROFESSIONAL CANVAS section) === */

/* === MINIMAP === */
.minimap{position:absolute;bottom:56px;right:16px;width:172px;height:108px;background:var(--minimap-bg);backdrop-filter:blur(16px) saturate(1.3);-webkit-backdrop-filter:blur(16px) saturate(1.3);border:1px solid var(--minimap-border);border-radius:16px;z-index:55;overflow:hidden;cursor:pointer;transition:opacity .25s ease,border-color .2s ease,box-shadow .2s ease;box-shadow:0 0 0 1px rgba(0,0,0,.03),0 2px 8px rgba(0,0,0,.06),0 8px 24px rgba(0,0,0,.04)}
.minimap:hover{border-color:var(--accent-10);box-shadow:0 4px 16px rgba(0,0,0,.08)}
.minimap canvas{width:100%;height:100%;display:block;border-radius:15px}
.minimap-toggle{position:absolute;top:4px;right:4px;width:20px;height:20px;border-radius:5px;background:transparent;border:none;color:var(--text-muted);font-size:12px;cursor:pointer;display:flex;align-items:center;justify-content:center;z-index:1;transition:color .15s,background .15s}
.minimap-toggle:hover{color:var(--text-primary);background:var(--nav-hover)}

/* === SNAP TOGGLE === */
.snap-toggle{position:absolute;bottom:56px;left:16px;font-size:11px;color:var(--snap-text);background:var(--snap-bg);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid var(--snap-border);border-radius:8px;padding:4px 10px;z-index:50;cursor:pointer;user-select:none;display:flex;align-items:center;gap:5px;transition:background .15s ease,color .15s ease,border-color .15s ease}
.snap-toggle:hover{border-color:var(--scrollbar-thumb);color:var(--text-secondary)}
.snap-toggle.active{color:var(--snap-active-text);border-color:var(--snap-active-border);background:var(--snap-active-bg)}
.snap-toggle .ti{font-size:12px}

/* === ALIGNMENT GUIDES === */
.align-guide{position:absolute;pointer-events:none;z-index:999}
.align-guide-h{left:0;width:100%;height:1px;background:var(--accent);opacity:.35}
.align-guide-v{top:0;height:100%;width:1px;background:var(--accent);opacity:.35}

/* === LOADING === */
.canvas-loading{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:14px;background:var(--loading-bg);z-index:100;transition:opacity .5s cubic-bezier(.2,.8,.2,1)}
.canvas-loading.done{opacity:0;pointer-events:none}
.spinner{width:24px;height:24px;border:2px solid var(--accent-10);border-top-color:var(--accent);border-radius:50%;animation:spin .8s cubic-bezier(.4,0,.2,1) infinite}
@keyframes spin{to{transform:rotate(360deg)}}
.tbtn:disabled{opacity:.3;cursor:default;pointer-events:none}
/* === NOTE NODE === */
.drawflow-node.note .nb{background:var(--note-bg)}.drawflow-node.note .node-preview{background:var(--note-bg)}
/* === SVG MARKERS === */
.drawflow svg{overflow:visible}

/* === CONNECTION LABELS (hidden — replaced by olb labels) === */
.drawflow-node .output{position:relative}
.drawflow-node.condition .output::after,.drawflow-node.menu .output::after,.drawflow-node.buttons .output::after{display:none}

/* === PROPERTIES PANEL === */
.props-panel{display:none}
.props-panel.active{display:block}
.props-hdr{display:flex;align-items:center;gap:8px;margin-bottom:12px}
.props-hdr .props-icon{width:28px;height:28px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0}
.props-hdr .props-title{font-size:14px;font-weight:500;color:var(--text-primary)}
.props-hdr .props-type{font-size:10px;color:var(--accent)}
.props-field{margin-bottom:10px}
.props-field label{display:block;font-size:14px;color:var(--text-secondary);margin-bottom:4px;font-weight:500}
.props-field input,.props-field select,.props-field textarea{width:100%;background:var(--search-bg);border:1px solid var(--search-border);outline:none;border-radius:10px;padding:9px 12px;color:var(--text-primary);font-family:inherit;font-size:13px;direction:ltr;transition:border-color .15s ease,box-shadow .15s ease}
.props-field input:focus,.props-field select:focus,.props-field textarea:focus{border-color:var(--search-focus);box-shadow:0 0 0 3px var(--accent-10)}
.props-field input:hover,.props-field select:hover,.props-field textarea:hover{border-color:var(--search-hover)}
.props-field textarea{resize:vertical;min-height:72px}
.props-field select option{background:var(--select-option-bg)}
.props-del{width:100%;margin-top:12px;padding:8px;border-radius:8px;border:0;background:var(--delete-bg);color:var(--delete-text);font-family:inherit;font-size:14px;font-weight:500;cursor:pointer;transition:background .1s ease-out}
.props-del:hover{background:var(--delete-hover)}
.props-del:active{transform:scale(.97)}
.tips-panel{display:block}
.tips-panel.hidden{display:none}

/* === VALIDATION === */
.node-dup-pulse{animation:dupPulse .6s ease-out}
@keyframes dupPulse{0%{box-shadow:0 0 0 0 rgba(124,58,237,.4)}100%{box-shadow:0 0 0 12px rgba(124,58,237,0)}}
.node-error{animation:pulse-err 2s infinite}
@keyframes pulse-err{0%,100%{box-shadow:0 4px 20px rgba(0,0,0,.4)}50%{box-shadow:0 0 0 4px rgba(231,76,60,.3)}}
.valid-list{max-height:200px;overflow-y:auto;margin-top:8px}
.valid-item{padding:6px 8px;font-size:11px;color:var(--valid-text);background:var(--valid-bg);border-radius:6px;margin-bottom:4px;display:flex;align-items:center;gap:6px;cursor:pointer}
.valid-item:hover{background:var(--valid-hover)}

/* === STATUS BAR === */
.status-bar{height:28px;background:var(--status-bg);border:1px solid var(--status-border);display:flex;align-items:center;gap:12px;padding:0 16px;font-size:11px;color:var(--status-text);direction:ltr;font-variant-numeric:tabular-nums;font-weight:500;position:absolute;bottom:12px;left:50%;transform:translateX(-50%);border-radius:20px;z-index:60;box-shadow:0 0 0 1px rgba(0,0,0,.03),0 2px 8px rgba(0,0,0,.06),inset 0 1px 0 rgba(255,255,255,.4);white-space:nowrap;backdrop-filter:blur(16px) saturate(1.4);-webkit-backdrop-filter:blur(16px) saturate(1.4)}
.status-sep{color:var(--status-sep);font-size:6px}
.sb-badge{display:inline-flex;align-items:center;gap:5px;padding:2px 10px;border-radius:20px;font-size:10.5px;font-weight:600;letter-spacing:.02em}
.sb-badge-blue{background:var(--badge-bg);color:var(--badge-text)}
.sb-badge-green{background:var(--badge-green-bg);color:var(--badge-green-text)}

/* === COLLAPSIBLE NODES === */
.nh-title{white-space:nowrap;flex:1;font-size:13px;overflow:hidden;text-overflow:ellipsis}
.nh-toggle{border:none;background:transparent;color:var(--nc-text,rgba(124,58,237,.5));opacity:.6;cursor:pointer;padding:0;font-size:11px;display:flex;align-items:center;flex-shrink:0;outline:none;width:24px;height:24px;justify-content:center;border-radius:7px;transition:background .15s,opacity .15s,transform .2s ease}
.nh-toggle:hover{background:var(--nc-icon-bg,rgba(124,58,237,.1));opacity:1}
.nh-toggle.open{transform:rotate(180deg)}
.nh-summary{display:none}
.node-preview{padding:10px 14px 12px;font-size:12px;color:var(--text-secondary);direction:ltr;line-height:1.5;word-break:break-word;border-top:.5px solid var(--node-border);background:transparent;overflow:hidden}
.node-preview:empty{padding:0;display:none;border:none;background:none}
.pv-bubble{background:var(--summary-bg);border-radius:10px 10px 4px 10px;padding:8px 12px;font-size:12px;color:var(--text-secondary);line-height:1.5;margin-bottom:6px;word-break:break-word;white-space:pre-wrap}
.pv-bubble-sm{font-size:11px;padding:6px 10px}
.pv-btns{display:flex;flex-wrap:wrap;gap:4px;margin-top:6px}
.pv-pill{padding:4px 12px;border-radius:16px;font-size:11px;font-weight:500;border:1px dashed var(--node-border);color:var(--text-muted);background:transparent;display:inline-block}
.pv-list{margin-top:4px}
.pv-list-item{font-size:11px;color:var(--text-muted);padding:3px 0;border-bottom:1px solid var(--node-border)}
.pv-list-item:last-child{border:none}
.pv-trigger{display:flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:rgba(22,163,74,.08);color:var(--success-text);font-size:12px;font-weight:500}
body.dark .pv-trigger{background:rgba(74,222,128,.1)}
.pv-condition{display:flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:rgba(202,138,4,.08);color:var(--warning-text);font-size:12px;font-weight:500}
body.dark .pv-condition{background:rgba(250,204,21,.1)}
.pv-wait{display:flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:rgba(8,145,178,.08);color:#0891B2;font-size:12px;font-weight:500}
body.dark .pv-wait{background:rgba(34,211,238,.1);color:#22D3EE}
.pv-api{display:flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:rgba(67,56,202,.06);color:#4338CA;font-size:12px;font-weight:500}
body.dark .pv-api{background:rgba(129,140,248,.1);color:#818CF8}
.pv-split{display:flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:rgba(192,38,211,.06);color:#C026D3;font-size:12px;font-weight:500}
body.dark .pv-split{background:rgba(232,121,249,.1);color:#E879F9}
.pv-goto{display:flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:rgba(71,85,105,.06);color:#475569;font-size:12px;font-weight:500}
body.dark .pv-goto{background:rgba(148,163,184,.1);color:#94A3B8}
.pv-media{display:flex;align-items:center;gap:6px;padding:6px 10px;border-radius:8px;background:var(--summary-bg);font-size:12px;color:var(--text-secondary)}
.pv-info{font-size:12px;color:var(--text-secondary);padding:4px 0;display:flex;align-items:center;gap:6px}
.pv-empty{font-size:11px;color:var(--text-faint);font-style:italic}
/* olb always visible — even when collapsed (ManyChat shows output labels always) */
.nb-collapsible{max-height:0;opacity:0;overflow:hidden;padding-top:0;padding-bottom:0;transition:max-height .25s cubic-bezier(.4,0,.2,1),opacity .2s ease,padding .2s ease}
.nb-collapsible.nb-open{max-height:600px;opacity:1;padding-top:10px;padding-bottom:12px}
.nb-collapsible.nb-open~.node-preview{display:none}

/* === NEW NODE COLORS === */
.nh-sp{--nc:#D97706}.nh-ss{--nc:#2563EB}.nh-ti{--nc:#7C3AED}
.dn-sp i{background:rgba(202,138,4,.2)}.dn-sp{background:rgba(202,138,4,.06)}
.dn-ss i{background:rgba(37,99,235,.2)}.dn-ss{background:rgba(37,99,235,.06)}
.dn-ti i{background:rgba(124,58,237,.2)}.dn-ti{background:rgba(124,58,237,.06)}

/* Wait Reply (cyan) */
.nh-wr{--nc-tint:rgba(8,145,178,.1);--nc-text:#0891B2;--nc-icon-bg:rgba(8,145,178,.14);--nc-line:rgba(8,145,178,.1)}
body.dark .nh-wr{--nc-tint:rgba(34,211,238,.13);--nc-text:#22D3EE;--nc-icon-bg:rgba(34,211,238,.2);--nc-line:rgba(34,211,238,.15)}
.dn-wr i{background:rgba(8,145,178,.2)}.dn-wr{background:rgba(8,145,178,.06)}
/* API Action (indigo) */
.nh-api{--nc-tint:rgba(67,56,202,.1);--nc-text:#4338CA;--nc-icon-bg:rgba(67,56,202,.14);--nc-line:rgba(67,56,202,.1)}
body.dark .nh-api{--nc-tint:rgba(129,140,248,.15);--nc-text:#818CF8;--nc-icon-bg:rgba(129,140,248,.22);--nc-line:rgba(129,140,248,.18)}
.dn-api i{background:rgba(67,56,202,.2)}.dn-api{background:rgba(67,56,202,.06)}
/* A/B Split (fuchsia) */
.nh-ab{--nc-tint:rgba(192,38,211,.1);--nc-text:#C026D3;--nc-icon-bg:rgba(192,38,211,.14);--nc-line:rgba(192,38,211,.1)}
body.dark .nh-ab{--nc-tint:rgba(232,121,249,.13);--nc-text:#E879F9;--nc-icon-bg:rgba(232,121,249,.2);--nc-line:rgba(232,121,249,.15)}
.dn-ab i{background:rgba(192,38,211,.2)}.dn-ab{background:rgba(192,38,211,.06)}
/* Go to Step (slate) */
.nh-go{--nc-tint:rgba(71,85,105,.1);--nc-text:#475569;--nc-icon-bg:rgba(71,85,105,.14);--nc-line:rgba(71,85,105,.1)}
body.dark .nh-go{--nc-tint:rgba(148,163,184,.13);--nc-text:#94A3B8;--nc-icon-bg:rgba(148,163,184,.2);--nc-line:rgba(148,163,184,.15)}
.dn-go i{background:rgba(71,85,105,.2)}.dn-go{background:rgba(71,85,105,.06)}
/* A/B split percentage label */
.olb-pct{font-size:10px;color:var(--text-faint);font-weight:400}

/* === PROFESSIONAL CANVAS === */
/* accent bar removed - full color headers instead */
/* Selected connection */
.drawflow .connection .main-path.conn-selected{stroke:var(--accent);stroke-width:2.5;opacity:1}

/* === CONDITION DYNAMIC FIELDS === */
.props-field .cond-sub{margin-top:4px}
.props-field .cond-sub label{font-size:12px;color:var(--text-faint);margin-bottom:3px}

/* === UNIQUE ENHANCEMENTS === */
@keyframes nodeEnter{from{opacity:0;filter:blur(4px);transform:scale(.97)}to{opacity:1;filter:blur(0);transform:scale(1)}}
/* --nc defined on .nh-XX classes (icon + header accent) */
/* Port hover (subtle) */
/* Icon micro-interaction removed for ManyChat-style clean look */
/* Save indicator dirty pulse */
.save-ind.dirty{animation:dirtyPulse 2s ease-in-out infinite}
@keyframes dirtyPulse{0%,100%{opacity:1}50%{opacity:.6}}
/* Dark mode overrides */
body.dark .tb{box-shadow:0 0 0 1px rgba(255,255,255,.04),0 2px 8px rgba(0,0,0,.3),0 8px 24px rgba(0,0,0,.2),inset 0 1px 0 rgba(255,255,255,.04)}
body.dark .status-bar{box-shadow:0 0 0 1px rgba(255,255,255,.04),0 2px 8px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.03)}
body.dark .ctx-menu{box-shadow:0 0 0 1px rgba(255,255,255,.04),0 4px 12px rgba(0,0,0,.3),0 16px 40px rgba(0,0,0,.25)}
body.dark .side-cfg{box-shadow:0 0 0 1px rgba(255,255,255,.04),4px 0 16px rgba(0,0,0,.3),8px 0 32px rgba(0,0,0,.2)}
body.dark .inbox-item.sel{border-color:rgba(139,92,246,.3)}
body.dark .minimap:hover{box-shadow:0 4px 16px rgba(0,0,0,.4)}
body.dark .canvas-empty kbd{border-color:rgba(255,255,255,.12);box-shadow:0 1px 0 rgba(255,255,255,.12)}
body.dark .nb select{background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24'%3E%3Cpath fill='%236B7280' d='M7 10l5 5 5-5z'/%3E%3C/svg%3E")}
/* Focus indicators */
.tbtn:focus-visible,.zb:focus-visible,.dn:focus-visible,.ctx-item:focus-visible,.snap-toggle:focus-visible,.minimap-toggle:focus-visible,.nodes-toggle:focus-visible,.side-cfg-close:focus-visible,.nh-toggle:focus-visible,.tb-bot-name:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
/* Reduced motion */
@media(prefers-reduced-motion:reduce){.drawflow .drawflow-node{animation:none !important}.save-ind.dirty{animation:none !important}.side-nodes{transition-duration:0s}.side-cfg{transition-duration:0s}}
</style></head>
<body>
<script>(function(){var s=null;try{var k=Object.keys(localStorage);for(var i=0;i<k.length;i++){if(k[i].indexOf('COLOR_SCHEME')!==-1){s=localStorage.getItem(k[i]);break}}}catch(e){}if(s==='dark'||(s!=='light'&&window.matchMedia('(prefers-color-scheme:dark)').matches))document.body.classList.add('dark')})()</script>
<div class="app-shell">
<nav class="app-nav">
  <a href="/bot-builder" class="active" title="Bot Builder"><i class="ti ti-robot"></i></a>
  <a href="/campaign-report" title="Campaign Report"><i class="ti ti-chart-bar"></i></a>
  <div class="nav-sp"></div>
  <a href="/app" title="Chatwoot"><i class="ti ti-layout-dashboard"></i></a>
</nav>
<div class="app-main">
<div class="tb">
  <a href="/bot-builder" class="tbtn tbtn-back" title="Back to list"><i class="ti ti-arrow-right"></i></a>
  <span class="tb-logo"><i class="ti ti-robot"></i></span>
  <div class="tb-center">
    <input type="text" id="bname" class="tb-bot-name" placeholder="Click to edit bot name...">
    <i class="ti ti-pencil" style="font-size:12px;color:var(--text-faint);pointer-events:none;margin-right:-4px"></i>
  </div>
  <div class="sp"></div>
  <div class="tb-group">
    <button class="tbtn" id="undo-btn" onclick="undo()" title="Undo (Ctrl+Z)" disabled><i class="ti ti-arrow-back-up"></i></button>
    <button class="tbtn" id="redo-btn" onclick="redo()" title="Redo (Ctrl+Shift+Z)" disabled><i class="ti ti-arrow-forward-up"></i></button>
  </div>
  <div class="tb-divider"></div>
  <div class="tb-group">
    <button class="tbtn" onclick="var sc=document.getElementById('side-cfg');sc.classList.contains('open')?closeCfg():openCfg()" title="Bot Settings"><i class="ti ti-settings"></i></button>
    <button class="tbtn" onclick="autoAlign()" title="Auto-align"><i class="ti ti-layout-grid"></i></button>
    <button class="tbtn" onclick="validateFlow()" title="Validate Flow"><i class="ti ti-circle-check"></i></button>
    <button class="tbtn" onclick="downloadFlow()" title="Export Flow (JSON)"><i class="ti ti-download"></i></button>
    <button class="tbtn" onclick="document.getElementById('flow-import').click()" title="Import Flow (JSON)"><i class="ti ti-upload"></i></button>
    <input type="file" id="flow-import" accept=".json" style="display:none" onchange="importFlow(this)">
  </div>
  <div class="tb-divider"></div>
  <button class="tbtn tbtn-save" id="savebtn"><i class="ti ti-device-floppy"></i> Save</button>
</div>
<div class="layout">
  <!-- RIGHT SIDEBAR: Nodes (collapsible 48px strip / 240px expanded) -->
  <div class="side-nodes" id="side-nodes">
    <button class="nodes-toggle" id="nodes-toggle" title="Expand/Collapse palette"><i class="ti ti-chevron-left"></i></button>
    <div class="nodes-content">
      <input type="text" id="node-search" class="node-search" placeholder="Search nodes...">
      <div id="nodes-no-results" style="display:none;text-align:center;padding:16px 8px;color:var(--text-muted);font-size:12px"><i class="ti ti-search-off" style="font-size:20px;display:block;margin-bottom:4px;opacity:.5"></i>No nodes found</div>
      <div class="sec" style="--sec-color:#ff6b35"><div class="sec-t" style="--sec-color:#ff6b35"><span class="dn-label">Triggers</span></div>
        <div class="dn dn-or" draggable="true" data-node="trigger" title="Incoming Message"><i class="ti ti-target"></i><span class="dn-label">Incoming Message</span></div>
      </div>
      <div class="sec" style="--sec-color:#4a9eff"><div class="sec-t" style="--sec-color:#4a9eff"><span class="dn-label">Messages</span></div>
        <div class="dn dn-bl" draggable="true" data-node="message" title="Send Message"><i class="ti ti-message"></i><span class="dn-label">Send Message</span></div>
        <div class="dn dn-gr" draggable="true" data-node="image" title="Send Image"><i class="ti ti-photo"></i><span class="dn-label">Send Image</span></div>
        <div class="dn dn-vi" draggable="true" data-node="video" title="Send Video"><i class="ti ti-video"></i><span class="dn-label">Send Video</span></div>
        <div class="dn dn-bt" draggable="true" data-node="buttons" title="Buttons"><i class="ti ti-click"></i><span class="dn-label">Buttons</span></div>
        <div class="dn dn-pu" draggable="true" data-node="menu" title="Menu"><i class="ti ti-list"></i><span class="dn-label">Menu</span></div>
      </div>
      <div class="sec" style="--sec-color:#f1c40f"><div class="sec-t" style="--sec-color:#f1c40f"><span class="dn-label">Logic</span></div>
        <div class="dn dn-ye" draggable="true" data-node="condition" title="Condition"><i class="ti ti-git-branch"></i><span class="dn-label">Condition</span></div>
        <div class="dn dn-dl" draggable="true" data-node="delay" title="Delay"><i class="ti ti-clock-pause"></i><span class="dn-label">Delay</span></div>
        <div class="dn dn-nt" draggable="true" data-node="note" title="Internal Note"><i class="ti ti-note"></i><span class="dn-label">Internal Note</span></div>
        <div class="dn dn-wr" draggable="true" data-node="wait_reply" title="Wait for Reply"><i class="ti ti-message-question"></i><span class="dn-label">Wait for Reply</span></div>
        <div class="dn dn-ab" draggable="true" data-node="ab_split" title="A/B Split"><i class="ti ti-arrows-split-2"></i><span class="dn-label">A/B Split</span></div>
        <div class="dn dn-go" draggable="true" data-node="goto_step" title="Go to Step"><i class="ti ti-arrow-back-up"></i><span class="dn-label">Go to Step</span></div>
      </div>
      <div class="sec" style="--sec-color:#27ae60"><div class="sec-t" style="--sec-color:#27ae60"><span class="dn-label">Actions</span></div>
        <div class="dn dn-gr" draggable="true" data-node="assign" title="Assign to Agent"><i class="ti ti-user"></i><span class="dn-label">Assign to Agent</span></div>
        <div class="dn dn-tl" draggable="true" data-node="add_label" title="Add Label"><i class="ti ti-tag"></i><span class="dn-label">Add Label</span></div>
        <div class="dn dn-tl" draggable="true" data-node="remove_label" title="Remove Label"><i class="ti ti-tag-off"></i><span class="dn-label">Remove Label</span></div>
        <div class="dn dn-nt" draggable="true" data-node="set_attribute" title="Set Attribute"><i class="ti ti-pencil"></i><span class="dn-label">Set Attribute</span></div>
        <div class="dn dn-sp" draggable="true" data-node="set_priority" title="Set Priority"><i class="ti ti-flag"></i><span class="dn-label">Set Priority</span></div>
        <div class="dn dn-ss" draggable="true" data-node="set_status" title="Set Status"><i class="ti ti-toggle-right"></i><span class="dn-label">Set Status</span></div>
        <div class="dn dn-ti" draggable="true" data-node="transfer_inbox" title="Transfer Inbox"><i class="ti ti-transfer"></i><span class="dn-label">Transfer Inbox</span></div>
        <div class="dn dn-rd" draggable="true" data-node="close" title="Close Conversation"><i class="ti ti-circle-check"></i><span class="dn-label">Close Conversation</span></div>
      </div>
      <div class="sec" style="--sec-color:#3498db"><div class="sec-t" style="--sec-color:#3498db"><span class="dn-label">Integrations</span></div>
        <div class="dn dn-wb" draggable="true" data-node="webhook" title="Webhook"><i class="ti ti-webhook"></i><span class="dn-label">Webhook</span></div>
        <div class="dn dn-api" draggable="true" data-node="api_action" title="API Action"><i class="ti ti-cloud-computing"></i><span class="dn-label">API Action</span></div>
      </div>
    </div>
  </div>

  <!-- CENTER: Canvas -->
  <div class="canvas">
    <div class="hint">Drag nodes to canvas &#x2022; Double-click = edit &#x2022; Scroll = zoom &#x2022; Connect ports</div>
    <div class="canvas-loading" id="canvas-loading"><div class="spinner"></div><span style="font-size:13px;color:var(--text-muted)">Loading...</span></div>
    <div id="drawflow"></div>
    <div class="canvas-empty" id="canvas-empty">
      <div class="canvas-empty-icon"><i class="ti ti-topology-star-3"></i></div>
      <h3>Build a bot in 3 steps</h3>
      <div class="empty-steps">
        <div>&#9312; Start with a <strong>Trigger</strong> (Incoming Message)</div>
        <div>&#9313; Add <strong>Actions</strong> (Message, Buttons, Menu...)</div>
        <div>&#9314; Connect nodes to create a Flow</div>
      </div>
      <p>
        <kbd>Ctrl</kbd>+<kbd>Z</kbd> Undo &#x2022;
        <kbd>Ctrl</kbd>+<kbd>S</kbd> Save &#x2022;
        <kbd>Del</kbd> Delete
      </p>
    </div>
    <div class="zoom">
      <button class="zb" onclick="editor.zoom_out()"><i class="ti ti-minus"></i></button>
      <span class="zoom-pct" id="zoom-pct">100%</span>
      <button class="zb" onclick="editor.zoom_in()"><i class="ti ti-plus"></i></button>
      <button class="zb" onclick="fitToScreen()" title="Fit to screen"><i class="ti ti-arrows-maximize"></i></button>
      <button class="zb" onclick="editor.zoom_reset();updZoom()" title="Reset"><i class="ti ti-refresh"></i></button>
    </div>
    <div class="snap-toggle active" id="snap-toggle" onclick="toggleSnap()" title="Snap to grid">
      <i class="ti ti-grid-dots"></i> <span id="snap-label">Snap</span>
    </div>
    <div class="minimap" id="minimap">
      <canvas id="minimap-canvas" width="320" height="200"></canvas>
    </div>
  </div>

</div>
<!-- Status bar below layout -->
<div class="status-bar">
  <span id="sb-nodes" class="sb-badge sb-badge-blue">0 nodes</span>
  <span id="sb-conns" class="sb-badge sb-badge-green">0 connections</span>
  <span class="status-sep">|</span>
  <span id="sb-snap">Snap: On</span>
  <div style="flex:1"></div>
  <span id="save-ind" class="save-ind"></span>
</div>
</div><!-- /app-main -->
</div><!-- /app-shell -->

<!-- LEFT SIDEBAR: Settings - OVERLAY (outside layout flex) -->
<div class="side-cfg" id="side-cfg" role="dialog" aria-label="Bot Settings">
  <button class="side-cfg-close" id="side-cfg-close"><i class="ti ti-chevron-right" style="font-size:14px"></i> Close <kbd>Esc</kbd></button>
  <h3><i class="ti ti-settings" style="font-size:16px;vertical-align:middle"></i> Bot Settings</h3>
  <label>Description</label>
  <input type="text" id="bdesc" placeholder="Short description..." style="width:100%;margin-bottom:14px">
  <label>Inboxes</label>
  <div id="inbox-list" class="inbox-list"></div>
  <div class="sep"></div>
  <h3><i class="ti ti-chart-bar" style="font-size:16px;vertical-align:middle"></i> Info</h3>
  <div class="sr"><span class="lab">Status</span><span class="val" id="st-s">New</span></div>
  <div class="sr"><span class="lab">Nodes</span><span class="val" id="st-n">0</span></div>
  <div class="sr"><span class="lab">Connections</span><span class="val" id="st-c">0</span></div>
  <div class="sr"><span class="lab">Last updated</span><span class="val" id="st-u">-</span></div>
  <div class="sep"></div>
  <!-- Properties panel -->
  <div id="props-panel" class="props-panel"></div>
  <!-- Tips -->
  <div id="tips-panel" class="tips-panel">
    <h3><i class="ti ti-bulb" style="font-size:16px;vertical-align:middle"></i> Tips</h3>
    <div style="font-size:12px;color:var(--text-muted);line-height:1.8">
      <i class="ti ti-drag-drop" style="font-size:13px"></i> Drag node to canvas<br>
      <i class="ti ti-mouse" style="font-size:13px"></i> Double-click = edit<br>
      <i class="ti ti-device-floppy" style="font-size:13px"></i> Ctrl+S = save<br>
      <i class="ti ti-backspace" style="font-size:13px"></i> Delete = remove node<br>
      <i class="ti ti-arrow-back-up" style="font-size:13px"></i> Ctrl+Z = undo<br>
      <i class="ti ti-menu-2" style="font-size:13px"></i> Right-click = menu
    </div>
  </div>
  <!-- Validation results -->
  <div id="valid-panel" style="display:none">
    <div class="sep"></div>
    <h3 style="color:var(--danger-text)"><i class="ti ti-alert-triangle" style="font-size:16px;vertical-align:middle"></i> Issues</h3>
    <div id="valid-list" class="valid-list"></div>
  </div>
</div>
<div id="toast" class="toast"></div>
<div id="ctx-menu" class="ctx-menu">
  <div class="ctx-item" data-act="duplicate"><i class="ti ti-copy"></i> Duplicate<span class="ks">Ctrl+D</span></div>
  <div class="ctx-item" data-act="copy"><i class="ti ti-clipboard"></i> Copy<span class="ks">Ctrl+C</span></div>
  <div class="ctx-item" data-act="paste"><i class="ti ti-clipboard-check"></i> Paste<span class="ks">Ctrl+V</span></div>
  <div class="ctx-sep"></div>
  <div class="ctx-item ctx-del" data-act="delete"><i class="ti ti-trash"></i> Delete<span class="ks">Del</span></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/drawflow@0.0.59/dist/drawflow.min.js"></script>
<script>
var BOT_ID = __BOT_ID__;
var LOCALE = __LOCALE__;
// Detect from Chatwoot if not set
if(!LOCALE || LOCALE==='en'){try{var k=Object.keys(localStorage);for(var i=0;i<k.length;i++){if(k[i].indexOf('user:')!==-1){try{var u=JSON.parse(localStorage.getItem(k[i]));if(u&&u.locale){LOCALE=u.locale;break}}catch(x){}}}}catch(e){}}
if(!LOCALE)LOCALE='en';
var isHe=LOCALE==='he';
var ARR=isHe?'ti-arrow-left':'ti-arrow-right';
var L={
  // Node categories
  trigger_cat:isHe?'\u05D8\u05E8\u05D9\u05D2\u05E8':'Trigger',
  message_cat:isHe?'\u05D4\u05D5\u05D3\u05E2\u05D4':'Message',
  logic_cat:isHe?'\u05DC\u05D5\u05D2\u05D9\u05E7\u05D4':'Logic',
  action_cat:isHe?'\u05E4\u05E2\u05D5\u05DC\u05D4':'Action',
  integration_cat:isHe?'\u05D0\u05D9\u05E0\u05D8\u05D2\u05E8\u05E6\u05D9\u05D4':'Integration',
  note_cat:isHe?'\u05D4\u05E2\u05E8\u05D4':'Note',
  // Node titles
  incoming_msg:isHe?'\u05D4\u05D5\u05D3\u05E2\u05D4 \u05E0\u05DB\u05E0\u05E1\u05EA':'Incoming Message',
  send_msg:isHe?'\u05E9\u05DC\u05D7 \u05D4\u05D5\u05D3\u05E2\u05D4':'Send Message',
  send_img:isHe?'\u05E9\u05DC\u05D7 \u05EA\u05DE\u05D5\u05E0\u05D4':'Send Image',
  send_vid:isHe?'\u05E9\u05DC\u05D7 \u05D5\u05D9\u05D3\u05D0\u05D5':'Send Video',
  buttons_title:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD':'Buttons',
  menu_title:isHe?'\u05EA\u05E4\u05E8\u05D9\u05D8':'Menu',
  condition_title:isHe?'\u05EA\u05E0\u05D0\u05D9':'Condition',
  delay_title:isHe?'\u05D4\u05DE\u05EA\u05E0\u05D4':'Delay',
  assign_title:isHe?'\u05D4\u05E7\u05E6\u05D4 \u05DC\u05E0\u05E6\u05D9\u05D2':'Assign to Agent',
  add_label_title:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05EA\u05D2\u05D9\u05EA':'Add Label',
  remove_label_title:isHe?'\u05D4\u05E1\u05E8 \u05EA\u05D2\u05D9\u05EA':'Remove Label',
  set_attr_title:isHe?'\u05E2\u05D3\u05DB\u05DF \u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':'Set Attribute',
  close_title:isHe?'\u05E1\u05D2\u05D5\u05E8 \u05E9\u05D9\u05D7\u05D4':'Close Conversation',
  note_title:isHe?'\u05D4\u05E2\u05E8\u05D4 \u05E4\u05E0\u05D9\u05DE\u05D9\u05EA':'Internal Note',
  priority_title:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA \u05E9\u05D9\u05D7\u05D4':'Set Priority',
  status_title:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1 \u05E9\u05D9\u05D7\u05D4':'Set Status',
  transfer_title:isHe?'\u05D4\u05E2\u05D1\u05E8 \u05EA\u05D9\u05D1\u05D4':'Transfer Inbox',
  wait_reply_title:isHe?'\u05D4\u05DE\u05EA\u05DF \u05DC\u05EA\u05E9\u05D5\u05D1\u05D4':'Wait for Reply',
  goto_title:isHe?'\u05E7\u05E4\u05D5\u05E5 \u05DC\u05E9\u05DC\u05D1':'Go to Step',
  // Labels
  trigger_type:isHe?'\u05E1\u05D5\u05D2 \u05D8\u05E8\u05D9\u05D2\u05E8':'Trigger type',
  keyword:isHe?'\u05DE\u05D9\u05DC\u05EA \u05DE\u05E4\u05EA\u05D7':'Keyword',
  any_msg:isHe?'\u05DB\u05DC \u05D4\u05D5\u05D3\u05E2\u05D4':'Any message',
  new_conv:isHe?'\u05E9\u05D9\u05D7\u05D4 \u05D7\u05D3\u05E9\u05D4':'New conversation',
  enter_keyword:isHe?'\u05D4\u05D6\u05DF \u05DE\u05D9\u05DC\u05D4...':'Enter keyword...',
  content:isHe?'\u05EA\u05D5\u05DB\u05DF':'Content',
  type_msg:isHe?'\u05D4\u05E7\u05DC\u05D3 \u05D4\u05D5\u05D3\u05E2\u05D4...':'Type a message...',
  img_url:isHe?'URL \u05EA\u05DE\u05D5\u05E0\u05D4':'Image URL',
  caption:isHe?'\u05DB\u05D9\u05EA\u05D5\u05D1':'Caption',
  optional:isHe?'\u05D0\u05D5\u05E4\u05E6\u05D9\u05D5\u05E0\u05DC\u05D9...':'Optional...',
  vid_url:isHe?'URL \u05D5\u05D9\u05D3\u05D0\u05D5':'Video URL',
  msg_text:isHe?'\u05D8\u05E7\u05E1\u05D8 \u05D4\u05D5\u05D3\u05E2\u05D4':'Message text',
  buttons_label:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD (\u05E2\u05D3 3)':'Buttons (up to 3)',
  btn1:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8 1':'Button 1',
  btn2:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8 2':'Button 2',
  btn3:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8 3':'Button 3',
  title_label:isHe?'\u05DB\u05D5\u05EA\u05E8\u05EA':'Title',
  choose_option:isHe?'\u05D1\u05D7\u05E8 \u05D0\u05E4\u05E9\u05E8\u05D5\u05EA:':'Choose an option:',
  options_label:isHe?'\u05D0\u05E4\u05E9\u05E8\u05D5\u05D9\u05D5\u05EA':'Options',
  opt:isHe?'\u05D0\u05E4\u05E9\u05E8\u05D5\u05EA':'Option',
  check_label:isHe?'\u05D1\u05D3\u05D9\u05E7\u05D4':'Check',
  contains:isHe?'\u05DE\u05DB\u05D9\u05DC\u05D4':'Contains',
  equals:isHe?'\u05E9\u05D5\u05D5\u05D4 \u05DC':'Equals',
  label_exists:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E7\u05D9\u05D9\u05DE\u05EA':'Label exists',
  contact_type:isHe?'\u05E1\u05D5\u05D2 \u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact type',
  conv_status:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1 \u05E9\u05D9\u05D7\u05D4':'Conv. status',
  conv_priority:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA \u05E9\u05D9\u05D7\u05D4':'Conv. priority',
  conv_label:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E9\u05D9\u05D7\u05D4':'Conv. label',
  custom_attr:isHe?'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF \u05DE\u05D5\u05EA\u05D0\u05DD':'Custom attribute',
  contact_field:isHe?'\u05E9\u05D3\u05D4 \u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact field',
  value_label:isHe?'\u05E2\u05E8\u05DA':'Value',
  seconds:isHe?'\u05E9\u05E0\u05D9\u05D5\u05EA':'Seconds',
  typing_ind:isHe?'\u05D0\u05D9\u05E0\u05D3\u05D9\u05E7\u05D8\u05D5\u05E8 \u05D4\u05E7\u05DC\u05D3\u05D4':'Typing indicator',
  no:isHe?'\u05DC\u05D0':'No',
  yes_typing:isHe?'\u05DB\u05DF \u2014 \u05D4\u05E6\u05D2 \u05D4\u05E7\u05DC\u05D3\u05D4':'Yes \u2014 show typing',
  agent:isHe?'\u05E0\u05E6\u05D9\u05D2':'Agent',
  team:isHe?'\u05E6\u05D5\u05D5\u05EA':'Team',
  none:isHe?'\u05DC\u05DC\u05D0':'None',
  label_label:isHe?'\u05EA\u05D2\u05D9\u05EA':'Label',
  select:isHe?'\u05D1\u05D7\u05E8...':'Select...',
  attr_label:isHe?'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':'Attribute',
  close_resolved:isHe?'\u05D4\u05E9\u05D9\u05D7\u05D4 \u05EA\u05E1\u05D5\u05DE\u05DF \u05DB\u05E4\u05EA\u05D5\u05E8\u05D4':'Conversation will be marked as resolved',
  internal_note_ph:isHe?'\u05D4\u05E2\u05E8\u05D4 \u05E4\u05E0\u05D9\u05DE\u05D9\u05EA...':'Internal note...',
  priority_label:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA':'Priority',
  low:isHe?'\u05E0\u05DE\u05D5\u05DB\u05D4':'Low',
  medium:isHe?'\u05D1\u05D9\u05E0\u05D5\u05E0\u05D9\u05EA':'Medium',
  high:isHe?'\u05D2\u05D1\u05D5\u05D4\u05D4':'High',
  urgent:isHe?'\u05D3\u05D7\u05D5\u05E4\u05D4':'Urgent',
  status_label:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1':'Status',
  open:isHe?'\u05E4\u05EA\u05D5\u05D7\u05D4':'Open',
  resolved:isHe?'\u05E4\u05EA\u05D5\u05E8\u05D4':'Resolved',
  pending:isHe?'\u05DE\u05DE\u05EA\u05D9\u05E0\u05D4':'Pending',
  inbox_label:isHe?'\u05EA\u05D9\u05D1\u05EA \u05D3\u05D5\u05D0\u05E8':'Inbox',
  save_var:isHe?'\u05E9\u05DE\u05D5\u05E8 \u05EA\u05E9\u05D5\u05D1\u05D4 \u05D1\u05DE\u05E9\u05EA\u05E0\u05D4':'Save response to variable',
  timeout_sec:isHe?'Timeout (\u05E9\u05E0\u05D9\u05D5\u05EA)':'Timeout (seconds)',
  timeout_msg:isHe?'\u05D4\u05D5\u05D3\u05E2\u05EA timeout (\u05D0\u05D5\u05E4\u05E6\u05D9\u05D5\u05E0\u05DC\u05D9)':'Timeout message (optional)',
  no_reply:isHe?'\u05DC\u05D0 \u05E7\u05D9\u05D1\u05DC\u05E0\u05D5 \u05EA\u05E9\u05D5\u05D1\u05D4. \u05E0\u05E1\u05D4 \u05E9\u05D5\u05D1...':'No reply received. Try again...',
  reply_received:isHe?'\u05EA\u05E9\u05D5\u05D1\u05D4 \u05D4\u05EA\u05E7\u05D1\u05DC\u05D4':'Reply received',
  save_response:isHe?'\u05E9\u05DE\u05D5\u05E8 \u05EA\u05E9\u05D5\u05D1\u05D4 \u05D1\u05DE\u05E9\u05EA\u05E0\u05D4':'Save response to variable',
  test_name:isHe?'Name \u05D4\u05D1\u05D3\u05D9\u05E7\u05D4':'Test name',
  test_ph:isHe?'\u05D1\u05D3\u05D9\u05E7\u05EA \u05D4\u05D5\u05D3\u05E2\u05D4 A':'Message test A',
  split_pct:isHe?'\u05D0\u05D7\u05D5\u05D6 \u05E0\u05EA\u05D9\u05D1 A (%)':'Path A percentage (%)',
  target_node:isHe?'\u05E6\u05D5\u05DE\u05EA \u05D9\u05E2\u05D3':'Target node',
  select_node:isHe?'\u05D1\u05D7\u05E8 \u05E6\u05D5\u05DE\u05EA...':'Select node...',
  // Output labels
  next:isHe?'\u05D4\u05DE\u05E9\u05DA':'Next',
  yes:isHe?'\u05DB\u05DF':'Yes',
  no_out:isHe?'\u05DC\u05D0':'No',
  success:isHe?'\u05D4\u05E6\u05DC\u05D7\u05D4':'Success',
  error:isHe?'\u05E9\u05D2\u05D9\u05D0\u05D4':'Error',
  // Summary / preview placeholders
  keyword_prefix:isHe?'\u05DE\u05D9\u05DC\u05EA \u05DE\u05E4\u05EA\u05D7: ':'Keyword: ',
  type_msg_ph:isHe?'\u05D4\u05E7\u05DC\u05D3 \u05D4\u05D5\u05D3\u05E2\u05D4...':'Type a message...',
  add_buttons_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD...':'Add buttons...',
  add_options_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05D0\u05E4\u05E9\u05E8\u05D5\u05D9\u05D5\u05EA...':'Add options...',
  img_attached:isHe?'\u05EA\u05DE\u05D5\u05E0\u05D4 \u05DE\u05E6\u05D5\u05E8\u05E4\u05EA':'Image attached',
  add_img_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05EA\u05DE\u05D5\u05E0\u05D4...':'Add image...',
  vid_attached:isHe?'\u05D5\u05D9\u05D3\u05D0\u05D5 \u05DE\u05E6\u05D5\u05E8\u05E3':'Video attached',
  add_vid_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05D5\u05D9\u05D3\u05D0\u05D5...':'Add video...',
  typing_label:isHe?'\u05D4\u05E7\u05DC\u05D3\u05D4':'Typing',
  delay_label:isHe?'\u05D4\u05DE\u05EA\u05E0\u05D4':'Delay',
  agent_prefix:isHe?'\u05E0\u05E6\u05D9\u05D2: ':'Agent: ',
  team_prefix:isHe?'\u05E6\u05D5\u05D5\u05EA: ':'Team: ',
  select_agent_team:isHe?'\u05D1\u05D7\u05E8 \u05E0\u05E6\u05D9\u05D2/\u05E6\u05D5\u05D5\u05EA...':'Select agent/team...',
  select_label_ph:isHe?'\u05D1\u05D7\u05E8 \u05EA\u05D2\u05D9\u05EA...':'Select label...',
  select_attr_ph:isHe?'\u05D1\u05D7\u05E8 \u05DE\u05D0\u05E4\u05D9\u05D9\u05DF...':'Select attribute...',
  enter_url_ph:isHe?'\u05D4\u05D6\u05DF URL...':'Enter URL...',
  note_ph:isHe?'\u05D4\u05E2\u05E8\u05D4 \u05E4\u05E0\u05D9\u05DE\u05D9\u05EA...':'Internal note...',
  select_priority_ph:isHe?'\u05D1\u05D7\u05E8 \u05E2\u05D3\u05D9\u05E4\u05D5\u05EA...':'Select priority...',
  priority_prefix:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA: ':'Priority: ',
  select_status_ph:isHe?'\u05D1\u05D7\u05E8 \u05E1\u05D8\u05D8\u05D5\u05E1...':'Select status...',
  status_prefix:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1: ':'Status: ',
  inbox_prefix:isHe?'\u05EA\u05D9\u05D1\u05D4: ':'Inbox: ',
  select_inbox_ph:isHe?'\u05D1\u05D7\u05E8 \u05EA\u05D9\u05D1\u05D4...':'Select inbox...',
  saved_in:isHe?'\u05E9\u05DE\u05D5\u05E8 \u05D1: ':'Saved in: ',
  waiting_reply:isHe?'\u05DE\u05DE\u05EA\u05D9\u05DF \u05DC\u05EA\u05E9\u05D5\u05D1\u05D4':'Waiting for reply',
  set_url_ph:isHe?'\u05D4\u05D2\u05D3\u05E8 URL...':'Set URL...',
  select_target_ph:isHe?'\u05D1\u05D7\u05E8 \u05E6\u05D5\u05DE\u05EA \u05D9\u05E2\u05D3...':'Select target node...',
  goto_node:isHe?'\u05E7\u05E4\u05D5\u05E5 \u05DC\u05E6\u05D5\u05DE\u05EA #':'Go to node #',
  // Condition check types for summary
  cond_contains:isHe?'\u05DE\u05DB\u05D9\u05DC\u05D4':'Contains',
  cond_equals:isHe?'\u05E9\u05D5\u05D5\u05D4 \u05DC':'Equals',
  cond_label_exists:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E7\u05D9\u05D9\u05DE\u05EA':'Label exists',
  cond_contact_type:isHe?'\u05E1\u05D5\u05D2 \u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact type',
  cond_conv_status:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1':'Status',
  cond_conv_priority:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA':'Priority',
  cond_has_label:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E9\u05D9\u05D7\u05D4':'Conv. label',
  cond_custom_attr:isHe?'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':'Attribute',
  cond_contact_field:isHe?'\u05E9\u05D3\u05D4':'Field',
  // Toast messages
  file_exported:isHe?'\u05E7\u05D5\u05D1\u05E5 \u05D9\u05D5\u05E6\u05D0 \u05D1\u05D4\u05E6\u05DC\u05D7\u05D4':'File exported successfully',
  import_confirm:isHe?'\u05D4\u05D9\u05D9\u05D1\u05D5\u05D0 \u05D9\u05D7\u05DC\u05D9\u05E3 \u05D0\u05EA \u05D4-flow \u05D4\u05E0\u05D5\u05DB\u05D7\u05D9. \u05DC\u05D4\u05DE\u05E9\u05D9\u05DA?':'Importing will replace the current flow. Continue?',
  invalid_file:isHe?'\u05E7\u05D5\u05D1\u05E5 \u05DC\u05D0 \u05EA\u05E7\u05D9\u05DF':'Invalid file',
  flow_imported:isHe?'Flow \u05D9\u05D5\u05D1\u05D0 \u05D1\u05D4\u05E6\u05DC\u05D7\u05D4':'Flow imported successfully',
  file_read_err:isHe?'\u05E9\u05D2\u05D9\u05D0\u05D4 \u05D1\u05E7\u05E8\u05D9\u05D0\u05EA \u05D4\u05E7\u05D5\u05D1\u05E5':'Error reading file',
  load_err:isHe?'\u05E9\u05D2\u05D9\u05D0\u05D4 \u05D1\u05D8\u05E2\u05D9\u05E0\u05EA \u05D4\u05D1\u05D5\u05D8':'Error loading bot',
  draft_saved:isHe?'\u05D8\u05D9\u05D5\u05D8\u05D4 \u05E0\u05E9\u05DE\u05E8\u05D4':'Draft saved',
  unsaved_changes:isHe?'\u05E9\u05D9\u05E0\u05D5\u05D9\u05D9\u05DD \u05DC\u05D0 \u05E0\u05E9\u05DE\u05E8\u05D5':'Unsaved changes',
  ls_full:isHe?'localStorage \u05DE\u05DC\u05D0 \u2014 \u05E9\u05DE\u05D5\u05E8 \u05D9\u05D3\u05E0\u05D9\u05EA':'localStorage full \u2014 save manually',
  copied:isHe?'\u05D4\u05D5\u05E2\u05EA\u05E7':'Copied',
  pasted:isHe?'\u05D4\u05D5\u05D3\u05D1\u05E7':'Pasted',
  node_duplicated:isHe?'\u05E6\u05D5\u05DE\u05EA \u05E9\u05D5\u05DB\u05E4\u05DC':'Node duplicated',
  // Draft restore
  ago_moments:isHe?'\u05DC\u05E4\u05E0\u05D9 \u05E8\u05D2\u05E2':'a moment ago',
  ago_min:isHe?'\u05DC\u05E4\u05E0\u05D9 ':'',
  ago_min_suffix:isHe?' \u05D3\u05E7\u05F3':' min ago',
  ago_hours:isHe?'\u05DC\u05E4\u05E0\u05D9 ':'',
  ago_hours_suffix:isHe?' \u05E9\u05E2\u05D5\u05EA':' hours ago',
  ago_days:isHe?'\u05DC\u05E4\u05E0\u05D9 ':'',
  ago_days_suffix:isHe?' \u05D9\u05DE\u05D9\u05DD':' days ago',
  draft_found:isHe?'\u05E0\u05DE\u05E6\u05D0\u05D4 \u05D8\u05D9\u05D5\u05D8\u05D4 \u05DE':'Draft found from ',
  draft_restore:isHe?'. \u05DC\u05E9\u05D7\u05D6\u05E8?':'. Restore?'
};
var botData = null;
var agents=[], labels=[], teams=[], inboxes=[], customAttrs=[], contactFields=[];
var dragNodeType = null;

// ===== DRAWFLOW =====
var dfEl = document.getElementById('drawflow');
var editor = new Drawflow(dfEl);
editor.reroute = false;
editor.curvature = 0.3;
editor.reroute_curvature_start_end = 0.3;
editor.reroute_curvature = 0.3;
editor.force_first_input = false;
editor.start();

// Override broken updateConnectionNodes with custom implementation
var _origUpdateConn = editor.updateConnectionNodes.bind(editor);
editor.updateConnectionNodes = function(id) {
  var pc = editor.precanvas;
  if (!pc) return;
  var pcRect = pc.getBoundingClientRect();
  var z = editor.zoom;
  var curv = editor.curvature;
  // Find all connections involving this node
  var conns = pc.querySelectorAll('.connection.node_in_' + id + ', .connection.node_out_' + id);
  conns.forEach(function(conn) {
    var classes = conn.classList;
    var nodeOutId = null, nodeInId = null, outClass = null, inClass = null;
    classes.forEach(function(c) {
      if (c.indexOf('node_out_') === 0) nodeOutId = c.replace('node_out_', '');
      if (c.indexOf('node_in_') === 0) nodeInId = c.replace('node_in_', '');
      if (c.indexOf('output_') === 0) outClass = c;
      if (c.indexOf('input_') === 0) inClass = c;
    });
    if (!nodeOutId || !nodeInId || !outClass || !inClass) return;
    var outEl = document.querySelector('#' + nodeOutId + ' .outputs .' + outClass);
    var inEl = document.querySelector('#' + nodeInId + ' .inputs .' + inClass);
    if (!outEl || !inEl) return;
    var outR = outEl.getBoundingClientRect();
    var inR = inEl.getBoundingClientRect();
    var ox = (outR.x + outR.width / 2 - pcRect.x) / z;
    var oy = (outR.y + outR.height / 2 - pcRect.y) / z;
    var ix = (inR.x + inR.width / 2 - pcRect.x) / z;
    var iy = (inR.y + inR.height / 2 - pcRect.y) / z;
    var hx = Math.abs(ix - ox) * curv;
    if (hx < 30) hx = 30;
    var d = ' M ' + ox + ' ' + oy + ' C ' + (ox + hx) + ' ' + oy + ' ' + (ix - hx) + ' ' + iy + ' ' + ix + ' ' + iy;
    var mp = conn.querySelector('.main-path');
    if (mp) mp.setAttribute('d', d);
    var hp = conn.querySelector('.hit-path');
    if (hp) hp.setAttribute('d', d);
  });
};

// Also hook into real-time drag updates via position observer
(function() {
  var dragging = false;
  var dragId = null;
  var rafId = null;
  function updateDuringDrag() {
    if (dragging && dragId) {
      editor.updateConnectionNodes('node-' + dragId);
      rafId = requestAnimationFrame(updateDuringDrag);
    }
  }
  editor.on('nodeSelected', function(id) { dragId = id; });
  dfEl.addEventListener('mousedown', function(e) {
    if (e.target.closest && e.target.closest('.drawflow-node')) {
      dragging = true;
      rafId = requestAnimationFrame(updateDuringDrag);
    }
  });
  document.addEventListener('mouseup', function() {
    dragging = false;
    if (rafId) { cancelAnimationFrame(rafId); rafId = null; }
    if (dragId) editor.updateConnectionNodes('node-' + dragId);
  });
})();

editor.on('nodeCreated', function(id){updStats();addNodeActions(id);setTimeout(function(){updateNodeSummary(id);fillGotoSelects()},200);var el=document.getElementById('node-'+id);if(el)el._createdAt=Date.now()});
editor.on('nodeRemoved', function(){updStats();setTimeout(fillGotoSelects,100)});
editor.on('connectionCreated', updStats);
editor.on('connectionRemoved', updStats);

function updStats(){
  var d=editor.export().drawflow.Home.data, nc=0, cc=0;
  for(var k in d){nc++;for(var o in d[k].outputs){cc+=(d[k].outputs[o].connections||[]).length}}
  document.getElementById('st-n').textContent=nc;
  document.getElementById('st-c').textContent=cc;
  var sbn=document.getElementById('sb-nodes');if(sbn)sbn.textContent=nc+' nodes';
  var sbc=document.getElementById('sb-conns');if(sbc)sbc.textContent=cc+' connections';
  updEmpty();
}
function updEmpty(){
  var d=editor.export().drawflow.Home.data;
  var empty=document.getElementById('canvas-empty');
  var hint=document.querySelector('.hint');
  var hasNodes=Object.keys(d).length>0;
  if(empty)empty.classList.toggle('hidden',hasNodes);
  if(hint)hint.style.display=hasNodes?'none':'';
}

function addNodeActions(id){
  var el=document.getElementById('node-'+id);
  if(!el||el.querySelector('.node-actions'))return;
  var acts=document.createElement('div');
  acts.className='node-actions';
  acts.innerHTML='<button class="na-btn na-dup" title="Duplicate" onclick="event.stopPropagation();duplicateNode('+id+')"><i class="ti ti-copy"></i></button><button class="na-btn na-del" title="Delete" onclick="event.stopPropagation();deselectConn();editor.removeNodeId(\'node-'+id+'\');selectedNodeId=null;hideNodeProps();markDirty()"><i class="ti ti-trash"></i></button>';
  el.appendChild(acts);
}
// Add actions to existing nodes on load
function addAllNodeActions(){
  var d=editor.export().drawflow.Home.data;
  for(var k in d)addNodeActions(k);
}

// ===== NODE CONFIG =====
var NC = {
  trigger:      {i:0, o:1, data:{trigger_type:'keyword',keyword:''}},
  message:      {i:1, o:1, data:{message:''}},
  image:        {i:1, o:1, data:{image_url:'',caption:''}},
  video:        {i:1, o:1, data:{video_url:'',caption:''}},
  buttons:      {i:1, o:3, data:{body:'',btn1:'',btn2:'',btn3:''}},
  menu:         {i:1, o:6, data:{title:'',opt1:'',opt2:'',opt3:'',opt4:'',opt5:'',opt6:''}},
  condition:    {i:1, o:2, data:{check_type:'contains',check_value:''}},
  delay:        {i:1, o:1, data:{seconds:'5',typing:'false'}},
  assign:       {i:1, o:1, data:{agent_id:'',team_id:''}},
  add_label:    {i:1, o:1, data:{label_name:''}},
  remove_label: {i:1, o:1, data:{label_name:''}},
  set_attribute:{i:1, o:1, data:{attr_key:'',attr_value:''}},
  close:        {i:1, o:0, data:{}},
  webhook:      {i:1, o:1, data:{url:'',method:'POST',headers:''}},
  note:         {i:0, o:0, data:{text:''}},
  set_priority: {i:1, o:1, data:{priority:''}},
  set_status:   {i:1, o:1, data:{status:''}},
  transfer_inbox:{i:1, o:1, data:{inbox_id:''}},
  wait_reply:   {i:1, o:2, data:{variable:'',timeout_seconds:'300',timeout_message:''}},
  api_action:   {i:1, o:2, data:{method:'GET',url:'',headers:'',body:'',save_response:''}},
  ab_split:     {i:1, o:2, data:{split_a:'50',name:''}},
  goto_step:    {i:1, o:0, data:{target_node:''}}
};

function nHtml(t){
  var tgl='<button class="nh-toggle" onclick="event.stopPropagation();toggleNodeCollapse(this)"><i class="ti ti-chevron-down"></i></button>';
  var olbNext='<div class="olb olb-single"><div class="olb-next"><span>'+L.next+'</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div></div>';
  var h={
    trigger:'<div><div class="nh nh-or"><i class="ti ti-target"></i><div class="nh-text"><span class="nh-cat">'+L.trigger_cat+'</span><span class="nh-title">'+L.incoming_msg+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.trigger_type+'</label><select df-trigger_type><option value="keyword">'+L.keyword+'</option><option value="any">'+L.any_msg+'</option><option value="first">'+L.new_conv+'</option></select><label>'+L.keyword+'</label><input type="text" df-keyword placeholder="'+L.enter_keyword+'"></div><div class="node-preview"></div></div>',
    message:'<div><div class="nh nh-bl"><i class="ti ti-message"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.send_msg+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.content+'</label><textarea df-message placeholder="'+L.type_msg+'" rows="3"></textarea></div><div class="node-preview"></div>'+olbNext+'</div>',
    image:'<div><div class="nh nh-im"><i class="ti ti-photo"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.send_img+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.img_url+'</label><input type="text" df-image_url placeholder="https://..." style="direction:ltr"><label>'+L.caption+'</label><input type="text" df-caption placeholder="'+L.optional+'"></div><div class="node-preview"></div>'+olbNext+'</div>',
    video:'<div><div class="nh nh-vi"><i class="ti ti-video"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.send_vid+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.vid_url+'</label><input type="text" df-video_url placeholder="https://..." style="direction:ltr"><label>'+L.caption+'</label><input type="text" df-caption placeholder="'+L.optional+'"></div><div class="node-preview"></div>'+olbNext+'</div>',
    buttons:'<div><div class="nh nh-bt"><i class="ti ti-click"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.buttons_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.msg_text+'</label><textarea df-body placeholder="'+L.type_msg+'" rows="2"></textarea><label>'+L.buttons_label+'</label><input type="text" df-btn1 placeholder="'+L.btn1+'"><input type="text" df-btn2 placeholder="'+L.btn2+'"><input type="text" df-btn3 placeholder="'+L.btn3+'"></div><div class="node-preview"></div><div class="olb"><div class="olb-btn-label" data-btn="1"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn1+'</span></div><div class="olb-btn-label" data-btn="2"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn2+'</span></div><div class="olb-btn-label" data-btn="3"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn3+'</span></div></div></div>',
    menu:'<div><div class="nh nh-pu"><i class="ti ti-list"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.menu_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.title_label+'</label><input type="text" df-title placeholder="'+L.choose_option+'"><label>'+L.options_label+'</label><input type="text" df-opt1 placeholder="1. ..."><input type="text" df-opt2 placeholder="2. ..."><input type="text" df-opt3 placeholder="3. ..."><input type="text" df-opt4 placeholder="4. ..."><input type="text" df-opt5 placeholder="5. ..."><input type="text" df-opt6 placeholder="6. ..."></div><div class="node-preview"></div><div class="olb"><div class="olb-btn-label" data-opt="1"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 1</span></div><div class="olb-btn-label" data-opt="2"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 2</span></div><div class="olb-btn-label" data-opt="3"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 3</span></div><div class="olb-btn-label" data-opt="4"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 4</span></div><div class="olb-btn-label" data-opt="5"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 5</span></div><div class="olb-btn-label" data-opt="6"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 6</span></div></div></div>',
    condition:'<div><div class="nh nh-ye"><i class="ti ti-git-branch"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.condition_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.check_label+'</label><select df-check_type><option value="contains">'+L.contains+'</option><option value="equals">'+L.equals+'</option><option value="regex">Regex</option><option value="label_exists">'+L.label_exists+'</option><option value="contact_type">'+L.contact_type+'</option><option value="conversation_status">'+L.conv_status+'</option><option value="conversation_priority">'+L.conv_priority+'</option><option value="has_label">'+L.conv_label+'</option><option value="custom_attribute">'+L.custom_attr+'</option><option value="contact_field">'+L.contact_field+'</option></select><label>'+L.value_label+'</label><input type="text" df-check_value placeholder="..."></div><div class="node-preview"></div><div class="olb"><div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.yes+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.no_out+' <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    delay:'<div><div class="nh nh-dl"><i class="ti ti-clock-pause"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.delay_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.seconds+'</label><input type="number" df-seconds value="5" min="1" max="3600"><label>'+L.typing_ind+'</label><select df-typing><option value="false">'+L.no+'</option><option value="true">'+L.yes_typing+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    assign:'<div><div class="nh nh-gr"><i class="ti ti-user"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.assign_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.agent+'</label><select df-agent_id class="asel"><option value="">'+L.none+'</option></select><label>'+L.team+'</label><select df-team_id class="tsel"><option value="">'+L.none+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    add_label:'<div><div class="nh nh-tl"><i class="ti ti-tag"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.add_label_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.label_label+'</label><select df-label_name class="lsel"><option value="">'+L.select+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    remove_label:'<div><div class="nh nh-tl"><i class="ti ti-tag-off"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.remove_label_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.label_label+'</label><select df-label_name class="lsel"><option value="">'+L.select+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    set_attribute:'<div><div class="nh nh-at"><i class="ti ti-pencil"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.set_attr_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.attr_label+'</label><select df-attr_key class="casel"><option value="">'+L.select+'</option></select><label>'+L.value_label+'</label><input type="text" df-attr_value placeholder="..."></div><div class="node-preview"></div>'+olbNext+'</div>',
    close:'<div><div class="nh nh-rd"><i class="ti ti-circle-check"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.close_title+'</span></div></div><div class="node-preview"><div class="pv-info"><i class="ti ti-circle-check" style="font-size:12px"></i> '+L.close_resolved+'</div></div></div>',
    webhook:'<div><div class="nh nh-wb"><i class="ti ti-webhook"></i><div class="nh-text"><span class="nh-cat">'+L.integration_cat+'</span><span class="nh-title">Webhook</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>URL</label><input type="text" df-url placeholder="https://..." style="direction:ltr"><label>Method</label><select df-method><option value="POST">POST</option><option value="GET">GET</option></select><label>Headers (JSON)</label><textarea df-headers placeholder=\'{"Authorization":"Bearer ..."}\' rows="2" style="direction:ltr"></textarea></div><div class="node-preview"></div>'+olbNext+'</div>',
    note:'<div><div class="nh nh-nt"><i class="ti ti-note"></i><div class="nh-text"><span class="nh-cat">'+L.note_cat+'</span><span class="nh-title">'+L.note_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><textarea df-text placeholder="'+L.internal_note_ph+'" rows="2"></textarea></div><div class="node-preview"></div></div>',
    set_priority:'<div><div class="nh nh-sp"><i class="ti ti-flag"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.priority_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.priority_label+'</label><select df-priority><option value="">'+L.select+'</option><option value="0">'+L.low+'</option><option value="1">'+L.medium+'</option><option value="2">'+L.high+'</option><option value="3">'+L.urgent+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    set_status:'<div><div class="nh nh-ss"><i class="ti ti-toggle-right"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.status_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.status_label+'</label><select df-status><option value="">'+L.select+'</option><option value="open">'+L.open+'</option><option value="resolved">'+L.resolved+'</option><option value="pending">'+L.pending+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    transfer_inbox:'<div><div class="nh nh-ti"><i class="ti ti-transfer"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.transfer_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.inbox_label+'</label><select df-inbox_id class="ibsel"><option value="">'+L.select+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    wait_reply:'<div><div class="nh nh-wr"><i class="ti ti-message-question"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.wait_reply_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.save_var+'</label><input type="text" df-variable placeholder="reply_text" style="direction:ltr"><label>'+L.timeout_sec+'</label><input type="number" df-timeout_seconds value="300" min="10" max="86400"><label>'+L.timeout_msg+'</label><textarea df-timeout_message placeholder="'+L.no_reply+'" rows="2"></textarea></div><div class="node-preview"></div><div class="olb"><div><i class="ti ti-message-check" style="font-size:10px;color:#16A34A"></i> '+L.reply_received+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-clock-x" style="font-size:10px;color:#DC2626"></i> Timeout <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    api_action:'<div><div class="nh nh-api"><i class="ti ti-cloud-computing"></i><div class="nh-text"><span class="nh-cat">'+L.integration_cat+'</span><span class="nh-title">API Action</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>Method</label><select df-method><option value="GET">GET</option><option value="POST">POST</option><option value="PUT">PUT</option><option value="PATCH">PATCH</option><option value="DELETE">DELETE</option></select><label>URL</label><input type="text" df-url placeholder="https://api.example.com/..." style="direction:ltr"><label>Headers (JSON)</label><textarea df-headers placeholder=\'{"Authorization":"Bearer ..."}\' rows="2" style="direction:ltr"></textarea><label>Body (JSON)</label><textarea df-body placeholder=\'{"key":"value"}\' rows="2" style="direction:ltr"></textarea><label>'+L.save_response+'</label><input type="text" df-save_response placeholder="api_result" style="direction:ltr"></div><div class="node-preview"></div><div class="olb"><div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.success+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.error+' <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    ab_split:'<div><div class="nh nh-ab"><i class="ti ti-arrows-split-2"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">A/B Split</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.test_name+'</label><input type="text" df-name placeholder="'+L.test_ph+'"><label>'+L.split_pct+'</label><input type="number" df-split_a value="50" min="1" max="99"></div><div class="node-preview"></div><div class="olb"><div><span style="font-weight:600;color:#6366f1">A</span> <span class="olb-pct">50%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><span style="font-weight:600;color:#a855f7">B</span> <span class="olb-pct">50%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    goto_step:'<div><div class="nh nh-go"><i class="ti ti-arrow-back-up"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.goto_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.target_node+'</label><select df-target_node class="goto-sel"><option value="">'+L.select_node+'</option></select></div><div class="node-preview"></div></div>'
  };
  return h[t]||'<div>???</div>';
}

// ===== COLLAPSIBLE NODES =====
function toggleNodeCollapse(btn){
  var nb=btn.closest('.drawflow_content_node').querySelector('.nb-collapsible');
  if(!nb)return;
  var isOpen=nb.classList.contains('nb-open');
  if(isOpen){
    nb.classList.remove('nb-open');
    btn.classList.remove('open');
    var nodeEl=btn.closest('.drawflow-node');
    if(nodeEl){
      var m=nodeEl.id.match(/node-(\d+)/);
      if(m)updateNodeSummary(m[1]);
    }
  }else{
    nb.classList.add('nb-open');
    btn.classList.add('open');
  }
  // Update Drawflow connections continuously during transition + after completion
  var nodeEl=btn.closest('.drawflow-node');
  if(nodeEl){
    var nid=nodeEl.id;
    var done=false;
    // Continuous updates during transition for smooth wire following
    var iv=setInterval(function(){editor.updateConnectionNodes(nid)},30);
    var finish=function(){if(done)return;done=true;clearInterval(iv);editor.updateConnectionNodes(nid)};
    nb.addEventListener('transitionend',function handler(e){
      if(e.propertyName==='max-height'){nb.removeEventListener('transitionend',handler);finish()}
    });
    setTimeout(finish,320);// fallback
  }
}

function getSummaryText(type,data){
  if(!data)return '';
  switch(type){
    case 'trigger':var tt=data.trigger_type||'keyword';if(tt==='any')return L.any_msg;if(tt==='first')return L.new_conv;return data.keyword?L.keyword_prefix+data.keyword:'';
    case 'message':var m=data.message||'';return m?(m.length>45?m.substring(0,45)+'\u2026':m):'';
    default:return '';
  }
}
function getSummaryHtml(type,data){
  if(!data)return '';
  switch(type){
    case 'trigger':
      var tt=data.trigger_type||'keyword';
      var label=tt==='any'?L.any_msg:tt==='first'?L.new_conv:L.keyword;
      var val=tt==='keyword'&&data.keyword?data.keyword:'';
      return '<div class="pv-trigger"><i class="ti ti-bolt" style="font-size:12px"></i> '+escHtml(label)+(val?' \u2014 <b>'+escHtml(val)+'</b>':'')+'</div>';
    case 'message':
      var m=data.message||'';
      if(!m)return '<span class="pv-empty">'+L.type_msg_ph+'</span>';
      return '<div class="pv-bubble">'+escHtml(m.length>80?m.substring(0,80)+'\u2026':m)+'</div>';
    case 'buttons':
      var bh='';
      if(data.body)bh+='<div class="pv-bubble">'+escHtml(data.body.length>60?data.body.substring(0,60)+'\u2026':data.body)+'</div>';
      var bs=[data.btn1,data.btn2,data.btn3].filter(Boolean);
      if(bs.length)bh+='<div class="pv-btns">'+bs.map(function(b){return '<span class="pv-pill">'+escHtml(b)+'</span>'}).join('')+'</div>';
      return bh||'<span class="pv-empty">'+L.add_buttons_ph+'</span>';
    case 'menu':
      var mh='';
      if(data.title)mh+='<div class="pv-bubble pv-bubble-sm">'+escHtml(data.title)+'</div>';
      var os=[data.opt1,data.opt2,data.opt3,data.opt4,data.opt5,data.opt6].filter(Boolean);
      if(os.length)mh+='<div class="pv-list">'+os.map(function(o,i){return '<div class="pv-list-item">'+(i+1)+'. '+escHtml(o)+'</div>'}).join('')+'</div>';
      return mh||'<span class="pv-empty">'+L.add_options_ph+'</span>';
    case 'image':
      return data.image_url?'<div class="pv-media"><i class="ti ti-photo"></i> '+(data.caption?escHtml(data.caption):L.img_attached)+'</div>':'<span class="pv-empty">'+L.add_img_ph+'</span>';
    case 'video':
      return data.video_url?'<div class="pv-media"><i class="ti ti-video"></i> '+(data.caption?escHtml(data.caption):L.vid_attached)+'</div>':'<span class="pv-empty">'+L.add_vid_ph+'</span>';
    case 'condition':
      var cl={contains:L.cond_contains,equals:L.cond_equals,regex:'Regex',label_exists:L.cond_label_exists,contact_type:L.cond_contact_type,conversation_status:L.cond_conv_status,conversation_priority:L.cond_conv_priority,has_label:L.cond_has_label,custom_attribute:L.cond_custom_attr,contact_field:L.cond_contact_field};
      var ct=data.check_type||'contains';var v=data.check_value||'';
      return '<div class="pv-condition"><i class="ti ti-filter" style="font-size:12px"></i> '+escHtml(cl[ct]||ct)+(v?' \u2192 <b>'+escHtml(v)+'</b>':'')+'</div>';
    case 'delay':
      var typing=data.typing==='true'?' + <i class="ti ti-keyboard" style="font-size:12px"></i> '+L.typing_label:'';
      return '<div class="pv-info"><i class="ti ti-clock-pause" style="font-size:14px"></i> '+L.delay_label+' '+(data.seconds||5)+' '+L.seconds+typing+'</div>';
    case 'assign':
      var pa=[];
      if(data.agent_id){var ag=agents.find(function(a){return String(a.id)===String(data.agent_id)});if(ag)pa.push(L.agent_prefix+ag.name)}
      if(data.team_id){var tm=teams.find(function(t){return String(t.id)===String(data.team_id)});if(tm)pa.push(L.team_prefix+tm.name)}
      return pa.length?'<div class="pv-info"><i class="ti ti-user" style="font-size:14px"></i> '+escHtml(pa.join(' \u00B7 '))+'</div>':'<span class="pv-empty">'+L.select_agent_team+'</span>';
    case 'add_label':
      return data.label_name?'<div class="pv-info"><i class="ti ti-tag" style="font-size:14px"></i> '+escHtml(data.label_name)+'</div>':'<span class="pv-empty">'+L.select_label_ph+'</span>';
    case 'remove_label':
      return data.label_name?'<div class="pv-info"><i class="ti ti-tag-off" style="font-size:14px"></i> '+escHtml(data.label_name)+'</div>':'<span class="pv-empty">'+L.select_label_ph+'</span>';
    case 'set_attribute':
      return data.attr_key?'<div class="pv-info"><i class="ti ti-pencil" style="font-size:14px"></i> '+escHtml(data.attr_key)+' = '+(data.attr_value?escHtml(data.attr_value):'\u2014')+'</div>':'<span class="pv-empty">'+L.select_attr_ph+'</span>';
    case 'close':return '';
    case 'webhook':
      return data.url?'<div class="pv-info"><i class="ti ti-webhook" style="font-size:14px"></i> '+(data.method||'POST')+' \u2192 '+escHtml(data.url.length>30?data.url.substring(0,30)+'\u2026':data.url)+'</div>':'<span class="pv-empty">'+L.enter_url_ph+'</span>';
    case 'note':
      var nt=data.text||'';
      return nt?'<div class="pv-bubble" style="background:var(--note-bg);border:1px solid var(--note-border)">'+escHtml(nt.length>60?nt.substring(0,60)+'\u2026':nt)+'</div>':'<span class="pv-empty">'+L.note_ph+'</span>';
    case 'set_priority':
      var pm={'0':L.low,'1':L.medium,'2':L.high,'3':L.urgent};
      return pm[data.priority]?'<div class="pv-info"><i class="ti ti-flag" style="font-size:14px"></i> '+L.priority_prefix+escHtml(pm[data.priority])+'</div>':'<span class="pv-empty">'+L.select_priority_ph+'</span>';
    case 'set_status':
      var sm={'open':L.open,'resolved':L.resolved,'pending':L.pending};
      return sm[data.status]?'<div class="pv-info"><i class="ti ti-toggle-right" style="font-size:14px"></i> '+L.status_prefix+escHtml(sm[data.status])+'</div>':'<span class="pv-empty">'+L.select_status_ph+'</span>';
    case 'transfer_inbox':
      if(data.inbox_id){var ib=inboxes.find(function(i){return String(i.id)===String(data.inbox_id)});if(ib)return '<div class="pv-info"><i class="ti ti-transfer" style="font-size:14px"></i> '+L.inbox_prefix+escHtml(ib.name)+'</div>'}
      return '<span class="pv-empty">'+L.select_inbox_ph+'</span>';
    case 'wait_reply':
      var wr='<div class="pv-wait"><i class="ti ti-message-question" style="font-size:12px"></i> ';
      wr+=data.variable?L.saved_in+'<b>{{'+escHtml(data.variable)+'}}</b>':L.waiting_reply;
      wr+='</div>';
      if(data.timeout_seconds)wr+='<div class="pv-info" style="margin-top:4px"><i class="ti ti-clock" style="font-size:11px"></i> Timeout: '+data.timeout_seconds+' '+L.seconds+'</div>';
      return wr;
    case 'api_action':
      if(!data.url)return '<div class="pv-api"><i class="ti ti-cloud-computing" style="font-size:12px"></i> '+L.set_url_ph+'</div>';
      var ah='<div class="pv-api"><span style="font-weight:700;font-size:10px;background:rgba(67,56,202,.15);padding:2px 6px;border-radius:4px">'+(data.method||'GET')+'</span> '+escHtml(data.url.length>35?data.url.substring(0,35)+'\u2026':data.url)+'</div>';
      if(data.save_response)ah+='<div class="pv-info" style="margin-top:3px"><i class="ti ti-variable" style="font-size:11px"></i> \u2192 {{'+escHtml(data.save_response)+'}}</div>';
      return ah;
    case 'ab_split':
      var sa=parseInt(data.split_a)||50;var sb=100-sa;
      return '<div class="pv-split"><span style="font-weight:700;background:rgba(99,102,241,.15);padding:1px 8px;border-radius:10px;color:#6366f1">A: '+sa+'%</span> <span style="font-weight:700;background:rgba(168,85,247,.15);padding:1px 8px;border-radius:10px;color:#a855f7">B: '+sb+'%</span>'+(data.name?' <span style="opacity:.7">\u2014 '+escHtml(data.name)+'</span>':'')+'</div>';
    case 'goto_step':
      if(!data.target_node)return '<div class="pv-goto"><i class="ti ti-arrow-back-up" style="font-size:12px"></i> '+L.select_target_ph+'</div>';
      return '<div class="pv-goto"><i class="ti ti-arrow-back-up" style="font-size:14px"></i> '+L.goto_node+escHtml(data.target_node)+'</div>';
    default:return '';
  }
}

function updateNodeSummary(id){
  var nd=editor.getNodeFromId(id);
  if(!nd)return;
  var el=document.getElementById('node-'+id);
  if(!el)return;
  var html=getSummaryHtml(nd.name,nd.data);
  // Update node-preview with rich HTML
  var prev=el.querySelector('.node-preview');
  if(prev)prev.innerHTML=html;
  // Update olb button/option labels
  if(nd.name==='buttons'){
    var bls=el.querySelectorAll('.olb-btn-label[data-btn] span');
    var bd=[nd.data.btn1,nd.data.btn2,nd.data.btn3];
    for(var bi=0;bi<bls.length;bi++){bls[bi].textContent=bd[bi]||(L.btn1.replace(/\d/,''+(bi+1)))}
  }else if(nd.name==='menu'){
    var ols=el.querySelectorAll('.olb-btn-label[data-opt] span');
    var od=[nd.data.opt1,nd.data.opt2,nd.data.opt3,nd.data.opt4,nd.data.opt5,nd.data.opt6];
    for(var oi=0;oi<ols.length;oi++){ols[oi].textContent=od[oi]||(L.opt+' '+(oi+1))}
  }else if(nd.name==='ab_split'){
    var pcts=el.querySelectorAll('.olb-pct');
    var sa=parseInt(nd.data.split_a)||50;
    if(pcts.length>=2){pcts[0].textContent=sa+'%';pcts[1].textContent=(100-sa)+'%'}
  }
}

function updateAllSummaries(){
  var d=editor.export().drawflow.Home.data;
  for(var k in d)updateNodeSummary(k);
}

// ===== UPGRADE OLD SAVED NODES =====
// Drawflow stores HTML at creation time. Saved bots have old HTML without nh-text/nh-cat.
// This function upgrades old nodes after editor.import() to match the new ManyChat-style layout.
function upgradeLoadedNodes(){
  var data=editor.export().drawflow.Home.data;
  var meta={
    trigger:{icon:'ti-target',cat:L.trigger_cat,title:L.incoming_msg},
    message:{icon:'ti-message',cat:L.message_cat,title:L.send_msg},
    image:{icon:'ti-photo',cat:L.message_cat,title:L.send_img},
    video:{icon:'ti-video',cat:L.message_cat,title:L.send_vid},
    buttons:{icon:'ti-click',cat:L.message_cat,title:L.buttons_title},
    menu:{icon:'ti-list',cat:L.message_cat,title:L.menu_title},
    condition:{icon:'ti-git-branch',cat:L.logic_cat,title:L.condition_title},
    delay:{icon:'ti-clock-pause',cat:L.logic_cat,title:L.delay_title},
    assign:{icon:'ti-user',cat:L.action_cat,title:L.assign_title},
    add_label:{icon:'ti-tag',cat:L.action_cat,title:L.add_label_title},
    remove_label:{icon:'ti-tag-off',cat:L.action_cat,title:L.remove_label_title},
    set_attribute:{icon:'ti-pencil',cat:L.action_cat,title:L.set_attr_title},
    close:{icon:'ti-circle-check',cat:L.action_cat,title:L.close_title},
    webhook:{icon:'ti-webhook',cat:L.integration_cat,title:'Webhook'},
    note:{icon:'ti-note',cat:L.note_cat,title:L.note_title},
    set_priority:{icon:'ti-flag',cat:L.action_cat,title:L.priority_title},
    set_status:{icon:'ti-toggle-right',cat:L.action_cat,title:L.status_title},
    transfer_inbox:{icon:'ti-transfer',cat:L.action_cat,title:L.transfer_title},
    wait_reply:{icon:'ti-message-question',cat:L.logic_cat,title:L.wait_reply_title},
    api_action:{icon:'ti-cloud-computing',cat:L.integration_cat,title:'API Action'},
    ab_split:{icon:'ti-arrows-split-2',cat:L.logic_cat,title:'A/B Split'},
    goto_step:{icon:'ti-arrow-back-up',cat:L.logic_cat,title:L.goto_title}
  };
  var singleTypes=['trigger','message','image','video','delay','assign','add_label','remove_label','set_attribute','webhook','set_priority','set_status','transfer_inbox'];
  for(var id in data){
    var nd=data[id];
    var el=document.getElementById('node-'+id);
    if(!el)continue;
    var m=meta[nd.name];
    if(!m)continue;
    // Skip if already upgraded (has nh-text)
    if(el.querySelector('.nh-text'))continue;
    // 1. Upgrade header: add nh-text structure
    var nh=el.querySelector('.nh');
    if(nh){
      var icon=nh.querySelector('i');
      var toggle=nh.querySelector('.nh-toggle');
      // Remove everything between icon and toggle (old text nodes/spans)
      if(icon){
        while(icon.nextSibling&&icon.nextSibling!==toggle){
          nh.removeChild(icon.nextSibling);
        }
      }
      // Insert nh-text
      var td=document.createElement('div');
      td.className='nh-text';
      td.innerHTML='<span class="nh-cat">'+m.cat+'</span><span class="nh-title">'+m.title+'</span>';
      if(toggle)nh.insertBefore(td,toggle);
      else if(icon)icon.insertAdjacentElement('afterend',td);
      else nh.appendChild(td);
    }
    // 2. Collapse node
    var nb=el.querySelector('.nb-collapsible');
    if(nb)nb.classList.remove('nb-open');
    var tgl=el.querySelector('.nh-toggle');
    if(tgl)tgl.classList.remove('open');
    // 3. Ensure node-preview exists
    var prev=el.querySelector('.node-preview');
    if(!prev){
      prev=document.createElement('div');
      prev.className='node-preview';
      var nbEl=el.querySelector('.nb-collapsible');
      var olbEl=el.querySelector('.olb');
      var ctn=el.querySelector('.drawflow_content_node>div');
      if(nbEl&&nbEl.nextSibling)nbEl.parentNode.insertBefore(prev,nbEl.nextSibling);
      else if(olbEl)olbEl.parentNode.insertBefore(prev,olbEl);
      else if(ctn)ctn.appendChild(prev);
    }
    // 4. Upgrade or create olb labels (not for trigger/close/note which have no olb in new design)
    var olb=el.querySelector('.olb');
    var needsOlb=nd.name!=='trigger'&&nd.name!=='close'&&nd.name!=='note'&&NC[nd.name]&&NC[nd.name].o>0;
    if(!olb&&needsOlb){
      // Create olb when missing
      olb=document.createElement('div');
      olb.className='olb';
      var ctn=el.querySelector('.drawflow_content_node>div');
      if(ctn)ctn.appendChild(olb);
    }
    if(olb&&!olb.querySelector('.olb-next')&&!olb.querySelector('.olb-btn-label')){
      if(nd.name==='buttons'){
        olb.innerHTML='<div class="olb-btn-label" data-btn="1"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn1+'</span></div><div class="olb-btn-label" data-btn="2"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn2+'</span></div><div class="olb-btn-label" data-btn="3"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn3+'</span></div>';
      }else if(nd.name==='menu'){
        var mh='';for(var oi=1;oi<=6;oi++)mh+='<div class="olb-btn-label" data-opt="'+oi+'"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' '+oi+'</span></div>';
        olb.innerHTML=mh;
      }else if(nd.name==='condition'){
        olb.innerHTML='<div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.yes+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.no_out+' <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else if(nd.name==='wait_reply'){
        olb.innerHTML='<div><i class="ti ti-message-check" style="font-size:10px;color:#16A34A"></i> '+L.reply_received+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-clock-x" style="font-size:10px;color:#DC2626"></i> Timeout <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else if(nd.name==='api_action'){
        olb.innerHTML='<div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.success+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.error+' <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else if(nd.name==='ab_split'){
        var sa=parseInt(nd.data.split_a)||50;
        olb.innerHTML='<div><span style="font-weight:600;color:#6366f1">A</span> <span class="olb-pct">'+sa+'%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><span style="font-weight:600;color:#a855f7">B</span> <span class="olb-pct">'+(100-sa)+'%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else{
        olb.className='olb olb-single';
        olb.innerHTML='<div class="olb-next"><span>'+L.next+'</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }
    }
  }
}

// ===== CONDITION INLINE DYNAMIC FIELDS =====
// When check_type dropdown changes inside a condition node, swap the value field
function getInlineOpts(ct){
  switch(ct){
    case 'contact_type':return [['0','Visitor'],['1','Lead'],['2','Customer']];
    case 'conversation_status':return [['open','Open'],['resolved','Resolved'],['pending','Pending'],['snoozed','Snoozed']];
    case 'conversation_priority':return [['0','Low'],['1','Medium'],['2','High'],['3','Urgent']];
    case 'has_label':return labels.map(function(l){return [l.title,l.title]});
    case 'label_exists':return labels.map(function(l){return [l.title,l.title]});
    default:return null;
  }
}

dfEl.addEventListener('change',function(e){
  if(!e.target.hasAttribute('df-check_type'))return;
  var nodeEl=e.target.closest('.drawflow-node');
  if(!nodeEl)return;
  var ct=e.target.value;
  var nb=nodeEl.querySelector('.nb');
  if(!nb)return;
  // Find old value input/select
  var oldVal=nb.querySelector('[df-check_value]');
  if(!oldVal)return;
  var opts=getInlineOpts(ct);
  if(opts){
    // Replace text input with select
    var sel=document.createElement('select');
    sel.setAttribute('df-check_value','');
    var ph=document.createElement('option');ph.value='';ph.textContent='Select...';sel.appendChild(ph);
    for(var i=0;i<opts.length;i++){
      var o=document.createElement('option');o.value=opts[i][0];o.textContent=opts[i][1];sel.appendChild(o);
    }
    oldVal.replaceWith(sel);
    // Also open the node if collapsed
    var nbCol=nodeEl.querySelector('.nb-collapsible');
    var toggle=nodeEl.querySelector('.nh-toggle');
    if(nbCol&&!nbCol.classList.contains('nb-open')){
      nbCol.classList.add('nb-open');
      if(toggle)toggle.classList.add('open');
      var iv2=setInterval(function(){editor.updateConnectionNodes(nodeEl.id)},30);
      nbCol.addEventListener('transitionend',function h2(e){if(e.propertyName==='max-height'){nbCol.removeEventListener('transitionend',h2);clearInterval(iv2);editor.updateConnectionNodes(nodeEl.id)}});
      setTimeout(function(){clearInterval(iv2);editor.updateConnectionNodes(nodeEl.id)},320);
    }
  } else {
    // Replace select with text input
    if(oldVal.tagName==='SELECT'){
      var inp=document.createElement('input');
      inp.type='text';inp.setAttribute('df-check_value','');inp.placeholder='...';
      oldVal.replaceWith(inp);
    }
  }
  // Update node data
  var m=nodeEl.id.match(/node-(\d+)/);
  if(m){
    var nd=editor.getNodeFromId(m[1]);
    if(nd){nd.data.check_value='';editor.updateNodeDataFromId(m[1],nd.data);updateNodeSummary(m[1]);markDirty();pushUndo()}
  }
});

// ===== DRAG & DROP (dual: click-to-place + HTML5 DnD) =====
var selectedNodeType = null;
var dns = document.querySelectorAll('.dn[draggable]');

function clearNodeSelection(){
  for(var j=0;j<dns.length;j++){dns[j].classList.remove('dn-selected')}
  dfEl.style.cursor='';
}

for(var i=0;i<dns.length;i++){
  (function(el){
    // HTML5 DnD: dragstart with preview
    el.addEventListener('dragstart', function(ev){
      dragNodeType = this.getAttribute('data-node');
      ev.dataTransfer.setData('text/plain', dragNodeType);
      ev.dataTransfer.effectAllowed = 'move';
      var ghost=this.cloneNode(true);
      ghost.style.cssText='position:absolute;left:-9999px;width:200px;opacity:.85;border-radius:12px;overflow:hidden;pointer-events:none;background:var(--bg-node);box-shadow:0 4px 16px rgba(0,0,0,.12)';
      document.body.appendChild(ghost);
      ev.dataTransfer.setDragImage(ghost,100,20);
      setTimeout(function(){if(ghost.parentNode)ghost.parentNode.removeChild(ghost)},60);
    });
    el.addEventListener('dragend', function(){ dragNodeType = null; });

    // Click-to-place: click sidebar node, then click canvas
    el.addEventListener('click', function(ev){
      ev.stopPropagation();
      var t = this.getAttribute('data-node');
      if(selectedNodeType === t){ selectedNodeType=null; clearNodeSelection(); return; }
      selectedNodeType = t;
      clearNodeSelection();
      this.classList.add('dn-selected');
      dfEl.style.cursor = 'crosshair';
    });
  })(dns[i]);
}

// Document-level DnD handlers (bypass Drawflow event interception)
document.addEventListener('dragover', function(e){ if(dragNodeType) e.preventDefault(); }, false);
document.addEventListener('drop', function(e){
  if(!dragNodeType) return;
  e.preventDefault();
  // Check if drop is over the canvas area
  var canvasEl = document.querySelector('.canvas');
  var rect = canvasEl.getBoundingClientRect();
  if(e.clientX < rect.left || e.clientX > rect.right || e.clientY < rect.top || e.clientY > rect.bottom){
    dragNodeType = null; return;
  }
  addNodeAt(dragNodeType, e.clientX, e.clientY);
  dragNodeType = null;
}, false);

// Click-to-place on canvas
dfEl.addEventListener('click', function(e){
  if(!selectedNodeType) return;
  if(e.target.closest && e.target.closest('.drawflow-node')) return;
  addNodeAt(selectedNodeType, e.clientX, e.clientY);
  selectedNodeType = null;
  clearNodeSelection();
});

// Shared: add node at screen position
function addNodeAt(type, clientX, clientY){
  if(!type || !NC[type]) return;
  var c = NC[type];
  var rect = editor.precanvas.getBoundingClientRect();
  var pos_x = (clientX - rect.x) / editor.zoom;
  var pos_y = (clientY - rect.y) / editor.zoom;
  editor.addNode(type, c.i, c.o, pos_x, pos_y, type, JSON.parse(JSON.stringify(c.data)), nHtml(type));
  setTimeout(popSelects, 150);
}

// ===== SELECTS =====
function popSelects(){
  fillAll('.asel',agents,'id','name','None');
  fillAll('.tsel',teams,'id','name','None');
  fillAll('.lsel',labels,'title','title','Select...');
  fillAll('.ibsel',inboxes,'id','name','Select...');
  fillAllCA('.casel',customAttrs);
  fillGotoSelects();
}
function fillGotoSelects(){
  var sels=document.querySelectorAll('.goto-sel');
  if(!sels.length)return;
  var d=editor.export().drawflow.Home.data;
  var nodes=[];
  for(var nid in d){
    var nd=d[nid];
    if(nd.name==='goto_step')continue;
    var m={trigger:'Trigger',message:'Message',buttons:'Buttons',menu:'Menu',condition:'Condition',delay:'Delay',image:'Image',video:'Video',assign:'Assign',add_label:'Label+',remove_label:'Label-',set_attribute:'Attribute',webhook:'Webhook',close:'Close',note:'Note',set_priority:'Priority',set_status:'Status',transfer_inbox:'Transfer',wait_reply:'Wait Reply',api_action:'API',ab_split:'A/B'};
    nodes.push({id:nid,label:'#'+nid+' '+(m[nd.name]||nd.name)});
  }
  for(var i=0;i<sels.length;i++){
    var s=sels[i],cv=s.value;
    while(s.options.length>0)s.remove(0);
    var ph=document.createElement('option');ph.value='';ph.textContent='Select node...';s.appendChild(ph);
    for(var j=0;j<nodes.length;j++){
      var o=document.createElement('option');o.value=nodes[j].id;o.textContent=nodes[j].label;
      if(cv===nodes[j].id)o.selected=true;
      s.appendChild(o);
    }
  }
}
function fillAllCA(cls,items){
  var sels=document.querySelectorAll(cls);
  for(var i=0;i<sels.length;i++){
    var s=sels[i],cv=s.value;
    while(s.options.length>0)s.remove(0);
    var d=document.createElement('option');d.value='';d.textContent='Select...';s.appendChild(d);
    var contactAttrs=items.filter(function(a){return a.model===0||a.model==='contact_attribute'});
    var convAttrs=items.filter(function(a){return a.model===1||a.model==='conversation_attribute'});
    if(contactAttrs.length){
      var og=document.createElement('optgroup');og.label='Contact';
      for(var j=0;j<contactAttrs.length;j++){var o=document.createElement('option');o.value=contactAttrs[j].key;o.textContent=contactAttrs[j].name;if(cv===contactAttrs[j].key)o.selected=true;og.appendChild(o)}
      s.appendChild(og);
    }
    if(convAttrs.length){
      var og=document.createElement('optgroup');og.label='Conversation';
      for(var j=0;j<convAttrs.length;j++){var o=document.createElement('option');o.value=convAttrs[j].key;o.textContent=convAttrs[j].name;if(cv===convAttrs[j].key)o.selected=true;og.appendChild(o)}
      s.appendChild(og);
    }
  }
}
function fillAll(cls,items,vk,tk,ph){
  var sels=document.querySelectorAll(cls);
  for(var i=0;i<sels.length;i++){
    var s=sels[i],cv=s.value;
    while(s.options.length>0)s.remove(0);
    var d=document.createElement('option');d.value='';d.textContent=ph;s.appendChild(d);
    for(var j=0;j<items.length;j++){
      var o=document.createElement('option');o.value=items[j][vk];o.textContent=items[j][tk];
      if(String(cv)===String(items[j][vk]))o.selected=true;
      s.appendChild(o);
    }
  }
}

// ===== INBOXES =====
function renderInboxes(){
  var el=document.getElementById('inbox-list');
  while(el.firstChild)el.removeChild(el.firstChild);
  var sel=botData?(botData.inbox_ids||[]):[];
  if(!inboxes.length){
    var m=document.createElement('div');m.style.cssText='color:#555;font-size:12px;padding:8px';
    m.textContent='No inboxes found';el.appendChild(m);return;
  }
  for(var i=0;i<inboxes.length;i++){
    (function(ib){
      var d=document.createElement('div');
      d.className='inbox-item'+(sel.indexOf(ib.id)!==-1?' sel':'');
      var cb=document.createElement('input');cb.type='checkbox';cb.value=ib.id;
      cb.checked=sel.indexOf(ib.id)!==-1;
      var sp=document.createElement('span');sp.textContent=ib.name;
      var sm=document.createElement('small');sm.textContent=ib.channel_type?ib.channel_type.split('::').pop():'';
      d.appendChild(cb);d.appendChild(sp);d.appendChild(sm);
      d.addEventListener('click',function(e){if(e.target!==cb)cb.checked=!cb.checked;d.className='inbox-item'+(cb.checked?' sel':'')});
      el.appendChild(d);
    })(inboxes[i]);
  }
}

// ===== API =====
function fetchT(url,opts,ms){
  var ctrl=new AbortController();opts=Object.assign({},opts||{},{signal:ctrl.signal});
  var t=setTimeout(function(){ctrl.abort()},ms||30000);
  return fetch(url,opts).finally(function(){clearTimeout(t)});
}
function safeFetch(url){
  return fetchT(url).then(function(r){ return r.ok ? r.json() : []; }).catch(function(){ return []; });
}
function loadMeta(){
  return Promise.all([
    safeFetch('/bot-builder/api/agents'),
    safeFetch('/bot-builder/api/labels'),
    safeFetch('/bot-builder/api/teams'),
    safeFetch('/bot-builder/api/inboxes'),
    safeFetch('/bot-builder/api/custom_attributes'),
    safeFetch('/bot-builder/api/contact_fields')
  ]).then(function(r){
    agents=r[0]||[];labels=r[1]||[];teams=r[2]||[];inboxes=r[3]||[];customAttrs=r[4]||[];contactFields=r[5]||[];
    console.log('[BotBuilder] Loaded: agents='+agents.length+' labels='+labels.length+' teams='+teams.length+' inboxes='+inboxes.length+' customAttrs='+customAttrs.length+' contactFields='+contactFields.length);
    renderInboxes();popSelects();
  });
}

// ===== EXPORT / IMPORT =====
function downloadFlow(){
  var d=editor.export();
  var name=(document.getElementById('bname').value.trim()||'bot')+'.json';
  var blob=new Blob([JSON.stringify(d,null,2)],{type:'application/json'});
  var a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=name;
  document.body.appendChild(a);a.click();document.body.removeChild(a);URL.revokeObjectURL(a.href);
  toast(L.file_exported,'ok');
}
function importFlow(inp){
  var f=inp.files[0];if(!f)return;
  if(!confirm(L.import_confirm)){inp.value='';return}
  var r=new FileReader();
  r.onload=function(ev){
    try{
      var d=JSON.parse(ev.target.result);
      if(!d.drawflow){toast(L.invalid_file,'err');return}
      pushUndo();editor.import(d);
      setTimeout(function(){popSelects();updStats();addAllNodeActions();upgradeLoadedNodes();updateAllSummaries();addConnHitAreas()},200);
      markDirty();pushUndo();
      toast(L.flow_imported,'ok');
    }catch(ex){toast(L.file_read_err,'err')}
  };
  r.readAsText(f);inp.value='';
}

// ===== SAVE =====
var saving=false;
document.getElementById('savebtn').addEventListener('click',function(){
  var btn=this;
  if(saving)return;
  var name=document.getElementById('bname').value.trim();
  if(!name){toast('Enter a bot name','err');return}
  saving=true;btn.disabled=true;btn.innerHTML='<i class="ti ti-loader-2" style="font-size:16px;animation:spin .7s linear infinite"></i> Saving...';
  var cbs=document.querySelectorAll('#inbox-list input:checked'),ids=[];
  for(var i=0;i<cbs.length;i++)ids.push(parseInt(cbs[i].value));
  var data={
    id:BOT_ID||(botData?botData.id:null),
    name:name,
    description:document.getElementById('bdesc').value.trim(),
    inbox_ids:ids,
    active:botData?(botData.active!==false):true,
    flow:editor.export()
  };
  fetchT('/bot-builder/api/bots',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)},30000)
    .then(function(r){if(!r.ok)throw new Error();return r.json()})
    .then(function(s){
      botData=s;
      if(!BOT_ID){BOT_ID=s.id;history.replaceState(null,'','/bot-builder/'+s.id+'/edit')}
      document.getElementById('st-s').textContent=s.active?'Active':'Disabled';
      document.getElementById('st-u').textContent='Just now';
      toast('Bot saved successfully!','ok');markSaved();
      if(BOT_ID)try{localStorage.removeItem('bot-draft-'+BOT_ID)}catch(ex){}
    }).catch(function(err){toast(err&&err.name==='AbortError'?'Save failed — timeout':'Error saving','err')})
    .finally(function(){saving=false;btn.disabled=false;btn.innerHTML='<i class="ti ti-device-floppy"></i> Save'});
});

// ===== LOAD =====
function loadBot(id){
  fetchT('/bot-builder/api/bots/'+encodeURIComponent(id),null,30000)
    .then(function(r){return r.ok?r.json():null})
    .then(function(d){
      if(!d)return;botData=d;
      document.getElementById('bname').value=d.name||'';
      document.getElementById('bdesc').value=d.description||'';
      document.getElementById('st-s').textContent=d.active?'Active':'Disabled';
      try{var t=new Date(d.updated_at);document.getElementById('st-u').textContent=t.toLocaleDateString('he-IL')+' '+t.toLocaleTimeString('he-IL',{hour:'2-digit',minute:'2-digit'})}catch(e){}
      // Check for unsaved draft
      var useDraft=false;
      try{
        var draft=localStorage.getItem('bot-draft-'+id);
        if(draft){var dd=JSON.parse(draft);if(dd.ts&&d.updated_at&&dd.ts>new Date(d.updated_at).getTime()){var ago=(function(t){var m=Math.round((Date.now()-t)/60000);if(m<1)return L.ago_moments;if(m<60)return L.ago_min+m+L.ago_min_suffix;var h=Math.round(m/60);if(h<24)return L.ago_hours+h+L.ago_hours_suffix;return L.ago_days+Math.round(h/24)+L.ago_days_suffix})(dd.ts);if(confirm(L.draft_found+ago+L.draft_restore)){d.flow=dd.flow;if(dd.name)document.getElementById('bname').value=dd.name;useDraft=true}else{localStorage.removeItem('bot-draft-'+id)}}}
      }catch(ex){}
      if(d.flow){editor.import(d.flow);setTimeout(function(){popSelects();updStats();addAllNodeActions();upgradeLoadedNodes();updateAllSummaries();autoAlign()},200)}
      if(useDraft)markDirty();
      renderInboxes();
      document.getElementById('canvas-loading').classList.add('done');
    })
    .catch(function(err){
      document.getElementById('canvas-loading').classList.add('done');
      toast(L.load_err,'err');
    });
}

// ===== TOAST =====
var toastTimer=null;
function toast(m,t){
  clearTimeout(toastTimer);
  var el=document.getElementById('toast');
  // Note: icon HTML is static/safe, m is escaped via escHtml
  var icon=t==='err'?'<i class="ti ti-alert-circle" style="font-size:14px"></i> ':'<i class="ti ti-check" style="font-size:14px"></i> ';
  el.innerHTML=icon+escHtml(m);
  el.className='toast toast-'+(t||'ok')+' show';
  toastTimer=setTimeout(function(){el.classList.remove('show')},t==='err'?5000:3000);
}

// ===== UNSAVED CHANGES TRACKING =====
var hasUnsavedChanges = false;
var saveInd = document.getElementById('save-ind');
function markDirty(){
  if(!hasUnsavedChanges){hasUnsavedChanges=true;saveInd.textContent='Unsaved changes';saveInd.className='save-ind dirty'}
}
var lastSaveTime=null;
function markSaved(){
  hasUnsavedChanges=false;lastSaveTime=new Date();
  saveInd.textContent='\u2713 Saved';saveInd.className='save-ind saved';
  setTimeout(function(){if(!hasUnsavedChanges&&lastSaveTime){
    var diff=Math.floor((Date.now()-lastSaveTime.getTime())/60000);
    saveInd.textContent=diff<1?'\u2713 Saved':'Saved '+diff+' min ago';
    saveInd.className='save-ind saved';
  }},5000);
}
window.addEventListener('beforeunload',function(e){if(hasUnsavedChanges){e.preventDefault();e.returnValue=''}});
// Auto-save draft to localStorage every 30s
setInterval(function(){
  if(!hasUnsavedChanges||!BOT_ID)return;
  try{
    localStorage.setItem('bot-draft-'+BOT_ID,JSON.stringify({flow:editor.export(),name:document.getElementById('bname').value,ts:Date.now()}));
    var si=document.getElementById('save-ind');
    if(si){si.textContent=L.draft_saved;si.className='save-ind saved';setTimeout(function(){if(hasUnsavedChanges){si.textContent=L.unsaved_changes;si.className='save-ind dirty'}},2000)}
  }catch(ex){toast(L.ls_full,'err')}
},30000);
editor.on('nodeCreated',function(){markDirty();pushUndo()});
editor.on('nodeRemoved',function(){markDirty();pushUndo()});
editor.on('connectionCreated',function(info){markDirty();pushUndo();addConnHitAreas();smartReposition(info)});
editor.on('connectionRemoved',function(){markDirty();pushUndo()});
// nodeMoved: single merged handler below (snap → undo → minimap)

// ===== UNDO STACK =====
var undoStack=[];
var redoStack=[];
var undoMax=100;
var isUndoing=false;
function updUndoState(){
  var ub=document.getElementById('undo-btn'),rb=document.getElementById('redo-btn');
  if(ub)ub.disabled=undoStack.length<2;
  if(rb)rb.disabled=redoStack.length===0;
}
function pushUndo(){
  if(isUndoing)return;
  var snap=JSON.stringify(editor.export());
  if(undoStack.length>0&&undoStack[undoStack.length-1]===snap)return;
  undoStack.push(snap);
  if(undoStack.length>undoMax)undoStack.shift();
  redoStack=[];
  updUndoState();
}
function undo(){
  if(undoStack.length<2)return;
  isUndoing=true;
  var cur=undoStack.pop();
  redoStack.push(cur);
  var prev=undoStack[undoStack.length-1];
  editor.import(JSON.parse(prev));
  setTimeout(function(){popSelects();updStats();isUndoing=false;updEmpty();upgradeLoadedNodes();updateAllSummaries();addConnHitAreas()},200);
  markDirty();updUndoState();
}
function redo(){
  if(!redoStack.length)return;
  isUndoing=true;
  var snap=redoStack.pop();
  undoStack.push(snap);
  editor.import(JSON.parse(snap));
  setTimeout(function(){popSelects();updStats();isUndoing=false;updEmpty();upgradeLoadedNodes();updateAllSummaries();addConnHitAreas()},200);
  markDirty();updUndoState();
}
// initial snapshot
setTimeout(function(){pushUndo()},500);

// ===== ZOOM TRACKING =====
function updZoom(){
  var pct=Math.round((editor.zoom||1)*100);
  document.getElementById('zoom-pct').textContent=pct+'%';
}
// Override zoom methods to track
var _zi=editor.zoom_in.bind(editor),_zo=editor.zoom_out.bind(editor),_zr=editor.zoom_reset.bind(editor);
editor.zoom_in=function(){_zi();updZoom()};
editor.zoom_out=function(){_zo();updZoom()};
editor.zoom_reset=function(){_zr();updZoom()};
// Track scroll-zoom
dfEl.addEventListener('wheel',function(){setTimeout(updZoom,50)});

// Add invisible wider hit-area paths to connections for easier clicking
function addConnHitAreas(){
  var paths=dfEl.querySelectorAll('.connection .main-path');
  for(var i=0;i<paths.length;i++){
    var p=paths[i];
    if(p.previousElementSibling&&p.previousElementSibling.classList.contains('hit-path'))continue;
    var hp=p.cloneNode(false);
    hp.setAttribute('class','hit-path');
    hp.style.cssText='stroke-width:16;stroke:transparent;fill:none;pointer-events:stroke;cursor:pointer;opacity:0';
    p.parentNode.insertBefore(hp,p);
    hp.addEventListener('click',function(ev){
      var mp=this.nextElementSibling;
      if(mp&&mp.classList.contains('main-path')){
        mp.dispatchEvent(new MouseEvent('click',{bubbles:true,clientX:ev.clientX,clientY:ev.clientY}));
      }
    });
  }
}
// Run on load + after undo/redo
setTimeout(addConnHitAreas,500);

function fitToScreen(){
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);if(!keys.length)return;
  var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];
    var el=document.querySelector('#node-'+keys[i]);
    var nw=el?el.offsetWidth:280,nodeH=el?el.offsetHeight:80;
    var x=n.pos_x,y=n.pos_y;
    if(x<minX)minX=x;if(y<minY)minY=y;
    if(x+nw>maxX)maxX=x+nw;if(y+nodeH>maxY)maxY=y+nodeH;
  }
  var cRect=document.querySelector('.canvas').getBoundingClientRect();
  var cW=cRect.width-60,cH=cRect.height-60;
  var fW=maxX-minX,fH=maxY-minY;
  if(fW<1||fH<1)return;
  var z=Math.min(cW/fW,cH/fH,1.5);
  z=Math.max(z,0.2);
  editor.zoom=z;
  editor.canvas_x=cW/2-((minX+maxX)/2)*z;
  editor.canvas_y=cH/2-((minY+maxY)/2)*z;
  editor.precanvas.style.transform='translate('+editor.canvas_x+'px, '+editor.canvas_y+'px) scale('+editor.zoom+')';
  updZoom();
}

// ===== KEYBOARD SHORTCUTS =====
function isInputFocused(){
  var t=document.activeElement;
  if(!t)return false;
  var tn=t.tagName.toLowerCase();
  return tn==='input'||tn==='textarea'||tn==='select'||t.isContentEditable;
}

document.addEventListener('keydown',function(e){
  // Ctrl+S: Save
  if((e.ctrlKey||e.metaKey)&&e.key==='s'){
    e.preventDefault();
    var sb=document.getElementById('savebtn');
    if(!sb.disabled)sb.click();
    return;
  }
  // Ctrl+Z: Undo, Ctrl+Shift+Z: Redo
  if((e.ctrlKey||e.metaKey)&&e.key==='z'){
    if(isInputFocused())return;
    e.preventDefault();
    if(e.shiftKey){redo()}else{undo()}
    return;
  }
  if((e.ctrlKey||e.metaKey)&&e.key==='y'){
    if(isInputFocused())return;
    e.preventDefault();
    redo();
    return;
  }
  // Ctrl+D: Duplicate selected node
  if((e.ctrlKey||e.metaKey)&&e.key==='d'){
    if(isInputFocused())return;
    e.preventDefault();
    duplicateSelected();
    return;
  }
  // Ctrl+C: Copy selected node
  if((e.ctrlKey||e.metaKey)&&e.key==='c'&&!isInputFocused()){
    e.preventDefault();
    var cid=getSelectedNodeId();if(!cid)return;
    var cnd=editor.getNodeFromId(cid);
    if(cnd){clipboard={name:cnd.name,data:JSON.parse(JSON.stringify(cnd.data)),pos_x:cnd.pos_x,pos_y:cnd.pos_y};toast(L.copied,'ok')}
    return;
  }
  // Ctrl+V: Paste copied node
  if((e.ctrlKey||e.metaKey)&&e.key==='v'&&!isInputFocused()){
    e.preventDefault();
    if(clipboard){
      var c=NC[clipboard.name];
      var pOff=Math.round(60/editor.zoom);
      if(c){
        editor.addNode(clipboard.name,c.i,c.o,clipboard.pos_x+pOff,clipboard.pos_y+pOff,clipboard.name,JSON.parse(JSON.stringify(clipboard.data)),nHtml(clipboard.name));
        setTimeout(popSelects,150);markDirty();pushUndo();
        toast(L.pasted,'ok');
      }
    }
    return;
  }
  if(isInputFocused())return;
  // Delete/Backspace: Delete selected connection or node
  if(e.key==='Delete'||e.key==='Backspace'){
    if(selectedConn){
      var connG=selectedConn.closest('.connection');
      if(connG){
        var nOut,nIn,oC,iC;
        connG.classList.forEach(function(c){
          if(c.startsWith('node_in_'))nIn=c.replace('node_in_node-','');
          if(c.startsWith('node_out_'))nOut=c.replace('node_out_node-','');
          if(c.startsWith('output_'))oC=c;
          if(c.startsWith('input_'))iC=c;
        });
        if(nOut&&nIn&&oC&&iC){editor.removeSingleConnection(nOut,nIn,oC,iC);markDirty();pushUndo()}
      }
      selectedConn=null;
      return;
    }
    deleteSelected();
    return;
  }
  // Arrow keys: Nudge selected node
  if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight'].includes(e.key)){
    var nid=getSelectedNodeId();if(!nid)return;
    e.preventDefault();
    var step=e.shiftKey?GRID:1;
    var nd=editor.getNodeFromId(nid);if(!nd)return;
    if(e.key==='ArrowLeft')nd.pos_x-=step;
    if(e.key==='ArrowRight')nd.pos_x+=step;
    if(e.key==='ArrowUp')nd.pos_y-=step;
    if(e.key==='ArrowDown')nd.pos_y+=step;
    var nel=document.getElementById('node-'+nid);
    if(nel){nel.style.left=nd.pos_x+'px';nel.style.top=nd.pos_y+'px';editor.updateConnectionNodes('node-'+nid)}
    markDirty();pushUndo();updateMinimap();
    return;
  }
  // F2: Open properties panel for selected node
  if(e.key==='F2'){
    var fid=getSelectedNodeId();if(!fid)return;
    e.preventDefault();openCfg();showNodeProps(fid);return;
  }
  // Escape: Close settings panel / Collapse all / Deselect
  if(e.key==='Escape'){
    if(sideCfg&&sideCfg.classList.contains('open')){closeCfg();return}
    collapseAllNodes();
    deselectAll();
    hideCtxMenu();
    // Update wires after collapse
    var allN=document.querySelectorAll('.drawflow-node');
    for(var ni=0;ni<allN.length;ni++){editor.updateConnectionNodes(allN[ni].id)}
    return;
  }
});

// ===== NODE SELECTION TRACKING =====
var selectedNodeId=null;
// nodeSelected/Unselected handled in SIDE-CFG OVERLAY section

function getSelectedNodeId(){
  if(selectedNodeId)return selectedNodeId;
  var sel=document.querySelector('.drawflow-node.selected');
  if(sel){var m=sel.id.match(/node-(\d+)/);if(m)return m[1]}
  return null;
}

function deleteSelected(){
  var id=getSelectedNodeId();
  if(id){deselectConn();editor.removeNodeId('node-'+id);selectedNodeId=null;hideNodeProps()}
}

function duplicateSelected(){
  var id=getSelectedNodeId();
  if(!id)return;
  duplicateNode(id);
}

function duplicateNode(id){
  var nd=editor.getNodeFromId(id);
  if(!nd)return;
  var c=NC[nd.name];if(!c)return;
  var newData=JSON.parse(JSON.stringify(nd.data));
  var newId=editor.addNode(nd.name,c.i,c.o,nd.pos_x+40,nd.pos_y+40,nd.name,newData,nHtml(nd.name));
  setTimeout(popSelects,150);
  markDirty();pushUndo();
  toast(L.node_duplicated,'ok');
  var newEl=document.getElementById('node-'+newId);
  if(newEl){newEl.classList.add('node-dup-pulse');setTimeout(function(){newEl.classList.remove('node-dup-pulse')},600)}
}

// ===== NODE SEARCH =====
document.getElementById('node-search').addEventListener('input',function(){
  var q=this.value.trim().toLowerCase();
  var secs=document.querySelectorAll('.side-nodes .sec');
  var totalVis=0;
  for(var s=0;s<secs.length;s++){
    var items=secs[s].querySelectorAll('.dn');
    var vis=0;
    for(var i=0;i<items.length;i++){
      var txt=items[i].textContent.toLowerCase();
      var ntype=items[i].getAttribute('data-node')||'';
      if(!q||txt.indexOf(q)!==-1||ntype.indexOf(q)!==-1){items[i].style.display='';vis++}
      else{items[i].style.display='none'}
    }
    secs[s].style.display=vis>0?'':'none';
    totalVis+=vis;
  }
  var noRes=document.getElementById('nodes-no-results');
  if(noRes)noRes.style.display=(q&&totalVis===0)?'block':'none';
});

// ===== PROPERTIES PANEL =====
var propsMeta={
  trigger:{icon:'<i class="ti ti-target"></i>',color:'#ff6b35',title:'Incoming Message',fields:[
    {key:'trigger_type',label:'Trigger type',type:'select',opts:[['keyword','Keyword'],['any','Any message'],['first','New conversation']]},
    {key:'keyword',label:'Keyword',type:'text',ph:'Enter keyword...'}
  ]},
  message:{icon:'<i class="ti ti-message"></i>',color:'#4a9eff',title:'Send Message',fields:[
    {key:'message',label:'Message content',type:'textarea',ph:'Type a message...'}
  ]},
  image:{icon:'<i class="ti ti-photo"></i>',color:'#2ecc71',title:'Send Image',fields:[
    {key:'image_url',label:'Image URL',type:'text',ph:'https://...',dir:'ltr'},
    {key:'caption',label:'Caption',type:'text',ph:'Optional...'}
  ]},
  video:{icon:'<i class="ti ti-video"></i>',color:'#6c5ce7',title:'Send Video',fields:[
    {key:'video_url',label:'Video URL',type:'text',ph:'https://...',dir:'ltr'},
    {key:'caption',label:'Caption',type:'text',ph:'Optional...'}
  ]},
  buttons:{icon:'<i class="ti ti-click"></i>',color:'#00b894',title:'Buttons',fields:[
    {key:'body',label:'Message text',type:'textarea',ph:'Type a message...'},
    {key:'btn1',label:'Button 1',type:'text',ph:'Button 1'},
    {key:'btn2',label:'Button 2',type:'text',ph:'Button 2'},
    {key:'btn3',label:'Button 3',type:'text',ph:'Button 3'}
  ]},
  menu:{icon:'<i class="ti ti-list"></i>',color:'#9b59b6',title:'Menu',fields:[
    {key:'title',label:'Title',type:'text',ph:'Choose an option:'},
    {key:'opt1',label:'Option 1',type:'text',ph:'1. ...'},
    {key:'opt2',label:'Option 2',type:'text',ph:'2. ...'},
    {key:'opt3',label:'Option 3',type:'text',ph:'3. ...'},
    {key:'opt4',label:'Option 4',type:'text',ph:'4. ...'},
    {key:'opt5',label:'Option 5',type:'text',ph:'5. ...'},
    {key:'opt6',label:'Option 6',type:'text',ph:'6. ...'}
  ]},
  condition:{icon:'<i class="ti ti-git-branch"></i>',color:'#f1c40f',title:'Condition',fields:[
    {key:'check_type',label:'Check type',type:'select',opts:[['contains','Contains'],['equals','Equals'],['regex','Regex'],['label_exists','Label exists'],['contact_type','Contact type'],['conversation_status','Conv. status'],['conversation_priority','Conv. priority'],['has_label','Conv. label'],['custom_attribute','Custom attribute'],['contact_field','Contact field']]},
    {key:'check_value',label:'Value',type:'cond_value',ph:'...'}
  ]},
  delay:{icon:'<i class="ti ti-clock-pause"></i>',color:'#8e44ad',title:'Delay',fields:[
    {key:'seconds',label:'Seconds',type:'number',ph:'5'}
  ]},
  assign:{icon:'<i class="ti ti-user"></i>',color:'#27ae60',title:'Assign to Agent',fields:[
    {key:'agent_id',label:'Agent',type:'agent_select'},
    {key:'team_id',label:'Team',type:'team_select'}
  ]},
  add_label:{icon:'<i class="ti ti-tag"></i>',color:'#00b894',title:'Add Label',fields:[
    {key:'label_name',label:'Label',type:'label_select'}
  ]},
  remove_label:{icon:'<i class="ti ti-tag-off"></i>',color:'#00b894',title:'Remove Label',fields:[
    {key:'label_name',label:'Label',type:'label_select'}
  ]},
  set_attribute:{icon:'<i class="ti ti-pencil"></i>',color:'#e67e22',title:'Set Attribute',fields:[
    {key:'attr_key',label:'Attribute',type:'custom_attr_select'},
    {key:'attr_value',label:'Value',type:'text',ph:'...'}
  ]},
  close:{icon:'<i class="ti ti-circle-check"></i>',color:'#e74c3c',title:'Close Conversation',fields:[]},
  webhook:{icon:'<i class="ti ti-webhook"></i>',color:'#3498db',title:'Webhook',fields:[
    {key:'url',label:'URL',type:'text',ph:'https://...',dir:'ltr'},
    {key:'method',label:'Method',type:'select',opts:[['POST','POST'],['GET','GET']]},
    {key:'headers',label:'Headers (JSON)',type:'textarea',ph:'{"Authorization":"Bearer ..."}',dir:'ltr'}
  ]},
  note:{icon:'<i class="ti ti-note"></i>',color:'#95a5a6',title:'Note',fields:[
    {key:'text',label:'Internal note',type:'textarea',ph:'...'}
  ]},
  set_priority:{icon:'<i class="ti ti-flag"></i>',color:'#f1c40f',title:'Conv. priority',fields:[
    {key:'priority',label:'Priority',type:'select',opts:[['','Select...'],['0','Low'],['1','Medium'],['2','High'],['3','Urgent']]}
  ]},
  set_status:{icon:'<i class="ti ti-toggle-right"></i>',color:'#6366F1',title:'Conv. status',fields:[
    {key:'status',label:'Status',type:'select',opts:[['','Select...'],['open','Open'],['resolved','Resolved'],['pending','Pending']]}
  ]},
  transfer_inbox:{icon:'<i class="ti ti-transfer"></i>',color:'#9b59b6',title:'Transfer Inbox',fields:[
    {key:'inbox_id',label:'Inbox',type:'inbox_select'}
  ]}
};

function showNodeProps(id){
  var nd=editor.getNodeFromId(id);
  if(!nd)return;
  var meta=propsMeta[nd.name];
  if(!meta)return;
  var pp=document.getElementById('props-panel');
  var tp=document.getElementById('tips-panel');
  tp.classList.add('hidden');
  var h='<div class="props-hdr"><div class="props-icon" style="background:'+meta.color+'33;color:'+meta.color+'">'+meta.icon+'</div><div><div class="props-title">'+meta.title+'</div><div class="props-type">'+nd.name+' #'+id+'</div></div></div>';
  for(var i=0;i<meta.fields.length;i++){
    var f=meta.fields[i];
    var val=nd.data[f.key]||'';
    h+='<div class="props-field"><label>'+f.label+'</label>';
    if(f.type==='textarea'){
      h+='<textarea data-pkey="'+f.key+'" placeholder="'+(f.ph||'')+'" rows="3">'+escHtml(val)+'</textarea>';
    } else if(f.type==='select'){
      h+='<select data-pkey="'+f.key+'">';
      for(var j=0;j<f.opts.length;j++){
        h+='<option value="'+f.opts[j][0]+'"'+(val===f.opts[j][0]?' selected':'')+'>'+f.opts[j][1]+'</option>';
      }
      h+='</select>';
    } else if(f.type==='agent_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">None</option>';
      for(var j=0;j<agents.length;j++){h+='<option value="'+agents[j].id+'"'+(String(val)===String(agents[j].id)?' selected':'')+'>'+escHtml(agents[j].name)+'</option>'}
      h+='</select>';
    } else if(f.type==='team_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">None</option>';
      for(var j=0;j<teams.length;j++){h+='<option value="'+teams[j].id+'"'+(String(val)===String(teams[j].id)?' selected':'')+'>'+escHtml(teams[j].name)+'</option>'}
      h+='</select>';
    } else if(f.type==='label_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">Select...</option>';
      for(var j=0;j<labels.length;j++){h+='<option value="'+escHtml(labels[j].title)+'"'+(val===labels[j].title?' selected':'')+'>'+escHtml(labels[j].title)+'</option>'}
      h+='</select>';
    } else if(f.type==='inbox_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">Select...</option>';
      for(var j=0;j<inboxes.length;j++){h+='<option value="'+inboxes[j].id+'"'+(String(val)===String(inboxes[j].id)?' selected':'')+'>'+escHtml(inboxes[j].name)+'</option>'}
      h+='</select>';
    } else if(f.type==='custom_attr_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">select an attribute...</option>';
      var ca0=customAttrs.filter(function(a){return a.model===0||a.model==='contact_attribute'});
      var ca1=customAttrs.filter(function(a){return a.model===1||a.model==='conversation_attribute'});
      if(ca0.length){h+='<optgroup label="Contact">';for(var j=0;j<ca0.length;j++){h+='<option value="'+escHtml(ca0[j].key)+'"'+(val===ca0[j].key?' selected':'')+'>'+escHtml(ca0[j].name)+'</option>'}h+='</optgroup>'}
      if(ca1.length){h+='<optgroup label="Conversation">';for(var j=0;j<ca1.length;j++){h+='<option value="'+escHtml(ca1[j].key)+'"'+(val===ca1[j].key?' selected':'')+'>'+escHtml(ca1[j].name)+'</option>'}h+='</optgroup>'}
      h+='</select>';
    } else if(f.type==='cond_value'){
      // Dynamic value field based on check_type
      var ct=nd.data.check_type||'contains';
      h+=buildCondValueField(ct,val,nd.data.attr_key||'');
    } else {
      h+='<input type="'+(f.type||'text')+'" data-pkey="'+f.key+'" value="'+escHtml(val)+'" placeholder="'+(f.ph||'')+'"'+(f.dir?' style="direction:'+f.dir+'"':'')+'>';
    }
    h+='</div>';
  }
  h+='<button class="props-del" onclick="deleteSelected()"><i class="ti ti-trash" style="font-size:14px;vertical-align:middle"></i> Delete node</button>';
  pp.innerHTML=h;
  pp.classList.add('active');
  // Bind real-time sync
  var inputs=pp.querySelectorAll('[data-pkey]');
  for(var k=0;k<inputs.length;k++){
    (function(inp){
      var evType=(inp.tagName==='SELECT')?'change':'input';
      inp.addEventListener(evType,function(){
        var key=this.getAttribute('data-pkey');
        var nid=getSelectedNodeId();
        if(!nid)return;
        var nd=editor.getNodeFromId(nid);
        if(!nd)return;
        var merged=JSON.parse(JSON.stringify(nd.data));
        merged[key]=this.value;
        editor.updateNodeDataFromId(nid,merged);
        markDirty();
        updateNodeSummary(nid);
        // Debounced undo push for field edits
        clearTimeout(inp._undoTimer);
        inp._undoTimer=setTimeout(function(){pushUndo()},400);
        // If check_type changed, rebuild value field
        if(key==='check_type'&&nd.name==='condition'){
          merged.check_value='';merged.attr_key='';
          editor.updateNodeDataFromId(nid,merged);
          showNodeProps(nid);
        }
      });
    })(inputs[k]);
  }
}
function buildCondValueField(ct,val,attrKey){
  var h='';
  switch(ct){
    case 'contact_type':
      h+='<select data-pkey="check_value"><option value="">Select...</option>';
      h+='<option value="0"'+(val==='0'?' selected':'')+'>Visitor</option>';
      h+='<option value="1"'+(val==='1'?' selected':'')+'>Lead</option>';
      h+='<option value="2"'+(val==='2'?' selected':'')+'>Customer</option>';
      h+='</select>';break;
    case 'conversation_status':
      h+='<select data-pkey="check_value"><option value="">Select...</option>';
      h+='<option value="open"'+(val==='open'?' selected':'')+'>Open</option>';
      h+='<option value="resolved"'+(val==='resolved'?' selected':'')+'>Resolved</option>';
      h+='<option value="pending"'+(val==='pending'?' selected':'')+'>Pending</option>';
      h+='<option value="snoozed"'+(val==='snoozed'?' selected':'')+'>Snoozed</option>';
      h+='</select>';break;
    case 'conversation_priority':
      h+='<select data-pkey="check_value"><option value="">Select...</option>';
      h+='<option value="0"'+(val==='0'?' selected':'')+'>Low</option>';
      h+='<option value="1"'+(val==='1'?' selected':'')+'>Medium</option>';
      h+='<option value="2"'+(val==='2'?' selected':'')+'>High</option>';
      h+='<option value="3"'+(val==='3'?' selected':'')+'>Urgent</option>';
      h+='</select>';break;
    case 'has_label':
      h+='<select data-pkey="check_value"><option value="">Select label...</option>';
      for(var j=0;j<labels.length;j++){h+='<option value="'+escHtml(labels[j].title)+'"'+(val===labels[j].title?' selected':'')+'>'+escHtml(labels[j].title)+'</option>'}
      h+='</select>';break;
    case 'custom_attribute':
      h+='<div class="cond-sub"><label>Attribute</label><select data-pkey="attr_key"><option value="">select an attribute...</option>';
      if(typeof customAttrs!=='undefined'){
        var contactAttrs=customAttrs.filter(function(a){return a.model===0||a.model==='contact_attribute'});
        var convAttrs=customAttrs.filter(function(a){return a.model===1||a.model==='conversation_attribute'});
        if(contactAttrs.length){h+='<optgroup label="Contact">';for(var j=0;j<contactAttrs.length;j++){h+='<option value="'+escHtml(contactAttrs[j].key)+'"'+(attrKey===contactAttrs[j].key?' selected':'')+'>'+escHtml(contactAttrs[j].name)+'</option>'}h+='</optgroup>'}
        if(convAttrs.length){h+='<optgroup label="Conversation">';for(var j=0;j<convAttrs.length;j++){h+='<option value="'+escHtml(convAttrs[j].key)+'"'+(attrKey===convAttrs[j].key?' selected':'')+'>'+escHtml(convAttrs[j].name)+'</option>'}h+='</optgroup>'}
      }
      h+='</select></div>';
      h+='<div class="cond-sub"><label>Value</label><input type="text" data-pkey="check_value" value="'+escHtml(val)+'" placeholder="..."></div>';
      break;
    case 'contact_field':
      h+='<div class="cond-sub"><label>Field</label><select data-pkey="attr_key"><option value="">Select field...</option>';
      if(typeof contactFields!=='undefined'){for(var j=0;j<contactFields.length;j++){h+='<option value="'+escHtml(contactFields[j].key)+'"'+(attrKey===contactFields[j].key?' selected':'')+'>'+escHtml(contactFields[j].label)+'</option>'}}
      h+='</select></div>';
      h+='<div class="cond-sub"><label>Value</label><input type="text" data-pkey="check_value" value="'+escHtml(val)+'" placeholder="..."></div>';
      break;
    default:
      h+='<input type="text" data-pkey="check_value" value="'+escHtml(val)+'" placeholder="...">';
  }
  return h;
}

function hideNodeProps(){
  document.getElementById('props-panel').classList.remove('active');
  document.getElementById('props-panel').innerHTML='';
  document.getElementById('tips-panel').classList.remove('hidden');
}
function deselectAll(){
  selectedNodeId=null;
  var sels=document.querySelectorAll('.drawflow-node.selected');
  for(var i=0;i<sels.length;i++)sels[i].classList.remove('selected');
  hideNodeProps();
  selectedNodeType=null;clearNodeSelection();
}
function escHtml(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;')}

// ===== CONTEXT MENU =====
var ctxMenu=document.getElementById('ctx-menu');
var ctxNodeId=null;
var clipboard=null;
var ctxPastePos=null;

dfEl.addEventListener('contextmenu',function(e){
  e.preventDefault();
  var nEl=e.target.closest('.drawflow-node');
  ctxPastePos=null;
  if(!nEl){
    // Canvas right-click: show paste-only menu if clipboard has content
    if(!clipboard){hideCtxMenu();return}
    ctxNodeId=null;
    ctxMenu.querySelectorAll('[data-act="duplicate"],[data-act="copy"]').forEach(function(el){el.style.display='none'});
    ctxMenu.querySelector('.ctx-del').style.display='none';
    ctxMenu.querySelector('.ctx-sep').style.display='none';
    ctxPastePos={x:e.clientX,y:e.clientY};
  } else {
    // Node right-click: show full menu
    var m=nEl.id.match(/node-(\d+)/);
    ctxNodeId=m?m[1]:null;
    ctxMenu.querySelectorAll('.ctx-item,.ctx-sep').forEach(function(el){el.style.display=''});
  }
  // Toggle paste disabled state
  var pasteItem=ctxMenu.querySelector('[data-act="paste"]');
  if(pasteItem)pasteItem.classList.toggle('ctx-disabled',!clipboard);
  ctxMenu.style.left=e.clientX+'px';
  ctxMenu.style.top=e.clientY+'px';
  ctxMenu.classList.add('open');
  // Adjust if off-screen
  var r=ctxMenu.getBoundingClientRect();
  if(r.right>window.innerWidth)ctxMenu.style.left=(e.clientX-r.width)+'px';
  if(r.bottom>window.innerHeight)ctxMenu.style.top=(e.clientY-r.height)+'px';
});

ctxMenu.addEventListener('click',function(e){
  var item=e.target.closest('[data-act]');
  if(!item)return;
  var act=item.getAttribute('data-act');
  if(act==='duplicate'&&ctxNodeId)duplicateNode(ctxNodeId);
  if(act==='copy'&&ctxNodeId){
    var nd=editor.getNodeFromId(ctxNodeId);
    if(nd)clipboard={name:nd.name,data:JSON.parse(JSON.stringify(nd.data)),pos_x:nd.pos_x,pos_y:nd.pos_y};
    toast('Copied','ok');
  }
  if(act==='paste'&&clipboard){
    var c=NC[clipboard.name];if(c){
      var px,py;
      if(ctxPastePos){
        var rect=editor.precanvas.getBoundingClientRect();
        px=(ctxPastePos.x-rect.x)/editor.zoom;
        py=(ctxPastePos.y-rect.y)/editor.zoom;
      } else {
        var pOff2=Math.round(60/editor.zoom);
        px=clipboard.pos_x+pOff2;py=clipboard.pos_y+pOff2;
      }
      editor.addNode(clipboard.name,c.i,c.o,px,py,clipboard.name,JSON.parse(JSON.stringify(clipboard.data)),nHtml(clipboard.name));
      setTimeout(popSelects,150);markDirty();pushUndo();
    }
  }
  if(act==='delete'&&ctxNodeId){deselectConn();editor.removeNodeId('node-'+ctxNodeId);selectedNodeId=null;hideNodeProps();markDirty()}
  hideCtxMenu();
});

document.addEventListener('click',function(e){
  if(!ctxMenu.contains(e.target))hideCtxMenu();
});
function hideCtxMenu(){ctxMenu.classList.remove('open');ctxNodeId=null}

// ===== DROP ZONE FEEDBACK =====
var canvasEl=document.querySelector('.canvas');
canvasEl.addEventListener('dragenter',function(e){if(dragNodeType)canvasEl.classList.add('drop-hover')});
canvasEl.addEventListener('dragleave',function(e){
  if(!canvasEl.contains(e.relatedTarget))canvasEl.classList.remove('drop-hover');
});
canvasEl.addEventListener('drop',function(){canvasEl.classList.remove('drop-hover')});

// ===== AUTO-ALIGN =====
function collapseAllNodes(){
  var nodes=document.querySelectorAll('.drawflow-node');
  for(var i=0;i<nodes.length;i++){
    var nb=nodes[i].querySelector('.nb-collapsible');
    var toggle=nodes[i].querySelector('.nh-toggle');
    if(nb&&nb.classList.contains('nb-open')){
      nb.classList.remove('nb-open');
      if(toggle)toggle.classList.remove('open');
      var m=nodes[i].id.match(/node-(\d+)/);
      if(m)updateNodeSummary(m[1]);
    }
  }
}
// === Smart auto-reposition on connection (ManyChat-style) ===
function smartReposition(info){
  // Drawflow connectionCreated: {output_id:NUM, input_id:NUM, output_class:STR, input_class:STR}
  if(!info||!info.output_id||!info.input_id)return;
  var srcId=String(info.output_id);
  var tgtId=String(info.input_id);
  var srcEl=document.getElementById('node-'+srcId);
  var tgtEl=document.getElementById('node-'+tgtId);
  if(!srcEl||!tgtEl)return;
  var d=editor.export().drawflow.Home.data;
  var srcN=d[srcId];var tgtN=d[tgtId];
  if(!srcN||!tgtN)return;
  var srcW=srcEl.offsetWidth;var tgtW=tgtEl.offsetWidth;
  var srcH=srcEl.offsetHeight;var tgtH=tgtEl.offsetHeight;
  // Only reposition if target is to the LEFT of source or overlapping
  var needsMove=tgtN.pos_x < srcN.pos_x+srcW+80;
  // Also check if target was just created (close to default/drop position)
  var tgtAge=Date.now()-(tgtEl._createdAt||0);
  if(!needsMove && tgtAge>2000) return; // already positioned manually, don't touch
  // Calculate ideal position: to the right of source, vertically centered
  var idealX=srcN.pos_x+srcW+200;
  var idealY=srcN.pos_y;
  // Find which output port this connection uses
  var outClass=info.output_class||'output_1';
  var outIdx=parseInt(outClass.replace('output_',''))||1;
  var totalOuts=Object.keys(srcN.outputs||{}).length;
  if(totalOuts>1){
    // Spread branches vertically: center output → same Y, top → up, bottom → down
    var spread=80;
    var mid=(totalOuts+1)/2;
    idealY=srcN.pos_y + (outIdx-mid)*spread;
  }
  // Check for overlap with existing nodes
  for(var nid in d){
    if(nid===tgtId)continue;
    var nx=d[nid].pos_x;var ny=d[nid].pos_y;
    var ne=document.getElementById('node-'+nid);
    if(!ne)continue;
    var nw=ne.offsetWidth;var nh=ne.offsetHeight;
    // If overlapping, nudge down
    if(idealX<nx+nw+20 && idealX+tgtW+20>nx && idealY<ny+nh+20 && idealY+tgtH+20>ny){
      idealY=ny+nh+40;
    }
  }
  // Apply position
  editor.drawflow.drawflow.Home.data[tgtId].pos_x=idealX;
  editor.drawflow.drawflow.Home.data[tgtId].pos_y=Math.max(20,idealY);
  tgtEl.style.left=idealX+'px';
  tgtEl.style.top=Math.max(20,idealY)+'px';
  // Update connections
  editor.updateConnectionNodes('node-'+srcId);
  editor.updateConnectionNodes('node-'+tgtId);
}

function autoAlign(){
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);if(!keys.length)return;
  // Collapse all nodes first for consistent sizing
  collapseAllNodes();
  setTimeout(function(){_doAutoAlign()},300);
}
function _doAutoAlign(){
  // === ManyChat-style auto layout ===
  var data=editor.export();
  var d=data.drawflow.Home.data;
  var keys=Object.keys(d);if(!keys.length)return;

  // Build undirected adjacency for component detection
  var adj={};
  for(var i=0;i<keys.length;i++)adj[keys[i]]=[];
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];
    for(var o in n.outputs){
      var cs=(n.outputs[o].connections||[]);
      for(var c=0;c<cs.length;c++){
        adj[keys[i]].push(cs[c].node);
        if(adj[cs[c].node])adj[cs[c].node].push(keys[i]);
      }
    }
  }

  // BFS to find connected components
  var visited={};var components=[];
  for(var i=0;i<keys.length;i++){
    if(visited[keys[i]])continue;
    var comp=[];var q=[keys[i]];visited[keys[i]]=true;
    while(q.length){
      var cur=q.shift();comp.push(cur);
      for(var j=0;j<(adj[cur]||[]).length;j++){
        var nb=adj[cur][j];
        if(!visited[nb]){visited[nb]=true;q.push(nb)}
      }
    }
    components.push(comp);
  }

  // Sort: trigger-containing components first, then larger first
  components.sort(function(a,b){
    var at=a.some(function(id){return d[id].name==='trigger'});
    var bt=b.some(function(id){return d[id].name==='trigger'});
    if(at!==bt)return at?-1:1;
    return b.length-a.length;
  });

  // Separate multi-node trees from single orphans
  var trees=[];var orphans=[];
  for(var i=0;i<components.length;i++){
    if(components[i].length===1)orphans.push(components[i][0]);
    else trees.push(components[i]);
  }

  // Layout each tree with dagre
  function layoutTree(comp){
    var g=new dagre.graphlib.Graph();
    g.setGraph({rankdir:'LR',nodesep:60,ranksep:200,marginx:0,marginy:0,ranker:'network-simplex'});
    g.setDefaultEdgeLabel(function(){return{}});
    for(var ni=0;ni<comp.length;ni++){
      var el=document.getElementById('node-'+comp[ni]);
      g.setNode(comp[ni],{width:el?el.offsetWidth:220,height:el?el.offsetHeight:100});
    }
    for(var ni=0;ni<comp.length;ni++){
      var n=d[comp[ni]];
      for(var o in n.outputs){
        var cs=(n.outputs[o].connections||[]);
        for(var c=0;c<cs.length;c++){g.setEdge(comp[ni],cs[c].node)}
      }
    }
    dagre.layout(g);
    var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
    var nodes=[];
    g.nodes().forEach(function(nid){
      var dn=g.node(nid);
      var lx=dn.x-dn.width/2;var ly=dn.y-dn.height/2;
      nodes.push({id:nid,x:lx,y:ly,w:dn.width,h:dn.height});
      minX=Math.min(minX,lx);minY=Math.min(minY,ly);
      maxX=Math.max(maxX,lx+dn.width);maxY=Math.max(maxY,ly+dn.height);
    });
    for(var ni=0;ni<nodes.length;ni++){nodes[ni].x-=minX;nodes[ni].y-=minY}
    return{nodes:nodes,width:maxX-minX,height:maxY-minY};
  }

  var treeLayouts=[];
  for(var ti=0;ti<trees.length;ti++)treeLayouts.push(layoutTree(trees[ti]));

  // Place trees stacked vertically (LR layout: each tree flows left→right)
  var TREE_GAP=120;
  var ORPHAN_GAP=50;
  var startX=100;var startY=80;
  var curY=startY;var maxTreeW=0;

  for(var ti=0;ti<treeLayouts.length;ti++){
    var lay=treeLayouts[ti];
    for(var ni=0;ni<lay.nodes.length;ni++){
      var nd=lay.nodes[ni];
      var x=Math.round(startX+nd.x);var y=Math.round(curY+nd.y);
      editor.drawflow.drawflow.Home.data[nd.id].pos_x=x;
      editor.drawflow.drawflow.Home.data[nd.id].pos_y=y;
      var el=document.getElementById('node-'+nd.id);
      if(el){el.style.left=x+'px';el.style.top=y+'px'}
    }
    maxTreeW=Math.max(maxTreeW,lay.width);
    curY+=lay.height+TREE_GAP;
  }

  // Place orphans in a column below the trees
  if(orphans.length){
    var orphY=curY+(treeLayouts.length?40:0);
    var orphX=startX;
    var maxRowH=0;var cols=Math.min(orphans.length,3);
    for(var oi=0;oi<orphans.length;oi++){
      var nid=orphans[oi];
      var el=document.getElementById('node-'+nid);
      var w=el?el.offsetWidth:220;var h=el?el.offsetHeight:100;
      editor.drawflow.drawflow.Home.data[nid].pos_x=orphX;
      editor.drawflow.drawflow.Home.data[nid].pos_y=orphY;
      if(el){el.style.left=orphX+'px';el.style.top=orphY+'px'}
      maxRowH=Math.max(maxRowH,h);
      orphX+=w+ORPHAN_GAP;
      if((oi+1)%cols===0){orphX=startX;orphY+=maxRowH+ORPHAN_GAP;maxRowH=0}
    }
  }

  // Update all connections
  var allNodes=document.querySelectorAll('.drawflow-node');
  for(var ni=0;ni<allNodes.length;ni++){editor.updateConnectionNodes(allNodes[ni].id)}
  pushUndo();fitToScreen();
  markDirty();
  toast('Nodes aligned','ok');
}

// ===== FLOW VALIDATION =====
function validateFlow(){
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);
  var issues=[];
  // Clear previous highlights
  var prev=document.querySelectorAll('.node-error');
  for(var p=0;p<prev.length;p++)prev[p].classList.remove('node-error');

  if(!keys.length){issues.push({msg:'No nodes \u2014 drag a trigger from the palette',id:null});showIssues(issues);return}
  // Check for trigger
  var hasTrigger=false;
  for(var i=0;i<keys.length;i++){if(d[keys[i]].name==='trigger')hasTrigger=true}
  if(!hasTrigger)issues.push({msg:'Missing trigger \u2014 drag "Incoming Message" from the palette',id:null});
  // Check each node
  var hasIncoming={};
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];
    for(var o in n.outputs){(n.outputs[o].connections||[]).forEach(function(c){hasIncoming[c.node]=true})}
  }
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];var nid=keys[i];
    // Orphan check (not trigger/note, no incoming)
    if(n.name!=='trigger'&&n.name!=='note'&&!hasIncoming[nid]){
      issues.push({msg:nodeName(n.name)+' #'+nid+' disconnected \u2014 connect to a previous node',id:nid});
    }
    // Empty required fields
    if(n.name==='message'&&!n.data.message){issues.push({msg:'Empty message #'+nid+' \u2014 add text',id:nid})}
    if(n.name==='trigger'&&n.data.trigger_type==='keyword'&&!n.data.keyword){issues.push({msg:'Empty keyword #'+nid+' \u2014 enter a trigger keyword',id:nid})}
    if(n.name==='menu'&&!n.data.opt1){issues.push({msg:'Menu #'+nid+' no options \u2014 add at least one',id:nid})}
    if(n.name==='webhook'&&!n.data.url){issues.push({msg:'Webhook #'+nid+' no URL \u2014 enter a URL',id:nid})}
    if(n.name==='set_priority'&&!n.data.priority&&n.data.priority!=='0'){issues.push({msg:'Priority #'+nid+' not selected \u2014 select a level',id:nid})}
    if(n.name==='set_status'&&!n.data.status){issues.push({msg:'Status #'+nid+' not selected \u2014 select a value',id:nid})}
    if(n.name==='transfer_inbox'&&!n.data.inbox_id){issues.push({msg:'Transfer #'+nid+' no inbox \u2014 select a target',id:nid})}
    if(n.name==='buttons'&&!n.data.btn1){issues.push({msg:'Buttons #'+nid+' \u2014 add a first button',id:nid})}
    if(n.name==='image'&&!n.data.image_url){issues.push({msg:'Image #'+nid+' no URL \u2014 add a link',id:nid})}
    if(n.name==='video'&&!n.data.video_url){issues.push({msg:'Video #'+nid+' no URL \u2014 add a link',id:nid})}
    if(n.name==='assign'&&!n.data.agent_id&&!n.data.team_id){issues.push({msg:'Assign #'+nid+' \u2014 select an agent or team',id:nid})}
    if(n.name==='set_attribute'&&!n.data.attr_key){issues.push({msg:'Attribute #'+nid+' no name \u2014 select an attribute',id:nid})}
    // No outputs connected (except close/note)
    if(n.name!=='close'&&n.name!=='note'){
      var totalConn=0;
      for(var o in n.outputs){totalConn+=(n.outputs[o].connections||[]).length}
      if(totalConn===0&&n.name!=='trigger'){issues.push({msg:nodeName(n.name)+' #'+nid+' no connection \u2014 connect to a target',id:nid})}
    }
  }
  showIssues(issues);
  if(!issues.length)toast('Flow is valid!','ok');
}

function nodeName(t){
  var m={trigger:'Trigger',message:'Message',image:'Image',video:'Video',buttons:'Buttons',menu:'Menu',condition:'Condition',delay:'Delay',assign:'Assign',add_label:'Label+',remove_label:'Label-',set_attribute:'Attribute',close:'Close',webhook:'Webhook',note:'Note',set_priority:'Priority',set_status:'Status',transfer_inbox:'Transfer'};
  return m[t]||t;
}

function showIssues(issues){
  var vp=document.getElementById('valid-panel');
  var vl=document.getElementById('valid-list');
  if(!issues.length){vp.style.display='none';return}
  vp.style.display='block';
  openCfg();
  vl.innerHTML='';
  for(var i=0;i<issues.length;i++){
    (function(issue){
      var el=document.createElement('div');
      el.className='valid-item';
      el.innerHTML='<i class="ti ti-alert-triangle" style="font-size:12px"></i> '+issue.msg;
      if(issue.id){
        // Highlight the node
        var ne=document.getElementById('node-'+issue.id);
        if(ne)ne.classList.add('node-error');
        el.addEventListener('click',function(){
          // Center viewport on node
          var ne2=document.getElementById('node-'+issue.id);
          if(ne2){
            ne2.classList.add('selected');
            var nd=editor.getNodeFromId(issue.id);
            if(nd){
              var dRect=document.getElementById('drawflow').getBoundingClientRect();
              editor.canvas_x=dRect.width/2-nd.pos_x*editor.zoom;
              editor.canvas_y=dRect.height/2-nd.pos_y*editor.zoom;
              editor.precanvas.style.transform='translate('+editor.canvas_x+'px,'+editor.canvas_y+'px) scale('+editor.zoom+')';
              if(typeof updateMinimap==='function')updateMinimap();
            }
          }
        });
      }
      vl.appendChild(el);
    })(issues[i]);
  }
}

// markSaved is called directly in the save handler above

// ===== COLLAPSIBLE PALETTE TOGGLE =====
var sideNodes=document.getElementById('side-nodes');
var nodesToggle=document.getElementById('nodes-toggle');
// Restore saved state
if(localStorage.getItem('bb-palette-expanded')==='true')sideNodes.classList.add('expanded');
nodesToggle.addEventListener('click',function(){
  sideNodes.classList.toggle('expanded');
  localStorage.setItem('bb-palette-expanded',sideNodes.classList.contains('expanded'));
});

// ===== SIDE-CFG OVERLAY =====
var sideCfg=document.getElementById('side-cfg');
var sideCfgClose=document.getElementById('side-cfg-close');
function openCfg(){sideCfg.classList.add('open');try{localStorage.setItem('bb-cfg-open','1')}catch(ex){}}
function closeCfg(){sideCfg.classList.remove('open');try{localStorage.removeItem('bb-cfg-open')}catch(ex){}}
sideCfgClose.addEventListener('click',closeCfg);
// Click outside to close
document.addEventListener('click',function(e){
  if(!sideCfg.classList.contains('open'))return;
  if(sideCfg.contains(e.target))return;
  if(e.target.closest&&e.target.closest('.drawflow-node'))return;
  if(e.target.closest&&e.target.closest('.tbtn'))return;
  closeCfg();
});
// Track selection + auto-expand on select, auto-collapse on deselect
editor.on('nodeSelected',function(id){
  selectedNodeId=id;
  // Collapse any other open node first
  var nodes=document.querySelectorAll('.drawflow-node');
  for(var i=0;i<nodes.length;i++){
    var nid=nodes[i].id;
    if(nid==='node-'+id)continue;
    var nb2=nodes[i].querySelector('.nb-collapsible');
    var tog2=nodes[i].querySelector('.nh-toggle');
    if(nb2&&nb2.classList.contains('nb-open')){
      nb2.classList.remove('nb-open');
      if(tog2)tog2.classList.remove('open');
      var mid=nodes[i].id.match(/node-(\d+)/);
      if(mid)updateNodeSummary(mid[1]);
      editor.updateConnectionNodes(nid);
    }
  }
  // Expand selected node
  var el=document.getElementById('node-'+id);
  if(el){
    var nb=el.querySelector('.nb-collapsible');
    var toggle=el.querySelector('.nh-toggle');
    if(nb&&!nb.classList.contains('nb-open')){
      nb.classList.add('nb-open');
      if(toggle)toggle.classList.add('open');
      var iv4=setInterval(function(){editor.updateConnectionNodes(el.id)},30);
      var done4=false;
      var finish4=function(){if(done4)return;done4=true;clearInterval(iv4);editor.updateConnectionNodes(el.id)};
      nb.addEventListener('transitionend',function h4(e){if(e.propertyName==='max-height'){nb.removeEventListener('transitionend',h4);finish4()}});
      setTimeout(finish4,320);
    }
  }
});
editor.on('nodeUnselected',function(){
  selectedNodeId=null;
  // Collapse all open nodes when clicking empty canvas
  var nodes=document.querySelectorAll('.drawflow-node');
  for(var i=0;i<nodes.length;i++){
    var nb=nodes[i].querySelector('.nb-collapsible');
    var toggle=nodes[i].querySelector('.nh-toggle');
    if(nb&&nb.classList.contains('nb-open')){
      nb.classList.remove('nb-open');
      if(toggle)toggle.classList.remove('open');
      var mid=nodes[i].id.match(/node-(\d+)/);
      if(mid)updateNodeSummary(mid[1]);
      var nid=nodes[i].id;
      var iv5=setInterval(function(){editor.updateConnectionNodes(nid)},30);
      setTimeout(function(){clearInterval(iv5)},320);
    }
  }
});
// Double-click to open properties panel
dfEl.addEventListener('dblclick',function(e){
  var nEl=e.target.closest('.drawflow-node');
  if(!nEl)return;
  var m=nEl.id.match(/node-(\d+)/);
  if(m){openCfg();showNodeProps(m[1])}
});

// ===== CONNECTION CLICK-SELECT + DELETE =====
var selectedConn=null;
function deselectConn(){
  if(selectedConn){selectedConn.classList.remove('conn-selected');selectedConn=null}
}
// Connection selection via click (use setTimeout to avoid interfering with Drawflow drag)
dfEl.addEventListener('click',function(e){
  // Only handle direct clicks on main-path SVG elements
  if(e.target.tagName==='path'&&e.target.classList.contains('main-path')){
    var prev=dfEl.querySelector('.main-path.conn-selected');
    if(prev&&prev!==e.target)prev.classList.remove('conn-selected');
    if(selectedConn===e.target){deselectConn();return}
    e.target.classList.add('conn-selected');
    selectedConn=e.target;
    return;
  }
  // Click on empty canvas = deselect connection
  if(selectedConn&&!e.target.closest('.drawflow-node')&&e.target.tagName!=='path'){deselectConn()}
});

// ===== SNAP TO GRID =====
var snapEnabled=true;
var GRID=24;
function toggleSnap(){
  snapEnabled=!snapEnabled;
  var el=document.getElementById('snap-toggle');
  el.classList.toggle('active',snapEnabled);
  var sb=document.getElementById('sb-snap');if(sb)sb.textContent='Snap: '+(snapEnabled?'On':'Off');
}
// Single merged nodeMoved handler: snap → dirty → undo → minimap
editor.on('nodeMoved',function(id){
  // 1. Snap to grid (must happen FIRST so undo captures snapped position)
  if(snapEnabled){
    var nd=editor.drawflow.drawflow.Home.data[id];
    if(nd){
      var sx=Math.round(nd.pos_x/GRID)*GRID;
      var sy=Math.round(nd.pos_y/GRID)*GRID;
      if(sx!==nd.pos_x||sy!==nd.pos_y){
        nd.pos_x=sx;nd.pos_y=sy;
        var el=document.getElementById('node-'+id);
        if(el){el.style.left=sx+'px';el.style.top=sy+'px';editor.updateConnectionNodes('node-'+id)}
      }
    }
  }
  // 2. Track changes + undo (AFTER snap)
  markDirty();pushUndo();
  // 3. Minimap (debounced)
  queueMM();
});

// ===== MINIMAP =====
var mmCanvas=document.getElementById('minimap-canvas');
var mmCtx=mmCanvas?mmCanvas.getContext('2d'):null;
var mmColors={trigger:'#ff6b35',message:'#6366F1',image:'#2ecc71',video:'#6c5ce7',buttons:'#00b894',menu:'#9b59b6',condition:'#f1c40f',delay:'#8e44ad',assign:'#27ae60',add_label:'#00b894',remove_label:'#00b894',set_attribute:'#e67e22',close:'#e74c3c',webhook:'#3498db',note:'#95a5a6',set_priority:'#f1c40f',set_status:'#6366F1',transfer_inbox:'#9b59b6'};
function updateMinimap(){
  if(!mmCtx)return;
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);
  mmCtx.clearRect(0,0,mmCanvas.width,mmCanvas.height);
  if(!keys.length)return;
  var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
  keys.forEach(function(k){var n=d[k];if(n.pos_x<minX)minX=n.pos_x;if(n.pos_y<minY)minY=n.pos_y;if(n.pos_x+260>maxX)maxX=n.pos_x+260;if(n.pos_y+120>maxY)maxY=n.pos_y+120});
  var pad=60,rX=(maxX-minX)+pad*2,rY=(maxY-minY)+pad*2;
  var sc=Math.min(mmCanvas.width/rX,mmCanvas.height/rY);
  // Connections
  mmCtx.strokeStyle='rgba(99,102,241,.25)';mmCtx.lineWidth=1;
  keys.forEach(function(k){var n=d[k];for(var o in n.outputs){(n.outputs[o].connections||[]).forEach(function(c){var t=d[c.node];if(!t)return;mmCtx.beginPath();mmCtx.moveTo((n.pos_x+130-minX+pad)*sc,(n.pos_y+50-minY+pad)*sc);mmCtx.lineTo((t.pos_x+130-minX+pad)*sc,(t.pos_y+50-minY+pad)*sc);mmCtx.stroke()})}});
  // Nodes
  keys.forEach(function(k){var n=d[k];var x=(n.pos_x-minX+pad)*sc,y=(n.pos_y-minY+pad)*sc,w=Math.max(220*sc,6),h=Math.max(50*sc,3);mmCtx.fillStyle=mmColors[n.name]||'#6366F1';mmCtx.globalAlpha=.6;mmCtx.beginPath();mmCtx.roundRect(x,y,w,h,2);mmCtx.fill();mmCtx.globalAlpha=1});
  // Viewport
  var cRect=document.querySelector('.canvas').getBoundingClientRect();
  var vpL=(-editor.canvas_x/editor.zoom),vpT=(-editor.canvas_y/editor.zoom);
  var vpW=cRect.width/editor.zoom,vpH=cRect.height/editor.zoom;
  mmCtx.strokeStyle='rgba(99,102,241,.6)';mmCtx.lineWidth=1.5;
  mmCtx.strokeRect((vpL-minX+pad)*sc,(vpT-minY+pad)*sc,vpW*sc,vpH*sc);
}
// Update minimap on changes
var mmTimer=null;
function queueMM(){clearTimeout(mmTimer);mmTimer=setTimeout(updateMinimap,100)}
editor.on('nodeCreated',queueMM);editor.on('nodeRemoved',queueMM);
// nodeMoved minimap is handled in merged handler above
editor.on('connectionCreated',queueMM);
editor.on('connectionRemoved',queueMM);
dfEl.addEventListener('wheel',queueMM);
// Click minimap to pan
if(mmCanvas){
  mmCanvas.addEventListener('click',function(e){
    var d=editor.export().drawflow.Home.data;var keys=Object.keys(d);if(!keys.length)return;
    var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
    keys.forEach(function(k){var n=d[k];if(n.pos_x<minX)minX=n.pos_x;if(n.pos_y<minY)minY=n.pos_y;if(n.pos_x+260>maxX)maxX=n.pos_x+260;if(n.pos_y+120>maxY)maxY=n.pos_y+120});
    var pad=60,rX=(maxX-minX)+pad*2,rY=(maxY-minY)+pad*2;
    var sc=Math.min(mmCanvas.width/rX,mmCanvas.height/rY);
    var rect=mmCanvas.getBoundingClientRect();
    var mx=(e.clientX-rect.left)*(mmCanvas.width/rect.width);
    var my=(e.clientY-rect.top)*(mmCanvas.height/rect.height);
    var flowX=mx/sc+minX-pad;var flowY=my/sc+minY-pad;
    var cRect=document.querySelector('.canvas').getBoundingClientRect();
    editor.canvas_x=-(flowX*editor.zoom-cRect.width/2);
    editor.canvas_y=-(flowY*editor.zoom-cRect.height/2);
    editor.precanvas.style.transform='translate('+editor.canvas_x+'px,'+editor.canvas_y+'px) scale('+editor.zoom+')';
    queueMM();
  });
}

// ===== INIT =====
loadMeta().then(function(){
  if(BOT_ID)return loadBot(BOT_ID);
}).then(function(){
  var cl=document.getElementById('canvas-loading');if(cl)cl.classList.add('done');
  updUndoState();
  try{if(localStorage.getItem('bb-cfg-open'))openCfg()}catch(ex){}
});
setTimeout(queueMM,800);
</script>
</body></html>
    ENDHTML
    html.gsub('__BOT_ID__', bid_js).gsub('__LOCALE__', "\"#{locale}\"")
  end
end

# Register
Rails.application.config.middleware.insert_after Warden::Manager, BotBuilderMiddleware

# === EXECUTION ENGINE ===
Rails.application.config.after_initialize do
  Rails.logger.info('[BotBuilder] Initializing...')
  BotFlowStore.storage_dir

  Message.class_eval do
    after_commit :_bb_exec, on: :create, if: -> {
      incoming? && !content_attributes&.dig('bot_response') && !content_attributes&.dig('campaign_id')
    }
    private
    def _bb_exec
      BotEngine.process_async(id)
    rescue => e
      Rails.logger.error("[BotEngine] queue: #{e.message}")
    end
  end

  module BotEngine
    class ProcessJob < ApplicationJob
      queue_as :default

      def perform(mid)
        msg = Message.find_by(id: mid); return unless msg
        conv = msg.conversation; return unless conv
        st = conv.custom_attributes&.dig('bot_state')
        if st && (st['waiting_for'] == 'menu_choice' || st['waiting_for'] == 'button_choice')
          choice_resp(msg, conv, st); return
        end
        BotFlowStore.active_for_inbox(conv.inbox_id, conv.account_id).each do |bot|
          fd = bot.dig('flow','drawflow','Home','data'); next unless fd
          fd.each do |_,n|
            next unless n['name']=='trigger'
            if trig?(n['data'], msg)
              run(n, fd, conv, bot); return
            end
          end
        end
      rescue => e
        Rails.logger.error("[BotEngine] #{e.message}\n#{e.backtrace&.first(3)&.join("\n")}")
      end

      private

      def trig?(d, m)
        case d['trigger_type']
        when 'any' then true
        when 'first' then m.conversation.messages.where(message_type: :incoming).count <= 1
        when 'keyword'
          k=d['keyword'].to_s.strip.downcase; k.present? && m.content.to_s.downcase.include?(k)
        else false end
      end

      def run(node, fd, conv, bot, out='output_1')
        (node.dig('outputs',out,'connections')||[]).each do |c|
          nx=fd[c['node']]; exec_node(nx,fd,conv,bot) if nx
        end
      end

      def exec_node(n, fd, conv, bot)
        case n['name']
        when 'message'
          txt(conv, n['data']['message']); run(n,fd,conv,bot)
        when 'image'
          img(conv, n['data']['image_url'], n['data']['caption']); run(n,fd,conv,bot)
        when 'video'
          vid(conv, n['data']['video_url'], n['data']['caption']); run(n,fd,conv,bot)
        when 'buttons'
          btns(conv, n, fd, bot)
        when 'menu'
          menu(conv,n,fd,bot)
        when 'condition'
          lm=conv.messages.where(message_type: :incoming).order(created_at: :desc).first
          ok=cond?(n['data'], lm&.content.to_s, conv)
          run(n,fd,conv,bot, ok ? 'output_1':'output_2')
        when 'delay'
          s=(n['data']['seconds']||5).to_i.clamp(1,3600)
          (n.dig('outputs','output_1','connections')||[]).each{|c|
            BotEngine::DelayJob.set(wait:s.seconds).perform_later(conv.id,bot['id'],c['node'])
          }
        when 'assign'
          d=n['data']
          conv.update!(assignee:User.find_by(id:d['agent_id'])) if d['agent_id'].present?
          conv.update!(team:Team.find_by(id:d['team_id'])) if d['team_id'].present?
          run(n,fd,conv,bot)
        when 'add_label'
          l=n['data']['label_name'].to_s.strip
          if l.present?; cur=conv.label_list||[]; conv.update!(label_list:cur+[l]) unless cur.include?(l); end
          run(n,fd,conv,bot)
        when 'remove_label'
          l=n['data']['label_name'].to_s.strip
          if l.present?; cur=conv.label_list||[]; conv.update!(label_list:cur-[l]) if cur.include?(l); end
          run(n,fd,conv,bot)
        when 'set_attribute'
          k=n['data']['attr_key'].to_s.strip; v=n['data']['attr_value'].to_s
          if k.present?; c=conv.contact; a=c.custom_attributes||{}; a[k]=v; c.update!(custom_attributes:a); end
          run(n,fd,conv,bot)
        when 'close'
          conv.update!(status: :resolved)
        when 'webhook'
          u=n['data']['url'].to_s.strip
          if u.present? && u.match?(/\Ahttps?:\/\//i)
            pl={conversation_id:conv.id,contact_name:conv.contact&.name,contact_phone:conv.contact&.phone_number,inbox_id:conv.inbox_id,last_message:conv.messages.where(message_type: :incoming).last&.content}
            begin
              hdrs={'Content-Type'=>'application/json'}
              ch=n['data']['headers'].to_s.strip
              if ch.present?; begin; hdrs.merge!(JSON.parse(ch)); rescue; end; end
              if (n['data']['method']||'POST').upcase=='GET'
                HTTParty.get(u,query:pl,headers:hdrs,timeout:15)
              else
                HTTParty.post(u,body:pl.to_json,headers:hdrs,timeout:15)
              end
            rescue => e; Rails.logger.error("[BotEngine] webhook: #{e.message}"); end
          end
          run(n,fd,conv,bot)
        when 'note'
          t=n['data']['text'].to_s.strip
          conv.messages.create!(message_type: :activity, content:"[Bot] #{t}", account_id:conv.account_id, inbox_id:conv.inbox_id, content_attributes:{'bot_response'=>true}) if t.present?
        when 'set_priority'
          p=n['data']['priority'].to_s.strip
          conv.update!(priority: p.to_i) if p.present? && %w[0 1 2 3].include?(p)
          run(n,fd,conv,bot)
        when 'set_status'
          s=n['data']['status'].to_s.strip
          if s.present? && %w[open resolved pending].include?(s)
            conv.update!(status: s.to_sym)
          end
          run(n,fd,conv,bot)
        when 'transfer_inbox'
          ib_id=n['data']['inbox_id'].to_s.strip
          if ib_id.present?
            ib=Inbox.find_by(id:ib_id, account_id:conv.account_id)
            conv.update!(inbox_id:ib.id) if ib
          end
          run(n,fd,conv,bot)
        end
      end

      def txt(conv, t)
        return if t.to_s.strip.empty?
        conv.messages.create!(message_type: :outgoing, content:interp(t,conv), account_id:conv.account_id, inbox_id:conv.inbox_id, content_attributes:{'bot_response'=>true})
      end

      def interp(t, conv)
        return t unless t.is_a?(String) && t.include?('{{')
        t.gsub(/\{\{([\w.]+)\}\}/) do |match|
          parts = $1.split('.', 2)
          case parts[0]
          when 'contact'
            c = conv.contact
            next match unless c
            case parts[1]
            when 'name' then c.name.to_s
            when 'phone' then c.phone_number.to_s
            when 'email' then c.email.to_s
            when 'id' then c.id.to_s
            else c.custom_attributes&.dig(parts[1]).to_s
            end
          when 'conversation'
            case parts[1]
            when 'id' then conv.display_id.to_s
            when 'status' then conv.status.to_s
            when 'priority' then conv.priority.to_s
            else match
            end
          when 'inbox'
            case parts[1]
            when 'name' then conv.inbox&.name.to_s
            else match
            end
          else match
          end
        end
      rescue => e
        Rails.logger.warn("[BotEngine] interp error: #{e.message}")
        t
      end

      def img(conv, url, cap)
        return if url.to_s.strip.empty?
        m=conv.messages.create!(message_type: :outgoing, content:interp(cap.to_s,conv), account_id:conv.account_id, inbox_id:conv.inbox_id, content_attributes:{'bot_response'=>true})
        begin
          f=Down.download(url, max_size:10*1024*1024)
          m.attachments.new(account_id:conv.account_id, file_type: :image, file:{io:f, filename:File.basename(url), content_type:f.content_type})
          m.save!
        rescue => e; Rails.logger.error("[BotEngine] img: #{e.message}"); end
      end

      def vid(conv, url, cap)
        return if url.to_s.strip.empty?
        m=conv.messages.create!(message_type: :outgoing, content:interp(cap.to_s,conv), account_id:conv.account_id, inbox_id:conv.inbox_id, content_attributes:{'bot_response'=>true})
        begin
          f=Down.download(url, max_size:40*1024*1024)
          m.attachments.new(account_id:conv.account_id, file_type: :video, file:{io:f, filename:File.basename(url), content_type:f.content_type})
          m.save!
        rescue => e; Rails.logger.error("[BotEngine] vid: #{e.message}"); end
      end

      def btns(conv, node, fd, bot)
        d=node['data']
        btns_list=(1..3).map{|i|d["btn#{i}"]}.reject{|b|b.to_s.strip.empty?}
        return if btns_list.empty?
        body_text=interp(d['body'].to_s.strip, conv)
        # Build text fallback with button labels
        t=body_text.dup; t+="\n\n" unless t.empty?
        btns_list.each_with_index{|b,i|t+="#{i+1}. #{b}\n"}
        txt(conv, t)
        nid=fd.find{|_,v|v.object_id==node.object_id}&.first
        nid||=fd.find{|_,v|v['name']=='buttons'&&v['data']['body']==d['body']}&.first
        conv.update!(custom_attributes:(conv.custom_attributes||{}).merge('bot_state'=>{'bot_id'=>bot['id'],'node_id'=>nid.to_s,'waiting_for'=>'button_choice','options_count'=>btns_list.length,'button_labels'=>btns_list}))
      end

      def menu(conv, node, fd, bot)
        d=node['data']
        opts=(1..6).map{|i|d["opt#{i}"]}.reject{|o|o.to_s.strip.empty?}
        return if opts.empty?
        t=interp(d['title'].to_s.strip, conv); t+="\n\n" unless t.empty?
        opts.each_with_index{|o,i|t+="#{i+1}. #{o}\n"}
        txt(conv, t)
        nid=fd.find{|_,v|v.object_id==node.object_id}&.first
        nid||=fd.find{|_,v|v['name']=='menu'&&v['data']['title']==d['title']}&.first
        conv.update!(custom_attributes:(conv.custom_attributes||{}).merge('bot_state'=>{'bot_id'=>bot['id'],'node_id'=>nid.to_s,'waiting_for'=>'menu_choice','options_count'=>opts.length}))
      end

      def choice_resp(msg, conv, st)
        bot=BotFlowStore.find(st['bot_id']); return clr(conv) unless bot
        fd=bot.dig('flow','drawflow','Home','data'); return clr(conv) unless fd
        node=fd[st['node_id']]; return clr(conv) unless node
        content=msg.content.to_s.strip
        cnt=st['options_count']||6
        # Try matching by number
        num=content.match(/^(\d+)/)&.captures&.first&.to_i
        # For buttons: also try matching by button label text
        if st['waiting_for']=='button_choice' && st['button_labels'].is_a?(Array)
          label_idx=st['button_labels'].index{|l|content.downcase==l.to_s.downcase}
          num=label_idx+1 if label_idx
        end
        if num&&num>=1&&num<=cnt
          clr(conv); run(node,fd,conv,bot,"output_#{num}")
        else
          txt(conv,"Sorry, please choose from the available options.")
        end
      end

      def clr(conv)
        a=conv.custom_attributes||{}; a.delete('bot_state'); conv.update!(custom_attributes:a)
      end

      def cond?(d, content, conv)
        v=d['check_value'].to_s.strip; return false if v.empty?
        case d['check_type']
        when 'contains' then content.downcase.include?(v.downcase)
        when 'equals' then content.strip.downcase==v.downcase
        when 'regex' then (begin; content.match?(Regexp.new(v, Regexp::IGNORECASE)); rescue RegexpError; Rails.logger.warn("[BotEngine] Invalid regex: #{v}"); false; end)
        when 'label_exists' then (conv.label_list||[]).include?(v)
        when 'contact_type'
          ct = conv.contact&.contact_type.to_s
          ct == v
        when 'conversation_status'
          conv.status.to_s == v
        when 'conversation_priority'
          conv.priority.to_s == v
        when 'has_label'
          (conv.label_list||[]).include?(v)
        when 'custom_attribute'
          ak=d['attr_key'].to_s.strip
          ak.present? && conv.contact&.custom_attributes&.dig(ak).to_s == v
        when 'contact_field'
          fk=d['attr_key'].to_s.strip
          return false unless fk.present? && conv.contact
          conv.contact.try(fk).to_s.downcase.include?(v.downcase)
        else false end
      rescue; false
      end
    end

    class DelayJob < ApplicationJob
      queue_as :default
      def perform(cid,bid,nid)
        conv=Conversation.find_by(id:cid); return unless conv
        bot=BotFlowStore.find(bid); return unless bot
        fd=bot.dig('flow','drawflow','Home','data'); return unless fd&&fd[nid]
        ProcessJob.new.send(:exec_node, fd[nid], fd, conv, bot)
      rescue => e; Rails.logger.error("[BotEngine] delay: #{e.message}"); end
    end

    def self.process_async(mid); ProcessJob.perform_later(mid); end
  end

  Rails.logger.info('[BotBuilder] Ready.')
end
