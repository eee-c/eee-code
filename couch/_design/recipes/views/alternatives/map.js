function(doc) {
  if (doc['type'] == 'Alternative') {
    for (var i=0; i < doc['recipes'].length; i++) {
      var alternatives = [];
      for (var j=0; j < doc['recipes'].length; j++) {
        if (i != j) {
          alternatives.push(doc['recipes'][j]);
        }
      }
      emit(doc['recipes'][i], alternatives);
    }
  }
}
