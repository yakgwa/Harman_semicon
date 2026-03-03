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
    logic [31:0] exp_result;

endinterface

class transaction;
    rand bit [4:0] rs1, rs2, rd;
    rand bit [2:0] funct3;
    rand bit funct7b5;

    bit [31:0] instr_code;
    bit [31:0] rs1_val;
    bit [31:0] rs2_val;
    bit [31:0] exp_result;

    function void instruction();
        bit [6:0] opcode = 7'b0110011;
        bit [6:0] funct7 = (funct7b5) ? 7'b0100000 : 7'b0000000;
        instr_code = {funct7[6:0], rs2[4:0], rs1[4:0], funct3[2:0], rd[4:0], opcode[6:0]};
    endfunction


    function void action();
        case ({funct7b5, funct3})
            4'b0000 : exp_result = rs1_val + rs2_val;
            4'b1000 : exp_result = rs1_val - rs2_val;
            4'b0111 : exp_result = rs1_val & rs2_val;
            4'b0110 : exp_result = rs1_val | rs2_val;
            4'b0100 : exp_result = rs1_val ^ rs2_val;
            4'b0010 : exp_result = ($signed(rs1_val) < $signed(rs2_val)) ? 1 : 0;
            4'b0011 : exp_result = (rs1_val < rs2_val) ? 1 : 0;
            4'b0001 : exp_result = rs1_val << rs2_val[4:0];
            4'b0101 : exp_result = rs1_val >> rs2_val[4:0];
            4'b1101 : exp_result = $signed(rs1_val) >>> rs2_val[4:0];
            default : exp_result = 32'hDEAD_BEFF;
        endcase
    endfunction


    task display(string name);
        $display("%t:[%s] : instr_code : %h, exp_reslut : %h, rs1 : %d , rs2 : %d"
        ,$time, name , instr_code, exp_result, rs1, rs2);
    endtask

endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    //mailbox #(transaction) gen2scb_mbox;
    event gen_next_event;

    int total_count = 0;

    function new(mailbox #(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int count);
        repeat(count) begin
            tr = new();
            assert(tr.randomize())
            else $display("Random Error!!!!");
            tr.instruction();  
            gen2drv_mbox.put(tr);
            tr.display("[Gen]");
            total_count++;
            @(gen_next_event);
        end
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) drv2mon_mbox;
    virtual RV32I_R_interface RV32I_R_interface_if;
    event mon_next_event;

    function new(mailbox #(transaction) gen2drv_mbox, virtual RV32I_R_interface RV32I_R_interface_if, 
    mailbox #(transaction) drv2mon_mbox, event mon_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.drv2mon_mbox = drv2mon_mbox;
        this.RV32I_R_interface_if = RV32I_R_interface_if;
        //this.mon_next_event = mon_next_event;
    endfunction

    task reset();
        RV32I_R_interface_if.reset = 1;
        RV32I_R_interface_if.instr_code = 32'b0;
        @(posedge RV32I_R_interface_if.clk);
        RV32I_R_interface_if.reset = 0;
        @(posedge RV32I_R_interface_if.clk);
        $display("Reset done!");
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(tr);

            @(posedge RV32I_R_interface_if.clk);
            RV32I_R_interface_if.instr_code = tr.instr_code;
            RV32I_R_interface_if.exp_result = tr.exp_result;

            tr.display("[Drv]");
            
            drv2mon_mbox.put(tr);
        end
    endtask
endclass


class monitor;
    transaction tr;
    mailbox #(transaction) drv2mon_mbox;
    mailbox #(transaction) mon2scb_mbox;
    virtual RV32I_R_interface RV32I_R_interface_if;
    event mon_next_event;

    function new(mailbox #(transaction) drv2mon_mbox, virtual RV32I_R_interface RV32I_R_interface_if,
                 mailbox #(transaction) mon2scb_mbox, event mon_next_event);
        this.drv2mon_mbox = drv2mon_mbox;
        this.mon2scb_mbox = mon2scb_mbox;
        this.RV32I_R_interface_if = RV32I_R_interface_if;
        //this.mon_next_event = mon_next_event;
    endfunction

    task run();
        forever begin
            @(mon_next_event);
            tr = new;
            drv2mon_mbox.get(tr);

            @(posedge RV32I_R_interface_if.clk);
            tr.rs1_val = tb_RV32I_R.dut.U_RV32I_CPU.U_Data_Path.U_REG_FILE.reg_file[tr.rs1];
            tr.rs2_val = tb_RV32I_R.dut.U_RV32I_CPU.U_Data_Path.U_REG_FILE.reg_file[tr.rs2];

            tr.action();
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

    int pass_count, fail_count = 0;

    bit [4:0] rs1;
    bit [4:0] rs2;
    bit [4:0] rd;

    bit [31:0] rs1_val;
    bit [31:0] rs2_val;
    bit [31:0] expected_result;


    function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;

    endfunction

    task run();
        forever begin
            
            mon2scb_mbox.get(tr);
            tr.display("[Scb]");
            if (tr.exp_result !== tr.dAddr) begin
                $display("[FAIL] rd(x%0d): Expected = %h, Got = %h, instr_code: %08h",
                         tr.rd, tr.exp_result, tr.dAddr, tr.instr_code);
                fail_count++;
            end else begin
                $display("[PASS] rd(x%0d) = %h", tr.rd, tr.exp_result);
                pass_count++;
            end

            -> gen_next_event; 
        end
    endtask
endclass

class environment;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) drv2mon_mbox;
    mailbox #(transaction) mon2scb_mbox;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    event gen_next_event;
    event mon_next_event;

    function new(virtual RV32I_R_interface RV32I_R_interface_if);
        gen2drv_mbox = new;
        drv2mon_mbox= new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, drv2mon_mbox, RV32I_R_interface_if, mon_next_event);
        mon = new(mon2scb_mbox, drv2mon_mbox, RV32I_R_interface_if, mon_next_event);
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

