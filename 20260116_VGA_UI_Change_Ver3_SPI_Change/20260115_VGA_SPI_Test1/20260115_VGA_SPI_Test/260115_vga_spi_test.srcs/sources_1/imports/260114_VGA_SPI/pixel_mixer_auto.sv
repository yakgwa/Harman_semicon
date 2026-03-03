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

//`timescale 1ns / 1ps

//module pixel_mixer_auto (
//    input logic [11:0] img_bg,  

//    input logic [9:0] aim_x, aim_y,        
//    input logic       aim_detected, 

//    input logic [9:0] x_pixel, y_pixel,  

//    input logic [11:0] box_x_min, box_x_max,
//    input logic [11:0] box_y_min, box_y_max,
    
//    input logic [9:0] motor_angle, 

//    output logic [3:0] r_port, g_port, b_port,
//    output logic       shoot
//);

//    // --- ªˆªÛ ¡§¿« ---
//    localparam logic [11:0] RED = 12'hF00, GREEN = 12'h0F0, WHITE = 12'hFFF, BLACK = 12'h000;
//    localparam logic [11:0] YELLOW = 12'hFF0, DARK_GREEN = 12'h040;

//    // --- ∫Ò∆Æ∏  µ•¿Ã≈Õ ---
//    localparam logic [0:7][7:0] CHAR_A = '{8'h3C, 8'h66, 8'hC3, 8'hFF, 8'hFF, 8'hC3, 8'hC3, 8'h00};
//    localparam logic [0:7][7:0] CHAR_U = '{8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h7E, 8'h00};
//    localparam logic [0:7][7:0] CHAR_T = '{8'hFF, 8'hFF, 8'h18, 8'h18, 8'h18, 8'h18, 8'h18, 8'h00};
//    localparam logic [0:7][7:0] CHAR_O = '{8'h3C, 8'h66, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h66, 8'h3C};
//    localparam logic [0:7][7:0] ICON_LOCK = '{8'h3C, 8'h42, 8'h99, 8'hA5, 8'hA5, 8'h99, 8'h42, 8'h3C};

//    // --- UI ∆ƒ∂ÛπÃ≈Õ ---
//    localparam int CX = 320, CY = 240, LOCK_ZONE = 30;
//    localparam int AUTO_X = 275, AUTO_Y = 15;
//    localparam int RADAR_CX = 540, RADAR_CY = 460, RADAR_R = 100;

//    // --- ªÁ¿Œ LUT ---
//    localparam int unsigned SIN_LUT [0:90] = '{0, 18, 36, 54, 71, 89, 107, 125, 143, 160, 178, 195, 213, 230, 248, 265, 282, 299, 316, 333, 350, 367, 384, 400, 416, 433, 449, 465, 481, 496, 512, 527, 543, 558, 573, 587, 602, 616, 630, 644, 658, 672, 685, 698, 711, 724, 737, 749, 761, 773, 784, 796, 807, 818, 828, 839, 849, 859, 868, 878, 887, 896, 904, 912, 920, 928, 935, 943, 949, 956, 962, 968, 974, 979, 984, 989, 994, 998, 1002, 1005, 1008, 1011, 1014, 1016, 1018, 1020, 1022, 1023, 1023, 1024, 1024};

//    // --- ≥ª∫Œ Ω≈»£ ---
//    logic is_locked_on, on_crosshair, is_auto_ui, is_auto_char, is_text_pixel;
//    logic on_radar_bg, on_radar_grid, on_radar_needle;
//    logic is_lock_ui, is_lock_icon;
//    int dist_x, dist_y, radar_dx, radar_dy, auto_rx, auto_ry, lock_rx, lock_ry;

//    // ¿˝¥Î∞™ «Ô∆€ «‘ºˆ
//    function automatic int my_abs(input int val); return (val < 0) ? -val : val; endfunction

//    // 1. ≈∏∞Ÿ π◊ ¡∂¡ÿ ∆«¡§
//    always_comb begin
//        is_locked_on = (aim_detected && my_abs(int'(aim_x) - CX) < LOCK_ZONE && my_abs(int'(aim_y) - CY) < LOCK_ZONE);
//        shoot = is_locked_on;
        
