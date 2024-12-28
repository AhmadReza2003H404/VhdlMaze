library work;
use work.MazeTypes.all;
library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity mazegen_tb2 is
	-- Generic declarations of the tested unit
		generic(
		BLOCK_SIZE : POSITIVE := 4;
		WALL_SIZE : POSITIVE := 20;
		MAP_SIZE : POSITIVE := 9 );
end mazegen_tb2;

architecture TB_ARCHITECTURE of mazegen_tb2 is
	-- Component declaration of the tested unit
	component mazegen
		generic(
		BLOCK_SIZE : POSITIVE := 4;
		WALL_SIZE : POSITIVE := 20;
		MAP_SIZE : POSITIVE := 9 );
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		mazePixelOut : out MazePixel(((MAP_SIZE*BLOCK_SIZE))-1 downto 0,((MAP_SIZE*BLOCK_SIZE))-1 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC := '0';
	signal reset : STD_LOGIC := '1';
	signal mazePixelOut : MazePixel(((MAP_SIZE*BLOCK_SIZE))-1 downto 0,((MAP_SIZE*BLOCK_SIZE))-1 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : mazegen
		generic map (
			BLOCK_SIZE => BLOCK_SIZE,
			WALL_SIZE => WALL_SIZE,
			MAP_SIZE => MAP_SIZE
		)

		port map (
			clk => clk,
			reset => reset,
			mazePixelOut => mazePixelOut
		);
	reset <= '0' after 0.5 ns;
	clk <= not clk after 1 ns;
	-- Add your stimulus here ...

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_mazegen of mazegen_tb is
	for TB_ARCHITECTURE
		for UUT : mazegen
			use entity work.mazegen(mazebehv);
		end for;
	end for;
end TESTBENCH_FOR_mazegen;

