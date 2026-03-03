`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 15:47:25
// Design Name: 
// Module Name: tb_uart_tx
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


module tb_uart_tx();
    parameter TX_DELAY = (100_000_000/9600) * 10 * 10; // 10비트에 한 클락 10ns

    parameter BAUD_RATE = 9600;
    parameter CLOCK_PERIOD_NS = 10; //100mhz
    parameter BIT_PER_CLOCK = 10416; //100_000_000 / BAUD_RATE; = 1 bit per clock 
    parameter BIT_PERIOD = BIT_PER_CLOCK * CLOCK_PERIOD_NS; // number of clock * 10(ns)

    // verification variable
    reg [7:0] expected_data;
    reg [7:0] receive_data;
    integer bit_count = 0;
    integer i = 0;

    integer pass_count = 0;
    integer fail_count = 0;

    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_busy;
    wire tx;

    uart_top dut(
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx(tx)
        );

    always #5 clk = ~clk;

//     initial begin
//         #0; clk = 0; rst = 1; tx_start = 0; tx_data = 8'h31;
//         #10; rst = 0;
//         #10 tx_start = 1;
//         #10; tx_start = 0;

//         #(TX_DELAY);
//         #1600;
//         $stop;


//         // for verification
//         $display("UART TX testbench started");
//         $display("BAUD Rate = %d", BAUD_RATE);
//         $display("Clock per bit = %d", BIT_PER_CLOCK);
//         $display("Bit period = %d", BIT_PERIOD);

//         //send(8'h41);
//         //receive_uart();
//         single_uart_tx_test(8'h41);
//         #1000;
//         $stop;

//     end
//     // vector gen to dut()
//     task send(input [7:0] send_data);
//         begin
//             expected_data = send_data;
//             tx_data = send_data;
//             @(negedge clk); // negedge clk까지 wait
//             tx_start = 1'b1;
//             @(negedge clk);
//             tx_start = 1'b0;
//             @(negedge tx_busy); // tx_busy가 low로 떨어질때
//         end
//     endtask
//     // receive for verification
//     task receive_uart ();
//         begin
//             $display("receive_uart start");
//             receive_data = 0;
//             @(negedge tx); /// tx가 high > low로 떨어지는 시점

//             #(BIT_PERIOD/2); // middle of start bit

//             // start bit pass/fail

//             if(tx) begin
//                 //fail
//                 $display("Fail Start bit");
//             end

//             // receivedata bit
//             for (bit_count = 0; bit_count < 8; bit_count = bit_count + 1) begin
//                 #(BIT_PERIOD);
//                 receive_data[bit_count] = tx;
//             end
            
//             // check stop bit
//             #(BIT_PERIOD);
//             if(!tx) begin
//                 $display("Fail STOP bit");
//             end // high면 정상이므로 쓸 필요 없음

//             #(BIT_PERIOD/2);

//             // pass/fail tx data
//             if(expected_data == receive_data) begin
//                 $display("Pass : Data matched : received data %2x", receive_data);
//             end else begin
//                 $display("Fail : Data mismatch : received data %2x", receive_data);
//             end          
//         end
//     endtask

//     task single_uart_tx_test(input [7:0] send_data);
//         fork
//             send(send_data);
//             receive_uart();
//         join
//     endtask
// endmodule

    initial begin
        clk = 0; rst = 1; tx_start = 0; tx_data = 8'h31;
        #10; rst = 0;
        #10;

        $display("UART TX testbench started");
        $display("BAUD Rate = %d", BAUD_RATE);
        $display("Clock per bit = %d", BIT_PER_CLOCK);
        $display("Bit period = %d", BIT_PERIOD);
        
        repeat (10) begin
            single_uart_tx_test();
            #1000;  
        end
        $display("Total Pass: %0d", pass_count);
        $display("Total Fail: %0d", fail_count);

        $stop;
    end

    task send;
        reg [7:0] send_data;
        begin
            send_data = $random % 256;

            expected_data = send_data;
            tx_data = send_data;

            @(negedge clk);
            tx_start = 1'b1;
            @(negedge clk);
            tx_start = 1'b0;

            @(negedge tx_busy); // 전송 끝날 때까지 대기

            $display("[SEND] Sent data: %2x", send_data);
        end
    endtask

    task receive_uart ();
        begin
            $display("receive_uart start");
            receive_data = 0;
            @(negedge tx); /// tx가 high > low로 떨어지는 시점

            #(BIT_PERIOD/2); // middle of start bit

            // start bit pass/fail

            if(tx) begin
                //fail
                $display("Fail Start bit");
            end

            // receivedata bit
            for (bit_count = 0; bit_count < 8; bit_count = bit_count + 1) begin
                #(BIT_PERIOD);
                receive_data[bit_count] = tx;
            end
            
            // check stop bit
            #(BIT_PERIOD);
            if(!tx) begin
                $display("Fail STOP bit");
            end // high면 정상이므로 쓸 필요 없음

            #(BIT_PERIOD/2);

            // pass/fail tx data
            if(expected_data == receive_data) begin
                $display("Pass : Data matched : received data %2x", receive_data);
                pass_count = pass_count + 1;
            end else begin
                $display("Fail : Data mismatch : received data %2x", receive_data);
                fail_count = fail_count + 1;
            end          
        end
    endtask

    task single_uart_tx_test;
    fork
        send();
        receive_uart();
    join
    endtask
endmodule