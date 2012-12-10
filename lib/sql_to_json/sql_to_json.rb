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

      #must include host parameter
      if db_config[:host].nil? || db_config[:host].strip.empty?
        raise_msg = "Host parameter required #{db_config.inspect}"
        raise ArgumentError, raise_msg
      end

      db_config[:port] = db_config[:port].to_i if db_config[:port]
      @client = Mysql2::Client.new(db_config)
    end

    def databases(fmt=nil)
      sql_resp = sql_ruby("show databases")
      dbs = sql_resp.map {|r| r.values.first }
      resp = fmt == :json ? dbs.to_json : dbs
    end

    def tables(dbname, fmt=nil)
      return ["-- unknown database: #{dbname} --"] if dbname.nil? || dbname.empty?
      sql_ruby( "use #{dbname}" )
      tables = sql_ruby( "show tables")
      resp = fmt == :json ? tables.to_json : tables
    end

    def sql_ruby(sql)
      resp = @client.query(sql)
      fmt_resp = format_response(resp)
    end

    def sql_json(sql)
      sql_r = sql_ruby(sql)
      sql_r.to_json
    end

    def ping
      ping = nil
      begin
        ping = sql_ruby('show tables')
      rescue
        ping = nil
      end
      ping ? true : false
    end

    private
    def format_response(resp)
      if resp.respond_to? :map
        fmt_resp = resp.map {|r| r}
      else
        fmt_resp = resp
      end
    end
  end
end
