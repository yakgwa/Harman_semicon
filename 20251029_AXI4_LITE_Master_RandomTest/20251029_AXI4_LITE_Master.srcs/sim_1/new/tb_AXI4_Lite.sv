`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/29 17:09:53
// Design Name: 
// Module Name: tb_AXI4_Lite
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

interface axi_master_if(
    input logic  clk,
    input logic  reset
);
    logic        transfer;
    logic        ready;
    logic [ 3:0] addr;
    logic [31:0] wdata;
    logic        write;
    logic [31:0] rdata;
endinterface

class transaction;
    logic        transfer;
    logic        ready;
    rand logic [ 3:0] addr;
    rand logic [31:0] wdata;
    logic        write;
    logic [31:0] rdata;    

    constraint c_addr {
        addr inside
            {[4'h0 : 4'hc]};
        addr % 4 == 0;
    }

    task automatic print(string name);
        $display("([%s], transfer = %h, write = %h, addr = %h, wdata = %h, rdata = %h)",
        name, transfer, write, addr, wdata, rdata);
    endtask

endclass

class apbSignal;

    virtual axi_master_if m_if;

    transaction t;

    int total, pass, fail;

    function new(virtual axi_master_if m_if);
        this.m_if = m_if;
        this.t = new();
    endfunction  //new()

    task automatic send();  //logic [31:0] addr);
        t.transfer = 1'b1;
        t.write = 1'b1;
        m_if.transfer <= t.transfer;
        m_if.write    <= t.write;
        m_if.addr     <= t.addr;
        m_if.wdata    <= t.wdata;
        @(posedge m_if.clk);
        m_if.transfer <= 1'b0;
        @(posedge m_if.clk);
        wait (m_if.ready);
        t.print("SEND");
        @(posedge m_if.clk);
    endtask  //automatic

    task automatic receive();
        t.transfer = 1'b1;
        t.write    = 1'b0;
        m_if.transfer <= t.transfer;
        m_if.write    <= t.write;
        m_if.addr     <= t.addr;
        @(posedge m_if.clk);
        m_if.transfer <= 1'b0;
        @(posedge m_if.clk);
        wait (m_if.ready);
        t.rdata <= m_if.rdata;
        t.print("RECEIVE");
        @(posedge m_if.clk);
    endtask  //automatic

    task automatic compare();
        total++;
        if(t.wdata == t.rdata) begin
            pass++;
            $display("PASS");
        end else begin
            fail++;
            $display("FAIL");
        end
    endtask

    task automatic run(int loop);
        repeat(loop) begin
            t.randomize();
            send();
            receive();
            compare();
        end
    endtask

    task automatic report();
        $display("===================================");
        $display("=========== TEST REPORT ===========");
        $display("== Total Transactions: %0d ==", total);
        $display("== PASS Count: %0d ==", pass);
        $display("== FAIL Count: %0d ==", fail);
        $display("===================================");
    endtask

endclass  //apbSignal


module tb_AXI4_Lite();
    // Global Signal
    logic ACLK;
    logic ARESETn;
    // WRITE Transaction, AW Channel
    logic [3:0]  AWADDR;
    logic        AWVALID;
    logic        AWREADY;
    // WRITE Transaction, W Channel
    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;
    // WRITE Transaction, B Channel
    logic [1:0]  BRESP;
    logic        BVALID;
    logic        BREADY;
    // READ Transaction, AR Channel
    logic [3:0] ARADDR; 
    logic       ARVALID; 
    logic       ARREADY; 

    // READ Transaction, R Channel
    logic [31:0] RDATA;
    logic        RVALID;
    logic        RREADY;

    axi_master_if m_if (
        ACLK,
        ARESETn
    );

    apbSignal apbSignalTester;

    AXI4_lite_Master dut_master(
        .*,
        .transfer(m_if.transfer),
        .write   (m_if.write),
        .addr    (m_if.addr),
        .wdata   (m_if.wdata),
        .rdata   (m_if.rdata),
        .ready   (m_if.ready)
        );
    AXI4_lite_Slave dut_slave(.*);

    always #5 ACLK = ~ACLK;

    initial begin
        ACLK = 0;
        ARESETn = 0;
        #10 ARESETn = 1;
    end

    initial begin
         apbSignalTester = new(m_if);

        repeat (3) @(posedge ACLK);

        apbSignalTester.run(100);

        apbSignalTester.report();

        @(posedge ACLK);
        #100;
        $finish;
    end
endmodule


// module tb_AXI4_Lite();
//     // Global Signal
//     logic ACLK;
//     logic ARESETn;
//     // WRITE Transaction, AW Channel
//     logic [3:0]  AWADDR;
//     logic        AWVALID;
//     logic        AWREADY;
//     // WRITE Transaction, W Channel
//     logic [31:0] WDATA;
//     logic        WVALID;
//     logic        WREADY;
//     // WRITE Transaction, B Channel
//     logic [1:0]  BRESP;
//     logic        BVALID;
//     logic        BREADY;
//     // READ Transaction, AR Channel
//     logic [3:0] ARADDR; 
//     logic       ARVALID; 
//     logic       ARREADY; 

//     // READ Transaction, R Channel
//     logic [31:0] RDATA;
//     logic        RVALID;
//     logic        RREADY;

//     // internal Signals
//     logic        transfer;
//     logic        ready;
//     logic [ 3:0] addr;
//     logic [31:0] wdata;
//     logic        write;
//     logic [31:0] rdata;

//     AXI4_lite_Master dut_master(.*);
//     AXI4_lite_Slave dut_slave(.*);

//     always #5 ACLK = ~ACLK;

//     initial begin
//         ACLK = 0;
//         ARESETn = 0;
//         #10 ARESETn = 1;

//         @(posedge ACLK);
//         #1; addr = 0; wdata = 10; write = 1; transfer = 1;
//         @(posedge ACLK);
//         #1; transfer = 0;
//         wait(ready == 1);

//         @(posedge ACLK);
//         #1; addr = 4; wdata = 11; write = 1; transfer = 1;
//         @(posedge ACLK);
//         #1; transfer = 0;
//         wait(ready == 1);

//         @(posedge ACLK);
//         #1; addr = 8; wdata = 12; write = 1; transfer = 1;
//         @(posedge ACLK);
//         #1; transfer = 0;
//         wait(ready == 1);
        
//         //read
//         @(posedge ACLK);
//         #1; addr = 12; write = 0; transfer = 1;
//         @(posedge ACLK);
//         #1; transfer = 0;
//         wait(ready == 1);

//         @(posedge ACLK);
//         #1; addr = 8; write = 0; transfer = 1;
//         @(posedge ACLK);
//         #1; transfer = 0;
//         wait(ready == 1);

//         @(posedge ACLK);
//         #1; addr = 4; write = 0; transfer = 1;
//         @(posedge ACLK);
//         #1; transfer = 0;
//         wait(ready == 1);

//         @(posedge ACLK);
//         #1; addr = 0; write = 0; transfer = 1;
//         @(posedge ACLK);
//         #1; transfer = 0;
//         wait(ready == 1);

//         #100;
//         $finish;
//     end
// endmodule
