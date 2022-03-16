module cmd_cfg_tb();

reg clk, rst_n;
logic [15:0] data_in, data_out, rand_16;
logic [8:0] rand_9;
logic [7:0] cmd_in, cmd_out, resp, resp_out;
logic send_cmd, resp_rdy, RX_TX, TX_RX, clr_cmd_rdy, send_resp, resp_sent, strt_cal, inertial_cal, cal_done, motors_off, clr_resp_rdy, cmd_rdy;

integer err_cnt;

//internal TB signals
defparam CMD.FAST_SIM = 0;

localparam DELAY_CLK = 200000;

wire signed [15:0] d_ptch, d_roll, d_yaw;
wire [8:0] thrst;

localparam POS_ACK = 8'hA5;
localparam SET_PTCH = 8'h2;
localparam SET_ROLL = 8'h3;
localparam SET_YAW = 8'h4;
localparam SET_THRST = 8'h5;
localparam CALIBRATE = 8'h6;
localparam EMER_LAND = 8'h7;
localparam MTRS_OFF = 8'h8;

// Instantiate cmd_cfg, UART_comm, RemoteComm
cmd_cfg CMD (
    .clk(clk),
    .rst_n(rst_n),
    .cmd_rdy(cmd_rdy),
    .cmd(cmd_out),
    .data(data_out),
    .clr_cmd_rdy(clr_cmd_rdy),
    .resp(resp),
    .send_resp(send_resp),
    .d_ptch(d_ptch),
    .d_roll(d_roll),
    .d_yaw(d_yaw),
    .thrst(thrst),
    .strt_cal(strt_cal),
    .inertial_cal(inertial_cal),
    .cal_done(cal_done),
    .motors_off(motors_off)
);

UART_comm UART_comm(
    .clk(clk),
    .rst_n(rst_n),
    .RX(TX_RX), 
    .TX(RX_TX),
    .resp(resp),
    .send_resp(send_resp),
    .resp_sent(resp_sent),
    .cmd_rdy(cmd_rdy),
    .cmd(cmd_out),
    .data(data_out),
    .clr_cmd_rdy(clr_cmd_rdy)
);
RemoteComm Remote_comm(
    .clk(clk),
    .rst_n(rst_n),
    .RX(RX_TX),
    .TX(TX_RX),
    .cmd(cmd_in),
    .data(data_in),
    .send_cmd(send_cmd),
    .cmd_sent(cmd_sent),
    .resp_rdy(resp_rdy),
    .resp(resp_out),
    .clr_resp_rdy(clr_resp_rdy)
);

// clock generator
always begin
    #1 clk = ~clk;
end


