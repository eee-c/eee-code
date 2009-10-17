#require 'pp'
require 'eee.rb'
require 'rubygems'
require 'sinatra'
require 'rack/cache'
require 'image_science'
require 'rack-rewrite'

###
# Rewrite
use Rack::Rewrite do
  r301 %r{(.+)\.html}, '$1'
  r301 %r{^/recipes/(\d{4})-(\d{2})-(\d{2})-(.+)}, '/recipes/$1/$2/$3/$4'
end

###
# Cache

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'file:/var/cache/rack/meta',
  :entitystore => 'file:/var/cache/rack/body'

###
# Thumbnail

require 'rack/thumbnailer'
use Rack::ThumbNailer

###
# Sinatra App

root_dir = File.dirname(__FILE__)

set :environment, :development
set :root,        root_dir
set :app_root,    root_dir
set :app_file,    File.join(root_dir, 'eee.rb')
disable :run

run Sinatra::Application
