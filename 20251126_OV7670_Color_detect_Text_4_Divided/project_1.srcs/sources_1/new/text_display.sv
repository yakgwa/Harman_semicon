//module text_display (
//    input  logic       clk,
//    input  logic       DE,
//    input  logic       blue_detect,
//    input  logic       red_detect,
//    input  logic [9:0] x_pixel,
//    input  logic [9:0] y_pixel,
//    output logic [3:0] red,
//    output logic [3:0] green,
//    output logic [3:0] blue,
//    output logic       text_on
//);

//    localparam int CHAR_WIDTH  = 8;
//    localparam int CHAR_HEIGHT = 8;
//    localparam int MAX_CHARS   = 5; // H E L L O
//    localparam int CAM_WIDTH   = 320;
//    localparam int CAM_HEIGHT  = 240;

//    localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS*CHAR_WIDTH)/2;
//    localparam int TEXT_Y_START = 16;
//    localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS*CHAR_WIDTH;
//    localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

//    logic [7:0] codes [0:MAX_CHARS-1];
//    logic [7:0] font_line;
//    logic [7:0] char_rom_idx;
//    logic pixel_on;
//    logic [3:0] row_addr;
//    logic [3:0] bit_idx;
//    logic [7:0] rom_addr;

//    // HELLO ���� �ڵ� (Font ROM�� ���缭)
//    always_comb begin
//        codes[0] = 8'd7;   // H
//        codes[1] = 8'd4;   // E
//        codes[2] = 8'd11;  // L
//        codes[3] = 8'd11;  // L
//        codes[4] = 8'd14;  // O
//    end

//    assign rom_addr = (char_rom_idx << 3) | row_addr;
//    assign text_on = pixel_on && DE;

//    font_rom u_font (
//        .clk(clk),
//        .addr(rom_addr),
//        .data(font_line)
//    );

//    always_comb begin
//        pixel_on = 1'b0;
//        char_rom_idx = 0;
//        row_addr = 0;
//        bit_idx  = 0;

//        if (DE) begin
//            if (x_pixel >= TEXT_X_START && x_pixel < TEXT_X_END &&
//                y_pixel >= TEXT_Y_START && y_pixel < TEXT_Y_END) begin

//                int char_slot = (x_pixel - TEXT_X_START) / CHAR_WIDTH;
//                if (char_slot < MAX_CHARS) begin
//                    char_rom_idx = codes[char_slot];
//                    row_addr     = (y_pixel - TEXT_Y_START) & 4'h7;
//                    bit_idx      = (x_pixel - TEXT_X_START) % CHAR_WIDTH;
//                    pixel_on     = font_line[bit_idx];
//                end
//            end
//        end
//    end

//    // �ܻ� ���? �ؽ�Ʈ
////    always_comb begin
////        if (pixel_on) begin
////            red   = 4'hf;
////            green = 4'h0;
////            blue  = 4'h0;
////        end else begin
////            red   = 4'h0;
////            green = 4'h0;
////            blue  = 4'h0;
////        end
////    end
//    always_comb begin
//        if (pixel_on) begin
//            if (blue_detect) begin
//                red   = 4'h0;
//                green = 4'h0;
//                blue  = 4'hf; // �Ķ�
//            end else if (red_detect) begin
//                red   = 4'hf; // ����
//                green = 4'h0;
//                blue  = 4'h0;
//            end else begin
//                red   = 4'hf; // �⺻ ���?
//                green = 4'hf;
//                blue  = 4'hf;
//            end
//        end else begin
//            red   = 4'h0;
//            green = 4'h0;
//            blue  = 4'h0;
//        end
//    end


//endmodule

//module font_rom (
//    input  logic        clk,
//    input  logic [10:0] addr,
//    output logic [7:0]  data
//);

//    (* rom_style = "block" *)
//    logic [7:0] rom [0:1023];

//    initial begin
//        $readmemh("Dispaly.mem", rom); // font data
//    end

//    always_ff @(posedge clk) begin
//        data <= rom[addr];
//    end

//module text_display (
//    input  logic       clk,
//    input  logic       reset,
//    input  logic       DE,
//    input  logic       blue_detect,
//    input  logic       red_detect,
//    input  logic [9:0] x_pixel,
//    input  logic [9:0] y_pixel,
//    output logic [3:0] red,
//    output logic [3:0] green,
//    output logic [3:0] blue,
//    output logic       text_on
//);

