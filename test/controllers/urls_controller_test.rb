require "test_helper"

class UrlsControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the home page without guest alias controls" do
    get root_path
    assert_response :success
    assert_includes response.body, "Custom aliases are available after sign in."
    refute_includes response.body, 'name="url[short_code]"'
    refute_includes response.body, 'id="alias-row"'
  end

  test "POST /urls as guest creates a copyable short URL without saving it to an account" do
    assert_difference "Url.count", 1 do
      post urls_path, params: { url: { original_url: "https://example.com" } }
    end

    created_url = Url.order(:created_at).last
    assert_nil created_url.user
    assert_redirected_to root_path

    follow_redirect!
    assert_response :success
    assert_includes response.body, "Short link ready"
    assert_includes response.body, "Copy"
    assert_includes response.body, created_url.short_code
  end

  test "POST /urls as guest ignores custom aliases" do
    assert_difference "Url.count", 1 do
      post urls_path, params: { url: { original_url: "https://example.com", short_code: "custom-alias" } }
    end

    refute_equal "custom-alias", Url.order(:created_at).last.short_code
  end

  test "POST /urls with invalid URL shows errors" do
    post urls_path, params: { url: { original_url: "" } }
    assert_response :unprocessable_entity
  end
end
