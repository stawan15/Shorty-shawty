require "test_helper"

class RedirectControllerTest < ActionDispatch::IntegrationTest
  test "redirects to the original URL" do
    url = urls(:one)
    get "/#{url.short_code}"
    assert_redirected_to url.original_url
  end

  test "increments click count on redirect" do
    url = urls(:one)
    original_count = url.clicks
    get "/#{url.short_code}"
    assert_equal original_count + 1, url.reload.clicks
  end

  test "creates a click_event on redirect" do
    url = urls(:one)
    assert_difference "ClickEvent.count", 1 do
      get "/#{url.short_code}"
    end
  end

  test "returns 404 for unknown short code" do
    get "/doesnotexist"
    assert_response :not_found
  end
end
