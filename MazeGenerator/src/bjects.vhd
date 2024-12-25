library ieee;
use ieee.std_logic_1164.all;

package MazeTypes is
    type Node is array (3 downto 0) of std_logic;
    type Maze is array (8 downto 0, 8 downto 0) of Node;
end MazeTypes;
