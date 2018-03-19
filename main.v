`include "vga.v"
`include "vga_adapter/vga_pll.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_adapter.v"
`include "ps2keyboard/PS2_Keyboard_Controller.v"
`include "counter.v"



module main_test ();

    // ### Wires. ###

    wire clk, reset;
    wire go;

    wire draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    wire draw_river_obj_1, draw_river_obj_2;
    wire draw_score, draw_lives;
    wire erase_frog;

    wire [3:0] score, lives;

    wire plot_done;

    wire plot;
    wire [8:0] x, y;
    wire [2:0] color;

    // VGA wires.
    wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    wire [9:0] VGA_R, VGA_G, VGA_B;

    // ### Datapath and control. ###

    datapath d0 (
        .clk(clk), .reset(reset),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2),
        .draw_score(draw_score), .draw_lives(draw_lives), .erase_frog(erase_frog),

        .score(score), .lives(lives),

        .plot_done(plot_done),

        .plot(plot), .x(x), .y(y), .color(color)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .plot_done(plot_done),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2),
        .draw_score(draw_score), .draw_lives(draw_lives), .erase_frog(erase_frog)
    );

endmodule // main_test 

module top (
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
    wire go = !KEY[0];
    wire reset = !KEY[3];
    wire enable = !KEY[2];

    wire [3:0] score = SW[3:0]; 
    wire [3:0] lives = SW[7:4];

    wire draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    wire draw_river_obj_1, draw_river_obj_2;
    wire draw_score, draw_lives;
    wire erase_frog;

    wire plot_done;

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

    // The output from the counter for the keyboard.
    wire keyboard_clock;

    // Since both w, a, s, d and up, left, down, right are the same controls, the wires can be combined.
    wire up_c, left_c, down_c, right_c

    assign up_c = w || up;
    assign left_c = a || left;
    assign down_c = s || down;
    assign right_c = d || right;

    // ### Datapath and control. ###

    datapath d0 (
        .clk(clk), .reset(reset),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2),
        .draw_score(draw_score), .draw_lives(draw_lives),
        .erase_frog(erase_frog),

        .score(score), .lives(lives),

        .left(left_c), .right(right_c), .up(up_c), .down(down_c),

        .plot_done(plot_done),

        .plot(plot), .x(x), .y(y), .color(color)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .plot_done(plot_done),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog),
        .draw_river_obj_1(draw_river_obj_1), .draw_river_obj_2(draw_river_obj_2),
        .draw_score(draw_score), .draw_lives(draw_lives),
        .erase_frog(erase_frog)
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

    // ### Counter to delay the keyboard. ###
    counter counter0 {
        .clock(clock),
        .en(enable),
        .rst(reset),
        .out(keyboard_clock)
    }

    // ### Keyboard tracker. ###
    keyboard_tracker k0(
        .clock(keyboard_clock), .reset(reset),

        .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),

        .w(w), .a(a), .s(s), .d(d),
        .left(left), .right(right), .up(up), .down(down),
        .space(space), .enter(enter)
    );


endmodule // top 

