require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "email.haml" do
  it "should say thanks for the feedback" do
    render("/views/email.haml")
    response.should have_selector("h1",
                                  :content => "Thank You")
  end
end
