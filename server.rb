require 'sinatra/base'
require 'sql_to_json'
require 'securerandom'
require 'json'


class Server < Sinatra::Base

  @@connections = {}

  set :static, true
  set :root, APP_ROOT #set in config.ru
  enable :sessions

  helpers do
    def connect(params)
      con_id = session[:connection_id] ||= SecureRandom.uuid
      client = SqlToJson::SqlToJson.new(params)
      @@connection[con_id] = client
      client
    end
  end

  get '/' do
    "Root - Running, but no data"
  end

  post '/connection' do
    begin
      client = connect(params)
      message = {"success" => "client connected"}
    rescue Exception => e
      message = {"error" => e}
    end

    content_type :json
    message.to_json
  end
end