module datapath (
    clk, reset,

    draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog,
    draw_river_obj_1, draw_river_obj_2,
    draw_score, draw_lives,
    erase_frog,

    score, lives,

    left, right, up, down,

    plot_done,

    plot, x, y, color
);

    // ### Inputs, outputs and wires. ###

    input clk, reset;

    input draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    input draw_river_obj_1, draw_river_obj_2;
    input draw_score, draw_lives;
    input erase_frog;

    input [3:0] score, lives;

    input left, right, up, down;

    output plot_done;
    wire plot_done_scrn, plot_done_char, plot_done_river_obj;
    assign plot_done = plot_done_scrn || plot_done_char || plot_done_river_obj;

    wire [8:0] next_x_scrn, next_x_char, next_x_river_obj, next_x_frog;
    wire [8:0] next_y_scrn, next_y_char, next_y_river_obj, next_y_frog;
    output reg [2:0] color;

    output reg plot;
    output reg [8:0] x;
    output reg [8:0] y;

    wire draw, draw_scrn, draw_char, draw_river_obj;
    assign draw = draw_scrn || draw_char || draw_river_obj || draw_frog;
    assign draw_scrn = draw_scrn_start || draw_scrn_game_over || draw_scrn_game_bg;
    assign draw_char = draw_score || draw_lives;
    assign draw_river_obj = draw_river_obj_1 || draw_river_obj_2;

    // ### Timing adjustments. ###

    always @ (posedge clk) begin
        // Plot signal, x and y need to be delayed by one clock cycle
        // due to delay of retrieving data from memory.
        // The x and y offsets specify the top left corner of the sprite 
        // that is being drawn.
        plot <= draw;
        if (draw_river_obj_1) begin
            x <= 20 + next_x_river_obj;
            y <= 80 + next_y_river_obj;
        end else if (draw_river_obj_2) begin
            x <= 120 + next_x_river_obj;
            y <= 150 + next_y_river_obj;
        end else if (draw_score) begin
            x <= 300 + next_x_char;
            y <= 14 + next_y_char;
        end else if (draw_lives) begin
            x <= 300 + next_x_char;
            y <= 27 + next_y_char;
        end else if (draw_frog) begin
            if(left && next_x_frog - 1 >= 0) begin
                x <= next_x_frog  - 1;
            end else if(right && next_x_frog + 1 <= 288) begin
                x <= next_x_frog + 1;
            end else if(up && next_y_frog - 1 >= 0) begin
                y <= next_y_frog - 1;
            end else if(down && next_y_frog + 1 <= 216) begin
                y <= next_y_frog + 1;
            end
        end else if (erase_frog) begin
            x <= next_x_frog;
            y <= next_y_frog;
        end
        end else begin
            x <= next_x_scrn;
            y <= next_y_scrn;
        end
    end

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
        .MAX_Y(40)
    ) plt_river_obj (
        .clk(clk), .en(draw_river_obj && !plot_done),
        .x(next_x_river_obj), .y(next_y_river_obj),
        .done(plot_done_river_obj) 
    );

    plotter #(
        .WIDTH_X(5),
        .WIDTH_Y(5),
        .MAX_X(32),
        .MAX_Y(24)
    ) plt_frog (
        .clk(clk), .en(draw_frog && !plot_done),
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
        .x(next_x_scrn), .y(next_y_scrn),
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

    always @ (*) begin
        // Color is set based on which draw signal is high.        
        if (draw_scrn_start)
            color = scrn_start_color;
        else if (draw_scrn_game_over)
            color = scrn_game_over_color;
        else if (draw_scrn_game_bg) 
            color = scrn_game_bg_color;
        else if (draw_frog)
            color = frog_color;
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
        else 
            color = 0;
    end

endmodule // datapath

module control (
    clk, reset,
    go, plot_done,

    draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog,
    draw_river_obj_1, draw_river_obj_2,
    draw_score, draw_lives,
    erase_frog
);

    input clk, reset;
    input go, plot_done;

    output reg draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;
    output reg draw_river_obj_1, draw_river_obj_2;
    output reg draw_score, draw_lives;
    output reg erase_frog;

    reg [3:0] current_state, next_state;

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
                S_DRAW_RIVER_OBJ_2      = 10;   // Draw river object 2.
                S_WAIT_FROG             = 11;   // Wait before drawing frog.
                S_DRAW_FROG             = 12;   // Draw frog.
                S_WAIT_ERASE_FROG       = 13;   // Wait to erase the frog.
                S_ERASE_FROG            = 14;   // Erase frog.

    // State table.
    always @ (posedge clk) begin
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
                next_state = plot_done ? S_WAIT_RIVER_OBJ : S_DRAW_LIVES;
            S_WAIT_RIVER_OBJ:
                next_state = go ? S_DRAW_RIVER_OBJ_1 : S_WAIT_RIVER_OBJ;
            S_DRAW_RIVER_OBJ_1:
                next_state = plot_done ? S_DRAW_RIVER_OBJ_2 : S_DRAW_RIVER_OBJ_1;
            S_DRAW_RIVER_OBJ_2:
                next_state = plot_done ? S_WAIT_FROG : S_DRAW_RIVER_OBJ_2;
            S_WAIT_FROG:
                next_state = go ? S_DRAW_FROG : S_WAIT_FROG;
            S_DRAW_FROG:
                next_state = plot_done ? S_WAIT_ERASE_FROG: S_DRAW_FROG;
            S_WAIT_ERASE_FROG:
                next_state = go ? S_ERASE_FROG: S_WAIT_ERASE_FROG;
            S_ERASE_FROG:
                next_state = plot_done ? S_WAIT_START: S_ERASE_FROG;

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
        draw_frog = 0;
        erase_frog = 0;


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
            S_DRAW_FROG: begin
                draw_frog = 1;
            end
            S_ERASE_FROG: begin
                erase_frog = 1;
            end
        endcase
    end

endmodule // control  