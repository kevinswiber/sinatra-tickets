require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/url_for'
require './config/environments'
require 'pg'
require 'securerandom'
require 'rexml/document'

include REXML

helpers do
  def prep_xml(raw_xml)
    xmldoc = Document.new raw_xml

    # strip out xml prolog
    xmldoc.root.to_s
  end
end

before do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/restdesk')
  conn = PG.connect \
    :host => db.host,
    :user => db.user,
    :password => db.password,
    :dbname => db.path[1..-1]
  set :db, conn
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
  rs = settings.db.exec("SELECT xmlagg(payload) FROM tickets")
  tickets = rs.getvalue(0,0)

  erb :tickets, :locals => {
    :self_url => url_for("/tickets", :full),
    :tickets => tickets
  }
end

# Create ticket
post '/tickets' do
  ticket_xml = prep_xml(request.body.read)
  uuid = SecureRandom.uuid
  settings.db.exec("INSERT INTO tickets (uuid, payload) VALUES ($1, XMLPARSE(CONTENT $2))", [uuid, ticket_xml])

  [201, {"Content-Location" => url_for("/tickets/#{uuid}", :full)}, '']
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
