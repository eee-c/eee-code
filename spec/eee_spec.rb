require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )

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
