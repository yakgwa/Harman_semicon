





// `timescale 1ns/1ps
// module MiniGameFSM_4way(
//     input  logic clk,
//     input  logic reset,
//     input  logic start,
//     input  logic vsync,

//     input  logic detect_LT,
//     input  logic detect_RT,
//     input  logic detect_LB,
//     input  logic detect_RB,

//     output logic [1:0] region,
//     output logic success,
//     output logic fail,
//     output logic game_over,

//     output logic pass_LT,
//     output logic pass_RT,
//     output logic pass_LB,
//     output logic pass_RB
// );

//     typedef enum logic [1:0] { IDLE, READY, PLAY, GAMEOVER } state_t;
//     state_t state, next_state;

//     //---------------------------------------------------------
//     // vsync rising edge
//     //---------------------------------------------------------
//     logic vs_d, vs_rise;
//     always_ff @(posedge clk) begin
//         vs_d    <= vsync;
//         vs_rise <= vsync & ~vs_d;
//     end

//     //---------------------------------------------------------
//     // detect latch (frame-based input)
//     //---------------------------------------------------------
//     logic LT_d, RT_d, LB_d, RB_d;
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             LT_d <= 0; RT_d <= 0; LB_d <= 0; RB_d <= 0;
//         end
//         else if (vs_rise) begin
//             LT_d <= detect_LT;
//             RT_d <= detect_RT;
//             LB_d <= detect_LB;
//             RB_d <= detect_RB;
//         end
//     end

//     //---------------------------------------------------------
//     // LFSR random
//     //---------------------------------------------------------
//     logic [7:0] lfsr;
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset)
//             lfsr <= 8'hA5;
//         else if (vs_rise)
//             lfsr <= {lfsr[6:0], ^(lfsr & 8'hB8)};
//     end

//     //---------------------------------------------------------
//     // counters
//     //---------------------------------------------------------
//     logic [7:0] hold_cnt;
//     logic [7:0] timeout_cnt;
//     logic [3:0] skip_frames;

//     //---------------------------------------------------------
//     // per-frame logic values
//     //---------------------------------------------------------
//     logic is_detected;
//     logic correct;

//     //---------------------------------------------------------
//     // State register
//     //---------------------------------------------------------
//     always_ff @(posedge clk or posedge reset) begin
//         if(reset)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

//     //---------------------------------------------------------
//     // Next State
//     //---------------------------------------------------------
//     always_comb begin
//         next_state = state;
//         case(state)
//             IDLE:
//                 if(start) next_state = READY;

//             READY:
//                 if(vs_rise) next_state = PLAY;

//             PLAY:
//                 if(fail) next_state = GAMEOVER;
//                 else if(success) next_state = READY;

//             GAMEOVER:
//                 if(start) next_state = READY;
//         endcase
//     end

//     //---------------------------------------------------------
//     // OUTPUT + FSM Behavior
//     //---------------------------------------------------------
//     always_ff @(posedge clk or posedge reset) begin
//         if(reset) begin
//             region <= 0;
//             success <= 0;
//             fail <= 0;
//             game_over <= 0;
//             hold_cnt <= 0;
//             timeout_cnt <= 0;
//             skip_frames <= 0;

//             pass_LT <= 0;
//             pass_RT <= 0;
//             pass_LB <= 0;
//             pass_RB <= 0;
//         end
//         else begin

//             // 기본 PASS 표시 리셋
//             pass_LT <= 0;
//             pass_RT <= 0;
//             pass_LB <= 0;
//             pass_RB <= 0;
//             success <= 0;
//             fail    <= 0;

//             case(state)

//                 //-----------------------------------------------------
//                 // READY
//                 //-----------------------------------------------------
//                 READY: begin
//                     if(vs_rise) begin
//                         region <= lfsr % 4;
//                         hold_cnt <= 0;
//                         timeout_cnt <= 0;
//                         skip_frames <= 8;
//                     end
//                 end

//                 //-----------------------------------------------------
//                 // PLAY
//                 //-----------------------------------------------------
//                 PLAY: begin
//                     if(vs_rise) begin

//                         if(skip_frames != 0) begin
//                             skip_frames <= skip_frames - 1;
//                         end
//                         else begin
//                             is_detected =
//                                 LT_d | RT_d | LB_d | RB_d;

