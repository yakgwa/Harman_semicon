`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/18 15:41:19
// Design Name: 
// Module Name: fifo
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


module fifo(
    input clk,
    input rst,
    input [7:0] push_data,
    input push,
    input pop,
    output [7:0] pop_data,
    output full,
    output empty
    );

    wire [1:0] w_wptr, w_rptr;

    register_file U_REG_FILE(
        .clk(clk),
        .wptr(w_wptr),
        .rptr(w_rptr),
        .push_data(push_data),
        .wr(~full&push),
        .pop_data(pop_data)
    );

    fifo_cu U_FIFO_CU(
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .wptr(w_wptr),
        .rptr(w_rptr),
        .full(full),
        .empty(empty)
    );


endmodule

module register_file(
    input clk,
    input [1:0] wptr,
    input [1:0] rptr,
    input [7:0] push_data,
    input wr,
    output [7:0] pop_data
    );

    reg [7:0] ram[0:3];

    // output CL
    assign pop_data = ram[rptr];


    always @(posedge clk) begin
        if(wr) begin // push
            ram[wptr] <= push_data;
        end 
    end
    
endmodule

module fifo_cu(
    input clk,
    input rst,
    input push,
    input pop,
    output [1:0] wptr,
    output [1:0] rptr,
    output full,
    output empty
    );

    // output
    reg [1:0] wptr_reg, wptr_next;
    reg [1:0] rptr_reg, rptr_next;
    reg full_reg, full_next;
    reg empty_reg, empty_next;

    assign wptr = wptr_reg;
    assign rptr = rptr_reg;
    assign full = full_reg;
    assign empty = empty_reg;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            wptr_reg <= 0;
            rptr_reg <= 0;
            full_reg <= 0;
            empty_reg <= 1;
        end else begin
            wptr_reg <= wptr_next;
            rptr_reg <= rptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end

    always @(*) begin
        wptr_next = wptr_reg;
        rptr_next = rptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;
        case({push,pop})
            // 2'b00 : begin

            // end
            2'b01 : begin // pop
                full_next = 1'b0;

                if(!empty_reg) begin
                    rptr_next = rptr_reg + 1;
                    if(wptr_reg == rptr_next) begin// 증가시킬거랑 현재 read point가 같은지 비교
                        empty_next = 1'b1;
                    end
                end
            end

            2'b10 : begin
                empty_next = 1'b0;

                if(!full_reg) begin
                    wptr_next = wptr_reg + 1;
                    if(wptr_next == rptr_reg) begin// 출력을 내보낼건데 현재를 봐야함
                        full_next = 1'b1;
                    end
                end
            end
            
            2'b11 : begin
                if(empty_reg == 1'b1) begin
                    wptr_next = wptr_reg + 1;
                    empty_next = 1'b0;
                end else if(full_reg == 1'b1) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                end else begin
                    //not be full, empty
                    wptr_next = wptr_reg + 1;
                    rptr_next = rptr_reg + 1;
                end
            end
        endcase
    end
endmodule
