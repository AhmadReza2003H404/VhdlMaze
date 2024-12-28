LIBRARY work;
USE work.MazeTypes.ALL;
LIBRARY ieee;
USE ieee.NUMERIC_STD.ALL;
USE ieee.std_logic_1164.ALL;

-- Add your library and packages declaration here ...

ENTITY mazegen_tb IS
	-- Generic declarations of the tested unit
	GENERIC (
		MAP_SCALE : POSITIVE := 640;
		MAP_SIZE : POSITIVE := 9);
END mazegen_tb;

ARCHITECTURE TB_ARCHITECTURE OF mazegen_tb IS
	-- Component declaration of the tested unit
	COMPONENT mazegen
		GENERIC (
			MAP_SIZE : POSITIVE := 9);
		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			mazeOut : OUT Maze(MAP_SIZE - 1 DOWNTO 0, MAP_SIZE - 1 DOWNTO 0));
	END COMPONENT;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL reset : STD_LOGIC := '1';
	-- Observed signals - signals mapped to the output ports of tested entity
	SIGNAL mazeOut : Maze(MAP_SIZE - 1 DOWNTO 0, MAP_SIZE - 1 DOWNTO 0);

	-- Add your code here ...

BEGIN

	-- Unit Under Test port map
	UUT : mazegen
	GENERIC MAP(
		MAP_SIZE => MAP_SIZE
	)

	PORT MAP(
		clk => clk,
		reset => reset,
		mazeOut => mazeOut
	);

	-- Add your stimulus here ...
	reset <= '0' after 0.5 ns;
	clk <= not clk after 1 ns;
END TB_ARCHITECTURE;

CONFIGURATION TESTBENCH_FOR_mazegen OF mazegen_tb IS
	FOR TB_ARCHITECTURE
		FOR UUT : mazegen
			USE ENTITY work.mazegen(mazebehv);
		END FOR;
	END FOR;
END TESTBENCH_FOR_mazegen;