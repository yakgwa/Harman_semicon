`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/16 10:16:00
// Design Name: 
// Module Name: tb_uart_top_tx
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
interface uart_top_tx_interface;
    logic clk;
    logic rst;
    logic tx_start;
    logic [7:0] tx_data;
    logic tx_busy;
    logic tx;
endinterface //uart_top_tx_interface

class transaction;
    bit tx_start;
    rand bit [7:0] tx_data;
    bit tx_busy;
    bit tx;
    // extra register
    bit [7:0] expected_data;

    task display(string name);
        $display("%t:[%s] : tx_data : %0h, tx_start : %0b",
        $time, name, tx_data, tx_start);
    endtask

endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) gen2scb_mbox;
    event gen_next_event;

    int total_count = 0;

    function new(mailbox #(transaction) gen2drv_mbox, mailbox #(transaction) gen2scb_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
        this.gen2scb_mbox = gen2scb_mbox;
    endfunction

    task run(int count);
        repeat(count) begin
            total_count++;
            tr = new;
            assert(tr.randomize())
            else $display("Random Error!!!!");
            gen2drv_mbox.put(tr);
            gen2scb_mbox.put(tr);
            tr.display("[Gen]");
            @(gen_next_event);
        end
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual uart_top_tx_interface uart_top_tx_interface_if;
    event mon_next_event;

    function new(mailbox #(transaction) gen2drv_mbox, virtual uart_top_tx_interface uart_top_tx_interface_if, event mon_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.uart_top_tx_interface_if = uart_top_tx_interface_if;
        this.mon_next_event = mon_next_event;
    endfunction

    task reset();
        uart_top_tx_interface_if.rst = 1;
        uart_top_tx_interface_if.tx_data = 1'b0;
        uart_top_tx_interface_if.tx_start = 1'b0;
        repeat(2) @(posedge uart_top_tx_interface_if.clk);
        uart_top_tx_interface_if.rst = 0;
        repeat(2) @(posedge uart_top_tx_interface_if.clk);
        $display("Reset done!");
    endtask

    task run();
        forever begin
        gen2drv_mbox.get(tr);
        uart_top_tx_interface_if.tx_start = 1;
        uart_top_tx_interface_if.tx_data = tr.tx_data;
        @(posedge uart_top_tx_interface_if.clk);
        uart_top_tx_interface_if.tx_start = 0;
        tr.display("[Drv]");

        -> mon_next_event;
        @(negedge uart_top_tx_interface_if.tx_busy);
        end
    endtask
endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual uart_top_tx_interface uart_top_tx_interface_if;
    event mon_next_event;

    // UART BIT PERIOD = Baud rate dependent. Adjust as per your design.
    parameter BIT_PERIOD = 104160; // For example: (1 / 9600 baud) = 104.16 us

    function new(mailbox #(transaction) mon2scb_mbox, virtual uart_top_tx_interface uart_top_tx_interface_if,
                 event mon_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.uart_top_tx_interface_if = uart_top_tx_interface_if;
        this.mon_next_event = mon_next_event;
    endfunction

    task run();
        forever begin
            @(mon_next_event);
            @(posedge uart_top_tx_interface_if.tx_busy);
            tr = new;

            #(BIT_PERIOD / 2);
            #(BIT_PERIOD);

            for (int i = 0; i < 8; i = i + 1) begin
                tr.expected_data[i] = uart_top_tx_interface_if.tx;
                #(BIT_PERIOD);
                $display("[Mon] Sampled Bit %0d: %0b", i, uart_top_tx_interface_if.tx);
            end

            tr.tx_start = uart_top_tx_interface_if.tx_start;
            tr.tx_data = uart_top_tx_interface_if.tx_data;
            tr.tx_busy = uart_top_tx_interface_if.tx_busy;
            tr.tx = uart_top_tx_interface_if.tx;

            tr.display("[Mon]");
            @(posedge uart_top_tx_interface_if.clk);
            mon2scb_mbox.put(tr);
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2scb_mbox;
    event gen_next_event;

    int pass_count, fail_count = 0;

    function new(mailbox #(transaction) mon2scb_mbox, mailbox #(transaction) gen2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen2scb_mbox = gen2scb_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.display("[Scb]");
            
            if (tr.expected_data == tr.tx_data) begin
                $display("[SCB] PASS: tx_data = %0x, Expected data = %0x", tr.tx_data, tr.expected_data);
                pass_count++;
            end else begin
                $display("[SCB] FAIL: tx_data = %0x, Expected data = %0x", tr.tx_data, tr.expected_data);
                fail_count++;
            end
            -> gen_next_event;
        end
    endtask

endclass

class environment;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2scb_mbox;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    event gen_next_event;
    event mon_next_event;

    function new(virtual uart_top_tx_interface uart_top_tx_interface_if);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen2scb_mbox = new;
        gen = new(gen2drv_mbox, gen2scb_mbox, gen_next_event);
        drv = new(gen2drv_mbox, uart_top_tx_interface_if, mon_next_event);
        mon = new(mon2scb_mbox, uart_top_tx_interface_if, mon_next_event);
        scb = new(mon2scb_mbox, gen2scb_mbox, gen_next_event);
    endfunction

    task report();
        $display("===================================");
        $display("=========== TEST REPORT ===========");
        $display("== Total Transactions: %0d ==", gen.total_count);
        $display("== PASS Count: %0d ==", scb.pass_count);
        $display("== FAIL Count: %0d ==", scb.fail_count);
        $display("===================================");
    endtask

    task run(int count);
        drv.reset();
        fork
            gen.run(count);
            drv.run();
            mon.run();
            scb.run(); 
        join_any
        report();
        $stop;
    endtask
endclass


module tb_uart_top_tx();
    uart_top_tx_interface uart_top_tx_interface_tb();
    environment env;

    logic clk = 0;

    uart_top dut(
    .clk(uart_top_tx_interface_tb.clk),
    .rst(uart_top_tx_interface_tb.rst),
    .tx_start(uart_top_tx_interface_tb.tx_start),
    .tx_data(uart_top_tx_interface_tb.tx_data),
    .tx_busy(uart_top_tx_interface_tb.tx_busy),    
    .tx(uart_top_tx_interface_tb.tx)  
    );

    always #5 uart_top_tx_interface_tb.clk = ~uart_top_tx_interface_tb.clk;

    initial begin
       uart_top_tx_interface_tb.clk = 0;
       env = new(uart_top_tx_interface_tb);
       env.run(50); 
    end




endmodule
