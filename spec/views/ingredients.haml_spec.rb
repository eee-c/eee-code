require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "ingredients.haml" do
  before(:each) do
    @ingredients = [{'butter' =>
                      [
                       ['recipe-id-1', 'title 1'],
                       ['recipe-id-2', 'title 2']
                      ]
                    },
                    {'sugar' =>
                      [
                       ['recipe-id-2', 'title 2']
                      ]
                    }]
  end

  it "should have a list of ingredients" do
    render("/views/ingredients.haml")
    response.should have_selector("p .ingredient", :count => 2)
  end

  it "should have a list of recipes using the ingredients" do
    render("/views/ingredients.haml")
    response.should have_selector("p", :content => 'title 1, title 2')
  end
end
