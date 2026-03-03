`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/10 14:41:15
// Design Name: 
// Module Name: tb_spi_slave
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


module tb_spi_slave();
    // global signal
    logic clk;
    logic reset;
    // Slave Internal signals
    logic start;
    logic cpol;
    logic cpha;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic tx_ready;
    logic done;
    // SPi External port
    logic sclk;
    logic mosi;
    logic miso;
    logic cs;
    // Slave Internal signals
    logic [7:0] si_data;
    logic si_done;
    logic [7:0] so_data;
    logic so_start;
    logic so_ready;
    //logic so_done;


    spi_master dut_master(.*);
    spi_slave dut_slave(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
    end

task automatic spi_mode(bit pol, bit pha);
    cpol = pol;
    cpha = pha;
    @(posedge clk);
endtask

task automatic spi_slave_out(byte data);
    //@(posedge clk);
    wait(so_ready);
    so_data = data;
    so_start = 1;
    @(posedge clk);
    so_start = 0;
    wait(so_ready);
    @(posedge clk);
endtask

task automatic spi_write(byte data);
    @(posedge clk);
    cs = 1'b0;
    wait(tx_ready);
    start = 1;
    tx_data = data;
    @(posedge clk);
    start = 0;
    wait(done);
    @(posedge clk);
    cs = 1'b1;
endtask

initial begin
    repeat(5) @(posedge clk);
    spi_mode(1'b0, 1'b0);
    // spi_write(8'hf0);
    // // spi_write(8'h0f);
    // // spi_write(8'haa);
    // // spi_write(8'h55);
    // spi_slave_out(8'haa);

    fork
        spi_write(8'hf0);
        spi_slave_out(8'haa);
    join


    #20; $finish;
end

endmodule

