// Backup SPI file... there were some issues in the other one when I was testing. We can look at it again later.
module SPI_mnrch(
	clk,
	rst_n,
	SS_n,
	SCLK,
	MOSI,
	MISO,
	spi_write_en,
	wt_data,
	spi_done,
	rd_data
);

input clk, rst_n, MISO, spi_write_en;
input [15:0] wt_data;

output SCLK, MOSI;
output logic SS_n, spi_done; 
output [15:0] rd_data;

// state defs
typedef enum logic [1:0] {
	IDLE,
	SHFTNG,
	BCK_PRCH
} state_t;

state_t state, next_state;

logic [3:0] SCLK_div;
logic [4:0] bit_cntr;
logic [15:0] shft_reg;
logic ld_SCLK, full, shft, init, set_done, done16;


// Continuous assignments for SPI and state machine signals
assign SCLK = SCLK_div[3];

assign shft = (SCLK_div == 4'b1010) ? 1'b1 : 1'b0;

assign full = &SCLK_div;

assign MOSI = shft_reg[15];

assign rd_data = shft_reg;

assign done16 = bit_cntr[4];


// update state
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end
		
// state machine logic
always_comb begin

	// default outputs
	ld_SCLK = 1;
	init = 0;
	set_done = 0;
	next_state = state;
	
	case(state)
        // Wait for 16 bits to shift before ending SPI transaction
		SHFTNG: begin 
			ld_SCLK = 0;
			if(done16) begin
				next_state = BCK_PRCH;
			end
		end

		BCK_PRCH: begin
			// Back porch so clock stops before chip select goes high
			ld_SCLK = 0;

			if(full) begin
				ld_SCLK = 1;
				set_done = 1;
				next_state = IDLE;
			end

		end


		default: begin
            // IDLE state, begin shifting on SPI transaction start
			if(spi_write_en) begin
				init = 1;
				next_state = SHFTNG;
			end

		end

	endcase

end

// Counts the number of bits currently shifted during SPI transaction
always_ff @(posedge clk) begin

	if(init)
		bit_cntr <= 5'b00000;
	else if(shft)
		bit_cntr <= bit_cntr + 1;
end

// Clock divider for SPI clock, enables back porch
always_ff @(posedge clk) begin

	if(ld_SCLK)
		SCLK_div <= 4'b1011;
	else
		SCLK_div <= SCLK_div + 1;
end

// Shift register, always shifts in MISO during transaction
always_ff @(posedge clk) begin

	if(init)
		shft_reg <= wt_data;
	else if(shft)
		shft_reg <= {shft_reg[14:0], MISO};
end

// Chip select flop
always_ff @(posedge clk) begin

	if(!rst_n)
		SS_n <= 1;
	else if(set_done)
		SS_n <= 1;
	else if(init)
		SS_n <= 0;
end

// Flop output to tell device we're done with transaction
always_ff @(posedge clk, negedge rst_n) begin

	if(!rst_n)
		spi_done <= 0;
	else if(init)
		spi_done <= 0;
	else if(set_done)
		spi_done <= 1;
end
	
endmodule