//    typedef enum logic [3:0] {
//        IDLE,
//        BLUE_UP,
//        BLUE_NO_UP,
//        RED_UP,
//        RED_NO_UP,
//        GAME_OVER
//    } commend_e;
    
//    commend_e state, state_next;

//    localparam int CAM_WIDTH   = 320;
//    localparam int CAM_HEIGHT  = 240;

//    localparam int MAX_CHARS   = 13;
//    localparam int CHAR_WIDTH  = 8;
//    localparam int CHAR_HEIGHT = 8;

//    // ���� �߾ӿ� �ؽ�Ʈ ������ ����
//    localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS * CHAR_WIDTH) / 2;
//    localparam int TEXT_Y_START = 16;
//    localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS * CHAR_WIDTH;
//    localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

//    localparam int ROW_ADDR_BITS = $clog2(CHAR_HEIGHT);
//    localparam int SLOT_NUM_BITS = $clog2(MAX_CHARS);

//    logic [ROW_ADDR_BITS-1:0]   row_addr;
//    logic [ROW_ADDR_BITS-1:0]   bit_idx;
//    logic [7:0]                 font_line;
//    logic                       pixel_on;

//    logic [7:0]                 char_rom_idx;
//    logic [ROW_ADDR_BITS + 7:0] rom_addr;

//    logic [7:0] codes       [0:MAX_CHARS-1];
//    int         str_len;
//    logic       show_text;

//    assign text_on  = pixel_on && DE;
//    assign rom_addr = (char_rom_idx << ROW_ADDR_BITS) | row_addr;

//    font_rom u_font (
//        .clk  (clk),
//        .addr (rom_addr),
//        .data (font_line)
//    );

//    logic red_d;
//    logic blue_d;
    
//    always_ff @(posedge clk) begin
//        red_d <= red_detect;
//        blue_d <= blue_detect;
//    end
    
//    wire red_rise = red_detect & ~red_d;
//    wire blue_rise = blue_detect & ~blue_d;

//    always_ff@(posedge clk) begin
//        if(!reset) begin
//            state <= IDLE;
//        end else begin
//            state <= state_next;
//        end
//    end

