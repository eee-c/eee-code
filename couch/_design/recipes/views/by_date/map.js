function (doc) {
  if (typeof(doc['preparations']) != 'undefined') {
    emit(doc['date'], [doc['_id'], doc['title']]);
  }
}
