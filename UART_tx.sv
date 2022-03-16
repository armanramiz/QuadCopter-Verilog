
//Author: Arman Ramiz
//UART transmitter, to be connected to a UART receiver of same baud rate.
//2604 baud rate


module UART_tx(clk, rst_n,TX, trmt, tx_data, tx_done);

input clk, rst_n; //50MHz System Clock and Active Low Reset

input trmt; //Asserted for 1 clock cycle. Means get going and start transmitting

input  [7:0] tx_data; // Byte to transmit

output logic tx_done; //Asserted when byte is done transmitting. Stays High till next byte is transmitted

output logic TX; //serial data output. LSB first

logic set_done;// will allow us to set tx done in the "done" flop when we have succesfully transmittied our data (byte)

logic init, shift, transmitting; // SM control signals to indicate what operation to perform

logic [11:0] baud_cnt;//when this is full (2604) shift the reg to right, transmit next LSB

logic [3:0] bit_cnt; //keep track of how many times we shifted. (10 times in this case (8bit data, 1 stop, 1 start

logic [8:0] tx_shft_reg; // Shift register to transmit the data. 9 bit shift register to accomodate the stop/ start bits

logic bit_cnt_full; // indicates that we have succesfully trasnmitted a byte of data

//Went and did this completely off from the exercise video, very helpful one indeed

typedef enum logic [1:0] {IDLE, DONE} state_t;// FSM
state_t state, next_state;


//assign TX = shiftreg[0];
//Going to need 4 always blocks and one always_comb block for state machine,
// I will use 2 states for the FSM
assign bit_cnt_full = (bit_cnt == 4'b1010) ? 1:0; // is the bit count full i.e 10?
assign shift = (baud_cnt ==2604) ? 1:0;// shift when baud is full

assign TX= tx_shft_reg[0]; //LSB of our transmit reg, initially it will get 0, indicates start!, will one by one store the data indicating each LSB


always@(posedge clk, negedge rst_n) begin  //the first shifter (topology) in our pdf. Will process a byte to shift (transmit)
	if(!rst_n)
		tx_shft_reg <= 9'h1FF; //Preset to all 1's. Idle state of a uart is high.
	else if (init) //upon receiving trmt signal, we init
		tx_shft_reg <=  {tx_data, 1'b0}; // if init, begin shifting from the start bit(0) TX gets 0 indicating start (tx line low)
	else if(shift)
		tx_shft_reg <= {1'b1, tx_shft_reg[8:1]}; // right shifted value. LSB first. We will end with 1 to indicate stop bit
		
end


always@(posedge clk, negedge rst_n) begin  //Second topology in our pdf, baud counter to 2064. Basically sampling each bit. Our clock is 50Mhz
	if(!rst_n)
		baud_cnt <= 0; //set baud counter to 0 on reset
	else if(init || shift)
		baud_cnt <= 0; //set baud counter to 0 on either receiving init or each time we shift to process the next bit( each bit will be sampled 2604 times)
	else if (transmitting) // increment baud caunt untill 2604 if we are transmiting
		baud_cnt <= baud_cnt +1;

end

always@(posedge clk, negedge rst_n) begin // third topology in our pdf, Baud counter indicates shifting to a new bit to transmit ( shift right, LSB gets transmitted first)
	if(!rst_n)
		bit_cnt <= 0; //set bit counter to 0 on reset
	else if( init)
		bit_cnt <= 0;//set bit counter to 0 when init ( new byte is about to be transmitted)
	else if(shift)
		bit_cnt <= bit_cnt +1; // increment bit counter when we shift to sample and process the next bit in our data (byte)
end


always@(posedge clk, negedge rst_n) begin // always block for the last part, done logic
	if(!rst_n)
		tx_done <=0;

	else if(init) // We are saying that a new byte is about to be transmited, so tx_done should be deasserted
		tx_done<=0;

	else if (set_done) // we have transmitted the byte succesfully. Set tx done flag
		tx_done <=1;
end


always@(posedge clk, negedge rst_n) begin //for state transitions within SM
	if(!rst_n)
		state <= IDLE;
	else
		state <=next_state;
end

//SM to control the UART 
always_comb begin//We are intending a combinational logic within our SM
	//Deassert the control signals, avoid unintentional latches.
	init= 0;
	transmitting = 0;
	set_done = 0;
	next_state = state; // Wont need an else to the ifs to indicate next state
	case(state)
		IDLE: if(trmt) begin
			init = 1; //as soon as we get trmt, we assert init. This will save power consumption (no free runing count)
			next_state = DONE;
			end
		DONE: if(bit_cnt_full) begin //when bit count is 10, we are done
			 set_done = 1; // set done and let receiver know we have done transmitting
			 next_state = IDLE; // go back to IDLE state to await transmission of the next byte
			end
		      else //if bit count isnt yet full (<10) continue transmiting the current bit. UNTILL baud count reaches 2604, in which case we shift to the next bit (lsb transmitted)
				transmitting =1; // go on to count bauds... remember 2604 sample rate takes a lot of clock cycles!
		     default: // Avoid unintentional latches
			next_state = IDLE;
		endcase
	end
endmodule

	




