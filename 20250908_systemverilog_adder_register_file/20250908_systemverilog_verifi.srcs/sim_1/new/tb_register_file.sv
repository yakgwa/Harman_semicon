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
endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual reg_interface reg_if;

    function new(mailbox #(transaction) gen2drv_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction

    task run(int count);
        repeat(count) begin
            tr = new;
            //tr.randomize();
            assert(tr.randomize())
            else $display("[GEN] tr.randomize() error!!!!!!");
            gen2drv_mbox.put(tr);
            #10;
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
            @(negedge reg_if.clk);
        end
    endtask //run
endclass

// test environment
class environment;

    generator gen;
    driver drv;
    mailbox #(transaction) gen2drv_mbox;
    function new(virtual reg_interface reg_if);
        gen2drv_mbox = new;
        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, reg_if);
    endfunction //new()

    task run(int count);
        drv.reset();
        fork
            gen.run(count);
            drv.run();
        join_any
        #100;
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
