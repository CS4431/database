require 'rubygems'
require 'sinatra'
require 'rack'
require './src/routes.rb'

set :root, Pathname(__FILE__).dirname
set :env, :production
set :run, false

run Routes
