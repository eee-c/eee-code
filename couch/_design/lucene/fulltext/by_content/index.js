function(doc) {
  if (doc['type'] != 'Recipe' || !doc['published']) return null;

  var ret = new Document();

  function zero_pad(i, number_of_zeroes) {
    var padded = i + '';
    while (padded.length < number_of_zeroes) {
      padded = '0' + padded;
    }
    return padded;
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

          ret.add(
            ingredients.join(', '),
            {'field': 'ingredient', 'store': 'yes'}
          );
          ret.add(ingredients.join(', '));
        }
        else {
          idx(obj[key]);
        }
        break;
      case 'function':
        break;
      default:
        ret.add(obj[key], {'field': key});
        ret.add(obj[key]);
        break;
      }
    }
  };

  idx(doc);

  ret.add(
    doc['title'],
    {'field': 'sort_title', 'store': 'yes', 'index': 'not_analyzed'}
  );

  ret.add(
    doc['date'],
    {'field': 'sort_date', 'store': 'yes', 'index': 'not_analyzed'}
  );

  ret.add(
    zero_pad(doc['prep_time'], 5),
    {'field': 'sort_prep', 'store': 'yes', 'index': 'not_analyzed'}
  );

  var ingredient_count = doc['preparations'] ? doc['preparations'].length : 0;
  ret.add(
    zero_pad(ingredient_count, 5),
    {'field': 'sort_ingredient', 'store': 'yes', 'index': 'not_analyzed'}
  );

  ret.add(doc['date'], {'field': 'date', 'store': 'yes'});
  ret.add(doc['title'], {'field': 'title', 'store': 'yes'});
  ret.add(doc['prep_time'], {'field': 'prep_time', 'store': 'yes'});
  ret.add(
    (doc['tag_names'] || []).join(' '),
    {'field': 'category', 'store': 'yes'}
  );

  if (doc._attachments) {
    for (var i in doc._attachments) {
      ret.attachment("default", i);
    }
  }

  return ret;
}
