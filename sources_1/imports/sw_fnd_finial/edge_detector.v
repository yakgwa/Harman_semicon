`timescale 1ns / 1ps

module edge_detector (
    input clk,
    input rst,
    input i_level, // Debounced level signal
    output o_pulse  // 1-clock pulse signal
);
    reg level_reg;

    always @(posedge clk) begin
        if (rst)
            level_reg <= 1'b0;
        else
            level_reg <= i_level;
    end

    // 이전 상태는 0이었고, 현재 상태는 1인 순간을 감지
    assign o_pulse = ~level_reg && i_level;

endmodule