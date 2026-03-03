`timescale 1ns/1ps

//class i2c_data_t;
//    rand logic [7:0] data;

//    constraint data_c { data inside {[8'h00 : 8'hFF]}; }

//endclass

//module tb_I2C_Master();
//    logic       clk;
//    logic       reset;
//    logic [7:0] tx_data;
//    logic [7:0] rx_data;
//    logic       tx_done;
//    logic       tx_ready;
//    logic       i2c_start;
//    logic       i2c_en;
//    logic       i2c_stop;
//    logic       SCL;
//    logic [7:0] LED;
//    logic rx_done;
//    tri1 SDA;

//    logic [7:0] slv_reg0;
//    logic [7:0] slv_reg1;
//    logic [7:0] slv_reg2;
//    logic [7:0] slv_reg3;
 
//    always #5 clk= ~clk;

//    task automatic i2c_write(input [7:0] data);
//        // START
//        #50;
//        tx_data = 8'b10101010; 
//        i2c_start = 1;
//        i2c_stop  = 0;
//        i2c_en    = 1;
//        #10;
//        i2c_en = 0;
//        @(posedge tx_ready);

//        // ADDRESS
//        #50;
//        i2c_start = 0;
//        i2c_stop  = 0;
//        i2c_en    = 1;
//        #50;
//        i2c_en = 0;
//        @(posedge tx_ready);

//        // DATA
//        #50;
//        tx_data = data;
//        i2c_start = 0;
//        i2c_stop  = 0;
//        i2c_en    = 1;
//        #50;
//        i2c_en = 0;
//        @(posedge tx_ready);

//        // STOP
//        #50;
//        i2c_start = 0;
//        i2c_stop  = 1;
//        i2c_en    = 1;
//        #50;
//        i2c_en = 0;
//        @(posedge tx_ready);
//    endtask

//    task automatic i2c_slave_out();
//        #50;
//        i2c_start = 1; 
//        tx_data = 8'b10101011; 
//        i2c_en = 1; 
//        i2c_stop = 0;
//        #10;
//        i2c_en = 0;
//        @(posedge tx_ready);

//        #50;
//        i2c_start = 0; 
//        i2c_stop = 0; 
//        i2c_en = 1;
//        #50;
//        i2c_en = 0;
//        @(posedge tx_ready);

//        repeat(4) begin
//            #50;
//            i2c_start = 1; 
//            i2c_stop  = 1; 
//            i2c_en    = 1;
//            #30;
//            i2c_en = 0;
//            @(posedge tx_ready);
//        end

//        #50;
//        i2c_start = 0; 
//        i2c_stop = 1; 
//        i2c_en = 1;
//        #50;
//        i2c_en = 0;
//        @(posedge tx_ready);
//    endtask

//    initial begin
//        clk =0; reset =1;
//        #10 reset =0;
//        @(posedge clk) reset=1;
//    end

//    initial begin    
//        i2c_data_t rand_data;
//        rand_data = new();
//        repeat (10) begin
//            if (!rand_data.randomize())
//                $fatal("Randomization failed!");

//            $display("[%0t] Random I2C Write Data = 0x%02h", $time, rand_data.data);
//            i2c_write(rand_data.data);
//        end
//        repeat (4) begin
//            i2c_slave_out();
//        end       
//   // #10;
//    $finish; 
//    end

//    I2C_Master DUT(.*);
//    I2C_Slave U_Slave(.*);

//endmodule



// module tb_I2C_Master();
//     logic       clk;
//     logic       reset;
//     logic [7:0] tx_data;
//     logic [7:0] rx_data;
//     logic       tx_done;
//     logic       tx_ready;
//     logic       i2c_start;
//     logic       i2c_en;
//     logic       i2c_stop;
//     logic       SCL;
//     logic [7:0] LED;
//     logic rx_done;
//     tri1 SDA;

//     logic [7:0] slv_reg0;
//     logic [7:0] slv_reg1;
//     logic [7:0] slv_reg2;
//     logic [7:0] slv_reg3;
 
//     always #5 clk= ~clk;

//     class i2c_data_t;
//         rand logic [7:0] data;
//     endclass

//     task automatic i2c_write(input [7:0] data);
//         // START
//         #50;
//         tx_data = 8'b10101010; 
//         i2c_start = 1;
//         i2c_stop  = 0;
//         i2c_en    = 1;
//         #10;
//         i2c_en = 0;
//         @(tx_ready);

//         // ADDRESS
//         #50;
//         i2c_start = 0;
//         i2c_stop  = 0;
//         i2c_en    = 1;
//         #50;
//         i2c_en = 0;
//         @(tx_ready);

//         // DATA
//         #50;
//         tx_data = data;
//         i2c_start = 0;
//         i2c_stop  = 0;
//         i2c_en    = 1;
//         #50;
//         i2c_en = 0;
//         @(tx_ready);

//         // STOP
//         #50;
//         i2c_start = 0;
//         i2c_stop  = 1;
//         i2c_en    = 1;
//         #50;
//         i2c_en = 0;
//         @(tx_ready);
//     endtask

//     task automatic i2c_slave_out();
//         #50;
//         i2c_start = 1; 
//         tx_data = 8'b10101011; 
//         i2c_en = 1; 
//         i2c_stop = 0;
//         #10;
//         i2c_en = 0;
//         @(posedge tx_ready);

//         #50;
//         i2c_start = 0; 
//         i2c_stop = 0; 
//         i2c_en = 1;
//         #50;
//         i2c_en = 0;
//         @(posedge tx_ready);

//         repeat(4) begin
//             #50;
//             i2c_start = 1; 
//             i2c_stop  = 1; 
//             i2c_en    = 1;
//             #30;
//             i2c_en = 0;
//             @(posedge tx_ready);
//         end

//         #50;
//         i2c_start = 0; 
//         i2c_stop = 1; 
//         i2c_en = 1;
//         #50;
//         i2c_en = 0;
//         @(posedge tx_ready);
//     endtask

//     initial begin
//         clk =0; reset =1;
//         #10 reset =0;
//         @(posedge clk) reset=1;
//     end

//     initial begin
//         i2c_write(8'h01);
//         i2c_write(8'h02);
//         i2c_write(8'h03);
//         i2c_write(8'h04);
//         i2c_slave_out();
//         i2c_slave_out();
//         i2c_slave_out();
//         i2c_slave_out();
//         #10;
//         $finish;
//     end

//     I2C_Master DUT(.*);
//     I2C_Slave U_Slave(.*);

// endmodule



 module tb_I2C_Master();
     logic       clk;
     logic       reset;
     logic [7:0] tx_data;
     logic [7:0] rx_data;
     logic       tx_done;
     logic       tx_ready;
     logic       i2c_start;
     logic       i2c_en;
     logic       i2c_stop;
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
         i2c_start = 1; tx_data = 8'b10101010; i2c_en = 1; i2c_stop =0;
         #10;
         i2c_en =0;
         @(posedge tx_ready);

         /***********address*************/
         #50;
         i2c_start =0; i2c_stop=0; i2c_en=1;
         #50;
         i2c_en=0;
         @(posedge tx_ready);

         /***********data0*************/
         #50;
         i2c_start =0; i2c_stop=0; i2c_en=1; tx_data=8'h01;
         #50;
         i2c_en=0;
         @(posedge tx_ready);



         /***********data1*************/
         #50;
         i2c_start =0; i2c_stop=0; i2c_en=1; tx_data=8'h02;
         #50;
         i2c_en=0;
         @(posedge tx_ready);


         /***********data2*************/
         #50;
         i2c_start =0; i2c_stop=0; i2c_en=1; tx_data=8'h03;
         #50;
         i2c_en=0;
         @(posedge tx_ready);

         /***********data3*************/
         #50;
         i2c_start =0; i2c_stop=0; i2c_en=1; tx_data=8'h04;
         #50;
         i2c_en=0;
         @(posedge tx_ready);


         /***********stop*************/
         #50;
         i2c_start = 0; i2c_stop=1; i2c_en=1;
         #50
         i2c_en=0;
         @(posedge tx_ready);

         /***********start*************/
         #50;
         i2c_start = 1; tx_data = 8'b10101011; i2c_en = 1; i2c_stop =0;
         #50;
         i2c_en =0;
         @(posedge tx_ready);

         /***********address*************/
         #50;
         i2c_start =0; i2c_stop=0; i2c_en=1;
         #50;
         i2c_en=0;
         @(posedge tx_ready);

         /*********read  X 4 ************/
         #50;
         i2c_start = 1; i2c_en = 1; i2c_stop =1;
         #50;
         i2c_en =0;
         @(posedge tx_ready);
         //read1

         i2c_en=1;
         #30;
         i2c_en=0;
         @(posedge tx_ready);
         //read2

         i2c_en=1;
         #30;
         i2c_en=0;
         @(posedge tx_ready);
         //read3
        
         i2c_en=1;
         #30;
         i2c_en=0;
         @(posedge tx_ready);


         /***********stop*************/
         @(posedge tx_ready); //DATA HOLD 기다�?
         @(posedge tx_ready); //hold 진입 기다�?
         #50;
         i2c_start=0; i2c_stop=1; i2c_en=1;
         #50;
         i2c_en=0;
         #10;
         $finish;

     end

     I2C_Master DUT(.*);
     I2C_Slave U_Slave(.*);
 endmodule