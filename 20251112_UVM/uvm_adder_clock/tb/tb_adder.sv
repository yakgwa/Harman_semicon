`include "uvm_macros.svh"
import uvm_pkg::*;

interface adder_intf(
    input logic clk,
    input logic reset
);
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface

class a_seq_item extends uvm_sequence_item;

    rand bit [7:0] a;
    rand bit [7:0] b;
    bit      [8:0] y;

    function new(input string name = "ITEM");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(a_seq_item) // item을 factory에 등록
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end
endclass

class a_sequence extends uvm_sequence #(a_seq_item);
    `uvm_component_utils(a_sequence)

    function new(input string name = "SEQ");
        super.new(name);
    endfunction

    task body();
        a_seq_item a_item;
        a_item = a_seq_item::type_id::create("ITEM", this);
        for (int i = 0; i < 10; i++) begin
            start_item(a_item);
            if(!a_item.randomize()) `uvm_error("SEQ","Randomize error");
            `uvm_error("SEQ", $sformatf("Data send to Driver a : %0d, b : %0d", a_item.a, a_item.b, UVM_NONE))
            finish_item(a_item);
        end
    endtask


endclass

class a_driver extends uvm_driver #(a_seq_item);
    `uvm_component_utils(a_driver)

    function new(input string name = "DRV", uvm_component c);
        super.new(name , c);
    endfunction

    a_seq_item a_item;
    virtual adder_intf a_if; 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_item = a_seq_item::type_id::create("ITEM");
        if(!uvm_config_db#(virtual adder_intf)::get(this, "", "a_if", a_if)) begin
            `uvm_fatal("DRV", "Unable to access uvm_config_db");
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(a_item);
            @(posedge a_if.clk);
            a_if.a <= a_item.a;
            a_if.b <= a_item.b;
                        `uvm_info("DRV",$sformatf("Data send to Scoreboard a : %0d, b : %0d", a_item.a, a_item.b),UVM_NONE)
            @(posedge a_if.clk);
            seq_item_port.item_done();
        end
    endtask //ss
endclass

class a_monitor extends uvm_monitor;
    `uvm_component_utils(a_monitor)
    uvm_analysis_port #(a_seq_item) send;// scb와 연결 포트

    function new(input string name = "MON", uvm_component c);
        super.new(name, c);
        send = new("Write", this);
    endfunction //new()

    a_seq_item a_item;
    virtual adder_intf a_if; // interface

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_item = a_seq_item::type_id::create("ITEM");
        if(!uvm_config_db#(virtual adder_intf)::get(this, "", "a_if", a_if)) begin
            `uvm_fatal("MON", "Unable to access uvm_config_db");
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge a_if.clk);
            a_item.a = a_if.a;
            a_item.b = a_if.b;
            @(posedge a_if.clk);
            a_item.y = a_if.y;
            `uvm_info("MON",$sformatf("Data send to Scoreboard a : %0d, b : %0d, y : %0d", a_item.a, a_item.b, a_item.y),UVM_NONE)
            send.write(a_item); // MON send item to scoreboard
        end
    endtask

endclass

class a_agent extends uvm_agent;
    `uvm_component_utils(a_agent)

    function new(input string name = "AGT", uvm_component c);
        super.new(name, c);
    endfunction //new()

    a_monitor a_mon;
    a_driver a_drv;
    uvm_sequencer #(a_seq_item) a_sqr;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_mon = a_monitor::type_id::create("MON", this);
        a_drv = a_driver::type_id::create("DRV", this);
        a_sqr = uvm_sequencer::type_id::create("SQR", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a_drv.seq_item_port.connect(a_sqr.seq_item_export); // agent가 sequencer & Driver 연결

    endfunction

endclass

class a_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(a_scoreboard)
    uvm_analysis_imp #(a_seq_item, a_scoreboard) recv; // Data 송수신 통로
    a_seq_item a_item;// Data Handler

    function new(input string name = "SCB", uvm_component c);
        super.new(name, c);
        recv = new("Read", this); // new에서 생성함
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_item = a_seq_item::type_id::create("ITEM");
    endfunction

    function void write(input a_seq_item item); // MON에서 던져주는 item
        a_item = item;
        `uvm_info("SCB", $sformatf("Data Received from Monitor a : %0d, b : %0d, y : %0d,", a_item.a, a_item.b, a_item.y),UVM_NONE)
    
        if(a_item.y == (a_item.a + a_item.b)) begin
           `uvm_info("SCB","PASEED",UVM_NONE)
        end
        else begin
           `uvm_error("SCB","FAILED")
        end
    endfunction

// MON & SCB를 이용한 Data 송수신



endclass //a_scoreboard extends uvm_scoreboard

class a_environment extends uvm_env;
    `uvm_component_utils(a_environment)
    function new(input string name = "ENV", uvm_component c);
        super.new(name, c);
    endfunction //new()

    a_agent a_agt;
    a_scoreboard a_scb;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_agt = a_agent::type_id::create("AGT", this);
        a_scb = a_scoreboard::type_id::create("SCB", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a_agt.a_mon.send.connect(a_scb.recv); // agent's mon의 uvm 내부 기능인 send와 scb의 recv는 연결 // TLM 통신 방식
    endfunction

endclass //a_environment extends superClass

class adder_test extends uvm_test;
    `uvm_component_utils(adder_test) // factory에 class 등록
    function new(input string name = "ADDER_TEST", uvm_component c);
        super.new(name, c); // super = 부모 class에 알려주는 것
    endfunction //new()

    a_sequence a_seq;
    a_environment a_env; // test class가 env와 seqence make

    virtual function void build_phase(uvm_phase phase); // virtual은 자식 class에 내 매소드를 변경시킬 수 있다는 의미(재정의)
        super.build_phase(phase);                       // Method를 넘겨줄 필요가 없으면 virtual 빼도 됨
        a_seq = a_sequence::type_id::create("SEQ",this); // instance 생성 및 Handler(a_seq)에 전달
        a_env = a_environment::type_id::create("ENV",this); // 원래 new에서 만드는 거지만 factory가 만들어서 만든 값을 return
    endfunction

    function void start_of_simulation_phase(vum_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_root::get().print_topology();
    endfunction

    task run_phase(uvm_phase phase); // run phase는 Process를 생성하며(fork join) 하며 class 내부의 run phase를 동시에 실행
        phase.raise_objection(phase); // uvm factory는 동작을 멈추지 마!
        a_seq.start(a_env.a_agt.a_sqr); // env안 agent안 sequencer와 연결
        #10;
        phase.drop_objection(phase); // 생산 다했어. 멈춰도 돼
    endtask // phase에는 build, run, cleanup이 있는데 준비 동작 동작완료후로 보면 됨
            // phase는 Factory에 실행 순서를 의미함

endclass 

module tb_adder();
    logic clk;
    logic reset;

    adder_intf a_if(
        .clk(a_if.clk),
        .reset(a_if.reset)       
    );

    adder dut(
        .a(a_if.a),
        .b(a_if.b),
        .y(a_if.y)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
    end

    initial begin
        uvm_config_db#(virtual adder_intf)::set(null, "*", "a_if", a_if);
        run_test("adder_test");
    end

endmodule