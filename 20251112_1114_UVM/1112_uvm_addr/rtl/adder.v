module adder(
 input  wire [7:0] a,
 input  wire [7:0] b,
 output wire [8:0] y
);

 assign y = a + b;

endmodule
