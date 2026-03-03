`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/22 10:45:40
// Design Name: 
// Module Name: tb_APB
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

interface apb_master_if(input logic clk, input logic reset);
    logic transfer; 
    logic write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic ready;
endinterface

class apbCoverage;
    logic [31:0] all_addrs[15:0] = '{
        32'h1000_0000, 32'h1000_0004, 32'h1000_0008, 32'h1000_000c,
        32'h1000_1000, 32'h1000_1004, 32'h1000_1008, 32'h1000_100c,
        32'h1000_2000, 32'h1000_2004, 32'h1000_2008, 32'h1000_200c,
        32'h1000_3000, 32'h1000_3004, 32'h1000_3008, 32'h1000_300c
    };

    bit addr_covered[15:0];
    //int hit = 0;

    function void record_addr(logic [31:0] addr);
        for (int i=0; i < 16; i++) begin
            if (addr == all_addrs[i]) begin
                addr_covered[i] = 1;
                break;
            end
        end
    endfunction

    function void display_coverage(string name);
        int hit = 0;
        //$display("=== Register Access Coverage for %s ===", name);
        for (int i=0; i < 16; i++) begin
            if (addr_covered[i]) begin
                hit++;
                $display("  Accessed: 0x%08h", all_addrs[i]);
            //end else begin
                //$display("  Missed:   0x%08h", all_addrs[i]);
            end
        end
        $display("Summary: %0d / 16 registers accessed (%.1f%%)\n",
                 hit, (hit*100.0)/16);
    endfunction
endclass


class apbSignal; // transaction
    logic transfer; // class안 member로 있는 member 변수
    logic write;
    rand logic [31:0] addr;
    rand logic [31:0] wdata;

    constraint c_addr { addr inside {
    [32'h1000_0000:32'h1000_000c], [32'h1000_1000:32'h1000_100c],
    [32'h1000_2000:32'h1000_200c], [32'h1000_3000:32'h1000_300c]}; (addr % 4 == 0);}

    virtual apb_master_if m_if;

    apbCoverage coverage;

    function new(virtual apb_master_if m_if);
        this.m_if = m_if;
        coverage = new;
    endfunction


    task automatic send();
        m_if.transfer <= 1'b1; 
        m_if.write <=  1'b1; 
        m_if.addr <= addr;
        m_if.wdata <= wdata;
        coverage.record_addr(addr);
        @(posedge m_if.clk);
        m_if.transfer <= 1'b0;
        @(posedge m_if.clk);
        wait(m_if.ready);
        @(posedge m_if.clk);        
    endtask //automatic

    task automatic receive();
        m_if.transfer <= 1'b1; 
        m_if.write <=  1'b0; 
        m_if.addr <= addr;
        coverage.record_addr(addr);
        @(posedge m_if.clk);
        m_if.transfer <= 1'b0;
        @(posedge m_if.clk);
        wait(m_if.ready);
        @(posedge m_if.clk);        
    endtask //automatic

endclass

module tb_APB();
    logic        PCLK;
    logic        PRESET;
    logic [31:0] PADDR;
    logic        PWRITE;
    // logic        PSEL;
    logic        PENABLE;
    logic [31:0] PWDATA;
    // logic [31:0] PRDATA;
    // logic [31:0] PREADY;
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
    // logic        transfer;
    // logic        write;
    // logic [31:0] addr;
    // logic [31:0] wdata;
    // logic [31:0] rdata;
    // logic        ready;

    apb_master_if m_if(PCLK, PRESET);

    apbSignal apbUART; // handler
    apbSignal apbUART_clone; // handler
    apbSignal apbGPIO;
    apbSignal apbTimer;

    APB_Manager dut_manager(.*,
        .transfer(m_if.transfer),
        .write(m_if.write),
        .addr(m_if.addr),
        .wdata(m_if.wdata),
        .rdata(m_if.rdata),
        .ready(m_if.ready)
    );
    APB_Slave dut_slave0(.*, 
    .PSEL(PSEL0),
    .PRDATA(PRDATA0),
    .PREADY(PREADY0)
    );
    APB_Slave dut_slave1(.*, 
    .PSEL(PSEL1),
    .PRDATA(PRDATA1),
    .PREADY(PREADY1)
    );
    APB_Slave dut_slave2(.*, 
    .PSEL(PSEL2),
    .PRDATA(PRDATA2),
    .PREADY(PREADY2)
    );    
    APB_Slave dut_slave3(.*, 
    .PSEL(PSEL3),
    .PRDATA(PRDATA3),
    .PREADY(PREADY3)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        #00 PCLK = 0; PRESET = 1;
        #10 PRESET = 0;
    end

    initial begin
        apbUART = new(m_if);
        apbUART_clone = apbUART; // 같은 주소 공유
        apbGPIO = new(m_if);
        apbTimer = new(m_if);

        repeat(3) @(posedge PCLK);

        repeat(60) begin
            apbUART.randomize();
            apbUART.send();
            @(posedge PCLK);
            apbUART_clone.receive();
            
            apbGPIO.randomize();
            apbGPIO.send();
            @(posedge PCLK);
            apbGPIO.receive();

            apbTimer.randomize();
            apbTimer.send();
            @(posedge PCLK);
            apbTimer.receive();

            @(posedge PCLK);
            //#20;
            //$finish;
            apbUART.coverage.display_coverage("apbUART");
            apbGPIO.coverage.display_coverage("apbGPIO");
            apbTimer.coverage.display_coverage("apbTimer");
        end
        $finish;

    end

/*
module tb_APB();
    logic        PCLK;
    logic        PRESET;
    logic [31:0] PADDR;
    logic        PWRITE;
    logic        PENABLE;
    logic [31:0] PWDATA;
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
    logic        transfer;
    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        ready;

    APB_Manager dut_manager(.*);
    APB_Slave dut_slave0(.*, 
    .PSEL(PSEL0),
    .PRDATA(PRDATA0),
    .PREADY(PREADY0)
    );
    APB_Slave dut_slave1(.*, 
    .PSEL(PSEL1),
    .PRDATA(PRDATA1),
    .PREADY(PREADY1)
    );
    APB_Slave dut_slave2(.*, 
    .PSEL(PSEL2),
    .PRDATA(PRDATA2),
    .PREADY(PREADY2)
    );    
    APB_Slave dut_slave3(.*, 
    .PSEL(PSEL3),
    .PRDATA(PRDATA3),
    .PREADY(PREADY3)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        #00 PCLK = 0; PRESET = 1;
        #10 PRESET = 0;
    end

    task automatic apbMasterWrite(logic [31:0] address, logic [31:0] data);
        transfer = 1'b1; write =  1'b1; addr = address; wdata = data;
        @(posedge PCLK);
        transfer = 1'b0;
        @(posedge PCLK);
        wait(ready);
        @(posedge PCLK);
    endtask

    task automatic apbMasterRead(logic [31:0] address);
        transfer = 1'b1; write =  1'b0; addr = address;
        @(posedge PCLK);
        transfer = 1'b0;
        @(posedge PCLK);
        wait(ready);
        @(posedge PCLK);
    endtask

    initial begin
        repeat(3) @(posedge PCLK);
        apbMasterWrite(32'h1000_0000, 32'h11111111);
        apbMasterWrite(32'h1000_0004, 32'h22222222);
        apbMasterWrite(32'h1000_0008, 32'h33333333);
        apbMasterWrite(32'h1000_000C, 32'h44444444);

        apbMasterRead(32'h1000_0000);
        apbMasterRead(32'h1000_0004);
        apbMasterRead(32'h1000_0008);
        apbMasterRead(32'h1000_000C);

        @(posedge PCLK);
        #20;
        $finish;
    end
*/

/*
    // global signals
    logic PCLK;
    logic PRESET;
    logic [3:0] PADDR;
    logic PWRITE;
    logic PENABLE;
    logic [31:0] PWDATA;
    logic PSEL;
    logic [31:0] PRDATA;
    logic PREADY;

    APB_Slave dut(.*);
    always #5 PCLK = ~PCLK;
    initial begin
        #00 PCLK = 0; PRESET = 1;
        #10 PRESET = 0;
    end

    task automatic apbWrite(logic [3:0] addr, logic [31:0] wdata);
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =  1'b1; PADDR = addr; PWDATA = wdata;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =  1'b1; PADDR = addr; PWDATA = wdata;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK);
    endtask

    task automatic apbRead(logic [3:0] addr);
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =  1'b0; PADDR = addr;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =  1'b0; PADDR = addr;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK);
    endtask

    initial begin
        repeat(3) @(posedge PCLK);
        apbWrite(4'h00, 32'h11111111);
        apbWrite(4'h04, 32'h22222222);
        apbWrite(4'h08, 32'h33333333);
        apbWrite(4'h0C, 32'h44444444);
        apbRead(4'h00);
        apbRead(4'h04);
        apbRead(4'h08);
        apbRead(4'h0C);
        @(posedge PCLK);
        #20;
        $finish;
    end
*/ 

/*
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =  1'b1; PADDR = 4'h00; PWDATA = 32'h1111;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =  1'b1; PADDR = 4'h00; PWDATA = 32'h1111;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =  1'b1; PADDR = 4'h04; PWDATA = 32'h2222;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =  1'b1; PADDR = 4'h04; PWDATA = 32'h2222;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =  1'b1; PADDR = 4'h08; PWDATA = 32'h3333;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =  1'b1; PADDR = 4'h08; PWDATA = 32'h3333;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b0; PWRITE =  1'b1; PADDR = 4'h0c; PWDATA = 32'h4444;
        @(posedge PCLK);
        PSEL = 1'b1; PENABLE = 1'b1; PWRITE =  1'b1; PADDR = 4'h0c; PWDATA = 32'h4444;
        wait(PREADY);
        @(posedge PCLK);
        PSEL = 1'b0; PENABLE = 1'b0;
        @(posedge PCLK);
        #20;
        $finish;
    end
*/
endmodule
