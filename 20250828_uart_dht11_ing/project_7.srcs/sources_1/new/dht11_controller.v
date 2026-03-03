`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/27 08:46:48
// Design Name: 
// Module Name: dht11_controller
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


module dht11_top(
    input clk,
    input rst,
    input btn_L,
    inout dht_io,
    output [2:0] led,
    output led_1,
    output [7:0]fnd_data,
    output [3:0]fnd_com,
    //output [31:0] o_data,
    input rx,
    output tx
    );

    wire w_tick_gen_1us;
    wire w_start;
    wire [39:0] w_data;
    wire [31:0] o_data;
    wire [31:0] w_o_data;

    wire w_b_tick;
    wire w_start_from_btn;
    wire w_start_from_uart;   
    wire [7:0] w_rx_data, w_rx_fifo_q;
    wire w_rx_done;
    wire w_rx_fifo_empty, w_rx_fifo_pop_req;
    wire [7:0] w_tx_fifo_push_data;
    wire w_tx_fifo_push;
    wire w_tx_fifo_full;
    wire w_tx_busy;
    wire w_tx_fifo_empty;
    wire [7:0] w_tx_fifo_popdata;
    wire w_echo_done;

    button_debounce U_BD(
        .clk(clk), 
        .rst(rst),
        .i_btn(btn_L),
        .o_btn(w_start_from_btn)
    );

    tick_gen_1us U_TICK_GEN_1US(
        .clk(clk),
        .rst(rst),
        .o_tick_1us(w_tick_gen_1us)
    );

    baud_tick_gen U_BAUD_TICK_GEN(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .b_tick(w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    fifo U_RX_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_rx_data),
        .push(w_rx_done),
        .pop(w_rx_fifo_pop_req),
        .pop_data(w_rx_fifo_q),
        .full(),
        .empty(w_rx_fifo_empty)
    );

    receive_controller U_RECEIVE_CONTROLLER(
        .clk(clk),
        .reset(rst),
        .rx_fifo_data(w_rx_fifo_q),
        .rx_trigger(~w_rx_fifo_empty),
        .o_pop(w_rx_fifo_pop_req),
        .o_start(w_start_from_uart)
    );

    dht11_controller U_DHT11_CU(
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_gen_1us),  
        .i_start(w_start),
        .dht_io(dht_io), 
        .o_valid(), 
        .o_data(w_data),
        .o_echo_done(w_echo_done),
        .led(led) 
        );

    assign w_start = w_start_from_btn | w_start_from_uart;


    check_sum U_CHECK_SUM(
        .data(w_data),
        .result(o_data),
        .led_1(led_1)
    );

    // datatoascii U_DATATOASCII(
    //     .i_data(o_data), 
    //     .o_data(w_o_data)
    // );

    send_controller U_SEND_CONTROLLER(
        .clk(clk),
        .rst(rst),
        .i_data(o_data),
        .echo_done(w_echo_done),
        .o_start(w_tx_fifo_push),
        .o_bcd(w_tx_fifo_push_data),
        .tx_busy(w_tx_fifo_full)
        );

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .start_trigger(~w_tx_fifo_empty),
        .tx_data(w_tx_fifo_popdata),
        .b_tick(w_b_tick),
        .tx_busy(w_tx_busy),
        .tx(tx)
    );

    fifo U_TX_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_tx_fifo_push_data),
        .push(w_tx_fifo_push),
        .pop(~w_tx_busy),
        .pop_data(w_tx_fifo_popdata),
        .full(w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );    


    fnd_controller U_FND_CTRL(
        .clk(clk),
        .reset(rst),
        .counter(o_data),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)

    );
endmodule

module dht11_controller(
    input clk,
    input rst,
    input i_tick, // 
    input i_start, // start trig
    inout dht_io, // sensor in/out
    output o_valid, // result of check sum caculate
    //output [31:0] o_data,
    output [39:0] o_data,
    output [2:0] led, // debug
    output o_echo_done
    );
    reg dht_io_enable_reg, dht_io_enable_next; // to control fpr dht_out_reg
    reg dht_out_reg, dht_out_next; // to dht11 sensor output

    parameter IDLE = 3'b000, START = 3'b001, WAIT = 3'b010, SYNC_LOW = 3'b011, 
              SYNC_HIGH = 3'b100, SYNC_DATA = 3'b101 , SYNC_DV = 4'b110, STOP = 3'b111;              
    reg [2:0] state, next;
    reg [14:0] count_reg, count_next;
    reg [2:0] led_reg, led_next;
    reg [39:0] data_reg, data_next;
    reg valid_reg, valid_next;
    reg echo_done_reg, echo_done_next;

    reg [5:0] bit_count_reg, bit_count_next;

    assign dht_io = (dht_io_enable_reg) ? dht_out_reg : 1'bz;
    assign led = led_reg;
    assign o_valid = valid_reg; 
    assign o_data = data_reg;
    assign o_echo_done = echo_done_reg;

    always@(posedge clk or posedge rst) begin
            if(rst) begin
                state <= 0;
                count_reg <= 0;
                led_reg <= 0;
                dht_out_reg <= 1'b1; 
                dht_io_enable_reg <= 0;
                data_reg <= 0;
                bit_count_reg <= 0; 
                valid_reg <= 0;  
                echo_done_reg <= 0;        

            end else begin
                state <= next;
                count_reg <= count_next;
                led_reg <= led_next;
                dht_io_enable_reg <= dht_io_enable_next;
                dht_out_reg <= dht_out_next;
                data_reg <= data_next;
                bit_count_reg <= bit_count_next;
                valid_reg <= valid_next;
                echo_done_reg <= echo_done_next;

            end
        end

    always@(*) begin
        next = state;
        count_next = count_reg;
        led_next = led_reg;
        bit_count_next = bit_count_reg;
        dht_io_enable_next = dht_io_enable_reg;
        dht_out_next = dht_out_reg;
        data_next = data_reg;
        valid_next = valid_reg;
        echo_done_next = echo_done_reg;
        echo_done_next = 1'b0;
        case(state)
        IDLE : begin
            //data_next = 0;
            led_next = 3'b100;
            dht_out_next = 1'b1;
            dht_io_enable_next = 1'b1; 
            echo_done_next = 1'b0; 
                if(i_start) begin
                    data_next = 0;
                    next = START;
                    count_next = 0;
                end
        end
        START : begin
            led_next = 3'b001;
            dht_out_next = 1'b0;
            if(i_tick) begin
                if(count_reg == 18_000) begin  //18ms
                    count_next = 0;
                    next = WAIT;
                end else begin
                    count_next = count_reg + 1;
                    end
                end
            end
        WAIT : begin
            //dht_out_next = 1'b1;
            dht_io_enable_next = 1'b0;
            if(i_tick) begin
                if(count_reg == 30) begin    
                    count_next = 0;
                    next  = SYNC_LOW;
                    dht_out_next = 1'b0;
                end else begin
                    count_next = count_reg + 1;
                    end
                end
            end
        SYNC_LOW : begin
            led_next = 3'b010;
            if(i_tick) begin
                if(count_reg  ==  80) begin
                    if(dht_io) begin
                        count_next = 0;
                        next = SYNC_HIGH;
                    end
                end else begin
                    count_next = count_reg + 1;
                end
            end
        end
        SYNC_HIGH :  begin
            led_next = 3'b001;
            if(i_tick) begin
                if(dht_io == 0) begin
                    next = SYNC_DATA;
                end
            end
         end
        SYNC_DATA : begin
            if(i_tick) begin
                count_next = 0;
                if(bit_count_reg == 40) begin
                    bit_count_next = 0;
                    count_next = 0;
                    next = STOP;
                 end else begin
                    if(dht_io) begin
                         next = SYNC_DV;
                    end
                end
             end
        end
        SYNC_DV : begin
            if(i_tick) begin
                if(dht_io == 0) begin
                    if(count_reg > 40) begin  
                        data_next[39 - (bit_count_reg)] = 1'b1;
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
        STOP : begin
            led_next = 3'b100;
            echo_done_next = 1'b1;
            if(i_tick) begin
                if(count_reg == 50) begin
                    next = IDLE;
                    count_next = 0;
                    valid_next = 1;
                end else begin
                    count_next = count_reg + 1;
                end
            end
        end
    endcase
    end
endmodule

module tick_gen_1us(
    input clk,
    input rst,
    output o_tick_1us
);

    parameter TICK_COUNT = 100_000_000 / 1_000_000;
    reg [$clog2(TICK_COUNT) - 1 : 0] counter_reg;
    reg tick_1us;

    assign o_tick_1us = tick_1us;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            tick_1us <= 0;
        end else begin
            if(counter_reg == TICK_COUNT - 1) begin   
                counter_reg = 0;
                tick_1us = 1;
            end else begin
                counter_reg = counter_reg + 1;
                tick_1us = 0;
            end
        end
    end
endmodule    

module button_debounce(
    input clk, rst,
    input i_btn,
    output o_btn
    );

    // 100m -> 1m
    reg[$clog2(100)-1:0] counter_reg;
    reg clk_reg;
    reg [7:0] q_reg, q_next;
    reg edge_reg;
    wire debounce;

    // clock divider
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if(counter_reg == 99) begin
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
        if(rst) begin
            q_reg <= 0;//4'b0;
        end else begin
            q_reg <= q_next; 
        end    
    end

    // Serial input, Paraller output shift register
    always@(*) begin
        q_next = {i_btn, q_reg[7:1]}; //q_reg[3:1]};
   
    end

    assign debounce = &q_reg; 

    // Q5 output
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debounce;
        end
    end

    // edge output
    assign o_btn = ~edge_reg & debounce;


endmodule

module check_sum(
    input [39:0] data,
    output [31:0] result,
    output reg led_1
    );

    wire humid_int, humid_deci, temp_int, temp_deci;

    assign humid_int = data[39:32];
    assign humid_deci = data[31:24];
    assign temp_int = data[23:16];
    assign temp_deci = data[15:8];
    assign result = data[39:8];
    assign total = humid_int +  humid_deci + temp_int + temp_deci;

    always@(*) begin
        if(total == data[7:0]) begin
            led_1 = 1'b1;
        end else begin
            led_1 = 1'b0;
        end
    end
endmodule

module datatoascii(
    input [31:0] i_data, // 0000 ~ 9999
    output [31:0] o_data
    );

    assign o_data[7:0] = i_data % 10 + 8'h30; // o_data[7:0]
    assign o_data[15:8] = (i_data/10) % 10 + 8'h30; // o_data[15:8]
    assign o_data[23:16] = (i_data/100) % 10 + 8'h30; // o_data[23:16]
    assign o_data[31:24] = (i_data/1000) % 10 + 8'h30; // o_data[31:24]
endmodule


module send_controller(
    input clk,
    input rst,
    input [31:0] i_data,
    input echo_done,
    output o_start,
    output [7:0] o_bcd,
    input tx_busy
);

    parameter IDLE = 4'b0000, WAIT = 4'b0001, DIGIT_1000 = 4'b0010, WAIT_1 = 4'b0011, DIGIT_100 = 4'b0100, DIGIT_10 = 4'b0101, DIGIT_1 = 4'b0110, WAIT_2 = 4'b0111, WAIT_3 = 4'b1000;
    //parameter IDLE = 3'b000, WAIT = 3'b001, DIGIT_1000 = 3'b010, WAIT_1 = 3'b011, DIGIT_100 = 3'b100, DIGIT_10 = 3'b101, DIGIT_1 = 3'b110, WAIT_2 = 3'b111;
    //reg clk_reg, clk_next;
    reg [3:0] state, next;
    reg [3:0] digit_1000_reg, digit_100_reg, digit_10_reg, digit_1_reg;
    reg [7:0] o_bcd_reg, o_bcd_next;
    reg o_start_reg, o_start_next;

    assign o_bcd = o_bcd_reg;
    assign o_start = o_start_reg;

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            digit_1000_reg <= 0;
            digit_100_reg <= 0;
            digit_10_reg  <= 0;
            digit_1_reg   <= 0;
        end else begin
            state <= next;
            o_bcd_reg <= o_bcd_next;
            o_start_reg <= o_start_next;
            if (next == WAIT) begin
                digit_1000_reg <= i_data[31:24];
                digit_100_reg <= i_data[23:16];
                digit_10_reg <= i_data[15:8];
                digit_1_reg <= i_data[7:0];                
            end
        end
    end

    always @(*) begin
        next = state;
        o_start_next = 1'b0;
        o_bcd_next  = o_bcd_reg;
        case (state)
            IDLE: begin
                if (echo_done == 1) begin
                    next = WAIT;
                end
            end
            WAIT: begin
                next = DIGIT_1000;
            end

            DIGIT_1000: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_1000_reg;// + 8'h30;
                    next = WAIT_1;//DIGIT_100;
                end
            end
            WAIT_1: begin
                next = DIGIT_100;
            end            
            DIGIT_100: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_100_reg;// + 8'h30;
                    next = WAIT_2;
                end
            end
            WAIT_2: begin
                next = DIGIT_10;
            end                  
            DIGIT_10: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_10_reg;// + 8'h30;
                    next = WAIT_3;
                end
            end
            WAIT_3: begin
                next = DIGIT_1;
            end                  
            DIGIT_1: begin
                if (!tx_busy) begin
                    o_start_next = 1'b1;
                    o_bcd_next  = digit_1_reg;// + 8'h30;
                    next = IDLE;
                end
            end            
        endcase
    end

endmodule


module receive_controller(
     input        clk,
     input        reset,
     input  [7:0] rx_fifo_data,
     input        rx_trigger,
     output       o_pop,
     output       o_start
 );

     assign o_pop = rx_trigger;
     assign o_start = (rx_trigger && (rx_fifo_data == 8'h64));

endmodule

module fnd_controller (
    input clk,
    input reset,
    //input  [7:0] bcd,
    input [31:0] counter,
    //input [1:0] sel,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

//assign fnd_com = 4'b1110;

wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
wire [3:0] w_bcd;
wire [1:0] w_sel;
wire w_clk_1khz;

clk_div_1khz U_CLK_DIV_1KHZ(
    .clk(clk),
    .reset(reset),
    .o_clk_1khz(w_clk_1khz)
);

counter_4 U_COUNTER_4(
    .clk(w_clk_1khz),
    .reset(reset),
    .sel(w_sel)
);

digit_splitter U_DS(
    .count_data(counter),
    .digit_1(w_digit_1),
    .digit_10(w_digit_10),
    .digit_100(w_digit_100),
    .digit_1000(w_digit_1000)
);

decoder_2x4 U_DECODER_2x4(
    .sel(w_sel),
    .fnd_com(fnd_com)
);

mux_4x1 U_MUX_4x1(
    .digit_1(w_digit_1),
    .digit_10(w_digit_10),
    .digit_100(w_digit_100),
    .digit_1000(w_digit_1000),
    .sel(w_sel),
    .bcd(w_bcd)
);

bcd_decoder U_BCD_DECODER(
    .bcd(w_bcd),
    .fnd_data(fnd_data)
);

endmodule

module clk_div_1khz(
    input clk,
    input reset,
    output o_clk_1khz
);

    // counter 10_000
    reg [$clog2(100_000)-1 : 0] r_counter; //$clog2는 시스템에서 제공하는 task
    reg r_clk_1khz;
    assign o_clk_1khz = r_clk_1khz;

    always@(posedge clk or posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            r_clk_1khz <= 1'b0;
        end else begin
            if (r_counter == 99_000) begin
                r_counter <= 0;
                r_clk_1khz <= 1'b1;
            end else begin
                r_counter <= r_counter + 1'b1;
                r_clk_1khz <= 1'b0;
            end
        end
    end

endmodule

module counter_4(
    input clk,
    input reset,
    output [1:0] sel
);

    reg [1:0] counter; // overflow가 나도 상관없음
                       // always 구문에서 값을 받아서 저장하므로 합성기가 자동으로 Flip-flop 생성
    assign sel = counter;

    always@(posedge clk or posedge reset) begin 
        if(reset) begin // clk의 상승엣지 or reset의 상승엣지가 발생했을때 begin ~ end 실행
            // initial
            counter <= 2'b00;
        end else begin
            // operation
            counter <= counter + 1'b1;
        end
    end

endmodule

module decoder_2x4(
    input [1:0] sel,
    output [3:0] fnd_com
);

    assign fnd_com = (sel == 2'b00) ? 4'b1110 :
                      (sel == 2'b01) ? 4'b1101 :
                      (sel == 2'b10) ? 4'b1011 :
                      (sel == 2'b11) ? 4'b0111 : 4'b1111;                  

endmodule

module mux_4x1(
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [1:0] sel,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    always@(*) begin
        case(sel)
            2'b00 : r_bcd = digit_1;
            2'b01 : r_bcd = digit_10;
            2'b10 : r_bcd = digit_100;
            2'b11 : r_bcd = digit_1000;
            default : r_bcd = digit_1;
        endcase
    end

endmodule

module digit_splitter(
    input [31:0] count_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    // assign digit_1 = count_data[31:24] % 10;
    // assign digit_10 = (count_data[31:24] / 10) % 10;
    // assign digit_100 = count_data[15:8] % 10;
    // assign digit_1000 = (count_data[15:8] / 10) % 10;

    assign digit_1000 = count_data[31:24] % 10; // 1000자리
    assign digit_100  = count_data[23:16] % 10; // 100자리
    assign digit_10   = count_data[15:8]  % 10; // 10자리
    assign digit_1    = count_data[7:0]   % 10; // 1자리

    // always@(*) begin
    //     case(bcd_data)
    // end

endmodule

module bcd_decoder(
    input  [3:0] bcd,
    output reg [7:0] fnd_data
);

    always@(bcd) begin 
        case(bcd)
        4'b0000 :  fnd_data = 8'hc0;
        4'b0001 :  fnd_data = 8'hF9; 
        4'b0010 :  fnd_data = 8'hA4;
        4'b0011 :  fnd_data = 8'hB0;
        4'b0100 :  fnd_data = 8'h99;
        4'b0101 :  fnd_data = 8'h92;
        4'b0110 :  fnd_data = 8'h82;
        4'b0111 :  fnd_data = 8'hF8;
        4'b1000 :  fnd_data = 8'h80;
        4'b1001 :  fnd_data = 8'h90;
        4'b1010 :  fnd_data = 8'h88;
        4'b1011 :  fnd_data = 8'h83;
        4'b1100 :  fnd_data = 8'hc6;
        4'b1101 :  fnd_data = 8'ha1;
        4'b1110 :  fnd_data = 8'h86;
        4'b1111 :  fnd_data = 8'h8e;
        default :  fnd_data = 8'hff;
        endcase
    end

endmodule

module baud_tick_gen(
    input clk,
    input rst,
    output b_tick
    );

    parameter BAUDRATE = 9600 * 16;
    localparam BAUD_COUNT = 100_000_000 / BAUDRATE;
    reg [$clog2(BAUD_COUNT - 1) : 0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    // output
    assign b_tick = tick_reg;

    // SL
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end
    end

    // next CL
    always@(*) begin
        counter_next = counter_reg;
        tick_next = tick_reg;
        if(counter_reg == BAUD_COUNT - 1) begin   
            counter_next = 0;
            tick_next = 1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next = 0;
        end
    end

endmodule
