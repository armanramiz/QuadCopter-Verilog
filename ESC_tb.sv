module ESC_tb();

reg clk, rst_n, wrt;
reg [10:0] speed;
int cnt;

wire pwm;

ESC_interface iESC(
    .clk(clk), 
    .rst_n(rst_n), 
    .wrt(wrt), 
    .SPEED(speed), 
    .PWM(pwm)
);

initial begin
    
    cnt = 0;
    clk = 0;
    rst_n = 0;
    wrt = 0;
    repeat(3) @(posedge clk);
    rst_n = 1;

    test(11'h0);

    test(11'h7ff);

    repeat(10) test($random);

    $stop;

end

task test(input [10:0] spd);

    cnt = 0;
    speed = spd;

    wrt = 1;
    @(posedge clk);
    if(pwm) cnt = cnt + 1;
    wrt = 0;

    repeat(5000) begin
       @(posedge clk);
       if(pwm) cnt = cnt + 1;
    end

    $display("Speed: %h, PWM clocks: %d", speed, cnt);

endtask

always
    #1 clk = ~clk;

endmodule

