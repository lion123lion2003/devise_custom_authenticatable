require 'devise/strategies/authenticatable'

module Devise::Strategies
  # Strategy for delegateing authentication logic to custom model's method
  class CustomAuthenticatable < Authenticatable

    def authenticate!
      resource  = valid_password? && mapping.to.find_for_custom_authentication(authentication_hash)
      unless resource.respond_to?(:valid_for_custom_authentication?) and
          resource.valid_for_custom_authentication?(password)
        return pass
      end

      catch(:skip_custom_strategies) do
        if validate(resource){ resource.valid_for_custom_authentication?(password) }
          resource.after_custom_authentication
          success!(resource)
        end
      end
    end

  end
end

Warden::Strategies.add(:custom_authenticatable, Devise::Strategies::CustomAuthenticatable)
