`timescale 1ns / 1ps

module btn_pulse_gen (
    input  clk,
    input  rst,
    input  i_btn,
    output o_pulse
);

    reg [1:0] r_btn_sync;

    assign o_pulse = (r_btn_sync == 2'b01);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_btn_sync <= 2'b00;
        end else begin
            r_btn_sync <= {r_btn_sync[0], i_btn};
        end
    end
    
endmodule