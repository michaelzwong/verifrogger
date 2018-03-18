# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns main.v
vsim -L altera_mf_ver main_test

# Add the signals to waveform.
add wave -bin clk -bin go
add wave -bin draw_scrn_start
add wave -bin /d0/plot -bin plot_done
add wave -uns /d0/x -uns /d0/y -uns /d0/scrn_start_color

add wave -uns /c0/current_state

# Force some possible inputs.
force clk 0 0ns, 1 1ns -repeat 2ns
force reset 1 0ns, 0 2ns
force go 0 0ns, 1 10ns

# Run simulation and zoom into relevant area of waveform.
run 100ns
wave zoom full