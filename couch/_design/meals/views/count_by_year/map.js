function (doc) {
  if (doc['type'] == 'Meal') {
    emit(doc['date'].substring(0, 4), 1);
  }
}
