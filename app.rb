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

after do
  settings.db.finish() unless settings.db.finished?
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
get %r{/tickets/([\w\d\-]+)/comments} do
  ticket_id = params[:captures].first

  erb :comments, :locals => {
    :self_url => url_for("/ticket/#{ticket_id}/comments", :full),
    :comments => '<comment></comment>' # TODO: insert real comment(s) for ticket here
  }
end

post %r{/tickets/([\w\d\-]+)/comments} do
  ticket_id = params[:captures].first

  rs = settings.db.exec("SELECT uuid FROM tickets WHERE uuid = $1", [ticket_id])
  
  if rs.num_tuples.zero?
    [404]
  else
    comment_xml = prep_xml(request.body.read)
    uuid = SecureRandom.uuid
    settings.db.exec("INSERT INTO comments (uuid, payload) VALUES ($1, XMLPARSE(CONTENT $2))", [uuid, comment_xml])

    [201, {"Content-Location" => url_for("/tickets/#{ticket_id}/comments/#{uuid}")}, '']
  end
end

# Create a user
post '/users' do
  user_xml = prep_xml(request.body.read)
  uuid = SecureRandom.uuid
  settings.db.exec("INSERT INTO users (uuid, payload) VALUES ($1, XMLPARSE(CONTENT $2))", [uuid, user_xml])

  [201, {"Content-Location" => url_for("/users/#{uuid}", :full)}, '']
end

# Get a user
get %r{/user/([\w\d\-])+} do
  user_id = params[:captures].first

  rs = settings.db.exec("SELECT payload FROM users WHERE uuid = $1", [user_id])

  if rs.num_tuples.zero?
    [404]
  else
    user = rs.getvalue(0, 0)
    [200, user.to_s]
  end
end

# Get/search users collection
get '/users' do
  rs = settings.db.exec("SELECT xmlagg(payload) FROM users")
  users = rs.getvalue(0,0)

  erb :users, :locals => {
    :self_url => url_for("/users", :full),
    :users => users
  }
end

# Change log
get '/changes' do
  rs = settings.db.exec("SELECT xmlagg(payload) FROM changes ORDER BY created_at DESC")
  changes = rs.getvalue(0,0)

  erb :changes, :locals => {
    :self_url => url_for("/changes", :full),
    :from_iso_time => '2012-09-13T12:01:00Z', # TODO: real from time here (ISO8601)
    :to_iso_time => '2012-09-13T12:01:59Z', # TODO: real to time here (ISO8601)
    :events => changes
  }
end
