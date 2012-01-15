# Be sure to restart your server when you modify this file.

Whichbus::Application.config.session_store :cookie_store, :key => '_whichbus_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Whichbus::Application.config.session_store :active_record_store
# Session cache

ActionController::Base.session = {
  :namespace   => 'sessions',
  :expire_after => 20.minutes.to_i,
  :memcache_server => ['server-1:11211', 'server-2:11211'],
  :key         => ...,
  :secret      => ...
}

require 'action_controller/session/dalli_store'
ActionController::Base.session_store = :dalli_store
