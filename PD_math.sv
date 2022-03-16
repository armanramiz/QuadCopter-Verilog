module PD_math(clk, rst_n, vld, desired, actual, pterm, dterm);

input clk, rst_n, vld;
input signed[15:0] desired, actual;
output signed[9:0] pterm;
output signed[11:0] dterm;

localparam COEFF = 5'b00111;
localparam D_QUEUE_DEPTH = 12;

logic signed[16:0] err;
logic signed[9:0] err_sat;
logic signed[9:0] err_pos, err_neg;
logic signed[9:0] D_diff;
logic signed[6:0] D_diff_sat, diff_pos, diff_neg;
logic signed[10*D_QUEUE_DEPTH - 1:0] prev_err;


// Calculate error with sign extended actual and desired values
assign err = {actual[15], actual} - {desired[15], desired};

// Get error values based on error being positive or negative
assign err_pos = (|err[15:9]) ? 10'b0111111111 : err[9:0];
assign err_neg = (&err[15:9]) ? err[9:0] : 10'b1000000000;
assign err_sat = err[16] ? err_neg : err_pos;

// Calculate pterm as 5/8 of error saturation value
assign pterm = (err_sat >>> 1) + (err_sat >>> 3);

// Assign previous error flop based on the depth of the error queue
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        prev_err <= 0;
    else if (vld)
        prev_err <= {err_sat, prev_err[10*D_QUEUE_DEPTH - 1:10]};
    
end

// Assignments for dterm and saturation values
assign D_diff = err_sat - prev_err[9:0];
assign diff_pos = (|D_diff[8:7]) ? 7'b0111111 : D_diff[6:0];
assign diff_neg = (&D_diff[8:6]) ? D_diff[6:0] : 7'b1000000;
assign D_diff_sat = D_diff[9] ? diff_neg : diff_pos;
assign dterm = D_diff_sat * $signed(COEFF);

endmodule