// interface RV32I_R_interface;
//     logic clk;
//     logic reset;
//     logic [31:0] instr_code; // input
//     logic [31:0] dRdata; // input
//     logic [31:0] instr_rAddr;
//     logic d_wr_en;
//     logic [31:0] dAddr;
//     logic [31:0] dWdata;

// endinterface

// class transaction;
//     rand bit [4:0] rs1, rs2, rd;
//     rand bit [6:0] opcode;   // 7'b0110011 for R-type
//     rand bit [2:0] funct3;
//     rand bit [6:0] funct7;
//     bit [31:0] instr_code;
//     bit [31:0] dRdata;
//     bit [31:0] instr_rAddr;
//     bit d_wr_en;
//     bit [31:0] dAddr;
//     bit [31:0] dWdata;

//     constraint c_opcode {opcode == 7'b0110011; }
//     // constraint c_funct3 {funct3 inside {3'b000, 3'b111, 3'b110, 3'b100};}
//     // constraint c_funct7 {funct7 inside {7'b0000000, 7'b0100000}; }
//     constraint c_funct3_funct7 {
//             funct3 == 3'b000;
//             funct7 == 7'b0000000;
//         //(funct3 == 3'b000 && (funct7 == 7'b0000000 || funct7 == 7'b0100000)); //|| // ADD/SUB
//         // (funct3 == 3'b001 && funct7 == 7'b0000000) ||                           // SLL
//         // (funct3 == 3'b010 && funct7 == 7'b0000000) ||                           // SLT
//         // (funct3 == 3'b011 && funct7 == 7'b0000000) ||                           // SLTU
//         // (funct3 == 3'b100 && funct7 == 7'b0000000) ||                           // XOR
//         // (funct3 == 3'b101 && (funct7 == 7'b0000000 || funct7 == 7'b0100000)) || // SRL/SRA
//         // (funct3 == 3'b110 && funct7 == 7'b0000000) ||                           // OR
//         // (funct3 == 3'b111 && funct7 == 7'b0000000);                             // AND
//     }
//     constraint c_regs {rs1 inside {[0:5]}; rs2 inside {[0:5]}; rd  inside {[0:31]};}

//     function void instruction();
//         instr_code = {funct7, rs2, rs1, funct3, rd, opcode};
//     endfunction

//     task display(string name);
//         $display("%t:[%s] : instr_code : %h, dRdata : %h, instr_rAddr : %h, d_wr_en : %d, dAddr : %h, dWdata : %h"
//         ,$time, name , instr_code, dRdata, instr_rAddr, d_wr_en, dAddr, dWdata);
//     endtask

// endclass

// class generator;
//     transaction tr;
//     mailbox #(transaction) gen2drv_mbox;
//     //mailbox #(transaction) gen2scb_mbox;
//     event gen_next_event;

//     int total_count = 0;

//     function new(mailbox #(transaction) gen2drv_mbox, event gen_next_event);
//         this.gen2drv_mbox = gen2drv_mbox;
//         this.gen_next_event = gen_next_event;
//     endfunction

