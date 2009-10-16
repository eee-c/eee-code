function (doc) {
  if (doc['type'] == 'Recipe' && doc['published']) {
    emit(doc['date'], [doc['_id'], doc['title']]);
  }
}
