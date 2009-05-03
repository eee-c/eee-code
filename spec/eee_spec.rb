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

  describe "GET /recipes/search" do
    before(:each) do
      self.stub!(:render)
    end

    it "should retrieve search results from couchdb-lucene" do
      RestClient.should_receive(:get).
        with(/_fti\?.*q=eggs/).
        and_return('{"total_rows":1,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=eggs"
    end

    it "should not include the \"all\" field when performing fielded searches" do
      RestClient.should_receive(:get).
        with(/q=title:eggs/).
        and_return('{"total_rows":1,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=title:eggs"
    end

    it "should have page sizes of 20 records" do
      RestClient.should_receive(:get).
        with(/limit=20/).
        and_return('{"total_rows":1,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=title:eggs"
    end

    it "should paginate" do
      RestClient.should_receive(:get).
        with(/skip=20/).
        and_return('{"total_rows":30,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=title:eggs&page=2"
    end

    it "should display page 1 when passing a bad page number" do
      RestClient.should_receive(:get).
        with(/skip=0/).
        and_return('{"total_rows":30,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=title:eggs&page=foo"
    end

    it "should sort" do
      RestClient.should_receive(:get).
        with(/sort=title/).
        and_return('{"total_rows":30,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=title:egg&sort=title"
    end

    it "should not sort when no sort field is supplied" do
      RestClient.stub!(:get).
        and_return('{"total_rows":30,"skip":0,"limit":20,"rows":[]}')

      RestClient.should_not_receive(:get).with(/sort=/)

      get "/recipes/search?q=title:egg&sort="
    end

    it "should reverse sort when order=desc is supplied" do
      RestClient.stub!(:get).
        and_return('{"total_rows":30,"skip":0,"limit":20,"rows":[]}')

      RestClient.should_receive(:get).with(/sort=%5C/)

      get "/recipes/search?q=title:egg&sort=sort_foo&order=desc"
    end

  end
end
