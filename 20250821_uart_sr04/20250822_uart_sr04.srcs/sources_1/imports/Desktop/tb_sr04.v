`timescale 1ns / 1ps
module tb_sr04();
    reg clk;
    reg rst;
    reg start;
    reg echo;
    wire o_trig;


 sr04_top dut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .echo(echo),
    .trig(o_trig),
    .fnd_com(),
    .fnd_data()
    );


    always #5 clk = ~clk;

    initial begin
    #0; clk = 0; rst = 1; start = 0; echo = 0;
    #10; rst = 0;
    // 1st, start btn
    #100; start = 1;
    #10_000; start = 0; // minimum 10ns
    
    // 2nd, 10ns TTL delay time
    #11_000;

    // 3rd, 
    #10_000;
    echo = 1;
    #(1000_000); //1ms
    echo = 0;

    #(1000 * 10000);
    $stop;
    end

   //  reg clk;
   //  reg rst;
   //  reg start;
   //  reg echo;
   //  wire o_trig;
   //  wire [8:0] o_dist;
   //  wire tick_1us;
   //  wire w_start;

   //  always #5 clk = ~clk;

   //  initial begin
   //  #0; clk = 0; rst = 1; start = 0; echo = 0;
   //  #10; rst = 0;
   //  // 1st, start btn
   //  #10; start = 1;
   //  #10; start = 0; // minimum 10ns
    
   //  // 2nd, 10ns TTL delay time
   //  #11_000;

   //  // 3rd, 
   //  #10_000;
   //  echo = 1;
   //  #(1000_000); //1ms
   //  echo = 0;

   //  #(1000 * 10);
   //  $stop;
   //  end

   //  tick_gen_1us dut0(
   //      .clk(clk),
   //      .rst(rst),
   //      .o_tick_1us(tick_1us)
   //  );


   //  sr04_controller dut1(
   //      .clk(clk),
   //      .rst(rst),
   //      .start(start),
   //      .echo(echo),
   //      .i_tick(tick_1us),
   //      .o_trig(o_trig),
   //      .o_dist(o_dist)
   //  );

   //  endmodule

 endmodule
