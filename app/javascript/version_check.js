// version_check.js
// Poll /version ทุก 60 วินาที — ถ้า version เปลี่ยน แสดง banner แจ้งให้ refresh
// nav-version badge จะอัปเดต text อัตโนมัติด้วย

const POLL_INTERVAL = 60_000 // 60 วิ
let currentVersion = document.getElementById('nav-version')?.textContent?.replace(/^v/, '').trim()

function checkVersion () {
  fetch('/version', { cache: 'no-store' })
    .then(r => r.json())
    .then(({ version }) => {
      if (!currentVersion) {
        currentVersion = version
        return
      }
      if (version !== currentVersion) {
        showUpdateBanner(version)
      }
    })
    .catch(() => {}) // ถ้า fetch fail (offline ฯลฯ) ก็ไม่ต้องทำอะไร
}

function showUpdateBanner (newVersion) {
  if (document.getElementById('version-banner')) return // ไม่แสดงซ้ำ

  const banner = document.createElement('div')
  banner.id = 'version-banner'
  banner.innerHTML = `
    <span>🚀 มีเวอร์ชั่นใหม่ <strong>v${newVersion}</strong> — </span>
    <button onclick="location.reload()">Reload</button>
    <button onclick="this.parentElement.remove()" aria-label="ปิด">✕</button>
  `
  document.body.prepend(banner)
}

// เริ่ม polling หลัง page load
if (typeof window !== 'undefined') {
  setInterval(checkVersion, POLL_INTERVAL)

  // Dev helper: window.checkVersion() เพื่อ trigger ทดสอบจาก browser console
  window.checkVersion = checkVersion
}
