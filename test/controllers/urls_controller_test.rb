require "test_helper"

class UrlsControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the home page" do
    get root_path
    assert_response :success
  end

  test "POST /urls creates a short URL and redirects" do
    assert_difference "Url.count", 1 do
      post urls_path, params: { url: { original_url: "https://example.com" } }
    end
    assert_redirected_to root_path
  end

  test "POST /urls with invalid URL shows errors" do
    post urls_path, params: { url: { original_url: "" } }
    assert_response :unprocessable_entity
  end
end
