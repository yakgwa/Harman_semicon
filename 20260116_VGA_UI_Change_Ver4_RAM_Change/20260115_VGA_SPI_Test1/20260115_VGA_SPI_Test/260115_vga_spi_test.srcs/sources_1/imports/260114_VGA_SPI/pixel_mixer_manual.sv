


//`timescale 1ns / 1ps

//module pixel_mixer_manual (
//    input logic [11:0] img_bg,

//    // ??Ôø?? ?ÔøΩÔøΩÔø??
//    input logic [15:0][9:0] aim_x_all,
//    input logic [15:0][9:0] aim_y_all,
//    input logic [15:0]      aim_detected_all,

//    input logic [9:0] x_pixel,
//    input logic [9:0] y_pixel,

//    // Î∞ïÏä§ ?ÔøΩÔøΩÔø??
//    input logic [15:0][11:0] box_x_min_all,
//    input logic [15:0][11:0] box_x_max_all,
//    input logic [15:0][11:0] box_y_min_all,
//    input logic [15:0][11:0] box_y_max_all,

//    // ?ÔøΩÔøΩÎ≥¥Îìú ?ÔøΩÔøΩ?ÔøΩÔøΩ?ÔøΩÔøΩ (W:0, A:1, S:2, D:3, L:4)
//    input logic [7:0] keyboard_data,

//    output logic [3:0] r_port,
//    output logic [3:0] g_port,
//    output logic [3:0] b_port,

//    output logic [9:0] x_coor,
//    output logic [9:0] y_coor,
//    output logic       shoot
//);
//    // --- ?ÔøΩÔøΩ?ÔøΩÔøΩ ?ÔøΩÔøΩ?ÔøΩÔøΩ ---
//    localparam logic [11:0] RED = 12'hF00;
//    localparam logic [11:0] GREEN = 12'h0F0;
//    localparam logic [11:0] YELLOW = 12'hFF0;
//    localparam logic [11:0] WHITE = 12'hFFF;
//    localparam logic [11:0] BLACK = 12'h000;

//    localparam logic [11:0] AIM_COLOR = RED;
//    localparam logic [11:0] BOX_COLOR = GREEN;

//    // =================================================================
//    // 1. ÎπÑÌä∏Ôø?? ?ÔøΩÔøΩ?ÔøΩÔøΩ (?ÔøΩÔøΩÎ≥¥Îìú UI?ÔøΩÔøΩ)
//    // =================================================================
//    localparam logic [0:7][7:0] CHAR_W = '{
//        8'b11000011,
//        8'b11000011,
//        8'b11000011,
//        8'b11000011,
//        8'b11011011,
//        8'b11011011,
//        8'b01100110,
//        8'b00000000
//    };
//    localparam logic [0:7][7:0] CHAR_A = '{
//        8'b00111100,
//        8'b01100110,
//        8'b11000011,
//        8'b11111111,
//        8'b11111111,
//        8'b11000011,
//        8'b11000011,
//        8'b00000000
//    };
//    localparam logic [0:7][7:0] CHAR_S = '{
//        8'b01111110,
//        8'b11000011,
//        8'b11000000,
//        8'b01111110,
//        8'b00000011,
//        8'b00000011,
//        8'b11000011,
//        8'b01111110
//    };
//    localparam logic [0:7][7:0] CHAR_D = '{
//        8'b11111100,
//        8'b11000011,
//        8'b11000011,
//        8'b11000011,
//        8'b11000011,
//        8'b11000011,
//        8'b11111100,
//        8'b00000000
//    };
//    localparam logic [0:7][7:0] CHAR_L = '{
//        8'b11000000,
//        8'b11000000,
//        8'b11000000,
//        8'b11000000,
//        8'b11000000,
//        8'b11000000,
//        8'b11111111,
//        8'b11111111
//    };

//    // Ï°∞ÔøΩ? ?ÔøΩÔøΩÔø?? ?ÔøΩÔøΩ?ÔøΩÔøΩÔø?? (Í≥ºÎÖÅ Î™®Ïñë)
//    localparam logic [0:7][7:0] ICON_LOCK = '{
//        8'b00111100,
//        8'b01000010,
//        8'b10011001,
//        8'b10100101,
//        8'b10100101,
//        8'b10011001,
//        8'b01000010,
//        8'b00111100
//    };

//    // =================================================================
//    // 2. UI ?ÔøΩÔøΩÔø?? ?ÔøΩÔøΩ?ÔøΩÔøΩÎØ∏ÌÑ∞
//    // =================================================================
//    localparam int KEY_SIZE = 30;
//    localparam int GAP = 5;
//    localparam int CHAR_OFFSET = (KEY_SIZE - 16) / 2;

//    // WASD Ï¢åÌëú
//    localparam int WASD_X = 30;
//    localparam int WASD_Y = 380;
//    localparam int AX1 = WASD_X, AY1 = WASD_Y + KEY_SIZE + GAP;
//    localparam int SX1 = WASD_X + KEY_SIZE + GAP, SY1 = AY1;
//    localparam int DX1 = WASD_X + 2 * (KEY_SIZE + GAP), DY1 = AY1;
//    localparam int WX1 = SX1, WY1 = WASD_Y;

//    // L?ÔøΩÔøΩ & ?ÔøΩÔøΩ?ÔøΩÔøΩ UI Ï¢åÌëú
//    localparam int L_X = 30, L_Y = 30;
//    localparam int LOCK_UI_X = 580, LOCK_UI_Y = 30;

//    // Ï§ëÏïô Ï°∞ÔøΩ??ÔøΩÔøΩ ?ÔøΩÔøΩ?ÔøΩÔøΩÎØ∏ÌÑ∞
//    localparam int CX = 320;
//    localparam int CY = 240;
//    localparam int LOCK_ZONE = 30;  // ?ÔøΩÔøΩ?ÔøΩÔøΩ ?ÔøΩÔøΩ?ÔøΩÔøΩ Î≤îÏúÑ

//    // ?ÔøΩÔøΩÔø?? Ôø???ÔøΩÔøΩ
//    logic on_box, on_aim;
//    logic is_wasd_ui, is_wasd_char;
//    logic [11:0] wasd_color;
//    logic is_l_ui, is_l_char;
//    logic [11:0] l_color;
//    logic on_crosshair;
//    logic is_locked_on;
//    logic is_lock_ui, is_lock_icon;

