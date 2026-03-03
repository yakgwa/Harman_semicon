//`timescale 1ns / 1ps

//module pixel_mixer_auto (
//    input logic [11:0] img_bg,  // Ïπ¥Î©î?ùº ?òÅ?ÉÅ

//    input logic [9:0] aim_x,        // Red Tracker?óê?Ñú ?ò® X Ï¢åÌëú
//    input logic [9:0] aim_y,        // Red Tracker?óê?Ñú ?ò® Y Ï¢åÌëú
//    input logic       aim_detected, // Í∞êÏ? ?ó¨Î∂?

//    input logic [9:0] x_pixel,  // ?òÑ?û¨ VGA ?îΩ?? X
//    input logic [9:0] y_pixel,  // ?òÑ?û¨ VGA ?îΩ?? Y

//    input logic [11:0] box_x_min,
//    input logic [11:0] box_x_max,
//    input logic [11:0] box_y_min,
//    input logic [11:0] box_y_max,

//    output logic [3:0] r_port,
//    output logic [3:0] g_port,
//    output logic [3:0] b_port,

//    output logic       shoot
//);

//    // --- ?Éâ?ÉÅ ?†ï?ùò ---
//    localparam logic [11:0] RED = 12'hF00;
//    localparam logic [11:0] GREEN = 12'h0F0;
//    localparam logic [11:0] BLUE = 12'h00F;
//    localparam logic [11:0] WHITE = 12'hFFF;
//    localparam logic [11:0] BLACK = 12'h000;
//    localparam logic [11:0] YELLOW = 12'hFF0;  // ?ùΩ?ò® ?ïåÎ¶? Î∞∞Í≤Ω?Éâ

//    localparam logic [11:0] AIM_COLOR = RED;
//    localparam logic [11:0] TEXT_COLOR = GREEN;
//    localparam logic [11:0] BOX_COLOR = GREEN;

//    // --- Îπ®Í∞Ñ Î¨ºÏ≤¥ Ï°∞Ï??†ê(?ã≠?ûê?Ñ†) ?Å¨Í∏? ---
//    localparam THK = 1;
//    localparam LEN = 10;

//    // --- Ï§ëÏïô Ï°∞Ï??Ñ† & ?ùΩ?ò® UI ?åå?ùºÎØ∏ÌÑ∞ ---
//    localparam int CX = 320;
//    localparam int CY = 240;
//    localparam int LOCK_ZONE = 30;  // ?ùΩ?ò® ?ù∏?ãù Î≤îÏúÑ (+/- 30?îΩ??)

//    // ?ö∞Ï∏? ?ÉÅ?ã® UI ?Å¨Í∏? Î∞? ?úÑÏπ?
//    localparam int KEY_SIZE = 30;
//    localparam int CHAR_OFFSET = (KEY_SIZE - 16) / 2;
//    localparam int LOCK_UI_X = 580;  // ?ö∞Ï∏? ?ÉÅ?ã®
//    localparam int LOCK_UI_Y = 30;

//    // --- Ï°∞Ï? ?ôÑÎ£? ?ïÑ?ù¥ÏΩ? (Í≥ºÎÖÅ Î™®Ïñë ÎπÑÌä∏Îß?) ---
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

//    // --- ?Ç¥Î∂? ?ã†?ò∏ ---
//    logic is_locked_on;
//    logic on_crosshair;
//    logic is_lock_ui, is_lock_icon;
//    logic [5:0] rel_x, rel_y;
//    logic [2:0] char_x, char_y;
//    int dist_x, dist_y;

//    // --- Ï¢åÌëú ?à´?ûê Í∑∏Î¶¨Í∏? (Seven Segment Style) ---
//    localparam w = 8;
//    localparam h = 16;
//    localparam scale = 2;