//        // ¡ﬂæ” Ω ¿⁄∞° ∆«¡§ (∞ˆº¿ ¡¶∞≈)
//        dist_x = my_abs(int'(x_pixel) - CX); dist_y = my_abs(int'(y_pixel) - CY);
//        on_crosshair = ((dist_x < 15 && dist_y < 2) || (dist_y < 15 && dist_x < 2));
//    end

//    // 2. UI ø‰º“ ∑Œ¡˜
//    always_comb begin
//        // AUTO πË∞Ê »Æ¿Â
//        is_auto_ui = (x_pixel >= AUTO_X-10 && x_pixel < AUTO_X+86 && y_pixel >= AUTO_Y-8 && y_pixel < AUTO_Y+24);
//        auto_rx = int'(x_pixel) - AUTO_X; auto_ry = int'(y_pixel) - AUTO_Y;
//        is_auto_char = 0;
//        if (auto_ry >= 0 && auto_ry < 16) begin
//            if (auto_rx >= 0 && auto_rx < 16)            is_auto_char = CHAR_A[auto_ry>>1][7-(auto_rx>>1)];
//            else if (auto_rx >= 20 && auto_rx < 36)      is_auto_char = CHAR_U[auto_ry>>1][7-((auto_rx-20)>>1)];
//            else if (auto_rx >= 40 && auto_rx < 56)      is_auto_char = CHAR_T[auto_ry>>1][7-((auto_rx-40)>>1)];
//            else if (auto_rx >= 60 && auto_rx < 76)      is_auto_char = CHAR_O[auto_ry>>1][7-((auto_rx-60)>>1)];
//        end

//        // LOCK æ∆¿Ãƒ‹
//        is_lock_ui = (x_pixel >= 580 && x_pixel < 610 && y_pixel >= 30 && y_pixel < 60);
//        is_lock_icon = 0;
//        if (is_lock_ui) begin
//            lock_rx = int'(x_pixel) - 580; lock_ry = int'(y_pixel) - 30;
//            if (lock_rx >= 7 && lock_rx < 23 && lock_ry >= 7 && lock_ry < 23)
//                is_lock_icon = ICON_LOCK[(lock_ry-7)>>1][7-((lock_rx-7)>>1)];
//        end
//    end

//    // 3. ∑π¿Ã¥ı ∑Œ¡˜ (√÷¿˚»≠)
//    always_comb begin
//        radar_dx = int'(x_pixel) - RADAR_CX;
//        radar_dy = RADAR_CY - int'(y_pixel);
//        on_radar_bg = 0; on_radar_grid = 0; on_radar_needle = 0;

//        // ∑π¿Ã¥ı øµø™ æ»¿œ ∂ß∏∏ π´∞≈øÓ ø¨ªÍ ºˆ«‡
//        if (radar_dy >= 0 && my_abs(radar_dx) <= RADAR_R && radar_dy <= RADAR_R) begin
//            int dist_sq = radar_dx*radar_dx + radar_dy*radar_dy;
//            if (dist_sq <= 10000) begin
//                on_radar_bg = 1;
//                if (dist_sq > 9600 || (dist_sq <= 2601 && dist_sq >= 2401)) on_radar_grid = 1;
//                if (radar_dx == 0 || radar_dy == 0) on_radar_grid = 1;

//                begin
//                    int theta, s, c; longint cross_v, dot_v;
//                    theta = 180 - ((motor_angle > 180) ? 180 : (motor_angle < 0 ? 0 : motor_angle));
//                    s = (theta <= 90) ? int'(SIN_LUT[theta]) : int'(SIN_LUT[180-theta]);
//                    c = (theta <= 90) ? int'(SIN_LUT[90-theta]) : -int'(SIN_LUT[theta-90]);
//                    cross_v = my_abs(longint'(radar_dx) * s - longint'(radar_dy) * c);
//                    dot_v = longint'(radar_dx) * c + longint'(radar_dy) * s;
//                    if (dot_v >= 0 && cross_v <= 1536) on_radar_needle = 1;
//                end
//            end
//        end
//    end