//    logic [5:0] rel_x, rel_y;
//    logic [2:0] char_x, char_y;

//    // Ï°∞ÔøΩ??ÔøΩÔøΩ Í∑∏Î¶¨Í∏∞ÔøΩ?? ?ÔøΩÔøΩ?ÔøΩÔøΩ ?ÔøΩÔøΩ??Í±∞Î¶¨ Ôø???ÔøΩÔøΩ
//    int dist_x, dist_y;

//    // miso signal
//    assign y_coor = keyboard_data[0] ? 10'd190 : keyboard_data[2] ? 10'd290 : 10'd240;
//    assign x_coor = keyboard_data[1] ? 10'd270 : keyboard_data[3] ? 10'd370 : 10'd320;
//    assign shoot  = keyboard_data[4] ? 1'b1 : 1'b0;

//    // =================================================================
//    // 3. Î°úÏßÅ Íµ¨ÌòÑ
//    // =================================================================

//    // (1) ?ÔøΩÔøΩ?ÔøΩÔøΩ Í∞êÔøΩ? (Îπ®Í∞Ñ Î¨ºÏ≤¥Ôø?? Ï§ëÏïô Î≤îÏúÑ ?ÔøΩÔøΩ?ÔøΩÔøΩ ?ÔøΩÔøΩ?ÔøΩÔøΩÔø???)
//    always_comb begin
//        is_locked_on = 0;
//        for (int k = 0; k < 16; k++) begin
//            if (aim_detected_all[k]) begin
//                if( (aim_x_all[k] > CX - LOCK_ZONE) && (aim_x_all[k] < CX + LOCK_ZONE) &&
//                    (aim_y_all[k] > CY - LOCK_ZONE) && (aim_y_all[k] < CY + LOCK_ZONE) ) begin
//                    is_locked_on = 1;
//                end
//            end
//        end
//    end

//    // (2) ?ÔøΩÔøΩÔø?? Í∑∏Î¶¨Ôø?? Î°úÏßÅ
//    always_comb begin
//        // Ï¥àÍ∏∞?ÔøΩÔøΩ
//        on_box       = 0;
//        on_aim       = 0;
//        on_crosshair = 0;
//        is_wasd_ui   = 0;
//        is_wasd_char = 0;
//        wasd_color   = WHITE;
//        is_l_ui      = 0;
//        is_l_char    = 0;
//        l_color      = WHITE;
//        is_lock_ui   = 0;
//        is_lock_icon = 0;
//        rel_x        = 0;
//        rel_y        = 0;
//        char_x       = 0;
//        char_y       = 0;


//        // --- A. Ï§ëÏïô Ï°∞ÔøΩ??ÔøΩÔøΩ (?ÔøΩÔøΩÎØ∏ÔøΩ? ?ÔøΩÔøΩ???ÔøΩÔøΩ Íµ¨ÌòÑ) ---
//        dist_x       = (x_pixel > CX) ? (x_pixel - CX) : (CX - x_pixel);
//        dist_y       = (y_pixel > CY) ? (y_pixel - CY) : (CY - y_pixel);

//        // 1. Ï§ëÏïô ?ÔøΩÔøΩ
//        if ((dist_x * dist_x + dist_y * dist_y) <= 36) on_crosshair = 1;

//        // 2. ?ÔøΩÔøΩÔø?? ?ÔøΩÔøΩ?ÔøΩÔøΩ?ÔøΩÔøΩ
//        if (dist_x < 2 && dist_y >= 12 && dist_y <= 22) on_crosshair = 1;
//        if (dist_y < 2 && dist_x >= 12 && dist_x <= 22) on_crosshair = 1;

//        // 3. ?ÔøΩÔøΩÔø?? ÏΩîÎÑà Î∏åÎùºÔø??
//        if (dist_y >= 33 && dist_y <= 35 && dist_x >= 20 && dist_x <= 35)
//            on_crosshair = 1;
//        if (dist_x >= 33 && dist_x <= 35 && dist_y >= 20 && dist_y <= 35)
//            on_crosshair = 1;