//    function logic draw_digit(input [3:0] num, input [9:0] px, input [9:0] py,
//                              input [9:0] ox, input [9:0] oy);
//        logic sa, sb, sc, sd, se, sf, sg, on;
//        int dx, dy;
//        dx = (px - ox) / scale;
//        dy = (py - oy) / scale;
//        if (dx < 0 || dx > w || dy < 0 || dy > h) return 0;
//        sa = (dy == 0) && (dx > 0 && dx < w);
//        sb = (dx == w) && (dy > 0 && dy < (h / 2));
//        sc = (dx == w) && (dy > (h / 2) && dy < h);
//        sd = (dy == h) && (dx > 0 && dx < w);
//        se = (dx == 0) && (dy > (h / 2) && dy < h);
//        sf = (dx == 0) && (dy > 0 && dy < (h / 2));
//        sg = (dy == (h / 2)) && (dx > 0 && dx < w);
//        case (num)
//            0: on = sa | sb | sc | sd | se | sf;
//            1: on = sb | sc;
//            2: on = sa | sb | sd | se | sg;
//            3: on = sa | sb | sc | sd | sg;
//            4: on = sb | sc | sf | sg;
//            5: on = sa | sc | sd | sf | sg;
//            6: on = sa | sc | sd | se | sf | sg;
//            7: on = sa | sb | sc | sf;
//            8: on = sa | sb | sc | sd | se | sf | sg;
//            9: on = sa | sb | sc | sd | sf | sg;
//            default: on = 0;
//        endcase
//        return on;
//    endfunction

//    // --- Ï¢åÌëú ?à´?ûê Ï∂îÏ∂ú Î°úÏßÅ ---
//    logic is_text_pixel;
//    logic [3:0] x_100, x_10, x_1;
//    logic [3:0] y_100, y_10, y_1;

//    assign x_100 = aim_x / 100;
//    assign x_10  = (aim_x / 10) % 10;
//    assign x_1   = aim_x % 10;

//    assign y_100 = aim_y / 100;
//    assign y_10  = (aim_y / 10) % 10;
//    assign y_1   = aim_y % 10;

//    // --- ?Öç?ä§?ä∏ ?†å?çîÎß? ?úÑÏπ? ?Ñ§?†ï ---
//    always_comb begin
//        is_text_pixel = 0;
//        if (draw_digit(x_100, x_pixel, y_pixel, 10, 10)) is_text_pixel = 1;
//        if (draw_digit(x_10, x_pixel, y_pixel, 30, 10)) is_text_pixel = 1;
//        if (draw_digit(x_1, x_pixel, y_pixel, 50, 10)) is_text_pixel = 1;

//        if (draw_digit(y_100, x_pixel, y_pixel, 10, 50)) is_text_pixel = 1;
//        if (draw_digit(y_10, x_pixel, y_pixel, 30, 50)) is_text_pixel = 1;
//        if (draw_digit(y_1, x_pixel, y_pixel, 50, 50)) is_text_pixel = 1;
//    end

//    // --- Î©îÏù∏ Í∑∏Îûò?îΩ Î°úÏßÅ ---
//    always_comb begin
//        // Ï¥àÍ∏∞?ôî
//        on_crosshair = 0;
//        is_lock_ui = 0;
//        is_lock_icon = 0;
//        is_locked_on = 0;
//        shoot        = 0;
//        rel_x = 0;
//        rel_y = 0;
//        char_x = 0;
//        char_y = 0;

//        // 1. ?ùΩ?ò® Í∞êÏ? (Îπ®Í∞Ñ Î¨ºÏ≤¥Í∞? Ï§ëÏïô Í∑ºÏ≤ò?óê ?ûà?äîÏß? ?ôï?ù∏)
//        if (aim_detected) begin
//            if ( (aim_x > CX - LOCK_ZONE) && (aim_x < CX + LOCK_ZONE) &&
//                 (aim_y > CY - LOCK_ZONE) && (aim_y < CY + LOCK_ZONE) ) begin
//                is_locked_on = 1;
//                shoot        = 1;
//            end
//        end

//        // 2. Ï§ëÏïô Ï°∞Ï??Ñ† Í∑∏Î¶¨Í∏? (Î≥¥ÎÇ¥Ï£ºÏã† ?ù¥ÎØ∏Ï? ?ä§???ùº)
//        dist_x = (x_pixel > CX) ? (x_pixel - CX) : (CX - x_pixel);
//        dist_y = (y_pixel > CY) ? (y_pixel - CY) : (CY - y_pixel);

//        // Ï§ëÏïô ?õê
//        if ((dist_x * dist_x + dist_y * dist_y) <= 36) on_crosshair = 1;
//        // ?Ç¥Î∂? ?ã≠?ûê?Ñ†
//        if (dist_x < 2 && dist_y >= 12 && dist_y <= 22) on_crosshair = 1;
//        if (dist_y < 2 && dist_x >= 12 && dist_x <= 22) on_crosshair = 1;
//        // ?ô∏Î∂? ÏΩîÎÑà Î∏åÎùºÏº?
//        if (dist_y >= 33 && dist_y <= 35 && dist_x >= 20 && dist_x <= 35)
//            on_crosshair = 1;
//        if (dist_x >= 33 && dist_x <= 35 && dist_y >= 20 && dist_y <= 35)
//            on_crosshair = 1;