//    // 4. √÷¡æ √‚∑¬ »•«’
//    always_comb begin
//        logic [11:0] res_color;
//        if (is_auto_ui)           res_color = is_auto_char ? BLACK : YELLOW;
//        else if (is_lock_ui)      res_color = is_lock_icon ? BLACK : (is_locked_on ? YELLOW : WHITE);
//        else if (on_crosshair)    res_color = BLACK;
//        else if (on_radar_needle) res_color = RED;
//        else if (on_radar_grid)   res_color = GREEN;
//        else if (on_radar_bg)     res_color = DARK_GREEN;
//        else if (aim_detected && (
//            ((int'(x_pixel) == box_x_min || int'(x_pixel) == box_x_max) && int'(y_pixel) >= box_y_min && int'(y_pixel) <= box_y_max) ||
//            ((int'(y_pixel) == box_y_min || int'(y_pixel) == box_y_max) && int'(x_pixel) >= box_x_min && int'(x_pixel) <= box_x_max)
//        ))                        res_color = GREEN;
//        else                      res_color = img_bg;

//        {r_port, g_port, b_port} = res_color;
//    end

//endmodule

//`timescale 1ns / 1ps

//module pixel_mixer_auto (
//    input logic [11:0] img_bg,  

//    input logic [9:0] aim_x, aim_y,        
//    input logic       aim_detected, 

//    input logic [9:0] x_pixel, y_pixel,  

//    input logic [11:0] box_x_min, box_x_max,
//    input logic [11:0] box_y_min, box_y_max,
    
//    input logic [9:0] motor_angle, 

//    output logic [3:0] r_port, g_port, b_port,
//    output logic       shoot
//);

//    // --- ªˆªÛ ¡§¿« ---
//    localparam logic [11:0] RED = 12'hF00, GREEN = 12'h0F0, WHITE = 12'hFFF, BLACK = 12'h000;
//    localparam logic [11:0] YELLOW = 12'hFF0, DARK_GREEN = 12'h040;

//    // --- ∫Ò∆Æ∏  µ•¿Ã≈Õ ---
//    localparam logic [0:7][7:0] CHAR_A = '{8'h3C, 8'h66, 8'hC3, 8'hFF, 8'hFF, 8'hC3, 8'hC3, 8'h00};
//    localparam logic [0:7][7:0] CHAR_U = '{8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h7E, 8'h00};
//    localparam logic [0:7][7:0] CHAR_T = '{8'hFF, 8'hFF, 8'h18, 8'h18, 8'h18, 8'h18, 8'h18, 8'h00};
//    localparam logic [0:7][7:0] CHAR_O = '{8'h3C, 8'h66, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h66, 8'h3C};
//    localparam logic [0:7][7:0] ICON_LOCK = '{8'h3C, 8'h42, 8'h99, 8'hA5, 8'hA5, 8'h99, 8'h42, 8'h3C};

//    // --- UI ∆ƒ∂ÛπÃ≈Õ ---
//    localparam int CX = 320, CY = 240, LOCK_ZONE = 30;
//    localparam int AUTO_X = 275, AUTO_Y = 15;
//    localparam int RADAR_CX = 540, RADAR_CY = 460, RADAR_R = 100;

//    // --- ªÁ¿Œ LUT ---
//    localparam int unsigned SIN_LUT [0:90] = '{0, 18, 36, 54, 71, 89, 107, 125, 143, 160, 178, 195, 213, 230, 248, 265, 282, 299, 316, 333, 350, 367, 384, 400, 416, 433, 449, 465, 481, 496, 512, 527, 543, 558, 573, 587, 602, 616, 630, 644, 658, 672, 685, 698, 711, 724, 737, 749, 761, 773, 784, 796, 807, 818, 828, 839, 849, 859, 868, 878, 887, 896, 904, 912, 920, 928, 935, 943, 949, 956, 962, 968, 974, 979, 984, 989, 994, 998, 1002, 1005, 1008, 1011, 1014, 1016, 1018, 1020, 1022, 1023, 1023, 1024, 1024};

//    // --- ≥ª∫Œ Ω≈»£ ---
//    logic is_locked_on, on_crosshair, is_auto_ui, is_auto_char, is_text_pixel;
//    logic on_radar_bg, on_radar_grid, on_radar_needle;
//    logic is_lock_ui, is_lock_icon;
//    int dist_x, dist_y, radar_dx, radar_dy, auto_rx, auto_ry, lock_rx, lock_ry;

