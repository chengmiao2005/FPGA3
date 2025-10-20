`timescale 1ns / 1ns

module tb_vga_ctrl();

// 输入信号
reg vga_clk;
reg sys_rst_n;
reg [15:0] pix_data;

// 输出信号
wire [9:0] pix_x;
wire [9:0] pix_y;
wire hsync;
wire vsync;
wire [15:0] rgb;

// 生成25MHz VGA时钟
initial begin
    vga_clk = 1'b0;
    forever #20 vga_clk = ~vga_clk;  // 20ns周期 = 50MHz，实际应为25MHz，这里加速仿真
end

// 初始化和复位
initial begin
    sys_rst_n = 1'b0;
    pix_data = 16'h0000;
    #100 sys_rst_n = 1'b1;  // 100ns后释放复位
    
    // 模拟像素数据输入
    #10000 pix_data = 16'hF800;  // 红色
    #50000 pix_data = 16'h07E0;  // 绿色
    #50000 pix_data = 16'h001F;  // 蓝色
    #50000 $stop;  // 停止仿真
end

// 实例化被测试模块
vga_ctrl vga_ctrl_inst (
    .vga_clk    (vga_clk),
    .sys_rst_n  (sys_rst_n),
    .pix_data   (pix_data),
    .pix_x      (pix_x),
    .pix_y      (pix_y),
    .hsync      (hsync),
    .vsync      (vsync),
    .rgb        (rgb)
);

// 监控信号变化
initial begin
    $monitor("Time: %0t, hsync: %b, vsync: %b, pix_x: %d, pix_y: %d, rgb: %h",
             $time, hsync, vsync, pix_x, pix_y, rgb);
end

endmodule
    
