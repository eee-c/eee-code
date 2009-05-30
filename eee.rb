require 'rubygems'
require 'sinatra'
require 'rest_client'
require 'json'
require 'helpers'

configure :test do
  @@db = "http://localhost:5984/eee-test"
end

configure :development, :production do
  @@db = "http://localhost:5984/eee"
end

helpers do
  include Eee::Helpers
end

get %r{/meals/(\d+)/(\d+)/(\d+)} do |year, month, day|
  data = RestClient.get "#{@@db}/#{year}-#{month}-#{day}"
  @meal = JSON.parse(data)

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
