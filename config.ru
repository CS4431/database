require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/activerecord'
require './src/routes.rb'

# Handles Rack connections with the app. Needed to clear ActiveRecord connections.
class RackHandler
  # Create a new RackHandler
  # @param app [Sinatra::Base] the application
  def initialize(app)
    @app = app
    @app.set :public_folder, 'public'
  end

  # Handles a user request
  # @param env [Hash] environment hash
  def call(env)
    results = @app.call(env)
    ActiveRecord::Base.clear_active_connections!
    results
  end
end

# database must be set before Routes is initilized
set :database, {adapter: "sqlite3", database: "db/books.sqlite"}

webrick_options = {
  :Host => '0.0.0.0',
  :Port => 4567
}

Rack::Handler::WEBrick.run(RackHandler.new(Routes), webrick_options)
