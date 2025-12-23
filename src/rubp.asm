; =============================================================================
; COMMODORE 128 RUBP PROTOCOL MODULE
; Message types defined in equates.asm
; ca65 syntax
; =============================================================================

rubp_init:
        lda     #0
        sta     rubp_seq
        sta     last_recv_seq
        rts

rubp_seq:       .byte   0
last_recv_seq:  .byte   0

build_header:
        sta     msg_type_temp
        lda     #'R'
        sta     tx_buffer
        lda     #'A'
        sta     tx_buffer+1
        lda     #'C'
        sta     tx_buffer+2
        lda     #'H'
        sta     tx_buffer+3
        lda     #$01
        sta     tx_buffer+4
        lda     #$00
        sta     tx_buffer+5
        lda     msg_type_temp
        sta     tx_buffer+6
        lda     #$00
        sta     tx_buffer+7
        sta     tx_buffer+8
        lda     rubp_seq
        sta     tx_buffer+9
        inc     rubp_seq
        lda     player_id
        sta     tx_buffer+10
        lda     player_id+1
        sta     tx_buffer+11
        lda     game_id
        sta     tx_buffer+12
        lda     game_id+1
        sta     tx_buffer+13
        lda     #$00
        sta     tx_buffer+14
        sta     tx_buffer+15
        rts

msg_type_temp:  .byte   0
player_id:      .word   0
game_id:        .word   0

send_join:
        lda     #MSG_JOIN
        jsr     build_header
        ldx     #16
        lda     #0
sj_clear:
        sta     tx_buffer,x
        inx
        cpx     #64
        bne     sj_clear
        jsr     net_send
        rts

send_ready:
        lda     #MSG_READY
        jsr     build_header
        ldx     #16
        lda     #0
sr_clear:
        sta     tx_buffer,x
        inx
        cpx     #64
        bne     sr_clear
        jsr     net_send
        rts

send_play_cards:
        stx     card_count_temp
        lda     #MSG_PLAY_CARDS
        jsr     build_header
        lda     card_count_temp
        sta     tx_buffer+16
        lda     nominated_suit
        sta     tx_buffer+17
        ldx     #0
spc_copy:
        cpx     card_count_temp
        bcs     spc_pad
        lda     card_play_buf,x
        sta     tx_buffer+18,x
        inx
        bne     spc_copy
spc_pad:
        cpx     #8
        bcs     spc_done
        lda     #0
        sta     tx_buffer+18,x
        inx
        bne     spc_pad
spc_done:
        ldx     #26
spc_clear:
        lda     #0
        sta     tx_buffer,x
        inx
        cpx     #64
        bne     spc_clear
        jsr     net_send
        rts

card_count_temp:    .byte   0
nominated_suit:     .byte   $FF
card_play_buf:      .res    8

send_draw:
        lda     #MSG_DRAW_CARD
        jsr     build_header
        ldx     #16
        lda     #0
sd_clear:
        sta     tx_buffer,x
        inx
        cpx     #64
        bne     sd_clear
        jsr     net_send
        rts

receive_message:
        jsr     net_recv
        bcs     rm_none
        lda     rx_buffer
        cmp     #'R'
        bne     rm_invalid
        lda     rx_buffer+1
        cmp     #'A'
        bne     rm_invalid
        lda     rx_buffer+2
        cmp     #'C'
        bne     rm_invalid
        lda     rx_buffer+3
        cmp     #'H'
        bne     rm_invalid
        lda     rx_buffer+9
        sta     last_recv_seq
        lda     rx_buffer+6
        clc
        rts
rm_invalid:
rm_none:
        lda     #0
        sec
        rts

process_game_state:
        lda     rx_buffer+16
        sta     CURRENT_TURN
        lda     rx_buffer+17
        sta     DIRECTION
        lda     rx_buffer+18
        sta     DISCARD_TOP
        lda     rx_buffer+19
        sta     NOMINATED_SUIT
        lda     rx_buffer+20
        sta     PENDING_DRAWS
        lda     rx_buffer+21
        sta     PENDING_SKIPS
        ldx     #0
pgs_counts:
        lda     rx_buffer+22,x
        sta     PLAYER_COUNTS,x
        inx
        cpx     #8
        bne     pgs_counts
        lda     rx_buffer+30
        sta     MY_INDEX
        lda     rx_buffer+31
        sta     HAND_COUNT
        ldx     #0
pgs_hand:
        lda     rx_buffer+32,x
        sta     MY_HAND,x
        inx
        cpx     #16
        bne     pgs_hand
        rts

tx_buffer:  .res    64
rx_buffer:  .res    64
