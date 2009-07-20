function (doc) {
  if (doc['type'] == 'Meal') {
    emit(doc['date'], {'title':doc['title'],'date':doc['date']});
  }
}