//    // ¿˝¥Î∞™ «Ô∆€ «‘ºˆ
//    function automatic int my_abs(input int val); return (val < 0) ? -val : val; endfunction

//    // º˝¿⁄ ±◊∏Æ±‚ «‘ºˆ
//    function automatic logic draw_digit(input [3:0] num, input [9:0] px, input [9:0] py, input [9:0] ox, input [9:0] oy);
//        logic sa, sb, sc, sd, se, sf, sg;
//        int ddx = int'(px) - int'(ox); int ddy = int'(py) - int'(oy);
//        ddx = ddx / 2; ddy = ddy / 2;
//        if (ddx < 0 || ddx > 8 || ddy < 0 || ddy > 16) return 0;
//        sa = (ddy == 0) && (ddx > 0 && ddx < 8); sb = (ddx == 8) && (ddy > 0 && ddy < 8);
//        sc = (ddx == 8) && (ddy > 8 && ddy < 16); sd = (ddy == 16) && (ddx > 0 && ddx < 8);
//        se = (ddx == 0) && (ddy > 8 && ddy < 16); sf = (ddx == 0) && (ddy > 0 && ddy < 8);
//        sg = (ddy == 8) && (ddx > 0 && ddx < 8);
//        case (num)
//            0: return sa|sb|sc|sd|se|sf; 1: return sb|sc; 2: return sa|sb|sd|se|sg;
//            3: return sa|sb|sc|sd|sg; 4: return sb|sc|sf|sg; 5: return sa|sc|sd|sf|sg;
//            6: return sa|sc|sd|se|sf|sg; 7: return sa|sb|sc|sf; 8: return sa|sb|sc|sd|se|sf|sg;
//            9: return sa|sb|sc|sd|sf|sg; default: return 0;
//        endcase
//    endfunction

//    // 1. ≈∏∞Ÿ π◊ ¡∂¡ÿ ∆«¡§ ∑π¿ÃæÓ
//    always_comb begin
//        is_locked_on = (aim_detected && my_abs(int'(aim_x) - CX) < LOCK_ZONE && my_abs(int'(aim_y) - CY) < LOCK_ZONE);
//        shoot = is_locked_on;
        
//        // ¡ﬂæ” Ω ¿⁄∞° (≈∏¿Ãπ÷ √÷¿˚»≠)
//        dist_x = my_abs(int'(x_pixel) - CX); dist_y = my_abs(int'(y_pixel) - CY);
//        on_crosshair = ((dist_x < 15 && dist_y < 2) || (dist_y < 15 && dist_x < 2));

//        // [∫π±∏µ ] ¡¬«• ≈ÿΩ∫∆Æ ∑π¿ÃæÓ ª˝º∫
//        is_text_pixel = draw_digit(aim_x/100, x_pixel, y_pixel, 10, 10) |
//                        draw_digit((aim_x/10)%10, x_pixel, y_pixel, 30, 10) |
//                        draw_digit(aim_x%10, x_pixel, y_pixel, 50, 10) |
//                        draw_digit(aim_y/100, x_pixel, y_pixel, 10, 50) |
//                        draw_digit((aim_y/10)%10, x_pixel, y_pixel, 30, 50) |
//                        draw_digit(aim_y%10, x_pixel, y_pixel, 50, 50);
//    end

//    // 2. UI ø‰º“ ∑Œ¡˜ (AUTO, LOCK)
//    always_comb begin
//        is_auto_ui = (x_pixel >= AUTO_X-10 && x_pixel < AUTO_X+86 && y_pixel >= AUTO_Y-8 && y_pixel < AUTO_Y+24);
//        auto_rx = int'(x_pixel) - AUTO_X; auto_ry = int'(y_pixel) - AUTO_Y;
//        is_auto_char = 0;
//        if (auto_ry >= 0 && auto_ry < 16) begin
//            if (auto_rx >= 0 && auto_rx < 16)            is_auto_char = CHAR_A[auto_ry>>1][7-(auto_rx>>1)];
//            else if (auto_rx >= 20 && auto_rx < 36)      is_auto_char = CHAR_U[auto_ry>>1][7-((auto_rx-20)>>1)];
//            else if (auto_rx >= 40 && auto_rx < 56)      is_auto_char = CHAR_T[auto_ry>>1][7-((auto_rx-40)>>1)];
//            else if (auto_rx >= 60 && auto_rx < 76)      is_auto_char = CHAR_O[auto_ry>>1][7-((auto_rx-60)>>1)];
//        end

