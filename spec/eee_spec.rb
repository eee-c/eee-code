require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )
require 'couch_design_docs'
require 'pp'

describe "eee" do
  before(:all) do
    RestClient.put @@db, { }
    # Upload the design documents with a super-easy gem :)
    CouchDesignDocs.upload_dir(@@db, 'couch')
  end

  after(:all) do
    RestClient.delete @@db
  end

  context "a CouchDB meal" do
    before(:each) do
      @date = Date.new(2009, 5, 13).to_s
      @title = "Meal Title"
      @permalink = @date

      @meal = {
        :title       => @title,
        :date        => @date,
        :serves      => 4,
        :summary     => "meal summary",
        :description => "meal description",
        :menu        => ["meal menu item"]
      }

      RestClient.put "#{@@db}/#{@permalink}",
        @meal.to_json,
        :content_type => 'application/json'

      RestClient.stub!(:get).and_return('{"rows": [] }')
    end

    after(:each) do
      data = RestClient.proxied_by_rspec__get "#{@@db}/#{@permalink}"
      meal = JSON.parse(data)

      RestClient.delete "#{@@db}/#{@permalink}?rev=#{meal['_rev']}"
    end

    describe "GET /" do
      it "should respond OK" do
        get "/"
        last_response.should be_ok
      end

      it "should request the most recent 13 meals from CouchDB" do
        RestClient.
          should_receive(:get).
          with(/by_date.+limit=13/).
          and_return('{"rows": [] }')

        get "/"
      end

      it "should pull back full details for the first 10 meals" do
        RestClient.
          stub!(:get).
          and_return('{"rows": [' +
                     '{"id":"2009-06-10","value":["2009-06-10","Foo"]},' +
                     '{"id":"2009-06-09","value":["2009-06-09","Foo"]},' +
                     '{"id":"2009-06-08","value":["2009-06-08","Foo"]},' +
                     '{"id":"2009-06-07","value":["2009-06-07","Foo"]},' +
                     '{"id":"2009-06-06","value":["2009-06-06","Foo"]},' +
                     '{"id":"2009-06-05","value":["2009-06-05","Foo"]},' +
                     '{"id":"2009-06-04","value":["2009-06-04","Foo"]},' +
                     '{"id":"2009-06-03","value":["2009-06-03","Foo"]},' +
                     '{"id":"2009-06-02","value":["2009-06-02","Foo"]},' +
                     '{"id":"2009-06-01","value":["2009-06-01","Foo"]},' +
                     '{"id":"2009-05-31","value":["2009-05-31","Foo"]},' +
                     '{"id":"2009-05-30","value":["2009-05-30","Foo"]},' +
                     '{"id":"2009-05-29","value":["2009-05-29","Foo"]}' +
                     ']}')

        RestClient.
          should_receive(:get).
          with(/2009-0/).
          exactly(13).times.
          and_return('{"title":"foo",' +
                      '"date":"2009-06-17",' +
                      '"summary":"foo summary",' +
                      '"menu":[]}')

        get "/"

      end
    end

    describe "GET /main.rss" do
      it "should respond OK" do
        get "/main.rss"
        last_response.should be_ok
      end

      it "should be the meals rss feed" do
        get "/main.rss"
        last_response.
          should have_selector("channel title",
                               :content => "EEE Cooks: Meals")
      end

      it "should request the 10 most recent meals from CouchDB" do
        RestClient.
          should_receive(:get).
          with(/by_date.+limit=10/).
          and_return('{"rows": [] }')

        get "/main.rss"
      end

      it "should pull back full details for the 10 meals" do
        RestClient.
          stub!(:get).
          and_return('{"rows": [' +
                     '{"id":"2009-06-10","value":["2009-06-10","Foo"]},' +
                     '{"id":"2009-06-09","value":["2009-06-09","Foo"]},' +
                     '{"id":"2009-06-08","value":["2009-06-08","Foo"]},' +
                     '{"id":"2009-06-07","value":["2009-06-07","Foo"]},' +
                     '{"id":"2009-06-06","value":["2009-06-06","Foo"]},' +
                     '{"id":"2009-06-05","value":["2009-06-05","Foo"]},' +
                     '{"id":"2009-06-04","value":["2009-06-04","Foo"]},' +
                     '{"id":"2009-06-03","value":["2009-06-03","Foo"]},' +
                     '{"id":"2009-06-02","value":["2009-06-02","Foo"]},' +
                     '{"id":"2009-06-01","value":["2009-06-01","Foo"]}' +
                     ']}')

        RestClient.
          should_receive(:get).
          with(/2009-06-/).
          exactly(10).times.
          and_return('{"title":"foo",' +
                      '"date":"2009-06-17",' +
                      '"summary":"foo summary",' +
                      '"menu":[]}')

        get "/main.rss"
      end
    end


    describe "GET /meals/YYYY" do
      it "should respond OK" do
        get "/meals/2009"
        last_response.should be_ok
      end

      it "should ask CouchDB for meal from year YYYY" do
        RestClient.
          should_receive(:get).
          with(%r{by_date.+startkey=.+2009-00-00.+endkey=.+2009-99-99}).
          and_return('{"rows": [] }')

        get "/meals/2009"
      end

      it "should ask CouchDB how many meals from all years" do
        RestClient.
          should_receive(:get).
          with(/meals.+count_by_year/).
          and_return('{"rows": [{"key":"2008","value":3},
                                {"key":"2009","value":3}]}')

        get "/meals/2009"
      end
    end

    describe "GET /meals/YYYY/MM" do
      it "should respond OK" do
        get "/meals/2009/05"
        last_response.should be_ok
      end

      it "should ask CouchDB for meals from year YYYY and month MM" do
        RestClient.
          should_receive(:get).
          with(%r{by_date.+startkey=.+2009-05-00.+endkey=.+2009-05-99}).
          and_return('{"rows": [] }')

        get "/meals/2009/05"
      end

      it "should ask CouchDB how many meals from all months" do
        RestClient.
          should_receive(:get).
          with(/meals.+count_by_month/).
          and_return('{"rows": [{"key":"2009-04","value":3},
                                {"key":"2009-05","value":3}]}')

        get "/meals/2009/05"
      end
    end

    describe "GET /meals/YYYY/MM/DD" do
      before(:each) do
        RestClient.
          stub!(:get).
          and_return(@meal.to_json)
      end

      it "should respond OK" do
        RestClient.
          should_receive(:get).
          with(/by_date/).
          and_return('{"rows": [] }')

        get "/meals/2009/05/13"
        last_response.should be_ok
      end

      it "should request the meal from CouchDB" do
        RestClient.
          should_receive(:get).
          with(/by_date/).
          and_return('{"rows": [] }')

        RestClient.
          should_receive(:get).
          with(/2009-05-13/).
          and_return(@meal.to_json)

        get "/meals/2009/05/13"
      end
    end
  end

  context "cached documents" do
    describe 'GET /meals/2009/09/25' do
      it "should etag with the CouchDB document's revision" do
        RestClient.
          should_receive(:get).
          once.
          and_return('{"_rev":1234}')

        get "/meals/2009/09/25", { }, { 'HTTP_IF_NONE_MATCH' => '"1234"' }
      end
    end
    describe 'GET /recipes/YYYY/MM/DD/short_name' do
      it "should etag with the CouchDB document's revision" do
        RestClient.
          should_receive(:get).
          once.
          and_return('{"_rev":1234}')

        get "/recipes/2009/10/14", { }, { 'HTTP_IF_NONE_MATCH' => '"1234"' }
      end
    end
  end

  describe "a CouchDB recipe" do
    before (:each) do
      @date = Date.today
      @title = "Recipe Title"
      @permalink = @date.to_s + "-" + @title.downcase.gsub(/\W/, '_')

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

    describe 'GET /recipes/YYYY/MM/DD/short_name' do
      it "should respond OK" do
        get "/recipes/#{@permalink.gsub(/-/, '/')}"
        last_response.should be_ok
      end
    end

    describe 'GET /recipes/:permalink/:image' do
      it "should retrieve the image" do
        data = RestClient.get "#{@@db}/#{@permalink}"
        recipe = JSON.parse(data)

        RestClient.put "#{@@db}/#{@permalink}/sample.jpg?rev=#{recipe['_rev']}",
        File.read('spec/fixtures/sample.jpg'),
        :content_type => 'image/jpeg'

        get "/images/#{@permalink}/sample.jpg"
        last_response.should be_ok
      end

      it "should return 404 for a non-existent image" do
        get "/images/#{@permalink}/sample2.jpg"
        last_response.should be_not_found
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
        with(/q=title%3Aeggs/).
        and_return('{"total_rows":1,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=title:eggs"
    end

    it "should search for all docs of type recipe when given an empty string" do
      RestClient.should_receive(:get).
        with(/q=type%3ARecipe/).
        and_return('{"total_rows":1,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q="
    end

    it "should sort by date when given an empty string" do
      RestClient.should_receive(:get).
        with(/sort_date/).
        and_return('{"total_rows":1,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q="
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

    it "should be able to search multiple terms" do
      RestClient.should_receive(:get).
        with(/q=foo\+bar/).
        and_return('{"total_rows":30,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=foo+bar"
    end

    it "should display a helpful message when no results" do
      RestClient.stub!(:get).
        and_return('{"total_rows":0,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=title:egg"

      last_response.should contain("No results")
    end

    it "should redirect without pagination after navigating beyond the pagination window" do
      RestClient.stub!(:get).
        and_return('{"total_rows":1,"skip":0,"limit":20,"rows":[]}')

      get "/recipes/search?q=egg&page=2"

      last_response.status.should == 302
      last_response.headers["Location"].should == "/recipes/search?q=egg"
    end

    it "should treat couchdb errors as no-results" do
      RestClient.stub!(:get).
        and_raise(Exception)

      get "/recipes/search?q=title:egg"

      last_response.should contain("No results")
    end

    it "should treat couchdb-lucene errors as an empty query" do
      RestClient.stub!(:get).
        and_raise(Exception)

      get "/recipes/search?q=title:egg"

      last_response.should have_selector("input[@name=q][@value='']")
    end
  end

  describe "GET /feedback" do
    it "should respond OK" do
      get "/feedback"
      last_response.should be_ok
    end
  end

  describe "POST /email" do
    before(:each) do
      Pony.stub!(:mail)
    end

    it "should respond OK" do
      post "/email"
      last_response.should be_ok
    end

    it "should send us an email" do
      Pony.
        should_receive(:mail).
        with(hash_including(:subject => "Subject"))

      post "/email",
        :name    => "Bob",
        :subject => "Subject",
        :message => "Feedback message."
    end

    it "should include the email, name and message in the email" do
      message = <<"_EOM"
From: from
Email: email

Message
_EOM

      Pony.
        should_receive(:mail).
        with(hash_including(:body => message))

      post "/email",
        :name    => "from",
        :email   => "email",
        :subject => "Subject",
        :message => "Message"
    end

    it "should include the URL (if supplied) in the email" do
      message = <<"_EOM"
From: from
Email: email

Message

URL: http://example.org/
_EOM

      Pony.
        should_receive(:mail).
        with(hash_including(:body => message))

      post "/email",
        :name    => "from",
        :email   => "email",
        :subject => "Subject",
        :message => "Message",
        :url     => "http://example.org/"
    end
  end
end

describe "GET /recipe.rss" do
  before(:each) do
    RestClient.stub!(:get).and_return('{"rows": [] }')
  end

  it "should respond OK" do
    get "/recipes.rss"
    last_response.should be_ok
  end

  it "should be the meals rss feed" do
    get "/recipes.rss"
    last_response.
      should have_selector("channel title",
                           :content => "EEE Cooks: Recipes")
  end

  it "should request the 10 most recent meals from CouchDB" do
    RestClient.
      should_receive(:get).
      with(/by_date.+limit=10/).
      and_return('{"rows": [] }')

    get "/recipes.rss"
  end

  it "should pull back full details for the 10 meals" do
    RestClient.
      stub!(:get).
      and_return('{"rows": [' +
                 '{"id":"2009-06-10","value":["2009-06-10","Foo"]},' +
                 '{"id":"2009-06-09","value":["2009-06-09","Foo"]},' +
                 '{"id":"2009-06-08","value":["2009-06-08","Foo"]},' +
                 '{"id":"2009-06-07","value":["2009-06-07","Foo"]},' +
                 '{"id":"2009-06-06","value":["2009-06-06","Foo"]},' +
                 '{"id":"2009-06-05","value":["2009-06-05","Foo"]},' +
                 '{"id":"2009-06-04","value":["2009-06-04","Foo"]},' +
                 '{"id":"2009-06-03","value":["2009-06-03","Foo"]},' +
                 '{"id":"2009-06-02","value":["2009-06-02","Foo"]},' +
                 '{"id":"2009-06-01","value":["2009-06-01","Foo"]}' +
                 ']}')

    RestClient.
      should_receive(:get).
      with(/2009-06-/).
      exactly(10).times.
      and_return('{"_id":"2009-06-17-foo",' +
                  '"title":"foo",' +
                  '"date":"2009-06-17",' +
                  '"summary":"foo summary",' +
                  '"menu":[]}')

    get "/recipes.rss"
  end
end

context "/mini" do
  describe "GET /mini/" do
    before(:each) do
      RestClient.
        stub!(:get).
        with(/count_by_month/).
        and_return('{"rows": [{"key":"2009-08","value":3}]}')

      RestClient.
        stub!(:get).
        with(/by_date_short/).
        and_return('{ "rows": [{"value":{"date": "2009-08-08", "title": "Foo"}}] }')
    end

    it "should respond OK" do
      get "/mini/"
      last_response.should be_ok
    end

    it "should retrieve the most recent month with a meal" do
      RestClient.
        should_receive(:get).
        with(/meals.+count_by_month/).
        and_return('{"rows": [{"key":"2009-08","value":3}]}')

      get "/mini/"
    end

    it "should display the month" do
      get "/mini/"
      last_response.
        should have_selector("h1", :content => "August 2009")
    end

    it "should display requested month" do
      get "/mini/2009/07"
      last_response.
        should have_selector("h1", :content => "July 2009")
    end
  end
end

describe "GET /foo-bar" do
  context "without an associated CouchDB document" do
    it "should not be found" do
      get "/foo-bar"
      last_response.status.should == 404
    end
  end

  context "with an associated CouchDB document" do
    before(:each) do
      RestClient.
        stub!(:get).
        and_return('{"content":"*bar*"}')
    end

    it "should be found" do
      get "/foo-bar"
      last_response.should be_ok
    end

    it "should convert textile in the CouchDB doc to HTML" do
      get "/foo-bar"
      last_response.
        should have_selector("strong", :content => "bar")
    end

    it "should insert the document into the normal site layout" do
      get "/foo-bar"
      last_response.
        should have_selector("title", :content => "EEE Cooks")
    end
  end
end

describe "GET /ingredients" do
  before(:each) do
    RestClient.
      stub!(:get).
      and_return('{"rows": [] }')
  end

  it "should respond OK" do
    get "/ingredients"
    last_response.should be_ok
  end

  it "should ask CouchDB for a list of ingredients" do
    RestClient.
      should_receive(:get).
      with(%r{by_ingredients}).
      and_return('{"rows": [] }')

    get "/ingredients"
  end

  it "should be named \"Ingredient Index\"" do
    get "/ingredients"
    last_response.
      should have_selector("title", :content => "EEE Cooks: Ingredient Index")
  end
end
