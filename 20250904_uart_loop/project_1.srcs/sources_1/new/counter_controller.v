`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/01 15:22:20
// Design Name: 
// Module Name: counter_controller
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


// module counter_controller(
//     input clk,
//     input rst,
//     input enable,
//     input clear,
//     input mode,
//     output o_enable,
//     output o_clear,
//     output o_mode    
//     );
//     parameter [1:0] IDLE = 2'b00, CMD = 2'b01;
//     reg [1:0] state, state_next;
//     reg enable_reg, enable_next;
//     reg clear_reg, clear_next;
//     reg mode_reg, mode_next;

//     assign o_enable = enable_reg;
//     assign o_clear = clear_reg;
//     assign o_mode = mode_reg;

//     always@(posedge clk or posedge rst) begin
//         if(rst) begin
//             state <= 0;
//             enable_reg <= 0;
//             clear_reg <= 0;
//             mode_reg <= 0;
//         end else begin
//             state <= state_next;
//             enable_reg <= enable_next;
//             clear_reg <= clear_next;
//             mode_reg <= mode_next;
//         end
//     end

//     always@(*) begin
//         state_next = state;
//         enable_next <= 1'b0;
//         clear_next <= 1'b0;
//         mode_next <= 1'b0;        
//         case(state)
//             IDLE : begin
//                 if(enable || clear || mode) begin
//                     state_next = CMD;
//                 end                                   
//             end
//                 CMD :   begin
//                     if(enable) begin
//                         enable_next = 1'b1;
//                         state_next = IDLE; 
//                     end else if(clear) begin
//                         clear_next = 1'b1;
//                         state_next = IDLE;
//                     end else if(mode) begin
//                         mode_next = 1'b1;
//                         state_next = IDLE;
//                     end
//                     state_next = IDLE;
//                 end                                               
//         endcase
//     end
// endmodule

module counter_controller(
    input clk,
    input rst,
    input enable,
    input clear,
    input mode,
    output o_enable,
    output o_clear,
    output o_mode    
);

    parameter [1:0] IDLE = 2'b00, CMD = 2'b01;

    reg [1:0] state, state_next;
    reg enable_reg, enable_next;
    reg clear_reg, clear_next;
    reg mode_reg, mode_next;

    assign o_enable = enable_reg;
    assign o_clear  = clear_reg;
    assign o_mode   = mode_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            enable_reg  <= 0;
            clear_reg   <= 0;
            mode_reg    <= 0;
        end else begin
            state       <= state_next;
            enable_reg  <= enable_next;
            clear_reg   <= clear_next;
            mode_reg    <= mode_next;
        end
    end

    always @(*) begin
        state_next   = state;
        enable_next  = enable_reg;
        clear_next   = clear_reg;
        mode_next    = mode_reg;

        case (state)
            IDLE: begin
                if (enable || clear || mode)
                    state_next = CMD;
            end

            CMD: begin
                if (enable) begin
                    enable_next = ~enable_reg;//1'b1;
                    clear_next = 1'b0;
                    mode_next = 1'b0;
                end else if (clear) begin
                    enable_next = 1'b0;
                    clear_next = ~clear_reg;//1'b1; 
                    mode_next = 1'b0;                    
                end else if (mode) begin
                    enable_next = 1'b0;
                    clear_next = 1'b0;                        
                    mode_next = ~mode_reg;//1'b1;                 
                end
                state_next = IDLE;
            end
        endcase
    end
endmodule
