`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/05 12:57:28
// Design Name: 
// Module Name: can_system_top
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
module can_system_top (
    input        clk, rst,
    input  [3:0] btn_send_bus,
    output       can_tx_phys,   
    input        can_rx_phys,   
    output [7:0] led            
);
    wire [3:0] req_bus, gnt_bus, tx_bus;

    round_robin_arbiter u_arbiter (
        .clk(clk), .rst_n(!rst), .REQ(req_bus), .GNT(gnt_bus)
    );

    // 버스 충돌 감지 로직 (디버깅용)
    always @(posedge clk) begin
        if (gnt_bus == 4'b0000 && req_bus != 4'b0000)
            $display("[%0t] [TOP_ERR] REQ exists (%b) but NO GNT!", $time, req_bus);
    end

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : can_node
            wire ale, wr, rd, cs;
            wire [7:0] bus_io;
            can_fsm_managed #(.NODE_ID(i)) fsm_inst (
                .clk(clk), .rst(rst), .btn_send(btn_send_bus[i]), .gnt(gnt_bus[i]), .req(req_bus[i]),
                .ale_i(ale), .wr_i(wr), .rd_i(rd), .cs_can_i(cs), .port_0_io(bus_io)
            );
            can_top core_inst (
                .clk_i(clk), .rst_i(rst), .ale_i(ale), .rd_i(rd), .wr_i(wr), .port_0_io(bus_io), .cs_can_i(cs),
                .rx_i(can_rx_phys), .tx_o(tx_bus[i])
            );
        end
    endgenerate

    assign can_tx_phys = &tx_bus; 
    assign led = {req_bus, gnt_bus}; 
endmodule