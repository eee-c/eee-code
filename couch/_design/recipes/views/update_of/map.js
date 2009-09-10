function(doc) {
  if (doc['type'] == 'Update') {
    var num = doc['updates'].length;
    var old = [];
    for (var i=0; i<num-1; i++) {
      old[i] = doc['updates'][i]['id'];
    }
    emit(doc['updates'][num-1]['id'], old);
  }
}
