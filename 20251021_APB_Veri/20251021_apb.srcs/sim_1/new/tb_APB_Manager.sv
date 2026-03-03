`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/21 14:05:49
// Design Name: 
// Module Name: tb_APB_Manager
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


module tb_APB_Manager();
    logic PCLK;
    logic PRESET;
    logic [31:0] PADDR;
    logic PWRITE;
    logic PENABLE;
    logic [31:0] PWDATA;
    logic PSEL0;
    logic PSEL1;
    logic PSEL2;
    logic PSEL3;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic PREADY0;
    logic PREADY1;
    logic PREADY2;
    logic PREADY3;

    logic transfer;
    logic write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic ready;

    APB_Manager U_APB_MANGER(.*);

    APB_Slave U_APB_SLAVE_0(
        .*, 
        .PSEL(PSEL0),
        .PREADY(PREADY0),
        .PRDATA(PRDATA0)    
    );

    APB_Slave U_APB_SLAVE_1(
        .*, 
        .PSEL(PSEL1),
        .PREADY(PREADY1),
        .PRDATA(PRDATA1)    
    );

    APB_Slave U_APB_SLAVE_2(
        .*, 
        .PSEL(PSEL2),
        .PREADY(PREADY2),
        .PRDATA(PRDATA2)    
    );    

    APB_Slave U_APB_SLAVE_3(
        .*, 
        .PSEL(PSEL3),
        .PREADY(PREADY3),
        .PRDATA(PRDATA3)    
    );

    always #5 PCLK = ~PCLK;

    initial begin
         #00; PCLK = 0; PRESET = 1;
         #10; PRESET = 0;
        //  @(posedge PCLK);
        //  #1 addr = 32'h1000_0000; write = 1; wdata = 11; transfer = 1;
        //  @(posedge PCLK);
        //  #1 transfer = 0; wait(ready == 1'b1);
        //  @(posedge PCLK);
        //  @(posedge PCLK);
        //  #1 addr = 32'h1000_0004; write = 1; wdata = 12; transfer = 1;
        //  @(posedge PCLK);
        //  #1 transfer = 0; wait(ready == 1'b1);
        //  @(posedge PCLK);
        //  @(posedge PCLK);
        //  #1 addr = 32'h1000_0004; write = 0; transfer = 1;
        //  @(posedge PCLK);
        //  #1 transfer = 0; wait(ready == 1'b1);
        //  @(posedge PCLK);
        for (int i = 0; i < 100; i++) begin
            @(posedge PCLK);
            #1 addr = 32'h1000_0000 + i * 4; wdata = i; write = 1; transfer = 1;
            @(posedge PCLK);
            #1 transfer = 0; wait (ready == 1'b1);  
            @(posedge PCLK);
            #1 addr = 32'h1000_0000 + i * 4; write = 0; transfer = 1;
            @(posedge PCLK);
            @(posedge PCLK);
            #1 transfer = 0; wait (ready == 1'b1);  
            @(posedge PCLK);
        end
        #1000; $finish;
    end
endmodule
