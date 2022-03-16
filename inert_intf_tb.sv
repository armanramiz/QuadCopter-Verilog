module inert_intf_tb();

logic clk, rst_n, strt_cal, INT, SS_n, SCLK, MOSI, MISO, vld, cal_done;
logic[15:0] ptch, roll, yaw;

localparam DELAY_SIM = 8_000_000;
localparam DELAY_CLK_NEMO_SETUP = 2_500_000;

parameter FAST_SIM = 1;

// Instantiate inertial interface
inert_intf #(FAST_SIM) IIntf(
    .clk(clk),
    .rst_n(rst_n),
    .strt_cal(strt_cal),
    .INT(INT),
    .SS_n(SS_n),
    .SCLK(SCLK),
    .MOSI(MOSI),
    .MISO(MISO),
    .vld(vld),
    .cal_done(cal_done),
    .ptch(ptch),
    .roll(roll),
    .yaw(yaw)
);

// Instantiate SPI_iNEMO3
SPI_iNEMO3 SN3(
    .SS_n(SS_n),
    .SCLK(SCLK),
    .MOSI(MOSI), 
    .MISO(MISO),
    .INT(INT),
    .AX(16'h0),
    .AY(16'h0),
    .PTCH(16'h0),
    .ROLL(16'h0),
    .YAW(16'h0)
);

initial begin
    clk = 0;
    rst_n = 0;
    strt_cal = 0;
    repeat (3) @(posedge clk);
    rst_n = 1;



    //Wait for interface internal timer to expire and NEMO_setup = 1
    fork
        begin : wait_nemo
            repeat (DELAY_CLK_NEMO_SETUP) begin 
                
                @(posedge clk);

                // could not do posedge for nemo setup because it starts out as x... should probably fix
                if(SN3.NEMO_setup) disable wait_nemo;

            end

            $display("NEMO_setup never asserted");
            $stop;

        end
        
    join

    // now start calibration
    strt_cal = 1;
    @(posedge clk) strt_cal = 0;

    fork
        begin
            @(posedge cal_done);
            disable timeout;
        end
        begin: timeout
            repeat (DELAY_CLK_NEMO_SETUP) @(posedge clk);
            $display("Calibration timeout");
            $stop;
        end
    join

    // Run for a while and plot analog pitch, roll, yaw results
    repeat (DELAY_SIM) @(posedge clk);
    $stop;
end

always
    #5 clk = ~clk;

endmodule