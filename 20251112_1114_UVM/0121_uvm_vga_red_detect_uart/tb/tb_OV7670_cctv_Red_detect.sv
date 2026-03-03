`timescale 1ns / 1ps

// ---------------------------------------------------------
// 1. Interface 정의
// ---------------------------------------------------------
interface cctv_top_if(input logic clk);
    logic reset;
    logic LED;
    // OV7670 side
    logic xclk, pclk, href, vsync;
    logic [7:0] data;
    // VGA side
    logic h_sync, v_sync;
    logic [3:0] r_port, g_port, b_port;
    // PC/UART & Buttons
    logic rx, tx;
    logic save_btn;
    logic freeze_sw;

    // 카메라 데이터 주입용 (pclk 동기)
    clocking drv_cb @(posedge pclk);
        output href, vsync, data;
    endclocking

    // 출력 모니터링용 (clk 동기)
    clocking mon_cb @(posedge clk);
        input h_sync, v_sync, r_port, g_port, b_port, LED, tx;
    endclocking
endinterface

// ---------------------------------------------------------
// 2. UVM Package (Components & Sequences)
// ---------------------------------------------------------
package cctv_top_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // --- Transaction Item ---
    class cctv_item extends uvm_sequence_item;
        rand bit [7:0] pixel_data;
        rand bit       save_trigger;

        `uvm_object_utils_begin(cctv_item)
            `uvm_field_int(pixel_data, UVM_ALL_ON)
            `uvm_field_int(save_trigger, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "cctv_item"); super.new(name); endfunction
    endclass

    // --- Sequencer 정의 ---
    typedef uvm_sequencer #(cctv_item) cctv_sequencer;

    // --- Sequence ---
    class cctv_main_seq extends uvm_sequence #(cctv_item);
        `uvm_object_utils(cctv_main_seq)
        function new(string name = "cctv_main_seq"); super.new(name); endfunction

        virtual task body();
            // [수정] 감지 확률을 높이기 위해 반복 횟수와 빨간색 주입 조건 상향
            repeat(4000) begin
                req = cctv_item::type_id::create("req");
                start_item(req);
                if(!req.randomize()) `uvm_error("SEQ", "Randomization failed")
                
                // [수정] 8'hFF 주입: RGB565 상/하위 바이트 어디든 R 문턱값(20)을 확실히 넘김
                if($urandom_range(0,10) > 2) req.pixel_data = 8'hF8; 
                else                         req.pixel_data = 8'h00; 
                
                finish_item(req);
            end
        endtask
    endclass

    // --- Driver ---
    class cctv_driver extends uvm_driver #(cctv_item);
        `uvm_component_utils(cctv_driver)
        virtual cctv_top_if vif;

        function new(string name, uvm_component parent); super.new(name, parent); endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual cctv_top_if)::get(this, "", "vif", vif))
                `uvm_fatal("DRV", "vif not found")
        endfunction

        virtual task run_phase(uvm_phase phase);
            vif.href = 0; vif.vsync = 0; vif.save_btn = 0;
            
            forever begin
                // 1. 프레임 시작: VSYNC 발생
                vif.drv_cb.vsync <= 1;
                repeat(10) @(vif.drv_cb); 
                vif.drv_cb.vsync <= 0;
                repeat(10) @(vif.drv_cb); 

                // 2. 데이터 전송 (10 x 50 전송)
                for (int row = 0; row < 10; row++) begin
                    vif.drv_cb.href <= 1; 
                    for (int col = 0; col < 50; col++) begin
                        seq_item_port.get_next_item(req);
                        @(vif.drv_cb);
                        vif.drv_cb.data <= req.pixel_data;
                        vif.save_btn    <= req.save_trigger;
                        seq_item_port.item_done();
                    end
                    vif.drv_cb.href <= 0; 
                    repeat(5) @(vif.drv_cb); 
                end
                repeat(100) @(vif.drv_cb);
            end
        endtask
    endclass

    // --- Monitor ---
    class cctv_monitor extends uvm_monitor;
        `uvm_component_utils(cctv_monitor)
        virtual cctv_top_if vif;
        uvm_analysis_port #(cctv_item) ap;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            uvm_config_db#(virtual cctv_top_if)::get(this, "", "vif", vif);
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                @(posedge vif.clk);
                // [수정] 조준선 감지 시 눈에 띄게 별표 표시
                if ({vif.r_port, vif.g_port, vif.b_port} == 12'hF00) begin
                    `uvm_info("MON", "★★★ RED AIM BOX DETECTED AT VGA OUTPUT! ★★★", UVM_LOW)
                end
            end
        endtask
    endclass

    // Agent, Env 클래스는 동일 (생략 가능하나 구조 유지)
    class cctv_agent extends uvm_agent;
        `uvm_component_utils(cctv_agent)
        cctv_driver drv;
        cctv_monitor mon;
        cctv_sequencer sqr;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        virtual function void build_phase(uvm_phase phase);
            drv = cctv_driver::type_id::create("drv", this);
            mon = cctv_monitor::type_id::create("mon", this);
            sqr = cctv_sequencer::type_id::create("sqr", this);
        endfunction
        virtual function void connect_phase(uvm_phase phase);
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

    class cctv_env extends uvm_env;
        `uvm_component_utils(cctv_env)
        cctv_agent agt;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        virtual function void build_phase(uvm_phase phase);
            agt = cctv_agent::type_id::create("agt", this);
        endfunction
    endclass

    // --- Test ---
    class cctv_test extends uvm_test;
        `uvm_component_utils(cctv_test)
        cctv_env env;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction
        virtual function void build_phase(uvm_phase phase);
            env = cctv_env::type_id::create("env", this);
        endfunction
        virtual task run_phase(uvm_phase phase);
            cctv_main_seq seq = cctv_main_seq::type_id::create("seq");
            phase.raise_objection(this);
            seq.start(env.agt.sqr);
            // [수정] 드라이버가 최소 2~3프레임을 처리할 수 있도록 시간 대폭 연장
            #50000; 
            phase.drop_objection(this);
        endtask
    endclass
endpackage

// ---------------------------------------------------------
// 3. Testbench Top Module
// ---------------------------------------------------------
module tb_top;
    import uvm_pkg::*;
    import cctv_top_pkg::*;

    bit clk, pclk;
    always #5 clk = ~clk;   
    always #20 pclk = ~pclk; 

    cctv_top_if _if(clk);
    assign _if.pclk = pclk;

    OV7670_CCTV_TOP dut (
        .clk        (clk),
        .reset      (_if.reset),
        .LED        (_if.LED),
        .xclk       (_if.xclk),
        .pclk       (_if.pclk),
        .href       (_if.href),
        .vsync      (_if.vsync),
        .data       (_if.data),
        .h_sync     (_if.h_sync),
        .v_sync     (_if.v_sync),
        .r_port     (_if.r_port),
        .g_port     (_if.g_port),
        .b_port     (_if.b_port),
        .rx         (_if.rx),
        .tx         (_if.tx),
        .save_btn   (_if.save_btn),
        .freeze_sw  (_if.freeze_sw),
        .sda        (),
        .scl        ()
    );

    initial begin
        uvm_config_db#(virtual cctv_top_if)::set(null, "*", "vif", _if);
        run_test("cctv_test");
    end

    initial begin
        _if.reset = 1; 
        _if.rx = 1; 
        _if.freeze_sw = 0; 
        _if.save_btn = 0;
        #100; 
        _if.reset = 0;
    end

    initial begin
        $fsdbDumpfile("cctv_top.fsdb");
        $fsdbDumpvars(0, tb_top);
    end
endmodule