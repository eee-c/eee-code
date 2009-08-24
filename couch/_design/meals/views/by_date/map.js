function (doc) {
  if (doc['type'] == 'Meal' && doc['published']) {
    emit(doc['date'], doc);
  }
}
