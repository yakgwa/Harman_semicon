`include "uvm_macros.svh"
import uvm_pkg::*;

interface adder_intf (
    input logic clk,
    input logic reset
);
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface  //adder_intf

class a_seq_item extends uvm_sequence_item;
    rand bit [7:0] a;
    rand bit [7:0] b;
    bit [8:0] y;

    function new(input string name = "ITEM");
        super.new(name);
    endfunction  //new()

    `uvm_object_utils_begin(a_seq_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end

endclass  //a_seq_item extends uvm_sequence_item



class a_sequence extends uvm_sequence #(a_seq_item);
    `uvm_object_utils(a_sequence)

    a_seq_item a_item;

    function new(input string name = "SEQ");
        super.new(name);
    endfunction  //new()

    task body();
        a_item = a_seq_item::type_id::create("SEQ");
        for (int i = 0; i < 10; i++) begin
            start_item(a_item);
            if (!a_item.randomize()) `uvm_error("SEQ", "Randomize error");
            `uvm_info("SEQ", $sformatf(
                      "Data send to Driver a :%0d, b :0%d", a_item.a, a_item.b),
                      UVM_NONE)
            finish_item(a_item);
        end
    endtask  //body

endclass  //a_sequence extends uvm_sequnce #(a_seq_item)



class a_driver extends uvm_driver #(a_seq_item);
    `uvm_component_utils(a_driver)

    function new(input string name = "DRV", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    a_seq_item a_item;
    virtual adder_intf a_if;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_item = a_seq_item::type_id::create("ITEM");
        if (!uvm_config_db#(virtual adder_intf)::get(
                this, "", "a_if", a_if
            )) begin
            `uvm_fatal("DRV",
                       "Unable to access uvm_config_db");  //fatal = uvm 종료
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(a_item);
            @(posedge a_if.clk);
            a_if.a <= a_item.a;
            a_if.b <= a_item.b;
            @(posedge a_if.clk);
            `uvm_info("DRV", $sformatf(
                      "DRV send to DUT a: %.d, b:%0d, y:%0d",
                      a_item.a,
                      a_item.b,
                      a_item.y
                      ), UVM_NONE)
            @(posedge a_if.clk);
            seq_item_port.item_done();
        end
    endtask  //

endclass  //a_driver extends uvm_driver #(a_seq_item)

class a_monitor extends uvm_monitor;
    `uvm_component_utils(a_monitor)
    uvm_analysis_port #(a_seq_item) send;

    function new(input string name = "MON", uvm_component c);
        super.new(name, c);
        send = new("Write", this);
    endfunction  //new()

    a_seq_item a_item;
    virtual adder_intf a_if;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_item = a_seq_item::type_id::create("ITEM");
        if (!uvm_config_db#(virtual adder_intf)::get(
                this, "", "a_if", a_if
            )) begin
            `uvm_fatal("MON",
                       "Unable to access uvm_config_db");  //fatal = uvm 종료
        end
    endfunction

    task run_phase(uvm_phase phase);
        #10;
        forever begin
            @(posedge a_if.clk);
            a_item.a = a_if.a;
            a_item.b = a_if.b;
            @(posedge a_if.clk);
            a_item.y = a_if.y;
            `uvm_info("MON", $sformatf(
                      "Data send to Scoreboard a: %.d, b:%0d, y:%0d",
                      a_item.a,
                      a_item.b,
                      a_item.y
                      ), UVM_NONE)
            send.write(
                a_item); //Monitor send item to Scoreboard 뭐가 자꾸 특이하대
        end
    endtask
endclass  //a_monitor extendss


class a_agent extends uvm_agent;
    `uvm_component_utils(a_agent)
    function new(input string name = "AGENT", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    a_monitor a_mon;
    a_driver a_drv;
    uvm_sequencer #(a_seq_item) a_sqr;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_mon = a_monitor::type_id::create("MON", this);
        a_drv = a_driver::type_id::create("DRV", this);
        a_sqr = uvm_sequencer#(a_seq_item)::type_id::create("SQR", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a_drv.seq_item_port.connect(a_sqr.seq_item_export);
    endfunction
endclass  //a_agend extends superClass


class a_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(a_scoreboard)
    uvm_analysis_imp #(a_seq_item, a_scoreboard) recv;
    a_seq_item a_item;

    function new(input string name = "SCB", uvm_component c);
        super.new(name, c);
        recv = new("Read", this);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_item = a_seq_item::type_id::create("ITEM");
    endfunction

    function void write(input a_seq_item item);
        a_item = item;
        `uvm_info("SCB", $sformatf(
                  "Data receieve from Monitor a: %0d, b:%0d, y:%0d",
                  a_item.a,
                  a_item.b,
                  a_item.y
                  ), UVM_NONE)
        a_item.print(uvm_default_line_printer);
        if (a_item.y == (a_item.a + a_item.b)) begin
            `uvm_info("SCB", "Test Passed", UVM_NONE);
        end else begin
            `uvm_error("SCB", "Test Failed!")
        end
    endfunction

endclass  //a_scoreboard extendsuvm_scoreboards

class a_environment extends uvm_env;
    `uvm_component_utils(a_environment)

    function new(input string name = "ENV", uvm_component c);
        super.new(name,c);
    endfunction  //new()

    a_agent a_agt;
    a_scoreboard a_scb;

    function void build_phase(
        uvm_phase phase
    );  //first phase : build_phase에서 agt,scb 생성 -> agent로 이동해서 다음 phase 실행
        super.build_phase(phase);
        a_agt = a_agent::type_id::create("AGT", this);
        a_scb = a_scoreboard::type_id::create("SCB", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a_agt.a_mon.send.connect(
            a_scb.recv); //TLM 통신 방식 : agt->mon가 전송하면 scb가 수신
    endfunction

endclass  //a_environment extends uvm_env


class adder_test extends uvm_test;
    `uvm_component_utils(adder_test)

    function new(input string name = "ADDER_TEST", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    a_sequence   a_seq;
    a_environment a_env;
    //virtual을 붙히면 자식 class에서 내 method를 대신 할 수 있다
    //virtual을 사용하면 가상의 공간에서 자식 클래스에서 생성해서 새롭게 재사용가능
    //-> 재사용성이 높아짐(재정의)
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a_seq = a_sequence::type_id::create("SEQ", this);
        a_env = a_environment::type_id::create(
            "ENV", this);  //factory에서 생성 후 전달
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_root::get().print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);  //uvm_factory는 정지X
        a_seq.start(
            a_env.a_agt.a_sqr);  //seq가 시작신호를 주면 env->agent->sqr와 통신
        phase.drop_objection(this);  //생산 종료 -> STOP
        #20;
    endtask  //run_phasesrun_phase extends superClass
endclass

module tb_adder ();
    logic clk;
    logic reset;

    adder_intf a_if (
        clk,
        reset
    );


    adder dut (
        .clk(a_if.clk),
        .reset(a_if.reset),
        .a(a_if.a),
        .b(a_if.b),
        .y(a_if.y)
    );

    always #5 clk = ~clk;
    initial begin
        $fsdbDumpvars(0);
        $fsdbDumpfile("wave.fsdb");
        clk   = 0;
        reset = 1;
        #10 reset = 0;
    end

    initial begin
        uvm_config_db#(virtual adder_intf)::set(null, "*", "a_if", a_if);
        run_test("adder_test");
    end

endmodule


