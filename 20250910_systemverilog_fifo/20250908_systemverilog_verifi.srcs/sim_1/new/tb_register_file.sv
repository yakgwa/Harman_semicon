`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/08 15:37:51
// Design Name: 
// Module Name: tb_register_file
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

interface reg_interface;
    logic clk;
    logic rst;
    logic w_en;
    logic[7:0] wdata;
    logic [7:0] rdata;
endinterface

class transaction;
    rand bit w_en;
    rand bit [7:0] wdata;
    bit [7:0] rdata;

    task display(string name);
        $display("%t:[%s] : w_en = %d, wdata = %d, rdata = %d", $time, name, w_en, wdata, rdata);
    endtask
endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    // event를 받기 위한
    event gen_next_event;
    virtual reg_interface reg_if;

    int total_count = 0;

    function new(mailbox #(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int count);
        repeat(count) begin
            total_count++;
            tr = new;
            //tr.randomize();
            assert(tr.randomize())
            else $display("[GEN] tr.randomize() error!!!!!!");
            gen2drv_mbox.put(tr);
            tr.display("[Gen]");
            //#10;
            // Receive event
            @(gen_next_event);
        end
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual reg_interface reg_if;

    function new(mailbox #(transaction) gen2drv_mbox, virtual reg_interface reg_if);
        this.gen2drv_mbox = gen2drv_mbox;
        this.reg_if = reg_if;
    endfunction

    task reset();
        reg_if.rst = 1;
        reg_if.w_en = 0;
        reg_if.wdata = 0;
        #10;
        reg_if.rst = 0;
    endtask


    task run ();
        forever begin
            gen2drv_mbox.get(tr); // blocking when empty in mailbox
            reg_if.w_en = tr.w_en;
            reg_if.wdata = tr.wdata;
            tr.display("[Drv]");
            @(posedge reg_if.clk);
            //tr.display("[Drv]");
        end
    endtask //run
endclass

class monitor;
    transaction tr;
    virtual reg_interface reg_if;
    mailbox #(transaction) mon2scb_mbox;

    function new(mailbox #(transaction) mon2scb_mbox, virtual reg_interface reg_if);
        this.mon2scb_mbox = mon2scb_mbox;
        this.reg_if = reg_if;
    endfunction

    task run();
        forever begin
            // generate transaction
            tr = new;
            #2 // 첫 데이터가 밀려서 Delay 추가
            tr.w_en = reg_if.w_en;
            tr.wdata = reg_if.wdata;
            @(posedge reg_if.clk); // compare for register logic output with input
            #1
            tr.rdata = reg_if.rdata;
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

    function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            // pass fail decision
            mon2scb_mbox.get(tr);
            tr.display("[Scb]");
            if(tr.w_en) begin
                if(tr.wdata == tr.rdata) begin
                    pass_count++;
                    $display("-> PASS | expected data = %d ==  rdata = %d", tr.wdata, tr.rdata);
                end else begin
                    fail_count++;
                    $display("-> FAIL | expected data = %d != rdata = %d", tr.wdata, tr.rdata);
                end
            end else begin
                $display("-> read data = %d", tr.rdata);
            end
            -> gen_next_event;
        end
    endtask

endclass

// test environment
class environment;

    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    function new(virtual reg_interface reg_if);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox , gen_next_event);
        drv = new(gen2drv_mbox, reg_if); // 
        mon = new(mon2scb_mbox, reg_if);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction //new()

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
    endtask //run

endclass //environment



module tb_register_file();

    reg_interface reg_interface_tb();
    environment env;

    logic clk = 0;

    register_file dut(
        .clk(reg_interface_tb.clk),
        .rst(reg_interface_tb.rst),
        .w_en(reg_interface_tb.w_en),
        .wdata(reg_interface_tb.wdata),
        .rdata(reg_interface_tb.rdata)
        );

        always #5 reg_interface_tb.clk = ~reg_interface_tb.clk;

        initial begin
             reg_interface_tb.clk = 0;
             env = new(reg_interface_tb);
             env.run(100);
        end

endmodule
