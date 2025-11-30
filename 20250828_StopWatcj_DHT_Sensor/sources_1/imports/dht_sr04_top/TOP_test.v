`timescale 1ns / 1ps

module TOP (

    // system I/O
    input clk,
    input rst,

    // user I/O
    input btn_L,
    input btn_R,
    input btn_U,
    input btn_D,
    input s_m_h_mode,  //  file : stopwatch > mode   , mode_manager > sw 0
    input sw_w_mode,   //  file :stopwatch > sw_mode , mode_manager > sw 1

    input sensor_sw_i,
    input sr_dht_sw,
    // uart(PC) I/O
    output tx,

    // SR04 I/O
    input echo,  // 얘는 센서에서 나오는거 아닌가 외부 입력은 아닌 것 같다.

    // DHT-11 I/O
    inout dht_io,
    output trig,
    output check,
    // display
    output [3:0] fnd_com,
    output [7:0] fnd_data,

    // uart
    input rx
);
    wire w_cal_don;
    wire w_pop_sw,w_pop_cu;
    wire w_sr_start_trig;
    wire w_dht_start_trig;
    wire [11:0] w_dist_data;
    wire w_empty_ctrl;
    wire [7:0] w_ctrl_data;


    // sw_wire
    wire w_current_function_mode;
    // reg left_pulse, right_pulse, up_pulse, down_pulse;


    // btn - sw_w_module_cu
    wire w_i_btn_l_pulse, w_i_btn_r_pulse, w_i_btn_u_pulse, w_i_btn_d_pulse;

    // sw_w_module_cu - sw_w_data
    wire w_o_left_pulse, w_o_right_pulse, w_o_up_pulse, w_o_down_pulse;
    wire w_o_clear_pulse;

    // mode manager - sw_dp
    wire w_i_runstop;

    // mode_manager - fnd

    wire w_i_mode;

    // fnd_mode_sel_wire
    wire [3:0] w_sw_fnd_com;
    wire [7:0] w_sw_fnd_data;
    wire [3:0] w_sr04_fnd_com;
    wire [7:0] w_sr04_fnd_data;
    wire [3:0] w_dht11_fnd_com;
    wire [7:0] w_dht11_fnd_data;

    wire w_o_pulse_L,w_o_pulse_R,w_o_pulse_U,w_o_pulse_D;

    dht11_top U_DHT11_TOP (
        .clk(clk),
        .rst(rst),
        .btn_L(btn_L),
        .uart_start(w_dht_start_trig),
        .dht_io(dht_io),
        .check(check),
        .fnd_com(w_dht11_fnd_com),
        .fnd_data(w_dht11_fnd_data)
    );

    sr04_top U_SR04_TOP (
        .clk(clk),
        .rst(rst),
        .start(btn_R),
        .uart_start(w_sr_start_trig),
        .echo(echo),
        .trig(trig),
        .cal_don(w_cal_don),
        .dist_data(w_dist_data),
        .fnd_com(w_sr04_fnd_com),
        .fnd_data(w_sr04_fnd_data)
    );


    uart_total U_UART_TOP (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .i_pop(w_pop_sw||w_pop_cu),
        .cal_don(w_cal_don),
        .i_dist_data(w_dist_data),
        .empty_ctrl(w_empty_ctrl),
        .tx(tx),
        .ctrl_data(w_ctrl_data)
    );

    command_cu_sensor U_COMMAND_CU_SENSOR (
        .clk(clk),
        .rst(rst),
        .empty_ctrl(w_empty_ctrl),
        .ctrl_data(w_ctrl_data),
        .sr_start_trig(w_sr_start_trig),
        .dht_start_trig(w_dht_start_trig),
        .o_pop(w_pop_cu)
    );





    btn_sw_top U_BTN_SW_TOP (
        .Btn_L(btn_L),
        .Btn_R(btn_R),
        .Btn_U(btn_U),
        .Btn_D(btn_D),
        .o_pulse_L(w_i_btn_l_pulse),
        .o_pulse_R(w_i_btn_r_pulse),
        .o_pulse_U(w_i_btn_u_pulse),
        .o_pulse_D(w_i_btn_d_pulse)
    );


    sw_w_module_cu U_SW_W_MODULE (
        .clk(clk),
        .rst(rst),
        .sw0(s_m_h_mode),
        .sw1(sw_w_mode),
        .i_fifo_empty(w_empty_ctrl),
        .i_fifo_rd_data(w_ctrl_data),
        .i_btn_l_pulse(w_o_pulse_L),
        .i_btn_r_pulse(w_o_pulse_R),
        .i_btn_u_pulse(w_o_pulse_U),
        .i_btn_d_pulse(w_o_pulse_D),
        .o_fifo_pop(w_pop_sw),
        .o_runstop_pulse(),
        .o_left_pulse(w_o_left_pulse),
        .o_right_pulse(w_o_right_pulse),
        .o_up_pulse(w_o_up_pulse),
        .o_down_pulse(w_o_down_pulse),
        .o_clear_pulse(w_o_clear_pulse),
        .o_current_function_mode(w_current_function_mode),
        .o_sw_runstop(w_i_runstop),
        .o_fnd_display_mode(w_i_mode)

    );


    sw_w_data U_SW_W_DATA (
        .clk(clk),
        .rst(rst),
        .i_current_function_mode(w_current_function_mode),
        .i_mode(w_i_mode),
        .i_runstop(w_i_runstop),
        .i_left_pulse(w_o_left_pulse),
        .i_right_pulse(w_o_right_pulse),
        .i_up_pulse(w_o_up_pulse),
        .i_down_pulse(w_o_down_pulse),
        .i_clear_pulse(w_o_clear_pulse),
        .fnd_com(w_sw_fnd_com),
        .fnd_data(w_sw_fnd_data)
    );


    fnd_mode_select U_FND_MODE_SEL (
        .current_active_mode({sensor_sw_i,sr_dht_sw}),  // 00: SW, 01: SR04, 10: DHT11
        .sw_fnd_com(w_sw_fnd_com),
        .sw_fnd_data(w_sw_fnd_data),
        .sr04_fnd_com(w_sr04_fnd_com),
        .sr04_fnd_data(w_sr04_fnd_data),
        .dht11_fnd_com(w_dht11_fnd_com),
        .dht11_fnd_data(w_dht11_fnd_data),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    

    btn_select U_BTN_SEL (
        .btn_L(w_i_btn_l_pulse),
        .btn_R(w_i_btn_r_pulse),
        .btn_U(w_i_btn_u_pulse),
        .btn_D(w_i_btn_d_pulse),
        .sensor_sw_i(sensor_sw_i),
        .o_btn_l(w_o_pulse_L),
        .o_btn_r(w_o_pulse_R),
        .o_btn_u(w_o_pulse_U),
        .o_btn_d(w_o_pulse_D)
    );
    







endmodule

module uart_total (
    input         clk,
    input         rst,
    input         rx,
    input         i_pop,
    input         cal_don,
    input  [11:0] i_dist_data,
    output        empty_ctrl,
    output        tx,
    output [ 7:0] ctrl_data
);

    wire [31:0] w_send_data;
    wire w_send_done;
    wire [7:0] w_tx_data;

    dat_to_asc U_DTOA (
        .i_dist_data(i_dist_data),
        .o_dist_data(w_send_data)
    );

    uart_top U_UART (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .i_pop(i_pop),
        .i_push(w_send_done),
        .tx_data(w_tx_data),
        .tx(tx),
        .tx_full(w_tx_full),
        .empty(empty_ctrl),
        .rx_data(ctrl_data)
    );
    sender_uart U_SENDER (
        .clk(clk),
        .rst(rst),
        .tx_full(w_tx_full),
        .i_send_data(w_send_data),
        .cal_don(cal_don),
        .o_tx_data(w_tx_data),
        .send_done(w_send_done)
    );
endmodule

module btn_select (
    input  btn_L,
    input  btn_R,
    input  btn_U,
    input  btn_D,
    input  sensor_sw_i,
    output o_btn_l,
    output o_btn_r,
    output o_btn_u,
    output o_btn_d
);

    reg c_btn_l, c_btn_r, c_btn_u, c_btn_d;
    assign o_btn_l = c_btn_l;
    assign o_btn_r  = c_btn_r;
    assign o_btn_u  = c_btn_u;
    assign o_btn_d   = c_btn_d;


    always @(*) begin
        case (sensor_sw_i)
            0: begin
                c_btn_l = btn_L;
                c_btn_r = btn_R;
                c_btn_u = btn_U;
                c_btn_d = btn_D;
            end

            1: begin
                c_btn_l = 0;
                c_btn_r = 0;
                c_btn_u = 0;
                c_btn_d = 0;
            end

            default: begin
                c_btn_l = btn_L;
                c_btn_r = btn_R;
                c_btn_u = btn_U;
                c_btn_d = btn_D;
            end
        endcase

    end



endmodule
