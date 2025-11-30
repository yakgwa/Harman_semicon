`timescale 1ns / 1ps

module command_router (
    // Inputs
    input current_function_mode, // from mode_manager
    input clear_pulse,           // from command_cu
    input up_pulse,
    input down_pulse,
    input left_pulse,
    input right_pulse,
    
    // Outputs (Routed signals)
    output sw_clear_en,
    output wc_up_en,
    output wc_down_en,
    output wc_left_en,
    output wc_right_en,
    output wc_clear_en
);

    assign sw_clear_en = (current_function_mode == 1'b0) ? clear_pulse : 1'b0;
    assign wc_up_en    = (current_function_mode == 1'b1) ? up_pulse    : 1'b0;
    assign wc_down_en  = (current_function_mode == 1'b1) ? down_pulse  : 1'b0;
    assign wc_left_en  = (current_function_mode == 1'b1) ? left_pulse  : 1'b0;
    assign wc_right_en = (current_function_mode == 1'b1) ? right_pulse : 1'b0;
    assign wc_clear_en = (current_function_mode == 1'b1) ? clear_pulse : 1'b0;

endmodule
