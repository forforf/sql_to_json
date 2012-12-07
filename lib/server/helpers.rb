require 'sql_to_json'

module SqlToJson
  module Server
    module Helpers
      def connect(params, tracker, con_id)
        client = SqlToJson.new(params)
        tracker[con_id] = client
        client
      end
    end
  end
end