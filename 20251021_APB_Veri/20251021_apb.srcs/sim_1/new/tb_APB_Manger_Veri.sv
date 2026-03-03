`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/21 16:34:33
// Design Name: 
// Module Name: tb_APB_Manger_Veri
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

interface apb_interface;
    logic PCLK;
    logic PRESET;
    logic transfer;
    logic write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic ready;
endinterface

class apb_transaction;
    rand bit transfer;
    rand bit write;
    rand bit [31:0] addr;
    rand bit [31:0] wdata;
    bit [31:0]rdata;
    bit ready;

    int num;
    int i;

    constraint transfer_first {
        transfer == 1;//(num == 0) ? 1 : transfer inside {0, 1};
        write == (num % 2 == 0) ? 1 : write inside {0, 1};
    }



    task display(string name);
        $display("%t:[%s] : transfer : %0b, write : %0b, addr : %0h, wdata : %0h, rdata : %0h",
        $time, name, transfer, write, addr, wdata, rdata);
    endtask

endclass

class generator;
    apb_transaction tr;
    mailbox #(apb_transaction) gen2drv_mbox;
    event gen_next_event;

    int total_count = 0;
    int base_addr = 32'h1000_0000;

    function new(mailbox #(apb_transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int count);
        repeat(count) begin
            total_count++;
            tr = new;
            assert(tr.randomize() with {addr == base_addr + i * 4;})
            else $display("Random Error!!!!");
            gen2drv_mbox.put(tr);
            tr.display("[Gen]");
            @(gen_next_event);
        end
    endtask

//     task run(int count);
//         int write_idx = 0;
//         int prev_addr = base_addr;
//         for(int i = 0; i < count; i++) begin
//             total_count++;
//             tr = new;

//             if(i % 2 == 0) begin
//                 tr.write = 1;
//                 assert(tr.randomize() with {addr == base_addr + write_idx * 4;})
//                 else $display("Random Error!!!!");
//                 prev_addr = tr.addr;
//                 write_idx++;
//             end else begin
//                 tr.write = 0;
//                 assert(tr.randomize() with {addr == prev_addr;})
//                 else $display("Random Error!!!!");
//             end
//             gen2drv_mbox.put(tr);
//             tr.display("[Gen]");
//             @(gen_next_event);
//         end
//     endtask

endclass

class driver;
    apb_transaction tr;
    mailbox #(apb_transaction) gen2drv_mbox;
    virtual apb_interface apb_interface_if;
    event mon_next_event;


    function new(mailbox #(apb_transaction) gen2drv_mbox, virtual apb_interface apb_interface_if
    ,event mon_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.apb_interface_if = apb_interface_if;
        this.mon_next_event = mon_next_event;
    endfunction

    task reset();
        apb_interface_if.PRESET = 1;
        apb_interface_if.transfer = 1'b0;
        apb_interface_if.write = 1'b0;
        apb_interface_if.addr = 1'b0;
        apb_interface_if.wdata = 1'b0;
        repeat(2) @(posedge apb_interface_if.PCLK);
        apb_interface_if.PRESET = 0;
        repeat(2) @(posedge apb_interface_if.PCLK);
        $display("Reset done!");
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            @(posedge apb_interface_if.PCLK);
            #1
            apb_interface_if.transfer = tr.transfer;
            apb_interface_if.write = tr.write;
            apb_interface_if.addr = tr.addr;
            apb_interface_if.wdata = tr.wdata;
            tr.display("[Drv]");
            @(posedge apb_interface_if.PCLK);
            apb_interface_if.transfer = 1'b0;
            @(posedge apb_interface_if.PCLK);
            wait(apb_interface_if.ready == 1'b1);
            //apb_interface_if.transfer = 1'b0;
            //apb_interface_if.write = 1'b0;
            @(posedge apb_interface_if.PCLK);
            -> mon_next_event;
        end
    endtask
endclass

class monitor;
    apb_transaction tr;
    mailbox #(apb_transaction) mon2scb_mbox;
    virtual apb_interface apb_interface_if;
    event mon_next_event;


    function new(mailbox #(apb_transaction) mon2scb_mbox, virtual apb_interface apb_interface_if
    ,event mon_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.apb_interface_if = apb_interface_if;
        this.mon_next_event = mon_next_event;
    endfunction

    task run();
        forever begin
            @(mon_next_event);
            tr = new;
            tr.transfer = apb_interface_if.transfer;
            tr.write = apb_interface_if.write;
            tr.addr = apb_interface_if.addr;
            tr.wdata = apb_interface_if.wdata;
            //@(posedge apb_interface_if.PCLK);
            tr.rdata = apb_interface_if.rdata;
            tr.ready = apb_interface_if.ready;
            @(posedge apb_interface_if.PCLK);
            mon2scb_mbox.put(tr);
            tr.display("[Mon]");
        end
    endtask
endclass

// class scoreboard;
//     apb_transaction tr;
//     mailbox #(apb_transaction) mon2scb_mbox;
//     event gen_next_event;

//     int pass_count, fail_count = 0;

//     function new(mailbox #(apb_transaction) mon2scb_mbox, event gen_next_event);
//         this.mon2scb_mbox = mon2scb_mbox;
//         this.gen_next_event = gen_next_event;
//     endfunction

//     task run();
//         forever begin
//             mon2scb_mbox.get(tr);
//             tr.display("[Scb]");
            
//             if (tr.rdata == tr.wdata) begin
//                 pass_count++;
//                 $display("[SCB] PASS: wdata = %0h, rdata = %0h", tr.wdata, tr.rdata);
//             end else begin
//                 fail_count++;
//                 $display("[SCB] FAIL: wdata = %0h, rdata = %0h", tr.wdata, tr.rdata);
//             end
//             -> gen_next_event;
//         end
//     endtask

// endclass

class scoreboard;
    apb_transaction tr;
    mailbox #(apb_transaction) mon2scb_mbox;
    event gen_next_event;

    bit [31:0] mem [bit [31:0]]; // reference memory model
    int pass_count, fail_count;

    function new(mailbox #(apb_transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.display("[Scb]");

            if (tr.write) begin
                // write일 때는 데이터 저장
                mem[tr.addr] = tr.wdata;
                $display("[SCB] WRITE stored: addr=%0h, data=%0h", tr.addr, tr.wdata);
            end else begin
                // read일 때는 이전 write 데이터와 비교
                if (mem.exists(tr.addr)) begin
                    bit [31:0] exp = mem[tr.addr];
                    if (tr.rdata == exp) begin
                        pass_count++;
                        $display("[SCB] PASS: addr=%0h, exp=%0h, got=%0h", tr.addr, exp, tr.rdata);
                    end else begin
                        fail_count++;
                        $display("[SCB] FAIL: addr=%0h, exp=%0h, got=%0h", tr.addr, exp, tr.rdata);
                    end
                end else begin
                    $display("[SCB] READ from unknown addr=%0h, got=%0h", tr.addr, tr.rdata);
                end
            end
            -> gen_next_event;
        end
    endtask
endclass

class environment;
    apb_transaction tr;
    mailbox #(apb_transaction) gen2drv_mbox;
    mailbox #(apb_transaction) mon2scb_mbox;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    event gen_next_event;
    event mon_next_event;

    function new(virtual apb_interface apb_interface_if);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, apb_interface_if, mon_next_event);
        mon = new(mon2scb_mbox, apb_interface_if, mon_next_event);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction

    // task report();
    //     $display("===================================");
    //     $display("=========== TEST REPORT ===========");
    //     $display("== Total Transactions: %0d ==", gen.total_count);
    //     $display("== PASS Count: %0d ==", scb.pass_count);
    //     $display("== FAIL Count: %0d ==", scb.fail_count);
    //     $display("===================================");
    // endtask

    task run(int count);
        drv.reset();
        fork
            gen.run(count);
            drv.run();
            mon.run();
            scb.run(); 
        join_any
        //report();
        $stop;
    endtask
endclass




module tb_APB_Manger_Veri();
    apb_interface apb_interface_tb();
    environment env;

    logic [3:0] PADDR;
    logic PWRITE, PENABLE;
    logic [31:0] PWDATA;
    logic PSEL0, PSEL1, PSEL2, PSEL3;
    logic [31:0] PRDATA0, PRDATA1, PRDATA2, PRDATA3;
    logic PREADY0, PREADY1, PREADY2, PREADY3;

    APB_Manager U_APB_MANGER (
        .PCLK(apb_interface_tb.PCLK),
        .PRESET(apb_interface_tb.PRESET),
        .transfer(apb_interface_tb.transfer),
        .write(apb_interface_tb.write),
        .addr(apb_interface_tb.addr),
        .wdata(apb_interface_tb.wdata),
        .rdata(apb_interface_tb.rdata),
        .ready(apb_interface_tb.ready),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PSEL0(PSEL0),
        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PSEL3(PSEL3),
        .PRDATA0(PRDATA0),
        .PRDATA1(PRDATA1),
        .PRDATA2(PRDATA2),
        .PRDATA3(PRDATA3),
        .PREADY0(PREADY0),
        .PREADY1(PREADY1),
        .PREADY2(PREADY2),
        .PREADY3(PREADY3)
    );
    
    APB_Slave U_APB_SLAVE_0 (
        .PCLK(apb_interface_tb.PCLK),
        .PRESET(apb_interface_tb.PRESET),
        .PADDR(PADDR[3:0]),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PSEL(PSEL0),
        .PRDATA(PRDATA0),
        .PREADY(PREADY0)
    );

    APB_Slave U_APB_SLAVE_1 (
        .PCLK(apb_interface_tb.PCLK),
        .PRESET(apb_interface_tb.PRESET),
        .PADDR(PADDR[3:0]),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PSEL(PSEL1),
        .PRDATA(PRDATA1),
        .PREADY(PREADY1)
    );

    APB_Slave U_APB_SLAVE_2 (
        .PCLK(apb_interface_tb.PCLK),
        .PRESET(apb_interface_tb.PRESET),
        .PADDR(PADDR[3:0]),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PSEL(PSEL2),
        .PRDATA(PRDATA2),
        .PREADY(PREADY2)
    );

    APB_Slave U_APB_SLAVE_3 (
        .PCLK(apb_interface_tb.PCLK),
        .PRESET(apb_interface_tb.PRESET),
        .PADDR(PADDR[3:0]),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PSEL(PSEL3),
        .PRDATA(PRDATA3),
        .PREADY(PREADY3)
    );


    always #5 apb_interface_tb.PCLK = ~apb_interface_tb.PCLK;

    initial begin
       apb_interface_tb.PCLK = 0;
       env = new(apb_interface_tb);
       env.run(50); 
    end


endmodule
