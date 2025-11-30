`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 14:23:13
// Design Name: 
// Module Name: counter
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

// module counter(
//     input clk,
//     input rst,
//     input i_tick,
//     output [3:0] o_count
//     );

//     reg [3:0] r_counter;

//     assign o_count = r_counter;

//     always @(posedge clk or posedge rst) begin
//         if(rst) begin
//             r_counter <= 0;
//         end else begin
//             if(i_tick) begin
//                 r_counter <= r_counter + 1;
//                 if(r_counter == 9) begin
//                     r_counter <= 0;
//                 end
//             end
//         end
//     end

// endmodule

// module counter(
//     input clk,
//     input rst,
//     input i_tick,
//     input mode,
//     output [13:0] o_count
//     );

//     reg [13:0] r_counter;

//     assign o_count = r_counter;

//     always @(posedge clk or posedge rst) begin
//         if(rst) begin
//             r_counter <= 0;
//         end else begin
//             if(i_tick) begin
//                 if(!mode) begin
//                     if(r_counter == 10000 - 1) begin
//                         r_counter <= 0;
//                     end else begin
//                             r_counter <= r_counter + 1;
//                     end
//                 end else begin
//                     if(r_counter == 0) begin
//                         r_counter <= 9999;
//                     end else begin
//                             r_counter <= r_counter - 1;
//                     end   
//                 end                 
//             end
//         end
//     end
    

// endmodule

module counter(
   input clk,
   input rst,
  input i_tick,
   output [13:0] o_count,
   input i_mode,
   input i_clear
   );

   reg [13:0] r_counter;

   assign o_count = r_counter;

  always @(posedge clk or posedge rst) begin
       if(rst | i_clear) begin
           r_counter <= 0;
       end else begin
           if(i_tick) begin
            if(i_mode) begin
                r_counter <= r_counter - 1;
                if(r_counter == 0) begin
                    r_counter <= 9999;
                end
            end else begin
               r_counter <= r_counter + 1;
               if(r_counter == 10000 - 1) begin
                   r_counter <= 0;  
               end              
            end
       end
   end
  end

//   always @(posedge clk or posedge rst) begin
//        if(rst | i_clear) begin
//            r_counter <= 0;
//        end else begin
//            if(i_tick) begin
//             if(~i_mode) begin
//                r_counter <= r_counter + 1;
//                if(r_counter == 10000 - 1) begin
//                    r_counter <= 0;
//                end
//             end else begin
//                 r_counter <= r_counter - 1;
//                 if(r_counter == 0) begin
//                     r_counter <= 9999;
//                 end
//             end
//             r_counter <= r_counter + 1;
//        end
//    end
//   end

endmodule
