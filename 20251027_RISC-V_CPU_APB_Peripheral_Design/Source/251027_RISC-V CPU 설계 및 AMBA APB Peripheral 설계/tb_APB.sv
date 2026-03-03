`timescale 1ns / 1ps

interface apb_master_if (
    input logic clk,
    input logic reset
);
    logic        transfer;
    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        ready;
endinterface  //apb_interf

class transaction;
    logic             transfer;
    logic             write;
    rand logic [31:0] addr;
    rand logic [31:0] wdata;
    logic      [31:0] rdata;

    constraint c_addr {
        addr inside
            {[32'h1000_0000 : 32'h1000_000c], [32'h1000_1000 : 32'h1000_100c],
             [32'h1000_2000 : 32'h1000_200c], [32'h1000_3000 : 32'h1000_300c]};
        addr % 4 == 0;
    }

    task automatic print(string name);
        $display("([%s], transfer = %h, write = %h, addr = %h, wdata = %h, rdata = %h)",
        name, transfer, write, addr, wdata, rdata);
    endtask

endclass


class apbSignal;

    // logic             transfer;
    // logic             write;
    // rand logic [31:0] addr;
    // rand logic [31:0] wdata;

    // constraint c_addr {
    //     addr inside
    //         {[32'h1000_0000 : 32'h1000_000c], [32'h1000_1000 : 32'h1000_100c],
    //          [32'h1000_2000 : 32'h1000_200c], [32'h1000_3000 : 32'h1000_300c]};
    //     addr % 4 == 0;
    // }

    virtual apb_master_if m_if;
    // logic [31:0] rdata;
    // logic        ready;
    transaction t;

    function new(virtual apb_master_if m_if);
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
        if(t.wdata == t.rdata) begin
            $display("PASS");
        end else begin
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

endclass  //apbSignal


module tb_APB ();

    // global signals
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [ 3:0] PADDR;
    logic        PWRITE;
    //logic        PSEL;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;

    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;

    // Internal Interface Signals
    // logic            transfer;
    // logic            write;
    // logic     [31:0] addr;
    // logic     [31:0] wdata;
    // logic     [31:0] rdata;
    // logic            ready;

    apb_master_if m_if (
        PCLK,
        PRESET
    );

    // apbSignal apbUART;  // handler
    // apbSignal apbUART_clone;  // handler
    // apbSignal apbGPIO;  // handler
    // apbSignal apbTimer;  // handlek
    apbSignal apbSignalTester;


    APB_Manager dut_mamger (
        .*,
        .transfer(m_if.transfer),
        .write   (m_if.write),
        .addr    (m_if.addr),
        .wdata   (m_if.wdata),
        .rdata   (m_if.rdata),
        .ready   (m_if.ready)
    );
    APB_Slave dut_slave_0 (
        .*,
        .PSEL  (PSEL0),
        .PRDATA(PRDATA0),
        .PREADY(PREADY0)
    );
    APB_Slave dut_slave_1 (
        .*,
        .PSEL  (PSEL1),
        .PRDATA(PRDATA1),
        .PREADY(PREADY1)
    );
    APB_Slave dut_slave_2 (
        .*,
        .PSEL  (PSEL2),
        .PRDATA(PRDATA2),
        .PREADY(PREADY2)
    );
    APB_Slave dut_slave_3 (
        .*,
        .PSEL  (PSEL3),
        .PRDATA(PRDATA3),
        .PREADY(PREADY3)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        #00 PCLK = 0;
        PRESET = 1;
        #10 PRESET = 0;
    end

    // task automatic apbMasterWrite(logic [31:0] address, logic [31:0] data);
    //     transfer = 1'b1;
    //     write = 1'b1;
    //     addr = address;
    //     wdata = data;
    //     @(posedge PCLK);
    //     transfer = 1'b0;
    //     @(posedge PCLK);
    //     wait (ready);
    //     @(posedge PCLK);
    // endtask  //automatic


    // task automatic apbMasterRead(logic [31:0] address);
    //     transfer = 1'b1;
    //     write = 1'b0;
    //     addr = address;
    //     @(posedge PCLK);
    //     transfer = 1'b0;
    //     @(posedge PCLK);
    //     wait (ready);
    //     @(posedge PCLK);
    // endtask  //automatic

    initial begin
        apbSignalTester = new(m_if);

        repeat (3) @(posedge PCLK);

        apbSignalTester.run(100);

        // for (int i = 0; i < 100; i++) begin
        //     apbSignalTester.randomize();
        //     apbSignalTester.send();
        //     apbSignalTester.receive();
        // end
        /*
        apbUART.send(32'h1000_0000);
        apbUART_clone.receive(32'h1000_0000);

        apbGPIO.randomize();
        apbGPIO.send(32'h1000_1000);
        apbGPIO.receive(32'h1000_1000);

        apbTimer.randomize();
        apbTimer.send(32'h1000_2000);
        apbTimer.receive(32'h1000_2000);
*/

        // apbMasterWrite(32'h1000_0000, 32'h11111111);
        // apbMasterWrite(32'h1000_1000, 32'h22222222);
        // apbMasterWrite(32'h1000_2000, 32'h33333333);
        // apbMasterWrite(32'h1000_3000, 32'h44444444);

        // apbMasterRead(32'h1000_0000);
        // apbMasterRead(32'h1000_1000);
        // apbMasterRead(32'h1000_2000);
        // apbMasterRead(32'h1000_3000);

        @(posedge PCLK);
        #20;
        $finish;
    end
endmodule
