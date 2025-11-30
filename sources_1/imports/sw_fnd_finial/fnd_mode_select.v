`timescale 1ns / 1ps

module fnd_mode_select(
    input      [1:0] current_active_mode, // 00: SW, 01: SR04, 10: DHT11
    input      [3:0] sw_fnd_com,
    input      [7:0] sw_fnd_data,
    input      [3:0] sr04_fnd_com,
    input      [7:0] sr04_fnd_data,
    input      [3:0] dht11_fnd_com,
    input      [7:0] dht11_fnd_data,
    output reg [3:0] fnd_com,
    output reg [7:0] fnd_data
);

    always @(*) begin
        case (current_active_mode)
            // 1. Stopwatch/Watch 모드일 때
            2'b00: begin
                fnd_com  = sw_fnd_com;
                fnd_data = sw_fnd_data;
            end
            // 2. SR04 모드일 때
            2'b01: begin
                fnd_com  = sr04_fnd_com;
                fnd_data = sr04_fnd_data;
            end
            // 3. DHT11 모드일 때
            2'b10: begin
                fnd_com  = dht11_fnd_com;
                fnd_data = dht11_fnd_data;
            end
            // 4. 그 외의 경우 (화면 끄기)
            default: begin
                fnd_com  = sw_fnd_com; // 모든 자리 비활성화
                fnd_data = sw_fnd_data;    // 모든 세그먼트 끄기
            end
        endcase
    end

endmodule