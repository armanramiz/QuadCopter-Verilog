module reset_synch(
    RST_n, clk, rst_n
);

input RST_n, clk;
output rst_n;

// meta-stability flops
reg ff1, ff2;

// output is just seconds flop
assign rst_n = ff2;

// first flop logic
always @(posedge clk, negedge RST_n) begin
    
    if(!RST_n) 
        ff1 <= 1'b0;
    else
        ff1 <= 1'b1;

end

// second flop logic, might be able to be shared in 
// same always block but just being safe here
always @(posedge clk, negedge RST_n) begin
    
    if(!RST_n) 
        ff2 <= 1'b0;
    else
        ff2 <= ff1;

end

endmodule