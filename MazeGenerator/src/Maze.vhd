LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.MazeTypes.ALL;

ENTITY MazeGen IS
    GENERIC (
        MAP_SCALE : POSITIVE := 640;
        MAP_SIZE : POSITIVE := 9
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        mazeOut : OUT Maze (MAP_SIZE - 1 DOWNTO 0, MAP_SIZE - 1 DOWNTO 0)
    );
END ENTITY MazeGen;

ARCHITECTURE MazeBehv OF MazeGen IS
    TYPE GameState IS (WAIT_FOR_START, GENERATE_MAP, PLAYING, END_GAME);
    TYPE StackObj is
        record
            i : integer range 0 to 8;
            j : integer range 0 to 8;
            validMoves : std_logic_vector(3 downto 0); -- index 0 up, index 1 down, index 2 right, index 3 left
        end record;
    TYPE StackArray IS ARRAY(MAP_SIZE * MAP_SIZE - 1 DOWNTO 0) OF StackObj;
    TYPE MapGenerateState IS (NOT_INIT, GENERATING, END_GENERATE, dummy);
    TYPE MazePixel IS ARRAY(MAP_SCALE - 1 DOWNTO 0, MAP_SCALE - 1 DOWNTO 0) OF STD_LOGIC;
    SIGNAL mazePixelArray : MazePixel;
    SIGNAL mazeArray : Maze (MAP_SIZE - 1 DOWNTO 0, MAP_SIZE - 1 DOWNTO 0);
    SIGNAL state, nextState : GameState;
    SIGNAL stack : StackArray;
    SIGNAL mapState, mapNextState : MapGenerateState;
    SIGNAL stackPointer : INTEGER RANGE -1 TO 81;
    SIGNAL randomNum : INTEGER RANGE 0 TO 3;
    SIGNAL pseudoRand : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    PROCESS (clk)
        -- maximal length 32-bit xnor LFSR
        FUNCTION lfsr32(x : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        BEGIN
            RETURN x(30 DOWNTO 0) & (x(0) XNOR x(1) XNOR x(21) XNOR x(31));
        END FUNCTION;
    BEGIN
        IF (reset = '1') THEN
            pseudoRand <= (OTHERS => '0');
            randomNum <= 0;
        ELSIF rising_edge(clk) THEN
            pseudoRand <= lfsr32(pseudoRand);
            randomNum <= to_integer(unsigned(pseudoRand(1 DOWNTO 0)));
        END IF;
    END PROCESS;
    Main_Process : PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            state <= WAIT_FOR_START;
        ELSIF (clk'event AND clk = '1') THEN
            state <= nextState;
        END IF;
    END PROCESS Main_Process;
    Next_State_Process : PROCESS (state)
    BEGIN
        nextState <= State;
        CASE(state) IS
            WHEN WAIT_FOR_START =>
            nextState <= GENERATE_MAP;
            WHEN GENERATE_MAP =>
            WHEN PLAYING =>
            WHEN END_GAME =>
            WHEN OTHERS =>
        END CASE;
    END PROCESS Next_State_Process;
    Genrate_Map_Process : PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            mapState <= NOT_INIT;
            mazeArray <= (OTHERS => (OTHERS => "0000"));
            stackPointer <= - 1;
        ELSIF (clk'event AND clk = '1') THEN
            IF (mapState = NOT_INIT) THEN
                stackPointer <= 0;
                stack(0).i <= 0;
                stack(0).j <= 0;
                stack(0).validMoves <= "0000";
                mapState <= GENERATING;
            ELSIF (mapState = GENERATING) THEN
                IF (stackPointer =- 1) THEN
                    mapState <= END_GENERATE;
                ELSE
                    IF (stack(stackPointer).validMoves = "1111") THEN
                        stackPointer <= stackPointer - 1;
                    ELSE
                        IF (stack(stackPointer).validMoves(randomNum) = '0') THEN
                            IF (randomNum = 0) THEN
                                IF (stack(stackPointer).i = 0) THEN
                                    stack(stackPointer).validMoves(0) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i - 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(0) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0010";
                                    mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j)(1) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(0) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(0) <= '1';
                                END IF;
                            ELSIF (randomNum = 1) THEN
                                IF (stack(stackPointer).i = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(1) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i + 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(1) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0001";
                                    mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j)(0) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(1) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(1) <= '1';
                                END IF;
                            ELSIF (randomNum = 2) THEN
                                IF (stack(stackPointer).j = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(2) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j + 1;
                                    stack(stackPointer).validMoves(2) <= '1';
                                    stack(stackPointer + 1).validMoves <= "1000";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(2) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1)(3) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(2) <= '1';
                                END IF;
                            ELSIF (randomNum = 3) THEN
                                IF (stack(stackPointer).j = 0) THEN
                                    stack(stackPointer).validMoves(3) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j - 1;
                                    stack(stackPointer).validMoves(3) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0100";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(3) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1)(2) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(3) <= '1';
                                END IF;
                            END IF;
                        ELSIF (stack(stackPointer).validMoves((randomNum + 1) MOD 3) = '0') THEN
                            IF ((randomNum + 1) MOD 3 = 0) THEN
                                IF (stack(stackPointer).i = 0) THEN
                                    stack(stackPointer).validMoves(0) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i - 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(0) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0010";
                                    mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j)(1) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(0) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(0) <= '1';
                                END IF;
                            ELSIF ((randomNum + 1) MOD 3 = 1) THEN
                                IF (stack(stackPointer).i = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(1) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i + 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(1) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0001";
                                    mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j)(0) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(1) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(1) <= '1';
                                END IF;
                            ELSIF ((randomNum + 1) MOD 3 = 2) THEN
                                IF (stack(stackPointer).j = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(2) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j + 1;
                                    stack(stackPointer).validMoves(2) <= '1';
                                    stack(stackPointer + 1).validMoves <= "1000";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(2) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1)(3) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(2) <= '1';
                                END IF;
                            ELSIF ((randomNum + 1) MOD 3 = 3) THEN
                                IF (stack(stackPointer).j = 0) THEN
                                    stack(stackPointer).validMoves(3) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j - 1;
                                    stack(stackPointer).validMoves(3) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0100";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(3) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1)(2) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(3) <= '1';
                                END IF;
                            END IF;
                        ELSIF (stack(stackPointer).validMoves((randomNum + 2) MOD 3) = '0') THEN
                            IF ((randomNum + 2) MOD 3 = 0) THEN
                                IF (stack(stackPointer).i = 0) THEN
                                    stack(stackPointer).validMoves(0) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i - 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(0) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0010";
                                    mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j)(1) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(0) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(0) <= '1';
                                END IF;
                            ELSIF ((randomNum + 2) MOD 3 = 1) THEN
                                IF (stack(stackPointer).i = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(1) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i + 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(1) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0001";
                                    mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j)(0) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(1) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(1) <= '1';
                                END IF;
                            ELSIF ((randomNum + 2) MOD 3 = 2) THEN
                                IF (stack(stackPointer).j = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(2) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j + 1;
                                    stack(stackPointer).validMoves(2) <= '1';
                                    stack(stackPointer + 1).validMoves <= "1000";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(2) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1)(3) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(2) <= '1';
                                END IF;
                            ELSIF ((randomNum + 2) MOD 3 = 3) THEN
                                IF (stack(stackPointer).j = 0) THEN
                                    stack(stackPointer).validMoves(3) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j - 1;
                                    stack(stackPointer).validMoves(3) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0100";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(3) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1)(2) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(3) <= '1';
                                END IF;
                            END IF;
                        ELSIF (stack(stackPointer).validMoves((randomNum + 3) MOD 3) = '0') THEN
                            IF ((randomNum + 3) MOD 3 = 0) THEN
                                IF (stack(stackPointer).i = 0) THEN
                                    stack(stackPointer).validMoves(0) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i - 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(0) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0010";
                                    mazeArray(stack(stackPointer).i - 1, stack(stackPointer).j)(1) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(0) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(0) <= '1';
                                END IF;
                            ELSIF ((randomNum + 3) MOD 3 = 1) THEN
                                IF (stack(stackPointer).i = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(1) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i + 1;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j;
                                    stack(stackPointer).validMoves(1) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0001";
                                    mazeArray(stack(stackPointer).i + 1, stack(stackPointer).j)(0) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(1) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(1) <= '1';
                                END IF;
                            ELSIF ((randomNum + 3) MOD 3 = 2) THEN
                                IF (stack(stackPointer).j = MAP_SIZE - 1) THEN
                                    stack(stackPointer).validMoves(2) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j + 1;
                                    stack(stackPointer).validMoves(2) <= '1';
                                    stack(stackPointer + 1).validMoves <= "1000";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(2) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j + 1)(3) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(2) <= '1';
                                END IF;
                            ELSIF ((randomNum + 3) MOD 3 = 3) THEN
                                IF (stack(stackPointer).j = 0) THEN
                                    stack(stackPointer).validMoves(3) <= '1';
                                ELSIF (mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1) = "0000") THEN
                                    stack(stackPointer + 1).i <= stack(stackPointer).i;
                                    stack(stackPointer + 1).j <= stack(stackPointer).j - 1;
                                    stack(stackPointer).validMoves(3) <= '1';
                                    stack(stackPointer + 1).validMoves <= "0100";
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j)(3) <= '1';
                                    mazeArray(stack(stackPointer).i, stack(stackPointer).j - 1)(2) <= '1';
                                    stackPointer <= stackPointer + 1;
                                ELSE
                                    stack(stackPointer).validMoves(3) <= '1';
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS Genrate_Map_Process;
	mazeOut <= mazeArray;
END ARCHITECTURE MazeBehv;