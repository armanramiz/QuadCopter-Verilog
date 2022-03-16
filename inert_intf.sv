module inert_intf (
	clk,
	rst_n,
	ptch,
	roll,
	yaw,
	strt_cal,
	cal_done,
	vld,
	SS_n,
	SCLK,
	MOSI,
	MISO,
	INT
);

// flag for speeding up the sim
parameter FAST_SIM = 0;
 
input clk, rst_n;
input MISO;
input INT;
input strt_cal;
  
output signed [15:0] ptch, roll, yaw;
output cal_done;
output reg vld;
output SS_n, SCLK, MOSI;
  
reg INT1, INT2;
reg [15:0] counter_reg;
reg [15:0] ptch_reg, roll_reg, yaw_reg, ax_reg, ay_reg;

logic spi_write_en;
logic [15:0] command, inertial_data;

// internal flags
logic ptch_h, ptch_l;
logic roll_h, roll_l;
logic yaw_h, yaw_l;
logic ax_h, ax_l;
logic ay_h, ay_l;
logic spi_done;

// for inertial integrator
wire signed [15:0] ptch_rt, roll_rt, yaw_rt;
wire signed [15:0] ax, ay;

// define states
typedef enum reg[4:0] {
	STARTUP,
	INIT1,
	INIT2,
	INIT3,
	INIT4,
	WAIT,
	ptchL,
	ptchH,
	rollL,
	rollH,
	yawL,
	yawH,
	AXL,
	AXH,
	AYL,
	AYH,
	VALID
} state_t;

state_t state, nxt_state;


	
// INT double flop for metastability
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		INT1 <= 1'b0;
		INT2 <= 1'b0;
	end else begin
		INT1 <= INT;
		INT2 <= INT1;
	end

end

// 16-bit counter
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n) begin
		counter_reg <= 16'h0000;
	end else begin
		counter_reg <= counter_reg + 1;
	end

end


// ptch register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n)
		ptch_reg <= 16'h00;
	else if (ptch_h)
		ptch_reg[15:8] <= inertial_data[7:0];
	else if (ptch_l)
		ptch_reg[7:0] <= inertial_data[7:0];

end



// roll register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n)
		roll_reg <= 16'h00;
	else if (roll_h)
		roll_reg[15:8] <= inertial_data[7:0];
	else if (roll_l)
		roll_reg[7:0] <= inertial_data[7:0];

end



// yaw register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n)
		yaw_reg <= 16'h00;
	else if (yaw_h)
		yaw_reg[15:8] <= inertial_data[7:0];
	else if (yaw_l)
		yaw_reg[7:0] <= inertial_data[7:0];

end



// ax register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n)
		ax_reg <= 16'h00;
	else if (ax_h)
		ax_reg[15:8] <= inertial_data[7:0];
	else if (ax_l)
		ax_reg[7:0] <= inertial_data[7:0];

end



// ay register
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n)
		ay_reg <= 16'h00;
	else if (ay_h)
		ay_reg[15:8] <= inertial_data[7:0];
	else if (ay_l)
		ay_reg[7:0] <= inertial_data[7:0];

end



// state change flop
always_ff @(posedge clk, negedge rst_n) begin

	if (!rst_n)
		state <= STARTUP;
	else
		state <= nxt_state;

end

