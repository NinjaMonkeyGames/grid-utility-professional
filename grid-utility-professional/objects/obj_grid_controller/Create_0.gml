// CREATES A CONSTRUCTOR CLASS  FOR GENERATING A 2D GRID

/// @description Generate 2D grid

global.grid_list = []; // Stores array of grid structs

/// @enum


#macro  LIMIT_CELL_WIDTH_MIN 8
#macro  LIMIT_CELL_WIDTH_MAX 1024
#macro  LIMIT_CELL_HEIGHT_MIN 8
#macro  LIMIT_CELL_HEIGHT_MAX 1024

#macro  LIMIT_ROW_QTY_MIN 0
#macro  LIMIT_ROW_QTY_MAX 1024

/// @function grid()
/// @constructor
/// @description																					   Generates a 2D grid based on parameters.
/// @since																								    v0.1.0.
/// @version																							    v0.1.0.
/// @parameter {Real}							    _x_offset								The horizontal starting position (origin) top-left.
/// @parameter {Real}							    _y_offset								The vertical starting position (origin) of the grid within the coordinate space.
/// @parameter {Real}							    _cell_width								The width of an individual grid cell in pixels or units. 
/// @parameter {Real}							    _cell_height							The height of an individual grid cell in pixels or units.
/// @parameter {Real}							    _row_qty								Total number of rows defined in the grid.
/// @parameter {Real}							    _column_qty							Total number of columns defined in the grid.
/// @parameter {Constant.Colour}			_grid_colour							Default label text colour.
/// @parameter {Constant.Colour}			_text_colour							Default label text colour.
/// @parameter {Constant.Colour}			_text_colour_selected			Selected label text colour.
/// @returns {Struct}							                                                    A new grid struct.					

function grid(_x_offset = 32, _y_offset = 32, _cell_width = 64, _cell_height = 64, _row_qty = 12, _column_qty = 16, _grid_colour = c_white, _text_colour = c_white, _text_colour_selected = c_red)  constructor
{
		/// @description Calculation variables
	
	    x_scale = 1;
        y_scale = 1;
	
		/// @description Imported variables
	
        x_offset							= _x_offset;
        y_offset							= _y_offset;
        
		base_cell_width				= _cell_width;
		base_cell_height			= _cell_height;
		
        cell_width						= _cell_width;
        cell_height						= _cell_height;
        
        row_qty							= _row_qty;
        column_qty					= _column_qty;
        
        text_colour					= _text_colour;
	    text_colour_selected		= _text_colour_selected;
    
	set_grid();

    /// @function											set_grid
    /// @description									Updates grid or initialises first grid. 				

	function set_grid()
	{
        for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
	            cell_data[_row][_column] =
	            {
	                x1 : x_offset + (_column * cell_width * x_scale),
	                x2 : x_offset + (_column * cell_width * x_scale) + (cell_width * x_scale),
                
	                y1 : y_offset + (_row    * cell_height * y_scale),
	                y2 : y_offset + (_row    * cell_height * y_scale) + (cell_height * y_scale),
					
					label_row_x : x_offset + (_column * cell_width * x_scale) - 22 ,
					label_row_y : y_offset + (_row    * cell_height * y_scale) + cell_height / 2,

					label_column_x : x_offset + (_column * cell_width * x_scale) + cell_width / 2,
					label_column_y : y_offset + (_row    * cell_height * y_scale) - 22 ,
					
					label_row_text : _row,
					label_column_text : _column,
					
					label_text_colour : c_white,
				}
				
				if get_x() == _row
				{
					cell_data[_row][_column].label_text_colour = c_red;
				}
				
				// Clear text from cells that are not on the edge.
				
				if _row != 0 then cell_data[_row][_column].label_column_text = "";
				if _column != 0 then cell_data[_row][_column].label_row_text = "";
	        }
	    }
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
	
	/// @function			get_x
	/// @description								Gets the selected X coordinate.
	/// @parameter		{Real}			 _x	Check row possition against X (mouse pointer by default).

    static get_x = function(_x = mouse_x) 
    {
		return floor((_x - x_offset) / cell_width);
	}
	
	/// @function			get_y
	/// @description								Gets the selected Y coordinate.
	/// @parameter		{Real}			 _y	Check row possition against Y (mouse pointer by default).

    static get_y = function(_y = mouse_y) 
    {
		return floor((_y - y_offset) / cell_height);
	}
	
	/// @function			step
    /// @description	Execute step code for grid constructor instance.
	
    static step = function() 
    {
		show_debug_message(get_x())
	}
	
    static draw = function() 
    {
		draw_set_halign(fa_center);
	    draw_set_valign(fa_middle);
    
	    for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
	            // Cache the reference: One lookup per cell
				
	            var _cache_data = cell_data[_row][_column];
            
	            draw_text(_cache_data.label_row_x, _cache_data.label_row_y, _cache_data.label_row_text);
	            draw_text(_cache_data.label_column_x, _cache_data.label_column_y, _cache_data.label_column_text);
	            draw_rectangle(_cache_data.x1, _cache_data.y1, _cache_data.x2, _cache_data.y2, true);
	        }
	    }
	}
	
    array_push(global.grid_list, self); // Add copy of self to grid array.
}

