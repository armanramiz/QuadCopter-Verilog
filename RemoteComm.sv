module RemoteComm(clk, rst_n, RX, TX, cmd, data, send_cmd, cmd_sent, resp_rdy, resp, clr_resp_rdy);

	input clk, rst_n;		// clock and active low reset
	input RX;				// serial data input
	input send_cmd;			// indicates to tranmit 24-bit command (cmd)
	input [7:0] cmd;		// 8-bit command to send
	input [15:0] data;		// 16-bit data that accompanies command
	input clr_resp_rdy;		// asserted in test bench to knock down resp_rdy

	output logic TX;				// serial data output
	output logic cmd_sent;		// indicates transmission of command complete
	output logic resp_rdy;		// indicates 8-bit response has been received
	output logic [7:0] resp;		// 8-bit response from DUT

	////////////////////////////////////////////////////
	// Declare any needed internal signals/registers //
	// below including state definitions            //
	/////////////////////////////////////////////////
	//SM signals 
	logic trmt; //assert trmt when we want to transmit
	logic [1:0] sel; // select signal for SM
	logic tx_done; //transmission of one byte is done when this is asserted
	logic frm_snt; // Assert this from SM after trasnmitting the data packet

	//logic send_data_byteHigh; //[15:8]
	//logic send_data_byteLow; //[7:0]
	
	//Signals to store the data
	logic [7:0]tx_data; // send this to the UART to transmit. 
	logic[7:0] highByte;
	logic[7:0] lowerByte;
	
	///////////////////////////////////////////////
	// Instantiate basic 8-bit UART transceiver //
	/////////////////////////////////////////////
	UART iUART(.clk(clk), .rst_n(rst_n), .RX(RX), .TX(TX), .tx_data(tx_data), .trmt(trmt),
			   .tx_done(tx_done), .rx_data(resp), .rx_rdy(resp_rdy), .clr_rx_rdy(clr_resp_rdy));
		   
	/////////////////////////////////
	// Implement RemoteComm Below //
	///////////////////////////////
	//cmd is the high byte, the other two we have to store in holding registers

	//THE CONJUGATE UNIT OF THE WRAPPER. MIMIC THE REMOTE CONTROL. IT will have 8 bit cmd 16 bit data that it wants to send, It will serialize it

	//We have 8 bit cmd and 16 bit data that we want to send through our UART. When those are applied, assert snd_cmd
	//After snd_cmd, it should immediately transmit the cmd[7:0] (no holding register for that) It will immediately be captured by the uart transmission
	// Need holding portion to capture rest of the cmd portion i.e data[15:0]. So the user of this whole remotecomm thing has to assert the cmd and the data they want to send
	//and then hit it with a snd_cmd =1, then that data could change
	
	//We would be immediatelly transmitting the high byte [23:16] of the cmd. but the other two should be stored in the holding registers
	
	//Once the first cmd is done being sent (trmt). The SM should select (sel) the first holding register and assert another trmt signal to the UART to send the second byte
	//Once the second byte is done sending, tx_done is asserted. It would select the last byte (low byte) and transmit that. Then tx_done is asserted again

	//We are storing our data's into tx_Data to send them to the uart


	//Register for the [15:8] data byte (middle byte of the cmd)
	always@(posedge clk, negedge rst_n) begin 
		if(!rst_n)
			highByte <= 0;
		else if (send_cmd)
			highByte <= data[15:8];
	end
	
	//Register for the [7:0] of the data byte (last byte of cmd)
	always@(posedge clk, negedge rst_n) begin 
		if(!rst_n)
			lowerByte <=0;
		else if (send_cmd)
			lowerByte <= data[7:0];
	end

	// indicates transmission of command complete.
	//frm_snt is asserted from the SM upon transmiting final byte of data
	always@(posedge clk, negedge rst_n) begin // always block for the last part
		if(!rst_n)
		cmd_sent <=0;
		else if (frm_snt)
		cmd_sent <=1;
	end

	//SELECT WHICH BYTE TO SEND (THE ORDER IS CMD -> HIGH BYTE -> LOWERBYTE
	assign tx_data = (sel == 2'b10) ? cmd : (sel == 2'b01) ? highByte :  lowerByte;

	typedef enum logic [1:0] {IDLE, HIGHBYTE, LOWBYTE, EXIT} state_t;// SM
		state_t state, next_state;

	always@(posedge clk, negedge rst_n) begin //for state transitions within FSM
	if(!rst_n)
		state <= IDLE;
	else
		state <=next_state;
	end

	//SM to control the Remote communicator. Bluetooth comm later??
	always_comb begin//comb always block for fsm. We dont intend any latches
	trmt=0;
	sel = 2'b10; //this will choose cmd
	frm_snt =0;
	next_state = state;
	
	case(state)
			//SEND THE CMD [23:16] IMMEDIATELY IF SEND_CMD IS ASSERTED
		IDLE:
			if(send_cmd) begin //User told us to start signal transmission
			trmt = 1; //Start with transmitting the cmd (opcode 8 bits)
			next_state = HIGHBYTE; //process the next byte
			end 
		
			//SEND THE NEXT BYTE [15:8] IF PREVIOUS TRANSMISSION HAS COMPLETED
		HIGHBYTE: 
			if(tx_done) begin 
			trmt = 1;
			sel = 2'b01;
			next_state = LOWBYTE;
 			end

			//SEND THE NEXT BYTE [7:0] IF PREVIOUS TRANSMISSION HAS COMPLETED
		LOWBYTE:
			if(tx_done) begin 
			trmt = 1;
			sel = 2'b00;
		 	next_state = EXIT;
			end 
				
		default: 	//THE FINAL BYTE FOR DATA [7:0] HAS BEEN TRANSMITTED
			if(tx_done) begin  //This is the EXIT stage
			frm_snt =1;//confirmation that all 3 bytes have been received ( UART asserts rdy)
			next_state = IDLE;
			end
		
		//default: next_state = IDLE;

		endcase
	end

endmodule	
