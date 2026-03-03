`timescale 1ns / 1ps

// ---------------------------------------------------------
// 1. Interface 정의
// ---------------------------------------------------------
interface cctv_top_if(input logic clk);
    logic reset;
    logic LED;
    logic xclk, pclk, href, vsync;
    logic [7:0] data;
    logic h_sync, v_sync;
    logic [3:0] r_port, g_port, b_port;
    logic rx, tx;
    logic save_btn;
    logic freeze_sw;

    // 카메라 데이터 주입용 (pclk 동기)
    clocking drv_cb @(posedge pclk);
        output href, vsync, data;
    endclocking
endinterface

// ---------------------------------------------------------
// 2. UVM Package
// ---------------------------------------------------------
package cctv_top_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // --- Transaction Item ---
    class cctv_item extends uvm_sequence_item;
        rand bit [7:0] pixel_data;
        rand bit       save_btn_press; // 버튼 누름 시나리오 트리거

        `uvm_object_utils_begin(cctv_item)
            `uvm_field_int(pixel_data, UVM_ALL_ON)
            `uvm_field_int(save_btn_press, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "cctv_item"); super.new(name); endfunction
    endclass

    typedef uvm_sequencer #(cctv_item) cctv_sequencer;

    // --- Sequence: 버튼 입력 시점 정의 ---
    class cctv_main_seq extends uvm_sequence #(cctv_item);
        `uvm_object_utils(cctv_main_seq)
        function new(string name = "cctv_main_seq"); super.new(name); endfunction

        virtual task body();
            int p_cnt = 0;
            repeat(4000) begin
                req = cctv_item::type_id::create("req");
                start_item(req);
                if(!req.randomize()) `uvm_error("SEQ", "Randomization failed")
                
                // 500번째 픽셀 전송 시점에서 save_btn을 누르는 상황 연출
                if (p_cnt == 500) req.save_btn_press = 1;
                else              req.save_btn_press = 0;

                // Red Tracker 인식을 위해 상위 5비트가 채워진 데이터 주입
                if($urandom_range(0,10) > 2) req.pixel_data = 8'hF8; 
                else                         req.pixel_data = 8'h00; 
                
                p_cnt++;
                finish_item(req);
            end
        endtask
    endclass

    // --- Driver: [버튼 감지] -> [RX 명령 주입] 루프 구현 ---
    class cctv_driver extends uvm_driver #(cctv_item);
        `uvm_component_utils(cctv_driver)
        virtual cctv_top_if vif;
        // 115,200 bps 기준 1비트 소요 시간 (약 8.68us)
        localparam real BIT_PERIOD = 8680.5; 

        function new(string name, uvm_component parent); super.new(name, parent); endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            void'(uvm_config_db#(virtual cctv_top_if)::get(this, "", "vif", vif));
        endfunction

        // UART 프로토콜에 맞춰 RX 핀을 흔들어주는 태스크
        task drive_uart_rx_packet(bit [7:0] cmd);
            `uvm_info("UART_DRV", $sformatf("Driving RX Command Packet: %h", cmd), UVM_LOW)
            vif.rx <= 0; // Start Bit
            #BIT_PERIOD;
            for (int i=0; i<8; i++) begin
                vif.rx <= cmd[i]; // Data Bits (LSB First)
                #BIT_PERIOD;
            end
            vif.rx <= 1; // Stop Bit
            #BIT_PERIOD;
        endtask

        virtual task run_phase(uvm_phase phase);
            // 초기 상태 설정
            vif.href = 0; vif.vsync = 0; vif.save_btn = 0; vif.rx = 1;
            
            forever begin
                vif.drv_cb.vsync <= 1;
                repeat(10) @(vif.drv_cb); 
                vif.drv_cb.vsync <= 0;
                repeat(10) @(vif.drv_cb); 

                for (int row = 0; row < 10; row++) begin
                    vif.drv_cb.href <= 1; 
                    for (int col = 0; col < 50; col++) begin
                        seq_item_port.get_next_item(req);
                        
                        // 1. 하드웨어 버튼 신호 인가
                        vif.save_btn <= req.save_btn_press;

                        // 2. 버튼이 눌리면(사용자 액션), 외부 장치(PC)가 RX로 전송 명령을 보내는 시나리오
                        if (req.save_btn_press) begin
                            `uvm_info("FLOW_DBG", "Save Button Detected! External PC sends RX command...", UVM_LOW)
                            fork 
                                drive_uart_rx_packet(8'hF8); // 전송 요청 커맨드(0xF8) 주입
                            join_none 
                        end

                        @(vif.drv_cb);
                        vif.drv_cb.data <= req.pixel_data;
                        seq_item_port.item_done();
                    end
                    vif.drv_cb.href <= 0; 
                    repeat(5) @(vif.drv_cb); 
                end
                repeat(100) @(vif.drv_cb);
            end
        endtask
    endclass

    // --- Monitor: TX 응답 시간 및 결과 감시 ---
    class cctv_monitor extends uvm_monitor;
        `uvm_component_utils(cctv_monitor)
        virtual cctv_top_if vif;
        function new(string name, uvm_component parent); super.new(name, parent); endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            void'(uvm_config_db#(virtual cctv_top_if)::get(this, "", "vif", vif));
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                @(posedge vif.clk);
                // TX 라인에서 데이터 전송 시작(Start Bit) 감지
                if (vif.tx == 0) begin
                    realtime start_time = $realtime;
                    `uvm_info("UART_MON", "UART TX Activity Detected! DUT is responding...", UVM_LOW)
                    wait(vif.tx == 1); // 전송 완료 대기
                    `uvm_info("UART_MON", $sformatf("UART TX Finished! Total Duration: %0t", $realtime - start_time), UVM_LOW)
                end
                
                // VGA 출력 조준선 감지 로직
                if ({vif.r_port, vif.g_port, vif.b_port} == 12'hF00) begin
                    `uvm_info("VGA_MON", "★★★ RED AIM BOX DETECTED ★★★", UVM_LOW)
                end
            end
        endtask
    endclass

    // Agent, Env 클래스
    class cctv_agent extends uvm_agent;
        `uvm_component_utils(cctv_agent)
        cctv_driver drv; cctv_monitor mon; cctv_sequencer sqr;
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
            // UART 1바이트 전송에 약 100us가 소요되므로 충분한 시간(2ms) 대기
            #2000000; 
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
    always #5 clk = ~clk;   // 100MHz
    always #20 pclk = ~pclk; // 25MHz

    cctv_top_if _if(clk);
    assign _if.pclk = pclk;

    // DUT 인스턴스
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
        _if.reset = 1; _if.rx = 1; _if.freeze_sw = 0; _if.save_btn = 0;
        #100; _if.reset = 0;
    end

    initial begin
        $fsdbDumpfile("cctv_top.fsdb");
        $fsdbDumpvars(0, tb_top);
    end
endmodule