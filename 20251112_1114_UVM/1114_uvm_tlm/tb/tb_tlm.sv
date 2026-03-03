`include "uvm_macros.svh"
import uvm_pkg::*;

class comp_a extends uvm_component;
    `uvm_component_utils(comp_a)

    uvm_blocking_put_port #(int) send;

    rand int data;

    function new(string name = "COMP_A", uvm_component c);
        super.new(name , c);
        send = new("send", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        for (int i = 0; i < 10; i++) begin
            this.randomize();
            `uvm_info("COMP_A", $sformatf("int data = %0h", data), UVM_NONE)
            send.put(data);
        end
        phase.drop_objection(this);
    endtask

endclass

class comp_b extends uvm_component;
    `uvm_component_utils(comp_b)

    uvm_blocking_put_imp #(int, comp_b) recv;

    function new(string name = "COMP_B", uvm_component c);
        super.new(name , c);
        recv = new("RECV", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

    task put (int data);
        `uvm_info("COMP_B", $sformatf("Received data = %0h", data), UVM_NONE)
    endtask


endclass

class env extends uvm_env;
    `uvm_component_utils(env)

    comp_a a;
    comp_b b;

    function new(string name = "ENV", uvm_component c);
        super.new(name , c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a = comp_a::type_id::create("COMP_A", this);
        b = comp_b::type_id::create("COMP_B", this);
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.send.connect(b.recv); // a & b connect
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

class test extends uvm_test;
    `uvm_component_utils(test)

    env e;

    function new(string name = "TEST", uvm_component c);
        super.new(name , c);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e = env::type_id::create("ENV", this);
    endfunction    

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_root::get().print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass

module tb_tlm();

    initial begin
        run_test("test");
    end

endmodule