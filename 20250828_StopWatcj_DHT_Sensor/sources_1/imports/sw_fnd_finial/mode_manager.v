`timescale 1ns / 1ps

module mode_manager (
    input clk,
    input rst,
    
    // Inputs from physical switches
    input sw0,
    input sw1,
    
    // Inputs from command_cu
    input runstop_pulse,
    input mode_switch_pulse,
    input fnd_toggle_pulse,
    
    // Outputs (The System's Current State)
    output reg current_function_mode,
    output reg fnd_display_mode,
    output reg sw_runstop
);

    // --- Switch Edge-Detection ---
    reg  sw0_reg, sw1_reg;
    wire sw0_flipped, sw1_flipped;

    always @(posedge clk) begin
        sw0_reg <= sw0;
        sw1_reg <= sw1;
    end
    assign sw0_flipped = (sw0 != sw0_reg);
    assign sw1_flipped = (sw1 != sw1_reg);

    // --- FND Display Mode Management ---
    always @(posedge clk) begin
        if (rst) fnd_display_mode <= sw0;
        else if (fnd_toggle_pulse || sw0_flipped) fnd_display_mode <= ~fnd_display_mode;
    end

    // --- Function Mode Management ---
    always @(posedge clk) begin
        if (rst) current_function_mode <= sw1;
        else if (mode_switch_pulse || sw1_flipped) current_function_mode <= ~current_function_mode;
    end

    // --- Stopwatch Run/Stop Toggle ---
    always @(posedge clk) begin
        if (rst) sw_runstop <= 1'b0;
        else if (current_function_mode == 1'b0 && runstop_pulse) sw_runstop <= ~sw_runstop;
    end

endmodule
