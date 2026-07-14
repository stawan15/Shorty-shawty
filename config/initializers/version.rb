# Shorty — App version
# Bump manually หรือ wire กับ CI/CD
APP_VERSION = "0.1.0"

# บันทึกเวลา boot ไว้ใช้กับ /version endpoint
Rails.application.config.x.deployed_at = Time.now.utc.iso8601
