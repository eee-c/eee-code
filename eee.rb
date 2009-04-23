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

get '/recipes/search' do
  data = RestClient.get "#{@@db}/_fti?limit=20&q=#{params[:q]}"
  @results = JSON.parse(data)

  haml :search
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
