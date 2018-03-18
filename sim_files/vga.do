# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns vga.v
vsim -L altera_mf_ver vga_test

# Add the signals to waveform.
add wave -bin clk 
add wave -bin plot_en -bin plot_done
add wave -uns x -uns y
add wave -uns /srm0/address
add wave -uns color

# Force some possible inputs.
force clk 0 0ns, 1 1ns -repeat 2ns
force plot_en 0 0ns, 1 5ns

# Run simulation and zoom into relevant area of waveform.
run 100ns
wave zoom full