//        // 3. ?ö∞Ï∏? ?ÉÅ?ã® ?ùΩ?ò® ?ïåÎ¶? UI
//        if (x_pixel >= LOCK_UI_X && x_pixel < LOCK_UI_X + KEY_SIZE && y_pixel >= LOCK_UI_Y && y_pixel < LOCK_UI_Y + KEY_SIZE) begin
//            is_lock_ui = 1;
//            rel_x = x_pixel - LOCK_UI_X;
//            rel_y = y_pixel - LOCK_UI_Y;
//            // ?ïÑ?ù¥ÏΩ? ÎπÑÌä∏Îß? Ï≤¥ÌÅ¨
//            if (rel_x >= CHAR_OFFSET && rel_x < CHAR_OFFSET + 16 && rel_y >= CHAR_OFFSET && rel_y < CHAR_OFFSET + 16) begin
//                char_x = (rel_x - CHAR_OFFSET) >> 1;
//                char_y = (rel_y - CHAR_OFFSET) >> 1;
//                if (ICON_LOCK[char_y][7-char_x]) is_lock_icon = 1;
//            end
//        end
//    end

//    // --- ÏµúÏ¢Ö ?îΩ?? ÎØπÏã± (?ö∞?Ñ†?àú?úÑ ?†Å?ö©) ---
//    always_comb begin
//        logic [11:0] pixel_color;

//        // ?ö∞?Ñ†?àú?úÑ 1: ?ö∞Ï∏? ?ÉÅ?ã® ?ùΩ?ò® ?ïåÎ¶?
//        if (is_lock_ui) begin
//            if (is_lock_icon)
//                pixel_color = BLACK;  // ?ïÑ?ù¥ÏΩòÏ? ?ï≠?ÉÅ Í≤????Éâ
//            else
//                pixel_color = is_locked_on ? YELLOW : WHITE; // Î∞∞Í≤Ω?? ?ùΩ?ò® ?ãú Ï£ºÌô©?Éâ, ?èâ?Üå ?ù∞?Éâ
//        end  // ?ö∞?Ñ†?àú?úÑ 2: Ï¢åÌëú ?Öç?ä§?ä∏ (Ï¢åÏ∏° ?ÉÅ?ã® Ï¥àÎ°ù ?à´?ûê)
//        else if (is_text_pixel) begin
//            pixel_color = TEXT_COLOR;
//        end  // ?ö∞?Ñ†?àú?úÑ 3: Ï§ëÏïô Ï°∞Ï??Ñ†
//        else if (on_crosshair) begin
//            pixel_color = BLACK;
//        end  // ?ö∞?Ñ†?àú?úÑ 4: ??Í≤? Î¨ºÏ≤¥?ùò Ï°∞Ï??†ê (Îπ®Í∞Ñ ?ã≠?ûê?Ñ†)
//        else if (aim_detected && 
//                 ( ((y_pixel >= aim_y - THK) && (y_pixel <= aim_y + THK) && (x_pixel >= aim_x - LEN) && (x_pixel <= aim_x + LEN)) ||
//                   ((x_pixel >= aim_x - THK) && (x_pixel <= aim_x + THK) && (y_pixel >= aim_y - LEN) && (y_pixel <= aim_y + LEN)) )) begin
//            pixel_color = AIM_COLOR;
//        end  // ?ö∞?Ñ†?àú?úÑ 5: ??Í≤? Î¨ºÏ≤¥?ùò Î∞îÏö¥?î© Î∞ïÏä§
//        else if (aim_detected && 
//                 ( ((y_pixel == box_y_min || y_pixel == box_y_max) && (x_pixel >= box_x_min && x_pixel <= box_x_max)) ||
//                   ((x_pixel == box_x_min || x_pixel == box_x_max) && (y_pixel >= box_y_min && y_pixel <= box_y_max)) )) begin
//            pixel_color = BOX_COLOR;
//        end  // 6. Í∏∞Î≥∏ Ïπ¥Î©î?ùº Î∞∞Í≤Ω
//        else begin
//            pixel_color = img_bg;
//        end

