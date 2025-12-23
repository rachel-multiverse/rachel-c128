; =============================================================================
; RACHEL - COMMODORE 128 MAIN MODULE
; Entry point and main loop (ca65 syntax)
; =============================================================================

        .segment "CODE"
        .org $1C01

; BASIC stub: 10 SYS 7181
        .word   link
        .word   10
        .byte   $9E
        .byte   "7181", 0
link:   .word   0

start:
        jsr     init_system
        jsr     display_init
        jsr     display_title

        ; Get server address
        jsr     input_ip_address

        ; Connect to server
        jsr     do_connect
        bcc     conn_ok
        jmp     conn_failed
conn_ok:
        ; Initialize RUBP
        jsr     rubp_init

        ; Send join request
        jsr     send_join

        ; Wait for game to start
        jsr     wait_for_game

; Main game loop
main_loop:
        jsr     net_recv
        bcs     ml_no_msg

        jsr     rubp_validate
        bcs     ml_no_msg

        lda     rx_buffer+6
        cmp     #MSG_GAME_STATE
        bne     ml_check_end

        jsr     process_game_state
        jsr     render_game
        jmp     ml_input

ml_check_end:
        cmp     #MSG_GAME_END
        bne     ml_no_msg
        jmp     game_over

ml_no_msg:
ml_input:
        lda     CURRENT_TURN
        cmp     MY_INDEX
        bne     main_loop

        jsr     get_input
        cmp     #KEY_QUIT
        beq     quit_game
        cmp     #KEY_LEFT
        beq     ml_left
        cmp     #KEY_RIGHT
        beq     ml_right
        cmp     #KEY_SELECT
        beq     ml_select
        cmp     #KEY_PLAY
        bne     ml_chk_draw
        jmp     ml_play
ml_chk_draw:
        cmp     #KEY_DRAW
        bne     ml_to_loop
        jmp     ml_draw
ml_to_loop:
        jmp     main_loop

ml_left:
        jsr     cursor_left
        jsr     render_hand
        jmp     main_loop

ml_right:
        jsr     cursor_right
        jsr     render_hand
        jmp     main_loop

ml_select:
        jsr     toggle_select
        jsr     render_hand
        jmp     main_loop

ml_play:
        jsr     count_selected
        beq     ml_play_done
        jsr     build_play_msg
        jsr     net_send
ml_play_done:
        jmp     main_loop

ml_draw:
        jsr     send_draw
        jmp     main_loop

conn_failed:
        jsr     display_clear
        ldx     #<msg_conn_fail
        ldy     #>msg_conn_fail
        jsr     print_string
        jmp     wait_key

game_over:
        jsr     display_clear
        ldx     #<msg_game_over
        ldy     #>msg_game_over
        jsr     print_string
        jsr     wait_key

quit_game:
        jsr     net_close
        rts

; Helper routines
init_system:
        sei
        lda     #$00
        sta     $D011
        jsr     net_init
        lda     #$1B
        sta     $D011
        cli
        rts

input_ip_address:
        jsr     display_clear
        ldx     #<msg_enter_ip
        ldy     #>msg_enter_ip
        jsr     print_string
        jsr     input_line
        rts

do_connect:
        jsr     display_clear
        ldx     #<msg_connecting
        ldy     #>msg_connecting
        jsr     print_string
        jsr     net_connect
        rts

wait_for_game:
        jsr     display_clear
        ldx     #<msg_waiting
        ldy     #>msg_waiting
        jsr     print_string
wfg_loop:
        jsr     net_recv
        bcs     wfg_loop
        jsr     rubp_validate
        bcs     wfg_loop
        lda     rx_buffer+6
        cmp     #MSG_GAME_STATE
        bne     wfg_loop
        jsr     process_game_state
        rts

rubp_validate:
        lda     rx_buffer
        cmp     #'R'
        bne     rv_fail
        lda     rx_buffer+1
        cmp     #'A'
        bne     rv_fail
        lda     rx_buffer+2
        cmp     #'C'
        bne     rv_fail
        lda     rx_buffer+3
        cmp     #'H'
        bne     rv_fail
        clc
        rts
rv_fail:
        sec
        rts

count_selected:
        ldx     #0
        ldy     #0
cs_loop:
        lda     selected_flags,x
        beq     cs_next
        iny
cs_next:
        inx
        cpx     HAND_COUNT
        bne     cs_loop
        tya
        rts

build_play_msg:
        lda     #MSG_PLAY_CARDS
        jsr     build_header
        jsr     count_selected
        sta     tx_buffer+16
        lda     nominated_suit
        sta     tx_buffer+17
        ldx     #0
        ldy     #0
bpm_loop:
        lda     selected_flags,x
        beq     bpm_next
        lda     MY_HAND,x
        sta     tx_buffer+18,y
        iny
bpm_next:
        inx
        cpx     HAND_COUNT
        bne     bpm_loop
        ldx     #0
bpm_clr:
        sta     selected_flags,x
        inx
        cpx     #16
        bne     bpm_clr
        rts

; Data
msg_enter_ip:   .byte   "ENTER SERVER IP:", 13, 0
msg_connecting: .byte   "CONNECTING...", 13, 0
msg_waiting:    .byte   "WAITING FOR GAME...", 13, 0
msg_conn_fail:  .byte   "CONNECTION FAILED", 13, 0
msg_game_over:  .byte   "GAME OVER!", 13, 0

selected_flags: .res    16

; Includes
        .include "equates.asm"
        .include "display.asm"
        .include "input.asm"
        .include "game.asm"
        .include "connect.asm"
        .include "rubp.asm"
        .include "net/wifi.asm"
