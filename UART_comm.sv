//Module to take 3 bytes over serial and package it up into a cmd byte and 16 bits of data
//Bytes are coming in from the uart. Hold on to the 2 bytes untill you receive the third byte

module UART_comm(clk, rst_n, RX, TX, resp, send_resp, resp_sent, cmd_rdy, cmd, data, clr_cmd_rdy);

	input clk, rst_n;		// clock and active low reset
	input RX;				// serial data input
	input send_resp;		// indicates to transmit 8-bit data (resp)
	input [7:0] resp;		// byte to transmit
	input clr_cmd_rdy;		// host asserts when command digested

	output TX;				// serial data output
	output resp_sent;		// indicates transmission of response complete
	output logic cmd_rdy;		// indicates 24-bit command has been received
	output logic [7:0] cmd;		// 8-bit opcode sent from host via BLE
	output logic [15:0] data;	// 16-bit parameter sent LSB first via BLE

	logic [7:0] rx_data;		// 8-bit data received from UART
	logic rx_rdy;			// indicates new 8-bit data ready from UART //indicates that first byte has come in from the uart
	//wire rx_rdy_posedge;	// output of posedge detector on rx_rdy used to transition SM
	
	logic clr_rx_rdy; // clear ready upon storing a byte
	////////////////////////////////////////////////////
	// declare any needed internal signals/registers //
	// below including any state definitions        //
	/////////////////////////////////////////////////

	///////////////////////////////////////////////
	// Instantiate basic 8-bit UART transceiver //
	/////////////////////////////////////////////
	UART iUART(
		.clk(clk),
		.rst_n(rst_n),
		.RX(RX),
		.TX(TX),
		.tx_data(resp),
		.trmt(send_resp),
		.tx_done(resp_sent),
		.rx_data(rx_data),
		.rx_rdy(rx_rdy),
		.clr_rx_rdy(clr_rx_rdy)
	);
		
	////////////////////////////////
	// Implement UART_comm below //
	//////////////////////////////
	//1st step
	//First byte comes in from RX, stored in rx_data. Rdy is asserted from the UART

	//State machine realizes thats the first byte of the cmd. the cmd byte itself.
	// So take the received byte and store it in a holding register (always block) for [23:16] (forms the command opcode)
	//Then state machine should assert clr_rdy and wait for the next byte to come in

	//When the next byte comes in,(rdy is asserted) say oh its the second byte, store that byte in the next holding register (always block)
	//Again assert clr_rd wait for the last byte to come in

	//Third byte is the low [7:0] data, doesnt require holding register (holding register is essentially in the uart itself)
	// After thirdy byte comes in, SM should assert cmd_rdy, ( need a set reset flop (always block)
	//clear cmd_rdy on either start of a new 24 bit packet coming in OR when clr_cmd_rdy is asserted from outside


	//Responses sent by the quadcopter is handled by the UART_tx
	//8 bit resp is applied from here, it goes to tx_data, then assert snd_response for one clock
	//
	
	//INDICATES WHAT STATE TO BE IN/ WHAT BYTE TO LOAD
	logic byte_one_cmd;
	logic byte_two_data;

	logic [7:0] data_high;
	
	//USED IN ASSERTING THE CMD RDY SIGNAL. FINAL STEP OF THIS MODULE
	logic set_cmd_rdy;
	logic clr_cmd_rdy_i;
	
	typedef enum logic [1:0] {IDLE, CMD, DATAUP} state_t;// SM
		state_t state, next_state;
	
	
	assign data = {data_high, rx_data}; // finally assigns the last byte received to our data packet. Forming the complete data


	//STORE CMD SIGNAL (OPCODE) untill all 
	always@(posedge clk, negedge rst_n) begin // always block to store the first byte (cmd
		if(!rst_n)
			cmd <=0;
		else if (byte_one_cmd)
			cmd <= rx_data;
	end
	
	//STORE DATA [15:8] 1ST BYTE OF THE DATA 
	always@(posedge clk, negedge rst_n) begin // always block to store the first byte (cmd
		if(!rst_n) 
			data_high <=0;
		else if (byte_two_data)
			data_high <= rx_data; // data gets 2nd byte of data
	end



	//We are producing a command rdy signal. It tells us we received the 3 byte packet
	//We also have clr_cmd_rdy which indicates that byte was consumed, i.e used.
	always@(posedge clk, negedge rst_n) begin // always block for the last part
		if(!rst_n)
			cmd_rdy <=0;
		else if (clr_cmd_rdy_i | clr_cmd_rdy)
			cmd_rdy <=0;
		else if (set_cmd_rdy)
			cmd_rdy <=1;
	end


	always@(posedge clk, negedge rst_n) begin //for state transitions within FSM
	if(!rst_n)
		state <= IDLE;
	else
		state <=next_state;
	end
	

	//SM to control the UARTcomm
	always_comb begin//comb always block for fsm. We dont intend any latches
	//Clear the done signals
	set_cmd_rdy = 0;
	clr_cmd_rdy_i= 0;
	clr_rx_rdy = 0;

	//INDICATES TRANSITIONS
	byte_one_cmd = 0;
	byte_two_data =0;

	next_state = state;
	
	case(state) 
			//RECEIVE THE FIRST BYTE: CMD
		IDLE: 
			if(rx_rdy) begin //confirmation that cmd byte is received ( UART asserts rdy)
			clr_cmd_rdy_i = 1; //assert clear, so we can receive the new data packet
			clr_rx_rdy = 1; //clear rdy 
			byte_one_cmd = 1;// load the first byte to CMD
			next_state = CMD; //insert the received byte to cmd
			end 
		
			//RECEIVE THE SECOND BYTE	
		CMD: 	
			if(rx_rdy) begin //confirmation that next byte (2nd) is received ( UART asserts rdy)
			  clr_rx_rdy = 1; 
			  byte_two_data =1; // store the data[15:8] in a reg untill we receive the last byte
			  next_state = DATAUP;
			  end
			
			//RECEIVE THE THIRD BYTE	

		DATAUP: //now when the assign statement executes, it will store the last byte on data[7:0]
			 if(rx_rdy) begin //This is the DATAUP stage
			  set_cmd_rdy = 1; //confirmation that all 3 bytes have been received ( UART asserts rdy
			  clr_rx_rdy = 1;
			  next_state = IDLE;
			  end
			  
			  default: next_state = IDLE;
			
		endcase
	end
endmodule
