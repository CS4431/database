require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/activerecord'
require './src/routes.rb'

set :env, :development
set :port, 4567
set :database, {adapter: "sqlite3", database: "db/books.sqlite"}
set :run, false

run Routes
