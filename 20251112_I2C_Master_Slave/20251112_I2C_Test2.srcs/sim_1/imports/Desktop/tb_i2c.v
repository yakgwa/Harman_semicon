`timescale 1ns/1ps
module tb_I2C_Master();
    logic       clk;
    logic       reset;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       tx_done;
    logic       ready;
    logic       start;
    logic       i2c_en;
    logic       stop;
    logic       SCL;
    logic [7:0] LED;
    logic rx_done;
    tri1 SDA;

    logic [7:0] slv_reg0;
    logic [7:0] slv_reg1;
    logic [7:0] slv_reg2;
    logic [7:0] slv_reg3;
 
    always #5 clk= ~clk;
    initial begin
        clk =0; reset =1;
        #10 reset =0;
        @(posedge clk) reset=1;

        /***********start*************/
        #50;
        start = 1; tx_data = 8'b10101010; i2c_en = 1; stop =0;
        #10;
        i2c_en =0;
        @(ready);

        /***********address*************/
        #50;
        start =0; stop=0; i2c_en=1;
        #50;
        i2c_en=0;
        @(ready);

        /***********data0*************/
        #50;
        start =0; stop=0; i2c_en=1; tx_data=8'h01;
        #50;
        i2c_en=0;
        @(ready);



        /***********data1*************/
        #50;
        start =0; stop=0; i2c_en=1; tx_data=8'h02;
        #50;
        i2c_en=0;
        @(ready);


        /***********data2*************/
        #50;
        start =0; stop=0; i2c_en=1; tx_data=8'h03;
        #50;
        i2c_en=0;
        @(ready);

        /***********data3*************/
        #50;
        start =0; stop=0; i2c_en=1; tx_data=8'h04;
        #50;
        i2c_en=0;
        @(ready);


        /***********stop*************/
        #50;
        start = 0; stop=1; i2c_en=1;
        #50
        i2c_en=0;
        @(ready);

        /***********start*************/
        #50;
        start = 1; tx_data = 8'b10101011; i2c_en = 1; stop =0;
        #50;
        i2c_en =0;
        @(ready);

        /***********address*************/
        #50;
        start =0; stop=0; i2c_en=1;
        #50;
        i2c_en=0;
        @(ready);

        /*********read  X 4 ************/
        #50;
        start = 1; i2c_en = 1; stop =1;
        #50;
        i2c_en =0;
        @(ready);
        //read1

        i2c_en=1;
        #30;
        i2c_en=0;
        @(ready);
        //read2

        i2c_en=1;
        #30;
        i2c_en=0;
        @(ready);
        //read3
        
        i2c_en=1;
        #30;
        i2c_en=0;
        @(ready);


        /***********stop*************/
        @(ready); //DATA HOLD 기다림
        @(ready); //hold 진입 기다림
        #50;
        start=0; stop=1; i2c_en=1;
        #50;
        i2c_en=0;

    end

    I2C_Master DUT(
    .clk(clk),
    .reset(reset),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .tx_done(tx_done),      // ACK
    .ready(ready),
    .start(start),
    .i2c_en(i2c_en),
    .stop(stop),
    .SCL(SCL),
    .LED(LED),
    .SDA(SDA)        
    );
    I2C_Slave U_Slave(
    .clk(clk),
    .reset(reset),
    .SCL(SCL),
    .SDA(SDA),
    .LED(LED),
    .slv_reg0(slv_reg0),
    .slv_reg1(slv_reg1),
    .slv_reg2(slv_reg2),
    .slv_reg3(slv_reg3)       
    );
endmodule