function(doc) {
  if (doc['type'] == 'Recipe') {
    emit(doc['_id'], doc['title']);
  }
}
