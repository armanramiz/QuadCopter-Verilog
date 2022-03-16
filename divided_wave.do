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
add wave -noupdate -divider {Simulation Signals}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/airborne
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/calc_physics
add wave -noupdate -divider -height 75 {Physics Simulation}
add wave -noupdate -divider Position
add wave -noupdate -format Analog-Step -height 74 -max 1648.0 -radix decimal /QuadCopter_tb/iQuad/vert_p
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/ptch_p
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/roll_p
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/yaw_p
add wave -noupdate -divider Velocity
add wave -noupdate -format Analog-Step -height 74 -max 5764.0 -radix decimal /QuadCopter_tb/iQuad/vert_v
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/ptch_v
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/roll_v
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/yaw_v
add wave -noupdate -divider Acceleration
add wave -noupdate -format Analog-Step -height 74 -max 2432.0 -min -964.0 -radix decimal /QuadCopter_tb/iQuad/vert_a
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/ptch_a
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/roll_a
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iQuad/yaw_a
add wave -noupdate -divider -height 75 {End Physics Simulation}
add wave -noupdate -divider {Motor Speeds}
add wave -noupdate -format Analog-Step -height 74 -max 866.0 -radix hexadecimal /QuadCopter_tb/iQuad/spd_frnt
add wave -noupdate -format Analog-Step -height 74 -max 864.0 -radix hexadecimal /QuadCopter_tb/iQuad/spd_back
add wave -noupdate -format Analog-Step -height 74 -max 866.0 -radix hexadecimal /QuadCopter_tb/iQuad/spd_left
add wave -noupdate -format Analog-Step -height 74 -max 864.0 -radix hexadecimal /QuadCopter_tb/iQuad/spd_rght
add wave -noupdate -divider {Motor Thrusts}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_frnt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_back
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_rght
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/thrst_left
add wave -noupdate -divider -height 30 inert_intf
add wave -noupdate -divider Data
add wave -noupdate -format Analog-Step -height 74 -max 1.0 -min -1.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/ptch
add wave -noupdate -format Analog-Step -height 74 -max 1.0 -min -1.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/roll
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/yaw
add wave -noupdate -format Analog-Step -height 74 -max 255.0 -min -45.0 -radix decimal -radixshowbase 0 /QuadCopter_tb/iDUT/iNEMO/ax
add wave -noupdate -format Analog-Step -height 74 -max 45.0 -radix decimal /QuadCopter_tb/iDUT/iNEMO/ay
add wave -noupdate -divider Signals
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iNEMO/strt_cal
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iNEMO/cal_done
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iNEMO/vld
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iNEMO/command
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iNEMO/inertial_data
add wave -noupdate -divider -height 30 {NEMO Data}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/SS_n
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/SCLK
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/MOSI
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/MISO
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/INT
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/iNEMO/AX
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/iNEMO/AY
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/iNEMO/PTCH
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/iNEMO/ROLL
add wave -noupdate -radix decimal /QuadCopter_tb/iQuad/iNEMO/YAW
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/state
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/nstate
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/shft_reg_tx
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/shft_reg_rx
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/bit_cnt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/write_reg
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/POR_n
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/internal_clk
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/update_period
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/clr_INT
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/ld_tx_reg
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/shft_tx
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/init
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/set_write
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/clr_write
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/tx_data
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iQuad/iNEMO/NEMO_setup
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
add wave -noupdate -divider -height 30 DUT
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/cmd_rdy
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/cmd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/data
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/clr_cmd_rdy
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/resp
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/send_resp
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/resp_sent
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/vld
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ptch
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/roll
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/yaw
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/d_ptch
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/d_roll
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/d_yaw
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/thrst
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/rst_n
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/strt_cal
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/inertial_cal
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/motors_off
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/cal_done
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/frnt_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/bck_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/lft_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/rght_spd
add wave -noupdate -divider -height 30 {ESC Block}
add wave -noupdate /QuadCopter_tb/clk_cnt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/wrt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/motors_off
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/frnt_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/bck_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/lft_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/rght_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/frnt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/bck
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/lft
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/rght
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/frnt_in
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/bck_in
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/lft_in
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/rght_in
add wave -noupdate -divider -height 30 {Front ESC}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/wrt
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/SPEED
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/PWM
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/mult_result
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/setting
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/Rst
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/Set
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/count_reg
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/iESC/front_ESC/WRITE
add wave -noupdate -divider -height 30 {Flight Control}
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/vld
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/inertial_cal
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/d_ptch
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/d_roll
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/d_yaw
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/ptch
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/roll
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/yaw
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/thrst
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/frnt_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/bck_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/lft_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/rght_spd
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/ptch_pterm
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/roll_pterm
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/yaw_pterm
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/ptch_dterm
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/roll_dterm
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/yaw_dterm
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/frnt_sum
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/bck_sum
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/lft_sum
add wave -noupdate -radix hexadecimal /QuadCopter_tb/iDUT/ifly/rght_sum
add wave -noupdate -divider Pitch
add wave -noupdate -radix binary /QuadCopter_tb/iDUT/ifly/iPTCH/vld
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/desired
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/actual
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/pterm
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/dterm
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/err
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/D_diff
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/err_sat
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iPTCH/diff_sat
add wave -noupdate -radix decimal -childformat {{{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[0]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[1]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[2]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[3]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[4]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[5]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[6]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[7]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[8]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[9]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[10]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[11]} -radix decimal}} -expand -subitemconfig {{/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[0]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[1]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[2]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[3]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[4]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[5]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[6]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[7]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[8]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[9]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[10]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iPTCH/d_queue[11]} {-radix decimal}} /QuadCopter_tb/iDUT/ifly/iPTCH/d_queue
add wave -noupdate -divider Roll
add wave -noupdate -radix binary /QuadCopter_tb/iDUT/ifly/iROLL/vld
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/desired
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/actual
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/pterm
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/dterm
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/err
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/D_diff
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/err_sat
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iROLL/diff_sat
add wave -noupdate -radix decimal -childformat {{{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[0]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[1]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[2]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[3]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[4]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[5]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[6]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[7]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[8]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[9]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[10]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[11]} -radix decimal}} -expand -subitemconfig {{/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[0]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[1]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[2]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[3]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[4]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[5]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[6]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[7]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[8]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[9]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[10]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iROLL/d_queue[11]} {-radix decimal}} /QuadCopter_tb/iDUT/ifly/iROLL/d_queue
add wave -noupdate -divider Yaw
add wave -noupdate -radix binary /QuadCopter_tb/iDUT/ifly/iYAW/vld
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/desired
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/actual
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/pterm
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/dterm
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/err
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/D_diff
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/err_sat
add wave -noupdate /QuadCopter_tb/iDUT/ifly/iYAW/diff_sat
add wave -noupdate -radix decimal -childformat {{{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[0]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[1]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[2]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[3]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[4]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[5]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[6]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[7]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[8]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[9]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[10]} -radix decimal} {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[11]} -radix decimal}} -expand -subitemconfig {{/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[0]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[1]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[2]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[3]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[4]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[5]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[6]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[7]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[8]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[9]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[10]} {-radix decimal} {/QuadCopter_tb/iDUT/ifly/iYAW/d_queue[11]} {-radix decimal}} /QuadCopter_tb/iDUT/ifly/iYAW/d_queue
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43321950 ps} 0}
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
WaveRestoreZoom {0 ps} {152319542 ps}
