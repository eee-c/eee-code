require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )

describe "wiki" do
  it "should return simple text as unaltered text" do
    wiki("bob").should contain("bob")
  end

  it "should return an empty string if called with nil" do
    wiki(nil).should == ""
  end

  it "should convert textile to HTML" do
    textile = <<_TEXTILE
paragraph 1 *bold text*

paragraph 2
_TEXTILE

    wiki(textile).
      should have_selector("p", :content => "paragraph 1 bold text") do |p|
      p.should have_selector("strong", :content => "bold text")
    end
  end

  it "should wikify temperatures" do
    wiki("250F").should contain("250° F")
  end

  context "data stored in CouchDB" do
    before(:each) do
      self.stub!(:_db).and_return("http://example.org/couchdb")
    end

    it "should lookup kid nicknames" do
      RestClient.stub!(:get).and_return('{"marsha":"the oldest Brady girl"}')
      wiki("[kid:marsha]").should contain("the oldest Brady girl")
    end

    it "should wikify recipe URIs" do
      RestClient.stub!(:get).
        and_return('{"_id":"id-123","title":"Title"}')

      wiki("[recipe:id-123]").
        should have_selector("a",
                             :href    => "/recipes/id-123",
                             :content => "Title")
    end
  end
end

describe "image_link" do
  it "should return a link tag pointing to the document's image" do
    doc = {
      '_id'          => "foo",
      '_attachments' => { 'sample.jpg' => { } }
    }

    image_link(doc).
      should have_selector("img",
                           :src => "/images/#{doc['_id']}/sample.jpg")
  end

  it "should return nil if no attachments" do
    image_link({ }).should be_nil
  end
  it "should return nil if no image attachments" do
    doc = { '_attachments' => { 'sample.txt' => { } } }
    image_link(doc).should be_nil
  end
end

describe "pagination" do
  before(:each) do
    @query = 'foo'
    @results = { 'total_rows' => 41, 'limit' => 20, 'skip' => 0}
  end
  it "should have a link to other pages" do
    pagination(@query, @results).
      should have_selector("a",
                           :content => "2",
                           :href    => "/recipes/search?q=foo&page=2")
  end
  it "should have 3 pages, when results.size > 2 * page size" do
    pagination(@query, @results).
      should have_selector("a", :content => "3")
  end
  it "should have only 2 pages, when results.size == 2 * page size" do
    @results['total_rows'] = 40
    pagination(@query, @results).
      should_not have_selector("a", :content => "3")
  end
  it "should have a link to the next page if before the last page" do
    @results['skip'] = 20
    pagination(@query, @results).
      should have_selector("a", :content => "Next »")
  end
  it "should not have a link to the next page if on the last page" do
    @results['skip'] = 40
    pagination(@query, @results).
      should have_selector("span", :content => "Next »")
  end
  it "should have a link to the previous page if past the first page" do
    @results['skip'] = 20
    pagination(@query, @results).
      should have_selector("a", :content => "« Previous")
  end
  it "should not have a link to the next page if on the first page" do
    pagination(@query, @results).
      should have_selector("span", :content => "« Previous")
  end
  it "should mark the current page" do
    pagination(@query, @results).
      should have_selector("span.current", :content => "1")
  end
end

describe "sort_link" do
  it "should link the supplied text" do
    sort_link("Foo", "sort_foo", "query", { }).
      should have_selector("a",
                           :content => "Foo")
  end
  it "should link to the query with the supplied sort field" do
    sort_link("Foo", "sort_foo", "query", { }).
      should have_selector("a",
                           :href => "/recipes/search?q=query&sort=sort_foo")
  end

  it "should link in descending order if already sorted on the sort field in ascending order" do
    results = {
      "sort_order" => [{ "field"   => "sort_foo",
                         "reverse" => false}]
    }
    sort_link("Foo", "sort_foo", "query", results).
      should have_selector("a",
                           :href => "/recipes/search?q=query&sort=sort_foo&order=desc")
  end

  it "should link in ascending order if already sorted on the sort field in descending order" do
    results = {
      "sort_order" => [{ "field"   => "sort_foo",
                         "reverse" => true}]
    }
    sort_link("Foo", "sort_foo", "query", results).
      should have_selector("a",
                           :href => "/recipes/search?q=query&sort=sort_foo")
  end
end
