# Set working dir, compile Verilog and load simulation.
vlib work
vlog -timescale 1ns/1ns main.v
vsim -L altera_mf_ver -L altera_mf main_test

# Add the signals to waveform.
add wave -bin clk -bin go -bin frame_tick
add wave -bin /d0/draw
add wave -bin plot -bin plot_done
add wave -uns x -uns y -uns color
add wave -uns /d0/score_color -uns /d0/lives_color
add wave -uns /d0/nc_score/x_offset -uns /d0/nc_score/x -uns /d0/nc_score/y -uns /d0/nc_score/color_out

add wave -uns /c0/current_state

add wave -uns /d0/frog_x -uns /d0/frog_y -uns /d0/next_x_frog -uns /d0/next_y_frog
add wave -uns /d0/frame_counter
add wave -bin win -bin /d0/on_river

add wave -bin /d0/dne_signal_1
add wave -bin /d0/dne_signal_2

add wave -bin /d0/rnd_13_bit_num

add wave -bin /d0/row_1_object_2_exists
add wave -bin /d0/row_1_object_3_exists
add wave -bin /d0/row_2_object_2_exists
add wave -bin /d0/row_2_object_3_exists
add wave -bin /d0/row_3_object_2_exists
add wave -bin /d0/row_3_object_3_exists

# Force some possible inputs.
force clk 0 0ns, 1 1ns -repeat 2ns
force reset 1 0ns, 0 4ns
force score 10#2 0
force lives 10#8 0
force go 0 0ns, 1 10ns, 0 15ns, 1 1700000ns, 0 1700005ns, 1 2500000ns, 0 2500005ns

force up 0 0
force left 0 0
force down 1 0
force right 0 0

# Run simulation and zoom into relevant area of waveform.
run 10000000ns
wave zoom full

# Export data.
add list -bin clk -uns x -uns y -bin color -bin plot
write list list.lst
