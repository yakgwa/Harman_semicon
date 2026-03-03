






`timescale 1ns / 1ps

module GameOverlay_4way #(
    parameter BOX_GRAY = 4'd10
) (
    input logic       DE,
    input logic [9:0] x,
    input logic [9:0] y,

    // FSM 입력
    input logic [2:0] fsm_state,
    input logic [1:0] region,
    input logic [1:0] result_type,
    input logic [2:0] round_cnt,     // 0~4
    input logic [4:0] round_result,  // 각 라운드 결과
    input logic [2:0] score,         // 총 점수

    // 최종 출력
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,
    output logic overlay_en
);

    //==========================================================
    // 타입 정의
    //==========================================================
    typedef logic [7:0] char_t;

    //==========================================================
    // 8x8 FONT (필요한 글자들)
    //==========================================================
    function automatic [7:0] font_row(input [7:0] ascii, input [2:0] row);
        unique case (ascii)
            // R (0x52)
            8'h52:
            case (row)
                0: font_row = 8'b11111100;
                1: font_row = 8'b10000100;
                2: font_row = 8'b10000100;
                3: font_row = 8'b11111100;
                4: font_row = 8'b10010000;
                5: font_row = 8'b10001000;
                6: font_row = 8'b10000100;
                7: font_row = 8'b00000000;
            endcase

            // E (0x45)
            8'h45:
            case (row)
                0: font_row = 8'b11111110;
                1: font_row = 8'b10000000;
                2: font_row = 8'b10000000;
                3: font_row = 8'b11111100;
                4: font_row = 8'b10000000;
                5: font_row = 8'b10000000;
                6: font_row = 8'b11111110;
                7: font_row = 8'b00000000;
            endcase

            // A (0x41)
            8'h41:
            case (row)
                0: font_row = 8'b01111100;
                1: font_row = 8'b10000010;
                2: font_row = 8'b10000010;
                3: font_row = 8'b11111110;
                4: font_row = 8'b10000010;
                5: font_row = 8'b10000010;
                6: font_row = 8'b10000010;
                7: font_row = 8'b00000000;
            endcase

            // D (0x44)
            8'h44:
            case (row)
                0: font_row = 8'b11111000;
                1: font_row = 8'b10000100;
                2: font_row = 8'b10000010;
                3: font_row = 8'b10000010;
                4: font_row = 8'b10000010;
                5: font_row = 8'b10000100;
                6: font_row = 8'b11111000;
                7: font_row = 8'b00000000;
            endcase

            // Y (0x59)
            8'h59:
            case (row)
                0: font_row = 8'b10000010;
                1: font_row = 8'b01000100;
                2: font_row = 8'b00101000;
                3: font_row = 8'b00010000;
                4: font_row = 8'b00010000;
                5: font_row = 8'b00010000;
                6: font_row = 8'b00010000;
                7: font_row = 8'b00000000;
            endcase

            // ? (0x3F)
            8'h3F:
            case (row)
                0: font_row = 8'b01111100;
                1: font_row = 8'b10000010;
                2: font_row = 8'b00000010;
                3: font_row = 8'b00001100;
                4: font_row = 8'b00010000;
                5: font_row = 8'b00000000;
                6: font_row = 8'b00010000;
                7: font_row = 8'b00000000;
            endcase

            // O (0x4F)
            8'h4F:
            case (row)
                0: font_row = 8'b01111100;
                1: font_row = 8'b10000010;
                2: font_row = 8'b10000010;
                3: font_row = 8'b10000010;
                4: font_row = 8'b10000010;
                5: font_row = 8'b10000010;
                6: font_row = 8'b01111100;
                7: font_row = 8'b00000000;
            endcase

            // U (0x55)
            8'h55:
            case (row)
                0: font_row = 8'b10000010;
                1: font_row = 8'b10000010;
                2: font_row = 8'b10000010;
                3: font_row = 8'b10000010;
                4: font_row = 8'b10000010;
                5: font_row = 8'b10000010;
                6: font_row = 8'b01111100;
                7: font_row = 8'b00000000;
            endcase

            // N (0x4E)
            8'h4E:
            case (row)
                0: font_row = 8'b11000010;
                1: font_row = 8'b11100010;
                2: font_row = 8'b10110010;
                3: font_row = 8'b10011010;
                4: font_row = 8'b10001110;
                5: font_row = 8'b10000110;
                6: font_row = 8'b10000010;
                7: font_row = 8'b00000000;
            endcase

            // L (0x4C)
            8'h4C:
            case (row)
                0: font_row = 8'b10000000;
                1: font_row = 8'b10000000;
                2: font_row = 8'b10000000;
                3: font_row = 8'b10000000;
                4: font_row = 8'b10000000;
                5: font_row = 8'b10000000;
                6: font_row = 8'b11111110;
                7: font_row = 8'b00000000;
            endcase

            // T (0x54)
            8'h54:
            case (row)
                0: font_row = 8'b11111110;
                1: font_row = 8'b00011000;
                2: font_row = 8'b00011000;
                3: font_row = 8'b00011000;
                4: font_row = 8'b00011000;
                5: font_row = 8'b00011000;
                6: font_row = 8'b00011000;
                7: font_row = 8'b00000000;
            endcase

            // B (0x42)
            8'h42:
            case (row)
                0: font_row = 8'b11111100;
                1: font_row = 8'b10000100;
                2: font_row = 8'b10000100;
                3: font_row = 8'b11111100;
                4: font_row = 8'b10000100;
                5: font_row = 8'b10000100;
                6: font_row = 8'b11111100;
                7: font_row = 8'b00000000;
            endcase

            // S (0x53)
            8'h53:
            case (row)
                0: font_row = 8'b01111100;
                1: font_row = 8'b10000000;
                2: font_row = 8'b10000000;
                3: font_row = 8'b01111100;
                4: font_row = 8'b00000010;
                5: font_row = 8'b00000010;
                6: font_row = 8'b11111100;
                7: font_row = 8'b00000000;
            endcase

            // C (0x43)
            8'h43:
            case (row)
                0: font_row = 8'b01111100;
                1: font_row = 8'b10000010;
                2: font_row = 8'b10000000;
                3: font_row = 8'b10000000;
                4: font_row = 8'b10000000;
                5: font_row = 8'b10000010;
                6: font_row = 8'b01111100;
                7: font_row = 8'b00000000;
            endcase

            // F (0x46)
            8'h46:
            case (row)
                0: font_row = 8'b11111110;
                1: font_row = 8'b10000000;
                2: font_row = 8'b10000000;
                3: font_row = 8'b11111100;
                4: font_row = 8'b10000000;
                5: font_row = 8'b10000000;
                6: font_row = 8'b10000000;
                7: font_row = 8'b00000000;
            endcase

            // I (0x49)
            8'h49:
            case (row)
                0: font_row = 8'b11111110;
                1: font_row = 8'b00011000;
                2: font_row = 8'b00011000;
                3: font_row = 8'b00011000;
                4: font_row = 8'b00011000;
                5: font_row = 8'b00011000;
                6: font_row = 8'b11111110;
                7: font_row = 8'b00000000;
            endcase

            // P (0x50)
            8'h50:
            case (row)
                0: font_row = 8'b11111100;
                1: font_row = 8'b10000100;
                2: font_row = 8'b10000100;
                3: font_row = 8'b11111100;
                4: font_row = 8'b10000000;
                5: font_row = 8'b10000000;
                6: font_row = 8'b10000000;
                7: font_row = 8'b00000000;
            endcase

            // 1 (0x31)
            8'h31:
            case (row)
                0: font_row = 8'b00010000;
                1: font_row = 8'b00110000;
                2: font_row = 8'b00010000;
                3: font_row = 8'b00010000;
                4: font_row = 8'b00010000;
                5: font_row = 8'b00010000;
                6: font_row = 8'b01111100;
                7: font_row = 8'b00000000;
            endcase

            // 2 (0x32)
            8'h32:
            case (row)
                0: font_row = 8'b01111100;
                1: font_row = 8'b10000010;
                2: font_row = 8'b00000010;
                3: font_row = 8'b00111100;
                4: font_row = 8'b01000000;
                5: font_row = 8'b10000000;
                6: font_row = 8'b11111110;
                7: font_row = 8'b00000000;
            endcase

            // 3 (0x33)
            8'h33:
            case (row)
                0: font_row = 8'b11111110;
                1: font_row = 8'b00000010;
                2: font_row = 8'b00000100;
                3: font_row = 8'b00011110;
                4: font_row = 8'b00000010;
                5: font_row = 8'b10000010;
                6: font_row = 8'b01111100;
                7: font_row = 8'b00000000;
            endcase

            // 4 (0x34)
            8'h34:
            case (row)
                0: font_row = 8'b00001100;
                1: font_row = 8'b00011100;
                2: font_row = 8'b00101100;
                3: font_row = 8'b01001100;
                4: font_row = 8'b11111110;
                5: font_row = 8'b00001100;
                6: font_row = 8'b00001100;
                7: font_row = 8'b00000000;
            endcase

            // 5 (0x35)
            8'h35:
            case (row)
                0: font_row = 8'b11111110;
                1: font_row = 8'b10000000;
                2: font_row = 8'b11111100;
                3: font_row = 8'b00000010;
                4: font_row = 8'b00000010;
                5: font_row = 8'b10000010;
                6: font_row = 8'b01111100;
                7: font_row = 8'b00000000;
            endcase

            default: font_row = 8'b00000000;
        endcase
    endfunction

    //==========================================================
    // 단일 문자 그리기
    //==========================================================
    function automatic logic draw_char(input char_t ascii, input [9:0] px,
                                       input [9:0] py);
        logic [7:0] row_bits;
        if (x >= px && x < px + 8 && y >= py && y < py + 8) begin
            row_bits  = font_row(ascii, y - py);
            draw_char = row_bits[7-(x-px)];
        end else begin
            draw_char = 1'b0;
        end
    endfunction

    //==========================================================
    // 단어별 전용 draw 함수들
    //==========================================================

    // "READY?"
    function automatic logic draw_READY();
        logic hit;
        hit = 1'b0;
        hit |= draw_char("R", 270, 220);
        hit |= draw_char("E", 278, 220);
        hit |= draw_char("A", 286, 220);
        hit |= draw_char("D", 294, 220);
        hit |= draw_char("Y", 302, 220);
        hit |= draw_char("?", 310, 220);
        return hit;
    endfunction

    // "ROUND"
    function automatic logic draw_ROUND(input [9:0] px, input [9:0] py);
        logic hit;
        hit = 1'b0;
        hit |= draw_char("R", px + 8 * 0, py);
        hit |= draw_char("O", px + 8 * 1, py);
        hit |= draw_char("U", px + 8 * 2, py);
        hit |= draw_char("N", px + 8 * 3, py);
        hit |= draw_char("D", px + 8 * 4, py);
        return hit;
    endfunction

    // 숫자 (1~5)
    function automatic logic draw_number(input [2:0] num, input [9:0] px,
                                         input [9:0] py);
        case (num)
            0: draw_number = draw_char("1", px, py);
            1: draw_number = draw_char("2", px, py);
            2: draw_number = draw_char("3", px, py);
            3: draw_number = draw_char("4", px, py);
            4: draw_number = draw_char("5", px, py);
            default: draw_number = 0;
        endcase
    endfunction

    // "LT"
    function automatic logic draw_LT(input [9:0] px, input [9:0] py);
        return draw_char("L", px, py) | draw_char("T", px + 8, py);
    endfunction

    // "LB"
    function automatic logic draw_LB(input [9:0] px, input [9:0] py);
        return draw_char("L", px, py) | draw_char("B", px + 8, py);
    endfunction

    // "RT"
    function automatic logic draw_RT(input [9:0] px, input [9:0] py);
        return draw_char("R", px, py) | draw_char("T", px + 8, py);
    endfunction

    // "RB"
    function automatic logic draw_RB(input [9:0] px, input [9:0] py);
        return draw_char("R", px, py) | draw_char("B", px + 8, py);
    endfunction

    // "success"
    function automatic logic draw_SUCCESS();
        logic hit;
        hit = 1'b0;
        hit |= draw_char("S", 250, 220);  // 소문자는 대문자 S 사용
        hit |= draw_char("U", 258, 220);
        hit |= draw_char("C", 266, 220);
        hit |= draw_char("C", 274, 220);
        hit |= draw_char("E", 282, 220);
        hit |= draw_char("S", 290, 220);
        hit |= draw_char("S", 298, 220);
        return hit;
    endfunction

    // "FAIL"
    function automatic logic draw_FAIL();
        logic hit;
        hit = 1'b0;
        hit |= draw_char("F", 285, 220);
        hit |= draw_char("A", 293, 220);
        hit |= draw_char("I", 301, 220);
        hit |= draw_char("L", 309, 220);
        return hit;
    endfunction



    // "LOSE" — 위치값 입력받는 버전
    function automatic logic draw_LOSE(input [9:0] px, input [9:0] py);
        logic hit;
        hit = 1'b0;
        hit |= draw_char("L", px + 8 * 0, py);
        hit |= draw_char("O", px + 8 * 1, py);
        hit |= draw_char("S", px + 8 * 2, py);
        hit |= draw_char("E", px + 8 * 3, py);
        return hit;
    endfunction



    // "pass"
    function automatic logic draw_PASS(input [9:0] px, input [9:0] py);
        logic hit;
        hit = 1'b0;
        hit |= draw_char("P", px + 8 * 0, py);
        hit |= draw_char("A", px + 8 * 1, py);
        hit |= draw_char("S", px + 8 * 2, py);
        hit |= draw_char("S", px + 8 * 3, py);
        return hit;
    endfunction

    // "scr"
    function automatic logic draw_SCR(input [9:0] px, input [9:0] py);
        logic hit;
        hit = 1'b0;
        hit |= draw_char("S", px + 8 * 0, py);
        hit |= draw_char("C", px + 8 * 1, py);
        hit |= draw_char("R", px + 8 * 2, py);
        return hit;
    endfunction

    //==========================================================
    // 박스 영역 검사
    //==========================================================
    function automatic logic in_rect(input [9:0] x_left, input [9:0] x_right,
                                     input [9:0] y_top, input [9:0] y_bottom);
        in_rect = (x >= x_left) && (x < x_right) &&
                  (y >= y_top)  && (y < y_bottom);
    endfunction

    // 박스 영역들
    logic in_ready_box;
    logic in_play_round_box;
    logic in_play_region_box;
    logic in_result_box;
    logic in_scoreboard_box;

    // // 4개 코너 박스
    // logic in_corner_LT, in_corner_RT, in_corner_LB, in_corner_RB;

    // assign in_ready_box       = in_rect(220, 420, 200, 260);
    // assign in_play_round_box  = in_rect(220, 380, 40, 80);
    // assign in_play_region_box = in_rect(200, 380, 90, 130);
    // assign in_result_box      = in_rect(220, 420, 200, 260);
    // assign in_scoreboard_box  = in_rect(180, 460, 120, 360);

    // ======================================
    // 깔끔하게 정리된 UI 사각형 정의
    // ======================================

    // READY (Top middle)
    assign in_ready_box       = in_rect(220, 420, 200, 260);

    // PLAY: ROUND box
    assign in_play_round_box  = in_rect(220, 380, 40, 80);

    // PLAY: REGION box
    assign in_play_region_box = in_rect(200, 380, 90, 130);

    // RESULT (Middle)
    assign in_result_box      = in_rect(220, 420, 200, 260);

    // SCOREBOARD (Large)
    assign in_scoreboard_box  = in_rect(180, 460, 120, 360);




    // // 4개 코너 (20x20 크기)
    // assign in_corner_LT       = in_rect(170, 190, 125, 145);
    // assign in_corner_RT       = in_rect(450, 470, 125, 145);
    // assign in_corner_LB       = in_rect(170, 190, 335, 355);
    // assign in_corner_RB       = in_rect(450, 470, 335, 355);

    //==========================================================
    // 메인 출력 로직
    //==========================================================
    always_comb begin
        overlay_en = 1'b0;
        r = 4'd0;
        g = 4'd0;
        b = 4'd0;

        if (DE) begin
            unique case (fsm_state)

                // ================= IDLE / READY ===================
                3'b000, 3'b001: begin  // IDLE or READY
                    // 회색 박스
                    if (in_ready_box) begin
                        overlay_en = 1'b1;
                        r = BOX_GRAY;
                        g = BOX_GRAY;
                        b = BOX_GRAY;
                    end

                    // "READY?" 텍스트
                    if (draw_READY()) begin
                        overlay_en = 1'b1;
                        r = 4'd0;
                        g = 4'd15;
                        b = 4'd0;  // 초록
                    end

                    // 4개 코너
                    // if (in_corner_LT || in_corner_RT || in_corner_LB || in_corner_RB) begin
                    //     overlay_en = 1'b1;
                    //     r = 4'd15;
                    //     g = 4'd15;
                    //     b = 4'd15;
                    // end
                end

                // ================= PLAY ====================
                3'b010: begin
                    // ROUND 박스
                    if (in_play_round_box) begin
                        overlay_en = 1'b1;
                        r = BOX_GRAY;
                        g = BOX_GRAY;
                        b = BOX_GRAY;
                    end

                    // "ROUND X" 텍스트
                    if (draw_ROUND(
                            250, 50
                        ) || draw_number(
                            round_cnt, 290, 50
                        )) begin
                        overlay_en = 1'b1;
                        r = 4'd15;
                        g = 4'd15;
                        b = 4'd15;
                    end

                    // Region 박스
                    if (in_play_region_box) begin
                        overlay_en = 1'b1;
                        r = BOX_GRAY;
                        g = BOX_GRAY;
                        b = BOX_GRAY;
                    end

                    // Region 텍스트 (LT/LB/RT/RB)
                    unique case (region)
                        2'd0:
                        if (draw_LT(270, 100)) begin
                            overlay_en = 1'b1;
                            r = 4'd15;
                            g = 4'd15;
                            b = 4'd15;
                        end
                        2'd1:
                        if (draw_RT(270, 100)) begin
                            overlay_en = 1'b1;
                            r = 4'd15;
                            g = 4'd15;
                            b = 4'd15;
                        end
                        2'd2:
                        if (draw_LB(270, 100)) begin
                            overlay_en = 1'b1;
                            r = 4'd15;
                            g = 4'd15;
                            b = 4'd15;
                        end
                        2'd3:
                        if (draw_RB(270, 100)) begin
                            overlay_en = 1'b1;
                            r = 4'd15;
                            g = 4'd15;
                            b = 4'd15;
                        end
                    endcase

                    // // 4개 코너
                    // if (in_corner_LT || in_corner_RT || in_corner_LB || in_corner_RB) begin
                    //     overlay_en = 1'b1;
                    //     r = 4'd15;
                    //     g = 4'd15;
                    //     b = 4'd15;
                    // end
                end

                // ================= ROUND_END ==================
                3'b011: begin
                    // 회색 박스
                    if (in_result_box) begin
                        overlay_en = 1'b1;
                        r = BOX_GRAY;
                        g = BOX_GRAY;
                        b = BOX_GRAY;
                    end

                    // SUCCESS / FAIL 텍스트
                    if (result_type == 2'b01) begin  // SUCCESS
                        if (draw_SUCCESS()) begin
                            overlay_en = 1'b1;
                            r = 4'd0;
                            g = 4'd15;
                            b = 4'd0;  // 파랑
                        end
                    end else if (result_type == 2'b10) begin  // FAIL
                        if (draw_FAIL()) begin
                            overlay_en = 1'b1;
                            r = 4'd15;
                            g = 4'd0;
                            b = 4'd0;  // 빨강
                        end
                    end




                    // // 4개 코너
                    // if (in_corner_LT || in_corner_RT || in_corner_LB || in_corner_RB) begin
                    //     overlay_en = 1'b1;
                    //     r = 4'd15;
                    //     g = 4'd15;
                    //     b = 4'd15;
                    // end
                end

                // ================= SCOREBOARD ===============
                3'b100: begin
                    // 큰 회색 박스
                    if (in_scoreboard_box) begin
                        overlay_en = 1'b1;
                        r = BOX_GRAY;
                        g = BOX_GRAY;
                        b = BOX_GRAY;
                    end

                    // "scr" 제목
                    if (draw_SCR(290, 140)) begin
                        overlay_en = 1'b1;
                        r = 4'd15;
                        g = 4'd15;
                        b = 4'd15;
                    end

                    // 각 라운드 결과 (5줄)
                    for (int i = 0; i < 5; i++) begin
                        int base_y;
                        base_y = 170 + i * 35;

                        // "ROUND X"
                        if (draw_ROUND(
                                200, base_y[9:0]
                            ) || draw_number(
                                i[2:0], 240, base_y[9:0]
                            )) begin
                            overlay_en = 1'b1;
                            r = 4'd15;
                            g = 4'd15;
                            b = 4'd15;
                        end

                        // "pass" or "FAIL"
                        if (round_result[i]) begin
                            if (draw_PASS(250, base_y[9:0])) begin
                                overlay_en = 1'b1;
                                r = 4'd0;
                                g = 4'd15;
                                b = 4'd0;  // 초록
                            end
                        end else begin
                            if (draw_LOSE(
                                    250, base_y[9:0]
                                )) begin  // 위치 조정 필요
                                overlay_en = 1'b1;
                                r = 4'd15;
                                g = 4'd0;
                                b = 4'd0;  // 빨강
                            end
                        end
                    end

                    // // 4개 코너
                    // if (in_corner_LT || in_corner_RT || in_corner_LB || in_corner_RB) begin
                    //     overlay_en = 1'b1;
                    //     r = 4'd15;
                    //     g = 4'd15;
                    //     b = 4'd15;
                    // end
                end

                // default: begin
                //     // 4개 코너만 표시
                //     if (in_corner_LT || in_corner_RT || in_corner_LB || in_corner_RB) begin
                //         overlay_en = 1'b1;
                //         r = 4'd15;
                //         g = 4'd15;
                //         b = 4'd15;
                //     end
                // end
            endcase
        end
    end

endmodule
