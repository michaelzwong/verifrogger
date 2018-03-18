module top (
    
);

endmodule // top 

module datapath (
  
);

endmodule // datapath

module control (
    clk, reset,
    go, plot_done
);

    input clk, reset;
    input go, plot_done;

    reg [2:0] current_state, next_state;

    // States.
    localparam  S_WAIT_START            = 0,    // Wait before drawing START screen.
                S_DRAW_SCRN_START       = 1,    // Draw START screen.
                S_WAIT_GAME_OVER        = 2,    // Wait before drawing GAME OVER screen.
                S_DRAW_SCRN_GAME_OVER   = 3,    // Draw GAME OVER screen.
                S_WAIT_SUCCESS          = 4,    // Wait before drawing SUCCESS screen.
                S_DRAW_SCRN_SUCCESS     = 5,    // Draw SUCCESS screen.
                S_WAIT_GAME_BG          = 6,    // Wait before drawing game background.
                S_DRAW_GAME_BG          = 7;    // Draw game background.
                // Add frog movement states here?

    // State table.
    always @ (posedge clk) begin
        case (current_state)
            S_WAIT_START:
                next_state = go ? S_DRAW_SCRN_START : S_DRAW_SCRN_START;
            S_DRAW_SCRN_START:
                next_state = plot_done ? S_WAIT_GAME_OVER : S_DRAW_SCRN_START;
            S_WAIT_GAME_OVER:
                next_state = go ? S_DRAW_SCRN_GAME_OVER : S_WAIT_GAME_OVER;
            S_DRAW_SCRN_GAME_OVER:
                next_state = plot_done ? S_WAIT_GAME_OVER : S_WAIT_SUCCESS;
            S_WAIT_SUCCESS:
                next_state = go ? S_DRAW_SCRN_SUCCESS : S_WAIT_SUCCESS;
            S_DRAW_SCRN_SUCCESS:
                next_state = plot_done ? S_WAIT_GAME_BG : S_DRAW_SCRN_SUCCESS;
            S_WAIT_GAME_BG:
                next_state = go ? S_DRAW_GAME_BG : S_WAIT_GAME_BG;
            S_DRAW_GAME_BG:
                next_state = plot_done ? S_WAIT_START : S_DRAW_GAME_BG;
        endcase

        // Output logic.
        always @ (*) begin
            // Reset control signals.

            // Set control signals based on state.
            case (current_state) 

            endcase
        end
    end

endmodule // control  