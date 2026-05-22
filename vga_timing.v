`timescale 1ns / 1ps

module vga_timing (
    input wire pixel_clk,
    output reg [9:0] x,   // current horizontal position
    output reg [9:0] y,   // current vertical position
    output wire hsync,
    output wire vsync,
    output wire visible   // HIGH when inside visible screen area
);

    // 640x480 @ 60Hz
    parameter H_VISIBLE = 640;
    parameter H_FRONT   = 16; // front porch
    parameter H_SYNC    = 96;
    parameter H_BACK    = 48; // back porch
    parameter H_TOTAL   = 800;

    parameter V_VISIBLE = 480;
    parameter V_FRONT   = 10; // front porch
    parameter V_SYNC    = 2;
    parameter V_BACK    = 33; // back porch
    parameter V_TOTAL   = 525;

    always @(posedge pixel_clk) begin
        if (x == H_TOTAL - 1) begin  // if we reach the end of the row
            x <= 0;                  // go back the the first pixel
                            
            if (y == V_TOTAL - 1)    // if we reach the last row of the frame
                y <= 0;              // go back to the top corner for the new frame
            else
                y <= y + 1;  // move one row down
        end else begin
            x <= x + 1;      // move one pixel to the right
        end
    end


    // active low -> when 0, tells monitor to start a new line
    assign hsync = ~(x >= (H_VISIBLE + H_FRONT) && // after visible + front 
                     x <  (H_VISIBLE + H_FRONT + H_SYNC)); // before the end of hsync


    // active low -> when 0, tells monitor to start a new frame from the top left pixel
    assign vsync = ~(y >= (V_VISIBLE + V_FRONT) && // after visible + front porch
                     y <  (V_VISIBLE + V_FRONT + V_SYNC)); // before the end of vsync


    // high only when x and y are inside the 640 x 480 area
    assign visible = (x < H_VISIBLE) && (y < V_VISIBLE);
endmodule
