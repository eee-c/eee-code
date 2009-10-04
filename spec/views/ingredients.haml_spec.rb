require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "ingredients.haml" do
  before(:each) do
    @ingredients = [{ 'key' => 'butter',
                      'value' =>
                      [
                       ['recipe-id-1', 'title 1'],
                       ['recipe-id-2', 'title 2']
                      ]
                    },
                    { 'key' => 'sugar',
                      'value' =>
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

  it "should link to the recipes" do
    render("/views/ingredients.haml")
    response.should have_selector("a", :count => 3)
  end

  it "should put half of the ingredients in the first column" do
    render("/views/ingredients.haml")
    response.should have_selector(".col1", :content => "butter")
  end

  it "should put the other half of the ingredients in the second column" do
    render("/views/ingredients.haml")
    response.should have_selector(".col2", :content => "sugar")
  end

  context "an ingredient is used in only one recipe" do
    it "should have one link to that recipe" do
      render("/views/ingredients.haml")
      response.should have_selector("a",
                                    :href => "/recipes/recipe-id-1",
                                    :content => "title 1",
                                    :count => 1)
    end
  end

  context "an ingredient is used in multiple recipes" do
    it "should have multiple links to that recipe" do
      render("/views/ingredients.haml")
      response.should have_selector("a",
                                    :href => "/recipes/recipe-id-2",
                                    :content => "title 2",
                                    :count => 2)
    end
  end
end
