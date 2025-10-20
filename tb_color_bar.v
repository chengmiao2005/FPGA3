`timescale 1ns / 1ns

module tb_color_bar();

// 输入信号
reg sys_clk;
reg sys_rst_n;

// 输出信号
wire hsync;
wire vsync;
wire [15:0] rgb;

// 生成50MHz系统时钟
initial begin
    sys_clk = 1'b0;
    forever #10 sys_clk = ~sys_clk;  // 10ns周期 = 50MHz
end

// 初始化和复位
initial begin
    sys_rst_n = 1'b0;
    #200 sys_rst_n = 1'b1;  // 200ns后释放复位
    
    // 运行足够长的时间以观察多个帧
    #1000000 $stop;  // 1ms后停止仿真
end

// 实例化顶层模块
ColorBar color_bar_inst (
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .hsync      (hsync),
    .vsync      (vsync),
    .rgb        (rgb)
);

// 监控关键信号
initial begin
    $monitor("Time: %0t, hsync: %b, vsync: %b, rgb: %h",
             $time, hsync, vsync, rgb);
end

// 波形记录（可选，用于仿真工具查看）
initial begin
    $dumpfile("color_bar_wave.vcd");
    $dumpvars(0, tb_color_bar);
end

endmodule
    
