class AccessGrant < ApplicationRecord
  belongs_to :user
  belongs_to :client

  before_create :generate_tokens

  class << self
    def prune!
      where("created_at < ?", 3.days.ago).delete_all
    end

    def authenticate code, client_id
      where(code: code, client_id: client_id).first
    end

    def authenticate_with_refresh_token refresh_token, client_id
      access_grant = find_by(refresh_token: refresh_token, client_id: client_id)

      if access_grant
        access_grant.update_attribute(:access_token_expires_at, Time.now + Devise.timeout_in)
        return access_grant
      end
    end

    def authenticate_with_user user_id, client_id
      access_grant = find_or_initialize_by user_id: user_id, client_id: client_id
      return access_grant if access_grant.persisted?
      access_grant.save
    end
  end

  def generate_tokens
    self.code = SecureRandom.hex(16)
    self.access_token = SecureRandom.hex(16)
    self.refresh_token = SecureRandom.hex(16)
  end

  def redirect_uri_for redirect_uri
    if redirect_uri =~ /\?/
      redirect_uri + "&code=#{code}&response_type=code&state=#{state}"
    else
      redirect_uri + "?code=#{code}&response_type=code&state=#{state}"
    end
  end

  # Note: This is currently configured through devise, and matches the AuthController access token life
  def start_expiry_period!
    self.update_attribute(:access_token_expires_at, Time.now + Devise.timeout_in)
  end
end
