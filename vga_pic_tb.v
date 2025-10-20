`timescale 1ns / 1ns

module vga_pic_tb;

// Inputs
reg vga_clk;
reg sys_rst_n;
reg [9:0] pix_x;
reg [9:0] pix_y;
reg up;
reg down;
reg left;
reg right;

// Outputs
wire [15:0] pix_data;

// Instantiate the Unit Under Test (UUT)
vga_pic uut (
    .vga_clk(vga_clk),
    .sys_rst_n(sys_rst_n),
    .pix_x(pix_x),
    .pix_y(pix_y),
    .up(up),
    .down(down),
    .left(left),
    .right(right),
    .pix_data(pix_data)
);

// Clock generation
initial begin
    vga_clk = 0;
    forever #20 vga_clk = ~vga_clk; // 25MHz clock (40ns period)
end

// VGA pixel coordinate generation
integer x, y;
initial begin
    pix_x = 0;
    pix_y = 0;
    
    // Simulate VGA scanning
    forever begin
        for (y = 0; y < 480; y = y + 1) begin
            for (x = 0; x < 640; x = x + 1) begin
                pix_x = x;
                pix_y = y;
                #40; // Wait for one clock cycle
            end
        end
    end
end

// Test sequence
initial begin
    // Initialize Inputs
    sys_rst_n = 0;
    up = 1;
    down = 1;
    left = 1;
    right = 1;
    
    // Wait 100 ns for global reset to finish
    #100;
    sys_rst_n = 1;
    
    // Test normal operation
    #100000;
    
    // Test button presses
    up = 0;
    #100;
    up = 1;
    
    #50000;
    
    down = 0;
    #100;
    down = 1;
    
    #50000;
    
    left = 0;
    #100;
    left = 1;
    
    #50000;
    
    right = 0;
    #100;
    right = 1;
    
    #100000;
    
    // End simulation
    $display("Simulation finished");
    $stop;
end

// Monitor important signals
initial begin
    $monitor("Time: %0t, pix_x: %d, pix_y: %d, pix_data: %h", 
             $time, pix_x, pix_y, pix_data);
end

// Create VCD file for waveform analysis
initial begin
    $dumpfile("vga_pic_waveform.vcd");
    $dumpvars(0, vga_pic_tb);
end

endmodule
