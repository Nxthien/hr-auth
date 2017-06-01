class AuthController < ApplicationController
  before_action :authenticate_user!, except: [:access_token, :me]
  skip_before_action :verify_authenticity_token, only: [:access_token]
  before_action :verify_user!, only: [:access_token], if: :is_grant_password_type?

  def authorize
    AccessGrant.prune!
    application = Client.find_by app_id: params[:client_id]
    access_grant = current_user.access_grants
      .create client: application, state: params[:state]
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    ag_support = AccessGrantSupport.new params, @user

    if ag_support.valid?
      access_grant = ag_support.access_grant
      access_grant.start_expiry_period!
      render json: {
        access_token: access_grant.access_token,
        refresh_token: access_grant.refresh_token,
        expires_in: Devise.timeout_in.to_i
      }
      return
    end

    if ag_support.application.nil?
      render json: {error: "Could not find application"}
      return
    end

    if ag_support.access_grant.nil?
      render json: {error: "Could not authenticate access code"}
      return
    end
  end

  def failure
    render text: "ERROR: #{params[:message]}"
  end

  def me
    user = User.find_for_token_authentication params[:access_token]
    user.authentication_token = User.generate_unique_secure_token.downcase!
    user.save

    if user.present?
      render json: user.json_data
    else
      render json: {}
    end
  end

  private

  def is_grant_password_type?
    params[:grant_type] == "password"
  end

  def verify_user!
    u_support = UserSupport.new params

    if u_support.invalid? || !u_support.authenticate_user!
      render json: {error: "Invalid email or password"}
      return
    end
    @user = u_support.user
  end
end
