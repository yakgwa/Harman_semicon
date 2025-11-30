interface top_interface;
    logic clk;
    logic rst;
    logic rx;
    logic start;
    logic clear;
    logic mode;
    logic [13:0] o_count;
endinterface

class transaction;
    //rand bit rx;
    rand bit [7:0] rx_data;
    bit start;
    bit clear;
    bit mode;
    bit [13:0] o_count;
    // bit [13:0] o_count_next;


    constraint c_rx_data {
        rx_data dist {
            "r" := 40,  
            "m" := 40,
            [0:255] := 20
        };
    }

    task display(string name);
        $display("%t:[%s] : rx = %h, o_count : %0d",
        $time, name, rx_data, o_count);
    endtask
endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) gen2scb_mbox;
    event gen_next_event;

    int total_count = 0;

    function new(mailbox #(transaction) gen2drv_mbox, mailbox #(transaction) gen2scb_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;

        this.gen_next_event = gen_next_event;
        this.gen2scb_mbox = gen2scb_mbox;
    endfunction


    // start(d -> 64), clear(r -> 72), mode(m -> 6d)
    task run(int count);
        repeat (count) begin
            total_count++;
            tr = new;
            tr.rx_data = 8'h64;

            // random stimulus
            assert(tr.randomize())
            else $display("Random Error!!!!");

            // start toggle
            if (total_count % 50 == 0) begin
                tr.rx_data = "d";  // start
            end

            // clear tick
            if (total_count % 100 == 0) begin
                tr.rx_data = "r";  // clear
            end

            // mode toggle
            if (total_count % 200 == 0) begin
                tr.rx_data = "m";  // mode
            end

            gen2drv_mbox.put(tr);
            gen2scb_mbox.put(tr);
            tr.display("[Gen]");
            #(10416*100);
            @(gen_next_event);
        end
    endtask
endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual top_interface top_interface_if;
    event mon_next_event;

    function new(mailbox #(transaction) gen2drv_mbox, virtual top_interface top_interface_if, event mon_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.top_interface_if = top_interface_if;
        this.mon_next_event = mon_next_event;
    endfunction

    task reset();
        top_interface_if.rst = 1;
        top_interface_if.rx = 1'b1;
        top_interface_if.start = 0;
        top_interface_if.clear = 0;
        top_interface_if.mode = 0;
        repeat(5) @(posedge top_interface_if.clk);
        top_interface_if.rst = 0;
        repeat(5) @(posedge top_interface_if.clk);
        $display("Reset done!");
    endtask

    // 9600 baud with a 100MHz clock (10ns period)
    localparam BAUD_RATE_DIVISOR = 100_000_000 / 9600;

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            $display("%t:[Drv] Transmitting data: %0h", $time, tr.rx_data);
            
            @(posedge top_interface_if.clk);
            
            top_interface_if.rx = 1'b0;
            repeat(BAUD_RATE_DIVISOR) @(posedge top_interface_if.clk);

            for (int i = 0; i < 8; i++) begin
                top_interface_if.rx = tr.rx_data[i];
                repeat(BAUD_RATE_DIVISOR) @(posedge top_interface_if.clk);
            end

            top_interface_if.rx = 1'b1;
            repeat(BAUD_RATE_DIVISOR) @(posedge top_interface_if.clk);
            
            -> mon_next_event;
        end
    endtask
endclass


// monitor, only actual value
class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual top_interface top_interface_if;
    event mon_next_event;

    // coverage
    covergroup cg;
        coverpoint tr.o_count {
            bins cnt_0      = {0};
            bins cnt_1_2500  = {[1:2500]};
            bins cnt_2501_5000 = {[2501:5000]};
            bins cnt_5001_7500 = {[5001:7500]};
            bins cnt_7501_10000 = {[7501:10000]};
        }

        coverpoint tr.rx_data {
            bins start = {"d"}; // start command
            bins clear = {"r"}; // clear command
            bins mode  = {"m"}; // mode command
            bins other = {[0:255]}; // other data
        }
    endgroup


    function new(mailbox #(transaction) mon2scb_mbox,
                virtual top_interface top_interface_if,
                event mon_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.top_interface_if = top_interface_if;
        this.mon_next_event = mon_next_event;
        cg = new();
    endfunction


    task run();
        forever begin
            @(mon_next_event);
            tr = new;
            tr.o_count = top_interface_if.o_count;

            tr.display("[Mon]"); 
            mon2scb_mbox.put(tr);
            cg.sample();    // functional coverage sample
        end
    endtask
endclass

class scoreboard;
    transaction expected_tr, actual_tr;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2scb_mbox;
    event gen_next_event;
    virtual top_interface top_interface_if;

    bit [13:0] expected_cnt;
    bit [13:0] actual_cnt;

    int passed_count = 0;
    int failed_count = 0;


    function new(
        mailbox #(transaction) gen2scb_mbox,
        mailbox #(transaction) mon2scb_mbox,
        event gen_next_event,
        virtual top_interface top_interface_if
    );
        this.gen2scb_mbox = gen2scb_mbox;
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
        this.top_interface_if = top_interface_if;
    endfunction

    // reference model for counter behavior
    function int counter_value(int prev_cnt, bit start, bit clear, bit mode);
        if (clear) return 0;
        if (!start) return prev_cnt;

        if (mode == 1'b0) begin
            // up-count
            return (prev_cnt == 10000) ? 0 : (prev_cnt + 1);
        end
        else begin
            // down-count
            return (prev_cnt == 0) ? 10000 : (prev_cnt - 1);
        end
    endfunction


    task run();
        forever begin
            gen2scb_mbox.get(expected_tr);

            expected_cnt = counter_value(
                expected_cnt, 
                expected_tr.start, 
                expected_tr.clear, 
                expected_tr.mode
            );

            mon2scb_mbox.get(actual_tr);

            if (actual_tr.o_count !== expected_cnt) begin
                failed_count++;
                $error("[%0t][SCB] MISMATCH exp=%0d act=%0d  (start=%0b clear=%0b mode=%0b)",
                       $time, expected_cnt, actual_tr.o_count,
                       expected_tr.start, expected_tr.clear, expected_tr.mode);
            end
            else begin
                passed_count++;
                $display("[%0t][SCB] MATCH    cnt=%0d  (P:%0d F:%0d)",
                         $time, expected_cnt, passed_count, failed_count);
            end
    
            -> gen_next_event;
        end
    endtask
endclass


class environment;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2scb_mbox;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    event gen_next_event;
    event mon_next_event;

    function new(virtual top_interface top_interface_if);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen2scb_mbox = new;
        gen = new(gen2drv_mbox, gen2scb_mbox, gen_next_event);
        drv = new(gen2drv_mbox, top_interface_if, mon_next_event);
        mon = new(mon2scb_mbox, top_interface_if, mon_next_event);
        scb = new(mon2scb_mbox, gen2scb_mbox, gen_next_event, top_interface_if);
    endfunction

    task report();
        $display("===================================");
        $display("=========== TEST REPORT ===========");
        $display("== Total Transactions: %0d ==", gen.total_count);
        $display("== PASS Count: %0d ==", scb.passed_count);
        $display("== FAIL Count: %0d ==", scb.failed_count);
        $display("===================================");
        $display("Functional coverage: %0.2f%%", mon.cg.get_coverage());
    endtask

    task run(int count);
        drv.reset();
        fork
            gen.run(count);
            drv.run();
            mon.run();
            scb.run(); 
        join_any
        report();
        $stop;
    endtask
endclass



module tb_inte_top_sv();
    top_interface top_interface_tb();
    environment env;

    logic clk = 0;

    inte_top dut(
        .clk(top_interface_tb.clk),
        .rst(top_interface_tb.rst),
        .rx(top_interface_tb.rx),
        .start(top_interface_tb.start),
        .clear(top_interface_tb.clear),
        .mode(top_interface_tb.mode),
        .o_count(top_interface_tb.o_count)
    );

    always #5 top_interface_tb.clk = ~top_interface_tb.clk;

    initial begin
        top_interface_tb.clk = 0;
        env = new(top_interface_tb);
        env.run(1000);
        // $coverage_save("cov_report.ucdb"); // Questa
    $stop;
    end
endmodule

// interface top_interface;
//     logic clk;
//     logic rst;
//     logic rx;
//     logic start;
//     logic clear;
//     logic mode;
//     logic [13:0] o_count;
// endinterface

// class transaction;
//     //rand bit rx;
//     rand bit [7:0] rx_data;
//     rand bit start;
//     rand bit clear;
//     rand bit mode;
//     bit [13:0] o_count;

//     constraint c_rx_data {
//         rx_data inside {8'b0110_0100};//{ 8'b0110_1101, 8'b0110_0100, 8'b0111_0010 };
//     }

//     task display(string name);
//         $display("%t:[%s] : rx = %h, o_count : %0d",
//         $time, name, rx_data, o_count);
//     endtask
// endclass

// class generator;
//     transaction tr;
//     mailbox #(transaction) gen2drv_mbox;
//     mailbox #(transaction) gen2scb_mbox;
//     event gen_next_event;

//     int total_count = 0;
//     bit sent_64 = 0;

//     function new(mailbox #(transaction) gen2drv_mbox, mailbox #(transaction) gen2scb_mbox, event gen_next_event);
//         this.gen2drv_mbox = gen2drv_mbox;
//         this.gen_next_event = gen_next_event;
//         this.gen2scb_mbox = gen2scb_mbox;
//     endfunction

//     task run(int count);
//         for (int i = 0; i < count; i++) begin
//             tr = new;
//             if (!sent_64) begin
//                 tr.rx_data = 8'h64; 
//                 sent_64 = 1;
//             end else if (i == 5) begin
//                 tr.rx_data = 8'h72; 
//             end else begin
//                 tr.rx_data = 8'hFF;
//             end
//             //assert(tr.randomize())
//             //else $display("Random Error!!!!");
//             gen2drv_mbox.put(tr);
//             gen2scb_mbox.put(tr);
//             tr.display("[Gen]");
//             #(10416*100);
//             @(gen_next_event);
//         end
//     endtask
// endclass

// class driver;
//     transaction tr;
//     mailbox #(transaction) gen2drv_mbox;
//     virtual top_interface top_interface_if;
//     event mon_next_event;

//     function new(mailbox #(transaction) gen2drv_mbox, virtual top_interface top_interface_if, event mon_next_event);
//         this.gen2drv_mbox = gen2drv_mbox;
//         this.top_interface_if = top_interface_if;
//         this.mon_next_event = mon_next_event;
//     endfunction

//     task reset();
//         top_interface_if.rst = 1;
//         top_interface_if.rx = 1'b1;
//         top_interface_if.start = 0;
//         top_interface_if.clear = 0;
//         top_interface_if.mode = 0;
//         repeat(5) @(posedge top_interface_if.clk);
//         top_interface_if.rst = 0;
//         repeat(5) @(posedge top_interface_if.clk);
//         $display("Reset done!");
//     endtask

//     // 9600 baud with a 100MHz clock (10ns period)
//     localparam BAUD_RATE_DIVISOR = 100_000_000 / 9600;

//     task run();
//         forever begin
//             gen2drv_mbox.get(tr);
//             $display("%t:[Drv] Transmitting data: %0h", $time, tr.rx_data);
            
//             @(posedge top_interface_if.clk);
            
//             top_interface_if.rx = 1'b0;
//             repeat(BAUD_RATE_DIVISOR) @(posedge top_interface_if.clk);

//             for (int i = 0; i < 8; i++) begin
//                 top_interface_if.rx = tr.rx_data[i];
//                 repeat(BAUD_RATE_DIVISOR) @(posedge top_interface_if.clk);
//             end

//             top_interface_if.rx = 1'b1;
//             repeat(BAUD_RATE_DIVISOR) @(posedge top_interface_if.clk);
            
//             -> mon_next_event;
//         end
//     endtask
// endclass



// class monitor;
//     transaction tr;
//     mailbox #(transaction) mon2scb_mbox;
//     virtual top_interface top_interface_if;
//     event mon_next_event;
    
//     function new(mailbox #(transaction) mon2scb_mbox, virtual top_interface top_interface_if
//     ,event mon_next_event);
//         this.mon2scb_mbox = mon2scb_mbox;
//         this.top_interface_if = top_interface_if;
//         this.mon_next_event = mon_next_event;
//     endfunction

//     task run();
//         forever begin
//             @(mon_next_event);
//             tr = new;
//             tr.o_count = top_interface_if.o_count;
//             tr.display("[Mon]"); 
//             mon2scb_mbox.put(tr);
//         end
//     endtask
// endclass

// class scoreboard;
//     transaction expected_tr, actual_tr;
//     mailbox #(transaction) mon2scb_mbox;
//     mailbox #(transaction) gen2scb_mbox;
//     event gen_next_event;

//     int counter_value = 0;
//     int error_count = 0;
//     logic [13:0] prev_o_count = 0;

//     virtual top_interface top_interface_if;

//     function new(
//         mailbox #(transaction) gen2scb_mbox,
//         mailbox #(transaction) mon2scb_mbox,
//         event gen_next_event,
//         virtual top_interface top_interface_if
//     );
//         this.gen2scb_mbox = gen2scb_mbox;
//         this.mon2scb_mbox = mon2scb_mbox;
//         this.gen_next_event = gen_next_event;
//         this.top_interface_if = top_interface_if;
//     endfunction

//     task run();
//         logic [13:0] current_o_count;
//         int time_cycle = 120_000_000;
//         int cycle = 0;

//         forever begin
//             mon2scb_mbox.get(actual_tr);
//             gen2scb_mbox.get(expected_tr);
//             do begin
//                 current_o_count = top_interface_if.o_count;
//                 if (current_o_count == prev_o_count + 1) begin
//                     counter_value++;
//                     $display("[SCB] PASS - o_count incremented : %0d -> %0d", prev_o_count, current_o_count);
//                     break;
//                 end

//             else if (expected_tr.rx_data == 8'h72) begin  // 0x72('r') 들어오면 o_count가 0이어야 함
//                 if (current_o_count == 0) begin
//                     //counter_value++;
//                     $display("[SCB] PASS - o_count cleared to 0 due to input 0x72");
//                     break;
//                 end
//             end

//                 @(posedge top_interface_if.clk);
//                 cycle++;
//             end while (cycle < time_cycle);

//             if (current_o_count == prev_o_count) begin
//                 error_count++;
//                 $display("[SCB] FAIL - o_count did not increment(stayed at: %0d)", current_o_count);
//             end

//             prev_o_count = current_o_count;
//             -> gen_next_event;
//         end
//     endtask
// endclass


// class environment;
//     transaction tr;
//     mailbox #(transaction) gen2drv_mbox;
//     mailbox #(transaction) mon2scb_mbox;
//     mailbox #(transaction) gen2scb_mbox;
//     generator gen;
//     driver drv;
//     monitor mon;
//     scoreboard scb;
//     event gen_next_event;
//     event mon_next_event;

//     function new(virtual top_interface top_interface_if);
//         gen2drv_mbox = new;
//         mon2scb_mbox = new;
//         gen2scb_mbox = new;
//         gen = new(gen2drv_mbox, gen2scb_mbox, gen_next_event);
//         drv = new(gen2drv_mbox, top_interface_if, mon_next_event);
//         mon = new(mon2scb_mbox, top_interface_if, mon_next_event);
//         scb = new(mon2scb_mbox, gen2scb_mbox, gen_next_event, top_interface_if);
//     endfunction

//     task report();
//         $display("===================================");
//         $display("=========== TEST REPORT ===========");
//         $display("== Total Transactions: %0d ==", gen.total_count);
//         $display("== PASS Count: %0d ==", scb.counter_value);
//         $display("== FAIL Count: %0d ==", scb.error_count);
//         $display("===================================");
//     endtask

//     task run(int count);
//         drv.reset();
//         fork
//             gen.run(count);
//             drv.run();
//             mon.run();
//             scb.run(); 
//         join
//         report();
//         $stop;
//     endtask
// endclass



// module tb_inte_top_sv();
//     top_interface top_interface_tb();
//     environment env;

//     logic clk = 0;

//     inte_top dut(
//         .clk(top_interface_tb.clk),
//         .rst(top_interface_tb.rst),
//         .rx(top_interface_tb.rx),
//         .start(top_interface_tb.start),
//         .clear(top_interface_tb.clear),
//         .mode(top_interface_tb.mode),
//         .o_count(top_interface_tb.o_count)
//     );

//     always #5 top_interface_tb.clk = ~top_interface_tb.clk;

//     initial begin
//          top_interface_tb.clk = 0;
//          env = new(top_interface_tb);
//          env.run(6);
//     end
// endmodule