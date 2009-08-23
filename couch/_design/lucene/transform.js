function(doc) {
  var ret = new Document();

  function zero_pad(i, number_of_zeroes) {
    var ret = i + '';
    while (ret.length < number_of_zeroes) {
      ret = '0' + ret;
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

  if (doc['type'] == 'Recipe' && doc['published']) {
//  if (doc['type'] == 'Recipe') {
    idx(doc);

    ret.field('sort_title', doc['title'],     'yes', 'not_analyzed');
    ret.field('sort_date',  doc['date'],      'yes', 'not_analyzed');

    ret.field('sort_prep',  zero_pad(doc['prep_time'], 5), 'yes', 'not_analyzed');

    var ingredient_count = doc['preparations'] ? doc['preparations'].length : 0;
    ret.field('sort_ingredient', zero_pad(ingredient_count, 5), 'yes', 'not_analyzed');

    ret.field('date',       doc['date'],                'yes');
    ret.field('title',      doc['title'],               'yes');
    ret.field('prep_time',  doc['prep_time'],           'yes');
    ret.field('category',   (doc['tag_names'] || []).join(' '), 'yes');

    return ret;
  }
}