//        // --- B. Í∏∞Ï°¥ ??Ôø?? Î∞ïÏä§ ---
//        for (int k = 0; k < 16; k++) begin
//            if (aim_detected_all[k]) begin
//                if ( ((y_pixel == box_y_min_all[k] || y_pixel == box_y_max_all[k]) && (x_pixel >= box_x_min_all[k] && x_pixel <= box_x_max_all[k])) ||
//                     ((x_pixel == box_x_min_all[k] || x_pixel == box_x_max_all[k]) && (y_pixel >= box_y_min_all[k] && y_pixel <= box_y_max_all[k])) )
//                    on_box = 1;
//                if ( (y_pixel >= aim_y_all[k]-1 && y_pixel <= aim_y_all[k]+1 && x_pixel >= aim_x_all[k]-5 && x_pixel <= aim_x_all[k]+5) ||
//                     (x_pixel >= aim_x_all[k]-1 && x_pixel <= aim_x_all[k]+1 && y_pixel >= aim_y_all[k]-5 && y_pixel <= aim_y_all[k]+5) )
//                    on_aim = 1;
//            end
//        end
//        // keyboard_data[0] = W 
//        // keyboard_data[1] = A
//        // keyboard_data[2] = S 
//        // keyboard_data[3] = D 
//        // keyboard_data[4] = L
//        // keyboard_data[5] = F1
//        // keyboard_data[6] = F2
//        // keyboard_data[7] = F3
//        // --- C. WASD UI ---
//        if (x_pixel >= WX1 && x_pixel < WX1 + KEY_SIZE && y_pixel >= WY1 && y_pixel < WY1 + KEY_SIZE) begin
//            is_wasd_ui = 1;
//            wasd_color = keyboard_data[0] ? YELLOW : WHITE;
//            rel_x = x_pixel - WX1;
//            rel_y = y_pixel - WY1;
//            if (rel_x>=CHAR_OFFSET && rel_x<CHAR_OFFSET+16 && rel_y>=CHAR_OFFSET && rel_y<CHAR_OFFSET+16) begin
//                char_x = (rel_x - CHAR_OFFSET) >> 1;
//                char_y = (rel_y - CHAR_OFFSET) >> 1;
//                if (CHAR_W[char_y][7-char_x]) is_wasd_char = 1;
//            end
//        end else if (x_pixel >= AX1 && x_pixel < AX1 + KEY_SIZE && y_pixel >= AY1 && y_pixel < AY1 + KEY_SIZE) begin
//            is_wasd_ui = 1;
//            wasd_color = keyboard_data[1] ? YELLOW : WHITE;
//            rel_x = x_pixel - AX1;
//            rel_y = y_pixel - AY1;
//            if (rel_x>=CHAR_OFFSET && rel_x<CHAR_OFFSET+16 && rel_y>=CHAR_OFFSET && rel_y<CHAR_OFFSET+16) begin
//                char_x = (rel_x - CHAR_OFFSET) >> 1;
//                char_y = (rel_y - CHAR_OFFSET) >> 1;
//                if (CHAR_A[char_y][7-char_x]) is_wasd_char = 1;
//            end
//        end else if (x_pixel >= SX1 && x_pixel < SX1 + KEY_SIZE && y_pixel >= SY1 && y_pixel < SY1 + KEY_SIZE) begin
//            is_wasd_ui = 1;
//            wasd_color = keyboard_data[2] ? YELLOW : WHITE;
//            rel_x = x_pixel - SX1;
//            rel_y = y_pixel - SY1;
//            if (rel_x>=CHAR_OFFSET && rel_x<CHAR_OFFSET+16 && rel_y>=CHAR_OFFSET && rel_y<CHAR_OFFSET+16) begin
//                char_x = (rel_x - CHAR_OFFSET) >> 1;
//                char_y = (rel_y - CHAR_OFFSET) >> 1;
//                if (CHAR_S[char_y][7-char_x]) is_wasd_char = 1;
//            end
//        end else if (x_pixel >= DX1 && x_pixel < DX1 + KEY_SIZE && y_pixel >= DY1 && y_pixel < DY1 + KEY_SIZE) begin
//            is_wasd_ui = 1;
//            wasd_color = keyboard_data[3] ? YELLOW : WHITE;
//            rel_x = x_pixel - DX1;
//            rel_y = y_pixel - DY1;
//            if (rel_x>=CHAR_OFFSET && rel_x<CHAR_OFFSET+16 && rel_y>=CHAR_OFFSET && rel_y<CHAR_OFFSET+16) begin
//                char_x = (rel_x - CHAR_OFFSET) >> 1;
//                char_y = (rel_y - CHAR_OFFSET) >> 1;
//                if (CHAR_D[char_y][7-char_x]) is_wasd_char = 1;
//            end
//        end

//        // --- D. L-Key UI ---
//        if (x_pixel >= L_X && x_pixel < L_X + KEY_SIZE && y_pixel >= L_Y && y_pixel < L_Y + KEY_SIZE) begin
//            is_l_ui = 1;
//            l_color = keyboard_data[4] ? YELLOW : WHITE;
//            rel_x   = x_pixel - L_X;
//            rel_y   = y_pixel - L_Y;
//            if (rel_x>=CHAR_OFFSET && rel_x<CHAR_OFFSET+16 && rel_y>=CHAR_OFFSET && rel_y<CHAR_OFFSET+16) begin
//                char_x = (rel_x - CHAR_OFFSET) >> 1;
//                char_y = (rel_y - CHAR_OFFSET) >> 1;
//                if (CHAR_L[char_y][7-char_x]) is_l_char = 1;
//            end
//        end

//        // --- E. ?ÔøΩÔøΩ?ÔøΩÔøΩ ?ÔøΩÔøΩÔø?? UI (?ÔøΩÔøΩ?ÔøΩÔøΩ ?ÔøΩÔøΩ?ÔøΩÔøΩÔø?? Ôø??Ôø??) ---
//        // is_locked_on Ï°∞Í±¥ ?ÔøΩÔøΩÍ±∞Ìïò?ÔøΩÔøΩ ?ÔøΩÔøΩ?ÔøΩÔøΩ Ï¢åÌëú?ÔøΩÔøΩ ÏßÑÏûÖ?ÔøΩÔøΩ?ÔøΩÔøΩÔø?? ?ÔøΩÔøΩ?ÔøΩÔøΩ
//        if (x_pixel >= LOCK_UI_X && x_pixel < LOCK_UI_X + KEY_SIZE && y_pixel >= LOCK_UI_Y && y_pixel < LOCK_UI_Y + KEY_SIZE) begin
//            is_lock_ui = 1;
//            rel_x = x_pixel - LOCK_UI_X;
//            rel_y = y_pixel - LOCK_UI_Y;
//            if (rel_x>=CHAR_OFFSET && rel_x<CHAR_OFFSET+16 && rel_y>=CHAR_OFFSET && rel_y<CHAR_OFFSET+16) begin
//                char_x = (rel_x - CHAR_OFFSET) >> 1;
//                char_y = (rel_y - CHAR_OFFSET) >> 1;
//                if (ICON_LOCK[char_y][7-char_x]) is_lock_icon = 1;
//            end
//        end
//    end

//    // =================================================================
//    // 4. ÏµúÏ¢Ö ?ÔøΩÔøΩ?ÔøΩÔøΩ Í≤∞Ï†ï
//    // =================================================================
//    always_comb begin
//        logic [11:0] pixel_color;

//        if (is_lock_ui) begin
//            if (is_lock_icon) begin
//                pixel_color = BLACK;  // ?ÔøΩÔøΩ?ÔøΩÔøΩÏΩòÔøΩ? ?ÔøΩÔøΩ?ÔøΩÔøΩ Ôø?????ÔøΩÔøΩ
//            end else begin
//                // [Ï§ëÏöî] Ï°∞ÔøΩ??ÔøΩÔøΩÔø?? ?ÔøΩÔøΩ?ÔøΩÔøΩ?ÔøΩÔøΩ, ?ÔøΩÔøΩ?ÔøΩÔøΩÔø?? ?ÔøΩÔøΩ???ÔøΩÔøΩ Î∞∞Í≤Ω
//                pixel_color = is_locked_on ? YELLOW : WHITE;
//            end
//        end else if (is_wasd_ui) begin
//            pixel_color = is_wasd_char ? BLACK : wasd_color;
//        end else if (is_l_ui) begin
//            pixel_color = is_l_char ? BLACK : l_color;
//        end else if (on_crosshair) begin
//            pixel_color = BLACK;  // Ï§ëÏïô Ï°∞ÔøΩ??ÔøΩÔøΩ
//        end else if (on_aim) begin
//            pixel_color = AIM_COLOR;
//        end else if (on_box) begin
//            pixel_color = BOX_COLOR;
//        end else begin
//            pixel_color = img_bg;
//        end

