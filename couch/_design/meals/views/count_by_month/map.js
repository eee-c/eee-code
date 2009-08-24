function (doc) {
  if (doc['type'] == 'Meal' && doc['published']) {
    emit(doc['date'].substring(0, 4) + '-' + doc['date'].substring(5, 7), 1);
  }
}
