`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/10 13:30:25
// Design Name: 
// Module Name: spi_slave
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
module spi_top(
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic       cpol,
    input  logic       cpha,
    input  logic [7:0] tx_data,
    output logic [7:0] si_data, // rx_data   
    output logic si_done, // rx_done
    output logic so_ready // tx_ready,  
    );

    wire sclk, mosi, miso, cs;

    spi_master U_SPI_MASTER(
        .clk(clk),
        .reset(reset),
        .start(Start),
        .cpol(cpol),
        .cpha(cpha),
        .tx_data(tx_data),
        .rx_data(si_data),
        .tx_ready(so_ready),
        .done(si_done),
        .sclk(sclk),
        .mos(mosi),
        .miso(miso),
        .cs(cs)
    );

    spi_slave U_SPI_SLAVE(
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .mos(mosi),
        .miso(miso),
        .cs(cs),
        .si_data(),
        .si_done(),
        .so_data(),
        .so_start(), 
        .so_ready(), 
        .so_done() 
    );

endmodule