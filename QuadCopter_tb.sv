module QuadCopter_tb();
			
//// Interconnects to DUT/support defined as type wire /////
wire SS_n,SCLK,MOSI,MISO,INT;
wire RX,TX;
wire [7:0] resp;				// response from DUT
wire cmd_sent,resp_rdy;
wire frnt_ESC, back_ESC, left_ESC, rght_ESC;

////// Stimulus is declared as type reg ///////
reg clk, RST_n;
int clk_cnt;
reg [7:0] host_cmd;				// command host is sending to DUT
reg [15:0] host_data;				// data associated with command
reg send_cmd;					// asserted to initiate sending of command
reg clr_resp_rdy;				// asserted to knock down resp_rdy

reg signed [15:0] set_point;

/*wire[15:0] tb_ptch, tb_roll, tb_yaw;
wire[8:0] tb_thrst;
assign tb_ptch = iDUT.iNEMO.ptch;
assign tb_roll = iDUT.iNEMO.roll;
assign tb_yaw = iDUT.iNEMO.yaw;
assign tb_thrst = iDUT.iCMD.thrst;*/

//// define some localparams for command encoding ///
localparam CMD_SET_PTCH = 8'h2;
localparam CMD_SET_ROLL = 8'h3;
localparam CMD_SET_YAW = 8'h4;
localparam CMD_SET_THRST = 8'h5;
localparam CMD_CAL = 8'h6;
localparam CMD_EMER_LAND = 8'h7;
localparam CMD_MTRS_OFF = 8'h8;
localparam POS_ACK = 8'hA5;
localparam CAL_SPEED = 11'h290;		// speed to run motors at during inertial calibration

parameter FAST_SIM = 1;

////////////////////////////////////////////////////////////////
// Instantiate Physical Model of Copter with Inertial sensor //
//////////////////////////////////////////////////////////////	
CycloneIV iQuad(
  .clk(clk),
  .RST_n(RST_n),
  .SS_n(SS_n),
  .SCLK(SCLK),
  .MISO(MISO),
  .MOSI(MOSI),
  .INT(INT),
  .frnt_ESC(frnt_ESC),
  .back_ESC(back_ESC),
	.left_ESC(left_ESC),
  .rght_ESC(rght_ESC)
);	
	 
	 
////// Instantiate DUT ////////
QuadCopter #(FAST_SIM) iDUT(
  .clk(clk),
  .RST_n(RST_n),
  .SS_n(SS_n),
  .SCLK(SCLK),
  .MOSI(MOSI),
  .MISO(MISO),
  .INT(INT),
  .RX(RX),
  .TX(TX),
  .FRNT(frnt_ESC),
  .BCK(back_ESC),
	.LFT(left_ESC),
  .RGHT(rght_ESC)
);


//// Instantiate Master UART (mimics host commands) //////
RemoteComm iREMOTE(
  .clk(clk),
  .rst_n(RST_n),
  .RX(TX),
  .TX(RX),
  .cmd(host_cmd),
  .data(host_data),
  .send_cmd(send_cmd),
	.cmd_sent(cmd_sent),
  .resp_rdy(resp_rdy),
	.resp(resp),
  .clr_resp_rdy(clr_resp_rdy)
);