//        {r_port, g_port, b_port} = pixel_color;
//    end

//endmodule

//`timescale 1ns / 1ps

//module pixel_mixer_manual (
//    input logic [11:0] img_bg,

//    // ≈∏∞Ÿ ¡§∫∏
//    input logic [15:0][9:0] aim_x_all,
//    input logic [15:0][9:0] aim_y_all,
//    input logic [15:0]      aim_detected_all,

//    input logic [9:0] x_pixel,
//    input logic [9:0] y_pixel,

//    // π⁄Ω∫ ¡§∫∏
//    input logic [15:0][11:0] box_x_min_all,
//    input logic [15:0][11:0] box_x_max_all,
//    input logic [15:0][11:0] box_y_min_all,
//    input logic [15:0][11:0] box_y_max_all,

//    // ≈∞∫∏µÂ µ•¿Ã≈Õ (W:0, A:1, S:2, D:3, L:4)
//    input logic [7:0] keyboard_data,

//    output logic [3:0] r_port,
//    output logic [3:0] g_port,
//    output logic [3:0] b_port,

//    output logic [9:0] x_coor,
//    output logic [9:0] y_coor,
//    output logic       shoot
//);
//    // --- ªˆªÛ ¡§¿« ---
//    localparam logic [11:0] RED    = 12'hF00;
//    localparam logic [11:0] GREEN  = 12'h0F0;
//    localparam logic [11:0] YELLOW = 12'hFF0;
//    localparam logic [11:0] WHITE  = 12'hFFF;
//    localparam logic [11:0] BLACK  = 12'h000;

//    localparam logic [11:0] AIM_COLOR = RED;
//    localparam logic [11:0] BOX_COLOR = GREEN;

//    // --- ∫Ò∆Æ∏  µ•¿Ã≈Õ (W, A, S, D, L, MANUAL, LOCK) ---
//    localparam logic [0:7][7:0] CHAR_W = '{8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hDB, 8'hDB, 8'h66, 8'h00};
//    localparam logic [0:7][7:0] CHAR_A = '{8'h3C, 8'h66, 8'hC3, 8'hFF, 8'hFF, 8'hC3, 8'hC3, 8'h00};
//    localparam logic [0:7][7:0] CHAR_S = '{8'h7E, 8'hC3, 8'hC0, 8'h7E, 8'h03, 8'h03, 8'hC3, 8'h7E};
//    localparam logic [0:7][7:0] CHAR_D = '{8'hFC, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hFC, 8'h00};
//    localparam logic [0:7][7:0] CHAR_L = '{8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hFF, 8'hFF};
//    localparam logic [0:7][7:0] CHAR_M = '{8'hC3, 8'hE7, 8'hDB, 8'hDB, 8'hC3, 8'hC3, 8'hC3, 8'h00};
//    localparam logic [0:7][7:0] CHAR_N = '{8'hC3, 8'hE3, 8'hF3, 8'hDB, 8'hCF, 8'hC7, 8'hC3, 8'h00};
//    localparam logic [0:7][7:0] CHAR_U = '{8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h7E, 8'h00};
//    localparam logic [0:7][7:0] ICON_LOCK = '{8'h3C, 8'h42, 8'h99, 8'hA5, 8'hA5, 8'h99, 8'h42, 8'h3C};

//    // --- UI ∆ƒ∂ÛπÃ≈Õ ---
//    localparam int KEY_SIZE = 30, GAP = 5, CHAR_OFFSET = 7;
//    localparam int WASD_X = 30, WASD_Y = 380;
//    localparam int AX1 = WASD_X, AY1 = WASD_Y + KEY_SIZE + GAP;
//    localparam int SX1 = WASD_X + KEY_SIZE + GAP, SY1 = AY1;
//    localparam int DX1 = WASD_X + 2 * (KEY_SIZE + GAP), DY1 = AY1;
//    localparam int WX1 = SX1, WY1 = WASD_Y;
//    localparam int L_X = 30, L_Y = 30, LOCK_UI_X = 580, LOCK_UI_Y = 30;
//    localparam int CX = 320, CY = 240, LOCK_ZONE = 30;
//    localparam int MANUAL_X = 260, MANUAL_Y = 15;

//    // --- ≥ª∫Œ Ω≈»£ ---
//    logic on_box, on_aim, on_crosshair, is_locked_on;
//    logic is_wasd_ui, is_wasd_char, is_l_ui, is_l_char, is_lock_ui, is_lock_icon;
//    logic is_manual_ui, is_manual_char;
//    logic [11:0] wasd_color;
//    logic [9:0] dx, dy;
//    int rx, ry;

//    // --- Ω≈»£ «“¥Á ---
//    assign y_coor = keyboard_data[0] ? 10'd190 : keyboard_data[2] ? 10'd290 : 10'd240;
//    assign x_coor = keyboard_data[1] ? 10'd270 : keyboard_data[3] ? 10'd370 : 10'd320;
//    assign shoot  = keyboard_data[4];

//    // (1) ∂Ùø¬ ∆«¡§
//    always_comb begin
//        is_locked_on = 0;
//        for (int k = 0; k < 16; k++) begin
//            if (aim_detected_all[k]) begin
//                if( (aim_x_all[k] > CX - LOCK_ZONE) && (aim_x_all[k] < CX + LOCK_ZONE) &&
//                    (aim_y_all[k] > CY - LOCK_ZONE) && (aim_y_all[k] < CY + LOCK_ZONE) ) begin
//                    is_locked_on = 1;
//                end
//            end
//        end
//    end

