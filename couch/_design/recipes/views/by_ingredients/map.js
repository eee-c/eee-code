function (doc) {
  if (doc['published']) {
    for (var i in doc['preparations']) {
      var ingredient = doc['preparations'][i]['ingredient']['name'];
      var value      = [doc['_id'], doc['title']];
      if (ingredient.indexOf('[recipe:') == -1)
        emit(ingredient, {"id":doc['_id'],"title":doc['title']});
    }
  }
}
