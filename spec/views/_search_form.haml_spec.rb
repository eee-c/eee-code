require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "_search_form.haml" do
  it "should display a form to refine your search" do
    render("/views/_search_form.haml")
    response.should have_selector("form",
                                  :action => "/recipes/search") do |form|
      form.should have_selector("input", :name => "q")
    end
  end
end
