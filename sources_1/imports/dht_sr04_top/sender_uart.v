`timescale 1ns / 1ps
module sender_uart (
    input         clk,
    input         rst,
    input         tx_full,
    input  [31:0] i_send_data,
    input         cal_don,
    output [ 7:0] o_tx_data,
    output        send_done
);

    parameter IDLE = 1'b0, SEND = 1'b1;
    reg cur, next;
    reg [7:0] send_data_reg, send_data_next;
    reg send_reg, send_next;
    reg [2:0] send_cnt_reg, send_cnt_next;
    assign o_tx_data = send_data_reg;
    assign send_done   = send_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cur <= 0;
            send_data_reg <= 0;
            send_reg <= 0;
            send_cnt_reg <= 0;
        end else begin
            cur <= next;
            send_data_reg <= send_data_next;
            send_reg <= send_next;
            send_cnt_reg <= send_cnt_next;
        end
    end

    always @(*) begin
        next = cur;
        send_data_next = send_data_reg;
        send_next = send_reg;
        send_cnt_next = send_cnt_reg;
        case (cur)
            IDLE: begin
                send_cnt_next = 0;
                if (cal_don) begin
                    next = SEND;
                end
            end
            SEND: begin
                if (~tx_full) begin
                    send_next = 1;
                    if (send_cnt_reg < 6) begin
                        case (send_cnt_reg)
                            3'b000: send_data_next = i_send_data[31:24];
                            3'b001: send_data_next = i_send_data[23:16];
                            3'b010: send_data_next = i_send_data[15:8];
                            3'b011: send_data_next = 8'h2e;
                            3'b100: send_data_next = i_send_data[7:0];
                            3'b101: send_data_next = 8'h0a;
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        next = IDLE;
                        send_next = 0;
                    end
                end else next = cur;
            end
        endcase
    end
endmodule


module dat_to_asc (
    input  [11:0] i_dist_data,
    output [31:0] o_dist_data
);
    // 1 disit is 0~8
    assign o_dist_data[7:0]   = i_dist_data % 10 + 8'h30;
    assign o_dist_data[15:8]  = (i_dist_data / 10) % 10 + 8'h30;
    assign o_dist_data[23:16] = (i_dist_data / 100) % 10 + 8'h30;
    assign o_dist_data[31:24] = (i_dist_data / 1000) % 10 + 8'h30;
endmodule


