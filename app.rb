require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'

get '/' do
  'Hello World'
end

# Search tickets
get '/tickets' do
end

# Search users
get '/users' do
end

# Change log
get '/changes' do
end