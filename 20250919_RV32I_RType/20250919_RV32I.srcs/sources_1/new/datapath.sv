`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/19 11:35:49
// Design Name: 
// Module Name: datapath
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


module datapath(
    input logic clk,
    input logic reset,
    input logic [31:0] inst_opcode,
    input logic [3:0] controls,
    input logic w_en,
    output logic [31:0] inst_rAddr

    );

    logic [31:0] w_regfile_rd1, w_regfile_rd2, w_alu_result, w_pc_src, w_pc_data, w_pc_out;

    // register u_PC(
    //     .clk(clk),
    //     .reset(reset),
    //     .d(w_pc_src),
    //     .q(w_pc_data)
    // );

    // adder u_adder(
    //     .a(32'd4), //4
    //     .b(w_pc_src), //pc값
    //     .result(inst_rAddr)  //pc(d)
    // );

    program_counter U_PC(
        .clk(clk),
        .reset(reset),
        .d(inst_rAddr),
        .pc(inst_rAddr)
    );

    register_file U_REG_FILE(
        .clk(clk),
        .RA1(inst_opcode[19:15]), 
        .RA2(inst_opcode[24:20]), 
        .WA(inst_opcode[11:7]), 
        .we(w_en),
        .WData(w_alu_result), 
        .RD1(w_regfile_rd1), 
        .RD2(w_regfile_rd2)
    );

    ALU U_ALU(
        .a(w_regfile_rd1),
        .b(w_regfile_rd2),
        .controls(controls),
        .result(w_alu_result)
    );



endmodule

module program_counter(
        input logic clk,
        input logic reset,
        input logic [31:0] d,
        output logic [31:0] pc
    );

    wire [31:0] pc_4;
    assign pc_4 = d + 4;
    register U_PC_REG(
        .clk(clk),
        .reset(reset),
        .d(pc_4),
        .q(pc)
    );
endmodule


module register(
    input logic clk,
    input logic reset,
    input logic [31:0] d,
    output logic [31:0] q
    );

    always_ff@(posedge clk or posedge reset) begin
        if(reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule

module register_file(
    input logic clk,
    input logic we,
    input logic [4:0] RA1,
    input logic [4:0] RA2,
    input logic [4:0] WA,
    input logic [31:0] WData,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);
    logic [31:0] regfile[0:2**5-1]; 

    initial begin
        regfile[1] = 1;
        regfile[2] = 2;
        regfile[3] = 3;
        regfile[4] = 4;
        regfile[5] = 5;
        regfile[6] = 6;
        regfile[7] = 7;
        regfile[8] = 8;
        regfile[9] = 9;
    //     for(int i = 1; i < 32; i++) begin
    //         regfile[i] = 10 + i;
    //     end
    end

    always_ff @(posedge clk) begin
        if(we) regfile[WA] <= WData;
    end

    assign RD1 = (RA1 != 0) ? regfile[RA1] : 32'b0;
    assign RD2 = (RA2 != 0) ? regfile[RA2] : 32'b0;
endmodule

module ALU(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] controls,
    output logic [31:0] result
    );

    enum logic [3:0] {ADD, SUB, OR, AND, SLL, SRL, SRA, SLT, SLTU, XOR} alu_op;

    always_comb begin
        case(controls)
            ADD : result = a + b; //ADD,0
            SUB : result = a - b; //SUB,1
            OR : result = a | b; //OR,2
            AND : result = a & b; //AND,3
            SLL : result = a << b; //SLL,4
            SRL : result = a >> b; //SRL,5
            SRA : result = a >>> b; //SRA,6, MSB extend
            SLT : result = (a < b) ? 1 : 0; //SLT,7
            SLTU : result = (a < b) ? 1 : 0; //SLTU,8
            XOR : result = a ^ b; //XOR,9
            default : result = 32'bx;
        endcase
    end
endmodule

module adder(
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] result
    );

    assign result = a + b;

endmodule
