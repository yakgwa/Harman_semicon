`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/25 13:50:02
// Design Name: 
// Module Name: tb_RV32I_R
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

interface RV32I_R_interface;
    logic clk;
    logic reset;
    logic [31:0] instr_code; // input
    logic [31:0] dRdata; // input
    logic [31:0] instr_rAddr;
    logic d_wr_en;
    logic [31:0] dAddr;
    logic [31:0] dWdata;

endinterface

class transaction;
    rand bit [4:0] rs1, rs2, rd;
    rand bit [6:0] opcode;   // 7'b0110011 for R-type
    rand bit [2:0] funct3;
    rand bit [6:0] funct7;
    bit [31:0] instr_code;
    bit [31:0] dRdata;
    bit [31:0] instr_rAddr;
    bit d_wr_en;
    bit [31:0] dAddr;
    bit [31:0] dWdata;

    constraint c_opcode {opcode == 7'b0110011; }
    constraint c_funct3 {funct3 inside {3'b000, 3'b111, 3'b110, 3'b100};}
    constraint c_funct7 {funct7 inside {7'b0000000, 7'b0100000}; }
    constraint c_regs {rs1 inside {[0:31]}; rs2 inside {[0:31]}; rd  inside {[0:31]};}

    function void instruction();
        instr_code = {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction

    task display(string name);
        $display("%t:[%s] : instr_code : %h, dRdata : %h, instr_rAddr : %h, d_wr_en : %d, dAddr : %h, dWdata : %h"
        ,$time, name , instr_code, dRdata, instr_rAddr, d_wr_en, dAddr, dWdata);
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
            tr = new();
            assert(tr.randomize())
            else $display("Random Error!!!!");
            tr.instruction();  
            tr.display("[Gen]");
            gen2drv_mbox.put(tr);
            gen2scb_mbox.put(tr);
            -> gen_next_event;
        end
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual RV32I_R_interface RV32I_R_interface_if;
    event mon_next_event;

    function new(mailbox #(transaction) gen2drv_mbox, virtual RV32I_R_interface RV32I_R_interface_if, 
    event mon_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.RV32I_R_interface_if = RV32I_R_interface_if;
        this.mon_next_event = mon_next_event;
    endfunction

    task reset();
        RV32I_R_interface_if.reset = 1;
        RV32I_R_interface_if.instr_code = 32'b0;
        RV32I_R_interface_if.dRdata = 32'b0;
        repeat(2) @(posedge RV32I_R_interface_if.clk);
        RV32I_R_interface_if.reset = 0;
        repeat(2) @(posedge RV32I_R_interface_if.clk);
        $display("Reset done!");
    endtask

    task run();
        forever begin
        gen2drv_mbox.get(tr);
        repeat(2) @(posedge RV32I_R_interface_if.clk);
        RV32I_R_interface_if.instr_code = tr.instr_code;
        RV32I_R_interface_if.dRdata = tr.dRdata;
        RV32I_R_interface_if.instr_rAddr = tr.rs1 + tr.rs2;
        RV32I_R_interface_if.d_wr_en = tr.d_wr_en;
        RV32I_R_interface_if.dAddr = tr.dAddr;   
        RV32I_R_interface_if.dWdata = tr.dWdata;      
        repeat(2) @(posedge RV32I_R_interface_if.clk);
        tr.display("[Drv]");
        -> mon_next_event;
        end
    endtask
endclass


class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual RV32I_R_interface RV32I_R_interface_if;
    event mon_next_event;

    function new(mailbox #(transaction) mon2scb_mbox, virtual RV32I_R_interface RV32I_R_interface_if,
                 event mon_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.RV32I_R_interface_if = RV32I_R_interface_if;
        this.mon_next_event = mon_next_event;
    endfunction

    task run();
        forever begin
            @(mon_next_event);
            tr = new;
            @(posedge RV32I_R_interface_if.clk);
            #1
            tr.instr_code = RV32I_R_interface_if.instr_code;
            tr.dRdata = RV32I_R_interface_if.dRdata;
            tr.instr_rAddr = RV32I_R_interface_if.instr_rAddr;
            tr.d_wr_en = RV32I_R_interface_if.d_wr_en;
            tr.dAddr = RV32I_R_interface_if.dAddr;   
            tr.dWdata = RV32I_R_interface_if.dWdata;  
            
            tr.display("[Mon]");
            @(posedge RV32I_R_interface_if.clk);
            mon2scb_mbox.put(tr);
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int pass_count = 0, fail_count = 0;
    logic [31:0] result_expected;

    function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            // pass fail decision
            mon2scb_mbox.get(tr);
            tr.display("[Scb]");

            if(tr.dAddr === tr.rs1 + tr.rs2) pass_count++;
            else fail_count++;      
        end
    endtask


endclass

class environment;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) gen2scb_mbox;
    mailbox #(transaction) mon2scb_mbox;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    event gen_next_event;
    event mon_next_event;

    function new(virtual RV32I_R_interface RV32I_R_interface_if);
        gen2drv_mbox = new;
        gen2scb_mbox= new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, gen2scb_mbox, gen_next_event);
        drv = new(gen2drv_mbox, RV32I_R_interface_if, mon_next_event);
        mon = new(mon2scb_mbox, RV32I_R_interface_if, mon_next_event);
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

module tb_RV32I_R();
    RV32I_R_interface RV32I_R_interface_tb();
    environment env;

    logic clk = 0;

    RV32I_Core dut(
    .clk(RV32I_R_interface_tb.clk),
    .reset(RV32I_R_interface_tb.reset),
    .instr_code(RV32I_R_interface_tb.instr_code),
    .dRdata(RV32I_R_interface_tb.dRdata),
    .instr_rAddr(RV32I_R_interface_tb.instr_rAddr),
    .d_wr_en(RV32I_R_interface_tb.d_wr_en),
    .dAddr(RV32I_R_interface_tb.dAddr),
    .dWdata(RV32I_R_interface_tb.dWdata)        
    );

    always #5 RV32I_R_interface_tb.clk = ~RV32I_R_interface_tb.clk;

    initial begin
       RV32I_R_interface_tb.clk = 0;
       env = new(RV32I_R_interface_tb);
       env.run(50); 
    end

endmodule