//        is_lock_ui = (x_pixel >= 580 && x_pixel < 610 && y_pixel >= 30 && y_pixel < 60);
//        is_lock_icon = 0;
//        if (is_lock_ui) begin
//            lock_rx = int'(x_pixel) - 580; lock_ry = int'(y_pixel) - 30;
//            if (lock_rx >= 7 && lock_rx < 23 && lock_ry >= 7 && lock_ry < 23)
//                is_lock_icon = ICON_LOCK[(lock_ry-7)>>1][7-((lock_rx-7)>>1)];
//        end
//    end

//    // 3. ∑π¿Ã¥ı ∑Œ¡˜
//    always_comb begin
//        radar_dx = int'(x_pixel) - RADAR_CX;
//        radar_dy = RADAR_CY - int'(y_pixel);
//        on_radar_bg = 0; on_radar_grid = 0; on_radar_needle = 0;

//        if (radar_dy >= 0 && my_abs(radar_dx) <= RADAR_R && radar_dy <= RADAR_R) begin
//            int dist_sq = radar_dx*radar_dx + radar_dy*radar_dy;
//            if (dist_sq <= 10000) begin
//                on_radar_bg = 1;
//                if (dist_sq > 9600 || (dist_sq <= 2601 && dist_sq >= 2401)) on_radar_grid = 1;
//                if (radar_dx == 0 || radar_dy == 0) on_radar_grid = 1;

//                begin
//                    int theta, s, c; longint cross_v, dot_v;
//                    theta = 180 - ((motor_angle > 180) ? 180 : (motor_angle < 0 ? 0 : motor_angle));
//                    s = (theta <= 90) ? int'(SIN_LUT[theta]) : int'(SIN_LUT[180-theta]);
//                    c = (theta <= 90) ? int'(SIN_LUT[90-theta]) : -int'(SIN_LUT[theta-90]);
//                    cross_v = my_abs(longint'(radar_dx) * s - longint'(radar_dy) * c);
//                    dot_v = longint'(radar_dx) * c + longint'(radar_dy) * s;
//                    if (dot_v >= 0 && cross_v <= 1536) on_radar_needle = 1;
//                end
//            end
//        end
//    end

//    // 4. √÷¡æ √‚∑¬ »•«’ (øÏº±º¯¿ß ¿Áº≥¡§)
//    always_comb begin
//        logic [11:0] res_color;
        
//        // øÏº±º¯¿ß 1: √÷ªÛ¥‹ Ω√Ω∫≈€ æÀ∏≤ (AUTO πÆ±∏)
//        if (is_auto_ui)           res_color = is_auto_char ? BLACK : YELLOW;
//        // øÏº±º¯¿ß 2: ∂Ùø¬ æ∆¿Ãƒ‹
//        else if (is_lock_ui)      res_color = is_lock_icon ? BLACK : (is_locked_on ? YELLOW : WHITE);
//        // øÏº±º¯¿ß 3: [∫π±∏µ ] ¡¬ªÛ¥‹ ¡¬«• ≈ÿΩ∫∆Æ
//        else if (is_text_pixel)   res_color = GREEN;
//        // øÏº±º¯¿ß 4: ¡ﬂæ” Ω ¿⁄∞°
//        else if (on_crosshair)    res_color = BLACK;
//        // øÏº±º¯¿ß 5: ∑π¿Ã¥ı ∑π¿ÃæÓ
//        else if (on_radar_needle) res_color = RED;
//        else if (on_radar_grid)   res_color = GREEN;
//        else if (on_radar_bg)     res_color = DARK_GREEN;
//        // øÏº±º¯¿ß 6: ≈∏∞Ÿ ∞®¡ˆ π⁄Ω∫
//        else if (aim_detected && (
//            ((int'(x_pixel) == box_x_min || int'(x_pixel) == box_x_max) && int'(y_pixel) >= box_y_min && int'(y_pixel) <= box_y_max) ||
//            ((int'(y_pixel) == box_y_min || int'(y_pixel) == box_y_max) && int'(x_pixel) >= box_x_min && int'(x_pixel) <= box_x_max)
//        ))                        res_color = GREEN;
//        // øÏº±º¯¿ß 7: πË∞Ê øµªÛ
//        else                      res_color = img_bg;