//    always_comb begin
//        for (int i = 0; i < MAX_CHARS; i++) begin
//            codes[i] = 8'd100;  
//        end
//        str_len   = 0;
//        show_text = 1'b0;
//        state_next = state;
//        case (state)
////            IDLE : begin
////                show_text = 1'b0;
////                str_len   = 0;
////            end     
//            IDLE: begin
//                show_text = 1'b1;
//                codes[0]  = 8'd100;  // ����
//                codes[1]  = 8'd6;   // 'G'
//                codes[2]  = 8'd0;   // 'A'
//                codes[3]  = 8'd12;  // 'M'
//                codes[4]  = 8'd4;   // 'E'
//                codes[5]  = 8'd63;  // '_'
//                codes[6]  = 8'd18;  // 'S'
//                codes[7]  = 8'd19;  // 'T'
//                codes[8]  = 8'd0;   // 'A'
//                codes[9]  = 8'd17;  // 'R'
//                codes[10] = 8'd19;  // 'T'
//                codes[11] = 8'd100;  // ����
//                str_len = 12;
//                if(red_rise) begin 
//                    state_next = RED_UP;
//                end else if(blue_rise) begin
//                    state_next = BLUE_UP;
//                end
//            end
//            BLUE_UP: begin
//                show_text = 1'b1;
//                codes[0]  = 8'd100;  // ����
//                codes[1]  = 8'd1;   // 'B'
//                codes[2]  = 8'd11;  // 'L'
//                codes[3]  = 8'd20;  // 'U'
//                codes[4]  = 8'd4;   // 'E'
//                codes[5]  = 8'd63;  // '_'
//                codes[6]  = 8'd20;  // 'U'
//                codes[7] = 8'd15;  // 'P'                
//                codes[8] = 8'd100;  // ����
//                str_len = 9;
//                state_next = BLUE_NO_UP;
//            end
//            BLUE_NO_UP: begin
//                show_text = 1'b1;
//                codes[0]  = 8'd100;  // ����
//                codes[1]  = 8'd1;   // 'B'
//                codes[2]  = 8'd11;  // 'L'
//                codes[3]  = 8'd20;  // 'U'
//                codes[4]  = 8'd4;   // 'E'
//                codes[5]  = 8'd63;  // '_'
//                codes[6]  = 8'd13;  // 'N'
//                codes[7]  = 8'd14;  // 'O'
//                codes[8]  = 8'd63;  // '_'
//                codes[9]  = 8'd20;  // 'U'
//                codes[10] = 8'd15;  // 'P'
//                codes[11] = 8'd100;  // ����
//                str_len = 11;
//                state_next = IDLE;
//            end
//            RED_UP: begin
//                show_text = 1'b1;
//                codes[0]  = 8'd100;  // ����
//                codes[1]  = 8'd17;   // 'R'
//                codes[2]  = 8'd4;  // 'E'
//                codes[3]  = 8'd3;  // 'D'
//                codes[4]  = 8'd63;  // '_'
//                codes[5]  = 8'd20;  // 'U'
//                codes[6] = 8'd15;  // 'P'                
//                codes[7] = 8'd100;  // ����
//                str_len = 8;
//                state_next = RED_NO_UP;
//            end
//            RED_NO_UP: begin
//                show_text = 1'b1;
//                codes[0]  = 8'd100;  // ����
//                codes[1]  = 8'd17;   // 'R'
//                codes[2]  = 8'd4;  // 'E'
//                codes[3]  = 8'd3;  // 'D'
//                codes[4]  = 8'd63;  // '_'
//                codes[5]  = 8'd13;  // 'N'
//                codes[6]  = 8'd14;  // 'O'
//                codes[7]  = 8'd63;  // '_'
//                codes[8]  = 8'd20;  // 'U'
//                codes[9] = 8'd15;  // 'P'
//                codes[10] = 8'd100;  // ����
//                str_len = 11;
//                state_next = BLUE_NO_UP;
//            end

//            default: begin
//                show_text = 1'b0;
//                str_len   = 0;
//            end
//        endcase

//        pixel_on     = 1'b0;
//        char_rom_idx = 8'h00;
//        row_addr     = '0;
//        bit_idx      = '0;

//        if (DE && show_text) begin
//            if ( x_pixel >= TEXT_X_START && x_pixel <  TEXT_X_END &&
//                 y_pixel >= TEXT_Y_START && y_pixel <  TEXT_Y_END ) begin

//                logic [SLOT_NUM_BITS-1:0] char_slot;
//                char_slot = (x_pixel - TEXT_X_START) / CHAR_WIDTH;

//                if (char_slot < str_len) begin
//                    char_rom_idx = codes[char_slot];
//                    row_addr     = (y_pixel - TEXT_Y_START) & ((1 << ROW_ADDR_BITS) - 1);
//                    bit_idx      = (x_pixel - TEXT_X_START) % CHAR_WIDTH;
//                    pixel_on     = font_line[bit_idx];
//                end else begin
//                    // str_len �ʰ� ����: ���� (pixel_on �״��? 0)
//                end
//            end
//        end
//    end

//    always_comb begin
//        if (pixel_on && DE) begin
//            red   = 4'hf;
//            green = 4'h0;
//            blue  = 4'h0;
//        end else begin
//            red   = 4'h0;
//            green = 4'h0;
//            blue  = 4'h0;
//        end
//    end

//endmodule

// module text_display (
//     input  logic       clk,
//     input  logic       DE,
//     input  logic [3:0] i_commend,
//     input  logic [9:0] x_pixel,
//     input  logic [9:0] y_pixel,
//     output logic [3:0] o_red,
//     output logic [3:0] o_green,
//     output logic [3:0] o_blue,
//     output logic       text_on
// );

//     typedef enum logic [3:0] {
//         GAME_START,
//         BLUE_DETECT,
//         RED_DETECT,
//         GAME_OVER
//     } commend_e;

//     logic [3:0] commend;

//     display_controller u_display_controller (
//         .i_commend(i_commend),
//         .o_commend(commend)
//     );

//     localparam int CAM_WIDTH   = 320;
//     localparam int CAM_HEIGHT  = 240;

