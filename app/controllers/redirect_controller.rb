class RedirectController < ApplicationController
  def show
    url = Url.find_by!(short_code: params[:short_code])

    url.click_events.create!(
      referrer: request.referer&.truncate(500),
      user_agent: request.user_agent&.truncate(500),
      ip_address: request.remote_ip
    )
    url.increment!(:clicks)

    redirect_to url.original_url, allow_other_host: true, status: :moved_permanently
  end
end
