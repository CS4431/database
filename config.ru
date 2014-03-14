require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/activerecord'
require './src/routes.rb'
require 'webrick/https'
require 'openssl'

# Handles Rack connections with the app. Needed to clear ActiveRecord connections.
class RackHandler
  # Create a new RackHandler
  # @param app [Sinatra::Base] the application
  def initialize(app)
    @app = app
  end

  # Handles a user request
  # @param env [Hash] environment hash
  def call(env)
    results = @app.call(env)
    ActiveRecord::Base.clear_active_connections!
    results
  end
end

set :env, :development
set :database, {adapter: "sqlite3", database: "db/books.sqlite"}
set :run, false

certificate = File.open("/opt/myCA/server/www.bookmarket.webhop.org.crt").read
key = File.open("/opt/myCA/server/www.bookmarket.webhop.org.key").read

webrick_options = {
  :Host => '0.0.0.0',
  :Port => 4567,
  :SSLEnable => true,
  :SSLCertificate => OpenSSL::X509::Certificate.new(certificate),
  :SSLPrivateKey => OpenSSL::PKey::RSA.new(key)
}

Rack::Handler::WEBrick.run(RackHandler.new(Routes), webrick_options)
