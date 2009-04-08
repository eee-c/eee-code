require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )

describe "wiki" do
  it "should return simple text as unaltered text" do
    wiki("bob").should contain("bob")
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

  it "should wikify kids names" do
    self.stub!(:kid_nicknames).
      and_return({"marsha" => "the oldest Brady girl"})
    wiki("[kid:marsha]").should contain("the oldest Brady girl")
  end

  it "should lookup kid nicknames in CouchDB"

  it "should wikify recipe URIs"
end
