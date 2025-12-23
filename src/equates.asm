; =============================================================================
; COMMODORE 128 EQUATES
; =============================================================================

; VDC Registers (80-column chip)
VDC_ADDR        = $D600         ; VDC address register
VDC_DATA        = $D601         ; VDC data register

; VDC Register Numbers
VDC_CURSOR_HI   = 14            ; Cursor position high
VDC_CURSOR_LO   = 15            ; Cursor position low
VDC_UPDATE_HI   = 18            ; Update address high
VDC_UPDATE_LO   = 19            ; Update address low
VDC_DATA_REG    = 31            ; Data register for read/write

; VDC Screen
VDC_COLS        = 80
VDC_ROWS        = 25
VDC_SCREEN      = $0000         ; VDC RAM base

; Zero page
zp_ptr          = $FB
zp_ptr2         = $FD
zp_temp1        = $02
zp_temp2        = $03
zp_temp3        = $04
zp_temp4        = $05

; KERNAL Routines
CHROUT          = $FFD2         ; Output character
GETIN           = $FFE4         ; Get character (non-blocking)
CHRIN           = $FFCF         ; Get character (blocking)

; RS-232 (User Port)
RS232_STATUS    = $DD01         ; User port data
RS232_DIR       = $DD03         ; Data direction

; Key codes
KEY_LEFT        = 157           ; CRSR LEFT
KEY_RIGHT       = 29            ; CRSR RIGHT
KEY_UP          = 145           ; CRSR UP
KEY_DOWN        = 17            ; CRSR DOWN
KEY_RETURN      = 13
KEY_SPACE       = 32
KEY_Q           = 81            ; Q key
KEY_D           = 68            ; D key

; RUBP Protocol Constants
MAGIC_0         = 'R'
MAGIC_1         = 'A'
MAGIC_2         = 'C'
MAGIC_3         = 'H'
PROTOCOL_VER    = 1

; Header offsets
HDR_MAGIC       = 0
HDR_VERSION     = 4
HDR_TYPE        = 5
HDR_FLAGS       = 6
HDR_RESERVED    = 7
HDR_SEQ         = 8
HDR_PLAYER_ID   = 10
HDR_GAME_ID     = 12
HDR_CHECKSUM    = 14
PAYLOAD_START   = 16
PAYLOAD_SIZE    = 48

; Message types
MSG_JOIN        = $01
MSG_LEAVE       = $02
MSG_READY       = $03
MSG_GAME_START  = $10
MSG_GAME_STATE  = $11
MSG_GAME_END    = $12
MSG_PLAY_CARDS  = $20
MSG_DRAW_CARD   = $21
MSG_NOMINATE    = $22
MSG_ACK         = $F0
MSG_NAK         = $F1

; Connection states
CONN_DISCONNECTED = 0
CONN_HANDSHAKE    = 1
CONN_WAITING      = 2
CONN_PLAYING      = 3

; Card constants
SUIT_HEARTS     = 0
SUIT_DIAMONDS   = 1
SUIT_CLUBS      = 2
SUIT_SPADES     = 3

RANK_ACE        = 1
RANK_JACK       = 11
RANK_QUEEN      = 12
RANK_KING       = 13
