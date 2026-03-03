`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/05 12:57:01
// Design Name: 
// Module Name: can_fsm_managed
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
module can_fsm_managed #(parameter NODE_ID = 0) (
    input        clk, rst, btn_send,
    input        gnt,               
    output reg   req,               
    output reg   ale_i, wr_i, rd_i, cs_can_i,
    inout  [7:0] port_0_io,
    output [3:0] led_state
);

    localparam IDLE=0, ADDR=1, ALE_HIGH=2, ALE_LOW=3, DATA=4, WR_HIGH=5, REL=6,
               RD_LOW=7, RD_WAIT=8, ARB_WAIT=9;
    
    reg [3:0] state;
    reg [7:0] out_data_reg, read_data_reg; 
    reg [3:0] step;      
    reg [15:0] wait_cnt;  
    reg       oe;

    assign led_state = state;
    assign port_0_io = oe ? out_data_reg : 8'bz; 

    // 주소 및 데이터 매핑 (기존과 동일)
    wire [7:0] target_addr = (step <= 4) ? ((step==0)?8'h00 : (step==1)?8'h06 : (step==2)?8'h07 : (step==3)?8'h1F : 8'h00) :
                             (step <= 9) ? (8'h10 + (step-5)) :
                             (step == 10) ? 8'h01 : (step == 11) ? 8'h02 : 
                             (step == 12) ? 8'h13 : (step == 13) ? 8'h14 : 8'h01;

    wire [7:0] target_data = (step <= 4) ? ((step==0)?8'h01 : (step==1)?8'h09 : (step==2)?8'h14 : (step==3)?8'h05 : 8'h00) :
                             (step == 5) ? 8'h55 : (step == 6) ? 8'hAA : (step == 7) ? 8'h02 :
                             (step == 8) ? 8'hDE : (step == 9) ? 8'hAD : 8'h01;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; req <= 0; step <= 0; wait_cnt <= 0;
            {ale_i, wr_i, rd_i, cs_can_i, oe} <= 5'b00000;
        end else begin
            case (state)
IDLE: begin
    {ale_i, wr_i, rd_i, cs_can_i, oe} <= 5'b00000;
    
    // 수정: 이미 권한을 쥐고 있다면 wait_cnt 무시하고 즉시 다음 단계 시작
    if (req && gnt) begin
        wait_cnt <= 0;
        state <= ADDR;
    end 
    // 권한이 없을 때만 대기 후 중재 요청
    else if (wait_cnt < 16'd100) begin
        wait_cnt <= wait_cnt + 1;
    end else begin
        wait_cnt <= 0;
        if (step <= 14) begin
            if (step == 10) begin
                if (btn_send) state <= ARB_WAIT;
            end else begin
                state <= ARB_WAIT;
            end
        end
    end
end

                ARB_WAIT: begin
                    req <= 1;
                    if (gnt) begin 
                        $display("[%0t] [NODE %0d] >>> GNT SEIZED (Step %0d)", $time, NODE_ID, step);
                        wait_cnt <= 0; state <= ADDR; 
                    end
                end

                ADDR: begin
                    oe <= 1; cs_can_i <= 1; out_data_reg <= target_addr;
                    if (wait_cnt >= 16'd50) begin wait_cnt <= 0; state <= ALE_HIGH; end 
                    else wait_cnt <= wait_cnt + 1;
                end

                ALE_HIGH: begin ale_i <= 1; if (wait_cnt >= 16'd50) begin wait_cnt <= 0; state <= ALE_LOW; end else wait_cnt <= wait_cnt + 1; end
                ALE_LOW:  begin ale_i <= 0; if (step >= 11) oe <= 0; if (wait_cnt >= 16'd50) begin wait_cnt <= 0; state <= (step >= 11) ? RD_LOW : DATA; end else wait_cnt <= wait_cnt + 1; end

                DATA: begin 
                    oe <= 1; out_data_reg <= target_data; wr_i <= 1;
                    if (wait_cnt == 0) $display("[%0t] [NODE %0d] WRITE: Addr 0x%h <= Data 0x%h", $time, NODE_ID, target_addr, target_data);
                    if (wait_cnt >= 16'd50) begin wait_cnt <= 0; state <= WR_HIGH; end else wait_cnt <= wait_cnt + 1;
                end

                WR_HIGH: begin wr_i <= 0; if (wait_cnt >= 16'd100) begin wait_cnt <= 0; state <= REL; end else wait_cnt <= wait_cnt + 1; end

                RD_LOW: begin 
                    oe <= 0; cs_can_i <= 1; rd_i <= 1;
                    if (wait_cnt >= 16'd100) begin wait_cnt <= 0; state <= RD_WAIT; end else wait_cnt <= wait_cnt + 1;
                end

                RD_WAIT: begin 
                    if (wait_cnt == 16'd80) begin
                        read_data_reg <= port_0_io; 
                        $display("[%0t] [NODE %0d] READ: Addr 0x%h => Data 0x%h", $time, NODE_ID, target_addr, port_0_io);
                    end
                    if (wait_cnt >= 16'd100) begin wait_cnt <= 0; state <= REL; end else wait_cnt <= wait_cnt + 1;
                end

                REL: begin
                    {ale_i, wr_i, rd_i, cs_can_i, oe} <= 5'b00000;
                    if (wait_cnt >= 16'd150) begin  
                        wait_cnt <= 0;
                        case (step)
                            10: begin $display("[%0t] [NODE %0d] TX CMD SENT. Waiting for Completion...", $time, NODE_ID); step <= 11; state <= IDLE; end
                            11: begin
    // read_data_reg[2]가 확실히 '1'일 때만 성공으로 간주
    if (read_data_reg[2] === 1'b1) begin 
        $display("[%0t] [NODE %0d] TX SUCCESS! Status: 0x%h", $time, NODE_ID, read_data_reg);
        step <= 12; 
        state <= IDLE;
    end else begin
        // 아직 0이거나 zz라면 다시 IDLE로 가서 읽기 시도 (req는 계속 1 유지)
        state <= IDLE; 
    end
end
                            14: begin 
                                $display("[%0t] [NODE %0d] === ALL VERIFIED. Releasing Bus... ===", $time, NODE_ID); 
                                req <= 0; step <= 15; state <= IDLE; 
                            end
                            default: begin step <= step + 1; state <= IDLE; end
                        endcase
                    end else wait_cnt <= wait_cnt + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule