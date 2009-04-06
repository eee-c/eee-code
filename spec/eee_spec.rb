require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )

describe "eee" do
  include Sinatra::Test

  before(:all) do
    RestClient.put @@db, { }
  end

  after(:all) do
    RestClient.delete @@db
  end

  describe "a CouchDB recipe" do
    before (:each) do
      @date = Date.today
      @title = "Recipe Title"
      @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '-')

      RestClient.put "#{@@db}/#{@permalink}",
        { :title => @title,
          :date  => @date }.to_json,
        :content_type => 'application/json'

    end

    after(:each) do
      data = RestClient.get "#{@@db}/#{@permalink}"
      recipe = JSON.parse(data)

      RestClient.delete "#{@@db}/#{@permalink}?rev=#{recipe['_rev']}"
    end

    describe 'GET /recipes/permalink' do
      it "should respond OK" do
        get "/recipes/#{@permalink}"
        response.should be_ok
      end
    end

    describe 'GET /recipes/:permalink/:image' do
      it "should retrieve the image" do
        data = RestClient.get "#{@@db}/#{@permalink}"
        recipe = JSON.parse(data)

        RestClient.put "#{@@db}/#{@permalink}/sample.jpg?rev=#{recipe['_rev']}",
          File.read('spec/fixtures/sample.jpg'),
          :content_type => 'image/jpeg'


        lambda { get "/images/#{@permalink}/sample.jpg" }.
          should raise_error(Rack::Lint::LintError)
      end

      it "should return 404 for a non-existent image" do
        get "/images/#{@permalink}/sample2.jpg"
        response.should be_not_found
      end
    end

  end
end
