`timescale 1ns / 1ps

module top_I2C_Slave (
    input  logic       clk,
    input  logic       reset,
    inout  logic       sda,
    input  logic       scl,
    input  logic       btn,
    output logic [7:0] gpio,
    output logic       ready,
    output logic [3:0] an,
    output logic [7:0] seg
);
    logic [7:0] slv_reg0;
    logic [7:0] slv_reg1;
    logic [7:0] slv_reg2;
    logic [7:0] slv_reg3;

    I2C_Slave u_I2C_Slave (
        .clk     (clk),
        .reset   (reset),
        .sda     (sda),
        .scl     (scl),
        .slv_reg0(slv_reg0),
        .slv_reg1(slv_reg1),
        .slv_reg2(slv_reg2),
        .slv_reg3(slv_reg3),
        .ready   (ready)
    );

    logic [1:0] sel;
    btn_push_counter u_btn_count (
        .clk  (clk),
        .reset(reset),
        .btn  (btn),
        .count  (sel)
    );

    //logic [7:0] bcd;

    always_comb begin : gpioCtrl
        case (sel)
            0: gpio = 8'b00000001;
            1: gpio = 8'b00000010;
            2: gpio = 8'b00000100;
            3: gpio = 8'b00001000;
            default : gpio = 8'b00000000;
        endcase
    end

    logic [7:0] bcd;

    always_comb begin : fndDataSel
        case (sel)
            0: bcd = slv_reg0;
            1: bcd = slv_reg1;
            2: bcd = slv_reg2;
            3: bcd = slv_reg3;
        endcase
    end

    fndController u_fndController (
        .clk    (clk),
        .reset  (reset),
        .fndData(bcd),
        .fndDot (4'b1111),
        .fndCom (an),
        .fndFont(seg)
    );        

    gpio u_gpio(
        .cr(8'b11110000),
        .odr(8'b00001111),
        .idr(),
        .gpio(gpio)
        );

endmodule

module btn_push_counter (
    input  logic       clk,
    input  logic       reset,
    input  logic       btn,
    output logic [1:0] count
);
    btn_debounce u_btn_debounce (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn),
        .o_btn(btdb)
    );

    always_ff @(posedge btdb, posedge reset) begin : blockName
        if (reset) begin
            count = 0;
        end else count <= count + 1;
    end
endmodule

module gpio(
    input   logic [7:0] cr,
    input   logic [7:0] odr,
    output  logic [7:0] idr,
    inout   logic [7:0] gpio
    );
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            assign gpio[i] = cr[i] ? odr[i] : 1'bz;
            assign idr[i] = ~cr[i] ? gpio[i] : 1'bz;
        end
    endgenerate


endmodule