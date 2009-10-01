function(keys, values, rereduce) {
  if (rereduce) {
    var ret = [];
    for (var i=0; i<values.length; i++) {
      ret = ret.concat(values[i]);
    }
    return ret;
  }
  else {
    return values;
  }
}
