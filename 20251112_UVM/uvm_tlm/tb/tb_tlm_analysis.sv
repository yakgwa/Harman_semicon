`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
    rand logic write;
    rand logic [31:0] addr;
    rand logic [31:0] wdata;

    function new(string name = "TRANS");
        super.new(name);
    endfunction

    constraint adder_c{
        addr < 100;
    }

    `uvm_object_utils_begin(transaction)
        `uvm_field_int(write, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_DEFAULT)
        `uvm_field_int(wdata, UVM_DEFAULT)
    `uvm_object_utils_end

endclass  //item


class comp_d extends uvm_component;
    `uvm_component_utils(comp_d)

    uvm_analysis_imp #(transaction, comp_d) recv;

    function new(string name = "COM_D", uvm_component c);
        super.new(name, c);

    endfunction  //new()
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("COMP_D_RECV", this);
    endfunction

    function void write(transaction t);
        `uvm_info("COMP_D", $sformatf(
                  "send data: write = %0h, addr = %0h, wdata= %0h", t.write, t.addr, t.wdata),
                  UVM_NONE);
        t.print(uvm_default_line_printer);
    endfunction

endclass  //comp_a extends uvm_component



class comp_c extends uvm_component;
    `uvm_component_utils(comp_c)

    uvm_analysis_imp #(transaction, comp_c) recv;

    function new(string name = "COM_C", uvm_component c);
        super.new(name, c);

    endfunction  //new()
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("COMP_C_RECV", this);
    endfunction

    function void write(transaction t);
        `uvm_info("COMP_C", $sformatf(
                  "send data: write = %0h, addr = %0h, wdata= %0h", t.write, t.addr, t.wdata),
                  UVM_NONE);
    endfunction

endclass  //comp_a extends uvm_component

class comp_b extends uvm_component;
    `uvm_component_utils(comp_b)

    uvm_analysis_imp #(transaction, comp_b) recv;

    function new(string name = "COM_B", uvm_component c);
        super.new(name, c);

    endfunction  //new()
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("COMP_B_RECV", this);
    endfunction

    function void write(transaction t);
        `uvm_info("COMP_B", $sformatf(
                  "send data: write = %0h, addr = %0h, wdata= %0h", t.write, t.addr, t.wdata),
                  UVM_NONE);
    endfunction

endclass  //comp_a extends uvm_component

class comp_a extends uvm_component;
    `uvm_component_utils(comp_a)

    uvm_analysis_port #(transaction) send;

    transaction t;

    function new(string name = "COM_A", uvm_component c);
        super.new(name, c);
        send = new("send", this);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        t = new();
    endfunction
      
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        for (int i = 0; i < 10; i++) begin
            t.randomize();
            `uvm_info("COMP_A", $sformatf(
                      "send data: write = %0h, addr = %0h, wdata= %0h", t.write, t.addr, t.wdata),
                      UVM_NONE);
            send.write(t);
            t.print(uvm_default_line_printer);
        end
        phase.drop_objection(this);
    endtask
     

endclass  //comp_a extends uvm_component

class env extends uvm_component;
    `uvm_component_utils(env)
    comp_a a;
    comp_b b;
    comp_c c;
    comp_d d;


    function new(string name = "ENV", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a = comp_a::type_id::create("COMP_A", this);
        b = comp_b::type_id::create("COMP_B", this);
        c = comp_c::type_id::create("COMP_C", this);
        d = comp_d::type_id::create("COMP_D", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.send.connect(b.recv);
        a.send.connect(c.recv);
        a.send.connect(d.recv);
    endfunction


endclass  //comp_a extends uvm_component





class test extends uvm_test;
    `uvm_component_utils(test)

    env e;
    function new(string name = "TEST", uvm_component c);
        super.new(name, c);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e = env::type_id::create("ENV", this);
    endfunction


    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_root::get().print_topology();
    endfunction

endclass  //test extends uvm_test


module tb_tlm ();

    initial begin
        run_test();
    end


endmodule
