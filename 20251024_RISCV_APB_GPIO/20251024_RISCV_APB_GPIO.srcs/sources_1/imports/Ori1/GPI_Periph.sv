`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/24 09:39:05
// Design Name: 
// Module Name: GPI_Periph
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


module GPI_Periph(
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 2:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // External Port
    input logic [ 7:0] gpi
);

    logic [7:0] cr;
    logic [7:0] idr;

    APB_SlaveIntf_GPI U_APB_SlaveInterf_GPI (.*);
    GPI U_GPI (.*);

endmodule

module APB_SlaveIntf_GPI (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 2:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // Internal Port
    output logic [ 7:0] cr,
    input  logic [ 7:0] idr
);
    logic [31:0] slv_reg0, slv_reg1;//, slv_reg2, slv_reg3;

    assign cr  = slv_reg0;
    //assign slv_reg1 = {24'b0, idr};

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            //slv_reg2 <= 0;
            //slv_reg3 <= 0;
        end else begin
            PREADY <= 1'b0;
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;//slv_reg1 <= PWDATA; // 1일때는 Not store
                        //2'd2: slv_reg2 <= PWDATA;
                        //2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    case (PADDR[2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= {24'b0, idr};
                        //2'd2: PRDATA <= slv_reg2;
                        //2'd3: PRDATA <= slv_reg3;
                    endcase

                end
            end
        end
    end
endmodule

module GPI (
    input  logic [7:0] cr,
    output logic [7:0] idr,
    input  logic [7:0] gpi
);
    // 1번 방식
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            assign idr[i] = cr[i] ? gpi[i] : 1'bz;
        end
    endgenerate

    //2번 방식
    // always_comb begin 
    //     for (int i=0; i<8; i++) begin
    //         idr[i] = ~cr[i] ? gpi[i] : 1'bz;
    //     end
    // end

    // 3번 방식
    // assign idr = cr[0] ? gpi[0] : 1'bz;
    // assign idr = cr[1] ? gpi[1] : 1'bz;
    // assign idr = cr[2] ? gpi[2] : 1'bz;
    // assign idr = cr[3] ? gpi[3] : 1'bz;
    // assign idr = cr[4] ? gpi[4] : 1'bz;
    // assign idr = cr[5] ? gpi[5] : 1'bz;
    // assign idr = cr[6] ? gpi[6] : 1'bz;
    // assign idr = cr[7] ? gpi[7] : 1'bz;

endmodule
