require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )

describe "wiki" do
  it "should return simple text as unaltered text" do
    wiki("bob").should == "bob"
  end
  it "should convert textile to HTML"
  it "should wikify temperatures"
  it "should wikify kids names"
  it "should wikify recipe URIs"
end