//                             correct =
//                                 (region==0 && LT_d && !(RT_d|LB_d|RB_d)) ||
//                                 (region==1 && RT_d && !(LT_d|LB_d|RB_d)) ||
//                                 (region==2 && LB_d && !(LT_d|RT_d|RB_d)) ||
//                                 (region==3 && RB_d && !(LT_d|RT_d|LB_d));

//                             timeout_cnt <= timeout_cnt + 1;

//                             if(correct)
//                                 hold_cnt <= hold_cnt + 1;
//                             else
//                                 hold_cnt <= 0;

//                             if(hold_cnt >= 15)
//                                 success <= 1;

//                             if(timeout_cnt >= 200)
//                                 fail <= 1;

//                             //---------------------------------------------------
//                             // PASS 신호 업데이트 (Overlay 용)
//                             //---------------------------------------------------
//                             pass_LT <= (region==0) ? correct : 0;
//                             pass_RT <= (region==1) ? correct : 0;
//                             pass_LB <= (region==2) ? correct : 0;
//                             pass_RB <= (region==3) ? correct : 0;
//                         end

//                         // 다음 라운드
//                         if(success) begin
//                             region <= lfsr % 4;
//                             hold_cnt <= 0;
//                             timeout_cnt <= 0;
//                             skip_frames <= 8;
//                         end
//                     end
//                 end

//                 //-----------------------------------------------------
//                 // GAMEOVER
//                 //-----------------------------------------------------
//                 GAMEOVER: begin
//                     fail <= 1;
//                     game_over <= 1;
//                 end

//             endcase
//         end
//     end

// endmodule








// `timescale 1ns/1ps
// module MiniGameFSM_4way(
//     input  logic clk,
//     input  logic reset,
//     input  logic start,
//     input  logic vsync,

//     input  logic detect_LT,
//     input  logic detect_RT,
//     input  logic detect_LB,
//     input  logic detect_RB,

//     output logic [1:0] region,
//     output logic success,
//     output logic fail,
//     output logic game_over,

//     // PASS → Overlay 표시용
//     output logic pass_LT,
//     output logic pass_RT,
//     output logic pass_LB,
//     output logic pass_RB
// );

//     typedef enum logic [1:0] { IDLE, READY, PLAY, GAMEOVER } state_t;
//     state_t state, next_state;

//     //---------------------------------------------------------
//     // vsync edge detect
//     //---------------------------------------------------------
//     logic vs_d, vs_rise;
//     always_ff @(posedge clk) begin
//         vs_d    <= vsync;
//         vs_rise <= vsync & ~vs_d;
//     end

//     //---------------------------------------------------------
//     // detect latch (frame-based)
//     //---------------------------------------------------------
//     logic LT_d, RT_d, LB_d, RB_d;
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             LT_d <= 0; RT_d <= 0; LB_d <= 0; RB_d <= 0;
//         end
//         else if (vs_rise) begin
//             LT_d <= detect_LT;
//             RT_d <= detect_RT;
//             LB_d <= detect_LB;
//             RB_d <= detect_RB;
//         end
//     end

//     //---------------------------------------------------------
//     // LFSR (랜덤 region)
//     //---------------------------------------------------------
//     logic [7:0] lfsr;
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset)
//             lfsr <= 8'hA5;
//         else if (vs_rise)
//             lfsr <= {lfsr[6:0], ^(lfsr & 8'hB8)};
//     end

//     //---------------------------------------------------------
//     // counters
//     //---------------------------------------------------------
//     logic [7:0] hold_cnt;
//     logic [7:0] timeout_cnt;
//     logic [3:0] skip_frames;

//     logic correct;

//     //---------------------------------------------------------
//     // State register
//     //---------------------------------------------------------
//     always_ff @(posedge clk or posedge reset) begin
//         if(reset)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

//     //---------------------------------------------------------
//     // Next State Logic
//     //---------------------------------------------------------
//     always_comb begin
//         next_state = state;

//         case(state)
//             IDLE:
//                 if(start) next_state = READY;

//             READY:
//                 if(vs_rise) next_state = PLAY;

//             PLAY:
//                 if(fail) next_state = GAMEOVER;
//                 else if(success) next_state = READY;

//             GAMEOVER:
//                 if(start) next_state = READY;
//         endcase
//     end

