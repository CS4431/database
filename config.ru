require 'rubygems'
require 'sinatra'
require 'rack'
require './src/routes.rb'

set :env, :production
set :run, false

run Routes
