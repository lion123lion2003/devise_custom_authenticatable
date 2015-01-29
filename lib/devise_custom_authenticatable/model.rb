require 'devise_custom_authenticatable/strategy'

module Devise::Models
  module CustomAuthenticatable
    extend ActiveSupport::Concern

    included do
      attr_accessor :password
    end

    def authenticated_by_any_custom_strategy?(password, *strategies)
      strategies.any? do |strategy|
        self.send(:"authenticated_by_#{strategy}_strategy?", password)
      end
    end

    def skip_custom_strategies
      throw :skip_custom_strategies
    end

    # A callback initiated after successfully authenticating. This can be
    # used to insert your own logic that is only run after the user successfully
    # authenticates.
    def after_custom_authentication

    end

    module ClassMethods
      # Find a user for custom authentication.
      def find_for_custom_authentication(attributes={})
        auth_key = self.authentication_keys.first
        return nil unless attributes[auth_key].present?

        auth_key_value = (self.case_insensitive_keys || []).include?(auth_key) ? attributes[auth_key].downcase : attributes[auth_key]
        auth_key_value = (self.strip_whitespace_keys || []).include?(auth_key) ? auth_key_value.strip : auth_key_value

        resource = where(auth_key => auth_key_value).first

        if resource.blank? && ::Devise.custom_create_user
          resource = new
          resource[auth_key] = auth_key_value
          resource.password = attributes[:password]
        end

        if resource && resource.new_record? && resource.valid_for_custom_authentication?(attributes[:password])
          resource.custom_before_save if resource.respond_to?(:custom_before_save)
          resource.save!
        end

        resource
      end

    end


  end
end
