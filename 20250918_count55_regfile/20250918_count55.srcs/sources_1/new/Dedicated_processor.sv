`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/18 10:31:21
// Design Name: 
// Module Name: Dedicated_processor
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


module Dedicated_processor(
    input logic clk,
    input logic reset,
    output logic [7:0] out
    );

    logic iLe10;
    logic sumSrcMuxSel;
    logic iSrcMuxSel;
    logic sumLoad;
    logic iLoad;
    logic adderSrcSel;
    logic outLoad;

    control_unit U_Control_unit(.*);
    datapath U_Datapath(.*);


endmodule

module control_unit(
    input logic clk,
    input logic reset,
    input logic iLe10,
    output logic sumSrcMuxSel,
    output logic iSrcMuxSel,
    output logic sumLoad,
    output logic iLoad,
    output logic adderSrcSel,
    output logic outLoad
    );

    typedef enum bit [2:0] { S0, S1, S2, S3, S4, S5 } state_e;

    state_e state, next;

    always_ff@(posedge clk or posedge reset) begin
        if(reset) begin
            state <= S0;
        end else begin
            state <= next;
        end
    end

    always_comb begin
        sumSrcMuxSel = 0;
        iSrcMuxSel = 0;
        sumLoad = 0;
        iLoad = 0;
        adderSrcSel = 0;
        outLoad = 0;
        next = S0;
        case(state)
            S0 : begin
                sumSrcMuxSel = 0;
                iSrcMuxSel = 0;
                sumLoad = 1;
                iLoad = 1;
                adderSrcSel = 0;
                outLoad = 0;
                next = S1;
            end
            S1 : begin
                sumSrcMuxSel = 0;
                iSrcMuxSel = 0;
                sumLoad = 0;
                iLoad = 0;
                adderSrcSel = 0;
                outLoad = 0;
                if(iLe10) next = S2;
                else next = S5;
            end
            S2 : begin
                sumSrcMuxSel = 1;
                iSrcMuxSel = 0;
                sumLoad = 1;
                iLoad = 0;
                adderSrcSel = 0;
                outLoad = 0;
                next = S3;
            end
            S3 : begin
                sumSrcMuxSel = 0;
                iSrcMuxSel = 1;
                sumLoad = 0;
                iLoad = 1;
                adderSrcSel = 1;
                outLoad = 0;
                next = S4;
            end
            S4 : begin
                sumSrcMuxSel = 0;
                iSrcMuxSel = 0;
                sumLoad = 0;
                iLoad = 0;
                adderSrcSel = 0;
                outLoad = 1;
                next = S1;
            end
            S5 : begin
                sumSrcMuxSel = 0;
                iSrcMuxSel = 0;
                sumLoad = 0;
                iLoad = 0;
                adderSrcSel = 0;
                outLoad = 1;
                next = S5;
            end   
        endcase         
    end

endmodule


module datapath(
    input logic clk,
    input logic reset,
    input logic sumSrcMuxSel,
    input logic iSrcMuxSel,
    input logic sumLoad,
    input logic iLoad,
    input logic adderSrcSel,
    input logic outLoad,
    output logic iLe10,
    output logic [7:0] out
    ); 

    logic [7:0] w_sum_mux_out, w_i_mux_out, w_adder_muxout;
    logic [7:0] w_sumreg_out, w_ireg_out, w_adder_out;

    register U_OUT_REG(
        .clk(clk),
        .reset(reset),
        .Load(outLoad),
        .d(w_sumreg_out),
        .q(out)
    );

    mux_2x1 U_SUM_REG_MUX(
        .srcSel(sumSrcMuxSel),
        .a(8'h00),
        .b(w_adder_out),
        .muxout(w_sum_mux_out)
    );

    mux_2x1 U_I_REG_MUX(
        .srcSel(iSrcMuxSel),
        .a(8'h00),
        .b(w_adder_out),
        .muxout(w_i_mux_out)
    );

    register U_SUM_REG(
        .clk(clk),
        .reset(reset),
        .Load(sumLoad),
        .d(w_sum_mux_out),
        .q(w_sumreg_out)
    );

    register U_I_REG(
        .clk(clk),
        .reset(reset),
        .Load(iLoad),
        .d(w_i_mux_out),
        .q(w_ireg_out)
    );

    comparator U_LE_COMP(
        .a(w_ireg_out),
        .b(8'd10),
        .iLe10(iLe10)
    );

    mux_2x1 U_ADDER_MUX(
        .srcSel(adderSrcSel),
        .a(w_sumreg_out),
        .b(8'd1),
        .muxout(w_adder_muxout)
    );    

    adder U_ADDER(
        .a(w_adder_muxout),
        .b(w_ireg_out),
        .sum(w_adder_out)
    );


endmodule

module mux_2x1(
    input logic srcSel,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] muxout
    );

    always_comb begin 
        muxout = 8'b0;
        case(srcSel)
            1'b0 : muxout = a;
            1'b1 : muxout = b;
        endcase
    end

endmodule

module register(
    input logic clk,
    input logic reset,
    input logic Load,
    input logic [7:0] d,
    output logic [7:0] q
    );

    always_ff @(posedge clk or posedge reset ) begin 
        if(reset) begin
            q <= 0;
        end else begin
            if(Load) begin
                q <= d;
            end else begin
                q <= q;
            end
        end
 
    end

endmodule

module comparator(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic iLe10 // True or False
    );

    assign iLe10 = a <= b;
endmodule

module adder(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum // True or False
    );

    assign sum = a + b;

endmodule

// module outBuf(
//     input logic [7:0] reg_data,
//     input logic outLoad,
//     output logic [7:0] out
//     );

//     assign out = outLoad ? reg_data : 8'bz;

// endmodule