//        {r_port, g_port, b_port} = pixel_color;
//    end

//endmodule

//`timescale 1ns / 1ps

//module pixel_mixer_auto (
//    input logic [11:0] img_bg,  

//    input logic [9:0] aim_x,        
//    input logic [9:0] aim_y,        
//    input logic       aim_detected, 

//    input logic [9:0] x_pixel,  
//    input logic [9:0] y_pixel,  

//    input logic [11:0] box_x_min,
//    input logic [11:0] box_x_max,
//    input logic [11:0] box_y_min,
//    input logic [11:0] box_y_max,

//    output logic [3:0] r_port,
//    output logic [3:0] g_port,
//    output logic [3:0] b_port,

//    output logic       shoot
//);

//    // --- ªˆªÛ ¡§¿« ---
//    localparam logic [11:0] RED    = 12'hF00;
//    localparam logic [11:0] GREEN  = 12'h0F0;
//    localparam logic [11:0] WHITE  = 12'hFFF;
//    localparam logic [11:0] BLACK  = 12'h000;
//    localparam logic [11:0] YELLOW = 12'hFF0;

//    localparam logic [11:0] AIM_COLOR  = RED;
//    localparam logic [11:0] TEXT_COLOR = GREEN;
//    localparam logic [11:0] BOX_COLOR  = GREEN;

//    // --- AUTO πÆ±∏øÎ ∫Ò∆Æ∏  (8x8) ---
//    localparam logic [0:7][7:0] CHAR_A = '{8'b00111100, 8'b01100110, 8'b11000011, 8'b11111111, 8'b11111111, 8'b11000011, 8'b11000011, 8'b00000000};
//    localparam logic [0:7][7:0] CHAR_U = '{8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b01111110, 8'b00000000};
//    localparam logic [0:7][7:0] CHAR_T = '{8'b11111111, 8'b11111111, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00000000};
//    localparam logic [0:7][7:0] CHAR_O = '{8'b00111100, 8'b01100110, 8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b01100110, 8'b00111100};

//    localparam logic [0:7][7:0] ICON_LOCK = '{8'b00111100, 8'b01000010, 8'b10011001, 8'b10100101, 8'b10100101, 8'b10011001, 8'b01000010, 8'b00111100};

//    // --- UI ∆ƒ∂ÛπÃ≈Õ ---
//    localparam int CX = 320;
//    localparam int CY = 240;
//    localparam int LOCK_ZONE = 30;

//    localparam int LOCK_UI_X = 580;
//    localparam int LOCK_UI_Y = 30;
//    localparam int AUTO_X = 275; 
//    localparam int AUTO_Y = 15;
//    localparam int CHAR_SIZE = 16; 

//    // --- ≥ª∫Œ Ω≈»£ ---
//    logic is_locked_on;
//    logic on_crosshair;
//    logic is_lock_ui, is_lock_icon;
//    logic is_auto_ui, is_auto_char;
//    logic is_text_pixel;
    
//    // ∞ËªÍøÎ ∫Øºˆ (always_comb ≥ª∫Œ ø°∑Ø πÊ¡ˆ∏¶ ¿ß«ÿ πÃ∏Æ º±æ)
//    int dist_x, dist_y;
//    int auto_rel_x, auto_rel_y;
//    int lock_rel_x, lock_rel_y;
//    int char_idx;
//    logic [2:0] sub_x, sub_y;

//    // --- º˝¿⁄ ±◊∏Æ±‚ «‘ºˆ (Seven Segment) ---
//    function logic draw_digit(input [3:0] num, input [9:0] px, input [9:0] py, input [9:0] ox, input [9:0] oy);
//        logic sa, sb, sc, sd, se, sf, sg;
//        int dx, dy;
//        dx = (px - ox) / 2;
//        dy = (py - oy) / 2;
//        if (dx < 0 || dx > 8 || dy < 0 || dy > 16) return 0;
//        sa = (dy == 0) && (dx > 0 && dx < 8);
//        sb = (dx == 8) && (dy > 0 && dy < 8);
//        sc = (dx == 8) && (dy > 8 && dy < 16);
//        sd = (dy == 16) && (dx > 0 && dx < 8);
//        se = (dx == 0) && (dy > 8 && dy < 16);
//        sf = (dx == 0) && (dy > 0 && dy < 8);
//        sg = (dy == 8) && (dx > 0 && dx < 8);
//        case (num)
//            4'd0: return (sa | sb | sc | sd | se | sf);
//            4'd1: return (sb | sc);
//            4'd2: return (sa | sb | sd | se | sg);
//            4'd3: return (sa | sb | sc | sd | sg);
//            4'd4: return (sb | sc | sf | sg);
//            4'd5: return (sa | sc | sd | sf | sg);
//            4'd6: return (sa | sc | sd | se | sf | sg);
//            4'd7: return (sa | sb | sc | sf);
//            4'd8: return (sa | sb | sc | sd | se | sf | sg);
//            4'd9: return (sa | sb | sc | sd | sf | sg);
//            default: return 0;
//        endcase
//    endfunction

