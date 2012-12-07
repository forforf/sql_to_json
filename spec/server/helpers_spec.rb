require "rspec"
require "../spec_helper"
require 'server/helpers'
require 'psych'

describe "helpers" do

  describe "#connect" do

    let(:dummy_class) do
      Class.new do
        extend(SqlToJson::Server::Helpers)
      end
    end

    before :each do
      @config_file = "/home/dave/Projects/config_files/sql_to_json.yaml"
      @config_yaml = File.open(@config_file, 'r'){|f| f.read}
      @params =  Psych.load(@config_yaml)['test']
      @par_syms = @params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end


    it "tracks client per connection ids " do
      tracker = {}
      dummy_class.connect(@params, tracker, 1)
      tracker[1].should be_kind_of SqlToJson::SqlToJson
    end

  end
end