// RUNS A SERIES OF UNIT TESTS

/* This object is used to run unit tests on the main code. This includes tests such as:

	- Data type testing.
	- Edge case testing.
	- Boundry testing.
*/

// Data type testing

//unit_test = new obj_grid_controller.grid(32, 32, 64, 64, 12, 18, true, false, c_white, c_white, c_red);

with obj_grid_controller
{
grid_instance = new grid(32, 32, "64", 64, 18, 24);
}