/// @description Loops through step code for each grid instance

var _list_size = array_length(global.grid_list);

for (var i = 0; i < _list_size; i++)
{
    var current_instance = global.grid_list[i];
    current_instance.step();
}