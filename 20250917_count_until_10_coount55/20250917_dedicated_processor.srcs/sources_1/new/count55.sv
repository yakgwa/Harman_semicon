`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/17 17:54:00
// Design Name: 
// Module Name: count55
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


module count55(
    input logic clk,
    input logic reset,
    output logic [7:0] out
    );

    logic ALt10, AsrcSel, OutBufSel, ALoad, SumsrcSel, AddersrcSel, SumLoad;

    
    Controlunit_1 U_CU_1(
    .clk(clk),
    .reset(reset),
    .ALt10(ALt10),
    .AsrcSel(AsrcSel),
    .ALoad(ALoad),
    .OutBufSel(OutBufSel),
    .SumsrcSel(SumsrcSel),
    .SumLoad(SumLoad),
    .AddersrcSel(AddersrcSel)
    );        
    Datapath_1 U_DP_1(
    .clk(clk),
    .rst(reset),
    .AsrcSel(AsrcSel),
    .SumsrcSel(SumsrcSel),
    .ALoad(ALoad),
    .SumLoad(SumLoad),
    .AddersrcSel(AddersrcSel),
    .OutBufSel(OutBufSel),
    .ALt10(ALt10),
    .out(out)
    );

endmodule

module Controlunit_1(
    input logic clk,
    input logic reset,
    input logic ALt10,
    output logic AsrcSel,
    output logic ALoad,
    output logic OutBufSel,
    output logic SumsrcSel,
    output logic SumLoad,
    output logic AddersrcSel
    );

    typedef enum bit [2:0] {S0, S1, S2, S3, S4, S5} state_e; 

    state_e state, next;

    assign OutBufSel = (state == S4) ? 1'b1 : 1'b0; // 밀리 출력으로 Change
    assign ALoad = (state == (S0 | S3)) ? 1'b1 : 1'b0;
    assign AsrcSel = (state == S3) ? 1'b1 : 1'b0;
    assign AddersrcSel = (state == S3) ? 1'b1 : 1'b0;
    assign SumLoad = (state == (S0 | S2)) ? 1'b1 : 1'b0;
    assign SumsrcSel = (state == S2) ? 1'b1 : 1'b0;

    // state register
    always_ff@(posedge clk or posedge reset) begin
        if(reset) begin
            state <= S0;
        end else begin
            state <= next;
        end
    end
    // next CL
    always_comb begin
        next = state;      
        case(state)
            S0 : begin
                next = S1;
            end
            S1 : begin   
                if(ALt10)  next = S2;
                else next = S5;
            end
            S2 : begin
                next = S3;           
            end
            S3 : begin
                next = S1;             
            end
            S4 : begin
                next = S4;           
            end    
            S5 : begin
                next = S4;           
            end                
        endcase
    end                    

endmodule

module Datapath_1(
    input logic clk,
    input logic rst,
    input logic AsrcSel,
    input logic SumsrcSel,
    input logic ALoad,
    input logic SumLoad,
    input logic AddersrcSel,
    input logic OutBufSel,
    output logic ALt10,
    output logic [7:0] out
    );

    logic [7:0] w_muxtoAreg, w_muxtoSumreg;
    logic [7:0] w_Aregout, w_Sumregout;
    logic [7:0] w_adderout;
    logic [7:0] w_Aout, w_Sumout;
    logic [7:0] w_in;

    mux_2x1_1 u_Mux_A(
        .AsrcSel(AsrcSel),
        .a(8'b0),
        .b(w_in),
        .muxtoAreg(w_muxtoAreg)
    );

    mux_2x1_1 u_Mux_SUM(
        .AsrcSel(SumsrcSel),
        .a(8'b0),
        .b(w_in),
        .muxtoAreg(w_muxtoSumreg)
    );

    mux_2x1_1 u_Mux_ADDER(
        .AsrcSel(AddersrcSel),
        .a(w_Sumregout),
        .b(8'h1),
        .muxtoAreg(w_adderout)
    );

    Areg_1 U_AReg(
        .clk(clk),
        .reset(rst),
        .ALoad(ALoad),
        .d(w_muxtoAreg),
        .q(w_Aregout)
    );

    Areg_1 U_SUMReg(
        .clk(clk),
        .reset(rst),
        .ALoad(SumLoad),
        .d(w_muxtoSumreg),
        .q(w_Sumregout)
    );

    comparator_1 U_COMP(
        .a(w_Aregout),
        .b(8'd11),
        .ALt10(ALt10)
    );

    adder_1 U_ADDER(
        .a(w_Aregout),
        .b(w_adderout),
        .sum(w_in) 
    );

    outBuf_1 U_OUTBUF(
        .Areg_data(w_Sumregout),
        .OutBufSel(OutBufSel),
        .out(out)
    );


endmodule

module mux_2x1_1(
    input logic AsrcSel,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] muxtoAreg
    );

    always_comb begin 
        muxtoAreg = 8'b0;
        case(AsrcSel)
            1'b0 : muxtoAreg = a;
            1'b1 : muxtoAreg = b;
        endcase
    end

endmodule

module Areg_1(
    input logic clk,
    input logic reset,
    input logic ALoad,
    input logic [7:0] d,
    output logic [7:0] q
    );

    always_ff @(posedge clk or posedge reset ) begin 
        if(reset) begin
            q <= 0;
        end else begin
            if(ALoad) begin
                q <= d;
            end else begin
                q <= q;
            end
        end
 
    end

endmodule

module comparator_1(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic ALt10 // True or False
    );

    assign ALt10 = a < b;
endmodule

module adder_1(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum // True or False
    );

    assign sum = a + b;

endmodule

module outBuf_1(
    input logic [7:0] Areg_data,
    input logic OutBufSel,
    output logic [7:0] out
    );

    assign out = OutBufSel ? Areg_data : 8'bz;

endmodule