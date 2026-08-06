// INITIALISE PROJECT

global.debug_enabled  = false;

window_set_caption("Grid Utility Professional v" + GM_version);								// Set window caption text.
global.grid_controller = instance_create_layer(0, 0, "lyr_gui", obj_grid_controller);	// Generate instance of grid controller object.


for (var _j = 0; _j < 3; ++_j) 
{
	for (var _i = 0; _i < 4; ++_i) 
	{
		tile_data[_i][_j] =
		{
			sprite : spr_jungle_temple,
			index : 30,
			angle : 0,
			alpha : 1
		}
	}
}



example_grid = new obj_grid_controller.grid(,,,,,,,,,,,tile_data);															// Generate example grid instance.





// Generat unit test object.

if global.debug_enabled == true then global.unit_test = instance_create_layer(0, 0, "lyr_gui", obj_unit_test);	