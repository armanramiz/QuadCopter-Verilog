module PB_release(
    PB, clk, rst_n, released
);

input PB, clk, rst_n;
output released;

// flops
reg ff1, ff2, ff3;

// rising edge detector
assign released = ff2 & ~ff3;

// first flop
always @(posedge clk, negedge rst_n) begin
    
    if(!rst_n)
        ff1 <= 1'b1;
    else
        ff1 <= PB;

end

// second flop
always @(posedge clk, negedge rst_n) begin
    
    if(!rst_n)
        ff2 <= 1'b1;
    else
        ff2 <= ff1;

end

// third flop
always @(posedge clk, negedge rst_n) begin
    
    if(!rst_n)
        ff3 <= 1'b1;
    else
        ff3 <= ff2;

end

endmodule