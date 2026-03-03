`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/04 13:39:20
// Design Name: 
// Module Name: up_counter
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


module up_counter(
    input clk,
    input reset,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );

wire w_tick_10hz;
wire [13:0] w_counter;

fnd_controller U_FND_CNTL(
    .clk(clk),
    .reset(reset),
    .counter(w_counter),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
);
clk_gen_10hz U_CLK_GEN_10HZ(
    .clk(clk),
    .reset(reset),
    .o_clk_10hz(w_tick_10hz)
);

counter_10000 U_COUNTER_10000(
    .clk(w_tick_10hz),
    .reset(reset),
    .o_counter(w_counter)
);
endmodule

module counter_10000(
    input clk,
    input reset,
    output [13:0] o_counter
);

reg [$clog2(10_000) - 1 : 0] r_counter;

assign o_counter = r_counter;

always@(posedge clk or posedge reset) begin
    if(reset) begin
        r_counter <= 0;
    end else begin
        if(r_counter == 10000 -1) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
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