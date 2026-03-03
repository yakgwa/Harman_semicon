`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/09 15:48:38
// Design Name: 
// Module Name: fifo
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


module fifo(
    input logic clk,
    input logic rst,
    input logic wr,
    input logic rd,
    input logic [7:0] wdata,
    output logic [7:0] rdata,
    output logic full,
    output logic empty
    );

    wire [1:0] w_waddr, w_raddr;


    fifo_cu U_FIFO_CU(
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .rd(rd),
        .waddr(w_waddr),
        .raddr(w_raddr),
        .empty(empty),
        .full(full)
    );

    register U_REGISTER(
        .clk(clk),
        .waddr(w_waddr),
        .raddr(w_raddr),
        .wdata(wdata),
        .wr(~full&wr),
        .rd(~empty&rd),
        .rdata(rdata)
    );

endmodule

module register(
    input logic clk,
    input logic [1:0] waddr,
    input logic [1:0] raddr,
    input logic [7:0] wdata,
    input logic rd,
    input logic wr,
    output [7:0] rdata
    );

    logic [7:0] ram [0:3];

    assign rdata = rd ? ram[raddr] : 8'b0;

    always_ff @(posedge clk) begin 
        if(wr) begin
            ram[waddr] <= wdata;
        end
    end
endmodule

module fifo_cu(
    input logic clk,
    input logic rst,
    input logic wr,
    input logic rd,
    output logic [1:0] waddr,
    output logic [1:0] raddr,
    output logic empty,
    output logic full
    );

    logic [1:0] waddr_reg, waddr_next;
    logic [1:0] raddr_reg, raddr_next;
    logic empty_reg, empty_next;
    logic full_reg, full_next;

    assign wptr = waddr_reg;
    assign rptr = raddr_reg;
    assign full = full_reg;
    assign empty = empty_reg;    

    always_ff@(posedge clk or posedge rst) begin
        if(rst) begin
            waddr_reg <= 0;
            raddr_reg <= 0;
            empty_reg <= 0;
            full_reg <= 0;
        end else begin
            waddr_reg <= waddr_next;
            raddr_reg <= raddr_next;
            empty_reg <= empty_next;
            full_reg <= full_next;
        end
    end

    always_comb begin 
            waddr_next = waddr_reg;
            raddr_next = raddr_reg;
            empty_next = empty_reg;
            full_next = full_reg;    
        case({wr,rd})
            2'b00 : begin
            
            end
            2'b01 : begin
                full_next = 1'b0;
                if(!empty_reg) begin
                    raddr_next = raddr_reg + 1;
                    if(waddr_reg == raddr_next) begin
                        empty_next = 1'b1;
                    end
                end
            end            
            2'b10 : begin
                empty_next = 1'b0;
                if(!full_reg) begin
                    waddr_next = waddr_reg + 1;
                    if(raddr_reg == waddr_next) begin
                        full_next = 1'b1;
                    end
                end
            end                
            2'b11 : begin
                if(empty_reg) begin
                    waddr_next = waddr_reg + 1;
                    empty_next = 1'b0;
                end else if(full_reg) begin
                    raddr_next = raddr_reg + 1;
                    full_next = 1'b0;
                end else begin
                    waddr_next = waddr_reg + 1;
                    raddr_next = raddr_reg + 1;
                end
            end           
        endcase
    end

endmodule


