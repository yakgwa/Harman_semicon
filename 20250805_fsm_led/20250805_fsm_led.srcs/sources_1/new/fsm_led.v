`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/05 15:45:17
// Design Name: 
// Module Name: fsm_led
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


module fsm_led(
    input clk,
    input reset,
    input sw,
    output [1:0] led
    );

    parameter A = 0, B = 1; // Make A & B 1bit state

    // To manage state
    // current_state : current manage
    // next_state : next manage
    reg current_state, next_state; // for store state(State를 관리할 변수)

    // state logic mange SL (sequential logic), State update

    always@(posedge clk or posedge reset) begin
        if(reset) begin
            current_state <= A; // state -> A
        end else begin
            current_state <= next_state; // 매 clock postive edge시 next_state값을 current_state값으로 바꿈(upadate)
        end
    end

    // next state를 위해 combinational logic으로 만들기(행동 모델링)
    always@(*) begin
        if(current_state == A) begin // A state
            if(sw == 1'b1) begin
                next_state = B;
            end else next_state = current_state; // current_state가 자기 자신(next_state)
        end else begin // B state
            if(sw == 1'b0) begin
                next_state = A;
            end else next_state = current_state;
        end
    end

    // output combinational logic
    assign led = (current_state == A) ? 2'b10 :  2'b01;


endmodule
