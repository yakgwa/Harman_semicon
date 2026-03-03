`timescale 1ns / 1ps

module VGA_Decoder (
    input  logic clk,
    input  logic reset,
    output logic h_sync,
    output logic v_sync,
    output logic DE,
    output logic [9:0] x_pixel,
    output logic [9:0] y_pixel
);
    logic pclk;
    logic [9:0] h_counter;
    logic [9:0] v_counter;

    pixel_clk_gen U_Pixel_Clk_Gen (.*);

    pixel_counter U_Pixel_Counter (
        .clk(pclk),
        .*
    );

    vgaDecoder U_VGA_Decoder (.*);
    
endmodule

module pixel_clk_gen (  // 100MHz -> 25MHz : 1/4
    input  logic clk,
    input  logic reset,
    output logic pclk
);

    logic [1:0] p_counter;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            p_counter <= 0;
        end else begin
            if (p_counter == 3) begin
                p_counter <= 0;
                pclk <= 1'b1;
            end else begin
                p_counter <= p_counter + 1;
                pclk <= 1'b0;
            end
        end
    end

endmodule

module pixel_counter (
    input  logic       clk,
    input  logic       reset,
    output logic [9:0] h_counter,
    output logic [9:0] v_counter
);

    localparam H_MAX = 800, V_MAX = 525;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            h_counter <= 0;
        end else begin
            if (h_counter == H_MAX - 1) begin
                h_counter <= 0;
            end else begin
                h_counter <= h_counter + 1;
            end
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            v_counter <= 0;
        end else begin
            if (h_counter == H_MAX - 1) begin
                if (v_counter == V_MAX - 1) begin
                    v_counter <= 0;
                end else begin
                    v_counter <= v_counter + 1;
                end
            end
        end
    end

endmodule

module vgaDecoder (
    input  logic [9:0] h_counter,
    input  logic [9:0] v_counter,
    output logic       h_sync,
    output logic       v_sync,
    output logic       DE,
    output logic [9:0] x_pixel,
    output logic [9:0] y_pixel
);

    localparam H_Visible_area = 640;
    localparam H_Front_porch = 16;
    localparam H_Sync_pulse = 96;
    localparam H_Back_porch = 48;

    localparam V_Visible_area = 480;
    localparam V_Front_porch = 10;
    localparam V_Sync_pulse = 2;
    localparam V_Back_porch = 33;

    assign h_sync = !((h_counter >= H_Visible_area+H_Front_porch) && (h_counter < H_Visible_area+H_Front_porch+H_Sync_pulse));
    assign v_sync = !((v_counter >= V_Visible_area+V_Front_porch) && (v_counter < V_Visible_area+V_Front_porch+V_Sync_pulse));
    assign DE = (h_counter < H_Visible_area) && (v_counter < V_Visible_area);
    assign x_pixel = h_counter;
    assign y_pixel = v_counter;
endmodule

    //assign h_sync = !((h_counter >= 656) && (h_counter < 752));
    //assign v_sync = !((h_counter >= 490) && (h_counter < 492));

module vgaPattern(
    input  logic DE,      // Data Enable (Active High)
    input  logic [9:0] x_pixel, // Horizontal Coordinate (0 to 639)
    input  logic [9:0] y_pixel, // Vertical Coordinate (0 to 479)
    output logic [3:0] red,   // 4-bit Red Output
    output logic [3:0] green,   // 4-bit Green Output
    output logic [3:0] blue    // 4-bit Blue Output
);

    localparam Y_UPPER = 320, Y_MIDDLE = 360, Y_LOWER = 480;

    reg [11:0] color;
    assign {red, green, blue} = color;

    wire [$clog2(8)-1:0] color_hnum;
    wire [$clog2(8)-1:0] color_hnum2;
    assign color_hnum  = x_pixel / 92;
    assign color_hnum2 = x_pixel / 108;

    always @(*) begin
        color = 12'b0;//12'bz;
        if (DE) begin
            if (y_pixel < Y_UPPER - 1) begin
                case (color_hnum)
                    3'd0: color = 12'b0110_0110_0110;
                    3'd1: color = 12'b1011_1011_0001;
                    3'd2: color = 12'b0001_1011_1011;
                    3'd3: color = 12'b0001_1011_0001;
                    3'd4: color = 12'b1011_0001_1011;
                    3'd5: color = 12'b1011_0001_0001;
                    3'd6: color = 12'b0001_0001_1011;
                endcase
            end else if (y_pixel < Y_MIDDLE - 1) begin
                case (color_hnum)
                    3'd0: color = 12'b0001_0001_1011;
                    3'd1: color = 12'b0000_0000_0000;
                    3'd2: color = 12'b1011_0001_1011;
                    3'd3: color = 12'b0000_0000_0000;
                    3'd4: color = 12'b0001_1011_1011;
                    3'd5: color = 12'b0000_0000_0000;
                    3'd6: color = 12'b0110_0110_0110;
                endcase
            end else begin
                case (color_hnum2)
                    3'd0: color = 12'b0100_0001_0111;
                    3'd1: color = 12'b1111_1111_1111;
                    3'd2: color = 12'b0010_0000_0100;
                    3'd3: color = 12'b0000_0000_0000;
                    3'd4: color = 12'b1111_1111_0000;
                    3'd5: color = 12'b0000_1111_1111;
                endcase
            end
        end
    end

endmodule
