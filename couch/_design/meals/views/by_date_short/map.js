function (doc) {
  if (doc['type'] == 'Meal' && doc['published']) {
    emit(doc['date'], {'title':doc['title'],'date':doc['date']});
  }
}
