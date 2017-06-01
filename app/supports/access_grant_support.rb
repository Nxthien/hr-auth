class AccessGrantSupport
  include ActiveModel::Validations

  attr_reader :access_grant, :application

  validates_presence_of :access_grant, :application

  def initialize params, user
    @params = params
    @grant_type = @params[:grant_type]
    @refresh_token = params[:refresh_token]
    @user = user
    @application = load_application
    @access_grant = load_access_grant if @application
  end

  private

  def load_access_grant
    case @grant_type
    when "refresh_token"
      AccessGrant.authenticate_with_refresh_token(@refresh_token, @application.id)
    when "password"
      AccessGrant.authenticate_with_user @user.id, @application.id
    else
      AccessGrant.authenticate(@params[:code], @application.id)
    end
  end

  def load_application
    Client.authenticate(@params[:client_id], @params[:client_secret])
  end
end
