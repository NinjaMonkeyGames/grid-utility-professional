// CREATES A CONSTRUCTOR CLASS  FOR GENERATING A 2D GRID

/// @description Generate 2D grid

global.grid_list = []; // Stores array of grid structs

global.last_mouse_x = mouse_x;
global.last_mouse_y = mouse_y;

/// @enum


#macro  LIMIT_CELL_WIDTH_MIN 8
#macro  LIMIT_CELL_WIDTH_MAX 1024
#macro  LIMIT_CELL_HEIGHT_MIN 8
#macro  LIMIT_CELL_HEIGHT_MAX 1024

#macro  LIMIT_ROW_QTY_MIN 0
#macro  LIMIT_ROW_QTY_MAX 1024
#macro  LIMIT_COLUMN_QTY_MIN 0
#macro  LIMIT_COLUMN_QTY_MAX 1024

#macro LIMIT_ROW_SHIFT_MIN -9999
#macro LIMIT_ROW_SHIFT_MAX 9999
#macro LIMIT_COLUMN_SHIFT_MIN -9999
#macro LIMIT_COLUMN_SHIFT_MAX 9999

// Add dedicated macros here if rows and columns should ever be bounded differently.

/// @function grid()
/// @constructor
/// @description																					Generates a 2D grid based on parameters.
/// @since																							    v0.1.0.
/// @param {Real}							    [_x_offset]								The horizontal starting position (origin) top-left.
/// @param {Real}							    [_y_offset]								The vertical starting position (origin) of the grid within the coordinate space.
/// @param {Real}							    [_cell_width]							The width of an individual grid cell in pixels or units. 
/// @param {Real}							    [_cell_height]							The height of an individual grid cell in pixels or units.
/// @param {Real}							    [_row_qty]								Total number of rows defined in the grid.
/// @param {Real}								[_column_qty]						Total number of columns defined in the grid.
/// @param {bool}								[_label_text_type_row]			Determine if row label text should be represented as numbers or letters.
/// @param {bool}								[_label_text_type_column]	Determine if column label text should be represented as numbers or letters.
/// @param {Constant.Colour}			[_grid_colour]						Default label text colour.
/// @param {Constant.Colour}			[_text_colour]						Default label text colour.
/// @param {Constant.Colour}			[_text_colour_selected]		Selected label text colour.
/// @returns {Struct}							                                                A new grid struct.					

