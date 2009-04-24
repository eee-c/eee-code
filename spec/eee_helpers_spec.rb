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
  it "should have a link to other pages" do
    pagination(0, 20, 41).
      should have_selector("a", :content => "2")
  end
  it "should have 3 pages, when results.size > 2 * page size" do
    pagination(0, 20, 41).
      should have_selector("a", :content => "3")
  end
  it "should have only 2 pages, when results.size == 2 * page size" do
    pagination(0, 20, 40).
      should_not have_selector("a", :content => "3")
  end
end
