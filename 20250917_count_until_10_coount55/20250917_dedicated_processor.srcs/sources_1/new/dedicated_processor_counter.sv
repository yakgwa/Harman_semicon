`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/17 14:24:04
// Design Name: 
// Module Name: dedicated_processor_counter
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


module dedicated_processor_counter(
    input logic clk,
    input logic reset,
    output logic [7:0] out
    );

    logic ALt10, AsrcSel, OutBufSel, ALoad;

    Controlunit U_CU(
    .clk(clk),
    .reset(reset),
    .ALt10(ALt10),
    .AsrcSel(AsrcSel),
    .ALoad(ALoad),
    .OutBufSel(OutBufSel)
        );

    Datapath U_DP(
    .clk(clk),
    .rst(reset),
    .AsrcSel(AsrcSel),
    .ALoad(ALoad),
    .OutBufSel(OutBufSel),
    .ALt10(ALt10),
    .out(out)
        );

endmodule

module Controlunit(
    input logic clk,
    input logic reset,
    input logic ALt10,
    output logic AsrcSel,
    output logic ALoad,
    output logic OutBufSel
    );

    typedef enum bit [2:0] {S0, S1, S2, S3, S4} state_e; 

    state_e state, next;

    assign OutBufSel = (state == S2) ? 1'b1 : 1'b0; // 밀리 출력으로 Change
    assign ALoad = (state == (S0 | S3)) ? 1'b1 : 1'b0;
    assign AsrcSel = (state == S3) ? 1'b1 : 1'b0;

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
                else next = S4;
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
        endcase
    end                    

endmodule

module Datapath(
    input logic clk,
    input logic rst,
    input logic AsrcSel,
    input logic ALoad,
    input logic OutBufSel,
    output logic ALt10,
    output logic [7:0] out
    );

    logic [7:0] w_muxtoAreg;
    logic [7:0] w_Aregout, w_addertomux;

    mux_2x1 u_Mux(
        .AsrcSel(AsrcSel),
        .a(8'b0),
        .b(w_addertomux),
        .muxtoAreg(w_muxtoAreg)
    );

    Areg U_AReg(
        .clk(clk),
        .reset(rst),
        .ALoad(ALoad),
        .d(w_muxtoAreg),
        .q(w_Aregout)
    );

    comparator U_COMP(
        .a(w_Aregout),
        .b(8'd10),
        .ALt10(ALt10)
    );

    adder U_ADDER(
        .a(w_Aregout),
        .b(8'h01),
        .sum(w_addertomux) 
    );

    outBuf U_OUTBUF(
        .Areg_data(w_Aregout),
        .OutBufSel(OutBufSel),
        .out(out)
    );


endmodule

module mux_2x1(
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

module Areg(
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

module comparator(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic ALt10 // True or False
    );

    assign ALt10 = a < b;
endmodule

module adder(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum // True or False
    );

    assign sum = a + b;

endmodule

module outBuf(
    input logic [7:0] Areg_data,
    input logic OutBufSel,
    output logic [7:0] out
    );

    assign out = OutBufSel ? Areg_data : 8'bz;

endmodule