//     //---------------------------------------------------------
//     // OUTPUT + FSM Behavior
//     //---------------------------------------------------------
//     always_ff @(posedge clk or posedge reset) begin
//         if(reset) begin
//             region <= 0;
//             success <= 0;
//             fail <= 0;
//             game_over <= 0;
//             hold_cnt <= 0;
//             timeout_cnt <= 0;
//             skip_frames <= 0;

//             pass_LT <= 0; pass_RT <= 0; pass_LB <= 0; pass_RB <= 0;
//         end
//         else begin

//             // PASS는 무조건 매 프레임 detect 정보 그대로 표시
//             pass_LT <= LT_d;
//             pass_RT <= RT_d;
//             pass_LB <= LB_d;
//             pass_RB <= RB_d;

//             success <= 0;
//             fail    <= 0;

//             case(state)

//                 //---------------------------------------------------------
//                 // READY
//                 //---------------------------------------------------------
//                 READY: begin
//                     if(vs_rise) begin
//                         region <= lfsr % 4;
//                         hold_cnt <= 0;
//                         timeout_cnt <= 0;
//                         skip_frames <= 5;
//                     end
//                 end

//                 //---------------------------------------------------------
//                 // PLAY
//                 //---------------------------------------------------------
//                 PLAY: begin
//                     if(vs_rise) begin

//                         // 안정화 프레임 스킵
//                         if(skip_frames != 0) begin
//                             skip_frames <= skip_frames - 1;
//                         end
//                         else begin
//                             timeout_cnt <= timeout_cnt + 1;

//                             correct =
//                                 (region==0 && LT_d && !(RT_d|LB_d|RB_d)) ||
//                                 (region==1 && RT_d && !(LT_d|LB_d|RB_d)) ||
//                                 (region==2 && LB_d && !(LT_d|RT_d|RB_d)) ||
//                                 (region==3 && RB_d && !(LT_d|RT_d|LB_d));

//                             if(correct)
//                                 hold_cnt <= hold_cnt + 1;
//                             else
//                                 hold_cnt <= 0;

//                             if(hold_cnt >= 15)
//                                 success <= 1;

//                             if(timeout_cnt >= 200)
//                                 fail <= 1;
//                         end

//                         if(success) begin
//                             region <= lfsr % 4;
//                             hold_cnt <= 0;
//                             timeout_cnt <= 0;
//                             skip_frames <= 5;
//                         end
//                     end
//                 end

//                 //---------------------------------------------------------
//                 // GAMEOVER
//                 //---------------------------------------------------------
//                 GAMEOVER: begin
//                     game_over <= 1;
//                     fail <= 1;
//                 end

//             endcase
//         end
//     end

// endmodule

////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////251127_12h_37m////////////////////////////////////////////////

// `timescale 1ns / 1ps
// module MiniGameFSM_4way (
//     input logic clk,
//     input logic reset,
//     input logic start,
//     input logic vsync,

//     input logic detect_LT,
//     input logic detect_RT,
//     input logic detect_LB,
//     input logic detect_RB,

//     output logic [1:0] region,
//     output logic success,
//     output logic fail,
//     output logic game_over
// );

//     typedef enum logic [1:0] {
//         IDLE,
//         READY,
//         PLAY,
//         GAMEOVER
//     } state_t;
//     state_t state, next_state;

//     // vsync rising
//     logic vs_d, vs_rise;
//     always_ff @(posedge clk) begin
//         vs_d <= vsync;
//         vs_rise <= vsync & ~vs_d;
//     end

//     // frame-latch
//     logic LT_d;  // left top detect
//     logic RT_d;  // right top detect
//     logic LB_d;  // left bottom detect
//     logic RB_d;  // right bottom detect

//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             LT_d <= 0;
//             RT_d <= 0;
//             LB_d <= 0;
//             RB_d <= 0;
//         end else if (vs_rise) begin
//             LT_d <= detect_LT;
//             RT_d <= detect_RT;
//             LB_d <= detect_LB;
//             RB_d <= detect_RB;
//         end
//     end

//     // LFSR
//     logic [7:0] lfsr;
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) lfsr <= 8'hA5;
//         else if (vs_rise) lfsr <= {lfsr[6:0], ^(lfsr & 8'hB8)};
//     end

//     // counters
//     logic [7:0] hold_cnt;
//     logic [7:0] timeout_cnt;
//     logic [3:0] skip_frames;
//     logic       correct;

//     // State register
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) state <= IDLE;
//         else state <= next_state;
//     end

