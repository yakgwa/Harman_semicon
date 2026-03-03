`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

// ==========================================================
// 0. Interface (Slave RTL 포트 4개 구성 유지)
// ==========================================================
interface i2c_if(input logic clk, input logic reset);
    logic [7:0] tx_data, rx_data;
    logic rx_done, tx_done, tx_ready, i2c_start, i2c_en, i2c_stop;
    tri1 SCL, SDA;
    
    // Slave Register Monitoring
    logic [7:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    assign (weak1, highz0) SCL = 1'b1;
    assign (weak1, highz0) SDA = 1'b1;
endinterface

typedef enum {I2C_WRITE, I2C_READ} i2c_rw_e;

// ==========================================================
// 1. Transaction & Sequence
// ==========================================================
class i2c_txn extends uvm_sequence_item;
    rand bit [7:0] addr;
    rand bit [7:0] data_q[$]; 
    rand i2c_rw_e rw_mode;
    `uvm_object_utils(i2c_txn)
    function new(string name="i2c_txn"); super.new(name); endfunction
endclass

class i2c_full_seq extends uvm_sequence #(i2c_txn);
    `uvm_object_utils(i2c_full_seq)
    function new(string name="i2c_full_seq"); super.new(name); endfunction

    task body();
        req = i2c_txn::type_id::create("req");

        // [1] Burst Write: 0x01, 0x02, 0x03, 0x04 순차 쓰기
        start_item(req);
        req.rw_mode = I2C_WRITE; req.addr = 8'hAA; 
        req.data_q = {8'h01, 8'h02, 8'h03, 8'h04}; 
        finish_item(req);
        #200000;

        // [2] Burst Read: 4바이트 연속 읽기
        start_item(req);
        req.rw_mode = I2C_READ; req.addr = 8'hAB; 
        finish_item(req);
        #200000;
    endtask
endclass

// ==========================================================
// 2. Master Driver (rx_done 핸드쉐이크 로직 적용)
// ==========================================================
class i2c_master_driver extends uvm_driver #(i2c_txn);
    `uvm_component_utils(i2c_master_driver)
    virtual i2c_if vif;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found!")
    endfunction
    
    task run_phase(uvm_phase phase);
        vif.i2c_en <= 0; vif.i2c_start <= 0; vif.i2c_stop <= 0;
        repeat(1000) @(posedge vif.clk);
        
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRV", "Transaction Started", UVM_MEDIUM)
            
            // --- [1] Address Phase ---
            wait(vif.tx_ready === 1'b1);
            vif.tx_data <= req.addr;
            vif.i2c_en <= 1'b1;
            repeat(10) @(posedge vif.clk);
            vif.i2c_start <= 1'b1; @(posedge vif.clk); vif.i2c_start <= 1'b0;
            
            wait(vif.tx_done === 1'b1);
            repeat(100) @(posedge vif.clk); 

            // --- [2] Data/Read Phase ---
            if (req.rw_mode == I2C_WRITE) begin
                foreach (req.data_q[i]) begin
                    wait(vif.tx_ready === 1'b1);
                    vif.tx_data <= req.data_q[i];
                    wait(vif.tx_done === 1'b1);
                    `uvm_info("DRV", $sformatf("Write [%0d]: 0x%h Done", i, req.data_q[i]), UVM_LOW)
                    repeat(1000) @(posedge vif.clk);
                end
                wait(vif.tx_ready === 1'b1);
                vif.i2c_stop <= 1'b1; repeat(2000) @(posedge vif.clk); vif.i2c_stop <= 1'b0;
            end 
            else begin
                // READ 진입 (DUT 특성에 따라 HOLD에서 START=1, STOP=1 동시 인가)
                wait(vif.tx_ready === 1'b1);
                vif.i2c_start <= 1'b1; vif.i2c_stop <= 1'b1;
                @(posedge vif.clk);
                vif.i2c_start <= 1'b0; vif.i2c_stop <= 1'b0;

                for (int i = 0; i < 4; i++) begin
                    // ✅ rx_done이 High가 될 때까지 대기 (데이터 수신 완료)
                    wait(vif.rx_done === 1'b1);
                    `uvm_info("DRV", $sformatf("Burst Read [%0d]: 0x%h", i, vif.rx_data), UVM_LOW)
                    
                    // ✅ [핵심] rx_done이 다시 Low가 될 때까지 대기 (중복 샘플링 방지)
                    // 마스터 IP가 READ_HOLD에서 READ_ACK로 상태를 완전히 바꿀 때까지 기다립니다.
                    wait(vif.rx_done === 1'b0);
                    
                    // 다음 바이트 처리를 위한 짧은 마진
                    repeat(10) @(posedge vif.clk); 
                end
            end

            vif.i2c_en <= 0;
            repeat(20000) @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
endclass

// ==========================================================
// 3. Scoreboard
// ==========================================================
class i2c_system_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_system_scoreboard)
    virtual i2c_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif));
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            wait(vif.rx_done === 1'b1);
            // 마지막 4번째 rx_done 이후 덤프
            repeat(100) @(posedge vif.clk); 
            
            if (vif.slv_reg0 == 8'h01 && vif.slv_reg1 == 8'h02 && 
                vif.slv_reg2 == 8'h03 && vif.slv_reg3 == 8'h04) begin
                `uvm_info("PASS", $sformatf("Burst Verified! Regs: 0x%h, 0x%h, 0x%h, 0x%h", 
                    vif.slv_reg0, vif.slv_reg1, vif.slv_reg2, vif.slv_reg3), UVM_LOW)
            end
            
            wait(vif.rx_done === 1'b0);
        end
    endtask
endclass

// ==========================================================
// 4. Env & Test
// ==========================================================
class i2c_env extends uvm_env;
    `uvm_component_utils(i2c_env)
    i2c_master_driver drv; i2c_system_scoreboard scb; uvm_sequencer #(i2c_txn) seqr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase); 
        drv = i2c_master_driver::type_id::create("drv", this);
        scb = i2c_system_scoreboard::type_id::create("scb", this);
        seqr = uvm_sequencer#(i2c_txn)::type_id::create("seqr", this);
    endfunction
    function void connect_phase(uvm_phase phase); drv.seq_item_port.connect(seqr.seq_item_export); endfunction
endclass

class i2c_full_test extends uvm_test;
    `uvm_component_utils(i2c_full_test)
    i2c_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase); super.build_phase(phase); env = i2c_env::type_id::create("env", this); endfunction
    task run_phase(uvm_phase phase);
        i2c_full_seq seq = i2c_full_seq::type_id::create("seq");
        phase.raise_objection(this); seq.start(env.seqr); #200000; phase.drop_objection(this);
    endtask
endclass

// ==========================================================
// 5. Top Module
// ==========================================================
module tb_top;
    bit clk, reset; always #5 clk = ~clk;
    initial begin reset = 0; #1000 reset = 1; end
    i2c_if vif(clk, reset);
    
    I2C_Master #(.FCOUNT(500)) master_u (
        .clk(vif.clk), .reset(vif.reset), .tx_data(vif.tx_data), 
        .rx_data(vif.rx_data), .rx_done(vif.rx_done), .tx_done(vif.tx_done), 
        .tx_ready(vif.tx_ready), .i2c_start(vif.i2c_start), 
        .i2c_en(vif.i2c_en), .i2c_stop(vif.i2c_stop), .SCL(vif.SCL), .SDA(vif.SDA)
    );

    I2C_Slave slave_u (
        .clk(vif.clk), .reset(vif.reset), .SCL(vif.SCL), .SDA(vif.SDA), 
        .slv_reg0(vif.slv_reg0), .slv_reg1(vif.slv_reg1), 
        .slv_reg2(vif.slv_reg2), .slv_reg3(vif.slv_reg3)
    );

    initial begin 
        uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", vif); 
        run_test("i2c_full_test"); 
    end
endmodule