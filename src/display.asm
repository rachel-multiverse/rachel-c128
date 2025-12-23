; =============================================================================
; COMMODORE 128 DISPLAY MODULE (VDC 80-Column)
; ca65 syntax
; =============================================================================

; Initialize display (80-column mode)
display_init:
        jsr     clear_screen
        rts

; Clear display (alias)
display_clear:
        jsr     clear_screen
        rts

; Display title screen
display_title:
        jsr     clear_screen
        ldx     #30
        ldy     #5
        jsr     set_cursor
        lda     #<dt_title
        sta     zp_ptr
        lda     #>dt_title
        sta     zp_ptr+1
        jsr     print_string
        rts

dt_title:
        .byte   "===== RACHEL =====", 0

; Render game (full redraw)
render_game:
        jsr     draw_game_screen
        jsr     redraw_game
        rts

; Render just the hand
render_hand:
        jsr     draw_hand
        rts

; Clear screen
clear_screen:
        lda     #VDC_UPDATE_HI
        ldx     #0
        jsr     vdc_write
        lda     #VDC_UPDATE_LO
        ldx     #0
        jsr     vdc_write

        ldy     #0
        ldx     #(VDC_COLS * VDC_ROWS / 256) + 1
cls_outer:
        lda     #0
cls_inner:
        pha
        lda     #VDC_DATA_REG
        ldx     #32
        jsr     vdc_write
        pla
        clc
        adc     #1
        bne     cls_inner
        dex
        bne     cls_outer
        rts

; Write to VDC register
; Input: A = register, X = value
vdc_write:
        sta     VDC_ADDR
vdc_wait1:
        bit     VDC_ADDR
        bpl     vdc_wait1
        stx     VDC_DATA
        rts

; Read from VDC register
vdc_read:
        sta     VDC_ADDR
vdc_wait2:
        bit     VDC_ADDR
        bpl     vdc_wait2
        lda     VDC_DATA
        rts

; Set cursor position
; Input: X = column (0-79), Y = row (0-24)
set_cursor:
        stx     zp_temp1

        tya
        ldx     #0
        stx     zp_temp2

        ; Multiply by 80 (64 + 16)
        asl     a
        rol     zp_temp2
        asl     a
        rol     zp_temp2
        asl     a
        rol     zp_temp2
        asl     a
        rol     zp_temp2
        sta     zp_temp3
        ldx     zp_temp2
        stx     zp_temp4

        asl     a
        rol     zp_temp2
        asl     a
        rol     zp_temp2

        clc
        adc     zp_temp3
        sta     zp_temp3
        lda     zp_temp2
        adc     zp_temp4
        sta     zp_temp4

        lda     zp_temp3
        clc
        adc     zp_temp1
        sta     zp_temp3
        lda     zp_temp4
        adc     #0
        sta     zp_temp4

        lda     #VDC_UPDATE_HI
        ldx     zp_temp4
        jsr     vdc_write
        lda     #VDC_UPDATE_LO
        ldx     zp_temp3
        jsr     vdc_write
        rts

; Print character
print_char:
        pha
        lda     #VDC_DATA_REG
        sta     VDC_ADDR
pc_wait:
        bit     VDC_ADDR
        bpl     pc_wait
        pla
        sta     VDC_DATA
        rts

; Print null-terminated string
; Input: zp_ptr = string address
print_string:
        ldy     #0
ps_loop:
        lda     (zp_ptr),y
        beq     ps_done
        jsr     print_char
        iny
        bne     ps_loop
ps_done:
        rts

; Clear a row
clear_row:
        ldx     #0
        jsr     set_cursor
        ldx     #VDC_COLS
        lda     #32
cr_loop:
        jsr     print_char
        dex
        bne     cr_loop
        rts

; Draw horizontal border
draw_border:
        ldx     #0
        jsr     set_cursor
        ldx     #VDC_COLS
        lda     #'-'
db_loop:
        jsr     print_char
        dex
        bne     db_loop
        rts

; Print a card
print_card:
        pha
        and     #$0F
        tax
        lda     rank_chars,x
        jsr     print_char
        pla
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        and     #$03
        tax
        lda     suit_chars,x
        jsr     print_char
        rts

; Print 2-digit number
print_number_2d:
        sta     zp_temp3
        ldx     #0
pn2d_tens:
        cmp     #10
        bcc     pn2d_print
        sec
        sbc     #10
        inx
        bne     pn2d_tens
pn2d_print:
        sta     zp_temp3
        txa
        ora     #'0'
        jsr     print_char
        lda     zp_temp3
        ora     #'0'
        jsr     print_char
        rts

rank_chars:
        .byte   "?A23456789TJQK"

suit_chars:
        .byte   "HDCS"
