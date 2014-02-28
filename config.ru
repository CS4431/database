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
set :port, 4567
set :database, {adapter: "sqlite3", database: "db/books.sqlite"}
set :run, false

run RackHandler.new(Routes)