//    // (2) »≠∏È ±◊∏Æ±‚ ∑Œ¡˜
//    always_comb begin
//        on_box = 0; on_aim = 0; on_crosshair = 0;
//        is_wasd_ui = 0; is_wasd_char = 0; wasd_color = WHITE;
//        is_l_ui = 0; is_l_char = 0; is_lock_ui = 0; is_lock_icon = 0;
//        is_manual_ui = 0; is_manual_char = 0;

//        // A. ¡ﬂæ” ¡∂¡ÿº± (≈∏¿Ãπ÷ ¿ÃΩ¥ «ÿ∞·¿ª ¿ß«ÿ ¥‹º¯ ∫Ò±≥ ø¨ªÍ ªÁøÎ)
//        dx = (x_pixel > CX) ? (x_pixel - CX) : (CX - x_pixel);
//        dy = (y_pixel > CY) ? (y_pixel - CY) : (CY - y_pixel);
//        if ((dx < 2 && dy < 15) || (dy < 2 && dx < 15)) on_crosshair = 1;
//        if ((dx >= 33 && dx <= 35 && dy >= 20 && dy <= 35) || (dy >= 33 && dy <= 35 && dx >= 20 && dx <= 35)) on_crosshair = 1;

//        // B. ≈∏∞Ÿ π⁄Ω∫ π◊ ø°¿” ¡° (ø¯∫ª ∑Œ¡˜ ±◊¥Î∑Œ)
//        for (int i = 0; i < 16; i++) begin
//            if (aim_detected_all[i]) begin
//                if (((y_pixel == box_y_min_all[i] || y_pixel == box_y_max_all[i]) && (x_pixel >= box_x_min_all[i] && x_pixel <= box_x_max_all[i])) ||
//                    ((x_pixel == box_x_min_all[i] || x_pixel == box_x_max_all[i]) && (y_pixel >= box_y_min_all[i] && y_pixel <= box_y_max_all[i])))
//                    on_box = 1;
//                if ( (y_pixel >= aim_y_all[i]-1 && y_pixel <= aim_y_all[i]+1 && x_pixel >= aim_x_all[i]-5 && x_pixel <= aim_x_all[i]+5) ||
//                     (x_pixel >= aim_x_all[i]-1 && x_pixel <= aim_x_all[i]+1 && y_pixel >= aim_y_all[i]-5 && y_pixel <= aim_y_all[i]+5) )
//                    on_aim = 1;
//            end
//        end

//        // C. MANUAL UI (√ﬂ∞°µ» ±‚¥…)
////        if (x_pixel >= MANUAL_X && x_pixel < MANUAL_X + 116 && y_pixel >= MANUAL_Y && y_pixel < MANUAL_Y + 16) begin
////            is_manual_ui = 1;
////            rx = x_pixel - MANUAL_X; ry = (y_pixel - MANUAL_Y) >> 1;
////            if (rx < 16)                     begin if (CHAR_M[ry][7-(rx>>1)]) is_manual_char = 1; end
////            else if (rx >= 20 && rx < 36)    begin if (CHAR_A[ry][7-((rx-20)>>1)]) is_manual_char = 1; end
////            else if (rx >= 40 && rx < 56)    begin if (CHAR_N[ry][7-((rx-40)>>1)]) is_manual_char = 1; end
////            else if (rx >= 60 && rx < 76)    begin if (CHAR_U[ry][7-((rx-60)>>1)]) is_manual_char = 1; end
////            else if (rx >= 80 && rx < 96)    begin if (CHAR_A[ry][7-((rx-80)>>1)]) is_manual_char = 1; end
////            else if (rx >= 100 && rx < 116)  begin if (CHAR_L[ry][7-((rx-100)>>1)]) is_manual_char = 1; end
////        end
//        if (x_pixel >= (MANUAL_X - 10) && x_pixel < (MANUAL_X + 126) && 
//            y_pixel >= (MANUAL_Y - 8) && y_pixel < (MANUAL_Y + 24)) begin
            
//            is_manual_ui = 1;
//            rx = x_pixel - MANUAL_X; 
//            ry = (y_pixel - MANUAL_Y) >> 1; // 2πË »Æ¥Î∏¶ ¿ß«— bit shift
            
//            // Ω«¡¶ ±€¿⁄ ∫Ò∆Æ∏ ¿∫ ±‚¡∏ ±€¿⁄ øµø™(0~116, ry 0~7) ≥ªø°º≠∏∏ √‚∑¬µ«µµ∑œ ∫∏»£
//            if (ry >= 0 && ry < 8) begin
//                if (rx >= 0 && rx < 16)               begin if (CHAR_M[ry][7-(rx>>1)]) is_manual_char = 1; end
//                else if (rx >= 20 && rx < 36)         begin if (CHAR_A[ry][7-((rx-20)>>1)]) is_manual_char = 1; end
//                else if (rx >= 40 && rx < 56)         begin if (CHAR_N[ry][7-((rx-40)>>1)]) is_manual_char = 1; end
//                else if (rx >= 60 && rx < 76)         begin if (CHAR_U[ry][7-((rx-60)>>1)]) is_manual_char = 1; end
//                else if (rx >= 80 && rx < 96)         begin if (CHAR_A[ry][7-((rx-80)>>1)]) is_manual_char = 1; end
//                else if (rx >= 100 && rx < 116)       begin if (CHAR_L[ry][7-((rx-100)>>1)]) is_manual_char = 1; end
//            end
//        end


