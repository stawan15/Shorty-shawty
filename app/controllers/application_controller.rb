class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :short_url_for

  def short_url_for(url)
    base = ENV["APP_BASE_URL"].presence || request.base_url
    "#{base}/#{url.short_code}"
  end
end
