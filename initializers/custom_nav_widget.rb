# frozen_string_literal: true

# ============================================================
# Custom Navigation Overlay for Chatwoot
# Hidden ghost edge (12px) on left - hover reveals 220px panel
# Access to: Bot Builder, Campaign Report, Chatwoot Dashboard
# Themed to match Chatwoot dark/light mode (body.dark class)
# Created: 2026-02-18 | Updated: 2026-02-22
# ============================================================

class CustomNavWidgetMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    content_type = headers['Content-Type'] || headers['content-type'] || ''
    return [status, headers, response] unless content_type.include?('text/html')

    path = env['PATH_INFO'] || ''
    # Skip injection for bot-builder and campaign-report (they render their own nav)
    return [status, headers, response] if path.start_with?('/bot-builder') || path.start_with?('/campaign-report')

    parts = []
    response.each { |part| parts << part }
    response.close if response.respond_to?(:close)
    body = parts.join

    if body.include?('</body>')
      body.sub!('</body>', "#{nav_overlay_html}</body>")
      headers['Content-Length'] = body.bytesize.to_s if headers['Content-Length']
    end

    [status, headers, [body]]
  rescue StandardError
    [status, headers, response]
  end

  private

  def nav_overlay_html
    <<~'HTML'
      <style data-custom-nav-style>
      .cw-ghost{position:fixed;left:0;top:0;width:12px;height:100vh;z-index:99997;cursor:pointer}
      .cw-ghost::after{content:'';position:absolute;left:0;top:50%;transform:translateY(-50%);width:2px;height:40px;background:linear-gradient(180deg,transparent,rgba(99,102,241,.3),transparent);border-radius:2px;opacity:0;animation:ghost-hint 3s ease-in-out 2s 2}
      .cw-ghost:hover::after{opacity:.6;animation:none}
      .cw-ghost:focus::before{content:'Navigation';position:absolute;left:16px;top:50%;transform:translateY(-50%);background:var(--bg-card,#fff);border:1px solid rgba(0,0,0,.1);padding:4px 10px;border-radius:6px;font-size:11px;color:#60646C;white-space:nowrap;font-family:Inter,system-ui,sans-serif;box-shadow:0 2px 8px rgba(0,0,0,.1)}
      @keyframes ghost-hint{0%,100%{opacity:0}50%{opacity:1}}
      .cw-panel{position:fixed;left:0;top:0;width:220px;height:100vh;background:#FEFEFE;border-right:1px solid #E8E9ED;z-index:99998;transform:translateX(-220px);transition:transform 280ms cubic-bezier(.4,0,.2,1);display:flex;flex-direction:column;padding:0;font-family:'Inter',-apple-system,system-ui,sans-serif;box-shadow:4px 0 24px rgba(0,0,0,.06),12px 0 40px rgba(0,0,0,.03)}
      .cw-panel:focus-within{transform:translateX(0)}
      .cw-panel.open{transform:translateX(0)}
      .cw-panel-hdr{padding:18px 16px 14px;border-bottom:1px solid #E8E9ED;display:flex;align-items:center;gap:10px}
      .cw-panel-hdr svg{width:20px;height:20px;flex-shrink:0}
      .cw-panel-hdr span{font-size:13px;font-weight:600;color:#60646C;letter-spacing:-.01em}
      .cw-panel-nav{flex:1;padding:8px 0;overflow-y:auto}
      .cw-panel-item{display:flex;align-items:center;gap:12px;padding:10px 16px;color:#60646C;text-decoration:none;font-size:14px;font-weight:500;transition:background .15s,color .15s,border-color .15s;border-left:3px solid transparent;position:relative;outline:none}
      .cw-panel-item:hover,.cw-panel-item:focus-visible{background:rgba(99,102,241,.04);color:#1C2024}
      .cw-panel-item:focus-visible{outline:2px solid #6366F1;outline-offset:-2px;border-radius:4px}
      .cw-panel-item.active{color:#6366F1;background:rgba(99,102,241,.08);border-left-color:transparent;font-weight:600}
      .cw-panel-item.active svg{fill:#6366F1}
      .cw-panel-item.active::before{content:'';position:absolute;left:0;top:8px;bottom:8px;width:3px;border-radius:0 3px 3px 0;background:linear-gradient(180deg,#6366F1,#818CF8)}
      .cw-panel-item svg{width:18px;height:18px;fill:currentColor;flex-shrink:0}
      .cw-panel-sep{height:1px;background:linear-gradient(90deg,transparent,#E8E9ED 20%,#E8E9ED 80%,transparent);margin:6px 16px}
      .cw-panel-foot{padding:12px 16px;border-top:1px solid #E8E9ED;font-size:11px;color:#8B8D98}
      /* RTL overrides */
      .cw-panel[dir="rtl"] .cw-panel-item{border-left:none;border-right:3px solid transparent}
      .cw-panel[dir="rtl"] .cw-panel-item.active{border-right-color:transparent}
      .cw-panel[dir="rtl"] .cw-panel-item.active::before{left:auto;right:0;border-radius:3px 0 0 3px}
      .cw-backdrop{position:fixed;inset:0;background:rgba(0,0,0,0);z-index:99996;pointer-events:none;transition:background 280ms ease}
      .cw-backdrop.active{background:rgba(0,0,0,.08);pointer-events:auto}
      /* Dark mode overrides */
      @media(prefers-reduced-motion:reduce){.cw-panel{transition:none}}
      body.dark .cw-panel{background:#0C0D14;border-right-color:rgba(255,255,255,.04);box-shadow:4px 0 24px rgba(0,0,0,.4),12px 0 48px rgba(0,0,0,.3)}
      body.dark .cw-panel-hdr{border-bottom-color:rgba(255,255,255,.06)}
      body.dark .cw-panel-hdr span{color:#B0B4BA}
      body.dark .cw-panel-item{color:#8B8D9E}
      body.dark .cw-panel-item:hover{background:rgba(99,102,241,.06);color:#EDEEF0}
      body.dark .cw-panel-item.active{color:#818CF8;background:rgba(99,102,241,.08)}
      body.dark .cw-panel-item.active svg{fill:#818CF8}
      body.dark .cw-ghost:focus::before{background:#1A1B25;border-color:rgba(255,255,255,.1);color:#B0B4BA}
      body.dark .cw-panel-sep{background:linear-gradient(90deg,transparent,rgba(255,255,255,.06) 20%,rgba(255,255,255,.06) 80%,transparent)}
      body.dark .cw-panel-foot{border-top-color:rgba(255,255,255,.06);color:#555770}
      </style>
      <div class="cw-ghost" data-custom-nav-ghost tabindex="0" role="button" aria-label="Open navigation" aria-expanded="false"></div>
      <nav class="cw-panel" data-custom-nav-panel role="navigation" aria-label="Chatwoot Tools">
        <div class="cw-panel-hdr">
          <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="none" stroke="#6366F1" stroke-width="1.5" opacity=".3"/><path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.07A7.001 7.001 0 0 1 7.07 19H6a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2z" fill="#6366F1" opacity=".35"/></svg>
          <span>Chatwoot Tools</span>
        </div>
        <div class="cw-panel-nav">
          <a href="/bot-builder" class="cw-panel-item" id="nav-bot">
            <svg viewBox="0 0 24 24"><path d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1.07A7.001 7.001 0 0 1 7.07 19H6a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h1a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2zM9.5 16a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zm5 0a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z"/></svg>
            <span>Bot Builder</span>
          </a>
          <a href="/campaign-report" class="cw-panel-item" id="nav-campaign">
            <svg viewBox="0 0 24 24"><path d="M3 3v18h18V3H3zm4 14H5v-6h2v6zm4 0H9V7h2v10zm4 0h-2v-8h2v8zm4 0h-2V5h2v12z"/></svg>
            <span>Campaign Report</span>
          </a>
          <div class="cw-panel-sep"></div>
          <a href="/app" class="cw-panel-item" id="nav-cw">
            <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
            <span>Chatwoot</span>
          </a>
        </div>
        <div class="cw-panel-foot">העבר עכבר לשמאל לפתיחה</div>
      </nav>
      <div class="cw-backdrop" data-custom-nav-backdrop></div>
      <script data-custom-nav-script>
      (function(){
        var panel=document.querySelector('[data-custom-nav-panel]');
        var ghost=document.querySelector('[data-custom-nav-ghost]');
        var backdrop=document.querySelector('[data-custom-nav-backdrop]');
        var timer=null;
        function openPanel(){clearTimeout(timer);panel.classList.add('open');backdrop.classList.add('active');ghost.setAttribute('aria-expanded','true')}
        function closePanel(){panel.classList.remove('open');backdrop.classList.remove('active');ghost.setAttribute('aria-expanded','false')}
        ghost.addEventListener('mouseenter',openPanel);
        ghost.addEventListener('mouseleave',function(){timer=setTimeout(closePanel,600)});
        panel.addEventListener('mouseenter',function(){clearTimeout(timer)});
        panel.addEventListener('mouseleave',function(){timer=setTimeout(closePanel,500)});
        // Keyboard: Escape to close
        document.addEventListener('keydown',function(e){
          if(e.key==='Escape'&&panel.classList.contains('open')){closePanel();e.preventDefault()}
        });
        // Focus trap
        panel.addEventListener('keydown', function(e) {
          if (e.key !== 'Tab') return;
          var focusable = panel.querySelectorAll('a[href], button, [tabindex]:not([tabindex="-1"])');
          if (focusable.length === 0) return;
          var first = focusable[0];
          var last = focusable[focusable.length - 1];
          if (e.shiftKey) {
            if (document.activeElement === first) { e.preventDefault(); last.focus(); }
          } else {
            if (document.activeElement === last) { e.preventDefault(); first.focus(); }
          }
        });
        // Click outside to close (includes backdrop)
        document.addEventListener('click',function(e){
          if(panel.classList.contains('open')&&!panel.contains(e.target)&&!ghost.contains(e.target)){closePanel()}
        });
        // Ghost click also opens (for touch/accessibility)
        ghost.addEventListener('click',function(){panel.classList.contains('open')?closePanel():openPanel()});
        // Set active state
        var p=window.location.pathname;
        if(p.indexOf('/bot-builder')===0)document.getElementById('nav-bot').classList.add('active');
        else if(p.indexOf('/campaign-report')===0)document.getElementById('nav-campaign').classList.add('active');
        else document.getElementById('nav-cw').classList.add('active');
      })();
      // i18n — multi-method locale detection + reusable applyI18n
      (function(){
        var panel=document.querySelector('[data-custom-nav-panel]');
        var loc='he';
        try{
          var htmlLang=document.documentElement.getAttribute('lang');
          if(htmlLang)loc=htmlLang.substring(0,2);
          if(window.chatwootConfig&&window.chatwootConfig.selectedLocale){
            loc=window.chatwootConfig.selectedLocale.substring(0,2);
          }
          var keys=Object.keys(localStorage);
          for(var i=0;i<keys.length;i++){
            if(keys[i].indexOf('user:locale')!==-1||keys[i].indexOf('LOCALE')!==-1){
              var v=localStorage.getItem(keys[i]);
              if(v&&v.length<=5){loc=v.substring(0,2);break;}
            }
          }
        }catch(e){}
        function applyI18n(locale){
          var isHe=(locale==='he');
          var hdr=panel.querySelector('.cw-panel-hdr span');
          if(hdr)hdr.textContent=isHe?'\u05DB\u05DC\u05D9 Chatwoot':'Chatwoot Tools';
          var items=panel.querySelectorAll('.cw-panel-item span');
          if(items[0])items[0].textContent=isHe?'\u05D1\u05D5\u05E0\u05D4 \u05D1\u05D5\u05D8\u05D9\u05DD':'Bot Builder';
          if(items[1])items[1].textContent=isHe?'\u05D3\u05D5\u05D7 \u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9\u05DD':'Campaign Report';
          if(items[2])items[2].textContent=isHe?'Chatwoot':'Chatwoot';
          var foot=panel.querySelector('.cw-panel-foot');
          if(foot)foot.textContent=isHe?'\u05D4\u05E2\u05D1\u05E8 \u05E2\u05DB\u05D1\u05E8 \u05DC\u05E9\u05DE\u05D0\u05DC \u05DC\u05E4\u05EA\u05D9\u05D7\u05D4':'hover left edge to open';
          panel.setAttribute('dir',isHe?'rtl':'ltr');
          panel.querySelectorAll('.cw-panel-hdr,.cw-panel-item,.cw-panel-foot').forEach(function(el){el.style.direction=isHe?'rtl':'ltr'});
        }
        applyI18n(loc);
        var observer=new MutationObserver(function(mutations){
          mutations.forEach(function(m){
            if(m.attributeName==='lang'){
              var newLang=document.documentElement.getAttribute('lang');
              if(newLang){newLang=newLang.substring(0,2);}
              if(newLang&&newLang!==loc){
                loc=newLang;
                applyI18n(loc);
              }
            }
          });
        });
        observer.observe(document.documentElement,{attributes:true,attributeFilter:['lang']});
      })();
      </script>
    HTML
  end
end

Rails.application.config.middleware.insert_before BotBuilderMiddleware, CustomNavWidgetMiddleware
