function(doc) {
  if (doc['type'] == 'Update') {
    var num = doc['updates'].length;
    for (var i=0; i<num-1; i++) {
      emit(doc['updates'][i]['id'], doc['updates'][num-1]['id']);
    }
  }
}
