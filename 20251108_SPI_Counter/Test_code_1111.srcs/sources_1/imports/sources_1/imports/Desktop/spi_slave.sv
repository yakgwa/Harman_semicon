`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/10 13:30:25
// Design Name: 
// Module Name: spi_slave
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


module spi_slave(
    // global signal
    input logic clk,
    input logic reset,
    // SPi External port
    input logic sclk,
    input logic mosi,
    output logic miso,
    input logic cs,
    // Internal signals
    output logic [7:0] si_data, // rx_data
    output logic si_done, // rx_done
    input logic [7:0] so_data, // tx_data
    input logic so_start, // tx_start
    output logic so_ready // tx_ready,
    //output logic so_done // tx_done
    );

    // synchronizer edge detector //

    logic sclk_sync0, sclk_sync1;
    logic sclk_rising;

    always_ff @( posedge clk or posedge reset ) begin
        if(reset) begin
            sclk_sync0 <= 0;
            sclk_sync1 <= 0;
        end else begin
            sclk_sync0 <= sclk; // 1st F/F q<=d mean
            sclk_sync1 <= sclk_sync0;
        end 
    end

    assign sclk_rising = sclk_sync0 & ~sclk_sync1;
    assign sclk_falling = ~sclk_sync0 & sclk_sync1;

    ////////////////////////////////
    // slave in is sampling in posedge clk
    // IDLE is active When cs is low
    // Slave in  Sequence///////////

    logic [7:0] si_data_reg, si_data_next;
    logic [2:0] si_bit_cnt_reg, si_bit_cnt_next;
    logic si_done_reg, si_done_next;

    assign si_data = si_data_reg;
    assign si_done = si_done_reg;

    typedef enum {SI_IDLE, SI_PHASE} si_state_e;

    si_state_e si_state, si_state_next;

    always_ff@(posedge clk or posedge reset) begin
        if(reset) begin
            si_state <= SI_IDLE;
            si_bit_cnt_reg <= 0;
            si_data_reg <= 0;
            si_done_reg <= 0;
        end else begin
            si_state <= si_state_next;
            si_bit_cnt_reg <= si_bit_cnt_next;
            si_data_reg <= si_data_next;
            si_done_reg <= si_done_next;
        end
    end

    always_comb begin 
        si_state_next = si_state;
        si_done_next = 1'b0;
        si_bit_cnt_next = si_bit_cnt_reg;
        si_data_next = si_data_reg;
        case(si_state)
            SI_IDLE : begin
                si_done_next = 1'b0;
                if(!cs) begin
                    si_state_next = SI_PHASE;
                end
            end
            SI_PHASE : begin
                if(!cs) begin
                    if(sclk_rising) begin
                        si_data_next = {si_data_reg[6:0], mosi}; // 이 데이터를 받음
                        if(si_bit_cnt_reg == 7) begin
                            si_bit_cnt_next = 0;
                            si_state_next = SI_IDLE;
                            si_done_next = 1'b1; // reg가기 한 클락 전 done 발생. done 신호 발생시 data read;;
                        end else begin
                            si_bit_cnt_next = si_bit_cnt_reg + 1;
                        end
                    end
                end else begin
                    si_state_next = SI_IDLE;
                end
            end
        endcase
        
    end

    // Slave out  Sequence///////////
    logic [7:0] so_data_reg, so_data_next;
    logic [2:0] so_bit_cnt_reg, so_bit_cnt_next;

    assign miso = cs ? 1'hz : so_data_reg[7];

    typedef enum {SO_IDLE, SO_PHASE} so_state_e;

    so_state_e so_state, so_state_next;

    always_ff@(posedge clk or posedge reset) begin
        if(reset) begin
            so_state <= SO_IDLE;
            so_bit_cnt_reg <= 0;
            so_data_reg <= 0;
        end else begin
            so_state <= so_state_next;
            so_bit_cnt_reg <= so_bit_cnt_next;
            so_data_reg <= so_data_next;
        end
    end

    always_comb begin 
        so_state_next = so_state;
        //so_done = 1'b0;
        so_bit_cnt_next = so_bit_cnt_reg;
        so_data_next = so_data_reg;
        so_ready = 1'b0;
        case(so_state)
            SO_IDLE : begin
                //so_done = 1'b0;
                if(!cs) begin
                    so_ready = 1'b1;
                    if(so_start) begin
                        so_state_next = SO_PHASE; // start 신호가 들어오면 나감
                        so_data_next = so_data; // Latching
                        so_bit_cnt_next = 0;
                    end
                end
            end
            SO_PHASE : begin
                if(!cs) begin
                    if(sclk_falling) begin
                        so_data_next = {so_data_reg[6:0], 1'b0}; 
                        if(so_bit_cnt_reg == 7) begin
                            so_bit_cnt_next = 0;
                            so_state_next = SO_IDLE;
                            //so_done = 1'b1; // ready를 보고 가면 reg, next구조는 필요없음
                        end else begin
                            so_bit_cnt_next = so_bit_cnt_reg + 1;
                        end
                    end
                end else begin
                    so_state_next = SO_IDLE;
                end
            end
        endcase
        
    end


endmodule
