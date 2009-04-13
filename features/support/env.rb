ENV['RACK_ENV'] = 'test'

# NOTE: This must come before the require 'webrat', otherwise
# sinatra will look in the wrong place for its views.
require File.dirname(__FILE__) + '/../../eee'

# RSpec matchers
require 'spec/expectations'

# Webrat
require 'webrat'
Webrat.configure do |config|
  config.mode = :sinatra
end

World do
  session = Webrat::SinatraSession.new
  session.extend(Webrat::Matchers)
  session.extend(Webrat::HaveTagMatcher)
  session
end

Before do
  RestClient.put @@db, { }

  # TODO need to accomplish this via CouchDB migrations
  lucene_index_function = <<_JS
function(doc) {
  var ret = new Document();

  function idx(obj) {
    for (var key in obj) {
      switch (typeof obj[key]) {
        case 'object':
          idx(obj[key]);
          break;
        case 'function':
          break;
        default:
          ret.field(key, obj[key]);
          ret.field('all', obj[key]);
          break;
      }
    }
  }

  idx(doc);

  return ret;
}
_JS

  doc = { 'transform' => lucene_index_function }

  RestClient.put "#{@@db}/_design/lucene",
    doc.to_json,
    :content_type => 'application/json'
end

After do
  RestClient.delete @@db
end
