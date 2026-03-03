`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/18 13:32:14
// Design Name: 
// Module Name: Dedicated_processor_revised
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


module Dedicated_processor_revised(
    input logic clk,
    input logic reset,
    output logic [7:0] out
    );

    logic iLe10, R1SrcSel, outLoad, we;
    logic [2:0] waddr, raddr0, raddr1;


    Controlunit_1 U_CU(.*);
    Datapath_1 U_DP(.*);

endmodule

// module Controlunit_1(
//     input logic clk,
//     input logic reset,
//     input logic iLe10,
//     output logic R1SrcSel,
//     output logic outLoad,
//     output logic we,
//     output logic [2:0] waddr,
//     output logic [2:0] raddr0,
//     output logic [2:0] raddr1
//     );

//     logic [11:0] control_code;

//     assign {R1SrcSel, raddr0, raddr1, waddr, we, outLoad} = control_code;

//     typedef enum { S0, S1, S2, S3, S4, S5, S6, S7 } state_e;

//     state_e state, next;

//     always_ff@(posedge clk or posedge reset) begin
//         if(reset) begin
//             state <= S0;
//         end else begin
//             state <= next;
//         end
//     end

//     always_comb begin
//         next = state;
//         control_code = 0;
//         case(state)
//             S0 : begin
//                 control_code = 12'b0_000_000_001_1_0;
//                 next = S1;
//             end
//             S1 : begin
//                 control_code = 12'b0_000_000_010_1_0;
//                 next = S2;
//             end
//             S2 : begin
//                 control_code = 12'b1_000_000_011_1_0;
//                 next = S3;
//             end
//             S3 : begin
//                 control_code = 12'b0_001_000_000_0_0;
//                 if(iLe10) next = S4;
//                 else next = S7;
//             end
//             S4 : begin
//                 control_code = 12'b0_010_001_010_1_0;
//                 next = S5;
//             end
//             S5 : begin
//                 control_code = 12'b0_001_011_001_1_0;
//                 next = S6;
//             end
//             S6 : begin
//                 control_code = 12'b0_010_000_000_0_1;
//                 next = S7;
//             end
//             S7 : begin
//                 control_code = 12'b0_0_0_000_000_000;
//                 next = S7;
//             end
//         endcase
//     end
// endmodule

///////////////////////////////////
module Controlunit_1 (
    input  logic       clk,
    input  logic       reset,
    output logic       R1SrcSel,
    output logic [2:0] raddr0,
    output logic [2:0] raddr1,
    output logic [2:0] waddr,
    output logic       we,
    output logic       outLoad,
    input  logic       iLe10
);
    typedef enum { S0, S1, S2, S3, S4, S5, S6, S7 } state_e;
    
    state_e state, state_next;
    logic [11:0] out_signals;

    assign {R1SrcSel, raddr0, raddr1, waddr, we, outLoad} = out_signals;

    always_ff @(posedge clk, posedge reset) begin : state_reg
        if (reset) state <= S0;
        else state <= state_next;
    end

    always_comb begin : state_next_machine
        state_next     = state;
        out_signals = 0;
        case (state)
            //{RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, outBuf} = out_signals;
            S0: begin // R1 = 0
                out_signals = 12'b0_000_000_001_1_0; // addr1에 0 -> 초기화
                state_next     = S1;
            end
            S1: begin // R2 = 0
                out_signals = 12'b0_000_000_010_1_0; // addr2에 0 -> 초기화
                state_next     = S2;
            end
            S2: begin // R3 = 1;
                out_signals = 12'b1_000_000_011_1_0; // addr3에 1, 고정
                state_next     = S3;
            end
            S3: begin // i <= 10
                out_signals = 12'b0_001_000_000_0_0; //addr1번 읽기
                if (iLe10) state_next = S4;
                else state_next = S7;
            end
            S4: begin // R2 = R2 + R1    // 값을 저장하므로 write 동작을 해줘야 함
                out_signals = 12'b0_010_001_010_1_0;
                state_next     = S5;
            end
            S5: begin // R1 = R1 + R3(1)  //값을 저장하므로 wirte 동작, 1로 지정된 3번 불러옴
                out_signals = 12'b0_001_011_001_1_0;
                state_next     = S6;
            end
            S6: begin // outport = R2    //R2의 값 read하고 outBuf로 값 출력
                out_signals = 12'b0_010_000_000_0_1;
                state_next     = S3;
            end
            S7: begin     //Halt
                out_signals = 12'b0_000_000_000_0_0;
                state_next     = S7;
            end
        endcase
    end
endmodule




module Datapath_1(
    input logic clk,
    input logic reset,
    input logic R1SrcSel,
    input logic outLoad,
    input logic we,
    input logic [2:0] waddr,
    input logic [2:0] raddr0,
    input logic [2:0] raddr1,
    output logic iLe10,
    output logic [7:0] out
    ); 

    logic [7:0] w_Areg_out, w_Breg_out, w_sumout, w_muxout;

    register_1 U_OUT_REG(
        .clk(clk),
        .reset(reset),
        .Load(outLoad),
        .d(w_Areg_out),
        .q(out)
    );

    comparator_1 U_COMP(
        .a(w_Areg_out),
        .b(8'd10),
        .iLe10(iLe10) 
    );

    mux_2x1_1 U_MUX(
        .srcSel(R1SrcSel),
        .a(w_sumout),
        .b(8'b1),
        .muxout(w_muxout)
    );

    register_file_1 U_REGFILE( 
        .clk(clk),
        .we(we),
        .waddr(waddr),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .wdata(w_muxout),
        .rdata0(w_Areg_out),
        .rdata1(w_Breg_out)
    );

    adder_1 U_ADDER(
        .a(w_Areg_out),
        .b(w_Breg_out),
        .sum(w_sumout)
    );

endmodule

module register_file_1(
    input logic clk,
    input logic we,
    input logic [2:0] waddr,
    input logic [2:0] raddr0,
    input logic [2:0] raddr1,
    input logic [7:0] wdata,
    output logic [7:0] rdata0,
    output logic [7:0] rdata1
    );

    logic [7:0] mem [0:7];

    always_ff@(posedge clk) begin
        if(we) mem[waddr] <= wdata;      
    end

    assign rdata0 = (raddr0 == 3'b0) ? 8'b0 : mem[raddr0];
    assign rdata1 = (raddr1 == 3'b0) ? 8'b0 : mem[raddr1];

endmodule


module mux_2x1_1(
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

module register_1(
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

module comparator_1(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic iLe10 // True or False
    );

    assign iLe10 = a <= b;
endmodule

module adder_1(
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum // True or False
    );

    assign sum = a + b;

endmodule
