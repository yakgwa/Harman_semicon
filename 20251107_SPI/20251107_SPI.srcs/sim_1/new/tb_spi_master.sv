`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/07 14:17:12
// Design Name: 
// Module Name: tb_spi_master
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

// module tb_spi_top1();

//     logic       clk;
//     logic       reset;
//     logic       start;
//     logic       cpol;
//     logic       cpha;
//     logic [7:0] tx_data;
//     logic [7:0] rx_data;
//     logic       done;
//     logic       ready;
//     logic       SCLK;
//     logic       MOSI;
//     logic       MISO;
//     logic       SS;

//     spi_master dut(.*);

//     spi_slave dut1(.*);

//     always #5 clk = ~clk;

//     initial begin
//         clk = 0;
//         reset = 1;
//         #10 reset = 0;
        
//         repeat (3) @(posedge clk); //clk 3번 후에 동작

//         SS = 1;
//         @(posedge clk); //write, tx_data[7] == 1, address == 0,
//         tx_data = 8'b10000000; start = 1; cpol = 0; cpha = 0; 
//         SS = 0;
//         @(posedge clk);
//         start = 0;
//         wait(done == 1); 
//         @(posedge clk);


//         @(posedge clk); //write data 8'h10  address == 0
//         tx_data = 8'h10; start = 1; cpol = 0; cpha = 0; 
//         @(posedge clk);
//         start = 0;
//         wait(done == 1); 
//         @(posedge clk);

//         @(posedge clk); //write data 8'h20  address == 1
//         tx_data = 8'h20; start = 1; cpol = 0; cpha = 0; 
//         @(posedge clk);
//         start = 0;
//         wait(done == 1); 
//         @(posedge clk);

//         @(posedge clk); //write data 8'h30  address == 2
//         tx_data = 8'h30; start = 1; cpol = 0; cpha = 0; 
//         @(posedge clk);
//         start = 0;
//         wait(done == 1); 
//         @(posedge clk);

//         @(posedge clk); //write data 8'h40  address == 3
//         tx_data = 8'h40; start = 1; cpol = 0; cpha = 0; 
//         @(posedge clk);
//         start = 0;
//         wait(done == 1); 
//         @(posedge clk);

//         SS = 1;


//         //read saction
//         repeat(5) @(posedge clk);
//         SS = 0;
//         @(posedge clk); // read, address == 0
//         tx_data = 8'b00000000; start = 1; cpol = 0; cpha = 0;
//         @(posedge clk);
//         start = 0;
//         wait(done == 1);
//         @(posedge clk);

//         for(int i = 0; i < 4; i = i + 1) begin
//             @(posedge clk);
//             start = 1;
//             @(posedge clk);
//             start = 0;
//             wait(done == 1);
//             @(posedge clk);
//         end

//         SS = 1;

//         #2000 $finish;
//     end

// endmodule

module tb_spi_master();
    logic clk;
    logic reset;
    logic start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic tx_ready;
    logic done;
    logic sclk;
    logic mosi;
    logic miso;
    logic loop_wire;

spi_master dut(.*,
.mosi(loop_wire),
.miso(loop_wire));

always #5 clk = ~clk;

initial begin
     clk = 0; reset = 1;
     #10; reset = 0;
end

task automatic spi_write(byte data);
    @(posedge clk);
    wait(tx_ready);
    start = 1;
    tx_data = data;
    @(posedge clk);
    start = 0;
    wait(done);
    @(posedge clk);
endtask

initial begin
    repeat(5) @(posedge clk);
    spi_write(8'hf0);
    spi_write(8'h0f);
    spi_write(8'haa);
    spi_write(8'h55);
    #20; $finish;
end

endmodule