//     // Next state
//     always_comb begin
//         next_state = state;
//         case (state)
//             IDLE: if (start) next_state = READY;
//             READY: if (vs_rise) next_state = PLAY;
//             PLAY:
//             if (fail) next_state = GAMEOVER;
//             else if (success) next_state = READY;
//             GAMEOVER: if (start) next_state = READY;
//         endcase
//     end

//     // OUTPUT behavior

//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             region <= 0;
//             success <= 0;
//             fail <= 0;
//             game_over <= 0;
//             hold_cnt <= 0;
//             timeout_cnt <= 0;
//             skip_frames <= 0;
//         end else begin
//             success <= 0;
//             fail <= 0;
//             case (state)
//                 READY: begin
//                     if (vs_rise) begin
//                         region <= lfsr % 4;
//                         hold_cnt <= 0;
//                         timeout_cnt <= 0;
//                         skip_frames <= 4;
//                     end
//                 end
//                 PLAY: begin
//                     if (vs_rise) begin
//                         if (skip_frames != 0) begin
//                             skip_frames <= skip_frames - 1;
//                         end else begin
//                             timeout_cnt <= timeout_cnt + 1;
//                             correct =
//                                 (region==0 && LT_d) ||
//                                 (region==1 && RT_d) ||
//                                 (region==2 && LB_d) ||
//                                 (region==3 && RB_d);
//                             if (correct) hold_cnt <= hold_cnt + 1;
//                             else hold_cnt <= 0;

//                             if (hold_cnt >= 15) success <= 1;

//                             if (timeout_cnt >= 200) fail <= 1;
//                         end
//                         if (success) begin
//                             region <= lfsr % 4;
//                             hold_cnt <= 0;
//                             timeout_cnt <= 0;
//                             skip_frames <= 4;
//                         end
//                     end
//                 end
//                 GAMEOVER: begin
//                     game_over <= 1;
//                     fail <= 1;
//                 end

//             endcase
//         end
//     end

// endmodule

// `timescale 1ns / 1ps

// module MiniGameFSM_4way (
//     input  logic clk,
//     input  logic reset,
//     input  logic start,
//     input  logic vsync,

//     // ColorDetector로부터 입력
//     input  logic detect_LT,
//     input  logic detect_RT,
//     input  logic detect_LB,
//     input  logic detect_RB,

//     // Overlay로 출력
//     output logic [1:0] fsm_state,      // IDLE/READY/PLAY/RESULT
//     output logic [1:0] region,         // 현재 지시 region (PLAY용)
//     output logic [1:0] result_region,  // 결과 region (RESULT용)
//     output logic [1:0] result_type     // SUCCESS/FAIL
// );

//     //==========================================================
//     // Type Definitions
//     //==========================================================
//     typedef enum logic [1:0] {
//         IDLE    = 2'b00,
//         READY   = 2'b01,
//         PLAY    = 2'b10,
//         RESULT  = 2'b11
//     } state_t;

//     typedef enum logic [1:0] {
//         RES_NONE    = 2'b00,
//         RES_SUCCESS = 2'b01,
//         RES_FAIL    = 2'b10
//     } result_t;

//     //==========================================================
//     // Internal Registers
//     //==========================================================
//     state_t state, next_state;

//     // Timers (frame 단위)
//     logic [7:0] ready_timer;   // 0 ~ 90  (3초)
//     logic [7:0] play_timer;    // 0 ~ 120 (4초)
//     logic [7:0] result_timer;  // 0 ~ 90  (3초)

//     // PLAY state counters
//     logic [7:0] hold_cnt;      // 정답 유지 frame 수
//     logic [3:0] skip_frames;   // 초기 안정화 frame skip

//     // Detect signals (frame-latched)
//     logic LT_d, RT_d, LB_d, RB_d;

//     // LFSR for random region
//     logic [7:0] lfsr;

//     // Internal logic
//     logic correct;

//     //==========================================================
//     // vsync Rising Edge Detection
//     //==========================================================
//     logic vs_d, vs_rise;

//     always_ff @(posedge clk) begin
//         vs_d    <= vsync;
//         vs_rise <= vsync & ~vs_d;
//     end

