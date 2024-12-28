SetActiveLib -work
comp -include "$dsn\src\Maze.vhd" 
comp -include "$dsn\src\TestBench\mazegen_TB.vhd" 
asim +access +r TESTBENCH_FOR_mazegen 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg mazeOut
wave -noreg mazePixelOut
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\mazegen_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_mazegen 
