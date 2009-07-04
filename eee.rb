require 'rubygems'
require 'sinatra'
require 'rest_client'
require 'json'
require 'pony'
require 'rss'
require 'helpers'

ROOT_URL = "http://www.eeecooks.com"

configure :test do
  @@db = "http://localhost:5984/eee-test"
end

configure :development, :production do
  @@db = "http://localhost:5984/eee"
end

helpers do
  include Eee::Helpers
end

get '/' do
  url = "#{@@db}/_design/meals/_view/by_date?limit=13&descending=true"
  data = RestClient.get url
  @meal_view = JSON.parse(data)['rows']

  @meals = @meal_view.inject([]) do |memo, couch_rec|
    data = RestClient.get "#{@@db}/#{couch_rec['key']}"
    meal = JSON.parse(data)
    memo + [meal]
  end

  @older_meals = @meals.slice!(10,3) || []

  haml :index
end

get '/main.rss' do
  content_type "application/rss+xml"

  url = "#{@@db}/_design/meals/_view/by_date?limit=10&descending=true"
  data = RestClient.get url
  @meal_view = JSON.parse(data)['rows']

  rss = RSS::Maker.make("2.0") do |maker|
    maker.channel.title = "EEE Cooks: Meals"
    maker.channel.link  = ROOT_URL
    maker.channel.description = "Meals from a Family Cookbook"
    @meal_view.each do |couch_rec|
      data = RestClient.get "#{@@db}/#{couch_rec['key']}"
      meal = JSON.parse(data)
      date = Date.parse(meal['date'])
      maker.items.new_item do |item|
        item.link = ROOT_URL + date.strftime("/meals/%Y/%m/%d")
        item.title = meal['title']
        item.pubDate = Time.parse(meal['date'])
        item.description = meal['summary']
      end
    end
  end

  rss.to_s
end

get '/recipes.rss' do
  content_type "application/rss+xml"

  url = "#{@@db}/_design/recipes/_view/by_date?limit=10&descending=true"
  data = RestClient.get url
  @recipe_view = JSON.parse(data)['rows']

  rss = RSS::Maker.make("2.0") do |maker|
    maker.channel.title = "EEE Cooks: Recipes"
    maker.channel.link  = ROOT_URL
    maker.channel.description = "Recipes from a Family Cookbook"

    @recipe_view.each do |couch_rec|
      data = RestClient.get "#{@@db}/#{couch_rec['value'][0]}"
      recipe = JSON.parse(data)
      maker.items.new_item do |item|
        item.link = ROOT_URL + "/recipes/recipe['id']"
        item.title = recipe['title']
        item.pubDate = Time.parse(recipe['date'])
        item.description = recipe['summary']
      end
    end
  end

  rss.to_s
end

get %r{/meals/(\d+)/(\d+)/(\d+)} do |year, month, day|
  data = RestClient.get "#{@@db}/#{year}-#{month}-#{day}"
  @meal = JSON.parse(data)

  url = "#{@@db}/_design/meals/_view/by_date"
  data = RestClient.get url
  @meals_by_date = JSON.parse(data)['rows']

  @recipes = @meal['menu'].map { |m| wiki_recipe(m) }.compact

  @url = request.url

  haml :meal
end

get %r{/meals/(\d+)/(\d+)} do |year, month|
  url = "#{@@db}/_design/meals/_view/by_month?group=true&key=%22#{year}-#{month}%22"
  data = RestClient.get url
  @meals = JSON.parse(data)
  @month = "#{year}-#{month}"

  url = "#{@@db}/_design/meals/_view/count_by_month?group=true"
  data = RestClient.get url
  @count_by_year = JSON.parse(data)['rows']

  haml :meal_by_month
end

get %r{/meals/(\d+)} do |year|
  url = "#{@@db}/_design/meals/_view/by_year?group=true&key=%22#{year}%22"
  data = RestClient.get url
  @meals = JSON.parse(data)
  @year  = year

  url = "#{@@db}/_design/meals/_view/count_by_year?group=true"
  data = RestClient.get url
  @count_by_year = JSON.parse(data)['rows']

  haml :meal_by_year
end

get '/recipes/search' do
  @query = params[:q]

  page = params[:page].to_i
  skip = (page < 2) ? 0 : ((page - 1) * 20)

  couchdb_url = "#{@@db}/_fti?limit=20" +
    "&q=#{@query}" +
    "&skip=#{skip}"

  if params[:sort] =~ /\w/
    order = params[:order] =~ /desc/ ? "%5C" : ""
    couchdb_url += "&sort=#{order}#{params[:sort]}"
  end

  begin
    data = RestClient.get couchdb_url
    @results = JSON.parse(data)
  rescue Exception
    @query = ""
    @results = { 'total_rows' => 0, 'rows' => [] }
  end

  if @results['rows'].count == 0 && page > 1
    redirect("/recipes/search?q=#{@query}")
    return
  end

  haml @results['total_rows'] == 0 ? :no_results : :search
end

get '/recipes/:permalink' do
  data = RestClient.get "#{@@db}/#{params[:permalink]}"
  @recipe = JSON.parse(data)

  @url = request.url

  haml :recipe
end

get '/images/:permalink/:image' do
  content_type 'image/jpeg'
  begin
    RestClient.get "#{@@db}/#{params[:permalink]}/#{params[:image]}"
  rescue
    404
  end
end

get '/feedback' do
  @subject = params[:subject]
  @url = params[:url]
  haml :feedback
end

post '/email' do
  message = <<"_EOM"
From: #{params[:name]}
Email: #{params[:email]}

#{params[:message]}
_EOM

  message << "\nURL: #{params[:url]}\n" if params[:url]

  Pony.mail(:to      => "us _at_ eeecooks.com".gsub(/\s*_at_\s*/, '@'),
            :subject => params[:subject],
            :body    => message)

  haml :email
end