// SM logic
always_comb begin

	// defaults
	command = 16'h0000;
	spi_write_en = 1'b0;
	vld = 1'b0;
	ax_h = 1'b0;
	ax_l = 1'b0;
	ay_h = 1'b0;
	ay_l = 1'b0;
	ptch_h = 1'b0;
	ptch_l = 1'b0;
	roll_h = 1'b0;
	roll_l = 1'b0;
	yaw_h = 1'b0;
	yaw_l = 1'b0;
	nxt_state = state;
	
	case (state)

		STARTUP: begin // wait for NEMO sensor to be ready

			command = 16'h0d02; // enable interrupt
			
			if (&counter_reg) begin
				spi_write_en = 1'b1;
				nxt_state = INIT1;
			end

		end

		INIT1: begin

			command = 16'h1062; // setup accel range

			if (spi_done) begin
				spi_write_en = 1'b1;
				nxt_state = INIT2;
			end

		end

		INIT2: begin

			command = 16'h1162; // setup gyro range
			
			if (spi_done) begin
				spi_write_en = 1'b1;
				nxt_state = INIT3;
			end

		end

		INIT3: begin

			command = 16'h1460; // turn on rounding
			
			if (spi_done) begin
				spi_write_en = 1'b1;
				nxt_state = INIT4;
			end

		end

		INIT4: begin

			if (spi_done) begin
				nxt_state = WAIT;
			end

		end

		WAIT: begin // wait for interrupt
			
			command = 16'hA200; // get pitch low

			if (INT2) begin
				spi_write_en = 1'b1;
				nxt_state = ptchL;
			end

		end

		ptchL: begin

			command = 16'hA300; // get pitch high

			if (spi_done) begin
				spi_write_en = 1'b1;
				ptch_l = 1'b1;
				nxt_state = ptchH;
			end

		end

		ptchH: begin

			command = 16'hA400; // get roll low

			if (spi_done) begin
				spi_write_en = 1'b1;
				ptch_h = 1'b1;
				nxt_state = rollL;
			end

		end

		rollL: begin

			command = 16'hA500; // get roll high

			if (spi_done) begin
				spi_write_en = 1'b1;
				roll_l = 1'b1;
				nxt_state = rollH;
			end

		end

		rollH: begin

			command = 16'hA600; // get yaw low

			if (spi_done) begin
				spi_write_en = 1'b1;
				roll_h = 1'b1;
				nxt_state = yawL;
			end

		end

		yawL: begin

			command = 16'hA700; // get yaw high

			if (spi_done) begin
				spi_write_en = 1'b1;
				yaw_l = 1'b1;
				nxt_state = yawH;
			end

		end

		yawH: begin

			command = 16'hA800; // get ax low
			
			if (spi_done) begin
				spi_write_en = 1'b1;
				yaw_h = 1'b1;
				nxt_state = AXL;
			end

		end

		AXL: begin

			command = 16'hA900; // get ax high

			if (spi_done) begin
				spi_write_en = 1'b1;
				ax_l = 1'b1;
				nxt_state = AXH;
			end

		end

		AXH: begin

			command = 16'hAA00; // get ay low

			if (spi_done) begin
				spi_write_en = 1'b1;
				ax_h = 1'b1;
				nxt_state = AYL;
			end

		end

		AYL: begin

			command = 16'hAB00; // get ay high

			if (spi_done) begin
				spi_write_en = 1'b1;
				ay_l = 1'b1;
				nxt_state = AYH;
			end

		end

		AYH: begin

			if (spi_done) begin
				ay_h = 1'b1;
				nxt_state = VALID;
			end

		end

		VALID: begin
			
			vld = 1'b1; // tell everyone we're ready
			nxt_state = WAIT; // go back and wait to do this all over

		end

		default: begin // default state go back to startup

			nxt_state = STARTUP;

		end

	endcase

end

assign ptch_rt = ptch_reg;
assign roll_rt = roll_reg;
assign yaw_rt = yaw_reg;
assign ax = ax_reg;
assign ay = ay_reg;

// Instantiate inertial integrator
inertial_integrator #(FAST_SIM) iII(
  	.clk(clk),
	.rst_n(rst_n),
	.strt_cal(strt_cal),
	.cal_done(cal_done),
    .vld(vld),
	.ptch_rt(ptch_rt),
	.roll_rt(roll_rt),
	.yaw_rt(yaw_rt),
	.ax(ax),
	.ay(ay),
	.ptch(ptch),
	.roll(roll),
	.yaw(yaw)
);

// Instantiate SPI monarch
SPI_mnrch iSPI_M(
	.clk(clk),
	.rst_n(rst_n),
	.SS_n(SS_n),
	.SCLK(SCLK),
	.MISO(MISO),
	.MOSI(MOSI),
    .spi_write_en(spi_write_en),
	.spi_done(spi_done),
	.rd_data(inertial_data),
	.wt_data(command)
);
  
endmodule
	  