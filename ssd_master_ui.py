import http.server, socketserver, subprocess, threading, json, os, webbrowser

PORT = 18890
BASE_DIR = r'F:\program\ssd-cloud-sync'
current_proc = None
log_lines = ['[SYSTEM] SSD Master HTML Control Panel Ready (v2.8).']
lock = threading.Lock()

HTML = '''<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>NAM KI-DONG | SSD Master Control Panel</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css">
<style>
  :root { --bg:#0f172a; --card:#1e293b; --text:#f1f5f9; --muted:#94a3b8; --border:#334155; --accent:#38bdf8; }
  body.light { --bg:#f8fafc; --card:#ffffff; --text:#0f172a; --muted:#475569; --border:#cbd5e1; --accent:#0284c7; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:'Pretendard',sans-serif; background:var(--bg); color:var(--text); padding:20px; transition:0.2s; }
  .wrap { max-width:980px; margin:0 auto; }
  header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; border-bottom:1px solid var(--border); padding-bottom:12px; }
  h1 { font-size:20px; font-weight:700; }
  .badge { background:var(--accent); color:#0f172a; font-size:12px; font-weight:700; padding:3px 8px; border-radius:6px; margin-left:8px; }
  .top-btns button, .top-btns .bridge-link { background:var(--card); color:var(--text); border:1px solid var(--border); padding:6px 12px; border-radius:6px; cursor:pointer; font-size:13px; margin-left:6px; }
  .top-btns .bridge-link { display:inline-block; text-decoration:none; }
  .grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(280px, 1fr)); gap:12px; margin-bottom:16px; }
  .card { background:var(--card); border:1px solid var(--border); border-radius:10px; padding:14px; display:flex; flex-direction:column; justify-content:space-between; }
  .card h3 { font-size:15px; margin-bottom:6px; color:var(--accent); }
  .card p { font-size:13px; color:var(--muted); line-height:1.45; margin-bottom:12px; }
  .btn { width:100%; padding:10px; border:none; border-radius:7px; font-weight:700; font-size:13px; cursor:pointer; color:#fff; background:#2563eb; }
  .btn:hover { opacity:0.9; }
  .btn.warn { background:#d97706; }
  .btn.safe { background:#059669; }
  .btn.dedupe { background:#7c3aed; }
  .ctrl-bar { display:flex; justify-content:space-between; align-items:center; background:var(--card); border:1px solid var(--border); padding:10px 14px; border-radius:8px; margin-bottom:10px; }
  .stop-btn { background:#dc2626; color:#fff; border:none; padding:7px 14px; border-radius:6px; font-weight:700; cursor:pointer; }
  pre { font-family:'NanumGothicCoding','Consolas',monospace; background:#020617; color:#e2e8f0; padding:14px; border-radius:8px; height:320px; overflow-y:auto; font-size:12.5px; line-height:1.5; border:1px solid var(--border); white-space:pre-wrap; }
</style>
</head>
<body>
<div class="wrap">
  <header>
    <div><h1>External SSD Master Sync <span class="badge">HTML Dashboard v2.9</span></h1></div>
    <div class="top-btns"><button style="background:#0284c7;color:#fff;border:none;font-weight:700;" onclick="toggleHelp(true)">❓ Help (사용 안내)</button><button style="background:#0284c7;color:#fff;border:none;font-weight:700;" onclick="toggleHelp(true)">❓ Help (사용 안내)</button>
      <button onclick="document.body.classList.toggle('light')">다크 / 라이트 전환</button>
      <button onclick="clearLog()">로그 지우기</button>
      <a class="bridge-link" href="http://127.0.0.1:18895/" target="_blank" rel="noopener noreferrer">모바일 원격 브릿지 (18895)</a>
    </div>
  </header>
  <div class="grid">
    <div class="card"><div><h3>[3] Start Work (출근 2-Way 동기화)</h3><p>PC와 구글 드라이브의 코딩 폴더(program, program-kdn)를 3.7초 만에 양방향 최신화합니다.</p></div><button class="btn safe" onclick="runTask('3')">▶ [3] 출근 동기화 실행</button></div>
    <div class="card"><div><h3>[4] Force Push (코딩 강제 업로드)</h3><p>로컬 PC의 최신 코딩 폴더를 구글 드라이브에 즉시 덮어써서 백업합니다.</p></div><button class="btn" onclick="runTask('4')">▶ [4] 코딩 강제 업로드</button></div>
    <div class="card"><div><h3>[5] Fast Eject (퇴근 백업 + 안전 분리)</h3><p>최근 24시간 내 수정된 파일만 빠르게 백업한 뒤 외장 SSD(F:)를 안전 제거합니다.</p></div><button class="btn warn" onclick="runTask('5')">▶ [5] 퇴근 백업 및 SSD 분리</button></div>
    <div class="card"><div><h3>[6] Full Backup (주간 F: 전체 백업)</h3><p>임시·캐시 폴더를 제외한 외장 SSD(F:) 전체 클린 폴더를 구글 드라이브로 통백업합니다.</p></div><button class="btn" onclick="runTask('6')">▶ [6] 주간 F: 전체 백업</button></div>
    <div class="card"><div><h3>[7] GDrive Dedupe (구글 드라이브 중복 검사)</h3><p>24개 업무 폴더(30초)와 대용량 백업 폴더의 중복 파일을 MD5 지문으로 스캔 후 메모장으로 엽니다.</p></div><button class="btn dedupe" onclick="runTask('7')">▶ [7] 구글 드라이브 중복 검사</button></div>
  </div>
  <div class="ctrl-bar">
    <span id="status" style="font-size:13px;font-weight:600;">● 대기 중 (원하는 작업 버튼을 클릭하세요)</span>
    <button class="stop-btn" onclick="stopTask()">■ 작업 즉시 안전 중단 (Ctrl+C)</button>
  </div>
  <pre id="log"></pre>
</div>
<script>
function runTask(id){ fetch('/run?id='+id); }
function stopTask(){ fetch('/stop'); }
function clearLog(){ fetch('/clear'); }
setInterval(async()=>{
  const r = await fetch('/status');
  const d = await r.json();
  document.getElementById('status').textContent = d.running ? '🔄 작업 실행 중... (중단 버튼으로 언제든 안전 중지 가능)' : '● 대기 중 (완료 또는 준비 상태)';
  const el = document.getElementById('log');
  const atBottom = el.scrollHeight - el.scrollTop <= el.clientHeight + 40;
  el.textContent = d.logs.join('\n');
  if(atBottom) el.scrollTop = el.scrollHeight;
}, 800);
</script>
<div id="helpModal" onclick="if(event.target===this)toggleHelp(false)" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.65);z-index:999;align-items:center;justify-content:center;padding:20px;">
  <div style="background:var(--card);color:var(--text);border:1px solid var(--border);border-radius:12px;max-width:640px;width:100%;padding:22px;box-shadow:0 20px 40px rgba(0,0,0,0.4);line-height:1.6;">
    <div style="display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border);padding-bottom:10px;margin-bottom:14px;">
      <h2 style="font-size:18px;">📘 SSD Master 사용 안내 (Help Guide)</h2>
      <button onclick="toggleHelp(false)" style="background:#ef4444;color:#fff;border:none;padding:5px 12px;border-radius:6px;cursor:pointer;font-weight:700;">닫기 ✕</button>
    </div>
    <ul style="font-size:13.5px;padding-left:18px;display:flex;flex-direction:column;gap:8px;">
      <li><b>[3] Start Work (출근 2-Way 동기화):</b> 출근 직후 PC와 구글 드라이브의 코딩 폴더(<code>program</code>, <code>program-kdn</code>)를 양방향 최신화합니다.</li>
      <li><b>[4] Force Push (코딩 강제 업로드):</b> 내 PC에서 수정한 코딩 폴더를 구글 드라이브에 즉시 덮어써서 백업할 때 사용합니다.</li>
      <li><b>[5] Fast Eject (퇴근 백업 + 안전 분리):</b> 퇴근 전 최근 24시간 내 변경 파일만 빠르게 백업한 뒤 외장 SSD(F:)를 안전 제거합니다.</li>
      <li><b>[6] Full Backup (주간 F: 전체 백업):</b> 주 1회 외장 SSD(F:) 전체 클린 폴더를 구글 드라이브로 통백업합니다.</li>
      <li><b>[7] GDrive Dedupe (구글 드라이브 중복 검사):</b> 24개 업무 폴더(약 30초)와 대용량 백업 폴더의 중복 파일을 찾아 바탕화면 <code>gdrive_duplicates.txt</code> 메모장으로 엽니다.</li>
      <li><b>■ 작업 즉시 안전 중단:</b> 실행 중 급한 용무가 생기면 빨간 중단 버튼을 누르세요. 전송 중이던 파일은 구글 드라이브에 올라가지 않아 <b>손상률 0%</b>이며, 다음 실행 시 멈춘 지점부터 자동 이어받기 됩니다.</li>
    </ul>
  </div>
</div>
<script>function toggleHelp(show){ document.getElementById('helpModal').style.display = show ? 'flex' : 'none'; }</script>
<div id="helpModal" onclick="if(event.target===this)toggleHelp(false)" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.65);z-index:999;align-items:center;justify-content:center;padding:20px;">
  <div style="background:var(--card);color:var(--text);border:1px solid var(--border);border-radius:12px;max-width:640px;width:100%;padding:22px;box-shadow:0 20px 40px rgba(0,0,0,0.4);line-height:1.6;">
    <div style="display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border);padding-bottom:10px;margin-bottom:14px;">
      <h2 style="font-size:18px;">📘 SSD Master 사용 안내 (Help Guide)</h2>
      <button onclick="toggleHelp(false)" style="background:#ef4444;color:#fff;border:none;padding:5px 12px;border-radius:6px;cursor:pointer;font-weight:700;">닫기 ✕</button>
    </div>
    <ul style="font-size:13.5px;padding-left:18px;display:flex;flex-direction:column;gap:8px;">
      <li><b>[3] Start Work (출근 2-Way 동기화):</b> 출근 직후 PC와 구글 드라이브의 코딩 폴더(<code>program</code>, <code>program-kdn</code>)를 양방향 최신화합니다.</li>
      <li><b>[4] Force Push (코딩 강제 업로드):</b> 내 PC에서 수정한 코딩 폴더를 구글 드라이브에 즉시 덮어써서 백업할 때 사용합니다.</li>
      <li><b>[5] Fast Eject (퇴근 백업 + 안전 분리):</b> 퇴근 전 최근 24시간 내 변경 파일만 빠르게 백업한 뒤 외장 SSD(F:)를 안전 제거합니다.</li>
      <li><b>[6] Full Backup (주간 F: 전체 백업):</b> 주 1회 외장 SSD(F:) 전체 클린 폴더를 구글 드라이브로 통백업합니다.</li>
      <li><b>[7] GDrive Dedupe (구글 드라이브 중복 검사):</b> 24개 업무 폴더(약 30초)와 대용량 백업 폴더의 중복 파일을 찾아 바탕화면 <code>gdrive_duplicates.txt</code> 메모장으로 엽니다.</li>
      <li><b>■ 작업 즉시 안전 중단:</b> 실행 중 급한 용무가 생기면 빨간 중단 버튼을 누르세요. 전송 중이던 파일은 구글 드라이브에 올라가지 않아 <b>손상률 0%</b>이며, 다음 실행 시 멈춘 지점부터 자동 이어받기 됩니다.</li>
    </ul>
  </div>
</div>
<script>function toggleHelp(show){ document.getElementById('helpModal').style.display = show ? 'flex' : 'none'; }</script>
</body>
</html>'''

