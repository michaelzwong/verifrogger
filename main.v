`include "vga.v"
`include "vga_adapter/vga_pll.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_adapter.v"


module main_test ();

    // ### Wires. ###

    wire clk, reset;
    wire go;

    wire draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;

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
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog)

        .plot_done(plot_done),

        .plot(plot), .x(x), .y(y), .color(color)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .plot_done(plot_done),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg), .draw_frog(draw_frog)
    );

endmodule // main_test 

module top (
    
);

endmodule // top 

module datapath (
    clk, reset,

    draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog

    plot_done,

    plot, x, y, color
);

    // ### Inputs, outputs and wires. ###

    input clk, reset;

    input draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg, draw_frog;

    output plot_done;

    wire [8:0] next_x;
    wire [8:0] next_y;
    output reg [2:0] color;

    output reg plot;
    output reg [8:0] x;
    output reg [8:0] y;

    wire draw;
    assign draw = draw_scrn_start || draw_scrn_game_over || draw_scrn_game_bg || draw_frog;

    // ### Timing adjustments. ###

    always @ (posedge clk) begin
        // Plot signal, x and y need to be delayed by one clock cycle
        // due to delay of retrieving data from memory.
        plot <= draw;
        x <= next_x;
        y <= next_y;
    end

    // ### Plotter. ###

    plotter #(
        .WIDTH_X(9),
        .WIDTH_Y(9),
        .MAX_X(10),
        .MAX_Y(6)
    ) plt_scrn_start (
        .clk(clk), .en(draw),
        .x(next_x), .y(next_y),
        .done(plot_done)
    );

    // ### Start screen. ###

    wire [2:0] scrn_start_color;

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("mif_files/test.mif")
    ) srm_scrn_start (
        .clk(clk),
        .x(next_x), .y(next_y),
        .color_out(scrn_start_color)
    );

    // ### Game over screen. ###

    wire [2:0] scrn_game_over_color;

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("mif_files/test.mif")
    ) srm_scrn_game_over (
        .clk(clk),
        .x(next_x), .y(next_y),
        .color_out(scrn_game_over_color)
    );

    // ### Game background screen. ###

    wire [2:0] scrn_game_bg_color;

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("mif_files/test.mif")
    ) srm_scrn_game_bg (
        .clk(clk),
        .x(next_x), .y(next_y),
        .color_out(scrn_game_bg_color)
    );

    // ### Frog. ###

    wire [2:0] frog_color;

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("mif_files/test.mif")
    ) srm_frog ( 
        .clk(clk),
        .x(next_x), .y(next_y),
        .color_out(frog_color)
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
        else 
            color = 0;
    end

endmodule // datapath

module control (
    clk, reset,
    go, plot_done,

    draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg
);

    input clk, reset;
    input go, plot_done;

    output reg draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg;

    reg [2:0] current_state, next_state;

    // States.
    localparam  S_WAIT_START            = 0,    // Wait before drawing START screen.
                S_DRAW_SCRN_START       = 1,    // Draw START screen.
                S_WAIT_GAME_OVER        = 2,    // Wait before drawing GAME OVER screen.
                S_DRAW_SCRN_GAME_OVER   = 3,    // Draw GAME OVER screen.
                S_WAIT_GAME_BG          = 4,    // Wait before drawing game background.
                S_DRAW_GAME_BG          = 5;    // Draw game background.
                // Add frog movement states here?

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
                next_state = plot_done ? S_WAIT_START : S_DRAW_GAME_BG;
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
        endcase
    end

endmodule // control  