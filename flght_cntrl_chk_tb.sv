module flght_cntrl_chk_tb();

integer i;
localparam SIZE = 2000;

reg [107:0] stim_arr [0:1999];
reg [43:0] resp_arr [0:1999];

reg [107:0] stim;
reg [43:0] resp;

wire [10:0] frnt, bck, lft, rght;

reg clk;

int err_cnt;

flght_cntrl iDUT(
  .clk(clk),
  .rst_n(stim[107]),
  .vld(stim[106]),
  .inertial_cal(stim[105]),
  .d_ptch(stim[104:89]),
  .d_roll(stim[88:73]),
  .d_yaw(stim[72:57]),
  .ptch(stim[56:41]),
  .roll(stim[40:25]),
  .yaw(stim[24:9]),
  .thrst(stim[8:0]),

  .frnt_spd(frnt),
  .bck_spd(bck),
  .lft_spd(lft),
  .rght_spd(rght)
);

initial begin

    $readmemh("flght_cntrl_stim_nq.hex", stim_arr);
    $readmemh("flght_cntrl_resp_nq.hex", resp_arr);

    clk = 0;
    err_cnt = 0;

    $display("Starting flght_ctrl tests.");

    for(i = 0; i < SIZE; i = i + 1) begin
        
        stim = stim_arr[i];
        resp = resp_arr[i];

        @(posedge clk);
        #1        

        if(frnt !== resp[43:33]) begin
            $display("frnt: %h,\texp: %h", frnt, resp[43:33]);
            err_cnt = err_cnt + 1;
        end

        if(bck !== resp[32:22]) begin
            $display("bck: %h,\texp: %h", bck, resp[32:22]);
            err_cnt = err_cnt + 1;
        end

        if(lft !== resp[21:11]) begin
            $display("lft: %h,\texp: %h", lft, resp[21:11]);
            err_cnt = err_cnt + 1;
        end

        if(rght !== resp[10:0]) begin
            $display("rght: %h,\texp: %h", rght, resp[10:0]);
            err_cnt = err_cnt + 1;
        end

    end

    if(err_cnt == 0)
        $display("All tests passed!");
    else
        $display("Tests failed with %d errors.", err_cnt);

    $stop();

end

always begin
    #5 clk = ~clk;
end
    
endmodule