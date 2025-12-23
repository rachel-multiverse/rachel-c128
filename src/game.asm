; =============================================================================
; COMMODORE 128 GAME MODULE (80-column)
; ca65 syntax
; =============================================================================

; Draw the complete game screen
draw_game_screen:
        jsr     display_init
        ldx     #34
        ldy     #0
        jsr     set_cursor
        lda     #<gm_title
        sta     zp_ptr
        lda     #>gm_title
        sta     zp_ptr+1
        jsr     print_string

        ldy     #1
        jsr     draw_border
        ldy     #3
        jsr     draw_border
        ldy     #7
        jsr     draw_border
        ldy     #14
        jsr     draw_border
        ldy     #16
        jsr     draw_border

        ldx     #1
        ldy     #8
        jsr     set_cursor
        lda     #<gm_hand
        sta     zp_ptr
        lda     #>gm_hand
        sta     zp_ptr+1
        jsr     print_string

        ldx     #1
        ldy     #15
        jsr     set_cursor
        lda     #<gm_ctrl
        sta     zp_ptr
        lda     #>gm_ctrl
        sta     zp_ptr+1
        jsr     print_string
        rts

gm_title:   .byte   "RACHEL V1.0", 0
gm_hand:    .byte   "YOUR HAND:", 0
gm_ctrl:    .byte   "LEFT/RIGHT=MOVE  SPACE=SELECT  RETURN=PLAY  D=DRAW  Q=QUIT", 0

; Full game redraw
redraw_game:
        jsr     draw_players
        jsr     draw_discard
        jsr     draw_hand
        jsr     draw_turn_indicator
        rts

; Player list
draw_players:
        ldx     #0
        ldy     #2
        jsr     set_cursor
        lda     #0
dp_loop1:
        sta     dp_idx
        jsr     draw_one_player
        lda     dp_idx
        clc
        adc     #1
        cmp     #4
        bcc     dp_loop1
        ldx     #40
        ldy     #2
        jsr     set_cursor
        lda     #4
dp_loop2:
        sta     dp_idx
        jsr     draw_one_player
        lda     dp_idx
        clc
        adc     #1
        cmp     #8
        bcc     dp_loop2
        rts

dp_idx: .byte   0

draw_one_player:
        lda     #'P'
        jsr     print_char
        lda     dp_idx
        clc
        adc     #'1'
        jsr     print_char
        lda     #':'
        jsr     print_char
        ldx     dp_idx
        lda     PLAYER_COUNTS,x
        jsr     print_number_2d
        lda     #' '
        jsr     print_char
        jsr     print_char
        rts

; Discard pile
draw_discard:
        ldx     #34
        ldy     #4
        jsr     set_cursor
        lda     #<dd_lbl
        sta     zp_ptr
        lda     #>dd_lbl
        sta     zp_ptr+1
        jsr     print_string
        ldx     #36
        ldy     #5
        jsr     set_cursor
        lda     DISCARD_TOP
        beq     dd_empty
        jsr     print_card
        jmp     dd_suit

dd_empty:
        lda     #<dd_mt
        sta     zp_ptr
        lda     #>dd_mt
        sta     zp_ptr+1
        jsr     print_string
        rts

dd_suit:
        lda     NOMINATED_SUIT
        cmp     #$FF
        beq     dd_done
        ldx     #34
        ldy     #6
        jsr     set_cursor
        lda     #<dd_st_lbl
        sta     zp_ptr
        lda     #>dd_st_lbl
        sta     zp_ptr+1
        jsr     print_string
        lda     NOMINATED_SUIT
        jsr     print_suit_name
dd_done:
        rts

dd_lbl:     .byte   "DISCARD:", 0
dd_mt:      .byte   "[EMPTY]", 0
dd_st_lbl:  .byte   "SUIT: ", 0

print_suit_name:
        and     #3
        asl     a
        tax
        lda     sn_ptrs,x
        sta     zp_ptr
        lda     sn_ptrs+1,x
        sta     zp_ptr+1
        jsr     print_string
        rts

sn_ptrs:    .word   sn_h, sn_d, sn_c, sn_s
sn_h:   .byte   "HEARTS", 0
sn_d:   .byte   "DIAMONDS", 0
sn_c:   .byte   "CLUBS", 0
sn_s:   .byte   "SPADES", 0

; Hand display
draw_hand:
        lda     HAND_COUNT
        bne     dh_has_cards
        ldx     #1
        ldy     #9
        jsr     set_cursor
        lda     #<dh_empty
        sta     zp_ptr
        lda     #>dh_empty
        sta     zp_ptr+1
        jsr     print_string
        rts

dh_has_cards:
        ldx     #1
        ldy     #9
        jsr     set_cursor
        lda     #0
        sta     dh_pos
        sta     dh_col

dh_loop:
        lda     dh_pos
        jsr     check_selected
        beq     dh_not_sel
        lda     #'['
        jsr     print_char
        jmp     dh_card

dh_not_sel:
        lda     dh_pos
        cmp     CURSOR_POS
        bne     dh_not_cur
        lda     #'>'
        jsr     print_char
        jmp     dh_card

dh_not_cur:
        lda     #' '
        jsr     print_char

dh_card:
        ldx     dh_pos
        lda     MY_HAND,x
        jsr     print_card
        lda     dh_pos
        jsr     check_selected
        beq     dh_no_close
        lda     #']'
        jsr     print_char
        jmp     dh_space
dh_no_close:
        lda     #' '
        jsr     print_char

dh_space:
        inc     dh_pos
        inc     dh_col
        lda     dh_col
        cmp     #13
        bne     dh_no_newline
        lda     #0
        sta     dh_col
        lda     dh_pos
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        clc
        adc     #9
        tay
        ldx     #1
        jsr     set_cursor

dh_no_newline:
        lda     dh_pos
        cmp     HAND_COUNT
        bcc     dh_loop
        rts

dh_pos:     .byte   0
dh_col:     .byte   0
dh_empty:   .byte   "(NO CARDS)", 0

; Check if card selected
check_selected:
        cmp     #8
        bcs     cks_high
        tax
        lda     SELECTED_LO
        jmp     cks_shift

cks_high:
        sec
        sbc     #8
        tax
        lda     SELECTED_HI

cks_shift:
        cpx     #0
        beq     cks_test
cks_sloop:
        lsr     a
        dex
        bne     cks_sloop

cks_test:
        and     #1
        rts

; Turn indicator
draw_turn_indicator:
        ldy     #17
        jsr     clear_row
        ldx     #30
        ldy     #17
        jsr     set_cursor
        lda     CURRENT_TURN
        cmp     MY_INDEX
        bne     dti_other
        lda     #<dti_your
        sta     zp_ptr
        lda     #>dti_your
        sta     zp_ptr+1
        jsr     print_string
        rts

dti_other:
        lda     #<dti_player
        sta     zp_ptr
        lda     #>dti_player
        sta     zp_ptr+1
        jsr     print_string
        lda     CURRENT_TURN
        clc
        adc     #'1'
        jsr     print_char
        lda     #<dti_turn
        sta     zp_ptr
        lda     #>dti_turn
        sta     zp_ptr+1
        jsr     print_string
        rts

dti_your:   .byte   ">>> YOUR TURN <<<", 0
dti_player: .byte   "PLAYER ", 0
dti_turn:   .byte   "'S TURN", 0
