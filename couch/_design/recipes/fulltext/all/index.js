function(rec) {
  function zero_pad(i, number_of_zeroes) {
    var ret = i + '';
    while (ret.length < number_of_zeroes) {
      ret = '0' + ret;
    }
    return ret;
  }

  if (rec.type == 'Recipe' && rec.published) {
    var doc = new Document();

    doc.add(rec.summary);
    doc.add(rec.instructions);

    doc.add(rec.title);
    doc.add(rec.title, {"field":"title", "store":"yes"});
    doc.add(rec.title, {"field":"sort_title", "index":"not_analyzed"});

    doc.add(rec.date);
    doc.add(rec.date, {"field":"date", "store":"yes"});
    doc.add(rec.date, {"field":"sort_date", "index":"not_analyzed"});

    doc.add(rec.prep_time);
    doc.add(rec.prep_time, {"store":"yes", "field":"prep_time"});
    doc.add(zero_pad(rec.prep_time, 5), {"field":"sort_prep", "index":"not_analyzed"});

    if (rec.tag_names) {
      for (var i=0; i< rec.tag_names.length; i++) {
	doc.add(rec.tag_names[i], {"field":"category"});
      }
    }

    if (rec.preparations) {
      var ingredients = [];
      for (var i=0; i<rec.preparations.length; i++) {
	ingredients.push(rec.preparations[i]['ingredient']['name']);
      }
      doc.add(ingredients.join(', '));
      doc.add(ingredients.join(', '), {"store":"yes", "field":"ingredient"});
    }
    var ingredient_count = doc['preparations'] ? doc['preparations'].length : 0;
    doc.add(zero_pad(ingredient_count, 5), {"field":"sort_ingredient", "index":"not_analyzed"});

    doc.add("Recipe", {"field":"type"});

    return doc;
  }
  else {
    return null;
  }
}
