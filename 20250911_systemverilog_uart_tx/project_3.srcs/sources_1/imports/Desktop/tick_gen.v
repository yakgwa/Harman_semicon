`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 15:13:28
// Design Name: 
// Module Name: tick_gen
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


// module tick_gen(
//     input clk,
//     input rst,
//     output o_tick,
    // input i_enable,
    // input i_clear
//     );

//     parameter FCOUNT = 10_000_000; 
//     reg r_clk_10hz;
//     reg [$clog2(FCOUNT) - 1 : 0] r_counter; // for 10hz

//     assign o_tick = r_clk_10hz;

//     always@(posedge clk or posedge rst) begin
//         if(rst | i_clear) begin
//             r_counter <= 0;
//             r_clk_10hz <= 1;
//         end else begin
//             if (r_counter == FCOUNT - 1) begin
//                 r_counter <= 0;
//                 r_clk_10hz <= 1;
//             end else begin
//                 if(r_counter == FCOUNT/2 - 1) begin
//                     r_clk_10hz <= 0;
//                 end
//                 r_counter = r_counter + 1; 
//             end
//         end
//     end
// endmodule

// module tick_gen(
//     input clk,
//     input rst,
//     output o_tick,
//     input i_enable,
//     input i_clear
// );

// // counter 10_000_000
// parameter F_COUNTER = 10_000_000;
// reg [$clog2(F_COUNTER) - 1 : 0] r_counter;
// reg r_clk_10kz;

// assign o_tick = r_clk_10kz;

// always@(posedge clk or posedge rst) begin
//     if(rst | i_clear) begin
//         r_counter <= 0;
//         r_clk_10kz <= 1;
//     end else begin
//         if(i_enable) begin
//             r_counter <= 1'b1;
//             r_clk_10kz <= 1'b1;
//         if(r_counter == F_COUNTER -1) begin
//             r_counter <= 0;
//             r_clk_10kz <= 1'b1;
//             end
//         end else begin
//             r_counter <= r_counter;
//         end
//     end
// end

// endmodule

module tick_gen(
    input clk,
    input rst,
    output o_tick,
    input i_enable,
    input i_clear
);

parameter F_COUNTER = 10_000_000;
reg [$clog2(F_COUNTER) - 1 : 0] r_counter;
reg r_clk_10kz;

assign o_tick = r_clk_10kz;

always@(posedge clk or posedge rst) begin
    if(rst | i_clear) begin
        r_counter <= 0;
        r_clk_10kz <= 0;
    end else begin
        if(i_enable) begin
            r_counter <= r_counter + 1;
            r_clk_10kz <= 0;
            if(r_counter == F_COUNTER -1) begin
                r_counter <= 0;
                r_clk_10kz <= 1'b1;
            end 
        end else begin
            r_counter <= r_counter;
        end
    end
end

endmodule