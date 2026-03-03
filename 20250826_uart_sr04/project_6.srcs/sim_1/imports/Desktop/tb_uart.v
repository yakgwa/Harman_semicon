module tb_uart_sr04();
    reg clk;
    reg rst;
    reg start;
    reg echo;
    wire trig;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    reg rx;
    wire tx;
    wire data;
    reg [7:0] send_data;

    uart_sr04_top dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .echo(echo),
        .trig(trig),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
    #0; clk = 0; rst = 1; start = 0; echo = 0;
    #10; rst = 0;
    // 1st, start btn
    #10;
    send_data = 8'h64;
    send_uart(send_data);
    #100_000;
    #10;
    send_data = 8'h64;
    send_uart(send_data);
    #100_000;
    #10;
    send_data = 8'h64;
    send_uart(send_data);
    #100_000;    
    #10;
    send_data = 8'h72;
    send_uart(send_data);
    #100_000;    
    #10;
    send_data = 8'h64;
    send_uart(send_data);
    #100_000;    

    // 2nd, 10ns TTL delay time
    #11_000;

    // 3rd, 
    #10_000;
    echo = 1;
    #(1000_000); //1ms
    echo = 0;

    #(1000 * 10000);
    $stop;
    end

    task send_uart(input [7:0] send_data);
        integer i;
        begin
            // start bit
            rx = 0;
            #(104166);  // uart 9600bps bit time
            // data bit
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(104166);  // uart 9600bps bit time 
            end
            // stopbit
            rx = 1;
            #(1000);  // uart 9600bps bit time
        end
    endtask

endmodule