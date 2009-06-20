require File.expand_path(File.dirname(__FILE__) + '/spec_helper' )

describe "categories" do
  it "should link to the italian category" do
    categories({}).
      should have_selector("#eee-categories a", :content => "Italian")
  end
  it "should be able to highlight the link to the italian category" do
    categories({'tag_names' => %w{italian}}).
      should have_selector("#eee-categories a", :content => "Italian")
  end
  it "should link to the fish category" do
    categories({}).
      should have_selector("#eee-categories a", :content => "Fish")
  end
  it "should link to the vegetarian category" do
    categories({}).
      should have_selector("#eee-categories a", :content => "Vegetarian")
  end
  it "should link to all recipes" do
    categories({}).
      should have_selector("#eee-categories a", :content => "Recipes")
  end
end

describe "recipe_category_link" do
  it "should create an active link if the recipe includes the category" do
    recipe_category_link({'tag_names' => ['italian']}, 'Italian').
      should have_selector("a", :class => "active")
  end
  it "should create an active link if any recipes include the category" do
    recipes = [{ 'tag_names' => ['italian'] },
               { 'tag_names' => ['foo'] }]
    recipe_category_link(recipes, 'Italian').
      should have_selector("a", :class => "active")
  end
  it "should link to the category search results" do
    recipe_category_link({}, "Italian").
      should have_selector("a",
                           :href => "/recipes/search?q=category:italian")
  end
end

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

    it "should wikify recipe URIs, using supplied text for the link" do
      RestClient.stub!(:get).
        and_return('{"_id":"id-123","title":"Title"}')

      wiki("[recipe:id-123 Different Title]").
        should have_selector("a",
                             :href    => "/recipes/id-123",
                             :content => "Different Title")
    end
  end
end

describe "wiki_recipe" do
  before(:each) do
    @json = '{"_id":"2009-06-16-recipe","title":"Recipe for Foo"}'
  end
  it "should lookup a recipe from recipe wiki text" do
    RestClient.
      should_receive(:get).
      with(/2009-06-16/).
      and_return(@json)

    wiki_recipe(" [recipe:2009/06/16]")
  end
  it "should return a recipe from recipe wiki text" do
    RestClient.
      stub!(:get).
      and_return(@json)

    wiki_recipe(" [recipe:2009/06/16]").
      should == { "_id" => "2009-06-16-recipe",
                  "title" => "Recipe for Foo" }

  end
  it "should return nil for non-recipe wiki text" do
    wiki_recipe("[rcip:2009/06/16]").should be_nil
  end
end

describe "recipe_link" do
  before(:each) do
    @json = '{"_id":"2009-06-11-recipe","title":"Recipe for Foo"}'
    RestClient.
      stub!(:get).
      and_return(@json)
  end
  it "should link to recipe resource" do
    recipe_link("2009-06-11-recipe").
      should have_selector("a",
                           :href => "/recipes/2009-06-11-recipe")
  end
  it "should be able to link with \"slash\" dates (e.g. 2009/06/11/recipe)" do
    RestClient.
      should_receive(:get).
      with(/2009-06-11-recipe/).
      and_return(@json)

    recipe_link("2009/06/11/recipe")
  end
end


describe "image_link" do
  context do
    before(:each) do
      @doc = {
        '_id'          => "foo",
        '_attachments' => { 'sample.jpg' => { } }
      }
    end
    it "should return a link tag pointing to the document's image" do
      image_link(@doc).
        should have_selector("img",
                             :src => "/images/#{@doc['_id']}/sample.jpg")
    end
    it "should include image attributes" do
      image_link(@doc, :alt => "foo").
        should have_selector("img", :alt => "foo")
    end
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
  before(:each) do
    @query = 'foo'
    @results = { 'total_rows' => 41, 'limit' => 20, 'skip' => 0}
  end
  it "should have a link to other pages" do
    pagination(@query, @results).
      should have_selector("a",
                           :content => "2",
                           :href    => "/recipes/search?q=foo&page=2")
  end
  it "should have 3 pages, when results.size > 2 * page size" do
    pagination(@query, @results).
      should have_selector("a", :content => "3")
  end
  it "should have only 2 pages, when results.size == 2 * page size" do
    @results['total_rows'] = 40
    pagination(@query, @results).
      should_not have_selector("a", :content => "3")
  end
  it "should have a link to the next page if before the last page" do
    @results['skip'] = 20
    pagination(@query, @results).
      should have_selector("a", :content => "Next »")
  end
  it "should not have a link to the next page if on the last page" do
    @results['skip'] = 40
    pagination(@query, @results).
      should have_selector("span", :content => "Next »")
  end
  it "should have a link to the previous page if past the first page" do
    @results['skip'] = 20
    pagination(@query, @results).
      should have_selector("a", :content => "« Previous")
  end
  it "should not have a link to the next page if on the first page" do
    pagination(@query, @results).
      should have_selector("span", :content => "« Previous")
  end
  it "should mark the current page" do
    pagination(@query, @results).
      should have_selector("span.current", :content => "1")
  end
  context "with sorting applied" do
    before(:each) do
      @results["sort_order"] = [{ "field"   => "sort_foo",
                                  "reverse" => false}]
    end
    it "should have a link to other pages with sorting applied" do
      pagination(@query, @results).
        should have_selector("a",
                             :content => "2",
                             :href    => "/recipes/search?q=foo&sort=sort_foo&page=2")
    end
    it "should have a link to other pages with reverse sorting applied" do
      @results["sort_order"].first["reverse"] = true
      pagination(@query, @results).
        should have_selector("a",
                             :content => "2",
                             :href    => "/recipes/search?q=foo&sort=sort_foo&order=desc&page=2")
    end
  end