//     task run(int count);
//         repeat(count) begin
//             total_count++;
//             tr = new();
//             assert(tr.randomize())
//             else $display("Random Error!!!!");
//             tr.instruction();  
//             gen2drv_mbox.put(tr);
//             tr.display("[Gen]");
//             $display("Machine Code: %08h", tr.instr_code);
//             @(gen_next_event);
//         end
//     endtask

// endclass

// class driver;
//     transaction tr;
//     mailbox #(transaction) gen2drv_mbox;
//     virtual RV32I_R_interface RV32I_R_interface_if;
//     event mon_next_event;

//     function new(mailbox #(transaction) gen2drv_mbox, virtual RV32I_R_interface RV32I_R_interface_if, 
//     event mon_next_event);
//         this.gen2drv_mbox = gen2drv_mbox;
//         this.RV32I_R_interface_if = RV32I_R_interface_if;
//         this.mon_next_event = mon_next_event;
//     endfunction

//     task reset();
//         RV32I_R_interface_if.reset = 1;
//         RV32I_R_interface_if.instr_code = 32'b0;
//         RV32I_R_interface_if.dRdata = 32'b0;
//         @(posedge RV32I_R_interface_if.clk);
//         RV32I_R_interface_if.reset = 0;
//         @(posedge RV32I_R_interface_if.clk);
//         $display("Reset done!");
//     endtask

//     task run();
//         forever begin
//         $display("%t: Driver waiting for transaction.", $time);
//         @(posedge RV32I_R_interface_if.clk);
//         gen2drv_mbox.get(tr);
//         $display("%t: Driver get transaction", $time);
//         @(posedge RV32I_R_interface_if.clk);
//         RV32I_R_interface_if.instr_code = tr.instr_code;
//         RV32I_R_interface_if.dRdata = tr.dRdata;
//         //RV32I_R_interface_if.instr_rAddr = tr.instr_rAddr;
//         //RV32I_R_interface_if.d_wr_en = tr.d_wr_en;
//         //RV32I_R_interface_if.dAddr = tr.dAddr;   
//         //RV32I_R_interface_if.dWdata = tr.dWdata;    
//         @(posedge RV32I_R_interface_if.clk);
//         tr.display("[Drv]");
//         @(posedge RV32I_R_interface_if.clk);
//         -> mon_next_event;
//         end
//     endtask
// endclass


// class monitor;
//     transaction tr;
//     mailbox #(transaction) mon2scb_mbox;
//     virtual RV32I_R_interface RV32I_R_interface_if;
//     event mon_next_event;

//     function new(mailbox #(transaction) mon2scb_mbox, virtual RV32I_R_interface RV32I_R_interface_if,
//                  event mon_next_event);
//         this.mon2scb_mbox = mon2scb_mbox;
//         this.RV32I_R_interface_if = RV32I_R_interface_if;
//         this.mon_next_event = mon_next_event;
//     endfunction

//     task run();
//         forever begin
//             @(mon_next_event);
//             tr = new;
//             @(posedge RV32I_R_interface_if.clk);
//             #1
//             tr.instr_code = RV32I_R_interface_if.instr_code;
//             tr.dRdata = RV32I_R_interface_if.dRdata;
//             tr.instr_rAddr = RV32I_R_interface_if.instr_rAddr;
//             tr.d_wr_en = RV32I_R_interface_if.d_wr_en;
//             tr.dAddr = RV32I_R_interface_if.dAddr;   
//             tr.dWdata = RV32I_R_interface_if.dWdata;  

//             tr.rd     = tr.instr_code[11:7];
//             tr.funct3 = tr.instr_code[14:12];
//             tr.rs1    = tr.instr_code[19:15];
//             tr.rs2    = tr.instr_code[24:20];
//             tr.funct7 = tr.instr_code[31:25];

//             tr.display("[Mon]");
//             @(posedge RV32I_R_interface_if.clk);
//             mon2scb_mbox.put(tr);
//         end
//     endtask
// endclass

// class scoreboard;
//     transaction tr;
//     mailbox #(transaction) mon2scb_mbox;
//     event gen_next_event;

//     int pass_count, fail_count = 0;

//     bit [4:0] rs1;
//     bit [4:0] rs2;
//     bit [4:0] rd;

//     bit [31:0] rs1_val;
//     bit [31:0] rs2_val;
//     bit [31:0] expected_result;

//     bit [31:0] reg_file [0:31];

//     function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
//         this.mon2scb_mbox = mon2scb_mbox;
//         this.gen_next_event = gen_next_event;

