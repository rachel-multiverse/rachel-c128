; =============================================================================
; COMMODORE 128 DISPLAY MODULE (VDC 80-Column)
; =============================================================================

; -----------------------------------------------------------------------------
; Initialize display (80-column mode)
; -----------------------------------------------------------------------------
display_init
        jsr     clear_screen
        rts

; -----------------------------------------------------------------------------
; Clear screen
; -----------------------------------------------------------------------------
clear_screen
        lda     #VDC_UPDATE_HI
        ldx     #0
        jsr     vdc_write
        lda     #VDC_UPDATE_LO
        ldx     #0
        jsr     vdc_write

        ldy     #0
        ldx     #(VDC_COLS * VDC_ROWS / 256) + 1
cls_outer
        lda     #0
cls_inner
        pha
        lda     #VDC_DATA_REG
        ldx     #32             ; Space character
        jsr     vdc_write
        pla
        clc
        adc     #1
        bne     cls_inner
        dex
        bne     cls_outer
        rts

; -----------------------------------------------------------------------------
; Write to VDC register
; Input: A = register, X = value
; -----------------------------------------------------------------------------
vdc_write
        sta     VDC_ADDR
vdc_wait1
        bit     VDC_ADDR
        bpl     vdc_wait1
        stx     VDC_DATA
        rts

; -----------------------------------------------------------------------------
; Read from VDC register
; Input: A = register
; Output: A = value
; -----------------------------------------------------------------------------
vdc_read
        sta     VDC_ADDR
vdc_wait2
        bit     VDC_ADDR
        bpl     vdc_wait2
        lda     VDC_DATA
        rts

; -----------------------------------------------------------------------------
; Set cursor position
; Input: X = column (0-79), Y = row (0-24)
; -----------------------------------------------------------------------------
set_cursor
        stx     zp_temp1        ; Save column

        ; Calculate address: row * 80 + column
        tya
        ldx     #0
        stx     zp_temp2        ; High byte

        ; Multiply by 80 (64 + 16)
        asl     a               ; *2
        rol     zp_temp2
        asl     a               ; *4
        rol     zp_temp2
        asl     a               ; *8
        rol     zp_temp2
        asl     a               ; *16
        rol     zp_temp2
        sta     zp_temp3
        ldx     zp_temp2
        stx     zp_temp4

        asl     a               ; *32
        rol     zp_temp2
        asl     a               ; *64
        rol     zp_temp2

        clc
        adc     zp_temp3        ; 64 + 16 = 80
        sta     zp_temp3
        lda     zp_temp2
        adc     zp_temp4
        sta     zp_temp4

        ; Add column
        lda     zp_temp3
        clc
        adc     zp_temp1
        sta     zp_temp3
        lda     zp_temp4
        adc     #0
        sta     zp_temp4

        ; Set VDC update address
        lda     #VDC_UPDATE_HI
        ldx     zp_temp4
        jsr     vdc_write
        lda     #VDC_UPDATE_LO
        ldx     zp_temp3
        jsr     vdc_write

        rts

; -----------------------------------------------------------------------------
; Print character
; Input: A = character
; -----------------------------------------------------------------------------
print_char
        pha
        lda     #VDC_DATA_REG
        sta     VDC_ADDR
pc_wait
        bit     VDC_ADDR
        bpl     pc_wait
        pla
        sta     VDC_DATA
        rts

; -----------------------------------------------------------------------------
; Print null-terminated string
; Input: zp_ptr = string address
; -----------------------------------------------------------------------------
print_string
        ldy     #0
ps_loop
        lda     (zp_ptr),y
        beq     ps_done
        jsr     print_char
        iny
        bne     ps_loop
ps_done
        rts

; -----------------------------------------------------------------------------
; Clear a row
; Input: Y = row number
; -----------------------------------------------------------------------------
clear_row
        ldx     #0
        jsr     set_cursor
        ldx     #VDC_COLS
        lda     #32
cr_loop
        jsr     print_char
        dex
        bne     cr_loop
        rts

; -----------------------------------------------------------------------------
; Draw horizontal border
; Input: Y = row number
; -----------------------------------------------------------------------------
draw_border
        ldx     #0
        jsr     set_cursor
        ldx     #VDC_COLS
        lda     #'-'
db_loop
        jsr     print_char
        dex
        bne     db_loop
        rts

; -----------------------------------------------------------------------------
; Print a card
; Input: A = card byte
; -----------------------------------------------------------------------------
print_card
        pha

        and     #$0F            ; Rank
        tax
        lda     rank_chars,x
        jsr     print_char

        pla
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        and     #$03            ; Suit
        tax
        lda     suit_chars,x
        jsr     print_char

        rts

rank_chars
        .byte   "?A23456789TJQK"

suit_chars
        .byte   "HDCS"
