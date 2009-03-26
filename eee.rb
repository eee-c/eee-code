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

get '/recipes/:permalink' do
  data = RestClient.get "#{@@db}/#{params[:permalink]}"
  result = JSON.parse(data)

  "<h1>#{result['title']}</h1>"
end
