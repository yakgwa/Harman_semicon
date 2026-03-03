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
//     input i_enable,
//     input i_clear
// );

// parameter F_COUNTER = 10_000_000;
// reg [$clog2(F_COUNTER) - 1 : 0] r_counter;
// reg r_clk_10kz;

// assign o_tick = r_clk_10kz;

// always@(posedge clk or posedge rst) begin
//     if(rst | i_clear) begin
//         r_counter <= 0;
//         r_clk_10kz <= 0;
//     end else begin
//         if(i_enable) begin
//             r_counter <= r_counter + 1;
//             r_clk_10kz <= 0;
//             if(r_counter == F_COUNTER -1) begin
//                 r_counter <= 0;
//                 r_clk_10kz <= 1'b1;
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

    //parameter F_COUNER = 10_000_000;
    parameter F_COUNTER = 10_000;
    reg [$clog2(F_COUNTER) - 1 : 0] r_counter;
    reg r_clk_10kz;

    // Registers for button edge detection and run state
    reg r_enable_prev;
    reg r_run;

    // Assign the output based on the tick register
    assign o_tick = r_clk_10kz;

    // Main sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst | i_clear) begin
            // Asynchronous reset or clear
            r_counter <= 0;
            r_clk_10kz <= 0;
            r_enable_prev <= 0;
            r_run <= 0;
        end else begin
            // Store the previous state of the enable signal for edge detection
            r_enable_prev <= i_enable;

            // Detect a rising edge on the i_enable input
            if (i_enable && !r_enable_prev) begin
                // Toggle the run state on the rising edge
                r_run <= !r_run;
            end

            // Main counter logic, now controlled by the r_run state
            if (r_run) begin
                r_counter <= r_counter + 1;
                r_clk_10kz <= 0;
                if (r_counter == F_COUNTER - 1) begin
                    r_counter <= 0;
                    r_clk_10kz <= 1'b1;
                end 
            end else begin
                // Keep the counter value when not running
                r_counter <= r_counter;
                r_clk_10kz <= 0;
            end
        end
    end

endmodule
