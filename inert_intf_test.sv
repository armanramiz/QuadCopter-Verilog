module inert_intf_test(
    clk, RST_n, NEXT, LED,

    // SPI stuff
    SS_n, SCLK, MOSI, MISO, INT
);

input clk, RST_n, NEXT;
input [7:0] LED;

// SPI
input MISO, INT;
output SS_n, SCLK, MOSI;

logic strt_cal, cal_done, stat, rst_n, btn_released, vld;
logic [1:0] sel;
logic [15:0] ptch, roll, yaw;

// state defs
typedef enum reg [2:0] {
    IDLE,
    CAL,
    PTCH,
    ROLL,
    YAW
} state_t;

state_t state, next_state;

// instantiate modules
reset_synch iRST_SYNCH(
    .RST_n(RST_n),
    .clk(clk),
    .rst_n(rst_n)
);

PB_release iRELEASE(
    .PB(NEXT),
    .clk(clk),
    .rst_n(rst_n),
    .released(btn_released)
);

inert_intf iINERT_INTF(
    .clk(clk), 
    .rst_n(rst_n), 
    .strt_cal(strt_cal), 
    .INT(INT), 
    .SS_n(SS_n), 
    .SCLK(SCLK), 
    .MOSI(MOSI), 
    .MISO(MISO), 
    .vld(vld), 
    .cal_done(cal_done), 
    .ptch(ptch), 
    .roll(roll), 
    .yaw(yaw)
);

// LED mux
assign LED =
    sel == 2'b00 ? {7'h0, stat} :
    sel == 2'b01 ? ptch[8:1] :
    sel == 2'b10 ? roll[8:1] :
    yaw[8:1];

// state update
always @(posedge btn_released, negedge rst_n) begin
    
    if(!rst_n)
        state <= IDLE;
    else 
        state <= next_state;

end

// state machine logic
always_comb begin
    
    // defaults
    next_state = IDLE;
    strt_cal = 0;
    cal_done = 0;
    stat = 0;
    sel = 2'b00;

    case(state)

        IDLE: begin
            
            next_state = CAL;
            strt_cal = 1;

        end

        CAL: begin

            stat = 1;
            sel = 2'b00;
            
            if(cal_done)
                next_state = PTCH;
            else
                next_state = CAL;

        end

        PTCH: begin
            
            sel = 2'b01;

            next_state = ROLL;

        end

        ROLL: begin
            
            sel = 2'b10;

            next_state = YAW;

        end

        YAW: begin
            
            sel = 2'b11;

            next_state = PTCH;

        end

    endcase

end

endmodule