initial begin
 
  // setup
  clk = 0;
  clk_cnt = 0;
  RST_n = 0;
  clr_resp_rdy = 0;
  repeat (3) @(posedge clk);
  RST_n = 1;
  @(posedge clk);


  // calibrate
  calibrate();
  delay(500000);

  // next few commands achieve a hover
  set_thrust(9'd160);
  delay(50000);

  set_thrust(9'h000);
  await_vert_v(16'h80, 16'h1, 7500000);

  set_thrust(9'h10);
  delay(10000);

  // run a bunch of random tests on pitch, roll, yaw
  repeat(3) begin
    
      // randomize pitch and wait
      rand_set_point();
      set_pitch(set_point);
      await_pitch(set_point, 5, 10000000);

      // randomize roll and wait
      rand_set_point();
      set_roll(set_point);
      await_roll(set_point, 5, 10000000);

      // randomize yaw and wait
      rand_set_point();
      set_yaw(set_point);
      await_yaw(set_point, 5, 10000000);

  end

  // turn motors off at the end
  set_motors_off();

  $display("Testing complete.");
  $stop;

end



always begin
  #10 clk = ~clk;
end

always @(posedge clk) 
  clk_cnt = clk_cnt + 1;







// BEGIN TASKS =================================================================================================================================

task delay(int cycles);
  repeat (cycles) @(posedge clk);
endtask


// send a new command
task send_command(input [7:0] cmd, input [15:0] data);

  host_cmd = cmd;
  host_data = data;
  send_cmd = 1;
  @(posedge clk);
  send_cmd = 0;

endtask


// wait for the response acknowledgement
task await_response();
  
  fork

    begin

      @(posedge resp_rdy);

      clr_resp_rdy = 1;
      @(posedge clk) clr_resp_rdy = 0;

      if (resp !== POS_ACK) begin
        $display("Response not POS_ACK");
        $stop;
      end

      disable response_timeout;
      
    end

    begin : response_timeout

      repeat (500000) @(posedge clk);
      $display("No response received.");
      $stop;
      
    end

  join

endtask


// calibration task, check speed settings
task calibrate();

  $display("Starting calibration.");
  
  // Send calibration command, check that motors are all at calibration speed
  send_command(CMD_CAL, 16'h0000);

  @(posedge iDUT.inertial_cal);

  if (iDUT.frnt_spd !== CAL_SPEED) begin
    $display("Incorrect motor speed. Expected: %h, actual: %h", CAL_SPEED, iDUT.frnt_spd);
    //$stop;
  end

  await_response();

  $display("Calibration complete.");

endtask


// set thrust task
task set_thrust(input [8:0] value);

  $display("Setting thrust to %h.", value);
  send_command(CMD_SET_THRST, {7'h0, value});
  await_response();
  $display("Thrust set acknowledged.");

endtask


// set pitch task
task set_pitch(input signed [15:0] value);

  $display("Setting pitch to %d.", value);
  send_command(CMD_SET_PTCH, value);
  await_response();
  $display("Pitch set acknowledged.");

endtask


// set roll task
task set_roll(input signed [15:0] value);

  $display("Setting roll to %d.", value);
  send_command(CMD_SET_ROLL, value);
  await_response();
  $display("Roll set acknowledged.");

endtask


// set yaw task
task set_yaw(input signed [15:0] value);

  $display("Setting yaw to %d.", value);
  send_command(CMD_SET_YAW, value);
  await_response();
  $display("Yaw set acknowledged.");

endtask

// turn motors off task
task set_motors_off();

  $display("Turning motors off.");
  send_command(CMD_MTRS_OFF, 16'h000);
  await_response();
  $display("Motors off acknowledged.");

endtask


// wait for vertical velocity
task await_vert_v(
  input signed [15:0] target, 
  input signed [15:0] range, 
  int wait_time
);

  fork

    begin

      while (1) begin

        @(posedge iQuad.calc_physics);

        if(iQuad.vert_v >= (target - range) && iQuad.vert_v <= (target + range)) begin
          
          disable vert_v_timeout;

          $display("Achieved vert_v of %d.", iQuad.vert_v);

          break;

        end

      end

    end

    begin : vert_v_timeout

      repeat (wait_time) @(posedge clk);
      $display("Did not reach desired vert_v.");
      $stop;
      
    end

  join
  
endtask


// wait for pitch
task await_pitch(
  input signed [15:0] target, 
  input signed [15:0] range, 
  int wait_time
);

  fork

    begin

      while (1) begin

        @(posedge iDUT.iNEMO.vld);

        if(iDUT.iNEMO.ptch >= (target - range) && iDUT.iNEMO.ptch <= (target + range)) begin
          
          disable pitch_timeout;

          $display("Achieved pitch of %d.", target);

          break;

        end

      end

    end

    begin : pitch_timeout

      repeat (wait_time) @(posedge clk);
      $display("Did not reach desired pitch.");
      $stop;
      
    end

  join
  
endtask


// wait for roll
task await_roll(
  input signed [15:0] target, 
  input signed [15:0] range, 
  int wait_time
);

  fork

    begin

      while (1) begin

        @(posedge iDUT.iNEMO.vld);

        if(iDUT.iNEMO.roll >= (target - range) && iDUT.iNEMO.roll <= (target + range)) begin
          
          disable roll_timeout;

          $display("Achieved roll of %d.", target);

          break;

        end

      end

    end

    begin : roll_timeout

      repeat (wait_time) @(posedge clk);
      $display("Did not reach desired roll.");
      $stop;
      
    end

  join
  
endtask


// wait for yaw
task await_yaw(
  input signed [15:0] target, 
  input signed [15:0] range, 
  int wait_time
);

  fork

    begin

      while (1) begin

        @(posedge iDUT.iNEMO.vld);

        if(iDUT.iNEMO.yaw >= (target - range) && iDUT.iNEMO.yaw <= (target + range)) begin
          
          disable yaw_timeout;

          $display("Achieved yaw of %d.", target);

          break;

        end

      end

    end

    begin : yaw_timeout

      repeat (wait_time) @(posedge clk);
      $display("Did not reach desired yaw.");
      $stop;
      
    end

  join
  
endtask

// generate a random set point between -255 and 255
task rand_set_point();
  set_point = -16'd255 + $random%16'd512;
endtask

// END TASKS ===================================================================================================================================







endmodule	

