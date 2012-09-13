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

before do
  content_type "application/vnd.org.restfest.2012.hackday+xml"
end

# Home
get '/' do
  erb :index, :locals => {
    :self_url => url_for("/", :full),
    :tickets_url => url_for("/tickets", :full),
    :users_url => url_for("/users", :full),
    :changes_url => url_for("/changes", :full)
  }
end

# Get/search tickets collection
get '/tickets' do
  erb :tickets, :locals => {
    :self_url => url_for("/tickets", :full),
    :tickets => '<ticket></ticket>' # TODO: insert real ticket(s) here
  }
end

# Get/search comments collection
get %r{/tickets/([\w\d]+)/comments} do
  ticket_id = params[:captures].first

  erb :comments, :locals => {
    :self_url => url_for("/ticket/#{ticket_id}/comments", :full),
    :comments => '<comment></comment>' # TODO: insert real comment(s) for ticket here
  }
end

# Get/search users collection
get '/users' do
  erb :users, :locals => {
    :self_url => url_for("/users", :full),
    :users => '<user></user>' # TODO: insert real user(s) here
  }
end

# Change log
get '/changes' do
  erb :changes, :locals => {
    :self_url => url_for("/changes", :full),
    :from_iso_time => '2012-09-13T12:01:00Z', # TODO: real from time here (ISO8601)
    :to_iso_time => '2012-09-13T12:01:59Z', # TODO: real to time here (ISO8601)
    :events => '<events></events>' # TODO: insert real event(s) here
  }
end