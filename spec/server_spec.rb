require "rspec"
require "spec_helper"
require File.join(APP_ROOT, 'server')
require 'rack/test'
require 'psych'
require 'json'

describe 'Server App' do
  include Rack::Test::Methods

  def app
    Server
  end



  describe "/" do
    it "returns something valid" do
      get '/'
      last_response.should be_ok
    end
  end

  describe "/connection" do
    before :each do
      @config_file = "/home/dave/Projects/config_files/sql_to_json.yaml"
      @config_yaml = File.open(@config_file, 'r'){|f| f.read}
      @params =  Psych.load(@config_yaml)['test']
      @par_syms = @params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

    it "succeeds with valid parameters" do
      post '/connection', @par_syms
      resp = JSON.parse(last_response.body)
      resp.keys.should include "success"
      resp["success"].should == "client connected"
    end


  end
end