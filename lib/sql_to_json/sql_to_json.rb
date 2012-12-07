require 'mysql2'
require 'json'

module SqlToJson
  class SqlToJson

    ConfigKeys = [:username, :password, :host, :port, :database, :socket, :flags]

    attr_accessor :client

    def initialize(config)

      #convert string keys to symbol keys for mysql2 client
      config_sym = config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

      #we only grab valid config keys
      db_config = config_sym.select{|k,v| ConfigKeys.include? k}

      @client = Mysql2::Client.new(db_config)
    end

    def sql_ruby(sql)
      resp = @client.query(sql)
      fmt_resp = format_response(resp)
    end

    def sql_json(sql)
      sql_r = sql_ruby(sql)
      sql_r.to_json
    end

    private
    def format_response(resp)
      fmt_resp = resp.map {|r| r}
    end
  end
end
