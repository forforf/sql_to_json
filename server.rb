require 'sinatra/base'
require 'sql_to_json'
require 'server/helpers'
require 'securerandom'
require 'json'
require 'pp'

#fix to allow application/json;charset=UTF-8
module Rack

  # A Rack middleware for parsing POST/PUT body data when Content-Type is
  # not one of the standard supported types, like <tt>application/json</tt>.
  #
  # TODO: Find a better name.
  #
  class PostBodyContentTypeParser

    # Constants
    #
    CONTENT_TYPE = 'CONTENT_TYPE'.freeze
    POST_BODY = 'rack.input'.freeze
    FORM_INPUT = 'rack.request.form_input'.freeze
    FORM_HASH = 'rack.request.form_hash'.freeze

    # Supported Content-Types
    #

    ################## turned into regex so it matches type with encoding data...
    #APPLICATION_JSON = 'application/json'.freeze
    APPLICATION_JSON = /^application\/json/.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      case env[CONTENT_TYPE]
        when APPLICATION_JSON
          env.update(FORM_HASH => JSON.parse(env[POST_BODY].read), FORM_INPUT => env[POST_BODY])
      end
      @app.call(env)
    end

  end
end


class Server < Sinatra::Base
  class << self; attr_accessor :connections; end
  Server.connections = {}

  use Rack::PostBodyContentTypeParser
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
    puts "Raw Params: #{params.inspect}"
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

  post '/raw_sql' do
    puts "Params: #{params.inspect}"
    sql = params[:sql]
    puts "SQL: #{sql}"
    con_id = session[:connection_id]
    client = Server.connections[con_id]
    resp = []
    begin
      resp = con_id ? client.sql_ruby(sql) : nil
      puts "Raw Sql Resp: #{resp.inspect}"
    #rescue Exception => e
    #  resp = ["Error: #{e}"]
    end
    resp = resp || [ "-- none --"]
    content_type :json
    resp.to_json


  end
end
