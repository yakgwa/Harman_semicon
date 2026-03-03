`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/09 13:29:47
// Design Name: 
// Module Name: tb_sram
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

interface sram_interface;
    logic clk;
    logic rst;
    logic wr;
    logic [3:0] address;
    logic [7:0] wdata;
    logic [7:0] rdata;    
endinterface //sram_interface

class transaction;
    rand logic wr;
    rand logic [3:0] address;
    rand logic [7:0] wdata;
    rand logic [7:0] rdata;

    task display(string name);
        $display("%t:[%s] : wr : %d, address : %d, wdata : %d, rdata : %d",$time, name , wr, address, wdata, rdata);
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
            else $display("Random Error!!!");
            gen2drv_mbox.put(tr);
            tr.display("[Gen]");
            @(gen_next_event);
        end
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual sram_interface sram_interface_if;

    int i = 0;

    function new(mailbox #(transaction) gen2drv_mbox, virtual sram_interface sram_interface_if);
        this.gen2drv_mbox = gen2drv_mbox;
        this.sram_interface_if = sram_interface_if;
    endfunction

    task reset();
        //#0;
        sram_interface_if.wr = 1;
        sram_interface_if.address = 0;
        sram_interface_if.wdata = 0;
        @(posedge sram_interface_if.clk);
        for (i = 0; i <16; i=i+1) begin
            sram_interface_if.wr = 1;
            sram_interface_if.address = i;
            sram_interface_if.wdata = 0;
            @(posedge sram_interface_if.clk);
        end
        sram_interface_if.wr = 0;
        #10;
    endtask
        
    task run();
        forever begin
            gen2drv_mbox.get(tr);
            sram_interface_if.wr = tr.wr;
            sram_interface_if.address = tr.address;
            sram_interface_if.wdata = tr.wdata;
            tr.display("[Drv]");
            @(posedge sram_interface_if.clk);
        end
    endtask
endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual sram_interface sram_interface_if;

    function new(mailbox #(transaction) mon2scb_mbox, virtual sram_interface sram_interface_if);
        this.mon2scb_mbox = mon2scb_mbox;
        this.sram_interface_if = sram_interface_if;
    endfunction

    task run();
        forever begin
            tr = new;
            @(posedge sram_interface_if.clk);
            #1
            tr.wr = sram_interface_if.wr;
            tr.address = sram_interface_if.address;
            tr.wdata = sram_interface_if.wdata;
            tr.rdata = sram_interface_if.rdata;
            tr.display("[Mon]");
            mon2scb_mbox.put(tr);
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int pass_count = 0, fail_count = 0;

    // ram buffer[0:15]
    byte ram[16]; // golden data, expected data

    function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            // pass fail decision
            mon2scb_mbox.get(tr);
            tr.display("[Scb]");
            if(tr.wr) begin
                ram[tr.address] = tr.wdata;
                $display("-> address [%d] wdata = %d", tr.address, tr.wdata);
            end else begin

                if(ram[tr.address] == tr.rdata) begin
                    pass_count++;
                    $display("-> PASS | address [%d] expected data = %d ==  rdata = %d", tr.address, tr.wdata, tr.rdata);
                end else begin
                    fail_count++;
                    $display("-> FAIL |address [%d]  expected data = %d != rdata = %d", tr.address, tr.wdata, tr.rdata);
                end
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

    function new(virtual sram_interface sram_interface_if);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, sram_interface_if);
        mon = new(mon2scb_mbox, sram_interface_if);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction

    task report();
        $display("===================================");
        $display("===================================");
        $display("=========== test report ===========");
        $display("==        Total Test : %d        ==",gen.total_count);
        $display("==         PASS Test : %d        ==",scb.pass_count);
        $display("==         FAIL Test : %d        ==",scb.fail_count);
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


module tb_sram();
    sram_interface sram_interface_tb();
    environment env;

    logic clk = 0;

    sram dut(
        .clk(sram_interface_tb.clk),
        .wr(sram_interface_tb.wr),
        .address(sram_interface_tb.address),
        .wdata(sram_interface_tb.wdata),
        .rdata(sram_interface_tb.rdata)
        );    

    always #5 sram_interface_tb.clk = ~sram_interface_tb.clk;

    initial begin
        sram_interface_tb.clk = 0;
        env = new(sram_interface_tb);
        env.run(100);
    end

endmodule
