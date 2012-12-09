require 'sinatra/base'
require 'sql_to_json'
require 'server/helpers'
require 'securerandom'
require 'json'


class Server < Sinatra::Base
  class << self; attr_accessor :connections; end
  Server.connections = {}

  set :static, true
  set :root, APP_ROOT #set in config.ru
  enable :sessions

  helpers do
    include SqlToJson::Server::Helpers
  end

  get '/' do
    "Root - Running, but no data"
  end

  post '/connection' do
    puts "Raw Params #{params.inspect}"
    db_params ={}
    db_params[:username] = params[:dbuser]
    db_params[:password] = params[:dbpass]
    db_params[:host] = params[:dbhost]
    db_params[:database] = params[:dbdb]
    db_params[:port] = params[:dbport]
    puts "Db params #{db_params.inspect}"
    begin
      con_id = session[:connection_id] ||= SecureRandom.uuid
      if Server.connections[con_id]
        puts "/connection: setting connection to nil"
        Server.connections[con_id] = nil
      end
      #connects to db and adds connection to Server.connections
      client = connect(db_params, Server.connections, con_id)
      me = client.sql_ruby('select user()').first
      message = {"success" => {"db_params" => db_params, "user" => me, "connection_id" => con_id}}
    rescue Exception => e
      puts "Exception: #{e}"
      message = {"error" => e}
    end

    content_type :json
    message.to_json
  end

  get '/ping' do
    con_id = session[:connection_id]
    client = Server.connections[con_id]
    message = nil
    message = client.ping ? {"success" => "true"} : {"fail" => "false"}

    content_type :json
    message.to_json
  end

  get '/databases' do
    puts "/databases"
    con_id = session[:connection_id]
    client = Server.connections[con_id]
    resp = []
    begin
      resp = con_id ? client.databases : nil
    rescue
      resp = ["-- connection error occurred --"]
    end
    resp = resp || [ "-- none --"]
    content_type :json
    resp.to_json
  end
end