//         foreach (reg_file[i]) reg_file[i] = 0;
//         reg_file[1] = 1;
//         reg_file[2] = 2;
//         reg_file[3] = 3;
//         reg_file[4] = 4;
//         reg_file[5] = 5;

//     endfunction

//     task run();
//         forever begin
//             mon2scb_mbox.get(tr);
//             tr.display("[Scb]");

//             // if (tr.rd != 0) begin
//             //     reg_file[tr.rd] = tr.dAddr;
//             // end

//             rs1_val = reg_file[tr.rs1];
//             rs2_val = reg_file[tr.rs2];

//             case ({tr.funct7, tr.funct3})
//                 {7'b0000000, 3'b000}: expected_result = rs1_val + rs2_val;  // ADD
//                 {7'b0100000, 3'b000}: expected_result = rs1_val - rs2_val;  // SUB
//                 {7'b0000000, 3'b111}: expected_result = rs1_val & rs2_val;  // AND
//                 {7'b0000000, 3'b110}: expected_result = rs1_val | rs2_val;  // OR
//                 {7'b0000000, 3'b100}: expected_result = rs1_val ^ rs2_val;  // XOR
//                 default: expected_result = 32'hx; 
//             endcase

//             //expected_result = rs1_val + rs2_val;

//             if (tr.dAddr !== expected_result) begin
//                 //$display("[FAIL] rd(x%0d): Expected %h, Got %h", tr.rd, expected_result, tr.dAddr);
//                 $display("[FAIL] rd(x%0d): Expected %h, Got %h, instr_code: %08h", tr.rd, expected_result, tr.dAddr, tr.instr_code);
//                 fail_count++;
//             end else begin
//                 $display("[PASS] rd(x%0d) = %h", tr.rd, expected_result);
//                 pass_count++;
//             end

//             if (tr.rd != 0) begin
//                 reg_file[tr.rd] = tr.dAddr;
//             end

//             -> gen_next_event;
//         end
//     endtask
// endclass

// class environment;
//     transaction tr;
//     mailbox #(transaction) gen2drv_mbox;
//     mailbox #(transaction) gen2scb_mbox;
//     mailbox #(transaction) mon2scb_mbox;
//     generator gen;
//     driver drv;
//     monitor mon;
//     scoreboard scb;
//     event gen_next_event;
//     event mon_next_event;

//     function new(virtual RV32I_R_interface RV32I_R_interface_if);
//         gen2drv_mbox = new;
//         gen2scb_mbox= new;
//         mon2scb_mbox = new;
//         gen = new(gen2drv_mbox, gen_next_event);
//         drv = new(gen2drv_mbox, RV32I_R_interface_if, mon_next_event);
//         mon = new(mon2scb_mbox, RV32I_R_interface_if, mon_next_event);
//         scb = new(mon2scb_mbox, gen_next_event);
//     endfunction

//     task report();
//         $display("===================================");
//         $display("===================================");
//         $display("=========== test report ===========");
//         $display("==        Total Test : %d        ==",gen.total_count);
//         $display("==         PASS Test : %d        ==",scb.pass_count);
//         $display("==         FAIL Test : %d        ==",scb.fail_count);
//         $display("===================================");
//         $display("======= Test bench is finish ======");
//         $display("===================================");
//     endtask

//     task run(int count);
//         drv.reset();
//         fork
//             gen.run(count);
//             drv.run();
//             mon.run();
//             scb.run();
//         join_any
//         #10;
//         report();
//         $stop;
//     endtask

// endclass

// module tb_RV32I_R();
//     RV32I_R_interface RV32I_R_interface_tb();
//     environment env;

//     logic clk = 0;

//     RV32I_Core dut(
//     .clk(RV32I_R_interface_tb.clk),
//     .reset(RV32I_R_interface_tb.reset),
//     .instr_code(RV32I_R_interface_tb.instr_code),
//     .dRdata(RV32I_R_interface_tb.dRdata),
//     .instr_rAddr(RV32I_R_interface_tb.instr_rAddr),
//     .d_wr_en(RV32I_R_interface_tb.d_wr_en),
//     .dAddr(RV32I_R_interface_tb.dAddr),
//     .dWdata(RV32I_R_interface_tb.dWdata)  
//     );

//     always #5 RV32I_R_interface_tb.clk = ~RV32I_R_interface_tb.clk;

//     initial begin
//        RV32I_R_interface_tb.clk = 0;
//        env = new(RV32I_R_interface_tb);
//        env.run(50); 
//     end

// endmodule