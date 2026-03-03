`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/26 15:34:57
// Design Name: 
// Module Name: tb_dht11
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


module tb_dht11();

    parameter US = 1_000;
    parameter MS = 1_000_000;

    reg clk, rst, btn_L;
    reg dht11_sensor_reg;
    reg dht11_sensor_enable;
    reg [39:0] dht11_sensor_data;
    wire dht_io;
    wire [3:0] led;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;
    integer i;

    assign dht_io = (dht11_sensor_enable) ? dht11_sensor_reg : 1'bz;

    always #5 clk = ~clk;

    dht11_top dut(
    .clk(clk),
    .rst(rst),
    .btn_L(btn_L),
    .dht_io(dht_io),
    .led(led),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
    );


    initial begin
        #0; 
        clk = 0; 
        rst = 1; 
        dht11_sensor_enable = 0; 
        btn_L = 0;
        dht11_sensor_reg = 0;// mcu에서 받아야하므로 끊어놔야함
        i = 0;
        dht11_sensor_data = 40'b10101010_00001111_11000110_00000000_01111111;
        #10;
        rst = 0;
        #10;
        btn_L = 1;
        #20_000; // for button debounce
        #10;
        btn_L = 0;
        #(18*MS); // start Low
        #(30*US); // wait High
        // sensor is change in sensor for RX to TX
        dht11_sensor_enable = 1;
        #(80*US); // sync_L, sensor unconnect
        dht11_sensor_reg = 1;
        #(80*US); // sync_H;

        // to transmit to FPGA for sensor data 40bit
        for ( i = 0; i < 40; i = i + 1) begin
            dht11_sensor_reg = 0;
            #(50*US)
            dht11_sensor_reg = 1;
            if(dht11_sensor_data[39-i]) begin
                #(70*US);
            end else begin
                #(28*US);
            end
        end
        dht11_sensor_reg = 0;
        #(50*US);
        dht11_sensor_enable = 0;

        #1000;
        $stop;
    end
endmodule
