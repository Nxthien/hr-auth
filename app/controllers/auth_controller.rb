class AuthController < ApplicationController
  before_action :authenticate_user!, except: [:access_token, :me]
  skip_before_action :verify_authenticity_token, only: [:access_token]

  def authorize
    AccessGrant.prune!
    access_grant = current_user.access_grants
      .create client: application, state: params[:state]
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    application = Client.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render json: {error: "Could not find application"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)

    if access_grant.nil?
      render json: {error: "Could not authenticate access code"}
      return
    end

    access_grant.start_expiry_period!
    render json: {
      access_token: access_grant.access_token,
      refresh_token: access_grant.refresh_token,
      expires_in: Devise.timeout_in.to_i
    }
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

  def application
    @application ||= Client.find_by app_id: params[:client_id]
  end
end
