`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/26 10:35:15
// Design Name: 
// Module Name: color_detect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module color_detect (
    input clk,
    input reset,
    input [9:0] x_pixel,
    input [9:0] y_pixel,
    input [3:0] R,
    input [3:0] G,
    input [3:0] B,
    output logic blue_detect, 
    output logic red_detect,
    output logic o_frame_end
);

    // --- ?îÑ?†à?ûÑ Î∞? ?òÅ?ó≠ ?†ï?ùò ---
    localparam int FRAME_WIDTH  = 320;
    localparam int FRAME_HEIGHT = 240;
    localparam int HALF_HEIGHT  = FRAME_HEIGHT / 2; // 120 

    // --- ?Éâ?ÉÅ ?ûÑÍ≥ÑÍ∞í (4-bit RGB) ---
    localparam int COLOR_HIGH_THRESHOLD = 10;
    localparam int COLOR_LOW_THRESHOLD  = 5;

    // --- ?îΩ?? Ïπ¥Ïö¥?Ñ∞ (32ÎπÑÌä∏) ---
    reg [31:0] blue_U_count; 
    reg [31:0] blue_D_count; 
    reg [31:0] red_U_count;  
    reg [31:0] red_D_count; 
    logic frame_end;

    assign o_frame_end = frame_end;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            blue_U_count   <= 0;
            blue_D_count   <= 0;
            red_U_count    <= 0;
            red_D_count    <= 0;
            blue_detect <= 0;
            red_detect  <= 0;
        end else begin
            
            // (0, 0) Î™®Îì† Ïπ¥Ïö¥?Ñ∞ Ï¥àÍ∏∞?ôî
            if (x_pixel == 0 && y_pixel == 0) begin
                blue_U_count <= 0;
                blue_D_count <= 0;
                red_U_count  <= 0;
                red_D_count  <= 0;
            end 
            
            // (320, 240): Ïπ¥Ïö¥?ä∏ ÎπÑÍµê Î∞? Í≤∞Í≥º Ï∂úÎ†•
            else if (x_pixel == FRAME_WIDTH && y_pixel == FRAME_HEIGHT) begin
                blue_detect <= (blue_U_count > blue_D_count); 
                red_detect  <= (red_U_count > red_D_count);  
                frame_end <= 1;
            end 
            
            // ?îÑ?†à?ûÑ ?Ç¥Î∂? ?îΩ?? Ï≤òÎ¶¨
            else if (x_pixel < FRAME_WIDTH && y_pixel < FRAME_HEIGHT) begin
                if ((R < COLOR_LOW_THRESHOLD) && (G < COLOR_LOW_THRESHOLD) && (B > COLOR_HIGH_THRESHOLD)) begin
                    if (y_pixel < HALF_HEIGHT) begin // ?ÉÅ?ã® ?òÅ?ó≠
                        blue_U_count <= blue_U_count + 1;
                    end else begin // ?ïò?ã® ?òÅ?ó≠
                        blue_D_count <= blue_D_count + 1;
                    end
                end 
                else if ((R > COLOR_HIGH_THRESHOLD) && (G < COLOR_LOW_THRESHOLD) && (B < COLOR_LOW_THRESHOLD)) begin
                    if (y_pixel < HALF_HEIGHT) begin // ?ÉÅ?ã® ?òÅ?ó≠
                        red_U_count <= red_U_count + 1;
                    end else begin // ?ïò?ã® ?òÅ?ó≠
                        red_D_count <= red_D_count + 1;
                    end
                end
            end
        end
    end

endmodule

// module color_detect(
//     input  logic       clk,
//     input  logic       reset,
//     input  logic [9:0] x_pixel,
//     input  logic [9:0] y_pixel,
//     input  logic [3:0] R,
//     input  logic [3:0] G,
//     input  logic [3:0] B,
//     output logic       blue_detect,
//     output logic       red_detect
// );

//     // ÔøΩÿΩÔøΩ∆Æ ÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ (text_displayÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩÔøΩœ∞ÔøΩ)
//     localparam int CHAR_WIDTH  = 8;
//     localparam int CHAR_HEIGHT = 8;
//     localparam int MAX_CHARS   = 5;
//     localparam int CAM_WIDTH   = 320;
//     localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS * CHAR_WIDTH) / 2;
//     localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS * CHAR_WIDTH;
//     localparam int TEXT_Y_START = 16;
//     localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             blue_detect <= 0;
//             red_detect  <= 0;
//         end else begin
//             // ÔøΩÿΩÔøΩ∆Æ ÔøΩÔøΩÔøΩÔøΩ ÔøΩ»øÔøΩÔøΩÔøΩ ÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ
//             if (x_pixel >= TEXT_X_START && x_pixel < TEXT_X_END &&
//                 y_pixel >= TEXT_Y_START && y_pixel < TEXT_Y_END) begin

//                 // ÔøΩƒ∂ÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ (ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ)
//                 if (B > 10 && R < 5 && G < 5) begin
//                     blue_detect <= 1;
//                     red_detect  <= 0;
//                 end 
//                 // ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ (ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ)
//                 else if (R > 10 && G < 5 && B < 5) begin
//                     blue_detect <= 0;
//                     red_detect  <= 1;
//                 end 
//                 else begin
//                     blue_detect <= 0;
//                     red_detect  <= 0;
//                 end

//             end else begin
//                 // ÔøΩÿΩÔøΩ∆Æ ÔøΩÔøΩÔøΩÔøΩ ÔøΩ€øÔøΩÔøΩÔøΩÔøΩÔøΩ detect ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ
//                 blue_detect <= 0;
//                 red_detect  <= 0;
//             end
//         end
//     end

// endmodule


//module color_detect(
//    input  logic       clk,
//    input  logic       reset,
//    input  logic [9:0] x_pixel,
//    input  logic [9:0] y_pixel,
//    input  logic [3:0] R,
//    input  logic [3:0] G,
//    input  logic [3:0] B,
//    output logic       blue_detect,
//    output logic       red_detect
//);

//    // ÔøΩÿΩÔøΩ∆Æ ÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ (text_displayÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩÔøΩœ∞ÔøΩ)
//    localparam int CHAR_WIDTH  = 8;
//    localparam int CHAR_HEIGHT = 8;
//    localparam int MAX_CHARS   = 5;
//    localparam int CAM_WIDTH   = 320;
//    localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS*CHAR_WIDTH)/2;
//    localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS*CHAR_WIDTH;
//    localparam int TEXT_Y_START = 16;
//    localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

//    always_ff @(posedge clk or posedge reset) begin
//        if(reset) begin
//            blue_detect <= 0;
//            red_detect  <= 0;
//        end else begin
//            // ÔøΩÿΩÔøΩ∆Æ ÔøΩÔøΩÔøΩÔøΩ ÔøΩ»øÔøΩÔøΩÔøΩ ÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ
//            if(x_pixel >= TEXT_X_START && x_pixel < TEXT_X_END &&
//               y_pixel >= TEXT_Y_START && y_pixel < TEXT_Y_END) begin

//                if(B > 10) begin //if(R < 5 && G < 5 && B > 10) begin
//                    blue_detect <= 1;
//                    red_detect  <= 0;
//                end else if(R > 10) begin //end else if(R > 10 && G < 5 && B < 5) begin
//                    blue_detect <= 0;
//                    red_detect  <= 1;
//                end else begin
//                    blue_detect <= 0;
//                    red_detect  <= 0;
//                end

//            end else begin
//                // ÔøΩÿΩÔøΩ∆Æ ÔøΩÔøΩÔøΩÔøΩ ÔøΩ€øÔøΩÔøΩÔøΩÔøΩÔøΩ detect ÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩÔøΩ ÔøΩÔøΩÔøΩÔøΩ
//                blue_detect <= 0;
//                red_detect  <= 0;
//            end
//        end
//    end

//endmodule




//module color_detect(
//    input  logic       clk,
//    input  logic       reset,
//    input  logic [9:0] x_pixel,
//    input  logic [9:0] y_pixel,
//    input  logic [3:0] R,
//    input  logic [3:0] G,
//    input  logic [3:0] B,
//    output logic       blue_detect,
//    output logic       red_detect
//);

//    reg [31:0] blue_count;
//    reg [31:0] red_count;

//    always_ff @(posedge clk, posedge reset) begin
//        if(reset) begin
//            blue_count   <= 0;
//            red_count    <= 0;
//            blue_detect  <= 0;
//            red_detect   <= 0;
//        end else begin
//            if(x_pixel == 0 && y_pixel == 0) begin
//                blue_count <= 0;
//                red_count  <= 0;
//            end

//            if(R < 5 && G < 5 && B > 10)       blue_count <= blue_count + 1; // ÔøΩƒ∂ÔøΩ
//            else if(R > 10 && G < 5 && B < 5)  red_count  <= red_count + 1;  // ÔøΩÔøΩÔøΩÔøΩ

//            if(x_pixel == 639 && y_pixel == 479) begin
//                blue_detect <= (blue_count > 0);
//                red_detect  <= (red_count  > 0);
//            end
//        end
//    end
//endmodule

