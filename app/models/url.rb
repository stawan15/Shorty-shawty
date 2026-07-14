class Url < ApplicationRecord
  belongs_to :user, optional: true
  has_many :click_events, dependent: :destroy

  before_validation :normalize_url, on: :create
  before_validation :generate_short_code, on: :create

  validates :original_url, presence: true
  validate :url_must_be_valid
  validates :short_code, uniqueness: true, allow_blank: true

  private

  def normalize_url
    return if original_url.blank?
    unless original_url.match?(/\Ahttps?:\/\//i)
      self.original_url = "https://#{original_url}"
    end
  end

  def url_must_be_valid
    return if original_url.blank?
    uri = URI.parse(original_url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:original_url, "must be a valid HTTP or HTTPS URL")
    end
  rescue URI::InvalidURIError
    errors.add(:original_url, "is not a valid URL")
  end

  def generate_short_code
    return if short_code.present?
    loop do
      self.short_code = SecureRandom.alphanumeric(6)
      break unless Url.exists?(short_code: short_code)
    end
  end
end