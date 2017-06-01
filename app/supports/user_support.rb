class UserSupport
  include ActiveModel::Validations

  attr_reader :email, :password, :user

  validates_presence_of :email, :password, :user

  def initialize params
    @email = params[:email]
    @password = params[:password]
    @user = User.find_by email: @email
  end

  def authenticate_user!
    return @user.valid_password?(@password)
  end
end