end

describe "sort_link" do
  before(:each) do
    @current_results = { }
  end

  it "should link the supplied text" do
    sort_link("Foo", "sort_foo", @current_results, :query => "query").
      should have_selector("a",
                           :content => "Foo")
  end
  it "should link to the query with the supplied sort field" do
    sort_link("Foo", "sort_foo", @current_results, :query => "query").
      should have_selector("a",
                           :href => "/recipes/search?q=query&sort=sort_foo")
  end

  it "should link in descending order if already sorted on the sort field in ascending order" do
    @current_results["sort_order"] =
      [{ "field"   => "sort_foo",
         "reverse" => false }]

    sort_link("Foo", "sort_foo", @current_results, :query => "query").
      should have_selector("a",
                           :href => "/recipes/search?q=query&sort=sort_foo&order=desc")
  end

  it "should link in ascending order if already sorted on the sort field in descending order" do
    @current_results["sort_order"] =
      [{ "field"   => "sort_foo",
         "reverse" => true }]

    sort_link("Foo", "sort_foo", @current_results, :query => "query").
      should have_selector("a",
                           :href => "/recipes/search?q=query&sort=sort_foo")
  end

  it "should link to descending sort if instructed to reverse" do
    sort_link("Foo",
              "sort_foo",
              @current_results,
              :query => "query",
              :reverse => true).
      should have_selector("a",
                           :href => "/recipes/search?q=query&sort=sort_foo&order=desc")
  end

end

describe "link_to_adjacent_view_date" do
  context "couchdb view by_year" do
    before(:each) do
      @count_by_year = [{"key" => "2008", "value" => 3},
                        {"key" => "2009", "value" => 3}]
    end
    it "should link to the next year after the current one" do
      link_to_adjacent_view_date(2008, @count_by_year).
        should have_selector("a",
                             :href => "/meals/2009")
    end
    it "should link to the previous before the current one" do
      link_to_adjacent_view_date(2009, @count_by_year, :previous => true).
        should have_selector("a",
                             :href => "/meals/2008")
    end
    it "should return empty if there are no more years" do
      link_to_adjacent_view_date(2009, @count_by_year).
        should == ""
    end
  end
  context "couchdb view by_month" do
    before(:each) do
      @count_by_month = [{"key" => "2009-04", "value" => 3},
                         {"key" => "2009-05", "value" => 3}]
    end
    it "should link to the next month after the current one" do
      link_to_adjacent_view_date("2009-04", @count_by_month).
        should have_selector("a",
                             :href => "/meals/2009/05")
    end
    it "should link to block text, if supplied" do
      link_to_adjacent_view_date("2009-04", @count_by_month) do
        "foo"
      end.
        should have_selector("a",
                             :href    => "/meals/2009/05",
                             :content => "foo")
    end
    it "should link to the CouchDB view's key and value, if block is given" do
      link_to_adjacent_view_date("2009-04", @count_by_month) do |date, value|
        "foo #{date} bar #{value} baz"
      end.
        should have_selector("a",
                             :href    => "/meals/2009/05",
                             :content => "foo 2009-05 bar 3 baz")
    end
  end
end

describe "month_text" do
  it "should increase readability of an ISO8601 date fragment" do
    month_text("2009-05").
      should == "May 2009"
  end
end

describe "breadcrumbs" do
  context "for a year (list of meals in a year)" do
    it "should link home" do
      breadcrumbs(Date.new(2009, 6, 2), :year).
        should have_selector("a", :href => "/")
    end
    it "should show the year" do
      breadcrumbs(Date.new(2009, 6, 2), :year).
        should have_selector("span", :content => "2009")
    end
  end
  context "for a month (list of meals in a month)" do
    it "should link home" do
      breadcrumbs(Date.new(2009, 6, 2), :month).
        should have_selector("a", :href => "/")
    end
    it "should link to the year" do
      breadcrumbs(Date.new(2009, 6, 2), :month).
        should have_selector("a", :href => "/meals/2009")
    end
    it "should show the month" do
      breadcrumbs(Date.new(2009, 6, 2), :month).
        should have_selector("span", :content => "June")
    end
  end
  context "for a day (show a single meal)" do
    it "should link home" do
      breadcrumbs(Date.new(2009, 6, 2), :day).
        should have_selector("a", :href => "/")
    end
    it "should link to the year" do
      breadcrumbs(Date.new(2009, 6, 2), :day).
        should have_selector("a", :href => "/meals/2009")
    end
    it "should link to the month" do
      breadcrumbs(Date.new(2009, 6, 2), :day).
        should have_selector("a", :href => "/meals/2009/06")
    end
    it "should show the day" do
      breadcrumbs(Date.new(2009, 6, 2), :day).
        should have_selector("span", :content => "2")
    end
  end
  context "for a recipe" do
    it "should link home" do
      breadcrumbs(Date.new(2009, 6, 2)).
        should have_selector("a", :href => "/")
    end
    it "should link to the year" do
      breadcrumbs(Date.new(2009, 6, 2)).
        should have_selector("a", :href => "/meals/2009")
    end
    it "should link to the month" do
      breadcrumbs(Date.new(2009, 6, 2)).
        should have_selector("a", :href => "/meals/2009/06")
    end

    it "should link to the day" do
      breadcrumbs(Date.new(2009, 6, 2)).
        should have_selector("a", :href => "/meals/2009/06/02")
    end
  end
end
