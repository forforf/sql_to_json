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
    begin
      con_id = session[:connection_id] ||= SecureRandom.uuid
      #connects to db and adds connection to Server.connections
      client = connect(params, Server.connections, con_id)
      message = {"success" => "client connected"}
    rescue Exception => e
      puts "Exception: #{e}"
      message = {"error" => e}
    end

    content_type :json
    message.to_json
  end
end
