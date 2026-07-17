# Shorty — App version
# Dokku injects GIT_REV automatically on every deploy
APP_VERSION = ENV.fetch("GIT_REV", "dev").then { |v| v.length > 8 ? v[0..7] : v }

# บันทึกเวลา boot ไว้ใช้กับ /version endpoint
Rails.application.config.x.deployed_at = Time.now.utc.iso8601
