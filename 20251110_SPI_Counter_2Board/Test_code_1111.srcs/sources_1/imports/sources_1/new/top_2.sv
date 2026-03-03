`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/11 00:47:24
// Design Name: 
// Module Name: top_2
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
module top_2(
    input         clk,
    input         rst,
    input         runstop,
    input         clear,
    // input  [ 13:0] counter,
    input         btn,
    output [ 3:0] fndCom,
    output [ 7:0] fndFont,

    output        master_mosi,
    input         master_miso,
    output        master_sclk,
    output        master_cs,  
    input         slave_mosi,
    output        slave_miso,
    input         slave_sclk,
    input         slave_cs

);
    wire cs, sclk, done;
    wire mosi, miso, start;
    wire [7:0] si_data, tx_data;
    wire [15:0] fndData;
    wire [13:0] counter;


    counter U_COUNTER(
        .clk(clk),
        .reset(reset),
        .runstop(runstop),
        .clear(clear),
        .o_counter(counter)
    );

    spi_master U_SPI_Master (
        .clk        (clk),
        .reset        (rst),
        .sclk       (master_sclk),
        .tx_data    (tx_data),
        .start      (start),
        .tx_ready   (),
        .done       (done),
        .rx_data    (),
        .mosi       (master_mosi),
        .cs         (master_cs),
        .miso       (master_miso),
        .cpol       (1'b0),
        .cpha       (1'b0)
    );

    spi_slave U_SPI_SLAVE (
        .clk(clk),
        .reset(rst),
        .sclk(slave_sclk),
        .mosi(slave_mosi),
        .miso(slave_miso),
        .cs(slave_cs),
        .si_data(si_data), 
        .si_done(), 
        .so_data(),
        .so_start(),
        .so_ready()
    );

    spi_ctrl U_SPI_CTRL (
        .clk    (clk),
        .reset    (rst),
        .btn      (btn),        
        // slave
        .cs     (cs),
        .si_done   (done),
        .si_data   (si_data),
        .fndData(fndData),
        // master
        .counter(counter),
        .tx_data(tx_data),
        .start(start)        
    );

    fnd_controller U_FND (
        .clk    (clk),
        .reset  (rst),
        .counter(fndData),
        .fnd_data(fndFont),
        .fnd_com(fndCom)
    );

endmodule