//    // --- ¡¬«• ≈ÿΩ∫∆Æ ∑π¿ÃæÓ ---
//    always_comb begin
//        is_text_pixel = draw_digit(aim_x/100, x_pixel, y_pixel, 10, 10) |
//                        draw_digit((aim_x/10)%10, x_pixel, y_pixel, 30, 10) |
//                        draw_digit(aim_x%10, x_pixel, y_pixel, 50, 10) |
//                        draw_digit(aim_y/100, x_pixel, y_pixel, 10, 50) |
//                        draw_digit((aim_y/10)%10, x_pixel, y_pixel, 30, 50) |
//                        draw_digit(aim_y%10, x_pixel, y_pixel, 50, 50);
//    end

//    // --- ±◊∑°«» ∑Œ¡˜ ---
//    always_comb begin
//        // ±‚∫ª∞™ √ ±‚»≠
//        on_crosshair = 0;
//        is_lock_ui   = 0;
//        is_lock_icon = 0;
//        is_locked_on = 0;
//        shoot        = 0;
//        is_auto_ui   = 0;
//        is_auto_char = 0;

//        // 1. ¡∂¡ÿ/ªÁ∞› ∆«¡§
//        if (aim_detected) begin
//            if ((aim_x > CX - LOCK_ZONE) && (aim_x < CX + LOCK_ZONE) &&
//                (aim_y > CY - LOCK_ZONE) && (aim_y < CY + LOCK_ZONE)) begin
//                is_locked_on = 1;
//                shoot = 1;
//            end
//        end

//        // 2. ¡ﬂæ” ¡∂¡ÿº± (Crosshair)
//        dist_x = (x_pixel > CX) ? (x_pixel - CX) : (CX - x_pixel);
//        dist_y = (y_pixel > CY) ? (y_pixel - CY) : (CY - y_pixel);
//        if ((dist_x**2 + dist_y**2) <= 36) on_crosshair = 1;
//        if (dist_x < 2 && dist_y >= 12 && dist_y <= 22) on_crosshair = 1;
//        if (dist_y < 2 && dist_x >= 12 && dist_x <= 22) on_crosshair = 1;
//        if (dist_y >= 33 && dist_y <= 35 && dist_x >= 20 && dist_x <= 35) on_crosshair = 1;
//        if (dist_x >= 33 && dist_x <= 35 && dist_y >= 20 && dist_y <= 35) on_crosshair = 1;

//        // 3. øÏªÛ¥‹ ∂Ùø¬ UI
//        if (x_pixel >= LOCK_UI_X && x_pixel < LOCK_UI_X + 30 && y_pixel >= LOCK_UI_Y && y_pixel < LOCK_UI_Y + 30) begin
//            is_lock_ui = 1;
//            lock_rel_x = x_pixel - LOCK_UI_X;
//            lock_rel_y = y_pixel - LOCK_UI_Y;
//            if (lock_rel_x >= 7 && lock_rel_x < 23 && lock_rel_y >= 7 && lock_rel_y < 23) begin
//                if (ICON_LOCK[(lock_rel_y-7)>>1][7-((lock_rel_x-7)>>1)]) is_lock_icon = 1;
//            end
//        end

//        // 4. ªÛ¥‹ ¡ﬂæ” AUTO UI (A-U-T-O)
//        if (x_pixel >= AUTO_X && x_pixel < AUTO_X + 80 && y_pixel >= AUTO_Y && y_pixel < AUTO_Y + 16) begin
//            is_auto_ui = 1;
//            auto_rel_x = x_pixel - AUTO_X;
//            auto_rel_y = y_pixel - AUTO_Y;
//            char_idx = auto_rel_x / 20; // 16px ±€¿⁄ + 4px ∞£∞›
//            sub_x = (auto_rel_x % 20) >> 1;
//            sub_y = auto_rel_y >> 1;

