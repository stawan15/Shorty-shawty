// version_check.js
// Poll /version ทุก 60 วินาที — ถ้า version เปลี่ยน รอ user idle แล้ว reload อัตโนมัติ

const POLL_INTERVAL = 60_000 // 60 วิ
const IDLE_THRESHOLD = 30_000 // idle 30 วิ ถึงจะ reload

let currentVersion = document.getElementById('nav-version')?.textContent?.replace(/^v/, '').trim()
let lastActivity = Date.now()
let pendingReload = false

// track user activity
;['mousemove', 'keydown', 'mousedown', 'touchstart', 'scroll'].forEach(e =>
  document.addEventListener(e, () => { lastActivity = Date.now() }, { passive: true })
)

function checkVersion () {
  fetch('/version', { cache: 'no-store' })
    .then(r => r.json())
    .then(({ version }) => {
      if (!currentVersion) {
        currentVersion = version
        return
      }
      if (version !== currentVersion && !pendingReload) {
        pendingReload = true
        waitForIdle()
      }
    })
    .catch(() => {}) // ถ้า fetch fail (offline ฯลฯ) ก็ไม่ต้องทำอะไร
}

function waitForIdle () {
  if (Date.now() - lastActivity >= IDLE_THRESHOLD) {
    location.reload()
  } else {
    setTimeout(waitForIdle, 5_000) // เช็คใหม่ทุก 5 วิ
  }
}

// เริ่ม polling หลัง page load
if (typeof window !== 'undefined') {
  setInterval(checkVersion, POLL_INTERVAL)

  // Dev helper: window.checkVersion() เพื่อ trigger ทดสอบจาก browser console
  window.checkVersion = checkVersion
}
