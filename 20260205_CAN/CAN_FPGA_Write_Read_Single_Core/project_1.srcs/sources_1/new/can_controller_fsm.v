`timescale 1ns / 1ps

module can_controller_fsm (
    input        clk, rst, btn_send,
    output reg   ale_i, wr_i, rd_i, cs_can_i,
    output [3:0] led_state, 
    inout  [7:0] port_0_io
);

    // 상태 정의 (읽기 전용 상태 RD_LOW, RD_WAIT 포함)
    parameter IDLE=0, ADDR=1, ALE_HIGH=2, ALE_LOW=3, DATA=4, WR_HIGH=5, REL=6,
              RD_LOW=7, RD_WAIT=8;
    
    reg [3:0] state;
    reg [7:0] out_data_reg; 
    reg [7:0] read_data_reg; 
    reg [3:0] step;      
    reg [7:0] wait_cnt;  
    reg        oe;

    assign led_state = state;
    assign port_0_io = oe ? out_data_reg : 8'bz; 

    wire [7:0] target_addr;
    wire [7:0] target_data;

    // 주소-데이터 매칭 테이블 (SJA1000 기준)
    assign target_addr = (step <= 4'd4) ? ((step==4'd0)?8'h00 : (step==4'd1)?8'h06 : (step==4'd2)?8'h07 : (step==4'd3)?8'h1F : 8'h00) :
                         (step <= 4'd9) ? (8'h10 + (step-4'd5)) :
                         (step == 4'd10)? 8'h01 : 8'h02; // Step 11: Status Register

    assign target_data = (step <= 4'd4) ? ((step==4'd0)?8'h01 : (step==4'd1)?8'h09 : (step==4'd2)?8'h14 : (step==4'd3)?8'h05 : 8'h00) :
                         (step == 4'd5) ? 8'h55 : (step == 4'd6) ? 8'hAA : (step == 4'd7) ? 8'h02 :
                         (step == 4'd8) ? 8'hDE : (step == 4'd9) ? 8'hAD : 8'h01;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; 
            {ale_i, wr_i, rd_i} <= 3'b010; // rd_i는 Active High이므로 0으로 시작
            cs_can_i <= 1; oe <= 0; step <= 0;
            wait_cnt <= 0; out_data_reg <= 8'h00; read_data_reg <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    // rd_i를 0으로 유지하여 다음 RD_LOW에서 0->1 상승 에지를 준비함
                    {wr_i, rd_i, ale_i, oe} <= 4'b0000; cs_can_i <= 1;
                    if (wait_cnt < 8'd255) wait_cnt <= wait_cnt + 1;
                    else begin
                        if (step < 10) begin wait_cnt <= 0; state <= ADDR; end
                        else if (btn_send && step == 10) begin wait_cnt <= 0; state <= ADDR; end
                        else if (step == 11) begin wait_cnt <= 0; state <= ADDR; end
                    end
                end

                ADDR: begin
                    oe <= 1; cs_can_i <= 0; out_data_reg <= target_addr;
                    if (wait_cnt >= 8'd50) begin wait_cnt <= 0; state <= ALE_HIGH; end
                    else wait_cnt <= wait_cnt + 1;
                end

                ALE_HIGH: begin
                    ale_i <= 1;
                    if (wait_cnt >= 8'd50) begin wait_cnt <= 0; state <= ALE_LOW; end
                    else wait_cnt <= wait_cnt + 1;
                end

                ALE_LOW: begin
                    ale_i <= 0;
                    if (wait_cnt >= 8'd50) begin 
                        wait_cnt <= 0; 
                        state <= (step == 11) ? RD_LOW : DATA; 
                    end
                    else wait_cnt <= wait_cnt + 1;
                end

                DATA: begin // WRITE 전용 (Active High wr_i 적용을 위해 wr_i=1 제어)
                    oe <= 1; out_data_reg <= target_data;
                    wr_i <= 0; // 쓰기 전 준비
                    if (wait_cnt >= 8'd50) begin wait_cnt <= 0; state <= WR_HIGH; end
                    else wait_cnt <= wait_cnt + 1;
                end

                WR_HIGH: begin
                    wr_i <= 1; // 0 -> 1 상승 에지로 쓰기 수행
                    if (wait_cnt >= 8'd100) begin wait_cnt <= 0; state <= REL; end
                    else wait_cnt <= wait_cnt + 1;
                end

                RD_LOW: begin 
                    oe <= 0;        // FPGA 입 다물기 (Hi-Z)
                    cs_can_i <= 0;  // 소스상 (cs_can_i & rd_i) 조건을 위해 1 유지
                    rd_i <= 1;      // ★ 다음 상태에서 0->1 에지를 만들기 위해 여기서 0으로 대기
                    
                    if (wait_cnt >= 8'd50) begin 
                        wait_cnt <= 0; 
                        state <= RD_WAIT; 
                    end
                    else wait_cnt <= wait_cnt + 1;
                end

                RD_WAIT: begin 
                    rd_i <= 1;      // ★ 여기서 0 -> 1 상승! (이 순간 IP 내부 cs가 튀어오름)

                    // 에지가 발생한 후 IP가 데이터를 버스에 실을 시간을 충분히 줌
                    if (wait_cnt == 8'd80) begin
                        read_data_reg <= port_0_io; 
                    end
                    
                    if (wait_cnt >= 8'd100) begin 
                        wait_cnt <= 0; 
                        rd_i <= 0;   // 다음 읽기를 위해 다시 내림
                        state <= REL; 
                        $display("[%0t] [FSM] Step 11: Status Value = 8'h%h", $time, read_data_reg);
                    end
                    else wait_cnt <= wait_cnt + 1;
                end

                REL: begin
                    {wr_i, rd_i} <= 2'b00; // 두 신호를 모두 비활성화(0) 상태로 복구
                    cs_can_i <= 1; oe <= 0;
                    if (wait_cnt >= 8'd100) begin  
                        wait_cnt <= 0;
                        if (step == 11) $display("[%0t] [FSM] Step 11: Status Value = 8'h%h", $time, read_data_reg);
                        
                        if (step < 10) begin 
                            step <= step + 1; state <= IDLE; 
                        end else if (step == 10) begin
                            step <= 11; state <= IDLE; 
                        end else begin
                            // Status Register의 Bit 2 (Transmission Complete)가 1인지 확인
                            if (read_data_reg[2]) begin
                                $display("[%0t] [FSM] SUCCESS: Transmission Complete!", $time);
                                step <= 11; // 루프 종료
                            end else begin
                                state <= IDLE; // 미완료 시 다시 Polling
                            end
                        end
                    end
                    else wait_cnt <= wait_cnt + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule