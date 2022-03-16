module ESC_interface(
    clk,
    rst_n,
    wrt,
    SPEED,
    PWM
);

input clk, rst_n, wrt;
input[10:0] SPEED;
output reg PWM;

wire[12:0] mult_result;
wire[13:0] setting;
wire Rst, Set;
reg[13:0] count_reg;
wire WRITE = wrt & ~PWM; // the & ~PWM can be removed probably, it was fixing a problem that should not have happened anyway
localparam BASE_SPEED = 13'h186A;

assign mult_result = SPEED * 2'h3;
assign setting = mult_result + BASE_SPEED;

// First flop, holding current number of clocks to pulse high
always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        count_reg <= 14'h0000;
    else
        count_reg <= WRITE ? setting : (count_reg - 1'b1);
end

// If output from flop is 0, trigger Rst to turn off PWM
assign Rst = ~|count_reg;
assign Set = /*PWM |*/ WRITE;

// Set-reset flop for PWM motor signal
always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        PWM <= 1'b0;
    else if (Set)
        PWM <= 1'b1;
    else if (Rst)
        PWM <= 1'b0;
end

endmodule