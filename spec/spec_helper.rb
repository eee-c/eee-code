ENV['RACK_ENV'] = 'test'

require 'eee'
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'

require 'webrat'
require 'haml'

Spec::Runner.configure do |config|
  config.include Webrat::Matchers, :type => :views
  config.include Eee::Helpers
end

# Renders the supplied template with Haml::Engine and assigns the
# @response instance variable
def render(template_path)
  template = File.read("./#{template_path.sub(/^\//, '')}")
  engine = Haml::Engine.new(template)
  @response = engine.render(self, assigns_for_template)
end

# Convenience method to access the @response instance variable set in
# the render call
def response
  @response
end

# Sets the local variables that will be accessible in the HAML
# template
def assigns
  @assigns ||= { }
end

# Prepends the assigns keywords with an "@" so that they will be
# instance variables when the template is rendered.
def assigns_for_template
  assigns.inject({}) do |memo, kv|
    memo["@#{kv[0].to_s}".to_sym] = kv[1]
    memo
  end
end
