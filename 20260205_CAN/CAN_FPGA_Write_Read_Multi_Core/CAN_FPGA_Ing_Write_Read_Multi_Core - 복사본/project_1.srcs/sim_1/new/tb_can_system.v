`timescale 1ns / 1ps

module tb_can_system();
    reg clk; reg rst; reg [3:0] btn_send_bus;
    wire can_tx; reg rx_ext;

    can_system_top uut (
        .clk(clk), .rst(rst),
        .btn_send_bus(btn_send_bus),
        .can_tx_phys(can_tx),
        .can_rx_phys(rx_ext)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        rst = 1; btn_send_bus = 0; rx_ext = 1;
        #1000; rst = 0;
        $display("[%0t] [TB] System Reset Released.", $time);
        
        #500000; 
        $display("[%0t] [TB] ALL NODES START REQUESTING...", $time);
        btn_send_bus = 4'b1111; 
        
        // 충분한 시간 대기
        #20000000; 
        $stop;
    end

    // 자동 ACK 생성기 로그 보강
    initial begin
        forever begin
            wait(can_tx == 0 && rst == 0);
            $display("[%0t] [TB_BUS] CAN Frame Start Detected...", $time);
            #115000; 
            rx_ext = 0; #2000; rx_ext = 1; 
            $display("[%0t] [TB_BUS] >>> ACK SENT to Bus", $time);
            #300000; 
        end
    end
endmodule