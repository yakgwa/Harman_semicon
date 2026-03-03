`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/19 15:47:44
// Design Name: 
// Module Name: tb_test
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


module tb_test();
    reg clk;
    reg rst;
    reg rx;
    wire tx;

    total_top UUT (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  
    end

    initial begin
        rst = 1;
        rx  = 1;  
        #100;
        rst = 0;
    end

    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            rx = 0;
            #(104166); 

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];   
                #(104166);
            end

            rx = 1;
            #(104166);
        end
    endtask

    initial begin
        @(negedge rst);  

        #1000;
        uart_send_byte(8'h30); 
        uart_send_byte(8'h72); 
        //uart_send_byte(8'h72); 

        #1000000;
        $stop;
    end

endmodule


//     parameter UART_TX_DELAY = (100_000_000 / 9600) * 12 * 10;
//     reg clk, rst, rx;
//     wire tx;
//     reg [7:0] send_data;


//     total_top dut (  
//         .clk(clk),
//         .rst(rst),
//         .rx(rx),
//         .tx(tx)
//     );

//     always #5 clk = ~clk;

//     initial begin
//         #0;
//         clk   = 0;
//         rst   = 1;
//         #10;
//         rst = 0;
//         #10;
//         // uart frame
//         send_data = 8'h30;
//         send_uart(send_data);
//         //#(104166 * 10);
//         //@(!tx_busy);
//         wait (dut.rx_done);
//         #10;
//         send_data = 8'h31;
//         send_uart(send_data);
//         wait (dut.rx_done);
//         #10;
//         send_data = 8'h32;
//         send_uart(send_data);
//         wait (dut.rx_done);
//         #100_000;

//         /*
//         btn_r = 1;
//         #10_000;  // 10usec
//         btn_r = 0;
//         */
//         // 100_000_000 / 9600 * 10nsec
//         #(UART_TX_DELAY);

// //        #100000;
//         #100_000_000;
//         $stop;
//     end
//     // task tx -> rx send_uart
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
