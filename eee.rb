require 'rubygems'
require 'sinatra'
require 'rest_client'
require 'json'

configure :test do
  @@db = "http://localhost:5984/eee-test"
end

configure :development, :production do
  @@db = "http://localhost:5984/eee"
end

helpers do
end

def hours(minutes)
  h = minutes.to_i / 60
  m = minutes.to_i % 60
  h > 0 ? "#{h} hours" : "#{m} minutes"
end


get '/recipes/:permalink' do
  data = RestClient.get "#{@@db}/#{params[:permalink]}"
  @recipe = JSON.parse(data)

  haml :recipe
end