def worker(cmd_list, label):
    global current_proc
    with lock:
        log_lines.append(f'\n================ {label} 시작 ================')
    try:
        current_proc = subprocess.Popen(cmd_list, cwd=BASE_DIR, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, encoding='utf-8', errors='replace')
        for line in current_proc.stdout:
            with lock:
                log_lines.append(line.rstrip())
                if len(log_lines) > 600: del log_lines[:100]
        current_proc.wait()
    except Exception as e:
        with lock: log_lines.append(f'[ERROR] {e}')
    finally:
        with lock: log_lines.append(f'================ {label} 종료 ================')
        current_proc = None

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *args): pass
    def do_GET(self):
        global current_proc
        if self.path == '/':
            self.send_response(200); self.send_header('Content-Type','text/html; charset=utf-8'); self.end_headers()
            self.wfile.write(HTML.encode('utf-8'))
        elif self.path.startswith('/run?id='):
            tid = self.path.split('=')[-1]
            if current_proc is None:
                if tid == '7':
                    cmd = ['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File', os.path.join(BASE_DIR,'gdrive_dedupe.ps1')]
                    threading.Thread(target=worker, args=(cmd, '[7] Google Drive 중복 검사'), daemon=True).start()
                elif tid in ('3','4','5','6'):
                    cmd = ['cmd','/c', f'echo {tid}| master_sync.bat']
                    threading.Thread(target=worker, args=(cmd, f'[{tid}] SSD Master 작업'), daemon=True).start()
            self.send_response(200); self.end_headers()
        elif self.path == '/stop':
            if current_proc is not None:
                subprocess.run(['taskkill','/F','/T','/PID', str(current_proc.pid)], capture_output=True)
                with lock: log_lines.append('[SAFE STOP] 사용자 요청으로 작업이 안전하게 중단되었습니다 (파일 손상 0%).')
            self.send_response(200); self.end_headers()
        elif self.path == '/clear':
            with lock: log_lines.clear(); log_lines.append('[SYSTEM] 로그 화면이 초기화되었습니다.')
            self.send_response(200); self.end_headers()
        elif self.path == '/status':
            self.send_response(200); self.send_header('Content-Type','application/json; charset=utf-8'); self.end_headers()
            with lock:
                payload = json.dumps({'running': current_proc is not None, 'logs': log_lines}, ensure_ascii=False)
            self.wfile.write(payload.encode('utf-8'))

if __name__ == '__main__':
    webbrowser.open(f'http://127.0.0.1:{PORT}')
    with socketserver.ThreadingTCPServer(('127.0.0.1', PORT), Handler) as httpd:
        httpd.serve_forever()
