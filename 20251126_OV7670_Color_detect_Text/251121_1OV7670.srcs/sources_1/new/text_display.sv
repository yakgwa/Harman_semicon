module text_display (
    input  logic       clk,
    input  logic       DE,
    input  logic       blue_detect,
    input  logic       red_detect,
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue,
    output logic       text_on
);

    localparam int CHAR_WIDTH  = 8;
    localparam int CHAR_HEIGHT = 8;
    localparam int MAX_CHARS   = 5; // H E L L O
    localparam int CAM_WIDTH   = 320;
    localparam int CAM_HEIGHT  = 240;

    localparam int TEXT_X_START = (CAM_WIDTH - MAX_CHARS*CHAR_WIDTH)/2;
    localparam int TEXT_Y_START = 16;
    localparam int TEXT_X_END   = TEXT_X_START + MAX_CHARS*CHAR_WIDTH;
    localparam int TEXT_Y_END   = TEXT_Y_START + CHAR_HEIGHT;

    logic [7:0] codes [0:MAX_CHARS-1];
    logic [7:0] font_line;
    logic [7:0] char_rom_idx;
    logic pixel_on;
    logic [3:0] row_addr;
    logic [3:0] bit_idx;
    logic [7:0] rom_addr;

    // HELLO ¹®ÀÚ ÄÚµå (Font ROM¿¡ ¸ÂÃç¼­)
    always_comb begin
        codes[0] = 8'd7;   // H
        codes[1] = 8'd4;   // E
        codes[2] = 8'd11;  // L
        codes[3] = 8'd11;  // L
        codes[4] = 8'd14;  // O
    end

    assign rom_addr = (char_rom_idx << 3) | row_addr;
    assign text_on = pixel_on && DE;

    font_rom u_font (
        .clk(clk),
        .addr(rom_addr),
        .data(font_line)
    );

    always_comb begin
        pixel_on = 1'b0;
        char_rom_idx = 0;
        row_addr = 0;
        bit_idx  = 0;

        if (DE) begin
            if (x_pixel >= TEXT_X_START && x_pixel < TEXT_X_END &&
                y_pixel >= TEXT_Y_START && y_pixel < TEXT_Y_END) begin

                int char_slot = (x_pixel - TEXT_X_START) / CHAR_WIDTH;
                if (char_slot < MAX_CHARS) begin
                    char_rom_idx = codes[char_slot];
                    row_addr     = (y_pixel - TEXT_Y_START) & 4'h7;
                    bit_idx      = (x_pixel - TEXT_X_START) % CHAR_WIDTH;
                    pixel_on     = font_line[bit_idx];
                end
            end
        end
    end

    // ´Ü»ö Èò»ö ÅØ½ºÆ®
//    always_comb begin
//        if (pixel_on) begin
//            red   = 4'hf;
//            green = 4'h0;
//            blue  = 4'h0;
//        end else begin
//            red   = 4'h0;
//            green = 4'h0;
//            blue  = 4'h0;
//        end
//    end
    always_comb begin
        if (pixel_on) begin
            if (blue_detect) begin
                red   = 4'h0;
                green = 4'h0;
                blue  = 4'hf; // ÆÄ¶û
            end else if (red_detect) begin
                red   = 4'hf; // »¡°­
                green = 4'h0;
                blue  = 4'h0;
            end else begin
                red   = 4'hf; // ±âº» Èò»ö
                green = 4'hf;
                blue  = 4'hf;
            end
        end else begin
            red   = 4'h0;
            green = 4'h0;
            blue  = 4'h0;
        end
    end


endmodule

module font_rom (
    input  logic        clk,
    input  logic [10:0] addr,
    output logic [7:0]  data
);

    (* rom_style = "block" *)
    logic [7:0] rom [0:1023];

    initial begin
        $readmemh("Dispaly.mem", rom); // font data
    end

    always_ff @(posedge clk) begin
        data <= rom[addr];
    end

endmodule
