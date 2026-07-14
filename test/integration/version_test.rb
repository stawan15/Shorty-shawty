require "test_helper"

class VersionTest < ActionDispatch::IntegrationTest
  test "GET /version returns JSON with version and deployed_at" do
    get "/version"

    assert_response :ok
    assert_equal "application/json", response.content_type.split(";").first

    body = JSON.parse(response.body)
    assert_equal APP_VERSION, body["version"]
    assert_match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/, body["deployed_at"],
                 "deployed_at should be ISO 8601 UTC")
  end

  test "GET /version is cache-busted (no caching)" do
    get "/version"

    assert_response :ok
    # ตรวจว่า response ไม่มี cache header ที่ทำให้ browser เก็บ version เก่า
    refute_match(/max-age=[^0]/, response.headers["cache-control"].to_s)
  end
end
