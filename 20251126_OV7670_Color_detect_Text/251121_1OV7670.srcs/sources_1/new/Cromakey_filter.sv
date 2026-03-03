`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/26 11:41:42
// Design Name: 
// Module Name: Cromakey_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ChromaKey (
    input  logic        clk,
    input  logic        reset,       
    input  logic [9:0]  x_pixel,
    input  logic [9:0]  y_pixel,
    input  logic        DE,
    output logic [3:0]  red_port,
    output logic [3:0]  green_port,
    output logic [3:0]  blue_port
);

    logic [11:0] rgb, rgb_o;
    logic [16:0] image_addr;
    logic [15:0] image_data, bg_image_data;

    logic chroma_en;


    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            chroma_en <= 1'b0;  
        else
            chroma_en <= 1'b1;  
    end

    assign rgb = {image_data[15:12], image_data[10:7], image_data[4:1]};
    assign bg_rgb = {
        bg_image_data[15:12], bg_image_data[10:7], bg_image_data[4:1]
    };

    assign rgb_o = (chroma_en && (rgb == 12'h0F0 || rgb == 12'h0F1))
                   ? bg_rgb : rgb;

    assign DE_1 = (x_pixel < 320 && y_pixel < 240) ? DE : 1'b0;

    assign image_addr = 320 * y_pixel + x_pixel;

    assign {red_port, green_port, blue_port} = DE_1 ? rgb_o : 12'b0;

    //=====================================================
    // image ROMs
    //=====================================================
    image_rom U_ROM (
        .addr(image_addr),
        .data(image_data)
    );

    bg_image_rom U_BG_ROM (
        .addr(image_addr),
        .data(bg_image_data)
    );

endmodule

module image_rom (
    input  logic [16:0] addr,
    output logic [15:0] data
);

    logic [15:0] rom[0:320*240-1];

    initial begin
        $readmemh("cat.mem", rom);
    end

    assign data = rom[addr];

endmodule

module bg_image_rom (
    input  logic [16:0] addr,
    output logic [15:0] data
);

    logic [15:0] rom[0:320*240-1];

    initial begin
        $readmemh("castle.mem", rom);
    end

    assign data = rom[addr];

endmodule

