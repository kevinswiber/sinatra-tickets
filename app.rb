require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/url_for'
require './config/environments'

# Home
get '/' do
  content_type "application/vnd.org.restfest.2012.hackday+xml"
  erb :index, :locals => {
    :self_url => url_for("/", :full),
    :tickets_url => url_for("/tickets", :full),
    :users_url => url_for("/users", :full),
    :changes_url => url_for("/changes", :full)
  }
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