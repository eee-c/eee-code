ENV['RACK_ENV'] = 'test'

require 'eee'
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'

require 'webrat'

Spec::Runner.configure do |config|
  config.include Webrat::Matchers, :type => :views
end
