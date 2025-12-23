; =============================================================================
; COMMODORE 128 INPUT MODULE
; ca65 syntax
; =============================================================================

; Get input for game (blocking)
get_input:
        jsr     wait_key
        rts

; Wait for key (blocking)
wait_key:
wk_loop:
        jsr     GETIN
        beq     wk_loop
        rts

; Check for key (non-blocking)
check_key:
        jsr     GETIN
        rts

; Input line
; Input: zp_ptr = buffer, X = max length
input_line:
        stx     zp_temp1
        ldy     #0

il_loop:
        jsr     wait_key
        cmp     #KEY_RETURN
        beq     il_done
        cmp     #20
        beq     il_delete
        cpy     zp_temp1
        bcs     il_loop
        cmp     #32
        bcc     il_loop
        cmp     #127
        bcs     il_loop
        sta     (zp_ptr),y
        iny
        jsr     CHROUT
        jmp     il_loop

il_delete:
        cpy     #0
        beq     il_loop
        dey
        lda     #20
        jsr     CHROUT
        jmp     il_loop

il_done:
        lda     #0
        sta     (zp_ptr),y
        tya
        rts

; Cursor movement
cursor_left:
        lda     CURSOR_POS
        beq     cl_done
        dec     CURSOR_POS
cl_done:
        rts

cursor_right:
        lda     CURSOR_POS
        clc
        adc     #1
        cmp     HAND_COUNT
        bcs     cr_done
        inc     CURSOR_POS
cr_done:
        rts

toggle_select:
        lda     CURSOR_POS
        cmp     #8
        bcs     ts_high
        tax
        lda     #1
ts_shift:
        cpx     #0
        beq     ts_toggle_lo
        asl     a
        dex
        bne     ts_shift
ts_toggle_lo:
        eor     SELECTED_LO
        sta     SELECTED_LO
        rts
ts_high:
        sec
        sbc     #8
        tax
        lda     #1
ts_shift2:
        cpx     #0
        beq     ts_toggle_hi
        asl     a
        dex
        bne     ts_shift2
ts_toggle_hi:
        eor     SELECTED_HI
        sta     SELECTED_HI
        rts
