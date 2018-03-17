# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns vga.v
vsim -L altera_mf_ver vga_test

# Add the signals to waveform.
add wave -bin clk
add wave -uns x -uns y
add wave -uns /srm0/address
add wave -uns color

# Force some possible inputs.
force clk 0 0ns, 1 1ns -repeat 2ns
force x 10#0 5ns, 10#2 10ns, 10#7 15ns, 10#9 20ns
force y 10#0 5ns, 10#3 10ns, 10#4 15ns, 10#5 20ns

# Run simulation and zoom into relevant area of waveform.
run 25ns
wave zoom full