//        // D. WASD UI (ø¯∫ª ∫π±∏)
//        if (x_pixel >= WX1 && x_pixel < WX1 + KEY_SIZE && y_pixel >= WY1 && y_pixel < WY1 + KEY_SIZE) begin
//            is_wasd_ui = 1; wasd_color = keyboard_data[0] ? YELLOW : WHITE;
//            rx = x_pixel - WX1; ry = y_pixel - WY1;
//            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
//                if (CHAR_W[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
//        end else if (x_pixel >= AX1 && x_pixel < AX1 + KEY_SIZE && y_pixel >= AY1 && y_pixel < AY1 + KEY_SIZE) begin
//            is_wasd_ui = 1; wasd_color = keyboard_data[1] ? YELLOW : WHITE;
//            rx = x_pixel - AX1; ry = y_pixel - AY1;
//            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
//                if (CHAR_A[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
//        end else if (x_pixel >= SX1 && x_pixel < SX1 + KEY_SIZE && y_pixel >= SY1 && y_pixel < SY1 + KEY_SIZE) begin
//            is_wasd_ui = 1; wasd_color = keyboard_data[2] ? YELLOW : WHITE;
//            rx = x_pixel - SX1; ry = y_pixel - SY1;
//            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
//                if (CHAR_S[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
//        end else if (x_pixel >= DX1 && x_pixel < DX1 + KEY_SIZE && y_pixel >= DY1 && y_pixel < DY1 + KEY_SIZE) begin
//            is_wasd_ui = 1; wasd_color = keyboard_data[3] ? YELLOW : WHITE;
//            rx = x_pixel - DX1; ry = y_pixel - DY1;
//            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
//                if (CHAR_D[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
//        end

//        // E. L-Key & Lock UI (ø¯∫ª ∫π±∏)
//        if (x_pixel >= L_X && x_pixel < L_X + KEY_SIZE && y_pixel >= L_Y && y_pixel < L_Y + KEY_SIZE) begin
//            is_l_ui = 1; rx = x_pixel - L_X; ry = y_pixel - L_Y;
//            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
//                if (CHAR_L[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_l_char = 1;
//        end
//        if (x_pixel >= LOCK_UI_X && x_pixel < LOCK_UI_X + KEY_SIZE && y_pixel >= LOCK_UI_Y && y_pixel < LOCK_UI_Y + KEY_SIZE) begin
//            is_lock_ui = 1; rx = x_pixel - LOCK_UI_X; ry = y_pixel - LOCK_UI_Y;
//            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
//                if (ICON_LOCK[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_lock_icon = 1;
//        end
//    end

//    // (3) √÷¡æ ªˆªÛ ∞·¡§ (ø¯∫ª øÏº±º¯¿ß ±◊¥Î∑Œ)
//    always_comb begin
//        logic [11:0] color;
//        if (is_manual_ui)      color = is_manual_char ? BLACK : YELLOW;
//        else if (is_lock_ui)   color = is_lock_icon ? BLACK : (is_locked_on ? YELLOW : WHITE);
//        else if (is_wasd_ui)   color = is_wasd_char ? BLACK : wasd_color;
//        else if (is_l_ui)      color = is_l_char ? BLACK : (keyboard_data[4] ? YELLOW : WHITE);
//        else if (on_crosshair) color = is_locked_on ? WHITE : BLACK; // ¡∂¡ÿ Ω√ «œæ·ªˆ Ω ¿⁄∞°
//        else if (on_aim)       color = AIM_COLOR;
//        else if (on_box)       color = BOX_COLOR;
//        else                   color = img_bg;

//        {r_port, g_port, b_port} = color;
//    end
//endmodule

