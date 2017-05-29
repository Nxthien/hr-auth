class Api::AuthorizesController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!
  before_action :verify_params!

  def create
    user = User.find_by email: @email

    if user.nil?
      render json: {error: "Not found user with email #{@email}"},
        status: :no_content
      return
    end

    if user.valid_password?(@password)
      sign_in("user", user)
      render json: {
        provider: "hr_system",
        uid: user.employee_code,
        info: user.json_data
      }
      return
    end

    render json: {error: "Invalid email or password"}
  end

  private

  def verify_params!
    @email = params[:email]
    @password = params[:password]

    if @email.blank? || @password.blank?
      render json: {error: "Invalid email or password"}
      return
    end
  end
end
