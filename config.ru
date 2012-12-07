require 'rubygems'
require 'bundler'

Bundler.require

require File.join(File.dirname(__FILE__), 'path_setup')

#Application server class name and paths
apps = {
  'Server' => './server'
}

#paths to additional libaries to require 
Libraries = ['sql_to_json']

libs = Libraries.map{|f| "lib/#{f}"}
require_files = ( apps.values + libs ).uniq.compact
require_files.each {|lib| require File.join(APP_ROOT, lib)}

apps.keys.each do |app_server|
  run Object.const_get(app_server)
end
