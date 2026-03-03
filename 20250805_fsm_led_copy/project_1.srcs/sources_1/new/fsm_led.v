`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/06 09:51:58
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
    input [2:0]sw,
    output [1:0] led
    );
    parameter [1:0] A = 0, B = 1, C = 2; // Make A & B 1bit state
                                         // 비트수 안 맞추면 latch가 생길 수 있음
    // To manage state
    // current_state : current manage
    // next_state : next manage
    reg [1:0] current_state, next_state; // for store state(State를 관리할 변수)
                                         // 비트수 안 맞추면 latch가 생길 수 있음
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
        next_state = current_state;
        case (current_state)
            A : begin
                if (sw == 3'b001) begin
                    next_state = B;
                end else if(sw == 3'b110) begin
                    next_state = C;
                    // current_state = C; >> current_state로 출력을 내보내면 Multiple drive 에러가 나는데 위의 State Machine의 출력과 중첩되기 때문!
                                          // >> state_machine의 output과 assign의 output이 겹치지 않는지 체크 필요!
                end else begin
                    next_state = current_state; // keep going current state
                end
            end
            B : begin
                if (sw == 3'b011) begin
                    next_state = C;
                end
            end
            C : begin
                if (sw == 3'b111) begin
                    next_state = A;
                end
            end
        
            default : next_state = current_state;
        endcase
        end                        
    // always@(*) begin
    //     if(current_state == A) begin // A state
    //         if(sw == 3'b001) begin
    //             next_state = B;
    //         end else if(sw == 3'b110) begin
    //             next_state = C;
    //         end else next_state = current_state; 
    //     end else if(current_state == B) begin // B state
    //         if(sw == 3'b011) begin
    //             next_state = C;
    //         end else next_state = current_state; 
    //     end else if(current_state == C) begin
    //         if(sw == 3'b111) begin
    //             next_state = A;
    //         end else next_state = current_state;
    //     end
    // end

    // output combinational logic
    assign led = (current_state == A) ? 2'b10 :  (current_state == B) ? 2'b01 : 2'b11;


endmodule