//     localparam int MAX_CHARS   = 13;
//     localparam int CHAR_WIDTH  = 8;
//     localparam int CHAR_HEIGHT = 8;

//     localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS * CHAR_WIDTH) / 2;
//     localparam int TEXT_Y_START = 16;
//     localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS * CHAR_WIDTH;
//     localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

//     localparam int ROW_ADDR_BITS = $clog2(CHAR_HEIGHT);
//     localparam int SLOT_NUM_BITS = $clog2(MAX_CHARS);

//     logic [ROW_ADDR_BITS-1:0]   row_addr;
//     logic [ROW_ADDR_BITS-1:0]   bit_idx;
//     logic [7:0]                 font_line;
//     logic                       pixel_on;

//     logic [7:0]                 char_rom_idx;
//     logic [ROW_ADDR_BITS + 7:0] rom_addr;

//     logic [7:0] codes       [0:MAX_CHARS-1];
//     int         str_len;
//     logic       show_text;

//     assign text_on  = pixel_on && DE;
//     assign rom_addr = (char_rom_idx << ROW_ADDR_BITS) | row_addr;

//     font_rom u_font (
//         .clk  (clk),
//         .addr (rom_addr),
//         .data (font_line)
//     );

//     always_comb begin
//         for (int i = 0; i < MAX_CHARS; i++) begin
//             codes[i] = 8'd100; 
//         end
//         str_len   = 0;
//         show_text = 1'b0;

//         case (commend)
//             GAME_START: begin
//                 show_text = 1'b1;
//                 codes[0]  = 8'd100;  // ����
//                 codes[1]  = 8'd6;   // 'G'
//                 codes[2]  = 8'd0;   // 'A'
//                 codes[3]  = 8'd12;  // 'M'
//                 codes[4]  = 8'd4;   // 'E'
//                 codes[5]  = 8'd100;  // ����
//                 codes[6]  = 8'd18;  // 'S'
//                 codes[7]  = 8'd19;  // 'T'
//                 codes[8]  = 8'd0;   // 'A'
//                 codes[9]  = 8'd17;  // 'R'
//                 codes[10] = 8'd19;  // 'T'
//                 codes[11] = 8'd57; // ����
//                 codes[12] = 8'd100;  // ����
//                 str_len = 13;
//             end

//             BLUE_DETECT: begin
//                 show_text = 1'b1;

//                 //   [0..2]=����, [3]='B', [4]='L', [5]='U', [6]='E', [7]='_', [8]='U', [9]='P', [10..12]=����
//                 codes[0]  = 8'd1;   // 'B'
//                 codes[1]  = 8'd11;  // 'L'
//                 codes[2]  = 8'd20;  // 'U'
//                 codes[3]  = 8'd4;   // 'E'
//                 codes[4]  = 8'd100;  // ����
//                 codes[5]  = 8'd3;   // 'D'
//                 codes[6]  = 8'd4;   // 'E'
//                 codes[7]  = 8'd2;   // 'C'
//                 codes[8]  = 8'd19;  // 'T'
//                 codes[9]  = 8'd100;  // ����
//                 codes[10] = 8'd100;  // ����
//                 codes[11] = 8'd100;  // ����
//                 codes[12] = 8'd100;  // ����
//                 str_len = 13;
//             end

//             RED_DETECT: begin
//                 show_text = 1'b1;

//                 //   [0..2]=����, [3]='B', [4]='L', [5]='U', [6]='E', [7]='_', [8]='U', [9]='P', [10..12]=����
//                 codes[0]  = 8'd17;  // 'R'
//                 codes[1]  = 8'd4;   // 'E'
//                 codes[2]  = 8'd3;   // 'D'
//                 codes[3]  =  8'd100;  // ����
//                 codes[4]  = 8'd3;   // 'D'
//                 codes[5]  = 8'd4;   // 'E'
//                 codes[6]  = 8'd2;   // 'C'
//                 codes[7]  = 8'd19;  // 'T'
//                 codes[8]  = 8'd100;  // ����
//                 codes[9]  = 8'd100;  // ����
//                 codes[10] = 8'd100;  // ����
//                 codes[11] = 8'd100;  // ����
//                 codes[12] = 8'd100;  // ����
//                 str_len = 13;
//             end

