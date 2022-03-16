
//`timescale 1ns/1ps
module SPI_mnrch_1 (
	clk,
	rst_n,
	SS_n,
	SCLK,
	MOSI,
	MISO,
	spi_write_en,
	spi_done,
	rd_data,
	wt_data
);

input clk, rst_n;
input spi_write_en; //Start of a transaction
input [15:0] wt_data;
input MISO; // sampled in fall edge

output MOSI;// sampled on posedge of SCLK, 2sys clocks after
output SCLK;// 1/16th of our 50mhz clock. Generate this from a 4-bit counter(everything is still edge triggered on actual clk)
output logic SS_n;
output logic spi_done;//Generate spi_done when entire spi transaction is done. Whatever data we get from the perip will be available in read data
output [15:0] rd_data; // the data that gets returned from the peripheral. 


logic[3:0] SCLK_div;//counter for SCLk
logic [4:0] bit_cnt; //keep track of how many times we shifted. 16 times, so 5 bits
logic [15:0] shft_reg; 
logic [4:0] done16; // indicates that we have succesfully filled the shift reg with rd_data = MISO
logic init, shft, set_done, id_SCLK, high; // SM control signals to indicate what operation to perform


//SM STATES
typedef enum logic [1:0] {IDLE, SHIFTING, BACK_PORCH} state_t;
state_t state, next_state;


//CONTINOUS ASSIGNMENTS
assign done16 = (bit_cnt == 5'h10) ? 1:0; // Have we shifted 16 times?
assign rd_data= shft_reg; // this will be sent out upon spi_done signal asserted from the state machine (16 shifts have happened)
assign SCLK = SCLK_div[3]; // sclk is the MSB of our sclk_div ( which is the clk/16)
assign MOSI= shft_reg[15];



//SCLK DIVIDER
//Only counts during SPI transactions, otherwise load 4'b1011 TO KEEP THE LINE HIGH
//SCLK_div is my 1/16 clk cycle counter. SCLK it self is held high for 8clk cycles, low for the other 8 by this method. Remember SCLK = MSB OF SCLK_DIV
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		SCLK_div <= 4'b1011;

	 else if(id_SCLK)// means SPI transaction is happening;
		SCLK_div <= 4'b1011;//accomodates for the back porch delay
	else
		SCLK_div <= SCLK_div + 1;
	end

	
//BIT counter
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		bit_cnt <= 5'b0;
	else if(init)
		bit_cnt <= 5'b0;
	else if (shft)
		bit_cnt <= bit_cnt + 1;
	end


//SHIFT REGISTER
//When sclk equals to 4'b1001, enable the shift register to force a sample of MISO into LSB of shift register at two system clocks after SCLK rise
always@(posedge clk, negedge rst_n) begin

	if(!rst_n)
		shft_reg <= 16'h0;
	else if(init)
		shft_reg <= wt_data;
	else if (shft)// will enable this when SCLK_div equals to 4'b1001?
		shft_reg <= {shft_reg[14:0], MISO};
	end

//DONE LOGIC
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		spi_done <=0;
	else if(init)// also means clr
		spi_done<=0;
	else if (set_done)
		spi_done <=1;
end


//State transitions to be used within the SM
always@(posedge clk, negedge rst_n) begin 
	if(!rst_n)
		state <= IDLE;
	else
		state <=next_state;
end


//logic for the behaviour of the Surf Select
//I origianlly simply handled the assertion and deassertion of SSn inside the SM
//But that didnt work out nicely, as we want to keep SSn high by default
logic SSn_drop, SSn_high;
always@(posedge clk, negedge rst_n) begin 
	if(!rst_n)
		SS_n <= 1;
	else if(SSn_drop)
		SS_n <= 0;
	else if(SSn_high)
		SS_n <= 1;
end

//SM
always_comb begin//We are intending a combinational logic within our SM
	//Deassert the control signals, avoid unintentional latches.
	init= 0;
	shft = 0;
	SSn_drop = 0;
	SSn_high = 0;
	//SS_n= 1;// like chip select, keep it high by default, THIS DID NOT WORK... (understandably)
	set_done = 0;

	id_SCLK=0;// indicates new assertion of SCLK, keept it high by default
	next_state = state; // Wont need an else to the ifs to indicate next state

	case(state)
		IDLE: if(spi_write_en) begin
			SSn_drop = 1; //drop surf select
			init = 1; //as soon as we get spi_write_en, we assert init to clear spi_done and the shift regs
			id_SCLK =1;// FRONT PORCH
			next_state = SHIFTING;
			end

		SHIFTING: if(done16) begin //when bit count is 16, we are spi_done
				id_SCLK = 1;
			 	next_state = BACK_PORCH; //Transmission is complete, SCLK is set to default high, now accomodate the back porch delay
			  end

		
			// MOSI is shifted 2SYS CLKS after SCLK RISE,
			// MISO IS SAMPLED AT THE SAME TIME. MISO IS REFLECTED ON SCLK FALL
			else if(SCLK_div == 4'b1001)
			  	shft = 1; 

			else	//initate SCLK clocks HERE!!!!!!!!!
				id_SCLK =0;
					   
		//SCLK is low, assert Surf Select after 2 clk cycles
		BACK_PORCH: if(SCLK_div ==4'b1101) begin// 2system clocks after SCLK was our last shift, we need to generate a back porch, the amount of time we wait untill rise of surf select.
				SSn_drop = 0;
				SSn_high = 1;// Put SURF SELECT to default high
				set_done = 1;// we are spi_done transreceiving
				id_SCLK = 1; // put the line back to high again, and this time keep it that way untill new transmission is started with a new spi_write_en assertion
				next_state = IDLE; // go back to IDLE state to await next process

			end 	//START COUNTING SCLK_DIV AGAIN FOR THE BACK PORCH, BUT WITHOUT CREATING A SCLK FALL
				else id_SCLK = 0;//allows for countin
		//No latches here	
		default: next_state = IDLE;
		endcase
	end
endmodule



