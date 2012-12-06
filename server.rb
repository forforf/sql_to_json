require 'sinatra/base'

class Server < Sinatra::Base
  set :static, true
  set :root, APP_ROOT #set in config.ru

  get '/' do
    "Root - Running, but no data"
  end
end
