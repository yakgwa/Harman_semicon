`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/22 10:21:28
// Design Name: 
// Module Name: uart_sr04_top
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


module uart_sr04_top(
    input clk,
    input rst,
    input start,
    input echo,
    output trig,
    //output data,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    input rx,
    output tx
    );

    wire w_tick_1us;
    wire [8:0] w_dist;
    wire w_rx_trigger;
    wire [7:0] w_rx_fifo_data;
    wire w_send;
    wire w_start;

    tick_gen_1us U_TICK_GEN_1US(
        .clk(clk),
        .rst(rst),
        .o_tick_1us(w_tick_1us)
    );

    button_debounce U_BD_1(
        .clk(clk), 
        .rst(rst),
        .i_btn(start),
        .o_btn(w_start)
    );

    sr04_controller U_SR04_CONTROLLER(
        .clk(clk),
        .rst(rst),
        .start(w_send || w_start),
        .echo(echo),
        .i_tick(w_tick_1us),
        .o_trig(trig),
        .o_dist(w_dist)
    );

    command_controller U_COMMAND_CONTROLLER(
        .clk(clk),
        .reset(rst),
        .rx_fifo_data(w_rx_fifo_data),
        .rx_trigger(w_rx_trigger),
        .o_send(w_send)
    );

    uart_top U_UART(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .rx_trigger(w_rx_trigger),
        .rx_fifo_data(w_rx_fifo_data)
    );


    datatoascii U_DATATOASCII(
        .i_data({5'b0,w_dist}),
        .o_data()
    );

    fnd_controller U_FND_CTRL(
        .clk(clk),
        .reset(rst),
        .counter({5'b0,w_dist}),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com) 
    );  

endmodule

module command_controller(
    input clk,
    input reset,
    input [7:0] rx_fifo_data,
    input rx_trigger,
    output o_send
    );

    
    parameter IDLE = 2'b00, SEND = 2'b01;
    reg [1:0] c_state, n_state;
    reg send_reg, send_next;

    assign o_send = send_reg;

    // state register
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            c_state <= IDLE;
            send_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            send_reg <= send_next;
        end
    end
    // next combinational logic
    always@(*) begin
        n_state = c_state;
        send_next = 1'b0;//send_reg;
        case(c_state)
            IDLE : begin          
                if(rx_trigger && rx_fifo_data == 8'h64) begin // d
                    n_state = SEND;
                end
            end
            SEND : begin
                send_next = 1'b1;
                n_state = IDLE;
            end
        endcase
    end                
endmodule


module datatoascii(
    input [13:0] i_data, // 0000 ~ 9999
    output [31:0] o_data
    );

    assign o_data[7:0] = i_data % 10 + 8'h30;
    assign o_data[15:8] = (i_data/10) % 10 + 8'h30;
    assign o_data[23:16] = (i_data/100) % 10 + 8'h30;
    assign o_data[31:24] = (i_data/1000) % 10 + 8'h30;
endmodule

// module command_controller(
//     input clk,
//     input reset,
//     input [7:0] rx_fifo_data,
//     input rx_trigger,
//     output o_send
//     );
