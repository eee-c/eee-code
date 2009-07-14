function (doc) {
  if (doc['type'] == 'Meal') {
    emit(doc['date'], [doc['_id'], doc['title']]);
  }
}
