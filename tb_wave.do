onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 30 {Test Bench Waves}
add wave -noupdate -divider {clk & rst_n}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/clk
add wave -noupdate -radix decimal /QuadCopter_tb/clk_cnt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/RST_n
add wave -noupdate -divider Command
add wave -noupdate -radix hexadecimal /QuadCopter_tb/host_cmd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/host_data
add wave -noupdate -radix hexadecimal /QuadCopter_tb/send_cmd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/cmd_sent
add wave -noupdate -divider Response
add wave -noupdate -radix hexadecimal /QuadCopter_tb/resp
add wave -noupdate -radix hexadecimal /QuadCopter_tb/resp_rdy
add wave -noupdate -radix hexadecimal /QuadCopter_tb/clr_resp_rdy
add wave -noupdate -divider -height 75 {Expected vs. Actual}
add wave -noupdate -divider Pitch
add wave -noupdate -format Analog-Step -height 74 -max 160.0 -radix decimal /QuadCopter_tb/iDUT/iCMD/d_ptch
add wave -noupdate -format Analog-Step -height 74 -max 64.0 -min -1.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/ptch
add wave -noupdate -divider Roll
add wave -noupdate -format Analog-Step -height 74 -max 160.0 -radix decimal /QuadCopter_tb/iDUT/iCMD/d_roll
add wave -noupdate -format Analog-Step -height 74 -max 49.0 -min -1.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/roll
add wave -noupdate -divider Yaw
add wave -noupdate -format Analog-Step -height 74 -max 160.0 -radix decimal /QuadCopter_tb/iDUT/iCMD/d_yaw
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/yaw
add wave -noupdate -divider -height 30 ESC
add wave -noupdate -divider Front
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_FRNT/PWM
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_FRNT/SPEED
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_FRNT/cnt
add wave -noupdate -divider Back
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_BACK/PWM
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_BACK/SPEED
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_BACK/cnt
add wave -noupdate -divider Left
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_LEFT/PWM
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_LEFT/SPEED
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_LEFT/cnt
add wave -noupdate -divider Right
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_RGHT/PWM
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_RGHT/SPEED
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iINV_RGHT/cnt
add wave -noupdate -divider -height 75 {Physics Simulation}
add wave -noupdate -divider {Simulation Signals}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/airborne
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/calc_physics
add wave -noupdate -divider Position
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/vert_p
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/ptch_p
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/roll_p
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/yaw_p
add wave -noupdate -divider Velocity
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/vert_v
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/ptch_v
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/roll_v
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/yaw_v
add wave -noupdate -divider Acceleration
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/vert_a
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/ptch_a
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/roll_a
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/yaw_a
add wave -noupdate -divider {End Physics Simulation}
add wave -noupdate -divider {Motor Speeds}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/spd_frnt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/spd_back
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/spd_left
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/spd_rght
add wave -noupdate -divider {Motor Thrusts}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_frnt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_back
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_rght
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_left
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {63638150 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 269
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {160787246 ps}
