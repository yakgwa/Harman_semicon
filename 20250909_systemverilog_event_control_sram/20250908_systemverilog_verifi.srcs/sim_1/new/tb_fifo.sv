`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/09 17:12:53
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

interface fifo_interface;
    logic clk;
    logic rst;
    logic wr;
    logic rd;
    logic [7:0] wdata;
    logic [7:0] rdata;
    logic full;
    logic empty;
endinterface //fifo_interface

class transaction;
    rand bit wr;
    rand bit rd;
    rand bit [7:0] wdata;
    bit [7:0] rdata;
    bit full;
    bit empty;

    task display(string name);
        $display("%t:[%s] : wr : %d, rd : %d, wdata : %d, rdata : %d, full : %d, empty : %d",$time, name , wr, rd, wdata, rdata, full, empty);
    endtask

endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_event;

    int total_count = 0;

    function new(mailbox #(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int count);
        repeat(count) begin
            total_count++;
            tr = new;
            assert(tr.randomize())
            else $display("Random Error!!!!");
            gen2drv_mbox.put(tr);
            tr.display("[Gen]");
            @(gen_next_event);
        end
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual fifo_interface fifo_interface_if;
    
    function new(mailbox #(transaction) gen2drv_mbox, virtual fifo_interface fifo_interface_if);
        this.gen2drv_mbox = gen2drv_mbox;
        this.fifo_interface_if = fifo_interface_if;
    endfunction        

    task reset();
    fifo_interface_if.rst = 1;
    fifo_interface_if.wr = 0;
    fifo_interface_if.rd = 0;
    fifo_interface_if.wdata = 0;
    repeat(5) @(posedge fifo_interface_if.clk);
    fifo_interface_if.rst = 0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            fifo_interface_if.wr = tr.wr;
            fifo_interface_if.rd = tr.rd;
            fifo_interface_if.wdata = tr.wdata;
            tr.display("[Drv]");
            @(posedge fifo_interface_if.clk);
        end
    endtask
endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual fifo_interface fifo_interface_if;
    
    function new(mailbox #(transaction) mon2scb_mbox, virtual fifo_interface fifo_interface_if);
        this.mon2scb_mbox = mon2scb_mbox;
        this.fifo_interface_if = fifo_interface_if;
    endfunction        

    task run();
        forever begin
            tr = new;
            //@(posedge fifo_interface_if.clk);
            #1;
            tr.wr = fifo_interface_if.wr;
            tr.rd = fifo_interface_if.rd;          
            tr.wdata = fifo_interface_if.wdata;
            tr.rdata = fifo_interface_if.rdata;   
            @(posedge fifo_interface_if.clk);  
            tr.full = fifo_interface_if.full;  
            tr.empty = fifo_interface_if.empty;         
            tr.display("[Mon]");
            mon2scb_mbox.put(tr);
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int write_count = 0, read_count = 0, pass_count = 0, fail_count = 0;

    reg [3:0] ram [$:8];

    function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.display("[Scb]");
            if(tr.wr) begin
                ram.push_back(tr.wdata);
                $display("Write!! fifo_data : %d", tr.wdata);
                write_count++;
            end else if(tr.rd) begin
                ram.pop_front();
                $display("Read!! fifo_data : %d", tr.rdata);
                read_count++;
            end
            -> gen_next_event;                     
        end
    endtask

endclass

class environment;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    event gen_next_event;

    function new(virtual fifo_interface fifo_interface_if);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, fifo_interface_if);
        mon = new(mon2scb_mbox, fifo_interface_if);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction

    task report();
        $display("===================================");
        $display("===================================");
        $display("=========== test report ===========");
        $display("==        Total Test : %d        ==",gen.total_count);
        $display("==        WRITE Test : %d        ==",scb.write_count);
        $display("==         PASS Test : %d        ==",scb.pass_count);
        $display("===================================");
        $display("======= Test bench is finish ======");
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
        #10;
        report();
        $stop;
    endtask

endclass

module tb_fifo();
    fifo_interface fifo_interface_tb();
    environment env;

    logic clk = 0;

    fifo dut(
        .clk(fifo_interface_tb.clk),
        .rst(fifo_interface_tb.rst),
        .wr(fifo_interface_tb.wr),
        .rd(fifo_interface_tb.rd),
        .wdata(fifo_interface_tb.wdata),
        .rdata(fifo_interface_tb.rdata),
        .full(fifo_interface_tb.full),
        .empty(fifo_interface_tb.empty)
    ); 

    initial begin
        fifo_interface_tb.clk = 0;
        env = new(fifo_interface_tb);
        env.run(100);
    end

endmodule
