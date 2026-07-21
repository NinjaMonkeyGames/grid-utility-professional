// CREATES A CONSTRUCTOR CLASS  FOR GENERATING A 2D GRID

/// @description Generate 2D grid

global.grid_list = [];							// Stores array of grid structs
global.grid_vformat = undefined;	// Shared vertex format for all grid instances

/// @description Soft limits

#macro  LIMIT_CELL_WIDTH_MIN 8
#macro  LIMIT_CELL_WIDTH_MAX 1024
#macro  LIMIT_CELL_HEIGHT_MIN 8
#macro  LIMIT_CELL_HEIGHT_MAX 1024

#macro  LIMIT_ROW_QTY_MIN 1
#macro  LIMIT_ROW_QTY_MAX 128
#macro  LIMIT_COLUMN_QTY_MIN 1
#macro  LIMIT_COLUMN_QTY_MAX 128

#macro LIMIT_ROW_SHIFT_MIN -9999
#macro LIMIT_ROW_SHIFT_MAX 9999
#macro LIMIT_COLUMN_SHIFT_MIN -9999
#macro LIMIT_COLUMN_SHIFT_MAX 9999

#macro LIMIT_X_SCALE_MIN 0.25
#macro LIMIT_Y_SCALE_MIN 0.25
#macro LIMIT_X_SCALE_MAX 4
#macro LIMIT_Y_SCALE_MAX 4

/// @function grid()
/// @constructor
/// @description																					Generates a 2D grid based on parameters.
/// @since																							    v0.1.0.
/// @param {Real}							    [_x_offset]								The horizontal starting position (origin) top-left.
/// @param {Real}							    [_y_offset]								The vertical starting position (origin) of the grid within the coordinate space.
/// @param {Real}							    [_cell_width]							The width of an individual grid cell in pixels or units. 
/// @param {Real}							    [_cell_height]							The height of an individual grid cell in pixels or units.
/// @param {Real}							    [_row_qty]								Total number of rows.
/// @param {Real}								[_column_qty]						Total number of columns.
/// @param {bool}								[_label_text_type_row]			Determine if row label text should be represented as numbers or letters.
/// @param {bool}								[_label_text_type_column]	Determine if column label text should be represented as numbers or letters.
/// @param {Constant.Colour}			[_grid_colour]						Default label text colour.
/// @param {Constant.Colour}			[_text_colour]						Default label text colour.
/// @param {Constant.Colour}			[_text_colour_selected]		Selected label text colour.
/// @returns {Struct}							                                                A new grid struct.					

