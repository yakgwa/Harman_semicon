`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/21 13:18:23
// Design Name: 
// Module Name: tb_total_top
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


module tb_total_top();

    parameter UART_TX_DELAY = (100_000_000 / 9600) * 12 * 10;
    reg clk;
    reg rst;
    reg rx;
    wire tx;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [1:0] led;
    reg btn_0;
    reg btn_1;
    reg [7:0] send_data;

    always #5 clk = ~clk;

    initial begin
        #0;
        clk   = 0;
        rst   = 1;
        btn_0 = 0;
        btn_1 = 0;
        #10;
        rst = 0;
        #10;
        btn_1 = 1;
        #10;
        // uart frame
        send_data = 8'h30;
        send_uart(send_data);
        //#(104166 * 10);
        //@(!tx_busy);
        #10;
        send_data = 8'h72;
        send_uart(send_data);
        #10;
        send_data = 8'h72;
        send_uart(send_data);
        #100_000;
        #10;
        send_data = 8'h72;
        send_uart(send_data);
        #100_000;
        #10;
        send_data = 8'h73;
        send_uart(send_data);
        #100_000;        
        #10;
        send_data = 8'h73;
        send_uart(send_data);
        #100_000;     
        #10;
        send_data = 8'h73;
        send_uart(send_data);
        #100_000; 
        #10;
        send_data = 8'h63;
        send_uart(send_data);
        #100_000; 
        #10;
        send_data = 8'h63;
        send_uart(send_data);
        #100_000; 
        #10;
        send_data = 8'h63;
        send_uart(send_data);
        #100_000; 
        #10;
        send_data = 8'h70;
        send_uart(send_data);
        #100_000; 
        #10;
        send_data = 8'h70;
        send_uart(send_data);
        #100_000;         
        #10;
        send_data = 8'h70;
        send_uart(send_data);
        #100_000;         
        #10;
        send_data = 8'h62;
        send_uart(send_data);
        #100_000;         
        #10;
        send_data = 8'h62;
        send_uart(send_data);
        #100_000;         
        send_data = 8'h62;
        send_uart(send_data);
        #100_000;         
        #10;
        send_data = 8'h75;
        send_uart(send_data);
        #100_000;         
        #10;
        send_data = 8'h75;
        send_uart(send_data);
        #100_000;         
        send_data = 8'h75;
        send_uart(send_data);
        #100_000;         
        #10;          
        
        btn_0 = 1;
        #10_000;  // 10usec
        //btn_0 = 0;
        
        /*
        btn_r = 1;
        #10_000;  // 10usec
        btn_r = 0;
        */
        // 100_000_000 / 9600 * 10nsec
        #(UART_TX_DELAY);

//        #100000;
        #100_000_000;
        $stop;
    end
    // task tx -> rx send_uart
    task send_uart(input [7:0] send_data);
        integer i;
        begin
            // start bit
            rx = 0;
            #(104166);  // uart 9600bps bit time
            // data bit
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(104166);  // uart 9600bps bit time 
            end
            // stopbit
            rx = 1;
            #(1000);  // uart 9600bps bit time
        end
    endtask

    total_top dut(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );


endmodule
