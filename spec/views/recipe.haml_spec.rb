require File.expand_path(File.dirname(__FILE__) + '/../spec_helper' )
require 'haml'

describe "recipe.haml" do
  before(:each) do
    @title  = "Recipe Title"
    @recipe = { 'title' => @title }

    template = File.read("./views/recipe.haml")
    @engine = Haml::Engine.new(template)
  end

  it "should display the recipe's title" do
    response = @engine.render(Object.new, :@recipe => @recipe)
    response.should have_selector("h1", :content => @title)
  end
end
