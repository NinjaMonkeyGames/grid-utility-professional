// CREATES A CONSTRUCTOR CLASS  FOR GENERATING A 2D GRID

/// @description Generate 2D grid

global.grid_list = [];

/// @function grid()
/// @constructor
/// @description																					Generates a 2D grid based on parameters.
/// @parameter {Real}							_x_offset								The horizontal starting position (origin) of the grid within the coordinate space.
/// @parameter {Real}							_y_offset								The vertical starting position (origin) of the grid within the coordinate space.
/// @parameter {Real}							_cell_width								The width of an individual grid cell in pixels or units. 
/// @parameter {Real}							_cell_height							The height of an individual grid cell in pixels or units.
/// @parameter {Real}							_row_qty								Total number of rows defined in the grid.
/// @parameter {Real}							_column_qty							Total number of columns defined in the grid.
/// @parameter {Constant.Colour}		_text_colour							Default label text colour.
/// @parameter {Constant.Colour}		_text_colour_selected			Label text colour corresponding to selected cell.
/// @returns {Struct}							A new grid struct					

function grid(_x_offset = 32, _y_offset = 32, _cell_width = 64, _cell_height = 64, _row_qty = 12, _column_qty = 16, _text_colour = c_white, _text_colour_selected = c_red) constructor
{
	
	/// @description Imported variables
	
	x_offset = _x_offset;
	y_offset = _y_offset;
	
	base_width = _cell_width;
	base_height = _cell_height;
	
	row_qty = _row_qty;
	column_qty = _column_qty;
	
	text_colour = _text_colour;
	text_colour_selected = _text_colour_selected;
	
	/// @function											_sanitise_input
    /// @description									Check input  				

	function sanitise_input()
	{
		
	}
	
	initialise_grid();

    /// @function											initialise_grid
    /// @description									Updates grid or initialises first grid. 				

	function initialise_grid()
	{

	}
	
	/// @function destroy()
	/// @description Cleans up the instance from the global list and clears data
	
	static destroy = function() 
	{
	    // Find the current instance's index in the global array
		
	    //var _index = array_get_index(global.grid_list, self);
    
	    // Only remove if it actually exists in the array
		
	   // if (_index != -1)  { array_delete(global.grid_list, _index, 1)};
    
	    //cell_data = undefined; // Clear cell data
	
	    // Mark as destroyed so any lingering references can check before use
		
	   // is_destroyed = true;
		
	}
	
	/// @function			step
    /// @description	Execute step code for grid constructor instance.
	
    static step = function() 
    {
		
	}
	
    static draw = function() 
    {
		
	}
	
    array_push(global.grid_list, self); // Add copy of self to grid array.
}

