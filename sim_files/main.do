# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns main.v
vsim -L altera_mf_ver -L altera_mf main_test

# Add the signals to waveform.
add wave -bin clk -bin go
add wave -bin draw_scrn_start -bin draw_scrn_game_over
add wave -bin plot -bin plot_done
add wave -uns x -uns y -uns color

add wave -uns /c0/current_state

# Force some possible inputs.
force clk 0 0ns, 1 1ns -repeat 2ns
force VGA_CLK 0 0ns, 1 2ns -repeat 4ns
force reset 1 0ns, 0 4ns
force go 0 0ns, 1 10ns, 0 15ns, 1 140ns, 0 145ns, 1 300ns, 0 305ns

# Run simulation and zoom into relevant area of waveform.
run 1000ns
wave zoom full