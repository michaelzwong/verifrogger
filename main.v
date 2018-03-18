`include "vga.v"
`include "vga_adapter/vga_adapter.v"

module main_test ();

    wire clk, reset;
    wire go;

    wire draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg;

    wire plot_done;


    datapath d0 (
        .clk(clk), .reset(reset),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg),

        .plot_done(plot_done)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(go), .plot_done(plot_done),

        .draw_scrn_start(draw_scrn_start), .draw_scrn_game_over(draw_scrn_game_over),
        .draw_scrn_game_bg(draw_scrn_game_bg)
    );

endmodule // main_test 

module top (
    
);

endmodule // top 

module datapath (
    clk, reset,

    draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg,

    plot_done
);

    // ### Inputs, outputs and wires. ###

    input clk, reset;

    input draw_scrn_start, draw_scrn_game_over, draw_scrn_game_bg;

    output plot_done;

    wire [3:0] next_x;
    wire [2:0] next_y;
    wire [2:0] color;

    reg plot;
    reg [3:0] x;
    reg [2:0] y;

    // ### Timing adjustments. ###

    always @ (posedge clk) begin
        // Plot signal, x and y need to be delayed by one clock cycle
        // due to delay of retrieving data from memory.
        plot <= draw_scrn_start;
        x <= next_x;
        y <= next_y;
    end

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
        .x(x), .y(y),
        .color_out(scrn_start_color)
    );

    plotter #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .MAX_X(10),
        .MAX_Y(6)
    ) plt_scrn_start (
        .clk(clk), .en(draw_scrn_start),
        .x(next_x), .y(next_y),
        .done(plot_done)
    );

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
                next_state = plot_done ? S_WAIT_GAME_OVER : S_WAIT_GAME_BG;
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