//             GAME_OVER: begin
//                 show_text = 1'b1;
//                 codes[0]  = 8'd100;  // ����
//                 codes[1]  = 8'd100;  // ����
//                 codes[2]  = 8'd6;   // 'G'
//                 codes[3]  = 8'd0;   // 'A'
//                 codes[4]  = 8'd12;  // 'M'
//                 codes[5]  = 8'd4;   // 'E'
//                 codes[6]  = 8'd63;  // '_'
//                 codes[7]  = 8'd14;  // 'O'
//                 codes[8]  = 8'd21;  // 'V'
//                 codes[9]  = 8'd4;   // 'E'
//                 codes[10] = 8'd17;  // 'R'
//                 codes[11] = 8'd100;  // ����
//                 codes[12] = 8'd100;  // ����
//                 str_len = 13;
//             end

//             default: begin
//                 // default�� �� show_text=0 �� ���� ����
//                 show_text = 1'b0;
//                 str_len   = 0;
//             end
//         endcase

//         pixel_on     = 1'b0;
//         char_rom_idx = 8'h00;
//         row_addr     = '0;
//         bit_idx      = '0;

//         if (DE && show_text) begin
//             if ( x_pixel >= TEXT_X_START && x_pixel <  TEXT_X_END &&
//                  y_pixel >= TEXT_Y_START && y_pixel <  TEXT_Y_END ) begin

//                 logic [SLOT_NUM_BITS-1:0] char_slot;
//                 char_slot = (x_pixel - TEXT_X_START) / CHAR_WIDTH;

//                 if (char_slot < str_len) begin
//                     char_rom_idx = codes[char_slot];
//                     row_addr     = (y_pixel - TEXT_Y_START) & ((1 << ROW_ADDR_BITS) - 1);
//                     bit_idx      = (x_pixel - TEXT_X_START) % CHAR_WIDTH;
//                     pixel_on     = font_line[bit_idx];
//                 end else begin
//                     // str_len �ʰ� ����: ���� (pixel_on �״��? 0)
//                 end
//             end
//         end
//     end

//     always_comb begin
//         if (pixel_on && DE) begin
//             case (commend)
//                 RED_DETECT: begin
//                     o_red   = 4'hf;
//                     o_green = 4'h0;
//                     o_blue  = 4'h0;
//                 end
//                 BLUE_DETECT: begin
//                     o_red   = 4'h0;
//                     o_green = 4'h0;
//                     o_blue  = 4'hf;
//                 end
//                 default: begin
//                     o_red   = 4'hf;
//                     o_green = 4'hf;
//                     o_blue  = 4'hf;
//                 end
//             endcase
//         end else begin
//             o_red   = 4'h0;
//             o_green = 4'h0;
//             o_blue  = 4'h0;
//         end
//     end

// endmodule




// module display_controller(
//     input  logic [3:0] i_commend,
//     output logic [3:0] o_commend
// );

//     typedef enum logic [3:0] {
//         GAME_START,
//         BLUE_DETECT,
//         RED_DETECT,
//         GAME_OVER
//     } commend_e;

//     always_comb begin
//         case (i_commend)
//             4'b0000: o_commend = GAME_START;
//             4'b0001: o_commend = BLUE_DETECT;
//             4'b0010: o_commend = RED_DETECT;
//             4'b0011: o_commend = GAME_OVER;
//             4'b0100: ;
//             4'b0101: ;
//             4'b0110: ;
//             4'b0111: ;
//             4'b1000: ;
//             4'b1001: ;
//             4'b1010: ;
//             4'b1011: ;
//             4'b1100: ;
//             4'b1111: ;
//             default: o_commend = GAME_START;
//         endcase
//     end

// endmodule

// module font_rom (
//     input  logic        clk,
//     input  logic [10:0] addr,
//     output logic [7:0]  data
// );

//     (* rom_style = "block" *)
//     logic [7:0] rom [0:1023];

//     initial begin
//         $readmemh("Dispaly.mem", rom); // font data
//     end

//     always_ff @(posedge clk) begin
//         data <= rom[addr];
//     end

// endmodule

