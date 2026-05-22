`timescale 1ns / 1ps

module clock_divider (
    input wire clk_in,       // 100 MHz input
    output wire clk_out      // 25 MHz output
);

    reg [1:0] div = 0;

    always @(posedge clk_in) begin
        div <= div + 1;
    end

    assign clk_out = div[1]; // divide by 4 → 25 MHz

endmodule