//     //==========================================================
//     // Detect Signal Latching (frame-based)
//     //==========================================================
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             LT_d <= 0;
//             RT_d <= 0;
//             LB_d <= 0;
//             RB_d <= 0;
//         end 
//         else if (vs_rise) begin
//             LT_d <= detect_LT;
//             RT_d <= detect_RT;
//             LB_d <= detect_LB;
//             RB_d <= detect_RB;
//         end
//     end

//     //==========================================================
//     // LFSR (Random Region Generator)
//     //==========================================================
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset)
//             lfsr <= 8'hA5;
//         else if (vs_rise)
//             lfsr <= {lfsr[6:0], ^(lfsr & 8'hB8)};
//     end

//     //==========================================================
//     // Block 1: State Register
//     //==========================================================
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

//     //==========================================================
//     // Block 2: Next State Logic (Combinational)
//     //==========================================================
//     always_comb begin
//         next_state = state;

//         case (state)
//             IDLE: begin
//                 if (start)
//                     next_state = READY;
//             end

//             READY: begin
//                 if (vs_rise && ready_timer >= 90)
//                     next_state = PLAY;
//             end

//             PLAY: begin
//                 if (vs_rise) begin
//                     // 성공 조건 (우선순위 1)
//                     if (hold_cnt >= 15)
//                         next_state = RESULT;
//                     // 타임아웃 조건 (우선순위 2)
//                     else if (play_timer >= 120)
//                         next_state = RESULT;
//                 end
//             end

//             RESULT: begin
//                 if (vs_rise && result_timer >= 90)
//                     next_state = IDLE;  // ⭐ 무한 루프
//             end
//         endcase
//     end

//     //==========================================================
//     // Block 3: Sequential Logic (Timers + Counters + Region)
//     //==========================================================
//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             // Timers
//             ready_timer  <= 0;
//             play_timer   <= 0;
//             result_timer <= 0;

//             // Counters
//             hold_cnt     <= 0;
//             skip_frames  <= 0;

//             // Outputs (registered)
//             region        <= 0;
//             result_region <= 0;
//             result_type   <= RES_NONE;

//         end
//         else begin

//             case (state)

//                 //--------------------------------------------------
//                 // IDLE State
//                 //--------------------------------------------------
//                 IDLE: begin
//                     // 모든 타이머 초기화
//                     ready_timer  <= 0;
//                     play_timer   <= 0;
//                     result_timer <= 0;
//                     hold_cnt     <= 0;
//                     result_type  <= RES_NONE;
//                 end

//                 //--------------------------------------------------
//                 // READY State (3초 대기)
//                 //--------------------------------------------------
//                 READY: begin
//                     if (vs_rise) begin
//                         ready_timer <= ready_timer + 1;

//                         // PLAY 진입 준비 (3초 경과)
//                         if (ready_timer >= 90) begin
//                             region       <= lfsr % 4;  // 새 region 생성
//                             play_timer   <= 0;
//                             hold_cnt     <= 0;
//                             skip_frames  <= 4;         // 초기 4 frame skip
//                         end
//                     end
//                 end

//                 //--------------------------------------------------
//                 // PLAY State (4초 게임 진행)
//                 //--------------------------------------------------
//                 PLAY: begin
//                     if (vs_rise) begin

//                         // 초기 안정화 frame skip
//                         if (skip_frames != 0) begin
//                             skip_frames <= skip_frames - 1;
//                         end
//                         else begin
//                             // 타이머 증가
//                             play_timer <= play_timer + 1;

//                             // 정답 판단 (현재 region과 detect 신호 일치 여부)
//                             correct = (region == 0 && LT_d) ||
//                                      (region == 1 && RT_d) ||
//                                      (region == 2 && LB_d) ||
//                                      (region == 3 && RB_d);

//                             // hold_cnt 업데이트
//                             if (correct)
//                                 hold_cnt <= hold_cnt + 1;
//                             else
//                                 hold_cnt <= 0;

//                             // 성공 조건 (0.5초 = 15 frames 유지)
//                             if (hold_cnt >= 15) begin
//                                 result_type   <= RES_SUCCESS;
//                                 result_region <= region;  // 성공한 region 기록
//                                 result_timer  <= 0;
//                             end
//                             // 실패 조건 (4초 타임아웃)
//                             else if (play_timer >= 120) begin
//                                 result_type   <= RES_FAIL;
//                                 result_region <= region;  // 실패한 region 기록
//                                 result_timer  <= 0;
//                             end
//                         end
//                     end
//                 end

