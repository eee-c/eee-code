require 'rubygems'
require 'sinatra'
require 'rest_client'
require 'json'
require 'pony'
require 'rss'
require 'helpers'
require 'pp'

$: << File.expand_path(File.dirname(__FILE__) + '/lib')

require 'float'

AMAZON_ASSOCIATE_ID = "eeecooks-20"
ROOT_URL = "http://www.eeecooks.com"
DEFAULT_QUERY = "type:Recipe"

configure :test do
  @@db = "http://localhost:5984/eee-test"
end

configure :development, :production do
  @@db = "http://localhost:5984/eee"
end

helpers do
  include Eee::Helpers
end

if ENV['RACK_ENV'] != 'test'
  before do
    content_type 'text/html', :charset => 'UTF-8'
  end
end

get '/' do
  url = "#{@@db}/_design/meals/_view/by_date?limit=13&descending=true"
  data = RestClient.get url
  @meal_view = JSON.parse(data)['rows']

  @meals = @meal_view.inject([]) do |memo, couch_rec|
    data = RestClient.get "#{@@db}/#{couch_rec['id']}"
    meal = JSON.parse(data)
    memo + [meal]
  end

  @older_meals = @meals.slice!(10,3) || []

  haml :index
end

get '/main.rss' do
  content_type "application/rss+xml"

  rss_for_date_view("meals") do |rss_item, meal|
    date = Date.parse(meal['date'])
    rss_item.link = ROOT_URL + date.strftime("/meals/%Y/%m/%d")
  end
end

get '/recipes.rss' do
  content_type "application/rss+xml"

  rss_for_date_view("recipes") do |rss_item, recipe|
    rss_item.link = ROOT_URL + "/recipes/#{url_from_permalink(recipe['_id'])}"
  end
end

# get '/benchmarking' do
#   url = "#{@@db}/_design/meals/_view/by_date_short"
#   data = RestClient.get url
#   JSON.parse(data)

#   ""
# end

get %r{/meals/(\d+)/(\d+)/(\d+)} do |year, month, day|
  data = RestClient.get "#{@@db}/#{year}-#{month}-#{day}"
  @meal = JSON.parse(data)
  etag(@meal['_rev'])

  url = "#{@@db}/_design/meals/_view/by_date_short"
  data = RestClient.get url
  @meals_by_date = JSON.parse(data)['rows']

  @recipes = @meal['menu'].map { |m| wiki_recipe(m) }.compact

  @url = request.url

  @title = @meal['title'] + ' (Meal)'
  haml :meal
end

get %r{/meals/(\d+)/(\d+)} do |year, month|
  url = "#{@@db}/_design/meals/_view/by_date?" +
    "startkey=%22#{year}-#{month}-00%22&" +
    "endkey=%22#{year}-#{month}-99%22"
  data = RestClient.get url
  @meals = JSON.parse(data)['rows'].map{|r| r['value']}
  @month = "#{year}-#{month}"

  url = "#{@@db}/_design/meals/_view/count_by_month?group=true"
  data = RestClient.get url
  @count_by_year = JSON.parse(data)['rows']

  @title = "Meals from #{year}-#{month}"
  haml :meal_by_month
end

get %r{/meals/(\d+)} do |year|
  url = "#{@@db}/_design/meals/_view/by_date?" +
    "startkey=%22#{year}-00-00%22&" +
    "endkey=%22#{year}-99-99%22"
  data = RestClient.get url
  @meals = JSON.parse(data)['rows'].map{|r| r['value']}
  @year  = year

  url = "#{@@db}/_design/meals/_view/count_by_year?group=true"
  data = RestClient.get url
  @count_by_year = JSON.parse(data)['rows']

  @title = "Meals from #{year}"
  haml :meal_by_year
end

get %r{/mini/(.*)} do |date_str|
  url = "#{@@db}/_design/meals/_view/count_by_month?group=true"
  data = RestClient.get url
  @count_by_month = JSON.parse(data)['rows']
  @month = date_str == '' ? @count_by_month.last['key'] : date_str.sub(/\//, '-')

  url = "#{@@db}/_design/meals/_view/by_date_short?" +
    "startkey=%22#{@month}-00%22&" +
    "endkey=%22#{@month}-99%22"
  data = RestClient.get url
  @meals_by_date = JSON.parse(data)['rows'].inject({ }) do |memo, m|
    memo[m['value']['date']] = m['value']['title']
    memo
  end

  haml :mini_calendar, :layout => false
end

get '/recipes/search' do
  @query = params[:q] == '' ? DEFAULT_QUERY  : params[:q]
  @sort  = params[:q] == '' ? "%5Csort_date" : params[:sort]

  page = params[:page].to_i
  skip = (page < 2) ? 0 : ((page - 1) * 20)

  couchdb_url = "#{@@db.sub('eee', '_fti/local/eee')}" +
    "/_design/lucene/by_content?limit=20" +
    "&q=#{Rack::Utils.escape(@query)}" +
    "&skip=#{skip}"

  if @sort =~ /\w/
    order = params[:order] =~ /desc/ ? "%5C" : ""
    couchdb_url += "&sort=#{order}#{@sort}"
  end

  begin
    data = RestClient.get couchdb_url
    @results = JSON.parse(data)
  rescue Exception
    #puts Rack::Utils.escape(@query)
    @query = ""
    @results = { 'total_rows' => 0, 'rows' => [] }
  end

  if @results['rows'].count == 0 && page > 1
    redirect("/recipes/search?q=#{@query}")
    return
  end

  @title = "Recipes"
  haml @results['total_rows'] == 0 ? :no_results : :search
end

get %r{/recipes/(\d+)/(\d+)/(\d+)/?(.*)} do |year, month, day, short_name|
  data = RestClient.get "#{@@db}/#{year}-#{month}-#{day}-#{short_name}"
  @recipe = JSON.parse(data)
  etag(@recipe['_rev'])

  url = "#{@@db}/_design/recipes/_view/by_date_short"
  data = RestClient.get url
  @recipes_by_date = JSON.parse(data)['rows']

  @url = request.url

  @title = @recipe['title'] + ' (Recipe)'
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

get '/ingredients' do
  url = "#{@@db}/_design/recipes/_view/by_ingredients?group=true"
  data = RestClient.get url
  @ingredients = JSON.parse(data)['rows']

  @title = "Ingredient Index"

  haml :ingredients
end

get %r{^/([\-\w]+)$} do |doc_id|
  begin
    data = RestClient.get "#{@@db}/#{doc_id}"
    @doc = JSON.parse(data)
  rescue RestClient::ResourceNotFound
    pass
  end
  haml RedCloth.new(@doc['content']).to_html
end

not_found do
  haml :'404'
end

error do
  haml :'500'
end
