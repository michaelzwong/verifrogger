module vga_test ();
    
    wire clk;
    wire [3:0] x;
    wire [2:0] y;
    wire [2:0] color;

    sprite_ram_module #(
        .WIDTH_X(4),
        .WIDTH_Y(3),
        .RESOLUTION_X(10),
        .RESOLUTION_Y(6),
        .MIF_FILE("mif_files/test.mif")
    ) srm0 (
        .clk(clk),
        .x(x), .y(y),
        .color_out(color)
    );

endmodule // vga_test 

module sprite_ram_module (
    clk,
    x, y,
    color_out
);

    parameter WIDTH_X = 1;
    parameter WIDTH_Y = 1;
    parameter WIDTH_ADDRESS = WIDTH_X + WIDTH_Y;

    parameter RESOLUTION_X = 1;
    parameter RESOLUTION_Y = 1;

    parameter MIF_FILE = "UNUSED";

    input clk;
    input [WIDTH_X - 1:0] x;
    input [WIDTH_Y - 1:0] y;
    
    output [2:0] color_out;

    wire [WIDTH_ADDRESS - 1:0] address;
    assign address = x + y * RESOLUTION_X;

    altsyncram #(
        .operation_mode ("SINGLE_PORT"),
        .width_a        (3),
        .widthad_a      (WIDTH_ADDRESS),
        .init_file      (MIF_FILE)
    ) ram0 ( 
        .clock0     (clk),
        .address_a  (address),
        .q_a        (color_out)
    );
    

endmodule // sprite_ram_module

