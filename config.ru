#require 'pp'
require 'eee.rb'
require 'rubygems'
require 'sinatra'


module Rack
  class Interstitial
    def initialize app
      @app = app
    end

    def call env
      session = env["rack.session"]
      session[:count] = session[:count].to_i + 1
      if session[:count] % 5 == 0
        return [200, { }, session[:count].to_s]
      end
      code, headers, body = @app.call env
      if session[:count] % 3 == 0
        ret = []
        body.each do |line|
          ret << line.gsub(/grits/i, '<span style="color:red">fizz</span>')
        end
      else
        ret = body
      end
      [code, headers, ret]
    end
  end
end


#use Rack::Session::Cookie

#use Rack::Interstitial

root_dir = File.dirname(__FILE__)

set :environment, :development
set :root,        root_dir
set :app_root,    root_dir
set :app_file,    File.join(root_dir, 'eee.rb')
disable :run

run Sinatra::Application
