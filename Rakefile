task :default => [:test]

desc "Run all tests"
task :test => [:app_specs, :helper_specs, :view_specs]

desc "Run the sinatra app specs"
task :app_specs do
  $stderr.puts "\n==\nSinatra app spec"
  system("spec", "./spec/eee_spec.rb")
end

desc "Run the helper specs"
task :helper_specs do
  $stderr.puts "\n==\nHelper specs"
  system("spec", "./spec/eee_helpers_spec.rb")
end

desc "Run the view specs"
task :view_specs do
  $stderr.puts "\n==\nView specs"
  system("spec ./spec/views/*.haml_spec.rb")
end


DB = "http://localhost:5984/eee"
require 'restclient'

namespace :couchdb do

  desc "Drop and re-create the CouchDB database, loading the design documents after creation"
  task :reset => [:drop, :create, :load_design_docs]

  desc "Create a new version of the CouchDB database"
  task :create do
    RestClient.put DB, { }
  end

  desc "Delete the current the CouchDB database"
  task :drop do
    RestClient.delete DB
  end

  require 'couch_design_docs'

  desc "Load (replacing any existing) all design documents"
  task :load_design_docs do
    CouchDesignDocs.upload_dir(DB, "couch")
  end
end
