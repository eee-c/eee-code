function(keys, values, rereduce) {
  if (rereduce) {
    var a = [];
    for (var i=0; i<values.length; i++) {
      for (var j=0; j<values[i].length; j++) {
        a.push(values[i][j]);
      }
    }
    return a;
  }
  else {
    return values;
  }
}
