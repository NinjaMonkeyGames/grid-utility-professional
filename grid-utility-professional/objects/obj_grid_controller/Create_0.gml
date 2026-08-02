// CONSTRUCTOR CLASS FOR GENERATING A 2D GRID

/// @description Generate 2D grid

global.grid_list = [];							// Stores array of grid structs
global.grid_vformat = undefined;	// Shared vertex format for all grid instances

// ---- Soft limits ----

#macro  LIMIT_CELL_WIDTH_MIN 8
#macro  LIMIT_CELL_WIDTH_MAX 256
#macro  LIMIT_CELL_HEIGHT_MIN 8
#macro  LIMIT_CELL_HEIGHT_MAX 256

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
#macro LIMIT_X_SCALE_MAX 2
#macro LIMIT_Y_SCALE_MAX 2

/// @function																					grid()
/// @constructor
/// @description																			Generates a 2D grid based on parameters.
/// @since																						v0.1.0.
/// @param {Real}						[_x_offset]								The horizontal starting position (origin, top-left) of the grid.
/// @param {Real}						[_y_offset]								The vertical starting position (origin, top-left) of the grid.
/// @param {Real}						[_cell_width]							The width of an individual grid cell in pixels or units.
/// @param {Real}						[_cell_height]							The height of an individual grid cell in pixels or units.
/// @param {Real}						[_row_qty]								Total number of rows.
/// @param {Real}						[_column_qty]						Total number of columns.
/// @param {Bool}						[_label_text_type_row]			Whether row labels are rendered as letters (true) or numbers (false).
/// @param {Bool}						[_label_text_type_column]	Whether column labels are rendered as letters (true) or numbers (false).
/// @param {Constant.Colour}	[_grid_colour]						Colour of the grid lines.
/// @param {Constant.Colour}	[_text_colour]						Default label text colour.
/// @param {Constant.Colour}	[_text_colour_selected]		Label text colour when the row/column is under the cursor.
/// @returns {Struct}																	A new grid struct.

