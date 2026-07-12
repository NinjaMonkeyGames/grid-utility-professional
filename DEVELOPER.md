# DEVELOPER

- [DEVELOPER](#developer)
  - [Developer Documentation](#developer-documentation)
  - [How to Use This Guide](#how-to-use-this-guide)
  - [HIGH LEVEL OVERVIEW](#high-level-overview)
    - [ARGUMENTS](#arguments)
  - [RM\_MAIN](#rm_main)
  - [OBJ\_GRID\_CONTROLLER](#obj_grid_controller)
    - [CREATE](#create)
    - [CLEANUP](#cleanup)
    - [STEP](#step)
    - [DRAW](#draw)
  - [OBJ\_UNIT\_TEST](#obj_unit_test)
  - [CONTACT INFORMATION](#contact-information)
  - [COPYRIGHT](#copyright)

## Developer Documentation

This document serves as the **technical blueprint for this project**. While `CONTRIBUTING.md` outlines the *how-to* for
processes and standards, this guide focuses on the *why* and *what* of the system architecture, internal logic, and
codebase organisation.

*Note: Please refer to the **[CONTRIBUTING.md](CONTRIBUTING.md)** for information regarding coding style, pull request
processes, and commit message conventions.*

## How to Use This Guide

PLACEHOLDER

## HIGH LEVEL OVERVIEW

All `new` instances of 'grid' are generated with the grid controller object 'obj_grid_controller'. To generate an
instance simply use the following syntax:

```gml
example_variable = grid(arguments);
```

### ARGUMENTS

| Variable Name          | Description                                                                        |
|-:----------------------|-:----------------------------------------------------------------------------------|
| `x_offset`             | The horizontal starting position (origin) of the grid within the coordinate space. |
| `y_offset`             | The vertical starting position (origin) of the grid within the coordinate space.   |
| `cell_width`           | The width of an individual grid cell in pixels or units.                           |
| `cell_height`          | The height of an individual grid cell in pixels or units.                          |
| `row_qty`              | The total number of rows defined in the grid.                                      |
| `column_qty`           | The total number of columns defined in the grid.                                   |
| `text_colour`          | Default label text colour.                                                         |
| `text_colour_selected` | Label text colour corresponding to selected cell.                                  |

ℹ️ *You must run the destroy function from the variable in which you have stored the grid structure.*

---

## RM_MAIN

Contains code to setup basic room variables and generates and instance of the grid controller object.

## OBJ_GRID_CONTROLLER

This contains the logic for generating new grid instances.

### CREATE

Contains code to setup grid constructor.

### CLEANUP

Contains code the loops through all of the active grids and removes them from memory.

### STEP

Directs control inputs to various grid helper functions.

### DRAW

Loops through every grid in the list and draw based on the data stored in the struct.

## OBJ_UNIT_TEST

The purpose of the unit test object is to provide automated tests for the main grid object. Mainly consists of boundary
and data type tests.

## CONTACT INFORMATION

Author: Daniel Mallett (Monkey Knuckles)

If you have any problems with the repository or have any suggestions please contact us at <info@ninjamonkeygames.com>.

You may also contact us via our [website](https://ninjamonkeygames.com).

Any bugs should be raised as an [issue](https://github.com/NinjaMonkeyGames/project-name-here/issues) on GitHub.

---

## COPYRIGHT

*NinjaMonkeyGames™ Copyright © 2026 All rights reserved.*
