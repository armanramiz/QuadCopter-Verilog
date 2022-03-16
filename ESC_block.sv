module ESC_block(clk, wrt, rst_n, motors_off, frnt_spd, bck_spd, lft_spd, rght_spd, frnt, bck, lft, rght);
input clk, wrt, rst_n, motors_off;
input[10:0] frnt_spd, bck_spd, lft_spd, rght_spd;
output frnt, bck, lft, rght;

wire[10:0] frnt_in, bck_in, lft_in, rght_in;

// Instantiate electronic speed controller for each motor
ESC_interface front_ESC(.clk(clk), .rst_n(rst_n), .wrt(wrt), .SPEED(frnt_in), .PWM(frnt));
ESC_interface back_ESC(.clk(clk), .rst_n(rst_n), .wrt(wrt), .SPEED(bck_in), .PWM(bck));
ESC_interface left_ESC(.clk(clk), .rst_n(rst_n), .wrt(wrt), .SPEED(lft_in), .PWM(lft));
ESC_interface right_ESC(.clk(clk), .rst_n(rst_n), .wrt(wrt), .SPEED(rght_in), .PWM(rght));


// Continuous assignments
// Force all speeds to 0 if motors should be off.
assign frnt_in = motors_off ? 11'h000 : frnt_spd;
assign bck_in = motors_off ? 11'h000 : bck_spd;
assign lft_in = motors_off ? 11'h000 : lft_spd;
assign rght_in = motors_off ? 11'h000 : rght_spd;

endmodule