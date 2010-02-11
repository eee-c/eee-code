function(head, req){
  var row, last_key, ingredient_list;
  send('[');
  while(row = getRow()) {
    if (last_key != row.key) {
      if (typeof(last_key) != 'undefined') {
	if (ingredient_list.length < 100) {
	  send(toJSON({key:last_key, value:ingredient_list}));
	  send(',');
	}
      }
      last_key = row.key;
      ingredient_list = [];
    }
    ingredient_list.push(row.value);
  }
  if (ingredient_list.length < 100) {
    send(toJSON({key:last_key, value:ingredient_list}));
  }
  else {
    send('{"key":"","value":[]}');
  }
  send(']');
}
