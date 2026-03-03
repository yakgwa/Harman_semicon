`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/11 11:24:57
// Design Name: 
// Module Name: counter
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

module counter(
    input logic clk,
    input logic reset,
    input logic runstop,
    input logic clear,
    output logic [13:0] o_counter
    );

    wire w_tick_10hz;

    clk_gen_10hz U_CLK_GEN_10HZ(
        .clk(clk),
        .reset(reset),
        .o_clk_10hz(w_tick_10hz)
    );

    counter_10000 U_COUNTER_10000(
        .clk(w_tick_10hz),
        .reset(reset),
        .runstop(runstop),
        .clear(clear),
        .o_counter(o_counter)
    );

endmodule

module counter_10000(
    input clk,
    input reset,
    input runstop,
    input clear,
    output [13:0] o_counter
);

reg [$clog2(10_000) - 1 : 0] r_counter;

assign o_counter = r_counter;

always@(posedge clk or posedge reset) begin
    if(reset | clear) begin
        r_counter <= 0;
    end else begin
        if(runstop) begin
            if(r_counter == 10000 -1) begin
                r_counter <= 0;
            end else begin
                r_counter <= r_counter + 1;
            end
        end
    end
end

endmodule


module clk_gen_10hz(
    input clk,
    input reset,
    output o_clk_10hz
);

// counter 10_000_000
parameter F_COUNTER = 10_000_000;
reg [$clog2(F_COUNTER) - 1 : 0] r_counter;
reg r_clk_10kz;

assign o_clk_10hz = r_clk_10kz;

always@(posedge clk or posedge reset) begin
    if(reset) begin
        r_counter <= 0;
        r_clk_10kz <= 1;
    end else begin
        if(r_counter == F_COUNTER -1) begin
            r_counter <= 0;
            r_clk_10kz <= 1'b1;
        end else begin
            if(r_counter == F_COUNTER/2 - 1) begin
                r_clk_10kz <= 1'b0;
            end
            r_counter <= r_counter + 1;
        end
    end
end

endmodule


// module counter(
//     input logic clk,
//     input logic reset,
//     output logic [13:0] o_counter
//     );

//     wire w_tick_10hz;

//     clk_gen_10hz U_CLK_GEN_10HZ(
//         .clk(clk),
//         .reset(reset),
//         .o_clk_10hz(w_tick_10hz)
//     );

//     counter_10000 U_COUNTER_10000(
//         .clk(w_tick_10hz),
//         .reset(reset),
//         .o_counter(o_counter)
//     );

// endmodule

// module counter_10000(
//     input clk,
//     input reset,
//     output [13:0] o_counter
// );

// reg [$clog2(10_000) - 1 : 0] r_counter;

// assign o_counter = r_counter;

// always@(posedge clk or posedge reset) begin
//     if(reset) begin
//         r_counter <= 0;
//     end else begin
//         if(r_counter == 10000 -1) begin
//             r_counter <= 0;
//         end else begin
//             r_counter <= r_counter + 1;
//         end
//     end
// end

// endmodule


// module clk_gen_10hz(
//     input clk,
//     input reset,
//     output o_clk_10hz
// );

// // counter 10_000_000
// parameter F_COUNTER = 10_000_000;
// reg [$clog2(F_COUNTER) - 1 : 0] r_counter;
// reg r_clk_10kz;

// assign o_clk_10hz = r_clk_10kz;

// always@(posedge clk or posedge reset) begin
//     if(reset) begin
//         r_counter <= 0;
//         r_clk_10kz <= 1;
//     end else begin
//         if(r_counter == F_COUNTER -1) begin
//             r_counter <= 0;
//             r_clk_10kz <= 1'b1;
//         end else begin
//             if(r_counter == F_COUNTER/2 - 1) begin
//                 r_clk_10kz <= 1'b0;
//             end
//             r_counter <= r_counter + 1;
//         end
//     end
// end

// endmodule
