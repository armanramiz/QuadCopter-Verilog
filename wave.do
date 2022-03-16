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
add wave -noupdate -format Analog-Step -height 74 -max 36.999999999999993 -min -156.0 -radix decimal /QuadCopter_tb/iDUT/iCMD/d_ptch
add wave -noupdate -format Analog-Step -height 74 -max 54.0 -min -156.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/ptch
add wave -noupdate -divider Roll
add wave -noupdate -format Analog-Step -height 74 -max 14.000000000000027 -min -237.0 -radix decimal /QuadCopter_tb/iDUT/iCMD/d_roll
add wave -noupdate -format Analog-Step -height 74 -max 123.99999999999997 -min -236.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/roll
add wave -noupdate -divider Yaw
add wave -noupdate -format Analog-Step -height 74 -max 142.0 -min -246.0 -radix decimal /QuadCopter_tb/iDUT/iCMD/d_yaw
add wave -noupdate -format Analog-Step -height 74 -max 142.0 -min -245.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/yaw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {783117011 ps} 0}
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
WaveRestoreZoom {0 ps} {829265819 ps}
