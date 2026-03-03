`timescale 1ns / 1ps

module tb_fpga_top();
    reg clk; 
    reg btnC; 
    reg sw_send;
    wire [7:0] led;
    
    // 외부에서 들어오는 rx 신호를 시뮬레이션하기 위한 변수
    reg rx_ext; 

    // DUT 인스턴스
    fpga_top uut (
        .clk(clk),
        .btnC(btnC),
        .sw_send(sw_send),
        .led(led)
    );

    // 실제 rx_i 핀에 외부 신호(rx_ext)를 연결
    // 이 assign은 블록(initial) 밖에 위치해야 합니다.
    assign uut.i_can_node.rx_i = rx_ext;

    // 100MHz 클럭 생성
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // 1. 초기화: 실제 보드에 전원을 넣은 상태
        btnC = 1; 
        sw_send = 0;
        rx_ext = 1; // CAN 버스는 평소에 High(Recessive) 상태입니다.

        #1000;
        btnC = 0; // 리셋 해제
        $display("[%0t] Reset Released - HW Booting...", $time);
        
        // 2. [Natural Wait] 실제 FPGA처럼 IP가 스스로 준비될 때까지 대기
        // force 없이 내부 카운터가 올라가야 하므로 시간이 좀 걸립니다.
        // IP가 Bus-Off Recovery를 마칠 때까지 충분히 기다립니다.
        $display("[%0t] Waiting for IP Internal Initialization (No Force)...", $time);
        #5000000; // 5ms 대기 (실제 하드웨어의 부팅 시간)

        // 3. 사용자 이벤트: 버튼을 누름
        sw_send = 1; 
        $display("[%0t] USER EVENT: sw_send ON", $time);
        
        #100000; // 100us 후 버튼 뗌
        sw_send = 0;
        $display("[%0t] USER EVENT: sw_send OFF", $time);

        #10000000; // 10ms 동안 관찰
        $display("[%0t] Simulation Finished.", $time);
        $stop;
    end

    // --- [자동 ACK 응답 로직] ---
    // 실제 상대방 CAN 노드가 메시지를 받고 응답하는 물리적 동작 재현
    initial begin
        forever begin
            // 송신자가 데이터를 쏘기 시작(SOF)할 때까지 대기
            wait(uut.can_tx == 0 && btnC == 0); 
            
            // 전송 중간(ACK Slot)까지 시간 대기 (Baudrate 625k 기준)
            #115000; 

            // 외부 노드가 RX를 0으로 당겨서 ACK 응답을 줌
            rx_ext = 0; 
            #1600;      // 1비트 시간 유지
            rx_ext = 1; // 다시 Recessive로 복구
            
            $display("[%0t] >>> [EXTERNAL NODE] ACK GENERATED!", $time);
            
            #100000; // 다음 프레임 전송 전까지 여유 대기
        end
    end

endmodule

//`timescale 1ns / 1ps

//module tb_fpga_top();
//    reg clk; reg btnC; reg sw_send;
//    wire [7:0] led;

//    fpga_top uut (.clk(clk), .btnC(btnC), .sw_send(sw_send), .led(led));

//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk;
//    end

//    initial begin
//        // 1. 초기화
//        btnC = 1; sw_send = 0;
//        force uut.i_can_node.rx_i = 1'b1; 

//        #1000;
//        btnC = 0; 
//        $display("[%0t] Reset Released", $time);
        
//        #2000000; // 초기화 대기

//        // 2. Bus-free Jump
//        force uut.i_can_node.i_can_bsp.bus_free_cnt = 4'd15; 
//        #1000;
//        release uut.i_can_node.i_can_bsp.bus_free_cnt;

//        #5000000; // 안정화 대기

//        // 3. 송신 시작 (펄스 형태)
//        sw_send = 1; 
//        $display("[%0t] sw_send ON", $time);
//        #5000;      // FSM이 인지하기 충분한 시간
//        sw_send = 0; // ★ 스위치를 뗌 (이제 FSM은 Step 11 Polling에 집중함)
//        $display("[%0t] sw_send OFF", $time);
        
//        release uut.i_can_node.rx_i;

//        #10000000; 
//        $stop;
//    end
    
    // --- can_tx 모니터링 로직 수정 ---
//    reg can_tx_prev;
//    always @(posedge clk) can_tx_prev <= uut.can_tx;

//    initial begin
//        forever @(uut.can_tx) begin
//            // sw_send 조건 삭제: 스위치를 떼어도 송신은 계속되므로!
//            if (!btnC) begin
//                if (can_tx_prev == 1'b1 && uut.can_tx == 1'b0) begin
//                    $display("[%0t] >>> [MONITOR] START OF FRAME (SOF) DETECTED!", $time);
//                end
//                $display("[%0t] >>> [PIN WATCH] can_tx pin value: %b", $time, uut.can_tx);
//            end
//        end
//    end
//endmodule