# Custom initializer: Campaign Report Dashboard
# Dark mode design, consistent with Bot Builder
# Created: 2026-02-18 | Updated: 2026-02-20
# Access: /campaign-report (requires Chatwoot login session)

class CampaignReportMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.path == "/campaign-report"
      return handle_campaign_list(request)
    elsif request.path =~ %r{^/campaign-report/(\d+)$}
      return handle_campaign_detail(request, $1.to_i)
    else
      return @app.call(env)
    end
  end

  private

  def authenticate(request)
    env = request.env
    warden = env["warden"]
    if warden
      user = warden.user
      return user if user.is_a?(User)
    end
    token = request.get_header("HTTP_API_ACCESS_TOKEN")
    if token.present?
      access_token = AccessToken.find_by(token: token)
      if access_token && access_token.owner.is_a?(User)
        return access_token.owner
      end
    end
    nil
  end

  def handle_campaign_list(request)
    user = authenticate(request)
    return unauthorized_response unless user

    account_ids = user.account_users.pluck(:account_id)
    campaigns = Campaign.where(account_id: account_ids).order(created_at: :desc).limit(50)

    rows = campaigns.map do |c|
      messages = campaign_messages(c.id)
      total = messages.count
      delivered = messages.where(status: :delivered).count + messages.where(status: :read).count
      read_count = messages.where(status: :read).count
      failed = messages.where(status: :failed).count
      audience_size = campaign_audience_size(c)

      {
        campaign: c,
        total_sent: total,
        delivered: delivered,
        read: read_count,
        failed: failed,
        audience_size: audience_size
      }
    end

    locale = begin; user.account_users.first&.account&.locale; rescue; nil end || 'en'
    html = render_list_page(rows, locale)
    [200, hdrs, [html]]
  rescue StandardError => e
    Rails.logger.error "[CampaignReport] Error: #{e.message}"
    [500, {"content-type"=>"text/html; charset=utf-8"}, ["<h1>#{h(e.message)}</h1>"]]
  end

  def handle_campaign_detail(request, campaign_id)
    user = authenticate(request)
    return unauthorized_response unless user

    account_ids = user.account_users.pluck(:account_id)
    campaign = Campaign.where(account_id: account_ids).find_by(id: campaign_id)
    campaign ||= Campaign.where(account_id: account_ids).find_by(display_id: campaign_id)

    return not_found_response unless campaign

    messages = campaign_messages(campaign.id)

    contact_results = messages.includes(conversation: :contact).map do |m|
      contact = m.conversation&.contact
      {
        contact_name: contact&.name || "Unknown",
        phone: contact&.phone_number || "-",
        status: m.status,
        conversation_id: m.conversation_id,
        created_at: m.created_at
      }
    end

    audience_contacts = campaign_audience_contacts(campaign)
    sent_phones = contact_results.map { |r| r[:phone] }.compact
    not_sent = audience_contacts.reject { |c| sent_phones.include?(c[:phone]) }

    locale = begin; user.account_users.first&.account&.locale; rescue; nil end || 'en'
    html = render_detail_page(campaign, contact_results, not_sent, locale)
    [200, hdrs, [html]]
  rescue StandardError => e
    Rails.logger.error "[CampaignReport] Error: #{e.message}"
    [500, {"content-type"=>"text/html; charset=utf-8"}, ["<h1>#{h(e.message)}</h1>"]]
  end

  def hdrs
    {"content-type"=>"text/html; charset=utf-8","cache-control"=>"no-store, no-cache, must-revalidate, private","x-frame-options"=>"DENY","x-content-type-options"=>"nosniff"}
  end

  def campaign_messages(campaign_id)
    Message.where("content_attributes::text LIKE ?", "%campaign_id%")
           .where("content_attributes::text LIKE ?", "%#{campaign_id}%")
  end

  def campaign_audience_size(campaign)
    return 0 if campaign.audience.blank?
    count = 0
    campaign.audience.each do |segment|
      if segment["type"] == "Label"
        label = Label.find_by(id: segment["id"])
        count += campaign.account.contacts.tagged_with(label.title).count if label
      end
    end
    count
  end

  def campaign_audience_contacts(campaign)
    contacts = []
    return contacts if campaign.audience.blank?
    campaign.audience.each do |segment|
      if segment["type"] == "Label"
        label = Label.find_by(id: segment["id"])
        if label
          campaign.account.contacts.tagged_with(label.title).each do |c|
            contacts << { name: c.name, phone: c.phone_number, id: c.id }
          end
        end
      end
    end
    contacts
  end

  def h(text); CGI.escapeHTML(text.to_s); end

  def status_text_he(status)
    case status.to_s
    when "sent" then "Sent"
    when "delivered" then "Delivered"
    when "read" then "Read"
    when "failed" then "Failed"
    else status.to_s end
  end

  def format_time(time)
    return "-" unless time
    time.in_time_zone("UTC").strftime("%d/%m/%Y %H:%M")
  end

  def campaign_status_he(status)
    case status.to_s
    when "completed" then "Completed"
    when "active" then "Active"
    when "scheduled" then "Scheduled"
    else status.to_s end
  end

  def campaign_status_color(status)
    case status.to_s
    when "completed" then "#2ecc71"
    when "active" then "#6366F1"
    when "scheduled" then "#f0ad4e"
    else "#777B84" end
  end

  def unauthorized_response
    [302, {"location"=>"/auth/sign_in","content-type"=>"text/html; charset=utf-8"}, ["Redirecting..."]]
  end

  def not_found_response
    [404, {"content-type"=>"text/html; charset=utf-8"}, ["<!DOCTYPE html><html dir='ltr' lang='en'><head><meta charset='utf-8'>#{dark_styles}</head><body>#{theme_detect_script}<div class='app-shell'>#{nav_html('report')}<div class='app-main' style='display:flex;justify-content:center;align-items:center'><div style='background:var(--bg-card);border:1px solid var(--border-weak);padding:3rem;border-radius:14px;text-align:center'><h2 style='color:var(--text-1);font-weight:600;letter-spacing:-.02em'>Campaign Not Found</h2><p style='color:#696E77;margin-top:8px'>Please verify the campaign ID is correct</p><a href='/campaign-report' style='display:inline-flex;align-items:center;gap:6px;margin-top:16px;padding:8px 20px;border-radius:8px;background:var(--accent-bg);border:1px solid var(--accent-border);color:#6366F1;font-size:13px;text-decoration:none'><i class='ti ti-arrow-right' style='font-size:14px'></i> Go Back</a></div></div></div></body></html>"]]
  end

  def nav_html(active)
    '<nav class="app-nav">' \
    "<a href='/bot-builder'#{active=='bot' ? " class='active'" : ''} title='Bot Builder'><i class='ti ti-robot'></i></a>" \
    "<a href='/campaign-report'#{active=='report' ? " class='active'" : ''} title='Campaign Report'><i class='ti ti-chart-bar'></i></a>" \
    '<div class="nav-sp"></div>' \
    "<a href='/app' title='Chatwoot'><i class='ti ti-layout-dashboard'></i></a>" \
    '</nav>'
  end

  def theme_detect_script
    '<script>(function(){var s=null;try{var k=Object.keys(localStorage);for(var i=0;i<k.length;i++){if(k[i].indexOf("COLOR_SCHEME")!==-1){s=localStorage.getItem(k[i]);break}}}catch(e){}if(s==="dark"||(s!=="light"&&window.matchMedia("(prefers-color-scheme:dark)").matches))document.body.classList.add("dark")})()</script>'
  end

  def dark_styles
    <<~STYLE
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
      <link href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@3/dist/tabler-icons.min.css" rel="stylesheet" onerror="this.onerror=null;this.href=this.href.replace('cdn.jsdelivr.net/npm','unpkg.com')">
      <style>
        :root{
          --bg-app:#F4F5F8;--bg-card:#FFFFFF;--bg-surface:#FAFBFC;--border-weak:#E8E9ED;--border-strong:#D4D6DC;
          --text-1:#1C2024;--text-2:#60646C;--text-3:#80838D;--text-4:#8B8D98;
          --accent:#6366F1;--accent-light:#818CF8;--accent-bg:rgba(99,102,241,.06);--accent-border:rgba(99,102,241,.15);
          --card-shadow:0 1px 2px rgba(0,0,0,.04),0 2px 4px rgba(0,0,0,.03),0 4px 8px rgba(0,0,0,.02);
          --card-hover-shadow:0 2px 4px rgba(0,0,0,.05),0 4px 8px rgba(0,0,0,.04),0 8px 16px rgba(0,0,0,.04),0 16px 32px rgba(0,0,0,.03);
          --glass-bg:rgba(255,255,255,.6);--glass-border:rgba(255,255,255,.8);
          --nav-bg:#FEFEFE;--nav-border:#E8E9ED;--nav-text:#80838D;
          --table-bg:#FFFFFF;--table-border:#E8E9ED;--table-hover:rgba(99,102,241,.03);
          --bar-bg:#E8E9ED;--input-bg:#FFFFFF;--input-border:#E8E9ED;
          --glow-accent:rgba(99,102,241,.08);
        }
        body.dark{
          --bg-app:#0F1014;--bg-card:#16171F;--bg-surface:#1C1E28;--border-weak:#1E1F2E;--border-strong:#2A2B3D;
          --text-1:#EDEEF0;--text-2:#B0B4BA;--text-3:#777B84;--text-4:#555770;
          --accent:#818CF8;--accent-light:#A5B4FC;--accent-bg:rgba(99,102,241,.08);--accent-border:rgba(99,102,241,.2);
          --card-shadow:0 1px 2px rgba(0,0,0,.2),0 2px 4px rgba(0,0,0,.15),0 4px 8px rgba(0,0,0,.1),inset 0 1px 0 rgba(255,255,255,.03);
          --card-hover-shadow:0 2px 4px rgba(0,0,0,.2),0 4px 8px rgba(0,0,0,.15),0 8px 16px rgba(0,0,0,.12),0 16px 32px rgba(0,0,0,.1),inset 0 1px 0 rgba(255,255,255,.05);
          --glass-bg:rgba(22,23,31,.7);--glass-border:rgba(255,255,255,.06);
          --nav-bg:#0C0D14;--nav-border:rgba(255,255,255,.04);--nav-text:#555770;
          --table-bg:#16171F;--table-border:#1E1F2E;--table-hover:rgba(99,102,241,.04);
          --bar-bg:#1E1F2E;--input-bg:#1C1E28;--input-border:rgba(255,255,255,.06);
          --glow-accent:rgba(99,102,241,.12);
        }
        *{box-sizing:border-box;margin:0;padding:0}
        ::-webkit-scrollbar{width:5px;height:5px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:var(--border-strong);border-radius:3px}::-webkit-scrollbar-thumb:hover{background:var(--text-3)}
        body{font-family:'Inter',-apple-system,system-ui,sans-serif;background:var(--bg-app);color:var(--text-1);line-height:1.65;margin:0;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}

        /* App shell */
        .app-shell{display:flex;min-height:100vh}
        .app-nav{width:56px;background:var(--nav-bg);border-right:1px solid var(--nav-border);display:flex;flex-direction:column;align-items:center;padding:12px 0;gap:4px;flex-shrink:0;position:sticky;top:0;height:100vh}
        .app-nav a{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;color:var(--nav-text);text-decoration:none;transition:background .15s,color .15s,box-shadow .2s;font-size:0;position:relative}
        .app-nav a:hover{background:rgba(99,102,241,.04);color:var(--text-1)}
        .app-nav a.active{color:var(--accent);background:var(--accent-bg);box-shadow:0 0 12px var(--glow-accent)}
        .app-nav a.active::before{content:'';position:absolute;left:-1px;top:6px;bottom:6px;width:3px;border-radius:0 3px 3px 0;background:linear-gradient(180deg,#6366F1,#818CF8)}
        .app-nav .nav-sp{flex:1}
        .app-nav .ti{font-size:20px}

        /* Layout */
        .app-main{flex:1;overflow-y:auto;min-width:0}
        .container{max-width:1200px;margin:0 auto;padding:32px 48px}

        /* Page header */
        .page-hdr{display:flex;justify-content:space-between;align-items:flex-start;gap:16px;margin-bottom:28px}
        .page-hdr h1{font-size:22px;font-weight:700;letter-spacing:-.03em;color:var(--text-1)}
        .page-hdr .subtitle{color:var(--text-3);font-size:13px;margin-top:4px;letter-spacing:-.01em}
        .page-hdr .refresh-btn{background:var(--glass-bg);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid var(--glass-border);border-radius:10px;padding:8px 16px;color:var(--text-2);font-family:inherit;font-size:13px;font-weight:500;cursor:pointer;transition:background .15s,color .15s,border-color .15s,box-shadow .2s;text-decoration:none;display:inline-flex;align-items:center;gap:6px;height:38px}
        .page-hdr .refresh-btn:hover{background:var(--accent-bg);color:var(--accent);border-color:var(--accent-border);box-shadow:0 0 12px var(--glow-accent);text-decoration:none}

        /* Search */
        .search-wrap{margin-bottom:20px;position:relative}
        .search-wrap input{width:100%;max-width:360px;background:var(--input-bg);border:none;outline:1px solid var(--input-border);border-radius:10px;padding:9px 14px;padding-right:36px;color:var(--text-1);font-family:inherit;font-size:13px;direction:ltr;transition:outline-color .15s ease,box-shadow .2s ease}
        .search-wrap input:focus{outline-color:var(--accent);box-shadow:0 0 0 3px var(--glow-accent)}
        .search-wrap input:hover{outline-color:var(--border-strong)}
        .search-wrap input::placeholder{color:var(--text-4)}

        /* === STAT CARDS - Premium glass === */
        .stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:28px}
        .stat-card{background:var(--bg-card);border:1px solid var(--border-weak);border-radius:16px;padding:20px 22px;position:relative;overflow:hidden;transition:border-color .2s,box-shadow .3s,transform .2s;box-shadow:var(--card-shadow)}
        .stat-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:16px 16px 0 0;background:var(--stat-accent,var(--accent));opacity:.6;transition:opacity .2s}
        .stat-card:hover{border-color:var(--border-strong);box-shadow:var(--card-hover-shadow);transform:translateY(-2px)}
        .stat-card:hover::before{opacity:1}
        .stat-icon{width:36px;height:36px;border-radius:10px;display:flex;align-items:center;justify-content:center;margin-bottom:12px;font-size:17px;transition:box-shadow .2s}
        .stat-card:hover .stat-icon{box-shadow:0 0 12px var(--stat-glow,rgba(99,102,241,.2))}
        .stat-number{font-size:30px;font-weight:700;line-height:1;font-variant-numeric:tabular-nums;letter-spacing:-.03em;transition:color .2s}
        .stat-label{font-size:10px;color:var(--text-4);margin-top:8px;font-weight:600;text-transform:uppercase;letter-spacing:.6px}
        .stat-pct{font-size:12px;color:var(--accent);margin-top:4px;font-weight:600;letter-spacing:-.01em}
        .stat-bar{height:3px;background:var(--bar-bg);border-radius:2px;margin-top:10px;overflow:hidden}
        .stat-bar-fill{height:100%;border-radius:2px;transition:width 1s cubic-bezier(.4,0,.2,1)}

        /* === SECTION TITLES === */
        .section-title{font-size:10px;font-weight:700;margin-bottom:12px;color:var(--text-4);text-transform:uppercase;letter-spacing:.8px;display:flex;align-items:center;gap:8px}
        .section-title::after{content:'';flex:1;height:1px;background:linear-gradient(90deg,var(--border-weak),transparent)}

        /* === TABLE - Premium === */
        .table-wrapper{background:var(--table-bg);border:1px solid var(--border-weak);border-radius:16px;overflow:hidden;margin-bottom:28px;box-shadow:var(--card-shadow);transition:box-shadow .3s}
        .table-scroll{max-height:600px;overflow-y:auto}
        table{width:100%;border-collapse:collapse;border-spacing:0;font-size:13px}
        thead{position:sticky;top:0;z-index:2;background:var(--table-bg)}
        th{padding:14px 16px;text-align:left;font-weight:600;font-size:11px;color:var(--text-4);border-bottom:1px solid var(--border-weak);cursor:pointer;user-select:none;transition:color .15s;white-space:nowrap;text-transform:uppercase;letter-spacing:.5px}
        th:hover{color:var(--text-1)}
        th .sort-arr{font-size:8px;margin-left:3px;opacity:.4}
        th.sorted{color:var(--accent)}
        th.sorted .sort-arr{opacity:1}
        td{padding:14px 16px;border-bottom:1px solid var(--border-weak);font-size:13px;font-variant-numeric:tabular-nums}
        tbody tr{transition:background .15s,transform .15s}
        tbody tr:hover{background:var(--table-hover)}
        tbody tr:last-child td{border-bottom:none}
        tbody tr.clickable{cursor:pointer}
        tbody tr.clickable:active{transform:scale(.998)}

        /* Status badge */
        .campaign-status{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;letter-spacing:-.01em}
        .campaign-status::before{content:'';width:6px;height:6px;border-radius:50%;background:currentColor;opacity:.6}
        .cs-completed{background:rgba(46,204,113,.1);color:#2ecc71}
        .cs-active{background:var(--accent-bg);color:var(--accent)}
        .cs-scheduled{background:rgba(240,173,78,.1);color:#f0ad4e}

        /* Links */
        a{color:var(--accent);text-decoration:none;font-weight:500}
        a:hover{text-decoration:underline;text-underline-offset:3px}

        /* Info card */
        .info-card{background:var(--bg-card);border:1px solid var(--border-weak);border-radius:16px;padding:24px;box-shadow:var(--card-shadow)}
        .info-card h3{font-size:10px;font-weight:700;margin-bottom:14px;color:var(--text-4);text-transform:uppercase;letter-spacing:.8px;display:flex;align-items:center;gap:8px}
        .info-card h3::after{content:'';flex:1;height:1px;background:linear-gradient(90deg,var(--border-weak),transparent)}
        .info-row{display:flex;gap:8px;margin-bottom:8px;color:var(--text-3);font-size:13px;align-items:baseline}
        .info-row strong{color:var(--text-2);min-width:80px;font-weight:600;font-size:12px}

        /* Empty state */
        .empty-state{text-align:center;padding:60px 20px;color:var(--text-4)}
        .empty-state .ti{font-size:32px;margin-bottom:8px;opacity:.3}
        .empty-state p{font-size:13px;margin-top:6px}

        /* Export button */
        .export-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:10px;background:var(--glass-bg);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid var(--glass-border);color:var(--accent);font-family:inherit;font-size:13px;font-weight:500;cursor:pointer;transition:background .15s,border-color .15s,box-shadow .2s;text-decoration:none}
        .export-btn:hover{background:var(--accent-bg);border-color:var(--accent-border);box-shadow:0 0 16px var(--glow-accent);text-decoration:none}
        .export-btn:active{transform:scale(.97)}
        .export-btn .ti{font-size:15px}
        .hdr-actions{display:flex;gap:8px;align-items:center}

        /* === FUNNEL - Gradient bars === */
        .funnel{margin-bottom:28px}
        .funnel-bar-wrap{background:var(--bg-card);border:1px solid var(--border-weak);border-radius:12px;overflow:hidden;height:32px;display:flex;box-shadow:var(--card-shadow)}
        .funnel-seg{height:100%;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:600;color:white;transition:width 1s cubic-bezier(.4,0,.2,1);min-width:0;overflow:hidden;letter-spacing:-.01em}
        .funnel-seg span{white-space:nowrap;padding:0 8px}
        .funnel-labels{display:flex;gap:16px;margin-top:10px;font-size:11px;color:var(--text-4);padding:0 2px}
        .funnel-label{display:flex;align-items:center;gap:5px;font-weight:500}
        .funnel-label .dot{width:8px;height:8px;border-radius:3px;flex-shrink:0}

        /* Attention box */
        .attention-box{background:rgba(229,70,102,.04);border:1px solid rgba(229,70,102,.12);border-radius:14px;padding:14px 20px;margin-bottom:24px;display:flex;align-items:center;gap:12px}
        .attention-box .att-icon{width:34px;height:34px;border-radius:10px;background:rgba(229,70,102,.1);color:#FCA5A5;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:16px}
        .attention-box .att-text{flex:1;font-size:13px;color:var(--text-2)}
        .attention-box .att-text strong{color:#FCA5A5;font-weight:600}

        /* === DOWNLOAD CARD === */
        .download-card{background:var(--bg-card);border:1px solid var(--border-weak);border-radius:16px;padding:32px;text-align:center;margin-bottom:28px;box-shadow:var(--card-shadow);transition:border-color .2s,box-shadow .3s,transform .2s;position:relative;overflow:hidden}
        .download-card::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse at 50% -20%,var(--glow-accent),transparent 70%);pointer-events:none}
        .download-card:hover{border-color:var(--accent-border);box-shadow:var(--card-hover-shadow);transform:translateY(-1px)}
        .download-card .dl-icon{width:52px;height:52px;border-radius:14px;background:var(--accent-bg);border:1px solid var(--accent-border);color:var(--accent);display:inline-flex;align-items:center;justify-content:center;font-size:24px;margin-bottom:14px;position:relative;transition:box-shadow .2s}
        .download-card:hover .dl-icon{box-shadow:0 0 20px var(--glow-accent)}
        .download-card h3{font-size:15px;font-weight:700;letter-spacing:-.02em;color:var(--text-1);margin-bottom:4px;position:relative}
        .download-card p{font-size:13px;color:var(--text-4);margin-bottom:18px;position:relative}
        .download-card .dl-btn{display:inline-flex;align-items:center;gap:8px;padding:10px 28px;border-radius:10px;background:linear-gradient(135deg,#6366F1 0%,#4F46E5 100%);border:none;color:#fff;font-family:inherit;font-size:14px;font-weight:600;cursor:pointer;transition:box-shadow .2s,transform .15s;box-shadow:0 2px 8px rgba(99,102,241,.3),0 0 0 1px rgba(99,102,241,.1);position:relative;letter-spacing:-.01em}
        .download-card .dl-btn:hover{box-shadow:0 4px 16px rgba(99,102,241,.4),0 0 0 1px rgba(99,102,241,.2);text-decoration:none;color:#fff;transform:translateY(-1px)}
        .download-card .dl-btn:active{transform:scale(.97) translateY(0)}
        .download-card .dl-btn .ti{font-size:17px}

        /* === ANIMATE ON LOAD === */
        @keyframes fadeUp{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
        .stat-card,.table-wrapper,.funnel,.download-card,.info-card,.attention-box{animation:fadeUp .4s ease-out both}
        .stat-card:nth-child(1){animation-delay:.05s}.stat-card:nth-child(2){animation-delay:.1s}.stat-card:nth-child(3){animation-delay:.15s}.stat-card:nth-child(4){animation-delay:.2s}
        .table-wrapper{animation-delay:.25s}.funnel{animation-delay:.2s}.download-card{animation-delay:.3s}

        @media(max-width:768px){.stats-grid{grid-template-columns:repeat(2,1fr);gap:8px}th,td{padding:8px 10px;font-size:11px}.container{padding:16px}.app-nav{width:48px}.app-nav .ti{font-size:18px}.download-card{padding:20px}}
      </style>
    STYLE
  end

  def render_list_page(rows, locale='en')
    total_campaigns = rows.size
    total_sent = rows.sum { |r| r[:total_sent] }
    total_delivered = rows.sum { |r| r[:delivered] }
    total_read = rows.sum { |r| r[:read] }

    campaign_rows = rows.map do |r|
      c = r[:campaign]
      pct_delivered = r[:total_sent] > 0 ? ((r[:delivered].to_f / r[:total_sent]) * 100).round(0) : 0
      pct_read = r[:total_sent] > 0 ? ((r[:read].to_f / r[:total_sent]) * 100).round(0) : 0

      <<~ROW
        <tr class="clickable" onclick="window.location='/campaign-report/#{c.id}'" data-search="#{h(c.title.to_s)} #{campaign_status_he(c.campaign_status)} #{format_time(c.scheduled_at)}" data-sort-0="#{h(c.title.to_s.downcase)}" data-sort-2="#{c.scheduled_at.to_i rescue 0}" data-sort-4="#{r[:total_sent]}" data-sort-5="#{r[:delivered]}" data-sort-6="#{r[:read]}" data-sort-7="#{r[:failed]}">
          <td><strong style="color:var(--text-1)">#{h(c.title)}</strong></td>
          <td><span class="campaign-status cs-#{c.campaign_status}">#{campaign_status_he(c.campaign_status)}</span></td>
          <td style="color:var(--text-3)">#{format_time(c.scheduled_at)}</td>
          <td style="color:var(--text-3)">#{r[:audience_size]}</td>
          <td>#{r[:total_sent]}</td>
          <td>#{r[:delivered]} <small style="color:var(--text-4)">(#{pct_delivered}%)</small></td>
          <td>#{r[:read]} <small style="color:var(--text-4)">(#{pct_read}%)</small></td>
          <td>#{r[:failed] > 0 ? "<span style='color:#ff6b6b;font-weight:600'>#{r[:failed]}</span>" : "<span style='color:#2E2D32'>0</span>"}</td>
        </tr>
      ROW
    end.join

    empty_html = "<tr><td colspan='8'><div class='empty-state'><p>No campaigns found</p></div></td></tr>"

    <<~HTML
      <!DOCTYPE html>
      <html dir="ltr" lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Campaign Report | WhatsApp</title>
        #{dark_styles}
      </head>
      <body>
        #{theme_detect_script}
        <div class="app-shell">
        #{nav_html('report')}
        <div class="app-main">
        <div class="container">
          <div class="page-hdr" style="direction:ltr">
            <div>
              <h1>Campaign Report</h1>
              <div class="subtitle">WhatsApp Campaign Performance Analytics</div>
            </div>
            <a href="/campaign-report" class="refresh-btn"><i class="ti ti-refresh" style="font-size:15px"></i> Refresh</a>
          </div>
          <div class="stats-grid">
            <div class="stat-card" style="--stat-accent:#6366F1;--stat-glow:rgba(99,102,241,.25)">
              <div class="stat-icon" style="background:rgba(99,102,241,.08);color:#6366F1;border:1px solid rgba(99,102,241,.12)"><i class="ti ti-speakerphone"></i></div>
              <div class="stat-number" style="color:var(--accent)">#{total_campaigns}</div>
              <div class="stat-label">Campaigns</div>
            </div>
            <div class="stat-card" style="--stat-accent:#3B82F6;--stat-glow:rgba(59,130,246,.25)">
              <div class="stat-icon" style="background:rgba(59,130,246,.08);color:#60A5FA;border:1px solid rgba(59,130,246,.12)"><i class="ti ti-send"></i></div>
              <div class="stat-number" style="color:#60A5FA">#{total_sent}</div>
              <div class="stat-label">Sent</div>
            </div>
            <div class="stat-card" style="--stat-accent:#14B8A6;--stat-glow:rgba(20,184,166,.25)">
              <div class="stat-icon" style="background:rgba(20,184,166,.08);color:#5EEAD4;border:1px solid rgba(20,184,166,.12)"><i class="ti ti-checks"></i></div>
              <div class="stat-number" style="color:#5EEAD4">#{total_delivered}</div>
              <div class="stat-label">Delivered</div>
              #{total_sent > 0 ? "<div class='stat-bar'><div class='stat-bar-fill' style='width:#{((total_delivered.to_f / total_sent) * 100).round}%;background:linear-gradient(90deg,#14B8A6,#5EEAD4)'></div></div>" : ""}
            </div>
            <div class="stat-card" style="--stat-accent:#8B5CF6;--stat-glow:rgba(139,92,246,.25)">
              <div class="stat-icon" style="background:rgba(139,92,246,.08);color:#C4B5FD;border:1px solid rgba(139,92,246,.12)"><i class="ti ti-eye"></i></div>
              <div class="stat-number" style="color:#C4B5FD">#{total_read}</div>
              <div class="stat-label">Read</div>
              #{total_sent > 0 ? "<div class='stat-bar'><div class='stat-bar-fill' style='width:#{((total_read.to_f / total_sent) * 100).round}%;background:linear-gradient(90deg,#8B5CF6,#C4B5FD)'></div></div>" : ""}
            </div>
          </div>

          <div class="search-wrap">
            <i class="ti ti-search" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);font-size:14px;color:#696E77;pointer-events:none"></i>
            <input type="text" id="campaign-search" placeholder="Search campaigns..." oninput="filterCampaigns(this.value)" style="padding-right:34px">
            <span id="search-count" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-size:11px;color:#696E77"></span>
          </div>

          <div class="section-title">All Campaigns</div>
          <div class="table-wrapper">
            <div class="table-scroll">
              <table id="campaign-table">
                <thead>
                  <tr>
                    <th data-col="0" onclick="sortTable(0,'str')">Campaign Name <span class="sort-arr"></span></th>
                    <th>Status</th>
                    <th data-col="2" onclick="sortTable(2,'num')">Date <span class="sort-arr"></span></th>
                    <th>Audience</th>
                    <th data-col="4" onclick="sortTable(4,'num')">Sent <span class="sort-arr"></span></th>
                    <th data-col="5" onclick="sortTable(5,'num')">Delivered <span class="sort-arr"></span></th>
                    <th data-col="6" onclick="sortTable(6,'num')">Read <span class="sort-arr"></span></th>
                    <th data-col="7" onclick="sortTable(7,'num')">Failed <span class="sort-arr"></span></th>
                  </tr>
                </thead>
                <tbody id="campaign-tbody">
                  #{campaign_rows.empty? ? empty_html : campaign_rows}
                </tbody>
              </table>
            </div>
          </div>
        </div>
        </div>
        </div>

        <script>
        var _locale='#{locale}';
        var _isHe=_locale==='he';
        if(_isHe){document.documentElement.setAttribute('dir','rtl');document.documentElement.setAttribute('lang','he')}
        function filterCampaigns(q){
          q=q.trim().toLowerCase();
          var rows=document.querySelectorAll('#campaign-tbody tr[data-search]');
          var vis=0;
          for(var i=0;i<rows.length;i++){
            var s=(rows[i].getAttribute('data-search')||'').toLowerCase();
            var show=!q||s.indexOf(q)!==-1;
            rows[i].style.display=show?'':'none';
            if(show)vis++;
          }
          var cnt=document.getElementById('search-count');
          if(cnt)cnt.textContent=q?vis+' / '+rows.length:'';
        }
        var sortState={col:null,asc:true};
        function sortTable(col,type){
          var tbody=document.getElementById('campaign-tbody');
          var rows=Array.from(tbody.querySelectorAll('tr[data-search]'));
          if(!rows.length)return;
          if(sortState.col===col){sortState.asc=!sortState.asc}else{sortState.col=col;sortState.asc=true}
          var ths=document.querySelectorAll('#campaign-table thead th');
          for(var i=0;i<ths.length;i++){ths[i].classList.remove('sorted');var a=ths[i].querySelector('.sort-arr');if(a)a.textContent=''}
          var th=document.querySelector('th[data-col="'+col+'"]');
          if(th){th.classList.add('sorted');var a=th.querySelector('.sort-arr');if(a)a.textContent=sortState.asc?'\u25B2':'\u25BC'}
          rows.sort(function(a,b){
            var va=a.getAttribute('data-sort-'+col)||'';
            var vb=b.getAttribute('data-sort-'+col)||'';
            if(type==='num'){va=parseFloat(va)||0;vb=parseFloat(vb)||0}
            if(va<vb)return sortState.asc?-1:1;
            if(va>vb)return sortState.asc?1:-1;
            return 0;
          });
          for(var i=0;i<rows.length;i++){tbody.appendChild(rows[i])}
        }
        (function(){if(!_isHe)return;
          var h1=document.querySelector('.page-hdr h1');if(h1)h1.textContent='\u05D3\u05D5\u05D7 \u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9\u05DD';
          var sub=document.querySelector('.page-hdr .subtitle');if(sub)sub.textContent='\u05E0\u05D9\u05EA\u05D5\u05D7 \u05D1\u05D9\u05E6\u05D5\u05E2\u05D9 \u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9 WhatsApp';
          var rb=document.querySelector('.refresh-btn');if(rb){var ic=rb.querySelector('.ti');rb.textContent=' \u05E8\u05E2\u05E0\u05DF';if(ic)rb.insertBefore(ic,rb.firstChild)}
          var si=document.getElementById('campaign-search');if(si)si.placeholder='\u05D7\u05E4\u05E9 \u05E7\u05DE\u05E4\u05D9\u05D9\u05DF...';
          var st=document.querySelector('.section-title');if(st)st.childNodes[0].textContent='\u05DB\u05DC \u05D4\u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9\u05DD';
          var labels=document.querySelectorAll('.stat-label');
          var lmap={'Campaigns':'\u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9\u05DD','Sent':'\u05E0\u05E9\u05DC\u05D7\u05D5','Delivered':'\u05E0\u05DE\u05E1\u05E8\u05D5','Read':'\u05E0\u05E7\u05E8\u05D0\u05D5'};
          for(var i=0;i<labels.length;i++){var t=labels[i].textContent.trim();if(lmap[t])labels[i].textContent=lmap[t]}
          var ths=document.querySelectorAll('#campaign-table thead th');
          var thmap={'Campaign Name':'\u05E9\u05DD \u05E7\u05DE\u05E4\u05D9\u05D9\u05DF','Status':'\u05E1\u05D8\u05D8\u05D5\u05E1','Date':'\u05EA\u05D0\u05E8\u05D9\u05DA','Audience':'\u05E7\u05D4\u05DC','Sent':'\u05E0\u05E9\u05DC\u05D7\u05D5','Delivered':'\u05E0\u05DE\u05E1\u05E8\u05D5','Read':'\u05E0\u05E7\u05E8\u05D0\u05D5','Failed':'\u05E0\u05DB\u05E9\u05DC\u05D5'};
          for(var i=0;i<ths.length;i++){var arr=ths[i].querySelector('.sort-arr');var txt=ths[i].textContent.trim();if(thmap[txt]){ths[i].textContent='';ths[i].appendChild(document.createTextNode(thmap[txt]+' '));if(arr)ths[i].appendChild(arr)}}
          var ep=document.querySelector('.empty-state p');if(ep)ep.textContent='\u05DC\u05D0 \u05E0\u05DE\u05E6\u05D0\u05D5 \u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9\u05DD';
        })();
        </script>
      </body>
      </html>
    HTML
  end

  def render_detail_page(campaign, contact_results, not_sent, locale='en')
    total = contact_results.size
    delivered = contact_results.count { |r| r[:status].to_s == "delivered" || r[:status].to_s == "read" }
    read_count = contact_results.count { |r| r[:status].to_s == "read" }
    failed = contact_results.count { |r| r[:status].to_s == "failed" }

    pct_delivered = total > 0 ? ((delivered.to_f / total) * 100).round(1) : 0
    pct_read = total > 0 ? ((read_count.to_f / total) * 100).round(1) : 0

    all_count = total + not_sent.size
    bar_read = all_count > 0 ? ((read_count.to_f / all_count) * 100).round(1) : 0
    bar_delivered = all_count > 0 ? ((delivered.to_f / all_count) * 100).round(1) : 0
    bar_failed = all_count > 0 ? ((failed.to_f / all_count) * 100).round(1) : 0
    bar_not_sent = all_count > 0 ? ((not_sent.size.to_f / all_count) * 100).round(1) : 0

    # Build JSON data for CSV export
    export_data = contact_results.map do |r|
      { n: h(r[:contact_name]), p: h(r[:phone]), s: status_text_he(r[:status]), d: format_time(r[:created_at]), c: r[:conversation_id].to_s }
    end
    not_sent.each do |c|
      export_data << { n: h(c[:name]), p: h(c[:phone] || "-"), s: "Not Sent", d: "-", c: "-" }
    end
    export_json = export_data.to_json

    attention_items = []
    attention_items << "#{failed} Failed" if failed > 0
    attention_items << "#{not_sent.size} Not Sent" if not_sent.size > 0

    <<~HTML
      <!DOCTYPE html>
      <html dir="ltr" lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Campaign: #{h(campaign.title)}</title>
        #{dark_styles}
      </head>
      <body>
        #{theme_detect_script}
        <div class="app-shell">
        #{nav_html('report')}
        <div class="app-main">
        <div class="container">
          <div class="page-hdr" style="direction:ltr">
            <div>
              <h1>#{h(campaign.title)}</h1>
              <div class="subtitle">
                ##{campaign.id} &middot;
                <span class="campaign-status cs-#{campaign.campaign_status}">#{campaign_status_he(campaign.campaign_status)}</span>
                &middot; #{format_time(campaign.scheduled_at)}
                &middot; Audience: #{all_count}
              </div>
            </div>
            <div class="hdr-actions">
              <button class="export-btn" onclick="exportCSV()"><i class="ti ti-file-spreadsheet"></i> Export Excel</button>
              <a href="/campaign-report" class="refresh-btn"><i class="ti ti-arrow-right" style="font-size:16px"></i> All Campaigns</a>
            </div>
          </div>

          <div class="stats-grid">
            <div class="stat-card" style="--stat-accent:#3B82F6;--stat-glow:rgba(59,130,246,.25)">
              <div class="stat-icon" style="background:rgba(59,130,246,.08);color:#60A5FA;border:1px solid rgba(59,130,246,.12)"><i class="ti ti-send"></i></div>
              <div class="stat-number" style="color:#60A5FA">#{total}</div>
              <div class="stat-label">Sent</div>
            </div>
            <div class="stat-card" style="--stat-accent:#14B8A6;--stat-glow:rgba(20,184,166,.25)">
              <div class="stat-icon" style="background:rgba(20,184,166,.08);color:#5EEAD4;border:1px solid rgba(20,184,166,.12)"><i class="ti ti-checks"></i></div>
              <div class="stat-number" style="color:#5EEAD4">#{delivered}</div>
              <div class="stat-label">Delivered</div>
              #{total > 0 ? "<div class='stat-pct'>#{pct_delivered}%</div><div class='stat-bar'><div class='stat-bar-fill' style='width:#{pct_delivered}%;background:linear-gradient(90deg,#14B8A6,#5EEAD4)'></div></div>" : ""}
            </div>
            <div class="stat-card" style="--stat-accent:#8B5CF6;--stat-glow:rgba(139,92,246,.25)">
              <div class="stat-icon" style="background:rgba(139,92,246,.08);color:#C4B5FD;border:1px solid rgba(139,92,246,.12)"><i class="ti ti-chevron-down"></i></div>
              <div class="stat-number" style="color:#C4B5FD">#{read_count}</div>
              <div class="stat-label">Read</div>
              #{total > 0 ? "<div class='stat-pct' style='color:#C4B5FD'>#{pct_read}%</div><div class='stat-bar'><div class='stat-bar-fill' style='width:#{pct_read}%;background:linear-gradient(90deg,#8B5CF6,#C4B5FD)'></div></div>" : ""}
            </div>
            <div class="stat-card" style="--stat-accent:#EF4444;--stat-glow:rgba(239,68,68,.25)">
              <div class="stat-icon" style="background:rgba(239,68,68,.08);color:#FCA5A5;border:1px solid rgba(239,68,68,.12)"><i class="ti ti-x"></i></div>
              <div class="stat-number" style="color:#{failed > 0 ? '#FCA5A5' : 'var(--text-4)'}">#{failed}</div>
              <div class="stat-label">Failed</div>
            </div>
          </div>

          <div class="funnel">
            <div class="funnel-bar-wrap">
              #{bar_read > 0 ? "<div class='funnel-seg' style='width:#{bar_read}%;background:#a29bfe'><span>#{read_count} Read</span></div>" : ""}
              #{(bar_delivered - bar_read) > 0 ? "<div class='funnel-seg' style='width:#{bar_delivered - bar_read}%;background:#2ecc71'><span>#{delivered - read_count} Delivered</span></div>" : ""}
              #{bar_failed > 0 ? "<div class='funnel-seg' style='width:#{bar_failed}%;background:#ff6b6b'><span>#{failed} Failed</span></div>" : ""}
              #{bar_not_sent > 0 ? "<div class='funnel-seg' style='width:#{bar_not_sent}%;background:#f0ad4e'><span>#{not_sent.size} Not Sent</span></div>" : ""}
            </div>
            <div class="funnel-labels">
              <div class="funnel-label"><span class="dot" style="background:#a29bfe"></span> Read #{bar_read}%</div>
              <div class="funnel-label"><span class="dot" style="background:#2ecc71"></span> Delivered #{bar_delivered}%</div>
              #{bar_failed > 0 ? "<div class='funnel-label'><span class='dot' style='background:#ff6b6b'></span> Failed #{bar_failed}%</div>" : ""}
              #{bar_not_sent > 0 ? "<div class='funnel-label'><span class='dot' style='background:#f0ad4e'></span> Not Sent #{bar_not_sent}%</div>" : ""}
            </div>
          </div>

          #{attention_items.any? ? "<div class='attention-box'><div class='att-icon'><i class='ti ti-alert-triangle'></i></div><div class='att-text'><strong>Needs Attention:</strong> #{attention_items.join(', ')}</div></div>" : ""}

          <div class="download-card">
            <div class="dl-icon"><i class="ti ti-table-export"></i></div>
            <h3>Download Full Report</h3>
            <p>Includes all contact details, delivery status, dates, and conversation IDs</p>
            <button class="dl-btn" onclick="exportCSV()"><i class="ti ti-download"></i> Download CSV</button>
          </div>

          <div class="info-card">
            <h3>Template Details</h3>
            <div class="info-row"><strong>Template:</strong> #{h(campaign.template_params&.dig('name') || '-')}</div>
            <div class="info-row"><strong>Language:</strong> #{h(campaign.template_params&.dig('language') || '-')}</div>
            <div class="info-row"><strong>Message:</strong> #{h(campaign.message || '-')}</div>
          </div>
        </div>
        </div>
        </div>
        <script>
        var _locale='#{locale}';
        var _isHe=_locale==='he';
        if(_isHe){document.documentElement.setAttribute('dir','rtl');document.documentElement.setAttribute('lang','he')}
        var _exportData=#{export_json};
        function exportCSV(){
          if(!_exportData.length){alert('No data to export');return}
          var csv='\\uFEFF';
          csv+=(_isHe?'\u05E9\u05DD,\u05D8\u05DC\u05E4\u05D5\u05DF,\u05E1\u05D8\u05D8\u05D5\u05E1,\u05EA\u05D0\u05E8\u05D9\u05DA \u05E9\u05DC\u05D9\u05D7\u05D4,\u05DE\u05D6\u05D4\u05D4 \u05E9\u05D9\u05D7\u05D4':'Name,Phone,Status,Send Date,Conversation ID')+'\\n';
          for(var i=0;i<_exportData.length;i++){
            var r=_exportData[i];
            csv+='"'+(r.n||'').replace(/"/g,'""')+'","'+(r.p||'').replace(/"/g,'""')+'","'+(r.s||'').replace(/"/g,'""')+'","'+(r.d||'').replace(/"/g,'""')+'","'+(r.c||'').replace(/"/g,'""')+'"\\n';
          }
          var blob=new Blob([csv],{type:'text/csv;charset=utf-8'});
          var url=URL.createObjectURL(blob);
          var a=document.createElement('a');
          a.href=url;
          a.download='campaign-report-#{campaign.id}.csv';
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        }
        (function(){if(!_isHe)return;
          var labels=document.querySelectorAll('.stat-label');
          var lmap={'Sent':'\u05E0\u05E9\u05DC\u05D7\u05D5','Delivered':'\u05E0\u05DE\u05E1\u05E8\u05D5','Read':'\u05E0\u05E7\u05E8\u05D0\u05D5','Failed':'\u05E0\u05DB\u05E9\u05DC\u05D5'};
          for(var i=0;i<labels.length;i++){var t=labels[i].textContent.trim();if(lmap[t])labels[i].textContent=lmap[t]}
          var dc=document.querySelector('.download-card');
          if(dc){var dh=dc.querySelector('h3');if(dh)dh.textContent='\u05D4\u05D5\u05E8\u05D3\u05EA \u05D3\u05D5\u05D7 \u05DE\u05DC\u05D0';var dp=dc.querySelector('p');if(dp)dp.textContent='\u05DB\u05D5\u05DC\u05DC \u05E4\u05E8\u05D8\u05D9 \u05DB\u05DC \u05D0\u05E0\u05E9\u05D9 \u05D4\u05E7\u05E9\u05E8, \u05E1\u05D8\u05D8\u05D5\u05E1 \u05DE\u05E9\u05DC\u05D5\u05D7, \u05EA\u05D0\u05E8\u05D9\u05DB\u05D9\u05DD \u05D5\u05DE\u05D6\u05D4\u05D9 \u05E9\u05D9\u05D7\u05D4';var db=dc.querySelector('.dl-btn');if(db){var dic=db.querySelector('.ti');db.textContent=' \u05D4\u05D5\u05E8\u05D3 CSV';if(dic)db.insertBefore(dic,db.firstChild)}}
          var allLink=document.querySelector('.hdr-actions .refresh-btn');if(allLink){var aic=allLink.querySelector('.ti');allLink.textContent=' \u05DB\u05DC \u05D4\u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9\u05DD';if(aic)allLink.insertBefore(aic,allLink.firstChild)}
          var expBtn=document.querySelector('.hdr-actions .export-btn');if(expBtn){var eic=expBtn.querySelector('.ti');expBtn.textContent=' \u05D9\u05D9\u05E6\u05D5\u05D0 Excel';if(eic)expBtn.insertBefore(eic,expBtn.firstChild)}
          var fsegs=document.querySelectorAll('.funnel-seg span');
          var fmap={'Read':'\u05E0\u05E7\u05E8\u05D0\u05D5','Delivered':'\u05E0\u05DE\u05E1\u05E8\u05D5','Failed':'\u05E0\u05DB\u05E9\u05DC\u05D5','Not Sent':'\u05DC\u05D0 \u05E0\u05E9\u05DC\u05D7\u05D5'};
          for(var i=0;i<fsegs.length;i++){var ft=fsegs[i].textContent.trim();for(var fk in fmap){if(ft.indexOf(fk)!==-1){fsegs[i].textContent=ft.replace(fk,fmap[fk]);break}}}
          var flbls=document.querySelectorAll('.funnel-label');
          for(var i=0;i<flbls.length;i++){var fn=flbls[i].childNodes;for(var j=0;j<fn.length;j++){if(fn[j].nodeType===3){var fv=fn[j].textContent.trim();for(var fk in fmap){if(fv.indexOf(fk)!==-1){fn[j].textContent=fv.replace(fk,fmap[fk]);break}}}}}
          var ic=document.querySelector('.info-card h3');if(ic)ic.childNodes[0].textContent='\u05E4\u05E8\u05D8\u05D9 \u05EA\u05D1\u05E0\u05D9\u05EA';
          var irows=document.querySelectorAll('.info-row strong');
          var irmap={'Template:':'\u05EA\u05D1\u05E0\u05D9\u05EA:','Language:':'\u05E9\u05E4\u05D4:','Message:':'\u05D4\u05D5\u05D3\u05E2\u05D4:'};
          for(var i=0;i<irows.length;i++){var ir=irows[i].textContent.trim();if(irmap[ir])irows[i].textContent=irmap[ir]}
          var att=document.querySelector('.att-text');if(att){var as=att.querySelector('strong');if(as)as.textContent='\u05D3\u05D5\u05E8\u05E9 \u05EA\u05E9\u05D5\u05DE\u05EA \u05DC\u05D1:'}
          var audSpan=document.querySelector('.subtitle');if(audSpan){var at=audSpan.textContent||'';audSpan.textContent=at.replace('Audience:','\u05E7\u05D4\u05DC:')}
        })();
        </script>
      </body>
      </html>
    HTML
  end
end

# Register middleware AFTER Warden (so session auth works) but BEFORE OmniAuth
Rails.application.config.middleware.insert_after Warden::Manager, CampaignReportMiddleware
Rails.logger.info "[CUSTOM] Campaign Report Dashboard middleware registered at /campaign-report (session auth)"
