ENV['RACK_ENV'] = 'test'

# NOTE: This must come before the require 'webrat', otherwise
# sinatra will look in the wrong place for its views.
require File.dirname(__FILE__) + '/../../eee'

# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = File.join(File.dirname(__FILE__), *%w[.. .. eee.rb])

require 'haml'

# RSpec matchers
require 'spec/expectations'

# RSpec mocks / stubs
require 'spec/mocks'

# For easy management of design docs
require 'couch_docs'

module WebRat
  class Session
    def xml_content_type?; raise "here"; true end
  end
end


require 'rack/test'
require 'webrat'
Webrat.configure do |config|
  config.mode = :rack
end

class MyWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Sinatra::Application
  end
end

World {MyWorld.new}


Before do
  # For mocking & stubbing in Cucumber
  $rspec_mocks ||= Spec::Mocks::Space.new

  # Create the DB
  RestClient.put @@db, { }

  # Upload the design documents with a super-easy gem :)
  CouchDocs.upload_dir(@@db, 'couch')
end

After do
  begin
    $rspec_mocks.verify_all
  ensure
    $rspec_mocks.reset_all
  end

  # Delete the DB
  RestClient.delete @@db
  sleep 0.5
end
