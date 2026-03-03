`timescale 1ns / 1ps



module dht11_top (
    input clk,
    input rst,
    input btn_L,
    input uart_start,
    inout dht_io,
    output check,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire w_o_tick_1us;
    wire w_start;
    wire [31:0] w_data;
    button_debounce_dht11 U_BD_DHT11 (
    .clk(clk),
    .rst(rst),
    .i_btn(btn_L),
    .o_btn(w_start)
);
    tick_gen_1us U_TICK_GEN_1US (
        .clk(clk),
        .rst(rst),
        .o_tick_1us(w_o_tick_1us)
    );

    dht11_controller U_DHT11_CU (
        .clk(clk),
        .rst(rst),
        .i_tick(w_o_tick_1us),
        .i_start(w_start||uart_start),
        .dht_io(dht_io),
        .o_valid(check),
        .o_data(w_data)
    );

    fnd_controller_dht11  U_FND_CTRL_DHT11(
    .clk(clk),
    .reset(rst),
    .counter(w_data),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
);
endmodule

module dht11_controller (
    input clk,
    input rst,
    input i_tick,  // 
    input i_start,  // start trig
    inout dht_io,  // sensor in/out
    output o_valid,  // result of check sum caculate
    output [31:0] o_data
);
    reg dht_io_enable_reg, dht_io_enable_next;  // to control fpr dht_out_reg
    reg dht_out_reg, dht_out_next;  // to dht11 sensor output


    parameter IDLE = 4'b0000, START = 4'b0001, WAIT = 4'b0010, SYNC_LOW = 4'b0011, 
              SYNC_HIGH = 4'b0100, SYNC_DATA = 4'b0101 , SYNC_DV = 4'b0110, STOP = 4'b0111, CAL = 4'b1000;
    reg [3:0] state, next;
    reg [14:0] count_reg, count_next;
    reg check_led_reg, check_led_next;
    reg [2:0] led_reg, led_next;
    reg [39:0] data_reg, data_next;

    reg [7:0] humid_int_reg, humid_int_next;
    reg [7:0] humid_deci_reg, humid_deci_next;
    reg [7:0] temp_int_reg, temp_int_next;
    reg [7:0] temp_deci_reg, temp_deci_next;
    reg [7:0] cal_reg, cal_next;

    reg [5:0] bit_count_reg, bit_count_next;

    assign dht_io = (dht_io_enable_reg) ? dht_out_reg : 1'bz;
    assign o_data = {
        humid_int_reg, humid_deci_reg, temp_int_reg, temp_deci_reg
    };
    assign o_valid = check_led_reg;

    // assign o_data = data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            count_reg <= 0;
            dht_out_reg <= 1'b1;
            dht_io_enable_reg <= 0;
            data_reg <= 0;
            bit_count_reg <= 0;
            check_led_reg <= 0;

            humid_int_reg <= 0;
            humid_deci_reg <= 0;
            temp_int_reg <= 0;
            temp_deci_reg <= 0;
            cal_reg <= 0;

        end else begin
            state <= next;
            count_reg <= count_next;
            dht_io_enable_reg <= dht_io_enable_next;
            dht_out_reg <= dht_out_next;
            data_reg <= data_next;
            bit_count_reg <= bit_count_next;
            check_led_reg <= check_led_next;

            humid_int_reg <= humid_int_next;
            humid_deci_reg <= humid_deci_next;
            temp_int_reg <= temp_int_next;
            temp_deci_reg <= temp_deci_next;
            cal_reg <= cal_next;

        end
    end

    always @(*) begin
        next = state;
        count_next = count_reg;
        bit_count_next = bit_count_reg;
        dht_io_enable_next = dht_io_enable_reg;
        dht_out_next = dht_out_reg;
        data_next = data_reg;
        check_led_next = check_led_reg;

        humid_int_next = humid_int_reg;
        humid_deci_next = humid_deci_reg;
        temp_int_next = temp_int_reg;
        temp_deci_next = temp_deci_reg;
        cal_next = cal_reg;

        case (state)
            IDLE: begin
                data_next = 0;
                check_led_next = check_led_reg;
                dht_out_next = 1'b1;
                dht_io_enable_next = 1'b1;
                if (i_start) begin
                    data_next = 0;
                    next = START;
                    count_next = 0;
                end
            end
            START: begin
                dht_out_next = 1'b0;
                if (i_tick) begin
                    if (count_reg == 18_000) begin  //18ms
                        count_next = 0;
                        next = WAIT;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            WAIT: begin
                //dht_out_next = 1'b1;
                dht_io_enable_next = 1'b0;
                if (i_tick) begin
                    if (count_reg == 30) begin
                        count_next = 0;
                        next = SYNC_LOW;
                        dht_out_next = 1'b0;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            SYNC_LOW: begin
                if (i_tick) begin
                    if (count_reg == 80) begin
                        if (dht_io) begin
                            count_next = 0;
                            next = SYNC_HIGH;
                        end
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            SYNC_HIGH: begin
                led_next = 3'b001;
                if (i_tick) begin
                    if (dht_io == 0) begin
                        next = SYNC_DATA;
                    end
                end
            end
            SYNC_DATA: begin
                if (i_tick) begin
                    count_next = 0;
                    if (bit_count_reg == 40) begin
                        bit_count_next = 0;
                        count_next = 0;
                        next = STOP;
                    end else begin
                        if (dht_io) begin
                            next = SYNC_DV;
                        end
                    end
                end
            end
            SYNC_DV: begin
                if (i_tick) begin
                    if (dht_io == 0) begin
                        if (count_reg > 40) begin
                            data_next[39-(bit_count_reg)] = 1'b1;
                            bit_count_next = bit_count_reg + 1;
                            next = SYNC_DATA;
                        end else begin
                            data_next[39-(bit_count_reg)] = 1'b0;
                            bit_count_next = bit_count_reg + 1;
                            next = SYNC_DATA;
                        end
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            STOP: begin
                if (i_tick) begin
                    if (count_reg == 50) begin
                        next = CAL;
                        count_next = 0;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            CAL: begin
                humid_int_next = data_reg[39:32];
                humid_deci_next = data_reg[31:24];
                temp_int_next = data_reg[23:16];
                temp_deci_next = data_reg[15:8];
                cal_next = humid_int_reg + humid_deci_reg + temp_int_reg + temp_deci_reg;
                if (cal_next == data_reg[7:0]) begin
                    check_led_next = 1;
                end else begin
                    check_led_next = 0;
                end
                if (i_tick) begin
                    next = IDLE;
                end
            end
        endcase
    end
endmodule

module tick_gen_1us (
    input  clk,
    input  rst,
    output o_tick_1us
);

    parameter TICK_COUNT = 100_000_000 / 1_000_000;
    reg [$clog2(TICK_COUNT) - 1 : 0] counter_reg;
    reg tick_1us;

    assign o_tick_1us = tick_1us;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_1us <= 0;
        end else begin
            if (counter_reg == TICK_COUNT - 1) begin
                counter_reg = 0;
                tick_1us = 1;
            end else begin
                counter_reg = counter_reg + 1;
                tick_1us = 0;
            end
        end
    end
endmodule

module button_debounce_dht11 (
    input  clk,
    rst,
    input  i_btn,
    output o_btn
);

    // 100m -> 1m
    reg [$clog2(100)-1:0] counter_reg;
    reg clk_reg;
    reg [7:0] q_reg, q_next;
    reg  edge_reg;
    wire debounce;

    // clock divider
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if (counter_reg == 99) begin
                counter_reg <= 0;
                clk_reg <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                clk_reg <= 1'b0;
            end
        end
    end

    // debounce logic, shift register
    always @(posedge clk_reg or posedge rst) begin
        if (rst) begin
            q_reg <= 0;  //4'b0;
        end else begin
            q_reg <= q_next;
        end
    end

    // Serial input, Paraller output shift register
    always @(*) begin
        q_next = {i_btn, q_reg[7:1]};  //q_reg[3:1]};

    end

    assign debounce = &q_reg;

    // Q5 output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debounce;
        end
    end

    // edge output
    assign o_btn = ~edge_reg & debounce;


endmodule
