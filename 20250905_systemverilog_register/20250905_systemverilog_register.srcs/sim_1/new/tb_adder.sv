`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/05 13:36:27
// Design Name: 
// Module Name: tb_adder
// Project Name: 
// Target Devices: 
// Tool Versions: S
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
interface adder_interface;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] sum;
    logic carry;
    
endinterface //adder_interface

class transaction;
    rand bit [31:0] a;
    rand bit [31:0] b;
    rand bit [31:0] sum;
    rand bit carry;
endclass //transaction

class generator;
    // virtual : 메모리에 실체화 시킬거다라는 의미
    virtual adder_interface adder_if;
    transaction tr;
    // for communication with external class when this class instance
    function new(virtual adder_interface adder_interf);
        this.adder_if = adder_interf;
        tr = new(); // tr을 생성하라는 의미, class가 생성될 때 같이 생성
        // 정적할당은 항상 메모리에 있는 것. new는 동적할당.
        // 생성시켜주는 class member 함수, this는 class 안 나 자신.
        // 가상으로 있으니까 너랑 붙여줘! 너 = testbench의 Interface
    endfunction

    task run (int count); // generation & drive
        repeat(count) begin
            // random generator
            tr.randomize(); // 제공하는 member함수

            //
            adder_if.a = tr.a; // adder_interface의 a에 tr에서 만든 값을 넣어줘. 생성된 random value 전달 // drive
            adder_if.b = tr.b;
            #10; // 시간 10ns : 왜 ns? Timescale이 1ns
        end
        
    endtask //run

endclass //generator


module tb_adder();
    /// sw를 testbench에 올리자!
    // interface adder_interface를 adder_interface_tb 이름으로 실체화됨
    adder_interface adder_interface_tb(); 
    // class generator handler(아직 실체화되지 않음. 실체화 시키기 위한 handler)
    generator gen;
    // new를 했을 때 실체화

    adder dut(
        .a(adder_interface_tb.a),
        .b(adder_interface_tb.b),
        .sum(adder_interface_tb.sum),
        .carry(adder_interface_tb.carry)
    );

    initial begin
        gen = new(adder_interface_tb);
        gen.run(100); // run 인자가 없으므로 비워둠

    end

endmodule
