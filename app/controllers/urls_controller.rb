require "net/http"

class UrlsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy, :analytics]
  before_action :set_url, only: [:destroy, :analytics, :qr_code]
  before_action :throttle_expand!, only: [:expand]

  def index
    @url = Url.new
    @urls = user_signed_in? ? current_user.urls.order(created_at: :desc) : []
  end

  def click_counts
    return render json: [] unless user_signed_in?
    counts = current_user.urls.pluck(:id, :clicks)
                         .map { |id, c| { id: id, clicks: c } }
    render json: counts
  end

  def create
    @url = Url.new(permitted_url_params)
    @url.user = current_user if user_signed_in?

    if @url.save
      if user_signed_in?
        redirect_to root_path, notice: "Short URL created successfully!"
      else
        redirect_to root_path, flash: {
          guest_short_url: short_url_for(@url),
          guest_original_url: @url.original_url
        }
      end
    else
      @urls = user_signed_in? ? current_user.urls.order(created_at: :desc) : []
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @url.destroy
    redirect_to root_path, notice: "URL deleted."
  end

  def analytics
    @clicks_by_day = @url.click_events
                         .group("DATE(created_at)")
                         .order("DATE(created_at) DESC")
                         .count
    @recent_clicks = @url.click_events.order(created_at: :desc).limit(50)
  end

  def lengthen
    raw = params[:url].to_s.strip
    raw = "https://#{raw}" unless raw.match?(/\Ahttps?:\/\//i)

    @url = Url.new(original_url: raw)
    @url.user = current_user if user_signed_in?

    # Override auto-generated short_code with a very long one
    @url.short_code = generate_long_code

    if @url.save
      long_url = short_url_for(@url)
      render json: { long_url: long_url }
    else
      render json: { error: @url.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  def expand
    raw = params[:url].to_s.strip
    raw = "https://#{raw}" unless raw.match?(/\Ahttps?:\/\//i)

    begin
      uri = URI.parse(raw)
      raise ArgumentError unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError, ArgumentError
      return render json: { error: "Invalid URL" }, status: :unprocessable_entity
    end

    final_url = follow_redirects(uri)
    render json: { original: raw, expanded: final_url }
  rescue => e
    render json: { error: "Could not expand URL: #{e.message}" }, status: :unprocessable_entity
  end

  def qr_code
    qr = RQRCode::QRCode.new(short_url_for(@url))
    svg = qr.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 7,
      standalone: true
    )

    if params[:format] == "svg"
      render plain: svg, content_type: "image/svg+xml"
    else
      # Embed as data URL — works on all devices, no second HTTP request
      @qr_data_url = "data:image/svg+xml;base64,#{Base64.strict_encode64(svg)}"
      @qr_svg_download = svg
    end
  end

  private

  def set_url
    if action_name.in?(%w[destroy analytics]) && user_signed_in?
      @url = current_user.urls.find(params[:id])
    else
      @url = Url.find(params[:id])
    end
  end

  PRIVATE_IP_PATTERNS = [
    /\A127\./,
    /\A10\./,
    /\A172\.(1[6-9]|2[0-9]|3[01])\./,
    /\A192\.168\./,
    /\A::1\z/,
    /\Alocalhost\z/i
  ].freeze

  MAX_REDIRECTS = 10

  def follow_redirects(uri, hops = 0)
    raise "Too many redirects" if hops >= MAX_REDIRECTS

    host = uri.host.to_s
    raise "Requests to private addresses are not allowed" if PRIVATE_IP_PATTERNS.any? { |p| p.match?(host) }

    use_ssl = uri.scheme == "https"
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl, open_timeout: 5, read_timeout: 5) do |http|
      http.head(uri.request_uri)
    end

    case response
    when Net::HTTPRedirection
      location = response["location"]
      next_uri = URI.parse(location)
      next_uri = uri.merge(next_uri) if next_uri.relative?
      follow_redirects(next_uri, hops + 1)
    else
      uri.to_s
    end
  end

  def generate_long_code
    loop do
      code = SecureRandom.alphanumeric(rand(200..300))
      return code unless Url.exists?(short_code: code)
    end
  end

  EXPAND_RATE_LIMIT = 10 # requests per window
  EXPAND_RATE_WINDOW = 60 # seconds

  def throttle_expand!
    key = "expand:#{request.remote_ip}"
    count = Rails.cache.increment(key, 1, expires_in: EXPAND_RATE_WINDOW) rescue nil
    return unless count.is_a?(Integer) && count > EXPAND_RATE_LIMIT
    render json: { error: "Too many requests. Please slow down." }, status: :too_many_requests
  end

  def permitted_url_params
    allowed = [:original_url]
    allowed << :short_code if user_signed_in?
    params.require(:url).permit(*allowed)
  end
end
