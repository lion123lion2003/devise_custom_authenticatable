# coding: utf-8
require 'devise'

require 'devise_custom_authenticatable/model'
require 'devise_custom_authenticatable/strategy'
require 'devise_custom_authenticatable/version'

module Devise
  # Add valid users to database
  mattr_accessor :custom_create_user
  @@custom_create_user = false
end

Devise.add_module(:custom_authenticatable, {
  route: :session,
  strategy: true,
  controller: :sessions,
  model: 'devise_custom_authenticatable/model'
})