//            if (sub_x < 8) begin // ±€¿⁄ øµø™ ≥ªø°º≠∏∏ √º≈©
//                case (char_idx)
//                    0: if (CHAR_A[sub_y][7-sub_x]) is_auto_char = 1;
//                    1: if (CHAR_U[sub_y][7-sub_x]) is_auto_char = 1;
//                    2: if (CHAR_T[sub_y][7-sub_x]) is_auto_char = 1;
//                    3: if (CHAR_O[sub_y][7-sub_x]) is_auto_char = 1;
//                    default: is_auto_char = 0;
//                endcase
//            end
//        end
//    end

//    // --- √÷¡æ «»ºø √‚∑¬ ---
//    always_comb begin
//        logic [11:0] out_color;

//        if (is_auto_ui) begin
//            out_color = is_auto_char ? BLACK : YELLOW;
//        end else if (is_lock_ui) begin
//            if (is_lock_icon) out_color = BLACK;
//            else              out_color = is_locked_on ? YELLOW : WHITE;
//        end else if (is_text_pixel) begin
//            out_color = TEXT_COLOR;
//        end else if (on_crosshair) begin
//            out_color = BLACK;
//        end else if (aim_detected && 
//                 (((y_pixel >= aim_y - 1) && (y_pixel <= aim_y + 1) && (x_pixel >= (aim_x-10)) && (x_pixel <= (aim_x+10))) ||
//                  ((x_pixel >= aim_x - 1) && (x_pixel <= aim_x + 1) && (y_pixel >= (aim_y-10)) && (y_pixel <= (aim_y+10))))) begin
//            out_color = AIM_COLOR;
//        end else if (aim_detected && 
//                 (((y_pixel == box_y_min || y_pixel == box_y_max) && (x_pixel >= box_x_min && x_pixel <= box_x_max)) ||
//                  ((x_pixel == box_x_min || x_pixel == box_x_max) && (y_pixel >= box_y_min && y_pixel <= box_y_max)))) begin
//            out_color = BOX_COLOR;
//        end else begin
//            out_color = img_bg;
//        end

//        r_port = out_color[11:8];
//        g_port = out_color[7:4];
//        b_port = out_color[3:0];
//    end

//endmodule