function grid
(
_x_offset = 64, _y_offset = 32, 
_cell_width = 64, _cell_height = 64, 
_row_qty = 18, _column_qty = 24, 
_label_text_type_row = false, _label_text_type_column = true,
_grid_colour = c_white, _text_colour = c_white, _text_colour_selected = c_red, 

)  
constructor
{
	/// @description Calculation variables
	
	x_scale = 1;
    y_scale = 1;
		
	x_shift = 0;
	y_shift = 0;
		
	label_text_grid_gap_column = 6;
	label_text_grid_gap_row = 12;

	vbuff = -1;
	cache_cursor = window_get_cursor();
	
	cell_data = [];
	
	/// @description Imported variables
	
    x_offset									= _x_offset;
    y_offset									= _y_offset;
		
    cell_width								= clamp(_cell_width, LIMIT_CELL_WIDTH_MIN, LIMIT_CELL_WIDTH_MAX);
    cell_height								= clamp(_cell_height, LIMIT_CELL_HEIGHT_MIN, LIMIT_CELL_HEIGHT_MAX);
        
    row_qty									= clamp(_row_qty, LIMIT_ROW_QTY_MIN, LIMIT_ROW_QTY_MAX);
    column_qty							= clamp(_column_qty, LIMIT_COLUMN_QTY_MIN, LIMIT_COLUMN_QTY_MAX);
        
    grid_colour							= _grid_colour;
    text_colour							= _text_colour;
	text_colour_selected				= _text_colour_selected;
		
	label_text_type_row				= _label_text_type_row;
	label_text_type_column		= _label_text_type_column;
		
	/// @description Build the shared vertex format once, the first time any grid is created.
	
	if (is_undefined(global.grid_vformat))
	{
		vertex_format_begin();
		vertex_format_add_position();
		vertex_format_add_colour();
		
		global.grid_vformat = vertex_format_end();
	}
    
    /// @function											set_grid
    /// @description									Updates grid or initialises first grid. 				

	static set_grid = function()
	{
		cell_data = [];

		// Free any previous buffer before rebuilding, otherwise each call leaks a buffer.
		
		if (vbuff != -1)
		{
			vertex_delete_buffer(vbuff);
			vbuff = -1;
		}

		vbuff = vertex_create_buffer();
		vertex_begin(vbuff, global.grid_vformat);
		
		// Calculate vertex boundries
		
		grid_x1 = x_offset;
		grid_y1 = y_offset;
		grid_x2 = x_offset + (column_qty * cell_width	* x_scale);
		grid_y2 = y_offset + (row_qty		* cell_height	* y_scale);

		// Horizontal lines

		for (var _row = 0; _row <= row_qty; ++_row)
		{
			var _y = y_offset + (_row * cell_height * y_scale);

			vertex_position(vbuff, grid_x1, _y); vertex_colour(vbuff, grid_colour, 1);
			vertex_position(vbuff, grid_x2, _y); vertex_colour(vbuff, grid_colour, 1);
		}

		// Vertical lines

		for (var _column = 0; _column <= column_qty; ++_column)
		{
			var _x = x_offset + (_column * cell_width * x_scale);

			vertex_position(vbuff, _x, grid_y1); vertex_colour(vbuff, grid_colour, 1);
			vertex_position(vbuff, _x, grid_y2); vertex_colour(vbuff, grid_colour, 1);
		}
		
		// Build grid
		
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

	            var _x1 = _x_pos;
	            var _y1 = _y_pos;
	            var _x2 = _x_pos + (cell_width	* x_scale);
	            var _y2 = _y_pos + (cell_height	* y_scale);

	            // Store cell data
				
	            cell_data[_row][_column] =
	            {
	                x1 : _x1,
					y1 : _y1,
	                x2 : _x2,
	                y2 : _y2,
                
	                label_row_text		: _row_string,
	                label_column_text : _column_string,
                
	                // Left label
					
	                label_row_x : (_x1 - string_width(_row_string)) - label_text_grid_gap_row,
	                label_row_y : _y1 + (cell_height * y_scale) / 2 - string_height(_row_string) / 2,

	                // Top label
					
	                label_column_x : _x1 + (cell_width * x_scale) / 2 - string_width(_column_string) / 2,
	                label_column_y : (_y1 - string_height(_column_string)) - label_text_grid_gap_column,
					
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

		vertex_end(vbuff);
		vertex_freeze(vbuff); // static geometry until the next set_grid() call — safe to freeze for a GPU-side speed boost
	}
	
	set_grid();
	
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

    static shift_x = function(_value) 
    {
		x_shift = clamp(x_shift + _value, LIMIT_COLUMN_SHIFT_MIN, 1 + LIMIT_COLUMN_SHIFT_MAX - column_qty);
		//set_grid();
	}
	
	/// @function												shift_y
	/// @description										Shift rows. (Negative values shift up)
	/// @parm				{Real}			_value		New row shift value.
	
    static shift_y = function(_value) 
    {
		y_shift = clamp(y_shift + _value, LIMIT_ROW_SHIFT_MIN, 1 + LIMIT_ROW_SHIFT_MAX - row_qty);
		//set_grid();
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
	
	/// @function										update_row
	/// @description								Changes the number of rows.
	/// @param {Real}			_value		Number of rows in new grid.

	static update_row = function(_value)
	{
		row_qty = clamp(_value, LIMIT_ROW_QTY_MIN, LIMIT_ROW_QTY_MAX);
		set_grid();
	}
	
	/// @function										update_column
	/// @description								Changes the number of columns.
	/// @param {Real}			_value		Number of columns in new grid.

	static update_column = function(_value)
	{
		column_qty = clamp(_value, LIMIT_COLUMN_QTY_MIN, LIMIT_COLUMN_QTY_MAX);
		set_grid();
	}

	/// @function										zoom
	/// @description								Zooms in/out while preserving the grid's total on-screen size.
	/// @param {Real}			_value		Amount to change scale by (e.g. 0.1 in, -0.1 out).

	static zoom = function(_value)
	{
		if is_real(_value) // Sanatise input prevent error
		{
	        if (_value < 0)
	        {
	            // Zooming Out: halve the scale, double the row/column quantities
				
	            var _new_x_scale	= x_scale / 2;
	            var _new_y_scale	= y_scale / 2;
	            var _new_col			= column_qty * 2;
	            var _new_row		= row_qty * 2;
            
	            // Check if the new state respects your absolute limits
				
	            if (_new_x_scale >= LIMIT_X_SCALE_MIN && _new_x_scale <= LIMIT_X_SCALE_MAX &&
	                _new_col <= LIMIT_COLUMN_QTY_MAX && _new_row <= LIMIT_ROW_QTY_MAX)
	            {
	                x_scale			= _new_x_scale;
	                y_scale			= _new_y_scale;
	                column_qty	= _new_col;
	                row_qty			= _new_row;
	            }
	        }
				else
	        {
	            // Zooming In: double the scale, halve the row/column quantities
				
	            var _new_x_scale		= x_scale * 2;
	            var _new_y_scale		= y_scale * 2;
	            var _new_col				= round(column_qty / 2);
	            var _new_row			= round(row_qty / 2);
            
	            // Check if the new state respects your absolute limits and won't hit zero cells
				
	            if (_new_x_scale >= LIMIT_X_SCALE_MIN && _new_x_scale <= LIMIT_X_SCALE_MAX &&
	                _new_col >= LIMIT_COLUMN_QTY_MIN && _new_row >= LIMIT_ROW_QTY_MIN)
	            {
	                x_scale			= _new_x_scale;
	                y_scale			= _new_y_scale;
	                column_qty	= _new_col;
	                row_qty			= _new_row;
	            }
			}
        }
       
        set_grid(); // Rebuild the grid geometry
	}

	/// @function												set_cursor
    /// @description										Set mouse pointer graphic
	
    static set_cursor = function() 
    {
		if point_in_rectangle(mouse_x, mouse_y, grid_x1, grid_y1, grid_x2, grid_y2)
		{
			window_set_cursor(cr_handpoint) 
		}
			else
		{
			window_set_cursor(cache_cursor);
		}
	}

	/// @function			step
    /// @description	Execute step code for grid constructor instance.
	
    static step = function() 
    {
		if mouse_wheel_down()
		{
			zoom(-0.1);
		}
		
		if mouse_wheel_up()
		{
			zoom(0.1);
		}
		
		if keyboard_check_pressed(vk_left)		then shift_x(-1);
		if keyboard_check_pressed(vk_right)		then shift_x(1);
		if keyboard_check_pressed(vk_up)			then shift_y(-1);
		if keyboard_check_pressed(vk_down)	then shift_y(1);
		
		set_coords(); 
		set_cursor();
	}
				
    static draw = function() 
    {
		// One draw call for every outline in the grid.

		vertex_submit(vbuff, pr_linelist, -1);

	    for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
	            var _cache_data = cell_data[_row][_column];
				
	            draw_text_ext_colour(_cache_data.label_row_x, _cache_data.label_row_y, _cache_data.label_row_text, 0, cell_width, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_x_alpha);
	            draw_text_ext_colour(_cache_data.label_column_x, _cache_data.label_column_y, _cache_data.label_column_text, 0, cell_height, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_y_alpha);
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

		// Free the vertex buffer - otherwise this leaks GPU memory every time a grid is destroyed.
		
		if (vbuff != -1)
		{
			vertex_delete_buffer(vbuff);
			vbuff = -1;
		}
	}
	
    array_push(global.grid_list, self); // Add copy of self to grid array.
}