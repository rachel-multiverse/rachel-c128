; =============================================================================
; COMMODORE 128 CONNECTION MODULE
; ca65 syntax
; =============================================================================

connect_server:
        jsr     net_init
        bcs     conn_fail
        jsr     net_connect
        bcs     conn_fail
        lda     #1
        sta     connected
        clc
        rts
conn_fail:
        lda     #0
        sta     connected
        sec
        rts

conn_port:  .word   0
connected:  .byte   0
server_ip:  .byte   0, 0, 0, 0

disconnect:
        lda     connected
        beq     disc_done
        jsr     net_close
        lda     #0
        sta     connected
disc_done:
        rts

show_connect_screen:
        jsr     display_init
        ldx     #30
        ldy     #8
        jsr     set_cursor
        lda     #<cs_title
        sta     zp_ptr
        lda     #>cs_title
        sta     zp_ptr+1
        jsr     print_string
        ldx     #28
        ldy     #10
        jsr     set_cursor
        lda     #<cs_prompt
        sta     zp_ptr
        lda     #>cs_prompt
        sta     zp_ptr+1
        jsr     print_string
        ldx     #28
        ldy     #12
        jsr     set_cursor
        rts

cs_title:   .byte   "CONNECT TO RACHEL", 0
cs_prompt:  .byte   "SERVER IP: ", 0

get_server_address:
        jsr     show_connect_screen
        lda     #<input_buffer
        sta     zp_ptr
        lda     #>input_buffer
        sta     zp_ptr+1
        ldx     #15
        jsr     input_line
        cmp     #0
        beq     gsa_cancel
        jsr     parse_ip
        bcs     gsa_cancel
        clc
        rts
gsa_cancel:
        sec
        rts

parse_ip:
        ldy     #0
        ldx     #0
pi_byte:
        lda     #0
        sta     zp_temp1
pi_digit:
        lda     (zp_ptr),y
        beq     pi_end_byte
        cmp     #'.'
        beq     pi_next
        cmp     #'0'
        bcc     pi_error
        cmp     #':'
        bcs     pi_end_byte
        sec
        sbc     #'0'
        sta     zp_temp2
        lda     zp_temp1
        asl     a
        asl     a
        adc     zp_temp1
        asl     a
        adc     zp_temp2
        sta     zp_temp1
        iny
        bne     pi_digit
pi_next:
        lda     zp_temp1
        sta     server_ip,x
        inx
        iny
        cpx     #4
        bcc     pi_byte
pi_error:
        sec
        rts
pi_end_byte:
        lda     zp_temp1
        sta     server_ip,x
        clc
        rts

input_buffer:   .res    16

show_connecting:
        ldx     #32
        ldy     #14
        jsr     set_cursor
        lda     #<sc_msg
        sta     zp_ptr
        lda     #>sc_msg
        sta     zp_ptr+1
        jsr     print_string
        rts
sc_msg: .byte   "CONNECTING...", 0

show_connect_error:
        ldx     #28
        ldy     #14
        jsr     set_cursor
        lda     #<sce_msg
        sta     zp_ptr
        lda     #>sce_msg
        sta     zp_ptr+1
        jsr     print_string
        jsr     wait_key
        rts
sce_msg:    .byte   "CONNECTION FAILED!", 0
