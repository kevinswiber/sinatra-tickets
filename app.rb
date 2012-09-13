require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/url_for'
require './config/environments'
require 'pg'

before do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/restdesk')
  conn = PG.connect \
    :host => db.host,
    :user => db.user,
    :password => db.password,
    :dbname => db.path[1..-1]

end

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
