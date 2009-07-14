function (doc) {
  if (doc['type'] == 'Meal') {
    emit(doc['date'].substring(0, 4) + '-' + doc['date'].substring(5, 7), doc);
  }
}