function grid
(
_x_offset = 32, _y_offset = 32, 
_cell_width = 64, _cell_height = 64, 
_row_qty = 18, _column_qty = 24, 
_label_text_type_row = false, _label_text_type_column = true,
_grid_colour = c_white, _text_colour = c_white, _text_colour_selected = c_red
)  
constructor
{
	// ---- Calculation variables ----
	
	cell_data = []; // Initialise cell data.
	is_destroyed = false; // Set true by destroy() - guarded methods check this before running.
	
	x_scale = 1;
    y_scale = 1;
		
	x_shift = 0;
	y_shift = 0;
		
	label_text_grid_gap_column = 6;
	label_text_grid_gap_row = 12;

	vbuff = -1;
	cache_cursor = window_get_cursor();

	// Vertex boundary cache (populated by set_grid), declared here for discoverability.

	grid_x1 = 0;
	grid_y1 = 0;
	grid_x2 = 0;
	grid_y2 = 0;

	/// @function																					sanitise_input()
	/// @description																			Sanitises bad arguments and throws error.
	/// @since																						v0.1.0.
	/// @param {Real}						_x_offset								The horizontal starting position (origin, top-left) of the grid.
	/// @param {Real}						_y_offset								The vertical starting position (origin, top-left) of the grid.
	/// @param {Real}						_cell_width								The width of an individual grid cell in pixels or units.
	/// @param {Real}						_cell_height							The height of an individual grid cell in pixels or units.
	/// @param {Real}						_row_qty								Total number of rows.
	/// @param {Real}						_column_qty							Total number of columns.
	/// @param {Bool}						_label_text_type_row			Whether row labels are rendered as letters (true) or numbers (false).
	/// @param {Bool}						_label_text_type_column		Whether column labels are rendered as letters (true) or numbers (false).
	/// @param {Constant.Colour}	_grid_colour							Colour of the grid lines.
	/// @param {Constant.Colour}	_text_colour							Default label text colour.
	/// @param {Constant.Colour}	_text_colour_selected			Label text colour when the row/column is under the cursor.

	static santise_input = function
	(
	_x_offset, _y_offset, 
	_cell_width, _cell_height, 
	_row_qty, _column_qty, 
	_label_text_type_row, _label_text_type_column,
	_grid_colour, _text_colour, _text_colour_selected
	)
	{ 
		// Data type checks
		
		if !is_real(_x_offset)								then throw("X_OFFSET MUST BE A NUMBER");
		if !is_real(_y_offset)								then throw("Y_OFFSET MUST BE A NUMBER");
		
		if !is_real(_cell_width)							then throw("CELL_WIDTH MUST BE A NUMBER");
		if !is_real(_cell_height)							then throw("CELL_HEIGHT MUST BE A NUMBER");
		
		if !is_real(_row_qty)								then throw("ROW_QTY MUST BE A NUMBER");
		if !is_real(_column_qty)						then throw("COLUMN_QTY MUST BE A NUMBER");
		
		if !is_bool(_label_text_type_row)			then throw("ROW_QTY MUST BE BOOLEAN");
		if !is_bool(_label_text_type_column)	then throw("COLUMN_QTY MUST BE A BOOLEAN");
		
		if !is_real(_grid_colour)							then throw("GRID COLOUR MUST BE A COLOUR");
		if !is_real(_text_colour)							then throw("TEXT COLOUR MUST BE A COLOUR");
		if !is_real(_text_colour_selected)			then throw("TEXT COLOUR SELECTED MUST BE A COLOUR");
		
		// Whole number checks
		
		if frac(_cell_width) != 0							then throw("_CELL_WIDTH MUST BE A WHOLE NUMBER");
		if frac(_cell_height) != 0						then throw("_CELL_HEIGHT MUST BE A WHOLE NUMBER");
		
		if frac(_row_qty) != 0								then throw("_ROW_QTY MUST BE A WHOLE NUMBER");
		if frac(_column_qty) != 0						then throw("_COLUMN_QTY MUST BE A WHOLE NUMBER");
		
		// Range checks
		
		if _cell_width						< LIMIT_CELL_WIDTH_MIN		||	_cell_width						>  LIMIT_CELL_WIDTH_MAX		then throw("_CELL_WIDTH");
		if _cell_height					< LIMIT_CELL_HEIGHT_MIN		||	 _cell_height					>  LIMIT_CELL_HEIGHT_MAX		then throw("_CELL_HEIGHT");
		
		if _row_qty							< LIMIT_ROW_QTY_MIN			||	_row_qty						>  LIMIT_ROW_QTY_MAX				then throw("_ROW_QTY");
		if _column_qty					< LIMIT_COLUMN_QTY_MIN	||	_column_qty					>  LIMIT_COLUMN_QTY_MAX		then throw("_COLUMN_QTY");
		
		if _grid_colour					< 0												||	_grid_colour					> 16777215									then throw("_GRID_COLOUR");
		if _text_colour					< 0												||	 _text_colour					> 16777215									then throw("_TEXT_COLOUR");
		if _text_colour_selected	< 0												||	_text_colour_selected	> 16777215									then throw("_TEXT_COLOUR_SELECTED");
		
	};
	
	// Validate raw arguments BEFORE anything (including clamp()) touches them.
	
	santise_input(_x_offset, _y_offset, _cell_width, _cell_height, _row_qty, _column_qty, _label_text_type_row, _label_text_type_column, _grid_colour, _text_colour, _text_colour_selected);

	// ---- Imported variables ----
	
    x_offset								= _x_offset;
    y_offset								= _y_offset;
		
    cell_width							= clamp(_cell_width , LIMIT_CELL_WIDTH_MIN, LIMIT_CELL_WIDTH_MAX);
    cell_height							= clamp(_cell_height, LIMIT_CELL_HEIGHT_MIN, LIMIT_CELL_HEIGHT_MAX);
        
    row_qty								= clamp(_row_qty, LIMIT_ROW_QTY_MIN, LIMIT_ROW_QTY_MAX);
    column_qty						= clamp(_column_qty, LIMIT_COLUMN_QTY_MIN, LIMIT_COLUMN_QTY_MAX);
        
    grid_colour						= _grid_colour;
    text_colour						= _text_colour;
	text_colour_selected			= _text_colour_selected;
		
	label_text_type_row			= _label_text_type_row;
	label_text_type_column	= _label_text_type_column;
		
	// Build the shared vertex format once, the first time any grid is created.
	
	if (is_undefined(global.grid_vformat))
	{
		vertex_format_begin();
		vertex_format_add_position();
		vertex_format_add_colour();
		
		global.grid_vformat = vertex_format_end();
	};

	/// @function						guard_alive()
	/// @description				Throws if this instance has already been destroyed. Single source of truth for the.
	///										use-after-destroy check - call at the top of any method that reads cell_data/vbuff or mutates grid state.
	/// @since							v0.1.0.

	static guard_alive = function()
	{
		if (is_destroyed) then throw("GRID INSTANCE HAS BEEN DESTROYED");
	};

	/// @function						clamp_shifts()
	/// @description				Re-clamps x_shift/y_shift against the current row_qty/column_qty.
	/// @since							v0.1.0.

	static clamp_shifts = function()
	{
		x_shift = clamp(x_shift, LIMIT_COLUMN_SHIFT_MIN, 1	+ LIMIT_COLUMN_SHIFT_MAX	- column_qty);
		y_shift = clamp(y_shift, LIMIT_ROW_SHIFT_MIN, 1			+ LIMIT_ROW_SHIFT_MAX			- row_qty);
	}
    
    /// @function						set_grid()
    /// @description				Rebuilds the grid's vertex buffer and cell data from the current parameters.
	/// @since							v0.1.0.

	static set_grid = function()
	{
		guard_alive();

		cell_data = [];

		// Free any previous buffer before rebuilding, otherwise each call leaks a buffer.
		
		if (vbuff != -1)
		{
			vertex_delete_buffer(vbuff);
			vbuff = -1;
		};

		vbuff = vertex_create_buffer();
		vertex_begin(vbuff, global.grid_vformat);
		
		// Calculate vertex boundaries.
		
		grid_x1 = x_offset;
		grid_y1 = y_offset;
		grid_x2 = x_offset + (column_qty	* cell_width	* x_scale);
		grid_y2 = y_offset + (row_qty			* cell_height	* y_scale);

		// Horizontal lines.

		for (var _row = 0; _row <= row_qty; ++_row)
		{
			var _y = y_offset + (_row * cell_height * y_scale);

			vertex_position(vbuff, grid_x1, _y); vertex_colour(vbuff, grid_colour, 1);
			vertex_position(vbuff, grid_x2, _y); vertex_colour(vbuff, grid_colour, 1);
		};

		// Vertical lines.

		for (var _column = 0; _column <= column_qty; ++_column)
		{
			var _x = x_offset + (_column * cell_width * x_scale);

			vertex_position(vbuff, _x, grid_y1); vertex_colour(vbuff, grid_colour, 1);
			vertex_position(vbuff, _x, grid_y2); vertex_colour(vbuff, grid_colour, 1);
		};
		
		// Build grid cells.
		
	    for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        var _is_top_edge = (_row == 0); // Top row also handles column headers below.

	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
	            var _is_left_edge = (_column == 0); // Left column also handles row headers below.

	            // Calculate coordinates.
				
	            var _x_pos = x_offset + (_column	* cell_width	* x_scale);
	            var _y_pos = y_offset + (_row			* cell_height	* y_scale);

	            var _x1 = _x_pos;
	            var _y1 = _y_pos;
	            var _x2 = _x_pos + (cell_width		* x_scale);
	            var _y2 = _y_pos + (cell_height	* y_scale);

	            // Only build a row label (left edge) when this cell is in column 0.

	            var _row_string		= "";
	            var _label_row_x	= 0;
	            var _label_row_y	= 0;

	            if (_is_left_edge)
	            {
	                _row_string	= label_text_type_row ? convert_letters(_row + y_shift) : string(_row + y_shift);
	                _label_row_x	= (_x1 - string_width(_row_string)) - label_text_grid_gap_row;
	                _label_row_y	= _y1 + (cell_height * y_scale) / 2 - string_height(_row_string) / 2;
	            };

	            // Only build a column label (top edge) when this cell is in row 0.

	            var _column_string	= "";
	            var _label_column_x	= 0;
	            var _label_column_y	= 0;

	            if (_is_top_edge)
	            {
	                _column_string		= label_text_type_column ? convert_letters(_column + x_shift) : string(_column + x_shift);
	                _label_column_x	= _x1 + (cell_width * x_scale) / 2 - string_width(_column_string) / 2;
	                _label_column_y	= (_y1 - string_height(_column_string)) - label_text_grid_gap_column;
	            };

	            // Store cell data.
				
	            cell_data[_row][_column] =
	            {
	                x1 : _x1,
					y1 : _y1,
	                x2 : _x2,
	                y2 : _y2,
                
	                label_row_text		: _row_string,
	                label_column_text	: _column_string,
                
	                // Left label.
					
	                label_row_x : _label_row_x,
	                label_row_y : _label_row_y,

	                // Top label.
					
	                label_column_x : _label_column_x,
	                label_column_y : _label_column_y,
					
	                label_text_colour_x : c_white,
	                label_text_colour_y : c_white,
					
	                label_text_x_alpha  : 1,
	                label_text_y_alpha  : 1,
					
	                outline : true
	            };
	        }
	    }

		vertex_end(vbuff);
		vertex_freeze(vbuff); // Static geometry until the next set_grid() call, so freezing is safe and gives a GPU-side speed boost.
	}
	
	set_grid();
	
	/// @function								get_x()
	/// @description						Gets the column index under the given X coordinate.
	/// @since									v0.1.0.
	/// @param	{Real}		[_x]		X coordinate to check (mouse pointer by default).
	/// @returns	{Real}					Column index, clamped to a valid range.

    static get_x = function(_x = mouse_x) 
    {
		guard_alive();
		return clamp(floor((_x - x_offset) / (cell_width * x_scale)), 0, floor(column_qty) - 1);
	}
	
	/// @function								get_y()
	/// @description						Gets the row index under the given Y coordinate.
	/// @since									v0.1.0.
	/// @param {Real}		[_y]		Y coordinate to check (mouse pointer by default).
	/// @returns {Real}					Row index, clamped to a valid range.

    static get_y = function(_y = mouse_y) 
    {
		guard_alive();
		return clamp(floor((_y - y_offset) / (cell_height * y_scale)), 0, floor(row_qty) - 1);
	}
	
	/// @function									shift_x()
	/// @description							Shifts columns. (Negative values shift left.)
	/// @since										v0.1.0.
	/// @param {Real}		_value		Amount to add to the current column shift.

    static shift_x = function(_value) 
    {
		guard_alive();

		if !is_real(_value)		then throw("_VALUE MUST BE A NUMBER");
		if frac(_value) != 0		then throw("_VALUE MUST BE A WHOLE NUMBER");

		x_shift = clamp(x_shift + _value, LIMIT_COLUMN_SHIFT_MIN, 1 + LIMIT_COLUMN_SHIFT_MAX - column_qty);
		set_grid();
	}
	
	/// @function									shift_y()
	/// @description							Shifts rows. (Negative values shift up.)
	/// @since										v0.1.0.
	/// @param {Real}		_value		Amount to add to the current row shift.
	
    static shift_y = function(_value) 
    {
		guard_alive();

		if !is_real(_value)		then throw("_VALUE MUST BE A NUMBER");
		if frac(_value) != 0		then throw("_VALUE MUST BE A WHOLE NUMBER");

		y_shift = clamp(y_shift + _value, LIMIT_ROW_SHIFT_MIN, 1 + LIMIT_ROW_SHIFT_MAX - row_qty);
		set_grid();
	}
	
	/// @function						set_coords()
	/// @description				Highlights the row/column labels under the current mouse position.
	/// @since							v0.1.0.

    static set_coords = function() 
    {
		guard_alive();

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
	
	/// @function									update_row()
	/// @description							Changes the number of rows.
	/// @since										v0.1.0.
	/// @param {Real}		_value		Number of rows in the new grid.

	static update_row = function(_value)
	{
		guard_alive();

		if !is_real(_value)		then throw("_VALUE MUST BE A NUMBER");
		if frac(_value) != 0		then throw("_VALUE MUST BE A WHOLE NUMBER");

		row_qty = clamp(_value, LIMIT_ROW_QTY_MIN, LIMIT_ROW_QTY_MAX);
		clamp_shifts();			// row_qty changed - re-validate y_shift so labels don't go stale.
		set_grid();
	}
	
	/// @function									update_column()
	/// @description							Changes the number of columns.
	/// @since										v0.1.0.
	/// @param {Real}		_value		Number of columns in the new grid.

	static update_column = function(_value)
	{
		guard_alive();

		if !is_real(_value)		then throw("_VALUE MUST BE A NUMBER");
		if frac(_value) != 0		then throw("_VALUE MUST BE A WHOLE NUMBER");

		column_qty = clamp(_value, LIMIT_COLUMN_QTY_MIN, LIMIT_COLUMN_QTY_MAX);
		
		clamp_shifts();	// column_qty changed - re-validate x_shift so labels don't go stale.
		set_grid();
	}

	/// @function														zoom()
	/// @description												Zooms in/out while preserving the grid's total on-screen size.
	/// @since															v0.1.0.
	/// @param {Bool}	[_zoom_direction]			True to zoom in, false to zoom out.

	static zoom = function(_zoom_direction = true)
	{
		guard_alive();

		if is_bool(_zoom_direction) // Sanitise input to prevent an error.
		{
	        if _zoom_direction == false
	        {
	            // Zooming out: halve the scale, double the row/column quantities.
				
	            var _new_x_scale	= x_scale			/ 2;
	            var _new_y_scale	= y_scale			/ 2;
	            var _new_col			= column_qty	* 2;
	            var _new_row		= row_qty			* 2;
            
	            // Check if the new state respects the absolute limits.
				
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
	            // Zooming in: double the scale, halve the row/column quantities.
				
	            var _new_x_scale	= x_scale						* 2;
	            var _new_y_scale	= y_scale						* 2;
	            var _new_col			= round(column_qty		/ 2);
	            var _new_row		= round(row_qty			/ 2);
            
	            // Check if the new state respects the absolute limits and won't hit zero cells.
				
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
       
        clamp_shifts();			// row_qty/column_qty may have changed - re-validate x_shift/y_shift.
        set_grid();					// Rebuild the grid geometry.
	}

	/// @function					set_cursor()
    /// @description			Sets the mouse pointer graphic depending on whether the cursor is over the grid.
	/// @since						v0.1.0.
	
    static set_cursor = function() 
    {
		guard_alive();

		if point_in_rectangle(mouse_x, mouse_y, grid_x1, grid_y1, grid_x2, grid_y2)
		{
			window_set_cursor(cr_handpoint) ;
		}
			else
		{
			window_set_cursor(cache_cursor);
		}
	}

	/// @function													convert_letters()
	/// @description											Converts number to a letter the same way as you would see on an atlas or a spreadsheet.
	/// @since														v0.1.0.
	/// @param               _number	{Real}			The number to convert to a letter(s).
	/// @return								{String}		Return letter.

	static convert_letters = function(_number)
	{
		if (!is_real(_number)) return undefined;

	    var _val = floor(_number);
	    var _prefix = (_val < 0) ? "-" : "";
	    var _num = abs(_val);
	
		if _number > 0 then _num ++;

	    var _string = "";
	
	    while (_num > 0)
	    {
	        _num -= 1; 
	        _string = chr((_num mod 26) + 65) + _string;
	        _num = _num div 26;
	    }

	    return _prefix + (_string == "" ? "A" : _string);
	}

	/// @function					step()
    /// @description			Executes the step logic for this grid instance (input handling and state updates).
	/// @since						v0.1.0.
	
    static step = function() 
    {
		guard_alive();

		if mouse_wheel_down()
		{
			zoom(true);
		}
		
		if mouse_wheel_up()
		{
			zoom(false);
		}
		
		if keyboard_check_pressed(vk_left)		then shift_x(-1);
		if keyboard_check_pressed(vk_right)		then shift_x(1);
		if keyboard_check_pressed(vk_up)			then shift_y(-1);
		if keyboard_check_pressed(vk_down)	then shift_y(1);
		
		set_coords(); 
		set_cursor();
	}
	
	/// @function					draw()
    /// @description			Executes the draw logic for this grid instance (grid lines and labels).
	/// @since						v0.1.0.
	
    static draw = function() 
    {
		guard_alive();

		// One draw call for every outline in the grid.

		vertex_submit(vbuff, pr_linelist, -1);

	    for (var _row = 0; _row < row_qty; ++_row) 
	    {
	        for (var _column = 0; _column < column_qty; ++_column) 
	        {
	            var _cache_data = cell_data[_row][_column];

	            draw_text_ext_colour(_cache_data.label_row_x, _cache_data.label_row_y, _cache_data.label_row_text, -1, -1, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_colour_x, _cache_data.label_text_x_alpha);
	            draw_text_ext_colour(_cache_data.label_column_x, _cache_data.label_column_y, _cache_data.label_column_text, -1, -1, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_colour_y, _cache_data.label_text_y_alpha);
	        }
	    }
	}
	
	/// @function						destroy()
	/// @description				Removes this instance from the global grid list, frees GPU resources, and wipes all instance data.
	/// @since							v0.1.0.
	
	static destroy = function() 
	{
	    if (is_destroyed) then return; // Already destroyed - safe no-op.

	    // Find the current instance's index in the global array.
		
	    var _index = array_get_index(global.grid_list, self);
    
	    // Only remove if it actually exists in the array.
		
	    if (_index != -1) { array_delete(global.grid_list, _index, 1); };

		// Free the vertex buffer - otherwise this leaks GPU memory every time a grid is destroyed.
		
		if (vbuff != -1)
		{
			vertex_delete_buffer(vbuff);
			vbuff = -1;
		}

		is_destroyed = true; // Set before the generic wipe below, since the wipe would otherwise erase it too.

		// Generically blank every remaining data field, so destroy() doesn't need
		// manual upkeep whenever a new variable is added to the constructor.
		// Methods are left intact so guard_alive() can still fire a clean error
		// on any call made after destruction, instead of a raw "undefined function" crash.

		var _names = variable_struct_get_names(self);

		for (var _i = 0; _i < array_length(_names); ++_i)
		{
			var _name = _names[_i];

			if (_name == "is_destroyed")						continue;
			if (is_method(variable_struct_get(self, _name)))	continue;

			variable_struct_set(self, _name, undefined);
		}
	}
	
    array_push(global.grid_list, self); // Add this instance to the global grid list.
}