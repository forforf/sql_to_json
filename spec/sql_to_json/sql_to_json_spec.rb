require "rspec"
require "../spec_helper"
require 'sql_to_json'
require 'psych'

describe "Config" do
  it "can find and parse config file" do
    config_file = "/home/dave/Projects/config_files/sql_to_json.yaml"
    File.exists?(config_file).should be_true
  end
end

describe SqlToJson::SqlToJson do

  before :each do
    @config_file = "/home/dave/Projects/config_files/sql_to_json.yaml"
    @config_yaml = File.open(@config_file, 'r'){|f| f.read}
    @db_config =  Psych.load(@config_yaml)['test']
  end



  describe "#initialize" do
    it "connects to the database" do

      expect{ SqlToJson::SqlToJson.new(@db_config)}.to_not raise_error
    end
  end

  describe "#sql_ruby" do
    before :each do
      @sqlj = SqlToJson::SqlToJson.new(@db_config)
    end
    it "returns ruby objects" do
      resp = @sqlj.sql_ruby('show tables')
      resp.should be_kind_of Array
      resp.each do |r|
        r.should be_kind_of Hash
      end
    end

    it "returns json" do
      resp = @sqlj.sql_json('show tables')
      expect{ JSON.parse(resp)}.to_not raise_error
    end
  end
end