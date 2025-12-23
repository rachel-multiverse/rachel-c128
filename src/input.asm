; =============================================================================
; COMMODORE 128 INPUT MODULE
; =============================================================================

; -----------------------------------------------------------------------------
; Wait for key (blocking)
; Returns: A = key code
; -----------------------------------------------------------------------------
wait_key
wk_loop
        jsr     GETIN
        beq     wk_loop
        rts

; -----------------------------------------------------------------------------
; Check for key (non-blocking)
; Returns: A = key if pressed, 0 if no key
; -----------------------------------------------------------------------------
check_key
        jsr     GETIN
        rts

; -----------------------------------------------------------------------------
; Input line
; Input: zp_ptr = buffer, X = max length
; Returns: A = length entered
; -----------------------------------------------------------------------------
input_line
        stx     zp_temp1        ; Max length
        ldy     #0              ; Current position

il_loop
        jsr     wait_key

        cmp     #KEY_RETURN
        beq     il_done

        cmp     #20             ; DEL key on C128
        beq     il_delete

        cpy     zp_temp1
        bcs     il_loop         ; At max

        cmp     #32
        bcc     il_loop         ; Non-printable
        cmp     #127
        bcs     il_loop

        sta     (zp_ptr),y
        iny
        jsr     CHROUT
        jmp     il_loop

il_delete
        cpy     #0
        beq     il_loop

        dey
        lda     #20             ; DEL
        jsr     CHROUT
        jmp     il_loop

il_done
        lda     #0
        sta     (zp_ptr),y
        tya
        rts
