`timescale 1ns / 1ps

module OV7670_CCTV (
    input  logic        clk,
    input  logic        reset,
    // ov7670 side
    output logic        xclk,
    input  logic        pclk,
    input  logic        href,
    input  logic        vsync,
    input  logic [ 7:0] data,
    // vga port
    output logic        h_sync,
    output logic        v_sync,
    output logic [ 3:0] r_port,
    output logic [ 3:0] g_port,
    output logic [ 3:0] b_port,
    // frame splitter port
    input  logic        saving,
    input  logic [16:0] save_rAddr,
    output logic [15:0] ram_rData,
    // frame stop btn
    input  logic        freeze_sw,
    output logic o_DE,
    // output scl, sda
    inout wire        scl,
    inout wire        sda
);
    logic        sys_clk;
    logic        DE;
    logic [ 9:0] x_pixel;
    logic [ 9:0] y_pixel;
    logic [16:0] vga_rAddr;
    logic [16:0] ram_rAddr;
    logic        we_cam;
    logic        we_ram;
    logic [16:0] wAddr;
    logic [15:0] wData;
    logic [ 3:0] w_r_port, w_g_port, w_b_port;
    logic [ 9:0] aim_x, aim_y;
    logic        aim_detected;

    assign xclk = sys_clk;
    assign we_ram = we_cam & ~freeze_sw;
    assign ram_rAddr = saving ? save_rAddr : vga_rAddr;
    assign o_DE = DE;

    pixel_clk_gen U_PXL_CLK_GEN (
        .clk  (clk),
        .reset(reset),
        .pclk (sys_clk)
    );

    VGA_Syncher VGA_Syncher (
        .clk    (sys_clk),
        .reset  (reset),
        .h_sync (h_sync),
        .v_sync (v_sync),
        .DE     (DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );

    ImgMemReader U_IMG_Reader (
        .DE     (DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .addr   (vga_rAddr),
        .imgData(ram_rData),
        .r_port (w_r_port),
        .g_port (w_g_port),
        .b_port (w_b_port)
    );

    frame_buffer U_Frame_Buffer (
        .wclk (pclk),
        .we   (we_ram),
        .wAddr(wAddr),
        .wData(wData),
        .rclk (sys_clk),
        .oe   (1'b1),
        .rAddr(ram_rAddr),
        .rData(ram_rData)
    );

    OV7670_Mem_Controller U_OV7670_Mem_Controller (
        .pclk (pclk),
        .reset(reset),
        .href (href),
        .vsync(vsync),
        .data (data),
        .we   (we_cam),
        .wAddr(wAddr),
        .wData(wData)
    );

    sccbTop u_sccb (
        .clk,
        .reset,
        .sda,
        .scl
    );
    
    red_tracker U_RED_TRACKER (
        .clk         (sys_clk),
        .reset       (reset),
        .v_sync      (v_sync),
        .DE          (DE),
        .x_pixel     (x_pixel),
        .y_pixel     (y_pixel),
        .data        (ram_rData),
        .aim_x       (aim_x),
        .aim_y       (aim_y),
        .aim_detected(aim_detected)
    );    
  
    pixel_mixer U_PIXEL_MIXER (
        .img_bg        ({w_r_port, w_g_port, w_b_port}),
        .aim_x         (aim_x),
        .aim_y         (aim_y),
        .aim_detected  (aim_detected),
        .x_pixel       (x_pixel),
        .y_pixel       (y_pixel),
        .r_port        (r_port),
        .g_port        (g_port),
        .b_port        (b_port)
    );  
    
endmodule

module red_tracker (
    input  logic        clk,
    input  logic        reset,
    input  logic        v_sync,
    input  logic        DE,
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic [15:0] data,
    output logic [9:0]  aim_x,
    output logic [9:0]  aim_y,
    output logic        aim_detected
);

    logic [4:0] r_val;
    logic [5:0] g_val;
    logic [4:0] b_val;

    assign r_val = data[15:11];
    assign g_val = data[10:5];
    assign b_val = data[4:0];

    logic is_red;
    assign is_red = (r_val > 5'd20) && (g_val < 6'd15) && (b_val < 5'd15);

    logic [11:0] x_min, x_max;
    logic [11:0] y_min, y_max;
    logic [16:0] pixel_count;

    logic vsync_d;
    logic vsync_start;

    always_ff @(posedge clk) begin
        vsync_d <= v_sync;
    end

    assign vsync_start = v_sync && !vsync_d;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            aim_x <= 0;
            aim_y <= 0;
            aim_detected <= 0;
            x_min <= 12'd4095; 
            x_max <= 0; 
            y_min <= 12'd4095; 
            y_max <= 0;
            pixel_count <= 0;
        end else begin
            if (vsync_start) begin
                if (pixel_count > 50) begin
                    aim_detected <= 1'b1;
                    aim_x <= (x_min + x_max) >> 1;
                    aim_y <= (y_min + y_max) >> 1;
                end else begin
                    aim_detected <= 1'b0;
                end

                x_min <= 12'd4095; 
                x_max <= 0;
                y_min <= 12'd4095; 
                y_max <= 0;
                pixel_count <= 0;

            end else begin
                if (DE && is_red && (x_pixel > 10) && (x_pixel < 630)) begin
                    pixel_count <= pixel_count + 1;

                    if ({2'b00, x_pixel} < x_min) x_min <= {2'b00, x_pixel};
                    if ({2'b00, x_pixel} > x_max) x_max <= {2'b00, x_pixel};

                    if ({2'b00, y_pixel} < y_min) y_min <= {2'b00, y_pixel};
                    if ({2'b00, y_pixel} > y_max) y_max <= {2'b00, y_pixel};
                end
            end
        end
    end

endmodule

module pixel_mixer (
    input  logic [11:0] img_bg,
    
    input  logic [ 9:0] aim_x,
    input  logic [ 9:0] aim_y,
    input  logic        aim_detected,
    
    input  logic [ 9:0] x_pixel,
    input  logic [ 9:0] y_pixel,
    
    output logic [ 3:0] r_port,
    output logic [ 3:0] g_port,
    output logic [ 3:0] b_port
);

    localparam logic [11:0] RED = 12'hF00;
    
    localparam logic [11:0] AIM_COLOR = RED; 

    localparam THK = 1; 
    localparam LEN = 10; 

    always_comb begin
        logic [11:0] pixel_color;

        pixel_color = img_bg;

        if (aim_detected) begin
            // LEFT border
            if ((x_pixel >= aim_x - LEN) && (x_pixel <= aim_x - LEN + THK) &&
                (y_pixel >= aim_y - LEN) && (y_pixel <= aim_y + LEN))
                pixel_color = AIM_COLOR;

            // RIGHT border
            else if ((x_pixel <= aim_x + LEN) && (x_pixel >= aim_x + LEN - THK) &&
                     (y_pixel >= aim_y - LEN) && (y_pixel <= aim_y + LEN))
                pixel_color = AIM_COLOR;

            // TOP border
            else if ((y_pixel >= aim_y - LEN) && (y_pixel <= aim_y - LEN + THK) &&
                     (x_pixel >= aim_x - LEN) && (x_pixel <= aim_x + LEN))
                pixel_color = AIM_COLOR;

            // BOTTOM border
            else if ((y_pixel <= aim_y + LEN) && (y_pixel >= aim_y + LEN - THK) &&
                     (x_pixel >= aim_x - LEN) && (x_pixel <= aim_x + LEN))
                pixel_color = AIM_COLOR;
        end
//        if (aim_detected) begin
//            if ((y_pixel >= aim_y - THK) && (y_pixel <= aim_y + THK) &&
//                (x_pixel >= aim_x - LEN) && (x_pixel <= aim_x + LEN)) begin
//                pixel_color = AIM_COLOR;
//            end 
//            else if ((x_pixel >= aim_x - THK) && (x_pixel <= aim_x + THK) &&
//                     (y_pixel >= aim_y - LEN) && (y_pixel <= aim_y + LEN)) begin
//                pixel_color = AIM_COLOR;
//            end
//        end

        {r_port, g_port, b_port} = pixel_color;
    end

endmodule