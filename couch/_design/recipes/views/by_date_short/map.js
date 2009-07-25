function (doc) {
  if (doc['type'] == 'Recipe') {
    emit(doc['date'], {'id':doc['_id'],'title':doc['title'],'date':doc['date']});
  }
}
