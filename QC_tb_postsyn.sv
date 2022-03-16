`timescale 1ns/1ps
module QC_tb_postsyn();
			
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
QuadCopter iDUT(
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
 
  /// your intellectual property goes here ///
  clk = 0;
  clk_cnt = 0;
  RST_n = 0;
  clr_resp_rdy = 0;
  repeat (3) @(posedge clk);
  RST_n = 1;
  @(posedge clk);


  set_thrust(9'h0a0);

  delay(50000);

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


// set thrust task
task set_thrust(input [8:0] value);

  $display("Setting thrust to %h.", value);
  send_command(CMD_SET_THRST, {7'h0, value});
  await_response();
  $display("Thrust set acknowledged.");

endtask



task set_pitch(input [15:0] value);

  $display("Setting pitch to %h.", value);
  send_command(CMD_SET_PTCH, value);
  await_response();
  $display("Pitch set acknowledged.");

endtask



task set_roll(input [15:0] value);

  $display("Setting roll to %h.", value);
  send_command(CMD_SET_ROLL, value);
  await_response();
  $display("Roll set acknowledged.");

endtask



task set_yaw(input [15:0] value);

  $display("Setting yaw to %h.", value);
  send_command(CMD_SET_YAW, value);
  await_response();
  $display("Yaw set acknowledged.");

endtask

task set_motors_off();

  $display("Turning motors off.");
  send_command(CMD_MTRS_OFF, 16'h000);
  await_response();
  $display("Motors off acknowledged.");

endtask

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

// END TASKS ===================================================================================================================================

endmodule	
