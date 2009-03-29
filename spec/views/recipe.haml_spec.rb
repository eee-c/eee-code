require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )

describe "recipe.haml" do
  before(:each) do
    @title  = "Recipe Title"
    assigns[:recipe] = @recipe = { 'title' => @title }
  end

  it "should display the recipe's title" do
    render("/views/recipe.haml")
    response.should have_selector("h1", :content => @title)
  end

  it "should render ingredient names" do
    @recipe['preparations'] =
      [  'quantity' => 1, 'ingredient' => { 'name' => 'egg' } ]

    render("views/recipe.haml")

    response.should have_selector(".preparations") do |preparations|
      preparations.
        should have_selector(".ingredient > .name", :content => 'egg')
    end
  end

  context "a recipe with no ingredient preparations" do
    before(:each) do
      @recipe[:preparations] = nil
    end

    it "should not render an ingredient preparations" do
      render("views/recipe.haml")
      response.should_not have_selector(".preparations")
    end
  end
end
