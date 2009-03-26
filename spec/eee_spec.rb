ENV['RACK_ENV'] = 'test'

require 'eee'
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'

require 'webrat'
Spec::Runner.configure do |config|
  config.include Webrat::Matchers, :type => :views
end

describe 'GET /recipes/permalink' do
  include Sinatra::Test

  before(:all) do
    RestClient.put @@db, { }
  end

  after(:all) do
    RestClient.delete @@db
  end

  before (:each) do
    @date = Date.today
    @title = "Recipe Title"
    @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

    RestClient.put "#{@@db}/#{@permalink}",
      { :title => @title,
        :date  => @date }.to_json,
        :content_type => 'application/json'
  end

  it "should include a title" do
    get "/recipes/#{@permalink}"
    response.should be_ok
    response.should have_selector("h1", :content => @title)
  end
end
