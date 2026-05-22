`timescale 1ns / 1ps

module top (
    input wire clk,          // 100 MHz
    output wire hsync,
    input wire btn_up,
    input wire btn_down,
    output wire vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b
);

    wire pixel_clk;
    wire [9:0] x;
    wire [9:0] y;
    wire visible;

    // Clock divider (100 MHz → 25 MHz)
    clock_divider clk_div_inst (
        .clk_in(clk),
        .clk_out(pixel_clk)
    );

    // VGA timing generator
    vga_timing timing_inst (
        .pixel_clk(pixel_clk),
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync),
        .visible(visible)
    );

    // Video generator (currently white screen)
    video_generator video_inst (
        .visible(visible),
        .x(x),
        .y(y),
        .r(vga_r),
        .g(vga_g),
        .b(vga_b),
        .clk(pixel_clk),
        .btn_up(btn_up),
        .btn_down(btn_down)
    );

endmodule