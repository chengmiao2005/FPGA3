`timescale 1ns / 1ns
module DevelopmentBoard(
    input clk,
    input rst,
    input B2,
    input B3,
    input B4,
    input B5,
    output h_sync,
    output v_sync,
    output [15:0] rgb
);

// 注释原有模块（如Simple_VGA，根据实际代码调整）
// Simple_VGA u_Simple_VGA(
//     .clk(clk),
//     .rst(rst),
//     .h_sync(h_sync),
//     .v_sync(v_sync),
//     .rgb(rgb)
// );

vga_top u_vga_top(
    .clk(clk),
    .rst(rst),
    .h_sync(h_sync),
    .v_sync(v_sync),
    .rgb(rgb)
);

endmodule
