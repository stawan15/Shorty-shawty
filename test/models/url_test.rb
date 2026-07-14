require "test_helper"

class UrlTest < ActiveSupport::TestCase
  test "generates a short_code automatically" do
    url = Url.create!(original_url: "https://example.com")
    assert url.short_code.present?
    assert_equal 6, url.short_code.length
  end

  test "short_codes are unique" do
    url1 = Url.create!(original_url: "https://example.com/1")
    url2 = Url.create!(original_url: "https://example.com/2")
    assert_not_equal url1.short_code, url2.short_code
  end

  test "prepends https:// to bare URLs" do
    url = Url.create!(original_url: "example.com")
    assert url.original_url.start_with?("https://")
  end

  test "rejects javascript: URLs" do
    url = Url.new(original_url: "javascript:alert(1)")
    assert_not url.valid?
  end

  test "requires original_url" do
    url = Url.new
    assert_not url.valid?
    assert_includes url.errors[:original_url], "can't be blank"
  end

  test "allows custom short_code" do
    url = Url.create!(original_url: "https://example.com", short_code: "custom")
    assert_equal "custom", url.short_code
  end
end