module text_display (
    input  logic       clk,
    input  logic       DE,
    input  logic [7:0] blue_count,
    input  logic [7:0] red_count,
    input  logic [3:0] i_commend,
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    output logic [3:0] o_red,
    output logic [3:0] o_green,
    output logic [3:0] o_blue,
    output logic       text_on
);

    typedef enum logic [3:0] {
        GAME_START,
        BLUE_DETECT,
        RED_DETECT,
        GAME_OVER
    } commend_e;

    logic [3:0] commend;

    display_controller u_display_controller (
        .i_commend(i_commend),
        .o_commend(commend)
    );

    localparam int CAM_WIDTH   = 320;
    localparam int CAM_HEIGHT  = 240;

    localparam int MAX_CHARS   = 13;
    localparam int CHAR_WIDTH  = 8;
    localparam int CHAR_HEIGHT = 8;

    localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS * CHAR_WIDTH) / 2;
    localparam int TEXT_Y_START = 16;
    localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS * CHAR_WIDTH;
    localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

    localparam int ROW_ADDR_BITS = $clog2(CHAR_HEIGHT);
    localparam int SLOT_NUM_BITS = $clog2(MAX_CHARS);

    logic [ROW_ADDR_BITS-1:0]   row_addr;
    logic [ROW_ADDR_BITS-1:0]   bit_idx;
    logic [7:0]                 font_line;
    logic                       pixel_on;

    logic [7:0]                 char_rom_idx;
    logic [ROW_ADDR_BITS + 7:0] rom_addr;

    logic [7:0] codes       [0:MAX_CHARS-1];
    int         str_len;
    logic       show_text;

    logic [3:0] blue_tens;
    logic [3:0] blue_ones;
    logic [3:0] red_tens;
    logic [3:0] red_ones;

    assign blue_tens = blue_count / 8'd10;
    assign blue_ones = blue_count % 8'd10;
    assign red_tens = red_count / 8'd10;
    assign red_ones = red_count % 8'd10;

    assign text_on  = pixel_on && DE;
    assign rom_addr = (char_rom_idx << ROW_ADDR_BITS) | row_addr;

    font_rom u_font (
        .clk  (clk),
        .addr (rom_addr),
        .data (font_line)
    );

    always_comb begin
        for (int i = 0; i < MAX_CHARS; i++) begin
            codes[i] = 8'd100; 
        end
        str_len   = 0;
        show_text = 1'b0;

        case (commend)
            GAME_START: begin
                show_text = 1'b1;
                codes[0]  = 8'd100;  // ����
                codes[1]  = 8'd6;   // 'G'
                codes[2]  = 8'd0;   // 'A'
                codes[3]  = 8'd12;  // 'M'
                codes[4]  = 8'd4;   // 'E'
                codes[5]  = 8'd100;  // ����
                codes[6]  = 8'd18;  // 'S'
                codes[7]  = 8'd19;  // 'T'
                codes[8]  = 8'd0;   // 'A'
                codes[9]  = 8'd17;  // 'R'
                codes[10] = 8'd19;  // 'T'
                codes[11] = 8'd57; // ����
                codes[12] = 8'd100;  // ����
                str_len = 13;
            end

            BLUE_DETECT: begin
                show_text = 1'b1;

                //   [0..2]=����, [3]='B', [4]='L', [5]='U', [6]='E', [7]='_', [8]='U', [9]='P', [10..12]=����
                codes[0]  = 8'd1;   // 'B'
                codes[1]  = 8'd11;  // 'L'
                codes[2]  = 8'd20;  // 'U'
                codes[3]  = 8'd4;   // 'E'
                codes[4]  = 8'd100;  // ����
                codes[5]  = 8'd3;   // 'D'
                codes[6]  = 8'd4;   // 'E'
                codes[7]  = 8'd2;   // 'C'
                codes[8]  = 8'd19;  // 'T'
                codes[9]  = 8'd100;  // ����
                codes[10] = 8'd100;  // ����
                codes[11] = 8'd26 + blue_tens;  // ����
                codes[12] = 8'd26 + blue_ones;  // ����
                str_len = 13;
            end

            RED_DETECT: begin
                show_text = 1'b1;

                //   [0..2]=����, [3]='B', [4]='L', [5]='U', [6]='E', [7]='_', [8]='U', [9]='P', [10..12]=����
                codes[0]  = 8'd17;  // 'R'
                codes[1]  = 8'd4;   // 'E'
                codes[2]  = 8'd3;   // 'D'
                codes[3]  =  8'd100;  // ����
                codes[4]  = 8'd3;   // 'D'
                codes[5]  = 8'd4;   // 'E'
                codes[6]  = 8'd2;   // 'C'
                codes[7]  = 8'd19;  // 'T'
                codes[8]  = 8'd100;  // ����
                codes[9]  = 8'd100;  // ����
                codes[10] = 8'd26 + red_tens;
                codes[11] = 8'd26 + red_ones;
                codes[12] = 8'd100;  // ����
                str_len = 13;
            end

            GAME_OVER: begin
                show_text = 1'b1;
                codes[0]  = 8'd100;  // ����
                codes[1]  = 8'd100;  // ����
                codes[2]  = 8'd6;   // 'G'
                codes[3]  = 8'd0;   // 'A'
                codes[4]  = 8'd12;  // 'M'
                codes[5]  = 8'd4;   // 'E'
                codes[6]  = 8'd63;  // '_'
                codes[7]  = 8'd14;  // 'O'
                codes[8]  = 8'd21;  // 'V'
                codes[9]  = 8'd4;   // 'E'
                codes[10] = 8'd17;  // 'R'
                codes[11] = 8'd100;  // ����
                codes[12] = 8'd100;  // ����
                str_len = 13;
            end

            default: begin
                // default�� �� show_text=0 �� ���� ����
                show_text = 1'b0;
                str_len   = 0;
            end
        endcase

        pixel_on     = 1'b0;
        char_rom_idx = 8'h00;
        row_addr     = '0;
        bit_idx      = '0;

        if (DE && show_text) begin
            if ( x_pixel >= TEXT_X_START && x_pixel <  TEXT_X_END &&
                 y_pixel >= TEXT_Y_START && y_pixel <  TEXT_Y_END ) begin

                logic [SLOT_NUM_BITS-1:0] char_slot;
                char_slot = (x_pixel - TEXT_X_START) / CHAR_WIDTH;

                if (char_slot < str_len) begin
                    char_rom_idx = codes[char_slot];
                    row_addr     = (y_pixel - TEXT_Y_START) & ((1 << ROW_ADDR_BITS) - 1);
                    bit_idx      = (x_pixel - TEXT_X_START) % CHAR_WIDTH;
                    pixel_on     = font_line[bit_idx];
                end else begin
                    // str_len �ʰ� ����: ���� (pixel_on �״��? 0)
                end
            end
        end
    end

    always_comb begin
        if (pixel_on && DE) begin
            case (commend)
                RED_DETECT: begin
                    o_red   = 4'hf;
                    o_green = 4'h0;
                    o_blue  = 4'h0;
                end
                BLUE_DETECT: begin
                    o_red   = 4'h0;
                    o_green = 4'h0;
                    o_blue  = 4'hf;
                end
                default: begin
                    o_red   = 4'hf;
                    o_green = 4'hf;
                    o_blue  = 4'hf;
                end
            endcase
        end else begin
            o_red   = 4'h0;
            o_green = 4'h0;
            o_blue  = 4'h0;
        end
    end

endmodule




module display_controller(
    input  logic [3:0] i_commend,
    output logic [3:0] o_commend
);

    typedef enum logic [3:0] {
        GAME_START,
        BLUE_DETECT,
        RED_DETECT,
        GAME_OVER
    } commend_e;

    always_comb begin
        case (i_commend)
            4'b0000: o_commend = GAME_START;
            4'b0001: o_commend = BLUE_DETECT;
            4'b0010: o_commend = RED_DETECT;
            4'b0011: o_commend = GAME_OVER;
            4'b0100: ;
            4'b0101: ;
            4'b0110: ;
            4'b0111: ;
            4'b1000: ;
            4'b1001: ;
            4'b1010: ;
            4'b1011: ;
            4'b1100: ;
            4'b1111: ;
            default: o_commend = GAME_START;
        endcase
    end

endmodule

module font_rom (
    input  logic        clk,
    input  logic [10:0] addr,
    output logic [7:0]  data
);

    (* rom_style = "block" *)
    logic [7:0] rom [0:2047];

    initial begin
        $readmemh("Dispaly.mem", rom); // font data
    end

    always_ff @(posedge clk) begin
        data <= rom[addr];
    end

endmodule

