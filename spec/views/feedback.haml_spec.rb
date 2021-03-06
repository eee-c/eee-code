require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "feedback.haml" do
  it "should include a field for the user's name" do
    render("/views/feedback.haml")
    response.should have_selector("label",
                                  :content => "Name")
  end
  it "should include a field for the user's email" do
    render("/views/feedback.haml")
    response.should have_selector("label",
                                  :content => "Email")
  end
  it "should include a field for a subject of the feedback" do
    render("/views/feedback.haml")
    response.should have_selector("label",
                                  :content => "Subject")
  end
  it "should include a field for the message" do
    render("/views/feedback.haml")
    response.should have_selector("label",
                                  :content => "Message")
  end

  it "should pre-fill the subject if supplied" do
    @subject = "Subject"
    render("/views/feedback.haml")
    response.should have_selector("input",
                                  :value => "Subject")
  end

  it "should pre-fill the url if supplied" do
    @url = "http://example.org/foo"
    render("/views/feedback.haml")
    response.should have_selector("input",
                                  :value => "http://example.org/foo")
  end
end
