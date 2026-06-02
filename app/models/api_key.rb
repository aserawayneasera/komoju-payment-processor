class ApiKey < ApplicationRecord
  belongs_to :merchant

  validates :token_digest, presence: true, uniqueness: true
  validates :name, presence: true

  def self.authenticate!(raw_token)
    digest = Digest::SHA256.hexdigest(raw_token)
    key = find_by!(token_digest: digest)
    raise ActiveRecord::RecordNotFound if key.revoked_at.present?
    key.touch(:last_used_at)
    key
  end

  def self.generate_for(merchant, name:)
    raw_token = SecureRandom.hex(32)
    digest = Digest::SHA256.hexdigest(raw_token)
    key = merchant.api_keys.create!(token_digest: digest, name: name)
    [key, raw_token]
  end

  def revoked?
    revoked_at.present?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end
