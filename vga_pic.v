`timescale 1ns / 1ns

module vga_pic(
    input wire vga_clk,          //VGA working clock, 25MHz
    input wire sys_rst_n,        //Reset signal. Low level is effective
    input wire [9:0] pix_x,      //X coordinate of current pixel
    input wire [9:0] pix_y,      //Y coordinate of current pixel
    input wire up,
    input wire down,
    input wire left,
    input wire right,

    output reg [15:0] pix_data   //Color information
);

////
//\* Parameter and Internal Signal \//
////
//parameter define
parameter H_VALID = 10'd640,     //Maximum x value
          V_VALID = 10'd480;     //Maximum y value

parameter RED     = 16'hF800,    //RED
          ORANGE  = 16'hFC00,    //Orange
          YELLOW  = 16'hFFE0,    //Yellow
          GREEN   = 16'h07E0,    //Green
          CYAN    = 16'h07FF,    //Cyan
          BLUE    = 16'h001F,    //Blue
          PURPPLE = 16'hF81F,    //Purple
          BLACK   = 16'h0000,    //Black
          WHITE   = 16'hFFFF,    //White
          GRAY    = 16'hD69A;    //Grey

// Letter parameters
parameter LETTER_WIDTH = 80;      // Width of each letter
parameter LETTER_HEIGHT = 120;    // Height of each letter
parameter LETTER_SPACING = 20;    // Spacing between letters
parameter TEXT_COLOR = WHITE;     // Text color
parameter BACKGROUND_COLOR = PURPPLE; // Background color

// Calculate starting position to center the text
parameter TEXT_TOTAL_WIDTH = 4 * LETTER_WIDTH + 3 * LETTER_SPACING;
parameter TEXT_START_X = (H_VALID - TEXT_TOTAL_WIDTH) / 2;
parameter TEXT_START_Y = (V_VALID - LETTER_HEIGHT) / 2;

// Function to check if pixel is within a rectangle
function is_in_rect;
    input [9:0] x, y, rect_x, rect_y, rect_w, rect_h;
    begin
        is_in_rect = (x >= rect_x) && (x < rect_x + rect_w) && 
                     (y >= rect_y) && (y < rect_y + rect_h);
    end
endfunction

// Function to draw letter M
function draw_M;
    input [9:0] x, y, base_x, base_y;
    reg [9:0] rel_x, rel_y;
    begin
        rel_x = x - base_x;
        rel_y = y - base_y;
        
        // Draw M shape - two vertical lines and two diagonal lines
        draw_M = ((rel_x < 10) ||                           // Left vertical
                 (rel_x >= LETTER_WIDTH - 10) ||           // Right vertical
                 ((rel_x >= 10) && (rel_x < LETTER_WIDTH/2) && 
                  (rel_y < (LETTER_HEIGHT/2)) && (rel_x == rel_y + 10)) || // Left diagonal
                 ((rel_x >= LETTER_WIDTH/2) && (rel_x < LETTER_WIDTH - 10) && 
                  (rel_y < (LETTER_HEIGHT/2)) && (rel_x + rel_y == LETTER_WIDTH - 10))); // Right diagonal
    end
endfunction

// Function to draw letter U
function draw_U;
    input [9:0] x, y, base_x, base_y;
    reg [9:0] rel_x, rel_y;
    begin
        rel_x = x - base_x;
        rel_y = y - base_y;
        
        // Draw U shape - two vertical lines and a bottom curve
        draw_U = ((rel_x < 10) ||                           // Left vertical
                 (rel_x >= LETTER_WIDTH - 10) ||           // Right vertical
                 (rel_y >= LETTER_HEIGHT - 20) && (rel_x >= 10) && (rel_x < LETTER_WIDTH - 10)); // Bottom horizontal
    end
endfunction

// Function to draw letter S
function draw_S;
    input [9:0] x, y, base_x, base_y;
    reg [9:0] rel_x, rel_y;
    begin
        rel_x = x - base_x;
        rel_y = y - base_y;
        
        // Draw S shape - complex shape with curves
        draw_S = ((rel_y < 10) && (rel_x >= 10) && (rel_x < LETTER_WIDTH - 10)) || // Top horizontal
                 ((rel_y >= 10) && (rel_y < LETTER_HEIGHT/2 - 10) && (rel_x < 10)) || // Top left vertical
                 ((rel_y >= LETTER_HEIGHT/2 - 10) && (rel_y < LETTER_HEIGHT/2 + 10) && 
                  (rel_x >= 10) && (rel_x < LETTER_WIDTH - 10)) || // Middle horizontal
                 ((rel_y >= LETTER_HEIGHT/2 + 10) && (rel_y < LETTER_HEIGHT - 10) && 
                  (rel_x >= LETTER_WIDTH - 10)) || // Bottom right vertical
                 ((rel_y >= LETTER_HEIGHT - 10) && (rel_x >= 10) && (rel_x < LETTER_WIDTH - 10)); // Bottom horizontal
    end
endfunction

// Function to draw letter T
function draw_T;
    input [9:0] x, y, base_x, base_y;
    reg [9:0] rel_x, rel_y;
    begin
        rel_x = x - base_x;
        rel_y = y - base_y;
        
        // Draw T shape - top horizontal and center vertical
        draw_T = ((rel_y < 10) && (rel_x >= 10) && (rel_x < LETTER_WIDTH - 10)) || // Top horizontal
                 ((rel_y >= 10) && (rel_x >= LETTER_WIDTH/2 - 5) && (rel_x < LETTER_WIDTH/2 + 5)); // Center vertical
    end
endfunction

// Generate color based on pixel position
always @(*) begin
    if (!sys_rst_n) begin
        pix_data = BACKGROUND_COLOR;
    end else begin
        // Check if pixel is within any letter area
        if (is_in_rect(pix_x, pix_y, TEXT_START_X, TEXT_START_Y, TEXT_TOTAL_WIDTH, LETTER_HEIGHT)) begin
            // Letter M
            if (is_in_rect(pix_x, pix_y, TEXT_START_X, TEXT_START_Y, LETTER_WIDTH, LETTER_HEIGHT)) begin
                pix_data = draw_M(pix_x, pix_y, TEXT_START_X, TEXT_START_Y) ? TEXT_COLOR : BACKGROUND_COLOR;
            end
            // Letter U
            else if (is_in_rect(pix_x, pix_y, TEXT_START_X + LETTER_WIDTH + LETTER_SPACING, TEXT_START_Y, LETTER_WIDTH, LETTER_HEIGHT)) begin
                pix_data = draw_U(pix_x, pix_y, TEXT_START_X + LETTER_WIDTH + LETTER_SPACING, TEXT_START_Y) ? TEXT_COLOR : BACKGROUND_COLOR;
            end
            // Letter S
            else if (is_in_rect(pix_x, pix_y, TEXT_START_X + 2*(LETTER_WIDTH + LETTER_SPACING), TEXT_START_Y, LETTER_WIDTH, LETTER_HEIGHT)) begin
                pix_data = draw_S(pix_x, pix_y, TEXT_START_X + 2*(LETTER_WIDTH + LETTER_SPACING), TEXT_START_Y) ? TEXT_COLOR : BACKGROUND_COLOR;
            end
            // Letter T
            else if (is_in_rect(pix_x, pix_y, TEXT_START_X + 3*(LETTER_WIDTH + LETTER_SPACING), TEXT_START_Y, LETTER_WIDTH, LETTER_HEIGHT)) begin
                pix_data = draw_T(pix_x, pix_y, TEXT_START_X + 3*(LETTER_WIDTH + LETTER_SPACING), TEXT_START_Y) ? TEXT_COLOR : BACKGROUND_COLOR;
            end
            else begin
                pix_data = BACKGROUND_COLOR;
            end
        end else begin
            pix_data = BACKGROUND_COLOR;
        end
    end
end

endmodule
