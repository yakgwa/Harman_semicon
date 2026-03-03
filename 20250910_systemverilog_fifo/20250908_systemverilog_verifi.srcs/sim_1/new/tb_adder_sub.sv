`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/08 10:44:21
// Design Name: 
// Module Name: tb_adder_sub
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

// interface
interface adder_sub_intf;
    logic [7:0] a;
    logic [7:0] b;
    logic mode;
    logic [7:0] sum;
    logic carry;
endinterface

// transaction(for random value)
class transaction;
// stimulus list
    rand bit [7:0] a; // randomize를 해주면 나중에 random 값이 자동으로 생성
    rand bit [7:0] b; // rand : 랜덤값을 생성하기 위한 변수를 지정하는데 사용하는 keyword
    rand bit mode;
endclass //transaction

// generator : stimulus 생성 객체
class generator;
    // transaction handle : tr
    transaction tr; 

    //generator는 put을 해서 data를 보내고 transcation할 data를 가지고 있다가 driver는 get을 해서 data를 처리
    //gen2drv_mbox는 generator에서 driver로 보내는 통신 box(buffer, 객체)
    mailbox #(transaction/*transaction 할 datatype */) gen2drv_mbox;
    function new(mailbox #(transaction) gen2drv_mbox_arg); // 시스템베릴로그 합성기가 new를 만나면 메모리에 할당
        this.gen2drv_mbox = gen2drv_mbox_arg; //gen2drv_mbox_arg를 받아와서 나 자신에 있는 gen2drv_mbox에 연결
    endfunction //new()

    task run (int count);
        repeat(count) begin
            tr = new;       // class transaction tr을 동적 할당. 키워드는 키워드인데 함수로 동작하는거라 new뒤에 괄호가 있어도 없어도 상관 없음
            tr.randomize(); // transaction내의 rand 키워드를 가진 변수는 random값을 생성시켜주는 멤버함수
            gen2drv_mbox.put(tr); // generator가 transaction tr로 동적 할당한 후 mail_box를 통해 driver에게 전달(주소, 포인터 전달)
            //#10;
        end
    endtask //run
endclass //generator

class driver;

    // adder_sub_intf 인터페이스 객체의 adder_sub_if 이름의 가상으로 인스턴스를 정의
    virtual adder_sub_intf adder_sub_if; 
    mailbox #(transaction) gen2drv_mbox; // data를 가져오기 위한 mailbox

    // adder_sub_if 객체타입
    function new(mailbox #(transaction) gen2drv_mbox_arg, virtual adder_sub_intf add_sub_if_drv_arg); // 연결
        this.adder_sub_if = add_sub_if_drv_arg; // new가 실행될 때 재정의
        this.gen2drv_mbox = gen2drv_mbox_arg;
    endfunction //new()

    task run ();
        // generator에서 동적할당된 transcation tr을 바다아오기 위한 handler
        forever begin
            transaction tr_driver;
            gen2drv_mbox.get(tr_driver);
            adder_sub_if.a = tr_driver.a;
            adder_sub_if.b = tr_driver.b;
            adder_sub_if.mode = tr_driver.mode;
            #10;
        end
    endtask //run

    task reset();
        adder_sub_if.a = 0;
        adder_sub_if.b = 0;  
        adder_sub_if.mode = 0;    
        #10;
    endtask //reset

endclass //driver

// 전체 test 환경을 관리
class environment;

    // handle 생성
    generator gen;
    driver drv;
    mailbox #(transaction) gen2drv_mbox;

    function new(virtual adder_sub_intf adder_sub_env_arg);
        gen2drv_mbox = new;
        gen = new(gen2drv_mbox); // gen2drv_mbox은 인자
        drv = new(gen2drv_mbox, adder_sub_env_arg);
    endfunction // new()

    task run();
        drv.reset();
        fork
            gen.run(10);
            drv.run();
        join_none // 누군가 하나 끝나면 Task 종료
        #50;
        $stop;
    endtask //run
endclass

module tb_adder_sub();
    // Handle of class environment 
    environment env; 
    adder_sub_intf adder_sub_interface();

    adder dut(
        .a(adder_sub_interface.a),
        .b(adder_sub_interface.b),
        .mode(adder_sub_interface.mode),
        .sum(adder_sub_interface.sum),
        .carry(adder_sub_interface.carry)
    );

    initial begin
        env = new(adder_sub_interface);
        env.run();
    end

endmodule
