module UserSso
  extend ActiveSupport::Concern

  included do
    has_many :authentications, dependent: :delete_all
    has_many :access_grants, dependent: :delete_all

    class << self
      def find_for_token_authentication access_token
        where(["access_grants.access_token = ? \
          AND (access_grants.access_token_expires_at IS NULL \
          OR access_grants.access_token_expires_at > ?)",
          access_token, Time.now])
        .joins(:access_grants).select("users.*").first
      end
    end

    def json_data
      {
        email: email,
        avatar: "http://#{Settings.host}#{avatar.url}",
        name: name,
        authentication_token: authentication_token,
        gender: gender,
        role: role,
        birthday: birthday,
        employee_code: employee_code,
        position: position,
        contract_date: contract_date,
        status: status,
        phone_number: phone_number,
        contract_type: contract_type,
        university: university,
        join_date: join_date,
        resigned_date: resigned_date
      }
    end
  end
end
