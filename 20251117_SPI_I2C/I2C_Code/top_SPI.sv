`timescale 1ns / 1ps
module SPI_Slave (
    input        clk,
    input        reset,
    input        SCLK,
    input        MOSI,
    output       MISO,
    input        SS,
    output [3:0] an,
    output [7:0] seg
);

    wire [7:0] si_data;
    wire       si_done;
    wire [7:0] so_data;
    wire       so_start;
    wire       so_done;
    wire [7:0] fnd_data1, fnd_data2, fnd_data3, fnd_data4;

    SPI_Slave_Intf U_SPI_Slave_Intf (
        .clk(clk),
        .reset(reset),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS),
        .si_data(si_data),
        .si_done(si_done),
        .so_data(so_data),
        .so_start(so_start),
        .so_done(so_done)
    );

    SPI_Slave_Reg U_SPI_Slave_Reg (
        .clk(clk),
        .reset(reset),
        .ss_n(SS),
        .si_data(si_data),
        .si_done(si_done),
        .so_data(so_data),
        .so_start(so_start),
        .so_done(so_done),
        .fnd_data1(fnd_data1),
        .fnd_data2(fnd_data2),
        .fnd_data3(fnd_data3),
        .fnd_data4(fnd_data4)
    );

    fndController U_fnd_ctrl (
        .clk(clk),
        .reset(reset),
        .fndData(fnd_data1),
        .fndDot(4'b1111),
        .fndCom(an),
        .fndFont(seg)
    );
endmodule

module SPI_Slave_Intf (
    input        clk,
    input        reset,
    input        SCLK,
    input        MOSI,
    output       MISO,
    input        SS,
    output [7:0] si_data,
    output       si_done,
    input  [7:0] so_data,
    input        so_start,
    output       so_done
);

    reg sclk_sync0, sclk_sync1;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            sclk_sync0 <= 0;
            sclk_sync1 <= 0;
        end
        begin
            sclk_sync0 <= SCLK;
            sclk_sync1 <= sclk_sync0;
        end
    end

    wire sclk_rising = sclk_sync0 & ~sclk_sync1;
    wire sclk_falling = ~sclk_sync0 & sclk_sync1;

    // Slave Input Circuit(MOSI)
    localparam SI_IDLE = 0, SI_PHASE = 1;

    reg si_state, si_state_next;
    reg [7:0] si_data_reg, si_data_next;
    reg [2:0] si_bit_cnt_reg, si_bit_cnt_next;
    reg si_done_reg, si_done_next;

    assign si_done = si_done_reg;
    assign si_data = si_data_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            si_state <= SI_IDLE;
            si_data_reg <= 0;
            si_bit_cnt_reg <= 0;
            si_done_reg <= 0;
        end else begin
            si_state       <= si_state_next;
            si_data_reg    <= si_data_next;
            si_bit_cnt_reg <= si_bit_cnt_next;
            si_done_reg    <= si_done_next;
        end
    end

    always @(*) begin
        si_state_next = si_state;
        si_data_next = si_data_reg;
        si_bit_cnt_next = si_bit_cnt_reg;
        si_done_next = 0;
        case (si_state)
            SI_IDLE: begin
                si_done_next = 1'b0;
                if (!SS) begin
                    si_state_next   = SI_PHASE;
                    si_bit_cnt_next = 0;
                end
            end
            SI_PHASE: begin
                if (!SS) begin
                    if (sclk_rising) begin  // sclk_rising
                        si_data_next = {si_data_reg[6:0], MOSI};
                        if (si_bit_cnt_reg == 7) begin
                            si_done_next = 1'b1;
                            si_bit_cnt_next = 0;
                            si_state_next = SI_IDLE;  //**
                        end else begin
                            si_bit_cnt_next = si_bit_cnt_reg + 1;
                        end
                    end
                end else begin
                    si_state_next = SI_IDLE;
                end
            end
        endcase
    end

    // Slave Output Circuit(MISO)
    localparam SO_IDLE = 0, SO_PHASE = 1;

    reg so_state, so_state_next;
    reg [7:0] so_data_reg, so_data_next;
    reg [2:0] so_bit_cnt_reg, so_bit_cnt_next;
    reg so_done_reg, so_done_next;

    assign so_done = so_done_reg;
    assign MISO = ~SS ? so_data_reg[7] : 1'bz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            so_state       <= SO_IDLE;
            so_data_reg    <= 1'b0;
            so_bit_cnt_reg <= 0;
            so_done_reg    <= 0;
        end else begin
            so_state       <= so_state_next;
            so_data_reg    <= so_data_next;
            so_bit_cnt_reg <= so_bit_cnt_next;
            so_done_reg    <= so_done_next;
        end
    end

    always @(*) begin
        so_state_next = so_state;
        so_bit_cnt_next = so_bit_cnt_reg;
        so_data_next = so_data_reg;
        so_done_next = so_done_reg;  // 수정 ********** so_done_reg;
        case (so_state)
            SO_IDLE: begin
                so_done_next = 1'b0;
                if (!SS && so_start) begin
                    so_state_next = SO_PHASE;
                    so_bit_cnt_next = 0;
                    so_data_next = so_data;
                end
            end
            SO_PHASE: begin
                if (!SS) begin
                    if (sclk_falling) begin
                        so_data_next = {so_data_reg[6:0], 1'b0};
                        if (so_bit_cnt_reg == 7) begin
                            so_bit_cnt_next = 0;
                            so_done_next = 1'b1;
                            so_state_next = SO_IDLE;
                        end else begin
                            so_bit_cnt_next = so_bit_cnt_reg + 1;
                        end
                    end
                end else begin
                    so_state_next = SO_IDLE;
                end
            end
        endcase
    end
endmodule

module SPI_Slave_Reg (
    input            clk,
    input            reset,
    input            ss_n,
    input      [7:0] si_data,
    input            si_done,
    //input          so_ready,
    output reg [7:0] so_data,
    output           so_start,
    input            so_done,

    output [7:0] fnd_data1,
    output [7:0] fnd_data2,
    output [7:0] fnd_data3,
    output [7:0] fnd_data4
);
    localparam IDLE = 0, ADDR_PHASE = 1, WRITE_PHASE = 2, READ_DEALY =3, READ_PHASE = 4;
    reg [7:0] slv_reg[0:3], slv_reg_next[0:3];
    reg [2:0] state, state_next;
    reg [1:0] addr_reg, addr_next;
    reg so_start_reg, so_start_next;
    reg [$clog2(50)-1:0] clk_counter_reg, clk_counter_next;

    assign so_start  = so_start_reg;

    assign fnd_data1 = slv_reg[0];
    assign fnd_data2 = slv_reg[1];
    assign fnd_data3 = slv_reg[2];
    assign fnd_data4 = slv_reg[3];

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state           <= IDLE;
            addr_reg        <= 2'b0;
            so_start_reg    <= 1'b0;
            clk_counter_reg <= 0;
            slv_reg[0]      <= 0;
            slv_reg[1]      <= 0;
            slv_reg[2]      <= 0;
            slv_reg[3]      <= 0;
        end else begin
            state           <= state_next;
            addr_reg        <= addr_next;
            so_start_reg    <= so_start_next;
            clk_counter_reg <= clk_counter_next;
            slv_reg[0]      <= slv_reg_next[0];
            slv_reg[1]      <= slv_reg_next[1];
            slv_reg[2]      <= slv_reg_next[2];
            slv_reg[3]      <= slv_reg_next[3];
        end
    end

    always @(*) begin
        state_next       = state;
        addr_next        = addr_reg;
        so_start_next    = so_start_reg;
        so_data          = 0;
        clk_counter_next = clk_counter_reg;
        slv_reg_next[0]  = slv_reg[0];
        slv_reg_next[1]  = slv_reg[1];
        slv_reg_next[2]  = slv_reg[2];
        slv_reg_next[3]  = slv_reg[3];
        case (state)
            IDLE: begin
                so_start_next = 1'b0;
                if (!ss_n) begin
                    state_next = ADDR_PHASE;
                end
            end
            ADDR_PHASE: begin
                if (!ss_n) begin
                    if (si_done) begin
                        addr_next = si_data[1:0];
                        if (si_data[7]) begin
                            state_next = WRITE_PHASE;
                        end else begin
                            state_next = READ_DEALY;
                        end
                    end
                end else begin
                    state_next = IDLE;
                end
            end
            WRITE_PHASE: begin
                if (!ss_n) begin
                    if (si_done) begin
                        //     slv_reg_next[0] = si_data;
                        //     addr_next = 0;
                        // end
                        slv_reg_next[addr_reg] = si_data;
                        if (addr_reg == 3) begin
                            addr_next = 0;
                        end else begin
                            addr_next = addr_reg + 1;
                        end
                    end
                end else begin
                    state_next = IDLE;
                end
            end
            READ_DEALY: begin
                if (clk_counter_reg == 49) begin
                    state_next = READ_PHASE;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            READ_PHASE: begin
                if (!ss_n) begin
                    so_start_next = 1'b1;
                    so_data = slv_reg_next[addr_reg];
                    if (so_done) begin
                        if (addr_reg == 3) begin
                            addr_next = 0;
                            so_data   = slv_reg[0];
                        end else begin
                            addr_next = addr_reg + 1;
                            so_data   = slv_reg[addr_reg+1];
                        end
                    end
                end else begin
                    state_next = IDLE;
                end
            end
        endcase
    end
endmodule

