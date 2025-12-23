; =============================================================================
; COMMODORE 128 WIFI NETWORK DRIVER
; RS-232 via User Port with WiFi modem
; =============================================================================

; User Port RS-232 registers (accent chip at $DE00)
ACIA_DATA       = $DE00
ACIA_STATUS     = $DE01
ACIA_COMMAND    = $DE02
ACIA_CONTROL    = $DE03

STAT_RDRF       = %00001000     ; Receive ready
STAT_TDRE       = %00010000     ; Transmit ready

net_state       .byte   0

net_init
        lda     #%00000000      ; Reset ACIA
        sta     ACIA_COMMAND
        lda     #%00001011      ; 8N1, 9600 baud
        sta     ACIA_CONTROL
        lda     #%00001001      ; DTR active, no parity
        sta     ACIA_COMMAND
        clc
        rts

net_connect
        lda     #1
        sta     net_state
        ; Send AT+CIPSTART (simplified)
        ldx     #0
nc_send
        lda     at_connect,x
        beq     nc_wait
        jsr     send_byte
        inx
        bne     nc_send
nc_wait
        jsr     wait_response
        bcs     nc_fail
        lda     #2
        sta     net_state
        clc
        rts
nc_fail
        lda     #0
        sta     net_state
        sec
        rts

at_connect  .byte   "AT+CIPSTART", 13, 0

net_close
        ldx     #0
ncl_send
        lda     at_close,x
        beq     ncl_done
        jsr     send_byte
        inx
        bne     ncl_send
ncl_done
        lda     #0
        sta     net_state
        rts

at_close    .byte   "AT+CIPCLOSE", 13, 0

net_send
        lda     net_state
        cmp     #2
        bne     ns_fail
        ldx     #0
ns_loop
        lda     tx_buffer,x
        jsr     send_byte
        inx
        cpx     #64
        bne     ns_loop
        clc
        rts
ns_fail
        sec
        rts

net_recv
        lda     net_state
        cmp     #2
        bne     nr_fail
        ldx     #0
nr_loop
        jsr     recv_byte_timeout
        bcs     nr_partial
        sta     rx_buffer,x
        inx
        cpx     #64
        bne     nr_loop
        clc
        rts
nr_partial
        lda     #0
nr_fill
        sta     rx_buffer,x
        inx
        cpx     #64
        bne     nr_fill
nr_fail
        sec
        rts

send_byte
        pha
sb_wait
        lda     ACIA_STATUS
        and     #STAT_TDRE
        beq     sb_wait
        pla
        sta     ACIA_DATA
        rts

recv_byte_timeout
        ldx     #0
        ldy     #0
rbt_loop
        lda     ACIA_STATUS
        and     #STAT_RDRF
        bne     rbt_got
        dex
        bne     rbt_loop
        dey
        bne     rbt_loop
        sec
        rts
rbt_got
        lda     ACIA_DATA
        clc
        rts

wait_response
        ldx     #0
wr_loop
        jsr     recv_byte_timeout
        bcs     wr_timeout
        cmp     #'O'
        bne     wr_loop
        jsr     recv_byte_timeout
        bcs     wr_timeout
        cmp     #'K'
        bne     wr_loop
        clc
        rts
wr_timeout
        sec
        rts