`timescale 1ns / 1ps

module pixel_mixer_manual (
    input logic [11:0] img_bg,

    // ≈∏∞Ÿ ¡§∫∏
    input logic [15:0][9:0] aim_x_all,
    input logic [15:0][9:0] aim_y_all,
    input logic [15:0]      aim_detected_all,

    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,

    // π⁄Ω∫ ¡§∫∏
    input logic [15:0][11:0] box_x_min_all,
    input logic [15:0][11:0] box_x_max_all,
    input logic [15:0][11:0] box_y_min_all,
    input logic [15:0][11:0] box_y_max_all,

    // ≈∞∫∏µÂ µ•¿Ã≈Õ (W:0, A:1, S:2, D:3, L:4)
    input logic [7:0] keyboard_data,
    
    // ∏≈Õ ∞¢µµ µ•¿Ã≈Õ (0~180µµ)
    input logic [9:0] motor_angle, 

    output logic [3:0] r_port, g_port, b_port,
    output logic [9:0] x_coor,
    output logic [9:0] y_coor,
    output logic       shoot
);
    // --- ªˆªÛ ¡§¿« ---
    localparam logic [11:0] RED    = 12'hF00, GREEN  = 12'h0F0;
    localparam logic [11:0] YELLOW = 12'hFF0, WHITE  = 12'hFFF;
    localparam logic [11:0] BLACK  = 12'h000, DARK_GREEN = 12'h040;

    // --- ∫Ò∆Æ∏  µ•¿Ã≈Õ ---
    localparam logic [0:7][7:0] CHAR_W = '{8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hDB, 8'hDB, 8'h66, 8'h00};
    localparam logic [0:7][7:0] CHAR_A = '{8'h3C, 8'h66, 8'hC3, 8'hFF, 8'hFF, 8'hC3, 8'hC3, 8'h00};
    localparam logic [0:7][7:0] CHAR_S = '{8'h7E, 8'hC3, 8'hC0, 8'h7E, 8'h03, 8'h03, 8'hC3, 8'h7E};
    localparam logic [0:7][7:0] CHAR_D = '{8'hFC, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hFC, 8'h00};
    localparam logic [0:7][7:0] CHAR_L = '{8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hFF, 8'hFF};
    localparam logic [0:7][7:0] CHAR_M = '{8'hC3, 8'hE7, 8'hDB, 8'hDB, 8'hC3, 8'hC3, 8'hC3, 8'h00};
    localparam logic [0:7][7:0] CHAR_N = '{8'hC3, 8'hE3, 8'hF3, 8'hDB, 8'hCF, 8'hC7, 8'hC3, 8'h00};
    localparam logic [0:7][7:0] CHAR_U = '{8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h7E, 8'h00};
    localparam logic [0:7][7:0] CHAR_L_MAN = '{8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hC0, 8'hFF, 8'hFF};
    localparam logic [0:7][7:0] ICON_LOCK = '{8'h3C, 8'h42, 8'h99, 8'hA5, 8'hA5, 8'h99, 8'h42, 8'h3C};

    // --- ªÁ¿Œ LUT ---
    localparam int unsigned SIN_LUT [0:90] = '{0, 18, 36, 54, 71, 89, 107, 125, 143, 160, 178, 195, 213, 230, 248, 265, 282, 299, 316, 333, 350, 367, 384, 400, 416, 433, 449, 465, 481, 496, 512, 527, 543, 558, 573, 587, 602, 616, 630, 644, 658, 672, 685, 698, 711, 724, 737, 749, 761, 773, 784, 796, 807, 818, 828, 839, 849, 859, 868, 878, 887, 896, 904, 912, 920, 928, 935, 943, 949, 956, 962, 968, 974, 979, 984, 989, 994, 998, 1002, 1005, 1008, 1011, 1014, 1016, 1018, 1020, 1022, 1023, 1023, 1024, 1024};

    // --- UI ∆ƒ∂ÛπÃ≈Õ (SX1, WY1, AY1 µÓ ø°∑Ø ∫Øºˆ ∫π±∏) ---
    localparam int KEY_SIZE = 30, GAP = 5, CHAR_OFFSET = 7;
    localparam int WASD_X = 30, WASD_Y = 380;
    localparam int AX1 = WASD_X, AY1 = WASD_Y + KEY_SIZE + GAP;
    localparam int SX1 = WASD_X + KEY_SIZE + GAP, SY1 = AY1;
    localparam int DX1 = WASD_X + 2 * (KEY_SIZE + GAP), DY1 = AY1;
    localparam int WX1 = SX1, WY1 = WASD_Y;
    localparam int L_X = 30, L_Y = 30, LOCK_UI_X = 580, LOCK_UI_Y = 30;
    localparam int CX = 320, CY = 240, LOCK_ZONE = 30;
    localparam int MANUAL_X = 260, MANUAL_Y = 15;
    localparam int RADAR_CX = 540, RADAR_CY = 460, RADAR_R = 100;

    // --- ≥ª∫Œ Ω≈»£ (ø°∑Ø πÊ¡ˆ∏¶ ¿ß«ÿ ∫Øºˆ º±æ∫Œ∏¶ ∏µ‚ ªÛ¥‹ø° πËƒ°) ---
    logic on_box, on_aim, on_crosshair, is_locked_on;
    logic is_wasd_ui, is_wasd_char, is_l_ui, is_l_char, is_lock_ui, is_lock_icon;
    logic is_manual_ui, is_manual_char;
    logic on_radar_bg, on_radar_grid, on_radar_needle;
    logic [11:0] wasd_color;
    int rx, ry, rdx, rdy, d_x, d_y, dist_sq;
    int theta, s_val, c_val;
    longint cross_v, dot_v;

    // «Ô∆€ «‘ºˆ
    function automatic int my_abs(input int val); return (val < 0) ? -val : val; endfunction

    // --- ≈∞∫∏µÂ π◊ ªÁ∞› Ω≈»£ ---
    assign y_coor = keyboard_data[0] ? 10'd190 : keyboard_data[2] ? 10'd290 : 10'd240;
    assign x_coor = keyboard_data[1] ? 10'd270 : keyboard_data[3] ? 10'd370 : 10'd320;
    assign shoot  = keyboard_data[4];

    // (1) ∂Ùø¬ ∆«¡§
    always_comb begin
        is_locked_on = 0;
        for (int k = 0; k < 16; k++) begin
            if (aim_detected_all[k]) begin
                if(my_abs(int'(aim_x_all[k]) - CX) < LOCK_ZONE && my_abs(int'(aim_y_all[k]) - CY) < LOCK_ZONE)
                    is_locked_on = 1;
            end
        end
    end

    // (2) »≠∏È ±◊∏Æ±‚ ∑Œ¡˜ (º¯¬˜ ø¨ªÍ π◊ ≈∏¿‘ ø¿∑˘ «ÿ∞·)
    always_comb begin
        on_box = 0; on_aim = 0; on_crosshair = 0;
        is_wasd_ui = 0; is_wasd_char = 0; wasd_color = WHITE;
        is_l_ui = 0; is_l_char = 0; is_lock_ui = 0; is_lock_icon = 0;
        is_manual_ui = 0; is_manual_char = 0;
        on_radar_bg = 0; on_radar_grid = 0; on_radar_needle = 0;

        // A. ¡ﬂæ” ∞Ì¡§ Ω ¿⁄∞°
        d_x = my_abs(int'(x_pixel) - CX); d_y = my_abs(int'(y_pixel) - CY);
        if ((d_x < 15 && d_y < 2) || (d_y < 15 && d_x < 2)) on_crosshair = 1;

        // B. ≈∏∞Ÿ π⁄Ω∫ π◊ ø°¿” ¡° (16∞≥ ¿¸√º ∞ÀªÁ)
        for (int i = 0; i < 16; i++) begin
            if (aim_detected_all[i]) begin
                if (((int'(y_pixel) == int'(box_y_min_all[i]) || int'(y_pixel) == int'(box_y_max_all[i])) && (int'(x_pixel) >= int'(box_x_min_all[i]) && int'(x_pixel) <= int'(box_x_max_all[i]))) ||
                    ((int'(x_pixel) == int'(box_x_min_all[i]) || int'(x_pixel) == int'(box_x_max_all[i])) && (int'(y_pixel) >= int'(box_y_min_all[i]) && int'(y_pixel) <= int'(box_y_max_all[i]))))
                    on_box = 1;
                if (my_abs(int'(x_pixel) - int'(aim_x_all[i])) < 10 && int'(y_pixel) == int'(aim_y_all[i]) ||
                    my_abs(int'(y_pixel) - int'(aim_y_all[i])) < 10 && int'(x_pixel) == int'(aim_x_all[i]))
                    on_aim = 1;
            end
        end

        // C. ∑π¿Ã¥ı UI ∑Œ¡˜ (≈∏¿Ãπ÷ ø°∑Ø ºˆ¡§ øœ∑·)
        rdx = int'(x_pixel) - RADAR_CX; rdy = RADAR_CY - int'(y_pixel);
        if (rdy >= 0 && my_abs(rdx) <= RADAR_R && rdy <= RADAR_R) begin
            dist_sq = rdx*rdx + rdy*rdy;
            if (dist_sq <= 10000) begin
                on_radar_bg = 1;
                if (dist_sq > 9604 || (dist_sq <= 2601 && dist_sq >= 2401) || rdx == 0 || rdy == 0) on_radar_grid = 1;
                
                // ¡ˆƒßº± ø¨ªÍ (πÿ¡Ÿ ø°∑Ø ø¯¿Œ «ÿ∞·)
                theta = 180 - ((motor_angle > 180) ? 180 : (motor_angle < 0 ? 0 : motor_angle));
                s_val = (theta <= 90) ? int'(SIN_LUT[theta]) : int'(SIN_LUT[180-theta]);
                c_val = (theta <= 90) ? int'(SIN_LUT[90-theta]) : -int'(SIN_LUT[theta-90]);
                cross_v = my_abs(int'(longint'(rdx) * s_val - longint'(rdy) * c_val));
                dot_v = longint'(rdx) * c_val + longint'(rdy) * s_val;
                if (dot_v >= 0 && cross_v <= 1536) on_radar_needle = 1;
            end
        end

        // D. MANUAL UI (≥Î∂ı πË∞Ê »Æ¿Â π◊ ¿‹ªÛ ¡¶∞≈)
        if (x_pixel >= (MANUAL_X - 10) && x_pixel < (MANUAL_X + 126) && 
            y_pixel >= (MANUAL_Y - 8) && y_pixel < (MANUAL_Y + 24)) begin
            is_manual_ui = 1; rx = int'(x_pixel) - MANUAL_X; ry = (int'(y_pixel) - MANUAL_Y) >> 1;
            if (ry >= 0 && ry < 8) begin
                if (rx >= 0 && rx < 16)               begin if (CHAR_M[ry][7-(rx>>1)]) is_manual_char = 1; end
                else if (rx >= 20 && rx < 36)         begin if (CHAR_A[ry][7-((rx-20)>>1)]) is_manual_char = 1; end
                else if (rx >= 40 && rx < 56)         begin if (CHAR_N[ry][7-((rx-40)>>1)]) is_manual_char = 1; end
                else if (rx >= 60 && rx < 76)         begin if (CHAR_U[ry][7-((rx-60)>>1)]) is_manual_char = 1; end
                else if (rx >= 80 && rx < 96)         begin if (CHAR_A[ry][7-((rx-80)>>1)]) is_manual_char = 1; end
                else if (rx >= 100 && rx < 116)       begin if (CHAR_L_MAN[ry][7-((rx-100)>>1)]) is_manual_char = 1; end
            end
        end

        // E. WASD & LOCK UI (ø°∑Ø «ÿ∞·µ» ∫Ì∑œ)
        if (x_pixel >= WX1 && x_pixel < WX1 + KEY_SIZE && y_pixel >= WY1 && y_pixel < WY1 + KEY_SIZE) begin
            is_wasd_ui = 1; wasd_color = keyboard_data[0] ? YELLOW : WHITE;
            rx = int'(x_pixel) - WX1; ry = int'(y_pixel) - WY1;
            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
                if (CHAR_W[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
        end else if (x_pixel >= AX1 && x_pixel < AX1 + KEY_SIZE && y_pixel >= AY1 && y_pixel < AY1 + KEY_SIZE) begin
            is_wasd_ui = 1; wasd_color = keyboard_data[1] ? YELLOW : WHITE;
            rx = int'(x_pixel) - AX1; ry = int'(y_pixel) - AY1;
            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
                if (CHAR_A[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
        end else if (x_pixel >= SX1 && x_pixel < SX1 + KEY_SIZE && y_pixel >= SY1 && y_pixel < SY1 + KEY_SIZE) begin
            is_wasd_ui = 1; wasd_color = keyboard_data[2] ? YELLOW : WHITE;
            rx = int'(x_pixel) - SX1; ry = int'(y_pixel) - SY1;
            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
                if (CHAR_S[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
        end else if (x_pixel >= DX1 && x_pixel < DX1 + KEY_SIZE && y_pixel >= DY1 && y_pixel < DY1 + KEY_SIZE) begin
            is_wasd_ui = 1; wasd_color = keyboard_data[3] ? YELLOW : WHITE;
            rx = int'(x_pixel) - DX1; ry = int'(y_pixel) - DY1;
            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
                if (CHAR_D[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_wasd_char = 1;
        end

        if (x_pixel >= L_X && x_pixel < L_X + KEY_SIZE && y_pixel >= L_Y && y_pixel < L_Y + KEY_SIZE) begin
            is_l_ui = 1; rx = int'(x_pixel) - L_X; ry = int'(y_pixel) - L_Y;
            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
                if (CHAR_L[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_l_char = 1;
        end
        if (x_pixel >= LOCK_UI_X && x_pixel < LOCK_UI_X + KEY_SIZE && y_pixel >= LOCK_UI_Y && y_pixel < LOCK_UI_Y + KEY_SIZE) begin
            is_lock_ui = 1; rx = int'(x_pixel) - LOCK_UI_X; ry = int'(y_pixel) - LOCK_UI_Y;
            if (rx>=CHAR_OFFSET && rx<CHAR_OFFSET+16 && ry>=CHAR_OFFSET && ry<CHAR_OFFSET+16)
                if (ICON_LOCK[(ry-CHAR_OFFSET)>>1][7-((rx-CHAR_OFFSET)>>1)]) is_lock_icon = 1;
        end
    end

    // (3) √÷¡æ ªˆªÛ √‚∑¬ (øÏº±º¯¿ß √÷¿˚»≠)
    always_comb begin
        logic [11:0] final_color;
        if (is_manual_ui)      final_color = is_manual_char ? BLACK : YELLOW;
        else if (is_lock_ui)   final_color = is_lock_icon ? BLACK : (is_locked_on ? YELLOW : WHITE);
        else if (is_wasd_ui)   final_color = is_wasd_char ? BLACK : wasd_color;
        else if (is_l_ui)      final_color = is_l_char ? BLACK : (keyboard_data[4] ? YELLOW : WHITE);
        else if (on_crosshair) final_color = is_locked_on ? WHITE : BLACK;
        else if (on_aim)       final_color = RED;
        else if (on_box)       final_color = GREEN;
        else if (on_radar_needle) final_color = RED;
        else if (on_radar_grid)   final_color = GREEN;
        else if (on_radar_bg)     final_color = DARK_GREEN;
        else                   final_color = img_bg;

        {r_port, g_port, b_port} = final_color;
    end
endmodule