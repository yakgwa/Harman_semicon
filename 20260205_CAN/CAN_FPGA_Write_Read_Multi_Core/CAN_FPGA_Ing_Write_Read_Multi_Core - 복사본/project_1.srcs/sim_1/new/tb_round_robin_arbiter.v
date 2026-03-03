`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/05 18:01:32
// Design Name: 
// Module Name: tb_round_robin_arbiter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_round_robin_arbiter();

reg clk;
reg rst_n;
reg [3:0] REQ;
wire [3:0] GNT;

round_robin_arbiter rra (
    .clk   (clk),
    .rst_n (rst_n),
    .REQ   (REQ),
    .GNT   (GNT) 
);

// 100MHz 클럭 생성
always #5 clk = ~clk;

initial begin
    // 1. 초기화 및 리셋
    clk = 1'b0; rst_n = 1'b0; REQ = 4'b0000;
    #15 rst_n = 1'b1; // 리셋 해제
    #10;
    
    // 2. 모든 노드가 동시에 요청 (우선순위: 0 > 1 > 2 > 3 예상)
    $display("[%0t] ALL NODES REQUEST (4'b1111)", $time);
    REQ = 4'b1111;  
    #20; // Node 0이 GNT를 잡고 있는 상태

    // 3. Node 0 종료 -> Node 1 승인 예상
    $display("[%0t] Node 0 FINISHED -> Expect GNT[1]", $time);
    REQ = 4'b1110; 
    #20;

    // 4. Node 1 종료 -> Node 2 승인 예상
    $display("[%0t] Node 1 FINISHED -> Expect GNT[2]", $time);
    REQ = 4'b1100;
    #20;

    // 5. Node 2 종료 -> Node 3 승인 예상
    $display("[%0t] Node 2 FINISHED -> Expect GNT[3]", $time);
    REQ = 4'b1000;
    #20;

    // 6. Node 3 종료 -> 모든 GNT 해제 예상
    $display("[%0t] Node 3 FINISHED -> Expect GNT=0", $time);
    REQ = 4'b0000;
    #20;

    // 7. 다시 Node 2, 3이 요청 -> Node 2 승인 예상
    $display("[%0t] Node 2, 3 REQUEST -> Expect GNT[2]", $time);
    REQ = 4'b1100;
    #20;

    // 8. Node 2 점유 중 Node 0이 끼어듦 -> 여전히 Node 2가 점유해야 함 (Hold 테스트)
    $display("[%0t] Node 0 REQUEST during Node 2 Working -> GNT[2] must stay", $time);
    REQ = 4'b1101; 
    #30;

    // 9. Node 2 종료 -> Round Robin에 의해 Node 3이 먼저인가 Node 0이 먼저인가 확인
    $display("[%0t] Node 2 FINISHED -> Check next priority", $time);
    REQ = 4'b1001; 
    #40;

    $display("[%0t] Simulation Finished.", $time);
    $finish;
end

initial begin
    $dumpfile ("dump.vcd");
    $dumpvars();
end

endmodule