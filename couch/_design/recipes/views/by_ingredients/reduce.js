function(keys, values, rereduce) {
  if (rereduce) {
    var ret = [];
    for (var i=0; i<values.length; i++) {
      ret = ret.concat(values[i]);
    }
    return ret.length > 100 ? [] : ret;
  }
  else {
    return values;
  }
}
