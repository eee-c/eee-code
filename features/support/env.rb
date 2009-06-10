ENV['RACK_ENV'] = 'test'

# NOTE: This must come before the require 'webrat', otherwise
# sinatra will look in the wrong place for its views.
require File.dirname(__FILE__) + '/../../eee'

# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = File.join(File.dirname(__FILE__), *%w[.. .. eee.rb])

require 'haml'

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

  function zero_pad(i, number_of_zeroes) {
    var ret = i + "";
    while (ret.length < number_of_zeroes) {
      ret = "0" + ret;
    }
    return ret;
  }

  function idx(obj) {
    for (var key in obj) {
      switch (typeof obj[key]) {
        case 'object':
          /* Handle ingredients as a special case */
          if (key == 'preparations') {
            var ingredients = [];
            for (var i=0; i<obj[key].length; i++) {
              ingredients.push(obj[key][i]['ingredient']['name']);
            }
            ret.field('ingredient', ingredients.join(', '), 'yes');
            ret.field('all',        ingredients.join(', '));
          }
          else {
            idx(obj[key]);
          }
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

  if (doc['preparations']) {
    idx(doc);

    ret.field('sort_title', doc['title'],     'yes', 'not_analyzed');
    ret.field('sort_date',  doc['date'],      'yes', 'not_analyzed');

    ret.field('sort_prep',  zero_pad(doc['prep_time'], 5), 'yes', 'not_analyzed');

    var ingredient_count = doc['preparations'] ? doc['preparations'].length : 0;
    ret.field('sort_ingredient', zero_pad(ingredient_count, 5), 'yes', 'not_analyzed');

    ret.field('date',       doc['date'],      'yes');
    ret.field('title',      doc['title'],     'yes');
    ret.field('prep_time',  doc['prep_time'], 'yes');

    return ret;
  }
}
_JS

  doc = { 'transform' => lucene_index_function }

  RestClient.put "#{@@db}/_design/lucene",
    doc.to_json,
    :content_type => 'application/json'

  meals_view = <<_JS
{
  "views": {
    "by_year": {
      "map": "function (doc) {
        if (doc['type'] == 'Meal') {
          emit(doc['date'].substring(0, 4), [doc['_id'], doc['title']]);
        }
      }",
      "reduce": "function(keys, values, rereduce) { return values; }"
    },
    "by_month": {
      "map": "function (doc) {
        if (doc['type'] == 'Meal') {
          emit(doc['date'].substring(0, 4) + '-' + doc['date'].substring(5, 7), doc);
        }
      }",
      "reduce": "function(keys, values, rereduce) { return values; }"
    },
    "count_by_year": {
      "map": "function (doc) {
        if (doc['type'] == 'Meal') {
          emit(doc['date'].substring(0, 4), 1);
        }
      }",
      "reduce": "function(keys, values, rereduce) { return sum(values); }"
    },
    "count_by_month": {
      "map": "function (doc) {
        if (doc['type'] == 'Meal') {
          emit(doc['date'].substring(0, 4) + '-' + doc['date'].substring(5, 7), 1);

        }
      }",
      "reduce": "function(keys, values, rereduce) { return sum(values); }"
    }
  },
  "language": "javascript"
}
_JS

  RestClient.put "#{@@db}/_design/meals",
    meals_view,
    :content_type => 'application/json'
end

After do
  RestClient.delete @@db
  sleep 0.5
end
