module adder(
    input wire clk,
    input wire reset,
    input wire [7:0] a,
    input wire [7:0] b,
    output reg [8:0] y
    );

    always @(posedge clk or posedge reset) begin
        if(reset) y <= 0;
        else y <= a + b;     
    end

endmodule