function grid
(
_x_offset = 64, _y_offset = 32, 
_cell_width = 32, _cell_height = 32, 
_row_qty = 12, _column_qty = 16, 
_grid_colour = c_white, _text_colour = c_white, _text_colour_selected = c_red, 
_label_text_type_row = false, _label_text_type_column = true
)  constructor
{
	/// @description Calculation variables
	
	x_scale = 1;
    y_scale = 1;
		
	x_shift = 1;
	y_shift = 1;
		
	label_text_grid_gap_row = 6;
	label_text_grid_gap_column = 12;

	// FIX: removed unused mouse_x_last / mouse_y_last instance fields.
	// They were written once at construction and never read or updated
	// anywhere else - dead state. Mouse-change tracking is handled via
	// global.last_mouse_x / global.last_mouse_y instead (see step()).

	is_destroyed = false; // FIX: initialise explicitly so it's never undefined before destroy() is called
		
	/// @description Imported variables
	
    x_offset									= _x_offset;
    y_offset									= _y_offset;
		
    cell_width								= clamp(_cell_width, LIMIT_CELL_WIDTH_MIN, LIMIT_CELL_WIDTH_MAX);
    cell_height								= clamp(_cell_height, LIMIT_CELL_HEIGHT_MIN, LIMIT_CELL_HEIGHT_MAX); // FIX: was clamping against LIMIT_CELL_WIDTH_MIN
        
    row_qty									= clamp(_row_qty, LIMIT_ROW_QTY_MIN, LIMIT_ROW_QTY_MAX);
    column_qty							= clamp(_column_qty, LIMIT_COLUMN_QTY_MIN, LIMIT_COLUMN_QTY_MAX);
        
    text_colour							= _text_colour;
	text_colour_selected				= _text_colour_selected;
		
	label_text_type_row				= _label_text_type_row;
	label_text_type_column		= _label_text_type_column;
		
	cell_data = [];
    
	set_grid();

    /// @function											set_grid
    /// @description									Updates grid or initialises first grid. 				

	function set_grid()
	{
		cell_data = [];
		
	    for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
	            // Cache the label values

	            var _row_string			= label_text_type_row			? spt_convert_letters(_row		+ y_shift)	: string(_row		+ y_shift);
	            var _column_string   = label_text_type_column	? spt_convert_letters(_column	+ x_shift)	: string(_column + x_shift);
            
	            // Calculate coordinates
				
	            var _x_pos = x_offset + (_column	* cell_width	* x_scale);
	            var _y_pos = y_offset + (_row			* cell_height	* y_scale);
				
				// Store cell data
				
	            cell_data[_row][_column] =
	            {
	                x1 : _x_pos,
	                x2 : _x_pos + (cell_width	* x_scale),
	                y1 : _y_pos,
	                y2 : _y_pos + (cell_height	* y_scale),
                
	                label_row_text		: _row_string,
	                label_column_text : _column_string,
                
	                // Left label
					
	                label_row_x : (_x_pos - string_width(_row_string)) - label_text_grid_gap_column,
	                label_row_y : _y_pos + (cell_height * y_scale) / 2 - string_height(_column_string) / 2,

	                // Top label
					
	                label_column_x : _x_pos + (cell_width * x_scale) / 2 - string_width(_column_string) / 2,
	                label_column_y : (_y_pos - string_height(_row_string)) - label_text_grid_gap_row,
					
	                label_text_colour_x : c_white,
	                label_text_colour_y : c_white,
					
	                label_text_x_alpha  : 1,
	                label_text_y_alpha  : 1,
					
	                outline : true
	            };
            
	            // Clear text from cells not on the edge
				
	            if (_row != 0)    cell_data[_row][_column].label_column_text = "";
	            if (_column != 0) cell_data[_row][_column].label_row_text    = "";
	        }
	    }
	}
	
	/// @function destroy()
	/// @description Cleans up the instance from the global list and clears data
	
	static destroy = function() 
	{
	    // Find the current instance's index in the global array
		
	    var _index = array_get_index(global.grid_list, self);
    
	    // Only remove if it actually exists in the array
		
	    if (_index != -1) { array_delete(global.grid_list, _index, 1); }
    
	    cell_data = undefined; // Clear cell data
	
	    // Mark as destroyed so any lingering references can check before use
		
	    is_destroyed = true;
		
	}
	
	/// @function			get_x
	/// @description								Gets the selected X coordinate.
	/// @parm				{Real}		 [_x]	Check row possition against X (mouse pointer by default).

    static get_x = function(_x = mouse_x) 
    {
		return clamp(floor((_x - x_offset) / (cell_width * x_scale)), 0, column_qty - 1);
	}
	
	/// @function										get_y
	/// @description								Gets the selected Y coordinate.
	/// @parm				{Real}		[_y]		Check row possition against Y (mouse pointer by default).

    static get_y = function(_y = mouse_y) 
    {
		return clamp(floor((_y - y_offset) / (cell_height * y_scale)), 0, row_qty - 1);
	}
	
	/// @function												shift_x
	/// @description										Shift columns. (Negative values shift left)
	/// @parm				{Real}			_value		New column shift value.

	// FIX: shift_x controls x_shift, which is added to the *column* index
	// (_column + x_shift in set_grid()). The original implementation used
	// row_qty and LIMIT_ROW_SHIFT_* here, which meant shift_x was actually
	// bounded/scaled by row data instead of column data. It now consistently
	// uses column_qty and LIMIT_COLUMN_SHIFT_*.
    static shift_x = function(_value) 
    {
	    var _column_shift = _value - column_qty;

	    x_shift = clamp(_column_shift, LIMIT_COLUMN_SHIFT_MIN, LIMIT_COLUMN_SHIFT_MAX - (column_qty - 1));
		
		set_grid();
	}
	
	/// @function												shift_y
	/// @description										Shift rows. (Negative values shift up)
	/// @parm				{Real}			_value		New row shift value.
	
    static shift_y = function(_value) 
    {
	    var _row_shift = _value - row_qty;

	    y_shift = clamp(_row_shift, LIMIT_ROW_SHIFT_MIN, LIMIT_ROW_SHIFT_MAX - (row_qty - 1));
		
		set_grid();
	}
	
	/// @function										set_coords
	/// @description								Highlights the row/column label under the given (or mouse) position.

    static set_coords = function() 
    {
		var _select_x = get_x();
		var _select_y = get_y();
		
		for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
				cell_data[_row][_column].label_text_colour_x = (_row ==_select_y) ? text_colour_selected : text_colour;
				cell_data[_row][_column].label_text_colour_y = (_column == _select_x) ? text_colour_selected : text_colour;
			}
		}
	}
	
	/// @function																detect_change
	/// @description														Checks whether the mouse has moved and/or a key is being pressed since the last check.
	/// @param               [_mouse]				{Bool}			Set this if you want to check mouse movement.
	/// @param               [_keyboard]		{Bool}			Set this if you want to check keyboard activity.
	/// @return											{Bool}			Returns true if state has changed and false if it has not.
	/// @pure

	static detect_change = function(_mouse = true, _keyboard = true)
	{
		if (_mouse == true)
		{
			if (mouse_x != global.last_mouse_x || mouse_y != global.last_mouse_y) { return true; }
		}
		
		return (_keyboard == true) ? keyboard_check(vk_anykey) : false;
	}

	/// @function			step
    /// @description	Execute step code for grid constructor instance.
	
    static step = function() 
    {
		if (detect_change() == true) { set_coords(); }
	}
				
    static draw = function() 
    {
	    for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
	            var _cache_data = cell_data[_row][_column];
				
	            draw_text_ext_colour(_cache_data.label_row_x, _cache_data.label_row_y, _cache_data.label_row_text, 0, cell_width, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_x_alpha);
	            draw_text_ext_colour(_cache_data.label_column_x, _cache_data.label_column_y, _cache_data.label_column_text, 0, cell_height, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_y_alpha);
	            
				draw_rectangle(_cache_data.x1, _cache_data.y1, _cache_data.x2, _cache_data.y2, _cache_data.outline);
	        }
	    }
	}
	
    array_push(global.grid_list, self); // Add copy of self to grid array.
}