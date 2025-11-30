module command_cu_sensor(
    input            clk,
    input            rst,
    input            empty_ctrl,
    input      [7:0] ctrl_data,
    output reg       sr_start_trig,
    output reg       dht_start_trig,
    output  reg       o_pop
);
    parameter IDLE = 1'b0, RECIEVE = 1'b1;
    reg state, next;
    reg [7:0] asc_data_reg, asc_data_next;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            asc_data_reg <= 0;
        end else begin
            asc_data_reg <= asc_data_next;
            state <= next;
        end
    end
    always @(*) begin
        next = state;
        sr_start_trig = 1'b0;
        dht_start_trig = 1'b0;
        o_pop = 1'b0;
        asc_data_next= asc_data_reg;
        case (state)
            IDLE: begin
                asc_data_next= 0;
                sr_start_trig = 1'b0;
                dht_start_trig = 1'b0;
                if (!empty_ctrl) begin
                    o_pop = 1'b1;
                    asc_data_next = ctrl_data;
                    next = RECIEVE;
                end
            end
            RECIEVE: begin
                case (asc_data_reg)
                    "d":begin
                        o_pop = 1'b0;
                        sr_start_trig = 1'b1;
                    end 
                    "o":begin
                        o_pop = 1'b0;
                        dht_start_trig = 1'b1;
                    end
                endcase
                if (empty_ctrl) begin
                    next = IDLE;
                    asc_data_next = 1'b0;
                end
            end
        endcase
    end
endmodule

