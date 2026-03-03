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

module Data_Mem(
    input logic clk,
    input logic d_wr_en,
    input logic [31:0] dAddr,
    input logic [31:0] dWdata,
    output logic [31:0] dRdata
    );

    logic [31:0] data_mem [0:15];

    initial begin
        for (int i = 0; i < 16; i++) begin
            data_mem[i] = i+32'h8765_4321;
        end
    end

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

