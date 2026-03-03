`timescale 1ns / 1ps
module fifo (
    input        clk,
    input        rst,
    input  [7:0] push_data,
    input        push,
    input        pop,
    output [7:0] pop_data,
    output       full,
    output       empty
);


    wire [2:0] w_w_ptr;
    wire [2:0] w_r_ptr;
    register_file U_REGISTER_FILE (
        .clk(clk),
        .w_ptr(w_w_ptr),
        .r_ptr(w_r_ptr),
        .push_data(push_data),
        .wr(~full & push),
        .pop_data(pop_data)
    );
    fifo_cu FIFO_CU (
        .clk  (clk),
        .rst  (rst),
        .push (push),
        .pop  (pop),
        .w_ptr(w_w_ptr),
        .r_ptr(w_r_ptr),
        .full (full),
        .empty(empty)
    );

endmodule

module register_file (
    input        clk,
    input  [2:0] w_ptr,
    input  [2:0] r_ptr,
    input  [7:0] push_data,
    input        wr,
    output [7:0] pop_data
);

    reg [7:0] ram[5:0];

    assign pop_data = ram[r_ptr];

    always @(posedge clk) begin
        if (wr) begin
            ram[w_ptr] <= push_data;
        end
    end
endmodule

module fifo_cu (
    input        clk,
    input        rst,
    input        push,
    input        pop,
    output [2:0] w_ptr,
    output [2:0] r_ptr,
    output       full,
    output       empty
);
    //output
    reg [2:0] w_ptr_reg, w_ptr_next;
    reg [2:0] r_ptr_reg, r_ptr_next;
    reg full_reg, full_next;
    reg empty_reg, empty_next;

    assign w_ptr = w_ptr_reg;
    assign r_ptr = r_ptr_reg;
    assign full  = full_reg;
    assign empty = empty_reg;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg  <= 0;
            empty_reg <= 1'b1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end
    always @(*) begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next  = full_reg;
        empty_next = empty_reg;
        case ({
            push, pop
        })
            2'b01: begin
                full_next = 1'b0;
                if (!empty_reg) begin
                    r_ptr_next = r_ptr_reg + 1;
                    if (r_ptr_next == w_ptr_reg) begin
                        empty_next = 1'b1;
                    end
                end
            end

            2'b10: begin
                // push
                empty_next = 0;
                if (!full_reg) begin
                    w_ptr_next = w_ptr_reg + 1;
                    if (w_ptr_next == r_ptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end
            2'b11: begin
                if (empty_reg == 1) begin
                    w_ptr_next = w_ptr_reg + 1;
                    empty_next = 1'b0;
                end else if (full_reg == 1'b1) begin
                    r_ptr_next = r_ptr_reg + 1;
                    full_next  = 1'b0;
                end else begin
                    w_ptr_next = w_ptr_reg + 1;
                    r_ptr_next = r_ptr_reg + 1;
                end
            end

        endcase
    end


endmodule
