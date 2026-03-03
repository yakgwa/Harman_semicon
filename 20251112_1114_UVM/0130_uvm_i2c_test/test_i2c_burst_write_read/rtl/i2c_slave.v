`timescale 1ns/1ps

module I2C_Slave(
    input clk,
    input reset,
    input SCL,
    inout SDA,
    output [7:0] slv_reg0,
    output [7:0] slv_reg1,
    output [7:0] slv_reg2,
    output [7:0] slv_reg3
);
    parameter IDLE=0, ADDR=1, ACK=2, READ=3, DATA=4, READ_ACK=5, READ_CNT=6, DATA_ACK=7, STOP=9;

    reg [3:0] state, state_next;
    reg [7:0] temp_rx_data_reg, temp_rx_data_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [7:0] temp_addr_reg, temp_addr_next;
    reg [3:0] bit_counter_reg, bit_counter_next;
    reg [1:0] slv_count_reg, slv_count_next;
    reg en, o_data;
    reg read_ack_reg, read_ack_next;

    reg sclk_sync0, sclk_sync1;
    wire sclk_rising, sclk_falling;
    reg sda_sync0, sda_sync1;
    wire sda_rising;

    reg [7:0] slv_reg0_reg, slv_reg0_next;
    reg [7:0] slv_reg1_reg, slv_reg1_next;
    reg [7:0] slv_reg2_reg, slv_reg2_next;
    reg [7:0] slv_reg3_reg, slv_reg3_next;

    assign SDA = en ? o_data : 1'bz;
    assign slv_reg0 = slv_reg0_reg;
    assign slv_reg1 = slv_reg1_reg;
    assign slv_reg2 = slv_reg2_reg;
    assign slv_reg3 = slv_reg3_reg;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            state <= IDLE;
            sclk_sync0 <= 1; sclk_sync1 <= 1;
            sda_sync0 <= 1; sda_sync1 <= 1;
            {temp_rx_data_reg, temp_tx_data_reg, temp_addr_reg} <= 0;
            bit_counter_reg <= 0; slv_count_reg <= 0;
            {slv_reg0_reg, slv_reg1_reg, slv_reg2_reg, slv_reg3_reg} <= 0;
            read_ack_reg <= 0;
        end else begin
            state <= state_next;
            sclk_sync0 <= SCL; sclk_sync1 <= sclk_sync0;
            sda_sync0 <= SDA; sda_sync1 <= sda_sync0;
            temp_rx_data_reg <= temp_rx_data_next;
            temp_tx_data_reg <= temp_tx_data_next;
            bit_counter_reg <= bit_counter_next;
            temp_addr_reg <= temp_addr_next;
            slv_reg0_reg <= slv_reg0_next; slv_reg1_reg <= slv_reg1_next;
            slv_reg2_reg <= slv_reg2_next; slv_reg3_reg <= slv_reg3_next;
            slv_count_reg <= slv_count_next;
            read_ack_reg <= read_ack_next;
        end
    end

    assign sclk_rising = sclk_sync0 & ~sclk_sync1;
    assign sclk_falling = ~sclk_sync0 & sclk_sync1;
    assign sda_rising = sda_sync0 & ~sda_sync1;

    always @(*) begin
        state_next = state;
        en = 1'b0; o_data = 1'b0;
        temp_rx_data_next = temp_rx_data_reg; temp_tx_data_next = temp_tx_data_reg;
        bit_counter_next = bit_counter_reg; temp_addr_next = temp_addr_reg;
        slv_count_next = slv_count_reg;
        slv_reg0_next = slv_reg0_reg; slv_reg1_next = slv_reg1_reg;
        slv_reg2_next = slv_reg2_reg; slv_reg3_next = slv_reg3_reg;
        read_ack_next = read_ack_reg;

        case (state)
            IDLE: begin
                if(sclk_falling && ~SDA) begin
                    state_next = ADDR;
                    bit_counter_next = 0; slv_count_next = 0;
                end
            end

            ADDR: begin
                if(sclk_rising) temp_addr_next = {temp_addr_reg[6:0], SDA};
                if(sclk_falling) begin
                    if (bit_counter_reg == 7) begin
                        bit_counter_next = 0; state_next = ACK;
                    end else bit_counter_next = bit_counter_reg + 1;
                end
            end

ACK: begin
    // 주소 전체가 0xAA(쓰기) 또는 0xAB(읽기)인지 확인
    if (temp_addr_reg == 8'hAA || temp_addr_reg == 8'hAB) begin
        en = 1'b1; o_data = 1'b0; // 일단 ACK 보냄
        
        if(sclk_falling) begin
            bit_counter_next = 0;
            slv_count_next = 0; // 레지스터 포인터 초기화
            
            if(temp_addr_reg == 8'hAB) begin 
                state_next = READ; // ★ 여기가 핵심! 0xAB면 읽기 상태로 전이
                temp_tx_data_next = slv_reg0_reg; // 첫 데이터(Reg0) 미리 준비
            end else begin
                state_next = DATA; // 0xAA면 계속 쓰기 상태로
            end
        end
    end else if(sclk_falling) state_next = IDLE;
end

            // --- [READ 로직 핵심 수정] ---
            READ: begin
                en = 1'b1;
                o_data = temp_tx_data_reg[7];
                if(sclk_falling) begin
                    if (bit_counter_reg == 7) begin
                        bit_counter_next = 0;
                        state_next = READ_ACK;
                    end else begin
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end

            READ_ACK: begin
                en = 1'b0; // Master의 ACK를 들어야 함
                if(sclk_rising) read_ack_next = SDA;
                if(sclk_falling) begin
                    if(read_ack_reg == 1'b0) begin // Master가 ACK(Low)를 줌
                        state_next = READ_CNT;
                        slv_count_next = slv_count_reg + 1;
                    end else state_next = STOP; // NACK이면 종료
                end
            end

            READ_CNT: begin
                state_next = READ;
                case(slv_count_next) // 다음 데이터를 미리 로드
                    2'd0: temp_tx_data_next = slv_reg0_reg;
                    2'd1: temp_tx_data_next = slv_reg1_reg;
                    2'd2: temp_tx_data_next = slv_reg2_reg;
                    2'd3: temp_tx_data_next = slv_reg3_reg;
                    default: temp_tx_data_next = 8'hFF;
                endcase
            end

            // --- [WRITE 로직] ---
            DATA: begin
                if(sclk_rising) temp_rx_data_next = {temp_rx_data_reg[6:0], SDA};
                if(SCL && sda_rising) state_next = STOP;
                else if (sclk_falling) begin
                    if (bit_counter_reg == 7) begin
                        state_next = DATA_ACK; bit_counter_next = 0;
                        case(slv_count_reg)
                            2'd0: slv_reg0_next = temp_rx_data_next;
                            2'd1: slv_reg1_next = temp_rx_data_next;
                            2'd2: slv_reg2_next = temp_rx_data_next;
                            2'd3: slv_reg3_next = temp_rx_data_next;
                        endcase
                        slv_count_next = slv_count_reg + 1;
                    end else bit_counter_next = bit_counter_reg + 1;
                end
            end

            DATA_ACK: begin
                en = 1'b1; o_data = 1'b0;
                if(sclk_falling) state_next = DATA;
            end

            STOP: if(SDA && SCL) state_next = IDLE;
            default: state_next = IDLE;
        endcase
    end
endmodule