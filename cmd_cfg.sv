module cmd_cfg (
    clk,
    rst_n,
    cmd_rdy,
    cmd,
    data,
    clr_cmd_rdy,
    resp,
    send_resp,
    d_ptch,
    d_roll,
    d_yaw,
    thrst,
    strt_cal,
    inertial_cal,
    cal_done,
    motors_off
);

input clk, rst_n, cmd_rdy, cal_done;
input[7:0] cmd;
input[15:0] data;
output reg clr_cmd_rdy, send_resp, strt_cal, inertial_cal, motors_off;
output reg[15:0] d_ptch, d_yaw, d_roll;
output reg[8:0] thrst;
output reg[7:0] resp;

logic wptch, wyaw, wroll, wthrst, clr_timer, timer_en, emergency;


parameter FAST_SIM = 0; // set to 1 during simulation
localparam TIMER_WIDTH = FAST_SIM ? 9 : 26;

// Parameters based on command hex values from specification
localparam POS_ACK = 8'hA5;
localparam SET_PTCH = 8'h2;
localparam SET_ROLL = 8'h3;
localparam SET_YAW = 8'h4;
localparam SET_THRST = 8'h5;
localparam CALIBRATE = 8'h6;
localparam EMER_LAND = 8'h7;
localparam MTRS_OFF = 8'h8;

reg [TIMER_WIDTH-1:0] timer_reg;
reg mtrs_off;
wire timer_full;
typedef enum reg [2:0] { IDLE, CAL } state_t;
state_t state, nxt_state;

always_ff @( posedge clk, negedge rst_n ) begin : state_ff // State flop
    if (!rst_n) state <= IDLE;
    else state <= nxt_state;
end

always_ff @( posedge clk, negedge rst_n ) begin : ptch_ff // Pitch output flop
    if (!rst_n) d_ptch <= 16'h0000;
    else if (emergency) d_ptch <= 16'h0000;
    else if (wptch) d_ptch <= data;
end

always_ff @( posedge clk, negedge rst_n ) begin : roll_ff // Roll output flop
    if (!rst_n) d_roll <= 16'h0000;
    else if (emergency) d_roll <= 16'h0000;
    else if (wroll) d_roll <= data;
end

always_ff @( posedge clk, negedge rst_n ) begin : yaw_ff // Yaw output flop
    if (!rst_n) d_yaw <= 16'h0000;
    else if (emergency) d_yaw <= 16'h0000;
    else if (wyaw) d_yaw <= data;
end

always_ff @( posedge clk, negedge rst_n ) begin : thrst_ff // Thrust output flop
    if (!rst_n) thrst <= 9'h000;
    else if (emergency) thrst <= 16'h0000;
    else if (wthrst) thrst <= data[8:0];
end

always_ff @( posedge clk, negedge rst_n ) begin : mtr_off_ff // Flop motors off output
    if (!rst_n) motors_off <= 1'b1;
    else if (mtrs_off) motors_off <= 1'b1;
    else if (inertial_cal) motors_off <= 1'b0;
end

always_comb begin : state_logic
    // Default state machine outputs
    inertial_cal = 1'b0;
    strt_cal = 1'b0;
    mtrs_off = 1'b0;
    wptch = 1'b0;
    wyaw = 1'b0;
    wroll = 1'b0;
    wthrst = 1'b0;
    clr_timer = 1'b0;
    timer_en = 1'b0;
    emergency = 1'b0;
    resp = 8'h0;
    send_resp = 1'b0;
    nxt_state = state;
    clr_cmd_rdy = 1'b0;

    case (state)

        IDLE: begin
            if(cmd_rdy) begin
                clr_cmd_rdy = 1'b1;

                case(cmd) // Process commands, enable respective registers. Should only leave IDLE on calibration

                    SET_PTCH: begin
                        wptch = 1'b1;
                        send_resp = 1'b1;
                        resp = POS_ACK;
                        nxt_state = IDLE;
                    end

                    SET_ROLL: begin
                        wroll = 1'b1;
                        send_resp = 1'b1;
                        resp = POS_ACK;
                        nxt_state = IDLE;
                    end

                    SET_YAW: begin
                        wyaw = 1'b1;
                        send_resp = 1'b1;
                        resp = POS_ACK;
                        nxt_state = IDLE;
                    end

                    SET_THRST: begin
                        wthrst = 1'b1;
                        send_resp = 1'b1;
                        resp = POS_ACK;
                        nxt_state = IDLE;
                    end

                    EMER_LAND: begin
                        emergency = 1'b1;
                        send_resp = 1'b1;
                        resp = POS_ACK;
                        nxt_state = IDLE;
                    end

                    MTRS_OFF: begin
                        mtrs_off = 1'b1;
                        send_resp = 1'b1;
                        resp = POS_ACK;
                        nxt_state = IDLE;
                    end

                    CALIBRATE: begin
                        nxt_state = CAL;
                        strt_cal = 1'b1;
                        timer_en = 1'b1;
                        clr_timer = 1'b1;
                    end

                endcase

            end

        end

        CAL: begin // Calibration state, wait for 1.34 second timer before checking for cal_done
            timer_en = 1'b1;
            strt_cal = 1'b0;
            clr_timer = 1'b0;
            inertial_cal = 1'b1;
            
            // check for timer full
            if(timer_full) begin

                timer_en = 1'b0;
                if (cal_done) begin
                    nxt_state = IDLE;
                    send_resp = 1'b1;
                    resp = POS_ACK;
                end

            end


        end

    endcase
    
end

// timer
always_ff @(posedge clk, negedge rst_n, posedge clr_timer) begin : timer_ff
    if(!rst_n) timer_reg <= 0;
    else if (clr_timer) timer_reg <= 0;
    else if(timer_en) timer_reg <= timer_reg + 1;
end

// Continuous assignments
assign timer_full = &timer_reg;

endmodule