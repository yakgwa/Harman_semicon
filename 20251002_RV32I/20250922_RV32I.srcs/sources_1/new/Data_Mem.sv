`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/22 15:21:47
// Design Name: 
// Module Name: Data_Mem
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

// module Data_Mem(
//     input  logic        clk,
//     input  logic        d_wr_en,
//     input  logic [31:0] dAddr,
//     input  logic [31:0] dWdata,
//     input  logic [31:0] instr_code,  
//     output logic [31:0] dRdata
// );
//     logic [7:0] data_mem [0:1023]; 

//     initial begin
//         for (int i = 0; i < 1024; i++)
//             data_mem[i] = i + 8'h2;
//     end

//     wire [2:0] funct3 = instr_code[14:12];
//     wire [9:0] addr = dAddr[9:0];

//     always_ff @(posedge clk) begin
//         if(d_wr_en) begin
//             case(funct3)
//                 3'b000: begin
//                     data_mem[addr] <= dWdata[7:0];
//                     end
//                 3'b001: begin // SH
//                     data_mem[addr]   <= dWdata[7:0];
//                     data_mem[addr+1] <= dWdata[15:8];                
//                     // data_mem[0][dAddr[dAddr]] <= dWdata[7:0];
//                     // data_mem[1][dAddr[dAddr]] <= dWdata[15:8];
//                 end
//                 3'b010: begin// SW
//                     data_mem[addr]   <= dWdata[7:0];
//                     data_mem[addr+1] <= dWdata[15:8];
//                     data_mem[addr+2] <= dWdata[23:16];
//                     data_mem[addr+3] <= dWdata[31:24];                
//                     // data_mem[dAddr[31:2]] <= dWdata[7:0];
//                     // data_mem[dAddr[dAddr+1]] <= dWdata[15:8];
//                     // data_mem[dAddr[dAddr+2]] <= dWdata[23:16];
//                     // data_mem[dAddr[dAddr+3]] <= dWdata[31:24];
//                 end
//                 default : data_mem[addr] <= dWdata[7:0];
//             endcase
//         end
//     end
//     assign dRdata = (d_wr_en) ? 32'hx :
//                     {data_mem[addr+3], data_mem[addr+2],
//                     data_mem[addr+1], data_mem[addr]};

//     // assign dRdata[31:24] = data_mem[dAddr+3];
//     // assign dRdata[23:16] = data_mem[dAddr+2];
//     // assign dRdata[15:8] = data_mem[dAddr+1];
//     // assign dRdata[7:0] = data_mem[dAddr];
// endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////

module Data_Mem(
    input logic clk,
    input logic d_wr_en,
    input logic [31:0] dAddr,
    input logic [31:0] dWdata,
    output logic [31:0] dRdata
    );

    logic [31:0] data_mem [0:199];

    // initial begin
    //     for (int i = 0; i < 199; i++) begin
    //         data_mem[i] = i;//+32'h8765_4321;
    //     end
    // end

    always_ff@(posedge clk) begin
        if(d_wr_en) data_mem[dAddr] <= dWdata;
    end

    assign dRdata = data_mem[dAddr];

endmodule



// module Data_Mem(
//     input logic clk,
//     input logic d_wr_en,
//     input logic [31:0] dAddr,
//     input logic [31:0] dWdata,
//     output logic [31:0] dRdata,
//     input logic [2:0] mem_read,
//     input logic [1:0] size
//     );

//     logic [7:0] data_mem [0:15];

//     initial begin
//         for (int i = 0; i < 16; i++) begin
//             data_mem[i] = i+8'h2;
//         end
//     end

//     always_ff@(posedge clk) begin
//         if(d_wr_en) data_mem[dAddr] <= dWdata;
//     end

//     // always_ff@(posedge clk) begin
//     //     if(d_wr_en) begin
//     //         case(store_type)
//     //             3'b000 : data_mem[dAddr] <= dWdata;
//     //             3'b001 : data_mem[dAddr] <= dWdata[7:0];
//     //             3'b010 : data_mem[dAddr] <= dWdata[15:0];
//     //         endcase
//     //     end
//     // end

//     //assign dRdata = data_mem[dAddr];

//     always_comb begin
//         if (mem_read) begin
//             case(size)
//                 2'b00 : dRdata = {24'b0, data_mem[dAddr]};
//                 2'b01 : dRdata = {16'b0, data_mem[dAddr+1]};
//                 2'b10 : dRdata = {data_mem[dAddr+3], data_mem[dAddr+2], data_mem[dAddr+1], data_mem[dAddr]};
//                 default : dRdata = 32'b0;
//             endcase
//         end else begin
//             dRdata = 32'b0;
//         end
//     end

//             // 3'b000 :
//             //     dRdata = {
//             //         data_mem[dAddr+3],
//             //         data_mem[dAddr+2],
//             //         data_mem[dAddr+1],
//             //         data_mem[dAddr]
//             //     };
//             // 3'b001 :
//             //     dRdata = {
//             //         16'h0,
//             //         data_mem[dAddr+1],
//             //         data_mem[dAddr]
//             //     };   
//             //     default : dRdata = 32'bx;
//     //     endcase
//     // end     

//     //assign dRdata = {data_mem[dAddr+3], data_mem[dAddr+2], data_mem[dAddr+1], data_mem[dAddr]};

// endmodule