//                 //--------------------------------------------------
//                 // RESULT State (3초 결과 표시)
//                 //--------------------------------------------------
//                 RESULT: begin
//                     if (vs_rise) begin
//                         result_timer <= result_timer + 1;

//                         // READY 복귀 준비 (3초 경과)
//                         if (result_timer >= 90) begin
//                             ready_timer <= 0;
//                             result_type <= RES_NONE;
//                         end
//                     end
//                 end

//             endcase
//         end
//     end

//     //==========================================================
//     // Block 4: Output Assignment
//     //==========================================================
//     // fsm_state는 조합 논리로 현재 state 직접 출력
//     assign fsm_state = state;

//     // region, result_region, result_type는 이미 sequential block에서 관리
//     // (별도 assign 불필요)

// endmodule

`timescale 1ns / 1ps

module MiniGameFSM_4way (
    input logic clk,
    input logic reset,
    input logic start,
    input logic vsync,

    // ColorDetector로부터 입력
    input logic detect_LT,
    input logic detect_RT,
    input logic detect_LB,
    input logic detect_RB,

    // Overlay로 출력
    output logic [2:0] fsm_state,    // IDLE/READY/PLAY/ROUND_END/SCOREBOARD
    output logic [1:0] region,       // 현재 지시 region
    output logic [1:0] result_type,  // SUCCESS/FAIL
    output logic [2:0] round_cnt,    // 현재 라운드 (0~4)
    output logic [2:0] score,        // 총 점수 (0~5)
    output logic [4:0] round_result  // 각 라운드 결과 (bit별)
);

    //==========================================================
    // Type Definitions
    //==========================================================
    typedef enum logic [2:0] {
        IDLE       = 3'b000,
        READY      = 3'b001,
        PLAY       = 3'b010,
        ROUND_END  = 3'b011,
        SCOREBOARD = 3'b100
    } state_t;

    typedef enum logic [1:0] {
        RES_NONE    = 2'b00,
        RES_SUCCESS = 2'b01,
        RES_FAIL    = 2'b10
    } result_t;

    //==========================================================
    // Internal Registers
    //==========================================================
    state_t state, next_state;

    // Timers (frame 단위)
    logic [7:0] ready_timer;  // 0 ~ 60  (2초 @ 30fps)
    logic [7:0] play_timer;  // 0 ~ 120 (4초)
    logic [7:0] round_end_timer;  // 0 ~ 60  (2초)
    logic [9:0] score_timer;  // 0 ~ 300 (10초)

    // PLAY state counters
    logic [7:0] hold_cnt;  // 정답 유지 frame 수
    logic [3:0] skip_frames;  // 초기 안정화 frame skip

    // Detect signals (frame-latched)
    logic LT_d, RT_d, LB_d, RB_d;

    // LFSR for random region
    logic [7:0] lfsr;

    // Internal logic
    logic correct;

    //==========================================================
    // vsync Rising Edge Detection
    //==========================================================
    logic vs_d, vs_rise;

    always_ff @(posedge clk) begin
        vs_d    <= vsync;
        vs_rise <= vsync & ~vs_d;
    end

    //==========================================================
    // Detect Signal Latching (frame-based)
    //==========================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            LT_d <= 0;
            RT_d <= 0;
            LB_d <= 0;
            RB_d <= 0;
        end else if (vs_rise) begin
            LT_d <= detect_LT;
            RT_d <= detect_RT;
            LB_d <= detect_LB;
            RB_d <= detect_RB;
        end
    end

    //==========================================================
    // LFSR (Random Region Generator)
    //==========================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) lfsr <= 8'hA5;
        else if (vs_rise) lfsr <= {lfsr[6:0], ^(lfsr & 8'hB8)};
    end

    //==========================================================
    // Block 1: State Register
    //==========================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end

    //==========================================================
    // Block 2: Next State Logic (Combinational)
    //==========================================================
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                //if (start) 
                next_state = READY;
            end

            READY: begin
                if (vs_rise && ready_timer >= 60)  // 2초
                    next_state = PLAY;
            end

            PLAY: begin
                if (vs_rise) begin
                    // 성공 조건
                    if (hold_cnt >= 15) next_state = ROUND_END;
                    // 타임아웃 조건
                    else if (play_timer >= 120) next_state = ROUND_END;
                end
            end

            ROUND_END: begin
                if (vs_rise && round_end_timer >= 60) begin  // 2초
                    if (round_cnt < 4)  // 라운드 0~4
                        next_state = READY;  // 다음 라운드
                    else next_state = SCOREBOARD;  // 5라운드 완료
                end
            end

            SCOREBOARD: begin
                if (vs_rise && score_timer >= 300)  // 10초
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    //==========================================================
    // Block 3: Sequential Logic (Timers + Counters + State)
    //==========================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Timers
            ready_timer     <= 0;
            play_timer      <= 0;
            round_end_timer <= 0;
            score_timer     <= 0;

            // Counters
            hold_cnt        <= 0;
            skip_frames     <= 0;

            // Game state
            round_cnt       <= 0;
            score           <= 0;
            round_result    <= 0;

            // Outputs
            region          <= 0;
            result_type     <= RES_NONE;

        end else begin

            case (state)

                //--------------------------------------------------
                // IDLE State
                //--------------------------------------------------
                IDLE: begin
                    // 모든 타이머/카운터 초기화
                    ready_timer     <= 0;
                    play_timer      <= 0;
                    round_end_timer <= 0;
                    score_timer     <= 0;
                    round_cnt       <= 0;
                    score           <= 0;
                    round_result    <= 0;
                    result_type     <= RES_NONE;
                end

                //--------------------------------------------------
                // READY State (2초 대기)
                //--------------------------------------------------
                READY: begin
                    if (vs_rise) begin
                        ready_timer <= ready_timer + 1;

                        // PLAY 진입 준비 (2초 경과)
                        if (ready_timer >= 60) begin
                            region      <= lfsr % 4;  // 새 region 생성
                            play_timer  <= 0;
                            hold_cnt    <= 0;
                            skip_frames <= 4;
                        end
                    end
                end

                //--------------------------------------------------
                // PLAY State (4초 게임 진행)
                //--------------------------------------------------
                PLAY: begin
                    if (vs_rise) begin

                        // 초기 안정화 frame skip
                        if (skip_frames != 0) begin
                            skip_frames <= skip_frames - 1;
                        end else begin
                            // 타이머 증가
                            play_timer <= play_timer + 1;

                            // 정답 판단
                            correct = (region == 0 && LT_d) ||
                                     (region == 1 && RT_d) ||
                                     (region == 2 && LB_d) ||
                                     (region == 3 && RB_d);

                            // hold_cnt 업데이트
                            if (correct) hold_cnt <= hold_cnt + 1;
                            else hold_cnt <= 0;

                            // 성공 조건 (0.5초 = 15 frames 유지)
                            if (hold_cnt >= 15) begin
                                result_type             <= RES_SUCCESS;
                                score                   <= score + 1;  // ⭐ 점수 증가
                                round_result[round_cnt] <= 1;  // ⭐ 성공 기록
                                round_end_timer         <= 0;
                            end  // 실패 조건 (4초 타임아웃)
                            else if (play_timer >= 120) begin
                                result_type <= RES_FAIL;
                                round_result[round_cnt] <= 0;  // ⭐ 실패 기록
                                round_end_timer <= 0;
                            end
                        end
                    end
                end

                //--------------------------------------------------
                // ROUND_END State (2초 결과 표시)
                //--------------------------------------------------
                ROUND_END: begin
                    if (vs_rise) begin
                        round_end_timer <= round_end_timer + 1;

                        // 다음 라운드 또는 Scoreboard 준비
                        if (round_end_timer >= 60) begin
                            if (round_cnt < 4) begin
                                // 다음 라운드
                                round_cnt   <= round_cnt + 1;  // ⭐ 라운드 증가
                                ready_timer <= 0;
                                result_type <= RES_NONE;
                            end else begin
                                // Scoreboard로
                                score_timer <= 0;
                            end
                        end
                    end
                end

                //--------------------------------------------------
                // SCOREBOARD State (10초 결과 표시)
                //--------------------------------------------------
                SCOREBOARD: begin
                    if (vs_rise) begin
                        score_timer <= score_timer + 1;

                        // IDLE 복귀 준비 (10초 경과)
                        if (score_timer >= 300) begin
                            // 모든 상태 초기화는 IDLE에서 처리
                        end
                    end
                end

            endcase
        end
    end

    //==========================================================
    // Block 4: Output Assignment
    //==========================================================
    assign fsm_state = state;

endmodule