`timescale 1ns / 1ps

module pixel_mixer_auto (
    input logic [11:0] img_bg,  

    input logic [9:0] aim_x,        
    input logic [9:0] aim_y,        
    input logic       aim_detected, 

    input logic [9:0] x_pixel,  
    input logic [9:0] y_pixel,  

    input logic [11:0] box_x_min,
    input logic [11:0] box_x_max,
    input logic [11:0] box_y_min,
    input logic [11:0] box_y_max,

    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port,

    output logic       shoot
);

    // --- ªˆªÛ ¡§¿« (±‚¡∏ ¿Ø¡ˆ) ---
    localparam logic [11:0] RED    = 12'hF00;
    localparam logic [11:0] GREEN  = 12'h0F0;
    localparam logic [11:0] WHITE  = 12'hFFF;
    localparam logic [11:0] BLACK  = 12'h000;
    localparam logic [11:0] YELLOW = 12'hFF0;

    localparam logic [11:0] AIM_COLOR  = RED;
    localparam logic [11:0] TEXT_COLOR = GREEN;
    localparam logic [11:0] BOX_COLOR  = GREEN;

    // --- AUTO πÆ±∏øÎ ∫Ò∆Æ∏  (8x8) ---
    localparam logic [0:7][7:0] CHAR_A = '{8'b00111100, 8'b01100110, 8'b11000011, 8'b11111111, 8'b11111111, 8'b11000011, 8'b11000011, 8'b00000000};
    localparam logic [0:7][7:0] CHAR_U = '{8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b01111110, 8'b00000000};
    localparam logic [0:7][7:0] CHAR_T = '{8'b11111111, 8'b11111111, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00011000, 8'b00000000};
    localparam logic [0:7][7:0] CHAR_O = '{8'b00111100, 8'b01100110, 8'b11000011, 8'b11000011, 8'b11000011, 8'b11000011, 8'b01100110, 8'b00111100};

    localparam logic [0:7][7:0] ICON_LOCK = '{8'b00111100, 8'b01000010, 8'b10011001, 8'b10100101, 8'b10100101, 8'b10011001, 8'b01000010, 8'b00111100};

    // --- UI ∆ƒ∂ÛπÃ≈Õ ---
    localparam int CX = 320;
    localparam int CY = 240;
    localparam int LOCK_ZONE = 30;

    localparam int LOCK_UI_X = 580;
    localparam int LOCK_UI_Y = 30;
    localparam int AUTO_X = 275;  
    localparam int AUTO_Y = 15;

    // --- ≥ª∫Œ Ω≈»£ ---
    logic is_locked_on;
    logic on_crosshair;
    logic is_lock_ui, is_lock_icon;
    logic is_auto_ui, is_auto_char;
    logic is_text_pixel;
    
    int dist_x, dist_y;
    int auto_rx, auto_ry; // auto_rx ∫Øºˆ º±æ »Æ¿Œ
    int lock_rel_x, lock_rel_y;

    // --- º˝¿⁄ ±◊∏Æ±‚ «‘ºˆ (±‚¡∏ ¿Ø¡ˆ) ---
    function logic draw_digit(input [3:0] num, input [9:0] px, input [9:0] py, input [9:0] ox, input [9:0] oy);
        logic sa, sb, sc, sd, se, sf, sg;
        int dx, dy;
        dx = (px - ox) / 2;
        dy = (py - oy) / 2;
        if (dx < 0 || dx > 8 || dy < 0 || dy > 16) return 0;
        sa = (dy == 0) && (dx > 0 && dx < 8);
        sb = (dx == 8) && (dy > 0 && dy < 8);
        sc = (dx == 8) && (dy > 8 && dy < 16);
        sd = (dy == 16) && (dx > 0 && dx < 8);
        se = (dx == 0) && (dy > 8 && dy < 16);
        sf = (dx == 0) && (dy > 0 && dy < 8);
        sg = (dy == 8) && (dx > 0 && dx < 8);
        case (num)
            4'd0: return (sa | sb | sc | sd | se | sf);
            4'd1: return (sb | sc);
            4'd2: return (sa | sb | sd | se | sg);
            4'd3: return (sa | sb | sc | sd | sg);
            4'd4: return (sb | sc | sf | sg);
            4'd5: return (sa | sc | sd | sf | sg);
            4'd6: return (sa | sc | sd | se | sf | sg);
            4'd7: return (sa | sb | sc | sf);
            4'd8: return (sa | sb | sc | sd | se | sf | sg);
            4'd9: return (sa | sb | sc | sd | sf | sg);
            default: return 0;
        endcase
    endfunction

    // --- ¡¬«• ≈ÿΩ∫∆Æ ∑π¿ÃæÓ (±‚¡∏ ¿Ø¡ˆ) ---
    always_comb begin
        is_text_pixel = draw_digit(aim_x/100, x_pixel, y_pixel, 10, 10) |
                        draw_digit((aim_x/10)%10, x_pixel, y_pixel, 30, 10) |
                        draw_digit(aim_x%10, x_pixel, y_pixel, 50, 10) |
                        draw_digit(aim_y/100, x_pixel, y_pixel, 10, 50) |
                        draw_digit((aim_y/10)%10, x_pixel, y_pixel, 30, 50) |
                        draw_digit(aim_y%10, x_pixel, y_pixel, 50, 50);
    end

    // --- ±◊∑°«» ∑Œ¡˜ ---
    always_comb begin
        // ±‚∫ª∞™ √ ±‚»≠
        on_crosshair = 0;
        is_lock_ui   = 0;
        is_lock_icon = 0;
        is_locked_on = 0;
        shoot        = 0;
        is_auto_ui   = 0;
        is_auto_char = 0;

        // 1. ¡∂¡ÿ/ªÁ∞› ∆«¡§ (±‚¡∏ ¿Ø¡ˆ)
        if (aim_detected) begin
            if ((aim_x > CX - LOCK_ZONE) && (aim_x < CX + LOCK_ZONE) &&
                (aim_y > CY - LOCK_ZONE) && (aim_y < CY + LOCK_ZONE)) begin
                is_locked_on = 1;
                shoot = 1;
            end
        end

        // 2. ¡ﬂæ” ¡∂¡ÿº± (±‚¡∏ ¿Ø¡ˆ)
        dist_x = (x_pixel > CX) ? (x_pixel - CX) : (CX - x_pixel);
        dist_y = (y_pixel > CY) ? (y_pixel - CY) : (CY - y_pixel);
        if ((dist_x**2 + dist_y**2) <= 36) on_crosshair = 1;
        if (dist_x < 2 && dist_y >= 12 && dist_y <= 22) on_crosshair = 1;
        if (dist_y < 2 && dist_x >= 12 && dist_x <= 22) on_crosshair = 1;
        if (dist_y >= 33 && dist_y <= 35 && dist_x >= 20 && dist_x <= 35) on_crosshair = 1;
        if (dist_x >= 33 && dist_x <= 35 && dist_y >= 20 && dist_y <= 35) on_crosshair = 1;

        // 3. øÏªÛ¥‹ ∂Ùø¬ UI (±‚¡∏ ¿Ø¡ˆ)
        if (x_pixel >= LOCK_UI_X && x_pixel < LOCK_UI_X + 30 && y_pixel >= LOCK_UI_Y && y_pixel < LOCK_UI_Y + 30) begin
            is_lock_ui = 1;
            lock_rel_x = x_pixel - LOCK_UI_X;
            lock_rel_y = y_pixel - LOCK_UI_Y;
            if (lock_rel_x >= 7 && lock_rel_x < 23 && lock_rel_y >= 7 && lock_rel_y < 23) begin
                if (ICON_LOCK[(lock_rel_y-7)>>1][7-((lock_rel_x-7)>>1)]) is_lock_icon = 1;
            end
        end

        // 4. ªÛ¥‹ ¡ﬂæ” AUTO UI (¬ıæÓ¡¸ «ÿ∞· π◊ ∫Øºˆ∏Ì auto_rx ≈Î¿œ)
        if (x_pixel >= AUTO_X && x_pixel < AUTO_X + 76 && y_pixel >= AUTO_Y && y_pixel < AUTO_Y + 16) begin
            is_auto_ui = 1;
            auto_rx = x_pixel - AUTO_X;
            auto_ry = y_pixel - AUTO_Y;
            
            if (auto_rx < 16) begin // 'A'
                if (CHAR_A[auto_ry >> 1][7-(auto_rx >> 1)]) is_auto_char = 1;
            end 
            else if (auto_rx >= 20 && auto_rx < 36) begin // 'U'
                if (CHAR_U[auto_ry >> 1][7-((auto_rx - 20) >> 1)]) is_auto_char = 1;
            end 
            else if (auto_rx >= 40 && auto_rx < 56) begin // 'T'
                if (CHAR_T[auto_ry >> 1][7-((auto_rx - 40) >> 1)]) is_auto_char = 1;
            end 
            else if (auto_rx >= 60 && auto_rx < 76) begin // 'O'
                if (CHAR_O[auto_ry >> 1][7-((auto_rx - 60) >> 1)]) is_auto_char = 1;
            end
        end
    end

    // --- √÷¡æ «»ºø √‚∑¬ (±‚¡∏ ¿Ø¡ˆ) ---
    always_comb begin
        logic [11:0] out_color;

        if (is_auto_ui) begin
            out_color = is_auto_char ? BLACK : YELLOW;
        end else if (is_lock_ui) begin
            if (is_lock_icon) out_color = BLACK;
            else              out_color = is_locked_on ? YELLOW : WHITE;
        end else if (is_text_pixel) begin
            out_color = TEXT_COLOR;
        end else if (on_crosshair) begin
            out_color = BLACK;
        end else if (aim_detected && 
                 (((y_pixel >= aim_y - 1) && (y_pixel <= aim_y + 1) && (x_pixel >= (aim_x-10)) && (x_pixel <= (aim_x+10))) ||
                  ((x_pixel >= aim_x - 1) && (x_pixel <= aim_x + 1) && (y_pixel >= (aim_y-10)) && (y_pixel <= (aim_y+10))))) begin
            out_color = AIM_COLOR;
        end else if (aim_detected && 
                 (((y_pixel == box_y_min || y_pixel == box_y_max) && (x_pixel >= box_x_min && x_pixel <= box_x_max)) ||
                  ((x_pixel == box_x_min || x_pixel == box_x_max) && (y_pixel >= box_y_min && y_pixel <= box_y_max)))) begin
            out_color = BOX_COLOR;
        end else begin
            out_color = img_bg;
        end

        r_port = out_color[11:8];
        g_port = out_color[7:4];
        b_port = out_color[3:0];
    end

endmodule
