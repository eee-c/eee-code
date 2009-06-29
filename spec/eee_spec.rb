require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )
require 'pp'

describe "eee" do
  before(:all) do
    RestClient.put @@db, { }
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
                     '{"key":"2009-06-10","value":["2009-06-10","Foo"]},' +
                     '{"key":"2009-06-09","value":["2009-06-09","Foo"]},' +
                     '{"key":"2009-06-08","value":["2009-06-08","Foo"]},' +
                     '{"key":"2009-06-07","value":["2009-06-07","Foo"]},' +
                     '{"key":"2009-06-06","value":["2009-06-06","Foo"]},' +
                     '{"key":"2009-06-05","value":["2009-06-05","Foo"]},' +
                     '{"key":"2009-06-04","value":["2009-06-04","Foo"]},' +
                     '{"key":"2009-06-03","value":["2009-06-03","Foo"]},' +
                     '{"key":"2009-06-02","value":["2009-06-02","Foo"]},' +
                     '{"key":"2009-06-01","value":["2009-06-01","Foo"]},' +
                     '{"key":"2009-05-31","value":["2009-05-31","Foo"]},' +
                     '{"key":"2009-05-30","value":["2009-05-30","Foo"]},' +
                     '{"key":"2009-05-29","value":["2009-05-29","Foo"]}' +
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

    describe "GET /meals/YYYY" do
      it "should respond OK" do
        get "/meals/2009"
        last_response.should be_ok
      end

      it "should ask CouchDB for meal from year YYYY" do
        RestClient.
          should_receive(:get).
          with(/key=...2009/).
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

      it "should ask CouchDB for meal from year YYYY and month MM" do
        RestClient.
          should_receive(:get).
          with(/key=...2009-05/).
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

      last_response.should have_selector("input[@name=query][@value='']")
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
