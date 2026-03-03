`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/18 16:40:22
// Design Name: 
// Module Name: tb_fifo
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


module tb_fifo();
    reg clk;
    reg rst;
    reg [7:0] push_data;
    reg push;
    reg pop;
    wire [7:0] pop_data;
    wire full;
    wire empty;

    always #5 clk = ~clk;

    integer i;
    reg rand_push;
    reg rand_pop;
    reg [7:0] compare_data[0:3];
    integer push_count, pop_count;

    // push
    initial begin
    #0; clk = 0; rst = 1; push = 0; pop = 0; push_count = 0; pop_count = 0;
    #15; rst = 0;
    for ( i = 0; i < 4; i = i + 1) begin
        #10;
        push = 1;
        push_data = i + 8'h30;
    end
    #10;
    push = 0;

    // pop
    for ( i = 0; i < 4; i = i + 1) begin
        #10;
        pop = 1;
    end
    #10;
    pop = 0;

    // push & pop
    for ( i = 0; i < 16; i = i + 1) begin
        #10;
        push = 1;
        pop = 1;
        push_data = i;
    end
    // for empty fifo buffer
    #10;
    push = 0;
    pop = 1;
    #40;
    pop = 0;
    #10;

    // random test
    // sync
    #100;
    @(negedge clk); // (negedge clk) 부터 Start

    for ( i = 0; i < 100; i = i + 1) begin
        // $random : system task, %256 : 모수
        // generate random number
        push_data = $random % 256; // 256 중 하나 Pick
        rand_push = $random % 2;
        rand_pop = $random % 2;
    

        // push
        if(rand_push && !full) begin
            push = 1'b1;
            compare_data[push_count] = push_data;
            if(push_count == 3) begin
                push_count = 0;
            end else begin
                push_count = push_count + 1;
            end
        end else begin
            push = 1'b0;
        end

        // pop
        if(rand_pop && !empty) begin
            pop = 1'b1;
            #1; // for pop data read, read combinational outuput이라 상승 엣지까지 안 가도 됨
            if(pop_data == compare_data[pop_count]) begin
                $display("pass");
            end else begin
                $display("fail pop_data = %d, compare_data = %d", pop_data, compare_data[pop_count]);
            end 
            if(pop_count == 3) begin
                pop_count = 0;
            end else begin
                pop_count = pop_count + 1;
            end
        end else begin
            pop = 1'b0;
        end
        @(negedge clk);
        end
        #10;
    

    $stop;

    end







    // initial begin
    // #0; clk = 0; rst = 1; push = 0; pop = 0;
    // #10; rst = 0;
    // #10; push_data = 8'h30;  push = 1'b1;
    // #10; push = 0;
    // #10; push_data = 8'h31;  push = 1'b1;
    // #10; push = 0;
    // #10; push_data = 8'h32;  push = 1'b1;
    // #10; push = 0;
    // #10; push_data = 8'h33;  push = 1'b1;
    // #10; push = 0;
    // // #10; push = 0;
    // #10;

    // #10; pop = 1'b1;
    // #10; pop = 1'b0;  
    // #10; pop = 1'b1;
    // #10; pop = 1'b0;     
    // #10; pop = 1'b1;
    // #10; pop = 1'b0;    
    // #10; pop = 1'b1;
    // #10; pop = 1'b0;  
    // #10;  
        
    // end



    fifo dut(
        .clk(clk),
        .rst(rst),
        .push_data(push_data),
        .push(push),
        .pop(pop),
        .pop_data(pop_data),
        .full(full),
        .empty(empty)
        );

endmodule
