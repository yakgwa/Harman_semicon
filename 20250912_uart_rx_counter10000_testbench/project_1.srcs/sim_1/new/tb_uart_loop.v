`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/04 13:06:10
// Design Name: 
// Module Name: tb_uart_loop
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


module tb_uart_loop();
    parameter TX_DELAY = (100_000_000/9600) * 10 * 10; // 10비트에 한 클락 10ns

    parameter BAUD_RATE = 9600;
    parameter CLOCK_PERIOD_NS = 10; //100mhz
    parameter BIT_PER_CLOCK = 10416; //100_000_000 / BAUD_RATE; = 1 bit per clock 
    parameter BIT_PERIOD = BIT_PER_CLOCK * CLOCK_PERIOD_NS; // number of clock * 10(ns)

    // verification variable
    reg [7:0] expected_data;
    reg [7:0] receive_data;
    reg [7:0] send_data;
    reg [7:0] random_rx_data;
    integer bit_count = 0;
    integer bit_count_1 = 0;
    integer i = 0;

    integer pass_count = 0;
    integer fail_count = 0;

    reg clk;
    reg rst;
    reg rx;
    wire tx;
    wire tx_busy;

    uart_top dut(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx)
        );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; rx = 1; send_data = 8'h31;
        #100; rst = 0;
        #100;
        // rx = 0;
        // #(BIT_PERIOD);
        // // Data
        // for(bit_count = 0; bit_count < 8; bit_count = bit_count + 1) begin
        //     rx = send_data[bit_count];
        //     #(BIT_PERIOD);
        // end
        // // stop
        // rx = 1'b1;
        // #(BIT_PERIOD);
        // //#1000;
        // $stop;   

        $display("UART TX & RX LOOP testbench started");
        $display("BAUD Rate = %d", BAUD_RATE);
        $display("Clock per bit = %d", BIT_PER_CLOCK);
        $display("Bit period = %d", BIT_PERIOD);
       
        for (i = 0; i < 10; i = i + 1) begin
            random_rx_data = $random() % 256;
            single_uart_tx_test(random_rx_data);
        end

        $display("Pass : %2d, Fail : %2d", pass_count, fail_count);
        #1000;
        $stop;

    end

    task send(input [7:0] send_data);
        begin
            expected_data = send_data;
            #10;
            rx = 0;
            #(BIT_PERIOD);
            // Data
            for(bit_count = 0; bit_count < 8; bit_count = bit_count + 1) begin
                rx = send_data[bit_count];
                #(BIT_PERIOD);
            end
            // stop
            rx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // task receive_uart ();
    //     begin
    //         $display("receive_uart start");
    //         receive_data = 0;
    //         @(negedge tx); /// tx가 high > low로 떨어지는 시점
    //         //#1000;
    //         #(BIT_PERIOD/2); // middle of start bit

    //         // start bit pass/fail

    //         if(tx) begin
    //             //fail
    //             $display("Fail Start bit");
    //         end

    //         // receivedata bit
    //         for (bit_count_1 = 0; bit_count_1 < 8; bit_count_1 = bit_count_1 + 1) begin
    //             #(BIT_PERIOD);
    //             receive_data[bit_count_1] = tx;
    //         end
            
    //         // check stop bit
    //         #(BIT_PERIOD);
    //         if(!tx) begin
    //             $display("Fail STOP bit");
    //         end // high면 정상이므로 쓸 필요 없음

    //         #(BIT_PERIOD/2);

    //         // pass/fail tx data
    //         if(expected_data == receive_data) begin
    //             $display("Pass : Data matched : received data %2x", receive_data);
    //             pass_count = pass_count + 1;
    //         end else begin
    //             $display("Fail : Data mismatch : received data %2x", receive_data);
    //             fail_count = fail_count + 1;
    //         end          
    //     end
    // endtask

    task receive_uart ();
        begin
            $display("receive_uart start");
            receive_data = 0;
            #10;
            @(negedge tx); /// tx가 high > low로 떨어지는 시점

            #(BIT_PERIOD/2); // middle of start bit

            // start bit pass/fail

            if(tx) begin
                //fail
                $display("Fail Start bit");
            end

            // receivedata bit
            for (bit_count_1 = 0; bit_count_1 < 8; bit_count_1 = bit_count_1 + 1) begin
                #(BIT_PERIOD);
                receive_data[bit_count_1] = tx;
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


    task single_uart_tx_test(input [7:0] send_data);
        fork    
            send(send_data);
            receive_uart();
        join
    endtask
endmodule

