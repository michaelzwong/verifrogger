`include "vga.v"
`include "vga_adapter/vga_pll.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_adapter.v"
`include "ps2keyboard/PS2_Keyboard_Controller.v"
`include "counter.v"
`include "lfsr.v"



module main_test ();

    // ### Wires. ###

    wire clk, reset, rnd_reset;
    wire go;

    wire draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    wire draw_river_obj_1, draw_river_obj_2, draw_river_obj_3;
    wire draw_score, draw_lives;
    wire erase_frog;
    wire move_objects;

    wire draw_pot_obj_1_2, draw_pot_obj_1_3, draw_pot_obj_2_2, draw_pot_obj_2_3, draw_pot_obj_3_2, draw_pot_obj_3_3;


    wire [3:0] score, lives;

    wire plot_done;

    wire dne_signal_1, dne_signal_2;

    wire plot;
    wire [8:0] x, y;
    wire [2:0] color;

    // VGA wires.
    wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    wire [9:0] VGA_R, VGA_G, VGA_B;

    // ### Datapath and control. ###

    datapath d0 (
        .clk(clk), .reset(reset), .rnd_reset(rnd_reset),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2), .draw_river_obj_3(draw_river_obj_3),
        .draw_score(draw_score), .draw_lives(draw_lives),
        .move_objects(move_objects),
        .erase_frog(erase_frog),

        .draw_pot_obj_1_2(draw_pot_obj_1_2), .draw_pot_obj_1_3(draw_pot_obj_1_3), .draw_pot_obj_2_2(draw_pot_obj_2_2),
        .draw_pot_obj_2_3(draw_pot_obj_2_3), .draw_pot_obj_3_2(draw_pot_obj_3_2), .draw_pot_obj_3_3(draw_pot_obj_3_3),

        .ld_frog_loc(ld_frog_loc),

        .score(score), .lives(lives),

        .frame_tick(frame_tick),

        .left(left), .right(right), .up(up), .down(down),

        .plot_done(plot_done),

        .plot(plot), .x(x), .y(y), .color(color),
        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),
        .win(win), .die(die)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .plot_done(plot_done), .mov_key_pressed(mov_key_pressed),
        .win(win), .die(die),

        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),

        .frame_tick(frame_tick),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2), .draw_river_obj_3(draw_river_obj_3),
        .draw_score(draw_score), .draw_lives(draw_lives), .move_objects(move_objects),
        .erase_frog(erase_frog),

        .ld_frog_loc(ld_frog_loc),

        .draw_pot_obj_1_2(draw_pot_obj_1_2), .draw_pot_obj_1_3(draw_pot_obj_1_3), .draw_pot_obj_2_2(draw_pot_obj_2_2),
        .draw_pot_obj_2_3(draw_pot_obj_2_3), .draw_pot_obj_3_2(draw_pot_obj_3_2), .draw_pot_obj_3_3(draw_pot_obj_3_3),

        .current_state(current_state)
    );

endmodule // main_test

module VeriFrogger (
    CLOCK_50,
    KEY, SW,
    PS2_CLK, PS2_DAT,
    LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B
);

    // ### FPGA inputs and outputs. ###

    input CLOCK_50;

    // For auxilary input or debugging.
    input [9:0] SW;
    input [3:0] KEY;

    // For keyboard input and output.
    inout PS2_CLK;
    inout PS2_DAT;

    // For auxiliary output or debugging.
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // VGA DAC signals.
    output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    output [9:0] VGA_R, VGA_G, VGA_B;

    // ### Wires. ###

    wire clk = CLOCK_50;
    wire go_key = !KEY[0];
    wire reset = !KEY[3];
    wire rnd_reset = !KEY[1];
    wire enable = !KEY[2];

    wire [3:0] score = SW[3:0];
    wire [3:0] lives = SW[7:4];

    reg go;

    wire draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    wire draw_river_obj_1, draw_river_obj_2, draw_river_obj_3;
    wire draw_score, draw_lives;
    wire erase_frog;
    wire move_objects;

    wire draw_pot_obj_1_2, draw_pot_obj_1_3, draw_pot_obj_2_2, draw_pot_obj_2_3, draw_pot_obj_3_2, draw_pot_obj_3_3;

    wire plot_done;

    wire dne_signal_1, dne_signal_2;

    wire plot;
    wire [8:0] x, y;
    wire [2:0] color;

    // VGA wires.
    wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    wire [9:0] VGA_R, VGA_G, VGA_B;

    // Keyboard wires.
    wire w, a, s, d;
    wire up, left, down, right;
    wire space, enter;

    wire mov_key_pressed;

    assign mov_key_pressed = w | a | s | d | up | left | down | right;

    // The output from the counter for the keyboard.
    wire keyboard_clock;

    // Since both w, a, s, d and up, left, down, right are the same controls, the wires can be combined.
//    wire up_c, left_c, down_c, right_c;

//    assign up_c = w || up;
//    assign left_c = a || left;
//    assign down_c = s || down;
//    assign right_c = d || right;

     // ### GO button stuff. ###

     reg [1:0] go_state, go_next_state;

     localparam GS_WAIT_GO = 0,
                    GS_GO_1	  = 1,
                    GS_GO_2	  = 2,
                    GS_WAIT	  = 3;

     always @ (*) begin
        case (go_state)
            GS_WAIT_GO:
                go_next_state = go_key ? GS_GO_1 : GS_WAIT_GO;
            GS_GO_1:
                go_next_state = GS_GO_2;
            GS_GO_2:
                go_next_state = GS_WAIT;
            GS_WAIT:
                go_next_state = !go_key ? GS_WAIT_GO : GS_WAIT;
        endcase
     end

     always @ (*) begin
            go = ((go_state == GS_GO_1) || (go_state == GS_GO_2)) ? 1 : 0;
     end

     always @ (posedge clk) begin
            if (reset)
                go_state <= GS_WAIT_GO;
            else
                go_state <= go_next_state;
     end

    // ### Debug stuff. ###

     wire [4:0] current_state;

     hex_dec hd0 (.in(current_state), .out(HEX0));

     hex_dec hd1 (.in(go_state), .out(HEX1));

     hex_dec hd2 (.in(go_key), .out(HEX2));

     assign LEDR[3] = up;
     assign LEDR[2] = left;
     assign LEDR[1] = down;
     assign LEDR[0] = right;


    // ### Datapath and control. ###

    datapath d0 (
        .clk(clk), .reset(reset), .rnd_reset(rnd_reset),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2), .draw_river_obj_3(draw_river_obj_3),
        .draw_score(draw_score), .draw_lives(draw_lives),
        .move_objects(move_objects),
        .erase_frog(erase_frog),

        .draw_pot_obj_1_2(draw_pot_obj_1_2), .draw_pot_obj_1_3(draw_pot_obj_1_3), .draw_pot_obj_2_2(draw_pot_obj_2_2),
        .draw_pot_obj_2_3(draw_pot_obj_2_3), .draw_pot_obj_3_2(draw_pot_obj_3_2), .draw_pot_obj_3_3(draw_pot_obj_3_3),

        .ld_frog_loc(ld_frog_loc),

        .score(score), .lives(lives),

        .frame_tick(frame_tick),

        .left(left), .right(right), .up(up), .down(down),

        .plot_done(plot_done),

        .plot(plot), .x(x), .y(y), .color(color),

        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .plot_done(plot_done), .mov_key_pressed(mov_key_pressed),

        .dne_signal_1(dne_signal_1), .dne_signal_2(dne_signal_2),

        .frame_tick(frame_tick),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2), .draw_river_obj_3(draw_river_obj_3),
        .draw_score(draw_score), .draw_lives(draw_lives), .move_objects(move_objects),
        .erase_frog(erase_frog),

          .ld_frog_loc(ld_frog_loc),

          .draw_pot_obj_1_2(draw_pot_obj_1_2), .draw_pot_obj_1_3(draw_pot_obj_1_3), .draw_pot_obj_2_2(draw_pot_obj_2_2),
          .draw_pot_obj_2_3(draw_pot_obj_2_3), .draw_pot_obj_3_2(draw_pot_obj_3_2), .draw_pot_obj_3_3(draw_pot_obj_3_3),


          .current_state(current_state)
    );

    // ### VGA adapter. ###

    vga_adapter #(
        .RESOLUTION("320x240"),
        .MONOCHROME("FALSE"),
        .BITS_PER_COLOUR_CHANNEL(1),
        .BACKGROUND_IMAGE("mif_files/black.mif")
    ) vga (
        .clock(clk), .resetn(!reset),

        // Controlled signals.
        .x(x), .y(y), .colour(color),
        .plot(plot),

        // VGA DAC signals.
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B)
    );


    // ### Keyboard tracker. ###

          keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(
         .clock(CLOCK_50),
          .reset(!reset),
          .PS2_CLK(PS2_CLK),
          .PS2_DAT(PS2_DAT),
          .w(up),
          .a(left),
          .s(down),
          .d(right),
          .left(l),
          .right(r),
          .up(u),
          .down(d),
          .space(s),
          .enter(e)
          );


//    keyboard_tracker k0 (
//        .clock(clk), .reset(!reset),
//
//        .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),
//
//        .w(w), .a(a), .s(s), .d(d),
//        .left(left), .right(right), .up(up), .down(down),
//        .space(space), .enter(enter)
//    );


endmodule // top


/**
................................................................................
..Datapath......................................................................
................................................................................
**/

module datapath (
    clk, reset, rnd_reset,

    draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog,
    draw_river_obj_1, draw_river_obj_2, draw_river_obj_3,
    draw_score, draw_lives,
    move_objects,
    erase_frog,

    draw_pot_obj_1_2, draw_pot_obj_1_3, draw_pot_obj_2_2, draw_pot_obj_2_3, draw_pot_obj_3_2, draw_pot_obj_3_3,

    ld_frog_loc,

    score, lives,

    frame_tick,

    left, right, up, down,

    plot_done,

    plot, x, y, color,

    dne_signal_1, dne_signal_2,
    win, die
);

    // ### Inputs, outputs and wires. ###

    input clk, reset, rnd_reset;

    input draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    input draw_river_obj_1, draw_river_obj_2, draw_river_obj_3;
    input draw_pot_obj_1_2, draw_pot_obj_1_3, draw_pot_obj_2_2, draw_pot_obj_2_3, draw_pot_obj_3_2, draw_pot_obj_3_3;
    input draw_score, draw_lives;
    input move_objects;
    input erase_frog;
    input ld_frog_loc;

    input [3:0] score, lives;

    input left, right, up, down;

    output plot_done;

    // does not exist signal 1 and 2, alternate usage to prevent timing issues
    output reg dne_signal_1, dne_signal_2;

    wire plot_done_scrn, plot_done_char, plot_done_river_obj, plot_done_frog;
    assign plot_done = plot_done_scrn || plot_done_char || plot_done_river_obj || plot_done_frog;

    wire [8:0] next_x_scrn, next_x_char, next_x_river_obj, next_x_frog;
    wire [8:0] next_y_scrn, next_y_char, next_y_river_obj, next_y_frog;
    output reg [2:0] color;

    output plot;
    output reg [8:0] x;
    output reg [8:0] y;
    output win, die; // indicates that the player won the level, or fell into the water and lost (died)

    reg pre_plot;
    wire is_transparent;
    assign plot = pre_plot && !is_transparent;

    // top left coordinates of objects in the game
    reg [8:0] frog_x, frog_y;
    // first row of river objects
    reg [8:0] river_object_1_x, river_object_1_y, river_object_1_x_2, river_object_1_y_2, river_object_1_x_3, river_object_1_y_3;
    // second row of river objects
    reg [8:0] river_object_2_x, river_object_2_y, river_object_2_x_2, river_object_2_y_2, river_object_2_x_3, river_object_2_y_3;
    // third row of river objects
    reg [8:0] river_object_3_x, river_object_3_y, river_object_3_x_2, river_object_3_y_2, river_object_3_x_3, river_object_3_y_3;

    wire draw_pot_obj_1_2, draw_pot_obj_1_3, draw_pot_obj_2_2, draw_pot_obj_2_3, draw_pot_obj_3_2, draw_pot_obj_3_3;

    wire draw, draw_scrn, draw_char, draw_river_obj;
    assign draw = draw_scrn || draw_char || draw_river_obj || draw_frog || erase_frog;
    assign draw_scrn = draw_scrn_start || draw_scrn_game_over || draw_scrn_game_bg;
    assign draw_char = draw_score || draw_lives;
    assign draw_river_obj = draw_river_obj_1 || draw_river_obj_2 || draw_river_obj_3 ||
      draw_pot_obj_1_2 || draw_pot_obj_1_3 ||
      draw_pot_obj_2_2 || draw_pot_obj_2_3 ||
      draw_pot_obj_3_2 || draw_pot_obj_3_3;

     // ### Frog collision detection signals. ###

    // Center of frog is used for these locations, i.e. x = frog_x + 32 /2, y = frog_y + 24 / 2.

    wire on_river;
    assign on_river = (frog_y + 32 / 2 > 66) && (frog_y + 32 / 2 < 203); // vertical center of frog within river boundaries
    assign win = frog_y < 66 - 24 - 2; // river top boundary - frog height - a few pixels

    // Check on which river row the frog is.
    wire on_river_object, on_river_row_1, on_river_row_2, on_river_row_3;
    assign on_river_row_1 = (frog_y + 32 / 2 > 66) && (frog_y + 32 / 2 <= 111);
    assign on_river_row_2 = (frog_y + 32 / 2 > 111) && (frog_y + 32 / 2 <= 158);
    assign on_river_row_1 = (frog_y + 32 / 2 > 158) && (frog_y + 32 / 2 < 203);

    // Check whether the frog is on a river object and on which row.
    wire on_river_object_row_1, on_river_object_row_2, on_river_object_row_3;
    assign on_river_object_row_1 = on_river_row_1 && (
        (frog_x + 24 / 2 > river_object_1_x && frog_x + 24 / 2 < river_object_1_x + 96) ||
        (frog_x + 24 / 2 > river_object_1_x_2 && frog_x + 24 / 2 < river_object_1_x_2 + 96) ||
        (frog_x + 24 / 2 > river_object_1_x_3 && frog_x + 24 / 2 < river_object_1_x_3 + 96));
    assign on_river_object_row_2 = on_river_row_2 && (
        (frog_x + 24 / 2 > river_object_2_x && frog_x + 24 / 2 < river_object_2_x + 96) ||
        (frog_x + 24 / 2 > river_object_2_x_2 && frog_x + 24 / 2 < river_object_2_x_2 + 96) ||
        (frog_x + 24 / 2 > river_object_2_x_3 && frog_x + 24 / 2 < river_object_2_x_3 + 96));
    assign on_river_object_row_3 = on_river_row_3 && (
        (frog_x + 24 / 2 > river_object_3_x && frog_x + 24 / 2 < river_object_3_x + 96) ||
        (frog_x + 24 / 2 > river_object_3_x_2 && frog_x + 24 / 2 < river_object_3_x_2 + 96) ||
        (frog_x + 24 / 2 > river_object_3_x_3 && frog_x + 24 / 2 < river_object_3_x_3 + 96));

    assign on_river_object = on_river_object_row_1 || on_river_object_row_2 || on_river_object_row_3;

    assign die = on_river && !on_river_object;

     // ### Counter to delay the keyboard. ###

     wire [20:0] frame_counter;
     output frame_tick;
     assign frame_tick = frame_counter == 833332;

    counter counter0 (
        .clk(clk),
        .en(1),
        .rst(reset),
        .out(frame_counter)
    );

    // LFSR (Linear feedback shift register), outputs a random 13 bit number
    // bits [5:0] determine if additional random objects are generated
    //
    wire [12:0] rnd_generator;

    // Used for spawning river objects. Minimum distance is min_dist, max is
    // min_dist + 15
    wire [12:0]rnd_13_bit_num = rnd_generator;
    LFSR lfsr0 (
      .clock(clk),
      .reset(rnd_reset),
      .rnd(rnd_generator)
    );

    reg row_1_object_2_exists, row_1_object_3_exists;
    reg row_2_object_2_exists, row_2_object_3_exists;
    reg row_3_object_2_exists, row_3_object_3_exists;

    // get the 4 least significant bit
    // used in randomly generating river objects

    // ### Timing adjustments. ###

    wire new_frog_x, new_frog_y;
    assign new_frog_x = frog_x + right - left + on_river_object_row_1 - on_river_object_row_2 + on_river_object_row_3;
    assign new_frog_y = frog_y + down - left;

    always @ (posedge clk) begin
        // Plot signal, x and y need to be delayed by one clock cycle
        // due to delay of retrieving data from memory.
        // The x and y offsets specify the top left corner of the sprite
        // that is being drawn.
        pre_plot <= draw;

        // starting coordinates of the frog and river objects
        if (reset) begin
            frog_x <= 320 / 2 - 32 / 2; // spawn frog in middle horizontally
            frog_y <= 48; //row_1_object_2_exists 240 - 24 - 5; // spawn frog a few pixels from the bottom edge
            river_object_1_x <= 0;  // test spawn value = 20
            river_object_1_y <= 75;   // test spawn value = 80

            // potential river object
            if (rnd_13_bit_num[0] == 1) begin
              row_1_object_2_exists <= 1;
              river_object_1_x_2 <= 7'b1100000 + 4'b1010 + rnd_13_bit_num[12:9]; // 96 + 10 + X, X < 16
              river_object_1_y_2 <= 75;
            end else begin
              row_1_object_2_exists <= 0;
            end

            // potential river object
            if (rnd_13_bit_num[1] == 1) begin
              row_1_object_3_exists <= 1;
              river_object_1_x_3 <= 7'b1100000 + 4'b1010 + rnd_13_bit_num[9:6]; // 96 + 10 + X, X < 16
              river_object_1_y_3 <= 75;
            end else begin
              row_1_object_3_exists <= 0;
            end

            /** Second row of river object(s) **/
            river_object_2_x <= 319;  // test spawn value = 120
            river_object_2_y <= 115;  // test spawn value = 150

            // potential river object
            if (rnd_13_bit_num[2] == 1) begin
              row_2_object_2_exists <= 1;
              river_object_2_x_2 <= 7'b1100000 + 4'b1010 + rnd_13_bit_num[6:3];
              river_object_2_y_2 <= 115;
            end else begin
              row_2_object_2_exists <= 0;
            end

            // potential river object
            if (rnd_13_bit_num[3] == 1) begin
              row_2_object_3_exists <= 1;
              river_object_2_x_3 <= 7'b1100000 + 4'b1010 + rnd_13_bit_num[3:0];
              river_object_2_y_3 <= 115;
            end else begin
              row_2_object_3_exists <= 0;
            end

            /** Third row of river object(s) **/
            river_object_3_x <=  0;
            river_object_3_y <= 155;

            // potential river object
            if (rnd_13_bit_num[4] == 1) begin
              row_3_object_2_exists <= 1;
              river_object_3_x_2 <= 7'b1100000 + 4'b1010 + rnd_13_bit_num[11:8];
              river_object_3_y_2 <= 155;
            end else begin
              row_3_object_2_exists <= 0;
            end

            // potential river object
            if (rnd_13_bit_num[5] == 1) begin
              row_3_object_3_exists <= 1;
              river_object_3_x_3 <= 7'b1100000 + 4'b1010 + rnd_13_bit_num[8:3];
              river_object_3_y_3 <= 0;
            end else begin
              row_3_object_3_exists <= 0;
            end

        end else if (draw_river_obj_1) begin
            // river object 1 flows right at 60 pixels per second
            // object only moves horizontally
            x <= river_object_1_x + next_x_river_obj;
            y <= river_object_1_y + next_y_river_obj;

        end else if (draw_river_obj_2) begin
            // river object 2 flows left at 60 pixels per second
            // object only moves horizontally
            x <= river_object_2_x + next_x_river_obj;
            y <= river_object_2_y + next_y_river_obj;

        end else if (draw_river_obj_3) begin
            // river object 3 flows right at 60 pixels per second
            // object only moves horizontally
            x <= river_object_3_x + next_x_river_obj;
            y <= river_object_3_y + next_y_river_obj;
            // move the river object for the next frame

        end else if (draw_pot_obj_1_2) begin
            dne_signal_2 <= 0;
            if (row_1_object_2_exists) begin
              x <= river_object_1_x_2 + next_x_river_obj;
              y <= river_object_1_y_2 + next_y_river_obj;
            end else begin
              dne_signal_1 <= 1;
            end

        end else if (draw_pot_obj_1_3) begin
            dne_signal_1 <= 0;
            if (row_1_object_3_exists) begin
              x <= river_object_1_x_3 + next_x_river_obj;
              y <= river_object_1_y_3 + next_y_river_obj;
            end else begin
              dne_signal_2 <= 1;
            end

        end else if (draw_pot_obj_2_2) begin
            dne_signal_2 <= 0;
            if (row_2_object_2_exists) begin
              x <= river_object_2_x_2 + next_x_river_obj;
              y <= river_object_2_y_2 + next_y_river_obj;
            end else begin
              dne_signal_1 <= 1;
            end

        end else if (draw_pot_obj_2_3) begin
            dne_signal_1 <= 0;
            if (row_2_object_3_exists) begin
              x <= river_object_2_x_3 + next_x_river_obj;
              y <= river_object_2_y_3 + next_y_river_obj;
            end else begin
              dne_signal_2 <= 1;
            end

        end else if (draw_pot_obj_3_2) begin
            dne_signal_2 <= 0;
            if (row_3_object_2_exists) begin
              x <= river_object_3_x_2 + next_x_river_obj;
              y <= river_object_3_y_2 + next_y_river_obj;
            end else begin
              dne_signal_1 <= 1;
            end
        end else if (draw_pot_obj_3_3) begin
              dne_signal_1 <= 0;
            if (row_3_object_3_exists) begin
              x <= river_object_3_x_3 + next_x_river_obj;
              y <= river_object_3_y_3 + next_y_river_obj;
            end else begin
              dne_signal_2 <= 1;
            end

        end else if (draw_score) begin
            x <= 300 + next_x_char;
            y <= 8 + next_y_char;
        end else if (draw_lives) begin
            x <= 300 + next_x_char;
            y <= 23 + next_y_char;
        end else if (draw_frog) begin
            x <= frog_x + next_x_frog;
            y <= frog_y + next_y_frog;
        end else if (move_objects) begin
            // flows right
            river_object_1_x <= river_object_1_x + 1;
            // flows left
            river_object_2_x <= river_object_2_x - 1;
            // flows right
            river_object_3_x <= river_object_3_x + 1;


            if(row_1_object_2_exists) begin
              river_object_1_x_2 <= river_object_1_x_2 + 1;
              river_object_1_y_2 <= river_object_1_y_2 + 1;
            end

            if(row_1_object_3_exists) begin
              river_object_1_x_3 <= river_object_1_x_3 + 1;
              river_object_1_y_3 <= river_object_1_y_3 + 1;
            end

            if(row_2_object_2_exists) begin
              river_object_2_x_2 <= river_object_2_x_2 - 1;
              river_object_2_y_2 <= river_object_2_y_2 - 1;
            end

            if(row_2_object_3_exists) begin
              river_object_2_x_3 <= river_object_2_x_3 - 1;
              river_object_2_y_3 <= river_object_2_y_3 - 1;
            end

            if(row_3_object_2_exists) begin
              river_object_3_x_2 <= river_object_3_x_2 + 1;
              river_object_3_y_2 <= river_object_3_y_2 + 1;
            end

            if(row_3_object_3_exists) begin
              river_object_3_x_3 <= river_object_3_x_3 + 1;
              river_object_3_y_3 <= river_object_3_y_3 + 1;
            end
            // check left and right boundaries (max x = resolution width - frog width - 1)
            if ((new_frog_x >= 0) && (new_frog_x <= 320 - 32 - 1)) begin
                // update top left pixel's x coordinate if possible
                frog_x <= new_frog_x;
            end

            // check up and down boundaries (max y = resolution height - frog height - 1)
            if ((new_frog_y >= 0) && (new_frog_y <= 240 - 24 - 1)) begin
                // update top left pixel's y coordinate if possible
                frog_y <= new_frog_y;
            end

        end else begin
            x <= next_x_scrn;
            y <= next_y_scrn;
        end
    end
//            if(left && next_x_frog - 1 >= 0) begin
//                x <= next_x_frog  - 1;
//            end else if(right && next_x_frog + 1 <= 288) begin
//                x <= next_x_frog + 1;
//            end else if(up && next_y_frog - 1 >= 0) begin
//                y <= next_y_frog - 1;
//            end else if(down && next_y_frog + 1 <= 216) begin
//                y <= next_y_frog + 1;
//            end
        // end else if (erase_frog) begin
        //         x <= frog_x + next_x_frog;
        //         y <= frog_y + next_y_frog;

        //
        //   if (ld_frog_loc) begin
        //         frog_x <= frog_x + right - left;
        //         frog_y <= frog_y - up + down;
        //   end

    // ### Plotters. ###

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(320),
        .MAX_Y(240)
    ) plt_scrn (
        .clk(clk), .en(draw_scrn && !plot_done),
        .x(next_x_scrn), .y(next_y_scrn),
        .done(plot_done_scrn)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(7),
        .MAX_Y(10)
    ) plt_char (
        .clk(clk), .en(draw_char && !plot_done),
        .x(next_x_char), .y(next_y_char),
        .done(plot_done_char)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(96),
        .MAX_Y(30)
    ) plt_river_obj (
        .clk(clk), .en(draw_river_obj && !plot_done),
        .x(next_x_river_obj), .y(next_y_river_obj),
        .done(plot_done_river_obj)
    );

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(32),
        .MAX_Y(24)
    ) plt_frog (
        .clk(clk), .en((draw_frog || erase_frog) && !plot_done),
        .x(next_x_frog), .y(next_y_frog),
        .done(plot_done_frog)
    );

    // ### Start screen. ###

    wire [2:0] scrn_start_color;

    sprite_ram_module #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .RESOLUTION_X(320),
        .RESOLUTION_Y(240),
        .MIF_FILE("graphics/game_start.mif")
    ) srm_scrn_start (
        .clk(clk),
        .x(next_x_scrn), .y(next_y_scrn),
        .color_out(scrn_start_color)
    );

    // ### Game over screen. ###

    wire [2:0] scrn_game_over_color;

    sprite_ram_module #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .RESOLUTION_X(320),
        .RESOLUTION_Y(240),
        .MIF_FILE("graphics/game_over.mif")
    ) srm_scrn_game_over (
        .clk(clk),
        .x(next_x_scrn), .y(next_y_scrn),
        .color_out(scrn_game_over_color)
    );

    // ### Game background screen. ###

    wire [2:0] scrn_game_bg_color;

    sprite_ram_module #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .RESOLUTION_X(320),
        .RESOLUTION_Y(240),
        .MIF_FILE("graphics/game_background.mif")
    ) srm_scrn_game_bg (
        .clk(clk),
        .x(erase_frog ? frog_x + next_x_frog : next_x_scrn), .y(erase_frog ? frog_y + next_y_frog : next_y_scrn),
        .color_out(scrn_game_bg_color)
    );

    // ### Frog. ###

    wire [2:0] frog_color;

    sprite_ram_module #(
        .WIDTH_X(5),
        .WIDTH_Y(5),
        .RESOLUTION_X(32),
        .RESOLUTION_Y(24),
        .MIF_FILE("graphics/frog.mif")
    ) srm_frog (
        .clk(clk),
        .x(next_x_frog), .y(next_y_frog),
        .color_out(frog_color)
    );


    // ### River objects. ###

    wire [2:0] river_obj_1_color, river_obj_2_color;

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("graphics/river_object_1.mif")
    ) srm_river_obj_1 (
        .clk(clk),
        .x(next_x_river_obj), .y(next_y_river_obj),
        .color_out(river_obj_1_color)
    );

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("graphics/river_object_2.mif")
    ) srm_river_obj_2 (
        .clk(clk),
        .x(next_x_river_obj), .y(next_y_river_obj),
        .color_out(river_obj_2_color)
    );

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("graphics/river_object_1.mif")
    ) srm_river_obj_3 (
        .clk(clk),
        .x(next_x_river_obj), .y(next_y_river_obj),
        .color_out(river_obj_1_color)
    );

    // ### Score and life counters. ###

    wire [2:0] score_color, lives_color;

    numchar_ram_module nc_score (
        .clk(clk),
        .numchar(score),
        .x(next_x_char), .y(next_y_char),
        .color_out(score_color)
    );

    numchar_ram_module nc_lives (
        .clk(clk),
        .numchar(lives),
        .x(next_x_char), .y(next_y_char),
        .color_out(lives_color)
    );

    // ### Color mux. ###

    assign is_transparent = draw_frog && frog_color == 0;

    always @ (*) begin
        // Color is set based on which draw signal is high.
        if (draw_scrn_start)
            color = scrn_start_color;
        else if (draw_scrn_game_over)
            color = scrn_game_over_color;
        else if (draw_scrn_game_bg)
            color = scrn_game_bg_color;
        else if (draw_river_obj_1)
            color = river_obj_1_color;
        else if (draw_river_obj_2)
            color = river_obj_2_color;
        else if (draw_score)
            color = score_color;
        else if (draw_lives)
            color = lives_color;
        else if (erase_frog)
            color = scrn_game_bg_color;
        else if (draw_frog)
            color = frog_color;
        else
            color = 0;
    end

endmodule

/**
................................................................................
..Datapath_End..................................................................
................................................................................
**/

/**
................................................................................
..Control.......................................................................
................................................................................
**/
module control (
    clk, reset,

    go, plot_done, mov_key_pressed,
    win, die,

    dne_signal_1, dne_signal_2,

    frame_tick,

    draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog,
    draw_river_obj_1, draw_river_obj_2, draw_river_obj_3,
    draw_score, draw_lives,
    move_objects,
    erase_frog,

    ld_frog_loc,

    draw_pot_obj_1_2, draw_pot_obj_1_3, draw_pot_obj_2_2, draw_pot_obj_2_3, draw_pot_obj_3_2, draw_pot_obj_3_3,


    current_state
);

    input clk, reset;
    input go, plot_done, mov_key_pressed;
    input dne_signal_1, dne_signal_2;
    input win, die;
    input frame_tick;

    output reg draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    output reg draw_river_obj_1, draw_river_obj_2, draw_river_obj_3;
    output reg draw_score, draw_lives;
    output reg move_objects;
    output reg erase_frog;
    output reg ld_frog_loc;

    output reg draw_pot_obj_1_2, draw_pot_obj_1_3, draw_pot_obj_2_2, draw_pot_obj_2_3, draw_pot_obj_3_2, draw_pot_obj_3_3;

    output reg [4:0] current_state;
    reg [4:0] next_state;

    // States.
    localparam  S_WAIT_START            = 0,    // Wait before drawing START screen.
                S_DRAW_SCRN_START       = 1,    // Draw START screen.
                S_WAIT_GAME_OVER        = 2,    // Wait before drawing GAME OVER screen.
                S_DRAW_SCRN_GAME_OVER   = 3,    // Draw GAME OVER screen.
                S_WAIT_GAME_BG          = 4,    // Wait before drawing game background.
                S_DRAW_GAME_BG          = 5,    // Draw game background.
                S_DRAW_SCORE            = 6,    // Draw score counter.
                S_DRAW_LIVES            = 7,    // Draw lives counter.
                S_WAIT_RIVER_OBJ        = 8,    // Wait before drawing river objects.
                S_DRAW_RIVER_OBJ_1      = 9,    // Draw river object 1.
                  S_DRAW_POT_OBJ_1_2      = 10,   // Potential river object 2 (1).
                  S_DRAW_POT_OBJ_1_3      = 11,   // Potential river object 3 (1).
                S_DRAW_RIVER_OBJ_2      = 12,   // Draw river object 2.
                  S_DRAW_POT_OBJ_2_2      = 13,   // Potential river object 2 (2).
                  S_DRAW_POT_OBJ_2_3      = 14,   // Potential river object 3 (2).
                S_DRAW_RIVER_OBJ_3      = 15,   // Draw river object 3.
                  S_DRAW_POT_OBJ_3_2      = 16,   // Potential river object 2 (3).
                  S_DRAW_POT_OBJ_3_3      = 17,   // Potential river object 3 (3).
                S_WAIT_FROG             = 18,   // Wait before drawing frog.
                S_DRAW_FROG             = 19,   // Draw frog.
                S_MOVE_OBJECTS           = 20,   // Move objects for the next cycle. (One cycle is from state 4 to 15)
                S_WAIT_FRAME_TICK       = 21;   // Wait for frame tick.
                // S_WAIT_FROG_MOVEMENT    = 13,   // Wait before preceding to movement state.
                // S_FROG_MOVEMENT         = 14;   // Movement state of frog (When key is pressed).
                // S_DRAW_FROG             = 12,   // Draw frog.
                // S_LOAD_FROG_LOC         = 13,   // Wait to erase the frog.
                // S_ERASE_FROG            = 14;   // Erase frog.

    // State table.
    always @ (*) begin
        case (current_state)
            S_WAIT_START:
                next_state = go ? S_DRAW_SCRN_START : S_WAIT_START;
            S_DRAW_SCRN_START:
                next_state = plot_done ? S_WAIT_GAME_OVER : S_DRAW_SCRN_START;
            S_WAIT_GAME_OVER:
                next_state = go ? S_DRAW_SCRN_GAME_OVER : S_WAIT_GAME_OVER;
            S_DRAW_SCRN_GAME_OVER:
                next_state = plot_done ? S_WAIT_GAME_BG : S_DRAW_SCRN_GAME_OVER;
            S_WAIT_GAME_BG:
                next_state = go ? S_DRAW_GAME_BG : S_WAIT_GAME_BG;
            S_DRAW_GAME_BG:
                next_state = plot_done ? S_DRAW_SCORE : S_DRAW_GAME_BG;
            S_DRAW_SCORE:
                next_state = plot_done ? S_DRAW_LIVES : S_DRAW_SCORE;
            S_DRAW_LIVES:
                next_state = plot_done ? S_DRAW_RIVER_OBJ_1 : S_DRAW_LIVES;
            S_WAIT_RIVER_OBJ:
                next_state = go ? S_DRAW_RIVER_OBJ_1 : S_WAIT_RIVER_OBJ;
            S_DRAW_RIVER_OBJ_1:
                next_state = plot_done ? S_DRAW_RIVER_OBJ_2 : S_DRAW_RIVER_OBJ_1;
            S_DRAW_RIVER_OBJ_2:
                next_state = plot_done ? S_DRAW_RIVER_OBJ_3 : S_DRAW_RIVER_OBJ_2;
            // newly added third row of objects
            S_DRAW_RIVER_OBJ_3:
                next_state = plot_done ? S_DRAW_POT_OBJ_1_2 : S_DRAW_RIVER_OBJ_3;

            // potential river objects
            S_DRAW_POT_OBJ_1_2:
                if(dne_signal_1 || plot_done) begin
                  next_state = S_DRAW_POT_OBJ_1_3;
                end else begin
                  next_state = S_DRAW_POT_OBJ_1_2;
                end
                // next_state = plot_done ? S_DRAW_POT_OBJ_1_3 : S_DRAW_POT_OBJ_1_2;

            // potential river objects
            S_DRAW_POT_OBJ_1_3:

              if(dne_signal_2 || plot_done) begin
                next_state = S_DRAW_POT_OBJ_2_2;
              end else begin
                next_state = S_DRAW_POT_OBJ_1_3;
              end
                // next_state = plot_done ? S_DRAW_POT_OBJ_2_2 : S_DRAW_POT_OBJ_1_3;

            S_DRAW_POT_OBJ_2_2:

              if(dne_signal_1 || plot_done) begin
                next_state = S_DRAW_POT_OBJ_2_3;
              end else begin
                next_state = S_DRAW_POT_OBJ_2_2;
              end
                // next_state = plot_done ? S_DRAW_POT_OBJ_2_3 : S_DRAW_POT_OBJ_2_2;

            S_DRAW_POT_OBJ_2_3:

              if(dne_signal_2 || plot_done) begin
                next_state = S_DRAW_POT_OBJ_3_2;
              end else begin
                next_state = S_DRAW_POT_OBJ_2_3;
              end
                // next_state = plot_done ? S_DRAW_POT_OBJ_3_2 : S_DRAW_POT_OBJ_2_3;

            S_DRAW_POT_OBJ_3_2:

              if(dne_signal_1 || plot_done) begin
                next_state = S_DRAW_POT_OBJ_3_3;
              end else begin
                next_state = S_DRAW_POT_OBJ_3_2;
              end
                // next_state = plot_done ? S_DRAW_POT_OBJ_3_3 : S_DRAW_POT_OBJ_3_2;

            S_DRAW_POT_OBJ_3_3:

              if(dne_signal_2 || plot_done) begin
                next_state = S_DRAW_FROG;
              end else begin
                next_state = S_DRAW_POT_OBJ_3_3;
              end
                // next_state = plot_done ? S_DRAW_FROG : S_DRAW_POT_OBJ_3_3;

            // New changes (need to be tested)
            S_WAIT_FROG:
                next_state = go ? S_DRAW_FROG : S_WAIT_FROG;
            S_DRAW_FROG:
                next_state = plot_done ? S_MOVE_OBJECTS : S_DRAW_FROG;
            S_MOVE_OBJECTS:
                next_state = S_WAIT_FRAME_TICK;
            S_WAIT_FRAME_TICK:
                next_state = frame_tick ? S_DRAW_GAME_BG : S_WAIT_FRAME_TICK;
                // if(plot_done && mov_key_pressed)
                //   next_state = S_DRAW_GAME_BG;
                // else
                //   next_state = S_DRAW_FROG;

            // S_WAIT_FROG_MOVEMENT:
            //     next_state = go ? S_FROG_MOVEMENT : S_WAIT_FROG_MOVEMENT;
            // S_FROG_MOVEMENT:
            //     next_state = mov_key_pressed ? S_DRAW_GAME_BG : S_FROG_MOVEMENT;

            // S_WAIT_FROG:
            //     next_state = go ? S_ERASE_FROG : S_WAIT_FROG;
            // S_ERASE_FROG:
            //     next_state = plot_done ? S_LOAD_FROG_LOC: S_ERASE_FROG;
            //    S_LOAD_FROG_LOC:
            //          next_state = S_DRAW_FROG;
            // S_DRAW_FROG:
            //     next_state = frame_tick ? S_ERASE_FROG: S_DRAW_FROG;
        endcase
    end

    // State switching and reset.
    always @ (posedge clk) begin
        if (reset)
            current_state <= S_WAIT_START;
        else
            current_state <= next_state;
    end

    // Output logic.
    always @ (*) begin
        // Reset control signals.
        draw_scrn_start = 0;
        draw_scrn_game_over = 0;
        draw_scrn_game_bg = 0;
        draw_score = 0;
        draw_lives = 0;
        draw_river_obj_1 = 0;
        draw_river_obj_2 = 0;
        draw_river_obj_3 = 0;
        draw_frog = 0;
        move_objects = 0;
        erase_frog = 0;
        ld_frog_loc = 0;

        draw_pot_obj_1_2 = 0;
        draw_pot_obj_1_3 = 0;
        draw_pot_obj_2_2 = 0;
        draw_pot_obj_2_3 = 0;
        draw_pot_obj_3_2 = 0;
        draw_pot_obj_3_3 = 0;

        // Set control signals based on state.
        case (current_state)
            S_DRAW_SCRN_START: begin
                draw_scrn_start = 1;
            end
            S_DRAW_SCRN_GAME_OVER: begin
                draw_scrn_game_over = 1;
            end
            S_DRAW_GAME_BG: begin
                draw_scrn_game_bg = 1;
            end
            S_DRAW_SCORE: begin
                draw_score = 1;
            end
            S_DRAW_LIVES: begin
                draw_lives = 1;
            end
            S_DRAW_RIVER_OBJ_1: begin
                draw_river_obj_1 = 1;
            end
            S_DRAW_RIVER_OBJ_2: begin
                draw_river_obj_2 = 1;
            end
            S_DRAW_RIVER_OBJ_3: begin
                draw_river_obj_3 = 1;
            end
            S_DRAW_FROG: begin
                draw_frog = 1;
            end
            S_MOVE_OBJECTS: begin
                move_objects = 1;
            end

            S_DRAW_POT_OBJ_1_2: begin
                draw_pot_obj_1_2 = 1;
            end

            S_DRAW_POT_OBJ_1_3: begin
                draw_pot_obj_1_3 = 1;
            end

            S_DRAW_POT_OBJ_2_2: begin
                draw_pot_obj_2_2 = 1;
            end

            S_DRAW_POT_OBJ_2_3: begin
                draw_pot_obj_2_3 = 1;
            end

            S_DRAW_POT_OBJ_3_2: begin
                draw_pot_obj_3_2 = 1;
            end

            S_DRAW_POT_OBJ_3_3: begin
                draw_pot_obj_3_3 = 1;
            end

        endcase
    end

endmodule

/**
................................................................................
..CONTROL_END...................................................................
................................................................................
**/


module hex_dec(in, out);
    input [3:0] in;
    output reg [6:0] out;

    always @(*)
        case (in)
            4'h0: out = 7'b100_0000;
            4'h1: out = 7'b111_1001;
            4'h2: out = 7'b010_0100;
            4'h3: out = 7'b011_0000;
            4'h4: out = 7'b001_1001;
            4'h5: out = 7'b001_0010;
            4'h6: out = 7'b000_0010;
            4'h7: out = 7'b111_1000;
            4'h8: out = 7'b000_0000;
            4'h9: out = 7'b001_1000;
            4'hA: out = 7'b000_1000;
            4'hB: out = 7'b000_0011;
            4'hC: out = 7'b100_0110;
            4'hD: out = 7'b010_0001;
            4'hE: out = 7'b000_0110;
            4'hF: out = 7'b000_1110;
            default: out = 7'h7f;
        endcase
endmodule
