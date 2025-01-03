LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE MazeTypes IS
    TYPE Node IS ARRAY (3 DOWNTO 0) OF STD_LOGIC;
    TYPE Maze IS ARRAY (NATURAL RANGE <>, NATURAL RANGE <>) OF Node;
    TYPE MazePixel IS ARRAY(NATURAL RANGE <>, NATURAL RANGE <>) OF STD_LOGIC;
END MazeTypes;