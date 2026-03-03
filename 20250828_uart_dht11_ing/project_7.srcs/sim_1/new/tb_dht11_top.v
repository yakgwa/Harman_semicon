`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/27 09:58:05
// Design Name: 
// Module Name: tb_dht11_top
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


module tb_dht11_top();
    parameter US = 1_000;
    parameter MS = 1_000_000;

    reg clk, rst, btn_L;
    reg dht11_sensor_reg;
    reg dht11_sensor_enable;
    reg [39:0] dht11_sensor_data;
    wire dht_io;
    wire [2:0] led;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;
    wire led_1;
    //wire o_valid;
    wire o_echo_done;
    //wire o_data;
    integer i;
    reg rx;

    wire w_tick_gen_1us;
    wire [39:0] w_o_data_2;
    wire [31:0] w_o_data_1;
    wire [31:0] w_o_data;
    wire w_echo_done;
    wire w_b_tick;
    wire w_start_from_btn;
    wire w_start_from_uart;   
    wire [7:0] w_rx_data, w_rx_fifo_q;
    wire w_rx_done;
    wire w_rx_fifo_empty, w_rx_fifo_pop_req;
    wire [7:0] w_tx_fifo_push_data;
    wire w_tx_fifo_push;
    wire w_tx_fifo_full;
    wire w_tx_busy;
    wire w_tx_fifo_empty;
    wire [7:0] w_tx_fifo_popdata;
    
    assign dht_io = (dht11_sensor_enable) ? dht11_sensor_reg : 1'bz;

    always #5 clk = ~clk;

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .b_tick(w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    fifo U_RX_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_rx_data),
        .push(w_rx_done),
        .pop(w_rx_fifo_pop_req),
        .pop_data(w_rx_fifo_q),
        .full(),
        .empty(w_rx_fifo_empty)
    );

    receive_controller U_RECEIVE_CONTROLLER(
        .clk(clk),
        .reset(rst),
        .rx_fifo_data(w_rx_fifo_q),
        .rx_trigger(~w_rx_fifo_empty),
        .o_pop(w_rx_fifo_pop_req),
        .o_start(w_start_from_uart)
    );

    tick_gen_1us dut0(
        .clk(clk),
        .rst(rst),
        .o_tick_1us(w_tick_gen_1us)
    );

    dht11_controller dut1(
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_gen_1us), 
        .i_start(btn_L), 
        .dht_io(dht_io), 
        .o_data(w_o_data_2),
        .led(led), 
        .o_echo_done(w_echo_done)
    );

    assign w_start = w_start_from_btn | w_start_from_uart;

    check_sum U_CHECK_SUM(
        .data(w_o_data_2),
        .result(w_o_data_1),
        .led_1(led_1)
    );

    datatoascii U_DATATOASCII(
        .i_data(w_o_data_1), 
        .o_data(w_o_data)
    );

    send_controller U_SEND_CONTROLLER(
        .clk(clk),
        .rst(rst),
        .i_data(w_o_data),
        .echo_done(w_echo_done),
        .o_start(w_tx_fifo_push),
        .o_bcd(w_tx_fifo_push_data),
        .tx_busy(w_tx_fifo_full)
        );

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .start_trigger(~w_tx_fifo_empty),
        .tx_data(w_tx_fifo_popdata),
        .b_tick(w_b_tick),
        .tx_busy(w_tx_busy),
        .tx(tx)
    );

    fifo U_TX_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_tx_fifo_push_data),
        .push(w_tx_fifo_push),
        .pop(~w_tx_busy),
        .pop_data(w_tx_fifo_popdata),
        .full(w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );    

    fnd_controller U_FND_CTRL(
        .clk(clk),
        .reset(rst),
        .counter(w_o_data_1),
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
        rx = 0;
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

//     parameter US = 1_000;
//     parameter MS = 1_000_000;

//     reg clk, rst, btn_L;
//     reg dht11_sensor_reg;
//     reg dht11_sensor_enable;
//     reg [39:0] dht11_sensor_data;
//     wire dht_io;
//     wire [2:0] led;
//     wire [7:0] fnd_data;
//     wire [3:0] fnd_com;
//     wire led_1;
//     //wire o_valid;
//     wire o_echo_done;
//     //wire o_data;
//     integer i;

//     wire w_tick_gen_1us;
//     wire [39:0] w_o_data_2;
//     wire [31:0] w_o_data_1;
//     wire [31:0] w_o_data;

//     assign dht_io = (dht11_sensor_enable) ? dht11_sensor_reg : 1'bz;

//     always #5 clk = ~clk;

//     tick_gen_1us dut0(
//         .clk(clk),
//         .rst(rst),
//         .o_tick_1us(w_tick_gen_1us)
//     );

//     dht11_controller dut1(
//         .clk(clk),
//         .rst(rst),
//         .i_tick(w_tick_gen_1us), 
//         .i_start(btn_L), 
//         .dht_io(dht_io), 
//         .o_data(w_o_data_2),
//         .led(led), 
//         .o_echo_done(o_echo_done)
//     );

//     check_sum U_CHECK_SUM(
//         .data(w_o_data_2),
//         .result(w_o_data_1),
//         .led_1(led_1)
//     );

//     datatoascii U_DATATOASCII(
//         .i_data(w_o_data_1), 
//         .o_data(w_o_data)
//     );

//     send_controller U_SEND_CONTROLLER(
//         .clk(clk),
//         .rst(rst),
//         .i_data(w_o_data),
//         .echo_done(w_echo_done),
//         .o_start(w_tx_fifo_push),
//         .o_bcd(w_tx_fifo_push_data),
//         .tx_busy(w_tx_fifo_full)
//         );

//         fnd_controller U_FND_CTRL(
//         .clk(clk),
//         .reset(rst),
//         .counter(w_o_data_1),
//         .fnd_data(fnd_data),
//         .fnd_com(fnd_com)
//         );

//     initial begin
//         #0; 
//         clk = 0; 
//         rst = 1; 
//         dht11_sensor_enable = 0; 
//         btn_L = 0;
//         dht11_sensor_reg = 0;// mcu에서 받아야하므로 끊어놔야함
//         i = 0;
//         dht11_sensor_data = 40'b10101010_00001111_11000110_00000000_01111111;
//         #10;
//         rst = 0;
//         #10;
//         btn_L = 1;
//         #20_000; // for button debounce
//         #10;
//         btn_L = 0;
//         #(18*MS); // start Low
//         #(30*US); // wait High
//         // sensor is change in sensor for RX to TX
//         dht11_sensor_enable = 1;
//         #(80*US); // sync_L, sensor unconnect
//         dht11_sensor_reg = 1;
//         #(80*US); // sync_H;

//         // to transmit to FPGA for sensor data 40bit
//         for ( i = 0; i < 40; i = i + 1) begin
//             dht11_sensor_reg = 0;
//             #(50*US)
//             dht11_sensor_reg = 1;
//             if(dht11_sensor_data[39-i]) begin
//                 #(70*US);
//             end else begin
//                 #(28*US);
//             end
//         end
//         dht11_sensor_reg = 0;
//         #(50*US);
//         dht11_sensor_enable = 0;

//         #1000;
//         $stop;
//     end
// endmodule

/////////////////////////////////////////////////////////////////////////////

//     reg clk;
//     reg rst;
//     reg btn_L;
//     wire dht_io;
//     wire [2:0] led;
//     wire led_1;
//     wire [3:0] fnd_com;
//     wire [7:0] fnd_data;
//     reg rx;
//     wire tx;
//     wire o_data;
//     reg [7:0] send_data;

//     dht11_top dut(
//         .clk(clk),
//         .rst(rst),
//         .btn_L(btn_L),
//         .led(led),
//         .led_1(led_1),
//         .fnd_com(fnd_com),
//         .fnd_data(fnd_data),
//         .o_data(o_data),
//         .rx(rx),
//         .tx(tx)
//     );

//     always #5 clk = ~clk;

//     initial begin
//     #0; clk = 0; rst = 1; btn_L = 0; //dht_io = 0;
//     #10; rst = 0;
//     // 1st, start btn
//     #10;
//     send_data = 8'h64;
//     send_uart(send_data);
//     #100_000;
//     #10;
//     send_data = 8'h64;
//     send_uart(send_data);
//     #100_000;
//     #10;
//     send_data = 8'h64;
//     send_uart(send_data);
//     #100_000;    
//     #10;
//     send_data = 8'h72;
//     send_uart(send_data);
//     #100_000;    
//     #10;
//     send_data = 8'h64;
//     send_uart(send_data);
//     #100_000;    

//     #1000_000;
//     $stop;
//     end

//     // // 2nd, 10ns TTL delay time
//     // #11_000;

//     // // 3rd, 
//     // #10_000;
//     // echo = 1;
//     // #(1000_000); //1ms
//     // echo = 0;

//     // #(1000 * 10000);
//     // $stop;
//     // end

//     task send_uart(input [7:0] send_data);
//         integer i;
//         begin
//             // start bit
//             rx = 0;
//             #(104166);  // uart 9600bps bit time
//             // data bit
//             for (i = 0; i < 8; i = i + 1) begin
//                 rx = send_data[i];
//                 #(104166);  // uart 9600bps bit time 
//             end
//             // stopbit
//             rx = 1;
//             #(1000);  // uart 9600bps bit time
//         end
//     endtask

// endmodule
