
//Author: Arman Ramiz
//UART is asyncronus, so we use a baud rate to make sure our transmission and receiving are in synch with each other

module UART_rcv(clk, rst_n, RX, rdy, rx_data, clr_rdy);

input clk, rst_n;// 50MHz system clock and Active Low Reset

input logic RX; //Serial data input. We are shifting in RX. Its asynch. So double flop before ever using it. RX gets TX

input clr_rdy; //Knocks down rdy when asserted. (Wil be used alongside init) indicate byte received was used up.

output  [7:0] rx_data;// byte of data received from the Transmitter

output logic rdy; //Asserted when byte is received. Stays high till start bit of next byte starts(init), or until clr_rdy is asserted. 

logic set_rdy;//will indicate rdy from the fsm. We are ready to process the byte

logic init, shift, receiving; // these are the control signals, used in State machine

logic [11:0] baud_cnt;//when this is full (2604) shift the reg to right, receive next LSB (TX)

logic [3:0] bit_cnt; //keep track of how many times we shifted. (10 times in this case (8bit data, 1 stop, 1 start

logic [8:0] rx_shft_reg; // 9 bit receive shift register. RX gets MSB from TX.

logic rx1, rx2; //these will be used when we double flop our rx signal. (CAUSE ITS ASYNCRONUS)
// rx2 will be used as if its RX
wire bit_cnt_full;
	
typedef enum logic [1:0] {IDLE, RECEIVED} state_t;// SM
state_t state, next_state;

assign bit_cnt_full = (bit_cnt == 4'b1010) ? 1:0; // Is the bit count full i.e 10? then we are rdy and we have received!
assign shift = (baud_cnt ==0) ? 1:0;// shift when baud_cnt had counted down to 0
assign rx_data= rx_shft_reg[7:0]; //What we have received. Will check this against our tx_data 


//RX is comming in (from the TX) MSB first. It wil contain the stop bit at first (1303 baud rate)
//
always@(posedge clk, negedge rst_n) begin// Double flop the asyncronus RX input. Will preset to 1 (indicates IDLE line)
	if(!rst_n) begin
		//RX  <=1;
		rx1 <= 1;
		rx2 <=1;
		end
	else begin
	     rx1 <= RX;
	     rx2<=rx1;
	end
end
		

always@(posedge clk, negedge rst_n) begin  //the first shifter in our pdf. RX gets MSB. or rather TX (LSB) = RX (MSB)
	if(!rst_n)
		rx_shft_reg <= 9'h1FF; //Preset to all 1's. Idle state of a uart is high.
	else if (shift)
		//Applied the same logic from the Transmitter
		rx_shft_reg <=  {rx2, rx_shft_reg[8:1]}; // rx2 gets MSB, shift right by 1. LSB from the TX
end


//Baud counter will count down. This allow us to be able to use 2 states, instead of 3.
//shift when baud count reaches 0
always@(posedge clk, negedge rst_n) begin  //second topology (diagram) in our pdf. Baud counter. Preload with either half baud period or full baud period
	if(!rst_n)
		baud_cnt <= 1302; //set baud counter to 1302 on reset (half baud period) for the start bit
	else if(init)
		baud_cnt <=1302; //load half baud when init. Indicates new transmission incoming. Start bit
	else if(shift)
		baud_cnt <= 2604; //set baud counter to 2604 ach time we shift to process (receive) the next bit of data( each bit will be sampled 2604 times)

	else if (receiving) // decrement baud caunt while we are receving, for each sample of a bit (baud rate)
		baud_cnt <= baud_cnt -1;
end

//Bit counter which will count up to 10 (state machine will keep track of this)
//When bit count reaches 10 we assert rdy
always@(posedge clk, negedge rst_n) begin // third shifter in our pdf. Bit counter
	if(!rst_n)
		bit_cnt <= 0;
	else if( init)
		bit_cnt <= 0;//indicates new receiving. Clear bit cnt.
	else if(shift)
		bit_cnt <= bit_cnt +1; // increment bit counter when each time we shift for each bit of data we receive
end

//We are producing a rdy signal. It tells us we received a new byte of data
//We also have clear_rdy which indicates that byte was consumed, i.e used.
//init will set rdy to 0, but also clr_rdy will set it to 0.
always@(posedge clk, negedge rst_n) begin // always block for the last part
	if(!rst_n)
		rdy <=0;
	else if (clr_rdy || init)
		rdy <=0;
	else if (set_rdy)
		rdy <=1;
end


always@(posedge clk, negedge rst_n) begin //for state transitions within FSM
	if(!rst_n)
		state <= IDLE;
	else
		state <=next_state;
end

//SM to control the UART 
always_comb begin//comb always block for fsm. We dont intend any latches
	// initialize the control signals, dont want no latch
	init= 0;	
	receiving = 0;
	set_rdy = 0;
	next_state = state;
	
	case(state) //IDLE will monitor for the 2604 samples of the IDLE line to fall, i.e go low. (START from the start bit)
		IDLE: if(!rx2) begin //start bit has been received (its low)
			init = 1; //as soon as we get start bit, we assert init to clear our rdy signal. This will save power consumption (no free runing count)
			next_state = RECEIVED;
			end // wait in idle for start of new receiving process (fall of receive line indicates this)

		RECEIVED: if(bit_cnt_full) begin //when bit count is 10, we are done. Means we have shifted right 10 times
			  set_rdy = 1;//time to produce the rdy signal, let them know we have succesfully received the transmitted data.
			  next_state = IDLE; // wait in idle for the next receiveing.
			  end
		       else //if bit count isnt yet full (<10) continue receiving the current bit. UNTILL baud count reaches 2604, in which case we shift to the next bit (MSB received)
				receiving =1; // go on to count bauds... remember 2604 sample rate takes a lot of clock cycles!
			default://avoid unintentional latches
			next_state = IDLE;
		endcase
	end
endmodule