initial begin
    // init testing
    clk = 0;
    rst_n = 0;
    err_cnt = 0;

    repeat (2) @(posedge clk);

    rst_n = 1;

    // start testing

    // test calibrate
    test_cal();

    test_set_pitch(16'h1234);
    test_set_roll(16'h1234);
    test_set_yaw(16'h1234);
    test_set_thrst(9'h123);

    repeat(5) begin

        rand_16 = $random();
        test_set_pitch(rand_16);

        rand_16 = $random();
        test_set_roll(rand_16);
    
        rand_16 = $random();
        test_set_yaw(rand_16);

        rand_9 = $random();
        test_set_thrst(rand_9);

        test_set_EMER_LAND();
        
        test_set_motorsoff();

    end

    // end testing
    if(err_cnt == 0) 
        $display("All tests passed!");
    else 
        $display("Tests failed with %d errors.", err_cnt);

    $stop;
    
end

task test_cal();
    
    cmd_in = CALIBRATE;
    data_in = 16'h0000;
    send_cmd = 1;
    @(posedge clk) send_cmd = 0;


    fork
        begin : start_cal
            @(posedge strt_cal);
            disable timeout1;
        end
        begin : timeout1
            repeat (DELAY_CLK) @(posedge clk);
            $display("Calibration never started!");
            err_cnt = err_cnt + 1;
            disable start_cal;
        end
    join
    cal_done = 1'b1;
    fork
        begin : cal_resp_rdy
            @(posedge resp_rdy);
            if (resp_out !== POS_ACK) begin
                $display("Incorrect response received.");
                err_cnt = err_cnt + 1;
            end
            clr_resp_rdy = 1;
            disable timeout2;
        end
        begin : timeout2
            repeat (DELAY_CLK) @(posedge clk);
            $display("Response never ready!");
            err_cnt = err_cnt + 1;
            disable cal_resp_rdy;
        end
    join

    @(posedge clk) clr_resp_rdy = 0;

endtask

// task for waiting for resp_rdy and checking for POS_ACK
task wait_for_resp();
    fork
        begin : wait_resp_rdy
            @(posedge resp_rdy) clr_resp_rdy = 1'b1;

            if(resp_out != POS_ACK) begin
                $display("ERROR: Response received was not POS_ACK.");
                err_cnt = err_cnt + 1;
            end

            @(posedge clk) clr_resp_rdy = 1'b0;

            disable timeout;
        end
        begin : timeout
            repeat (DELAY_CLK) @(posedge clk);
            $display("ERROR: Never received response!");
            err_cnt = err_cnt + 1;
            disable wait_resp_rdy;
        end
    join
endtask

// task for sending a command (data must be set before running this)
task send_command(input [7:0] command);
    
    cmd_in = command; // change
    send_cmd = 1'b1;

    @(posedge clk) send_cmd = 1'b0;

endtask

// SET PITCH TEST
task test_set_pitch(input [15:0] des_val);

    data_in = des_val;

    send_command(SET_PTCH);
    wait_for_resp();

    // change check value for each command
    if(d_ptch !== des_val) begin
        err_cnt = err_cnt + 1;
        
        // change output message
        $display("ERROR: desired set pitch: %h, actual set pitch: %h", des_val, d_ptch);
    end
 
endtask

// SET ROLL TEST
task test_set_roll(input [15:0] des_val);

    data_in = des_val;

    send_command(SET_ROLL);
    wait_for_resp();

    // change check value for each command
    if(d_roll !== des_val) begin
        err_cnt = err_cnt + 1;
        
        // change output message
        $display("ERROR: desired set roll: %h, actual set roll: %h", des_val, d_roll);
    end
 
endtask

// SET YAW TEST
task test_set_yaw(input [15:0] des_val);

    data_in = des_val;

    send_command(SET_YAW);
    wait_for_resp();

    // change check value for each command
    if(d_yaw !== des_val) begin
        err_cnt = err_cnt + 1;
        
        // change output message
        $display("ERROR: desired set yaw: %h, actual set yaw: %h", des_val, d_yaw);
    end
 
endtask

// SET THRUST TEST
task test_set_thrst(input [8:0] des_val);

    data_in = {7'h0, des_val};
    cmd_in = SET_THRST; // change
    send_cmd = 1'b1;

    @(posedge clk) send_cmd = 1'b0;

    wait_for_resp();

    if(resp_out == POS_ACK) begin

        // change check value for each command
        if(thrst !== des_val) begin
            err_cnt = err_cnt + 1;
            
            // change output message
            $display("ERROR: desired set thrust: %h, actual set thrust: %h", des_val, d_yaw);
        end

    end else begin
        err_cnt = err_cnt + 1;
        $display("ERROR: ACK response not received");
    end
 
endtask






// EMERGENCY LAND TEST
task test_set_EMER_LAND();

    cmd_in = EMER_LAND; // change
    send_cmd = 1'b1;

    @(posedge clk) send_cmd = 1'b0;

    wait_for_resp();

    if(resp_out == POS_ACK) begin

        // change check value for each command
        if((d_ptch != 15'h0) || (d_yaw != 15'h0) || (d_roll != 15'h0) || (thrst != 15'h0)) begin
            err_cnt = err_cnt + 1;
            
            // change output message
            $display("ERROR: motors should have been turned off");
        end

    end else begin 
        err_cnt = err_cnt + 1;
        $display("ERROR: ACK response not received");
    end
 
endtask

// MOTORS OFF TEST
task test_set_motorsoff();

    cmd_in = MTRS_OFF; // change
    send_cmd = 1'b1;

    @(posedge clk) send_cmd = 1'b0;

    wait_for_resp();

    if(resp_out == POS_ACK) begin

        // change check value for each command
        if(!motors_off) begin
            err_cnt = err_cnt + 1;
            
            // change output message
            $display("ERROR: motors should have been turned off");
        end

    end else begin
        err_cnt = err_cnt + 1;
        $display("ERROR: ACK response not received");
    end
 
endtask

endmodule