//        {r_port, g_port, b_port} = res_color;
//    end

//endmodule

`timescale 1ns / 1ps

module pixel_mixer_auto (
    input logic [11:0] img_bg,  

    input logic [9:0] aim_x, aim_y,        
    input logic       aim_detected, 

    input logic [9:0] x_pixel, y_pixel,  

    input logic [11:0] box_x_min, box_x_max,
    input logic [11:0] box_y_min, box_y_max,
    
    input logic [9:0] motor_angle, 

    output logic [3:0] r_port, g_port, b_port,
    output logic       shoot
);

    // --- ªˆªÛ ¡§¿« ---
    localparam logic [11:0] RED = 12'hF00, GREEN = 12'h0F0, WHITE = 12'hFFF, BLACK = 12'h000;
    localparam logic [11:0] YELLOW = 12'hFF0, DARK_GREEN = 12'h040;

    // --- ∫Ò∆Æ∏  µ•¿Ã≈Õ ---
    localparam logic [0:7][7:0] CHAR_A = '{8'h3C, 8'h66, 8'hC3, 8'hFF, 8'hFF, 8'hC3, 8'hC3, 8'h00};
    localparam logic [0:7][7:0] CHAR_U = '{8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h7E, 8'h00};
    localparam logic [0:7][7:0] CHAR_T = '{8'hFF, 8'hFF, 8'h18, 8'h18, 8'h18, 8'h18, 8'h18, 8'h00};
    localparam logic [0:7][7:0] CHAR_O = '{8'h3C, 8'h66, 8'hC3, 8'hC3, 8'hC3, 8'hC3, 8'h66, 8'h3C};
    localparam logic [0:7][7:0] ICON_LOCK = '{8'h3C, 8'h42, 8'h99, 8'hA5, 8'hA5, 8'h99, 8'h42, 8'h3C};

    // --- UI ∆ƒ∂ÛπÃ≈Õ ---
    localparam int CX = 320, CY = 240, LOCK_ZONE = 30;
    localparam int AUTO_X = 275, AUTO_Y = 15;
    localparam int RADAR_CX = 540, RADAR_CY = 460, RADAR_R = 100;

    // --- ªÁ¿Œ LUT ---
    localparam int unsigned SIN_LUT [0:90] = '{0, 18, 36, 54, 71, 89, 107, 125, 143, 160, 178, 195, 213, 230, 248, 265, 282, 299, 316, 333, 350, 367, 384, 400, 416, 433, 449, 465, 481, 496, 512, 527, 543, 558, 573, 587, 602, 616, 630, 644, 658, 672, 685, 698, 711, 724, 737, 749, 761, 773, 784, 796, 807, 818, 828, 839, 849, 859, 868, 878, 887, 896, 904, 912, 920, 928, 935, 943, 949, 956, 962, 968, 974, 979, 984, 989, 994, 998, 1002, 1005, 1008, 1011, 1014, 1016, 1018, 1020, 1022, 1023, 1023, 1024, 1024};

    // --- ≥ª∫Œ Ω≈»£ ---
    logic is_locked_on, on_crosshair, is_auto_ui, is_auto_char, is_text_pixel;
    logic on_radar_bg, on_radar_grid, on_radar_needle;
    logic is_lock_ui, is_lock_icon;
    int dist_x, dist_y, radar_dx, radar_dy, auto_rx, auto_ry, lock_rx, lock_ry;

    // ¿˝¥Î∞™ «Ô∆€ «‘ºˆ
    function automatic int my_abs(input int val); return (val < 0) ? -val : val; endfunction

    // º˝¿⁄ ±◊∏Æ±‚ «‘ºˆ
    function automatic logic draw_digit(input [3:0] num, input [9:0] px, input [9:0] py, input [9:0] ox, input [9:0] oy);
        logic sa, sb, sc, sd, se, sf, sg;
        int ddx = int'(px) - int'(ox); int ddy = int'(py) - int'(oy);
        ddx = ddx / 2; ddy = ddy / 2;
        if (ddx < 0 || ddx > 8 || ddy < 0 || ddy > 16) return 0;
        sa = (ddy == 0) && (ddx > 0 && ddx < 8); sb = (ddx == 8) && (ddy > 0 && ddy < 8);
        sc = (ddx == 8) && (ddy > 8 && ddy < 16); sd = (ddy == 16) && (ddx > 0 && ddx < 8);
        se = (ddx == 0) && (ddy > 8 && ddy < 16); sf = (ddx == 0) && (ddy > 0 && ddy < 8);
        sg = (ddy == 8) && (ddx > 0 && ddx < 8);
        case (num)
            0: return sa|sb|sc|sd|se|sf; 1: return sb|sc; 2: return sa|sb|sd|se|sg;
            3: return sa|sb|sc|sd|sg; 4: return sb|sc|sf|sg; 5: return sa|sc|sd|sf|sg;
            6: return sa|sc|sd|se|sf|sg; 7: return sa|sb|sc|sf; 8: return sa|sb|sc|sd|se|sf|sg;
            9: return sa|sb|sc|sd|sf|sg; default: return 0;
        endcase
    endfunction

    // 1. ≈∏∞Ÿ π◊ ¡∂¡ÿ ∆«¡§ ∑π¿ÃæÓ
    always_comb begin
        is_locked_on = (aim_detected && my_abs(int'(aim_x) - CX) < LOCK_ZONE && my_abs(int'(aim_y) - CY) < LOCK_ZONE);
        shoot = is_locked_on;
        
        // ¡ﬂæ” ∞Ì¡§ Ω ¿⁄∞°
        dist_x = my_abs(int'(x_pixel) - CX); dist_y = my_abs(int'(y_pixel) - CY);
        on_crosshair = ((dist_x < 15 && dist_y < 2) || (dist_y < 15 && dist_x < 2));

        // ¡¬ªÛ¥‹ ¡¬«• ≈ÿΩ∫∆Æ
        is_text_pixel = draw_digit(aim_x/100, x_pixel, y_pixel, 10, 10) |
                        draw_digit((aim_x/10)%10, x_pixel, y_pixel, 30, 10) |
                        draw_digit(aim_x%10, x_pixel, y_pixel, 50, 10) |
                        draw_digit(aim_y/100, x_pixel, y_pixel, 10, 50) |
                        draw_digit((aim_y/10)%10, x_pixel, y_pixel, 30, 50) |
                        draw_digit(aim_y%10, x_pixel, y_pixel, 50, 50);
    end

    // 2. UI ø‰º“ ∑Œ¡˜ (AUTO, LOCK)
    always_comb begin
        is_auto_ui = (x_pixel >= AUTO_X-10 && x_pixel < AUTO_X+86 && y_pixel >= AUTO_Y-8 && y_pixel < AUTO_Y+24);
        auto_rx = int'(x_pixel) - AUTO_X; auto_ry = int'(y_pixel) - AUTO_Y;
        is_auto_char = 0;
        if (auto_ry >= 0 && auto_ry < 16) begin
            if (auto_rx >= 0 && auto_rx < 16)            is_auto_char = CHAR_A[auto_ry>>1][7-(auto_rx>>1)];
            else if (auto_rx >= 20 && auto_rx < 36)      is_auto_char = CHAR_U[auto_ry>>1][7-((auto_rx-20)>>1)];
            else if (auto_rx >= 40 && auto_rx < 56)      is_auto_char = CHAR_T[auto_ry>>1][7-((auto_rx-40)>>1)];
            else if (auto_rx >= 60 && auto_rx < 76)      is_auto_char = CHAR_O[auto_ry>>1][7-((auto_rx-60)>>1)];
        end

        is_lock_ui = (x_pixel >= 580 && x_pixel < 610 && y_pixel >= 30 && y_pixel < 60);
        is_lock_icon = 0;
        if (is_lock_ui) begin
            lock_rx = int'(x_pixel) - 580; lock_ry = int'(y_pixel) - 30;
            if (lock_rx >= 7 && lock_rx < 23 && lock_ry >= 7 && lock_ry < 23)
                is_lock_icon = ICON_LOCK[(lock_ry-7)>>1][7-((lock_rx-7)>>1)];
        end
    end

    // 3. ∑π¿Ã¥ı ∑Œ¡˜ (√÷¿˚»≠)
    always_comb begin
        radar_dx = int'(x_pixel) - RADAR_CX;
        radar_dy = RADAR_CY - int'(y_pixel);
        on_radar_bg = 0; on_radar_grid = 0; on_radar_needle = 0;

        if (radar_dy >= 0 && my_abs(radar_dx) <= RADAR_R && radar_dy <= RADAR_R) begin
            int dist_sq = radar_dx*radar_dx + radar_dy*radar_dy;
            if (dist_sq <= 10000) begin
                on_radar_bg = 1;
                if (dist_sq > 9600 || (dist_sq <= 2601 && dist_sq >= 2401)) on_radar_grid = 1;
                if (radar_dx == 0 || radar_dy == 0) on_radar_grid = 1;

                begin
                    int theta, s, c; longint cross_v, dot_v;
                    theta = 180 - ((motor_angle > 180) ? 180 : (motor_angle < 0 ? 0 : motor_angle));
                    s = (theta <= 90) ? int'(SIN_LUT[theta]) : int'(SIN_LUT[180-theta]);
                    c = (theta <= 90) ? int'(SIN_LUT[90-theta]) : -int'(SIN_LUT[theta-90]);
                    cross_v = my_abs(longint'(radar_dx) * s - longint'(radar_dy) * c);
                    dot_v = longint'(radar_dx) * c + longint'(radar_dy) * s;
                    if (dot_v >= 0 && cross_v <= 1536) on_radar_needle = 1;
                end
            end
        end
    end

    // 4. √÷¡æ √‚∑¬ »•«’ (øÏº±º¯¿ß ¿Áº≥¡§)
    always_comb begin
        logic [11:0] res_color;
        
        // øÏº±º¯¿ß 1: √÷ªÛ¥‹ Ω√Ω∫≈€ æÀ∏≤ (AUTO πÆ±∏)
        if (is_auto_ui)           res_color = is_auto_char ? BLACK : YELLOW;
        // øÏº±º¯¿ß 2: ∂Ùø¬ æ∆¿Ãƒ‹
        else if (is_lock_ui)      res_color = is_lock_icon ? BLACK : (is_locked_on ? YELLOW : WHITE);
        // øÏº±º¯¿ß 3: ¡¬ªÛ¥‹ ¡¬«• ≈ÿΩ∫∆Æ
        else if (is_text_pixel)   res_color = GREEN;
        // øÏº±º¯¿ß 4: ¡ﬂæ” Ω ¿⁄∞°
        else if (on_crosshair)    res_color = BLACK;
        // øÏº±º¯¿ß 5: [√ﬂ∞°µ ] Ω«Ω√∞£ ≈∏∞Ÿ ª°∞£ AIM ¡° (10x10 Ω ¿⁄∞° «¸≈¬)
        else if (aim_detected && (
            (my_abs(int'(x_pixel) - int'(aim_x)) < 10 && int'(y_pixel) == int'(aim_y)) ||
            (my_abs(int'(y_pixel) - int'(aim_y)) < 10 && int'(x_pixel) == int'(aim_x))
        ))                        res_color = RED;
        // øÏº±º¯¿ß 6: ∑π¿Ã¥ı ∑π¿ÃæÓ
        else if (on_radar_needle) res_color = RED;
        else if (on_radar_grid)   res_color = GREEN;
        else if (on_radar_bg)     res_color = DARK_GREEN;
        // øÏº±º¯¿ß 7: ≈∏∞Ÿ ∞®¡ˆ π⁄Ω∫
        else if (aim_detected && (
            ((int'(x_pixel) == box_x_min || int'(x_pixel) == box_x_max) && int'(y_pixel) >= box_y_min && int'(y_pixel) <= box_y_max) ||
            ((int'(y_pixel) == box_y_min || int'(y_pixel) == box_y_max) && int'(x_pixel) >= box_x_min && int'(x_pixel) <= box_x_max)
        ))                        res_color = GREEN;
        // øÏº±º¯¿ß 8: πË∞Ê øµªÛ
        else                      res_color = img_bg;

        {r_port, g_port, b_port} = res_color;
    end

endmodule