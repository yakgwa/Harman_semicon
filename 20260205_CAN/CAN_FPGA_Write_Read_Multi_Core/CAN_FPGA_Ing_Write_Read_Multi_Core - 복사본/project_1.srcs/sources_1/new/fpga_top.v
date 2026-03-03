//`include "timescale.v"
`timescale 1ns/1ps

module fpga_top (
    input        clk, btnC, sw_send, // btnR 대신 스위치 sw_send 사용
    output [7:0] led
);
    // 클럭 분주 (약 6Hz로 설정하여 상태 변화 관찰)
    reg [24:0] clk_div;
    wire clk_slow = clk_div[24]; 
    always @(posedge clk or posedge btnC) begin
        if (btnC) clk_div <= 0;
        else      clk_div <= clk_div + 1;
    end

    wire ale, wr, rd, cs, can_tx, irq_n, bus_off;
    wire [7:0] bus_io;
    wire [3:0] fsm_state;

    // 내부 루프백 (Self-Test 환경)
    wire virtual_bus = (can_tx === 1'b0) ? 1'b0 : 1'b1; 

    can_controller_fsm i_fsm (
        .clk(clk), 
        .rst(btnC), 
        .btn_send(sw_send), // 스위치 직접 연결
        .ale_i(ale), .wr_i(wr), .rd_i(rd), .cs_can_i(cs), 
        .port_0_io(bus_io),
        .led_state(fsm_state)
    );

    can_top i_can_node (
        .clk_i(clk), .rst_i(btnC), .rx_i(1'b1), .tx_o(can_tx),
        .cs_can_i(~cs), .ale_i(ale), .rd_i(rd), .wr_i(wr), .port_0_io(bus_io),
        .irq_on(irq_n), .bus_off_on(bus_off), .clkout_o()
    );

    // LED 매핑
    assign led[3:0] = fsm_state;  
    assign led[4]   = clk_slow;   
    assign led[5]   = sw_send;    // 스위치 ON/OFF 확인
    assign led[6]   = ~irq_n;     
    assign led[7]   = bus_off;    
endmodule