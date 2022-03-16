module flght_cntrl(
  clk,
  rst_n,
  vld,
  inertial_cal,
  d_ptch,
  d_roll,
  d_yaw,ptch,
	roll,
  yaw,
  thrst,
  frnt_spd,
  bck_spd,
  lft_spd,
  rght_spd
);
				
input clk,rst_n;
input vld;									// tells when a new valid inertial reading ready
											// only update D_QUEUE on vld readings
input inertial_cal;							// need to run motors at CAL_SPEED during inertial calibration
input signed [15:0] d_ptch,d_roll,d_yaw;	// desired pitch roll and yaw (from cmd_cfg)
input signed [15:0] ptch,roll,yaw;			// actual pitch roll and yaw (from inertial interface)
input [8:0] thrst;							// thrust level from slider
output [10:0] frnt_spd;						// 11-bit unsigned speed at which to run front motor
output [10:0] bck_spd;						// 11-bit unsigned speed at which to back front motor
output [10:0] lft_spd;						// 11-bit unsigned speed at which to left front motor
output [10:0] rght_spd;						// 11-bit unsigned speed at which to right front motor


  //////////////////////////////////////////////////////
  // You will need a bunch of interal wires declared //
  // for intermediate math results...do that here   //
  ///////////////////////////////////////////////////
  wire [9:0] ptch_pterm, roll_pterm, yaw_pterm;
  wire [11:0] ptch_dterm, roll_dterm, yaw_dterm;
  wire signed[12:0] SE_thrst, SE_ptch_p, SE_ptch_d, SE_yaw_p, SE_yaw_d, SE_roll_p, SE_roll_d;
  wire signed[12:0] frnt_sum, left_sum, right_sum, back_sum;
  wire [10:0] frnt_sat, left_sat, right_sat, back_sat;

  ///////////////////////////////////////////////////////////////
  // some Parameters to keep things more generic and flexible //
  /////////////////////////////////////////////////////////////
  localparam CAL_SPEED = 11'h290;		// speed to run motors at during inertial calibration
  localparam MIN_RUN_SPEED = 13'h2C0;	// minimum speed while running  
  localparam D_COEFF = 5'b00111;		// D coefficient in PID control = +7
  
  //////////////////////////////////////
  // Instantiate 3 copies of PD_math //
  ////////////////////////////////////
  PD_math iPTCH(
    .clk(clk),
    .rst_n(rst_n),
    .vld(vld),
    .desired(d_ptch),
    .actual(ptch),
    .pterm(ptch_pterm),
    .dterm(ptch_dterm)
  );

  PD_math iROLL(
    .clk(clk),
    .rst_n(rst_n),
    .vld(vld),
    .desired(d_roll),
    .actual(roll),
    .pterm(roll_pterm),
    .dterm(roll_dterm)
  );

  PD_math iYAW(
    .clk(clk),
    .rst_n(rst_n),
    .vld(vld),
    .desired(d_yaw),
    .actual(yaw),
    .pterm(yaw_pterm),
    .dterm(yaw_dterm)
  );
  
  // sign extend values (except thrust)
  assign SE_thrst = {4'h0, thrst};
  assign SE_ptch_p = {ptch_pterm[9], ptch_pterm[9], ptch_pterm[9], ptch_pterm};
  assign SE_ptch_d = {ptch_dterm[11], ptch_dterm};
  assign SE_yaw_p = {yaw_pterm[9], yaw_pterm[9], yaw_pterm[9], yaw_pterm};
  assign SE_yaw_d = {yaw_dterm[11], yaw_dterm};
  assign SE_roll_p = {roll_pterm[9], roll_pterm[9], roll_pterm[9], roll_pterm};
  assign SE_roll_d = {roll_dterm[11], roll_dterm};

  // Calculating front motor speed and saturation based on respective inertial values
  assign frnt_sum = SE_thrst + MIN_RUN_SPEED - SE_ptch_p - SE_ptch_d - SE_yaw_p - SE_yaw_d;
  assign frnt_sat = (|frnt_sum[12:11]) ? 11'hfff : frnt_sum[10:0];

  // Calculating left motor speed and saturation based on respective inertial values
  assign left_sum = SE_thrst + MIN_RUN_SPEED - SE_roll_p - SE_roll_d + SE_yaw_p + SE_yaw_d;
  assign left_sat = (|left_sum[12:11]) ? 11'hfff : left_sum[10:0];

  // Calculating right motor speed and saturation based on respective inertial values
  assign right_sum = SE_thrst + MIN_RUN_SPEED + SE_roll_p + SE_roll_d + SE_yaw_p + SE_yaw_d;
  assign right_sat = (|right_sum[12:11]) ? 11'hfff : right_sum[10:0];

  // Calculating back motor speed and saturation based on respective inertial values
  assign back_sum = SE_thrst + MIN_RUN_SPEED + SE_ptch_p + SE_ptch_d - SE_yaw_p - SE_yaw_d;
  assign back_sat = (|back_sum[12:11]) ? 11'hfff : back_sum[10:0];

  // Assign final motor speeds based on if we are calibrating or not
  assign frnt_spd = inertial_cal ? CAL_SPEED : frnt_sat;
  assign lft_spd = inertial_cal ? CAL_SPEED : left_sat;
  assign rght_spd = inertial_cal ? CAL_SPEED : right_sat;
  assign bck_spd = inertial_cal ? CAL_SPEED : back_sat;
  
endmodule 