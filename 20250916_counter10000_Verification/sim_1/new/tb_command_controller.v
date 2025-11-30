`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/15 17:33:26
// Design Name: 
// Module Name: tb_command_controller
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


// `timescale 1ns/1ps

// module command_controller_tb;

//   // Inputs
//   reg clk = 0;
//   reg reset;
//   reg [7:0] rx_fifo_data;
//   reg rx_trigger;
//   reg i_btn;

//   // Outputs
//   wire o_pop;
//   wire o_start;
//   wire o_clear;
//   wire o_mode;

//   // DUT instantiation
//   command_controller_1 dut (
//     .clk(clk),
//     .reset(reset),
//     .rx_fifo_data(rx_fifo_data),
//     .rx_trigger(rx_trigger),
//     .i_btn(i_btn),
//     .o_pop(o_pop),
//     .o_start(o_start),
//     .o_clear(o_clear),
//     .o_mode(o_mode)
//   );

//   // Clock generation
//   always #5 clk = ~clk;

//   // Task: apply rx input
//   task apply_rx;
//     input [7:0] data;
//     begin
//       rx_fifo_data = data;
//       rx_trigger = 1;
//       #10;
//       rx_trigger = 0;
//       #10;
//     end
//   endtask

//   // Task: simulate button press
//   task press_button;
//     begin
//       i_btn = 1;
//       #10;
//       i_btn = 0;
//       #10;
//     end
//   endtask

//   initial begin
//     $display("==== TEST START ====");
    
//     // Initialize inputs
//     rx_fifo_data = 8'h00;
//     rx_trigger = 0;
//     i_btn = 0;
//     reset = 1;

//     #20;
//     reset = 0;
//     #20;

//     // --- Test 1: Send 'd' (0x64) ---
//     $display("Test 1: Sending 'd'...");
//     apply_rx(8'h64);
//     if (o_start !== 1)
//       $display("FAIL: o_start not asserted on 'd'");
//     else
//       $display("PASS: o_start asserted on 'd'");

//     #10;
//     if (o_start !== 0)
//       $display("FAIL: o_start not de-asserted after 1 cycle");
//     else
//       $display("PASS: o_start de-asserted");

//     // --- Test 2: Send 'r' (0x72) ---
//     $display("Test 2: Sending 'r'...");
//     apply_rx(8'h72);
//     if (o_clear !== 1)
//       $display("FAIL: o_clear not asserted on 'r'");
//     else
//       $display("PASS: o_clear asserted on 'r'");

//     #10;
//     if (o_clear !== 0)
//       $display("FAIL: o_clear not de-asserted after 1 cycle");
//     else
//       $display("PASS: o_clear de-asserted");

//     // --- Test 3: Send 'm' (0x6D) to toggle o_mode ---
//     $display("Test 3: Sending 'm'...");
//     reg prev_mode;
//     prev_mode = o_mode;

//     apply_rx(8'h6D);
//     #10;
//     if (o_mode === ~prev_mode)
//       $display("PASS: o_mode toggled on 'm'");
//     else
//       $display("FAIL: o_mode did not toggle on 'm'");

//     // --- Test 4: Button press to toggle o_mode ---
//     $display("Test 4: Button press...");
//     prev_mode = o_mode;
//     press_button();
//     #10;
//     if (o_mode === ~prev_mode)
//       $display("PASS: o_mode toggled on button press");
//     else
//       $display("FAIL: o_mode did not toggle on button press");

//     $display("==== TEST END ====");
//     $finish;
//   end

// endmodule