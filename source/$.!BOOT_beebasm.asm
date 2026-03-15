; Constants
crtc_horz_total = 0
keymap_any_fire = 207
keymap_pause    = 128
screen_height_g = 24
screen_width_g  = 32

; Memory locations
BUG_should_be_cmp_hash_32       = &0001
z_l                             = &0020
z_h                             = &0021
z_c                             = &0022
z_b                             = &0023
z_e                             = &0024
z_d                             = &0025
z_as                            = &0026
z_ixl                           = &0028
t_RetAddrL                      = &0029
z_ixh                           = &0029
t_RetAddrH                      = &002a
t_a                             = &002b
t_MemdumpL                      = &002e
t_MemdumpH                      = &002f
t_MemdumpBL                     = &0030
t_MemdumpBH                     = &0031
cursorX                         = &0040
cursorY                         = &0041
BUG_should_be_immediate_FF      = &00ff
l0100                           = &0100
l0101                           = &0101
l0104                           = &0104
l0105                           = &0105
tile_map2                       = &3300
playerX1                        = &3610
random_seed                     = &3611
playerY1                        = &3612
fast_growth                     = &3613
player_dir                      = &3614
bulletX1                        = &3615
nothing_shot                    = &3616
bulletY1                        = &3617
allowed_fast_growth             = &3619
bullet_dir                      = &361a
playing_sfx                     = &361b
control_mode                    = &361c
game_tick                       = &361d
lives                           = &361e
anim_frame                      = &361f
score                           = &3620
high_score                      = &3624
anim_tick                       = &3628
debounce_count                  = &3629
random_seed_2                   = &362a
raw_bitmap_end                  = &3640
BUG_c64_PLOT                    = &e50a
crtc_address_register           = &fe00
crtc_register_data              = &fe01
video_ula_control               = &fe20
video_ula_palette               = &fe21
system_via_orb_irb              = &fe40
system_via_ora_ira              = &fe41
system_via_ddrb                 = &fe42
system_via_ddra                 = &fe43
adc_start_conversion_or_status  = &fec0
adc_read_data_high_byte         = &fec1
BUG_c64_READ                    = &ffe4

    org &3000

.pydis_start
.entry_point
.raw_bitmap
.tile_map
    sei                                                               ; 3000: 78          x
    lda BUG_should_be_immediate_FF                                    ; 3001: a5 ff       ..
    sta system_via_ddra                                               ; 3003: 8d 43 fe    .C.
    lda #&9f                                                          ; 3006: a9 9f       ..
    sta system_via_ora_ira                                            ; 3008: 8d 41 fe    .A.
    lda #8                                                            ; 300b: a9 08       ..
    sta system_via_orb_irb                                            ; 300d: 8d 40 fe    .@.
    lda #0                                                            ; 3010: a9 00       ..
    sta system_via_orb_irb                                            ; 3012: 8d 40 fe    .@.
    ; relocation loop. Moves the code from $3000 to $200 for $1900 bytes
    lda #0                                                            ; 3015: a9 00       ..
    sta z_c                                                           ; 3017: 85 22       ."
    sta z_l                                                           ; 3019: 85 20       .
    sta z_e                                                           ; 301b: 85 24       .$
    lda #&30                                                          ; 301d: a9 30       .0
    sta z_h                                                           ; 301f: 85 21       .!
    lda #&19                                                          ; 3021: a9 19       ..
    sta z_b                                                           ; 3023: 85 23       .#
    lda #2                                                            ; 3025: a9 02       ..
    sta z_d                                                           ; 3027: 85 25       .%
.loop
    ldy #0                                                            ; 3029: a0 00       ..
    lda (z_l),y                                                       ; 302b: b1 20       .
    sta (z_e),y                                                       ; 302d: 91 24       .$
    inc z_l                                                           ; 302f: e6 20       .
    bne skip_inc2                                                     ; 3031: d0 02       ..
    inc z_h                                                           ; 3033: e6 21       .!
.skip_inc2
    inc z_e                                                           ; 3035: e6 24       .$
    bne skip_inc1                                                     ; 3037: d0 02       ..
    inc z_d                                                           ; 3039: e6 25       .%
.skip_inc1
    dec z_c                                                           ; 303b: c6 22       ."
    bne loop                                                          ; 303d: d0 ea       ..
    lda z_b                                                           ; 303f: a5 23       .#
    beq relocation_done                                               ; 3041: f0 05       ..
    dec z_b                                                           ; 3043: c6 23       .#
    sec                                                               ; 3045: 38          8
    bcs loop                                                          ; 3046: b0 e1       ..             ; ALWAYS branch

.relocation_done
    jmp start                                                         ; 3048: 4c 4b 02    LK.


; Move 1: &304b to &024b for length 6174
    org &024b
.start
    sei                                                               ; 304b: 78          x   :024b[1]
    cld                                                               ; 304c: d8          .   :024c[1]
    jsr initialize_screen                                             ; 304d: 20 29 18     ). :024d[1]

    ; Clear memory from $3000 for $640 bytes
    lda #>raw_bitmap                                                  ; 3050: a9 30       .0  :0250[1]
    sta z_h                                                           ; 3052: 85 21       .!  :0252[1]
    lda #<raw_bitmap                                                  ; 3054: a9 00       ..  :0254[1]
    sta z_l                                                           ; 3056: 85 20       .   :0256[1]
    lda #<(raw_bitmap_end - raw_bitmap)                               ; 3058: a9 40       .@  :0258[1]
    sta z_c                                                           ; 305a: 85 22       ."  :025a[1]
    lda #>(raw_bitmap_end - raw_bitmap)                               ; 305c: a9 06       ..  :025c[1]
    sta z_b                                                           ; 305e: 85 23       .#  :025e[1]
    lda #0                                                            ; 3060: a9 00       ..  :0260[1]
    jsr set_memory                                                    ; 3062: 20 7e 0e     ~. :0262[1]

    lda #0                                                            ; 3065: a9 00       ..  :0265[1]
    sta control_mode                                                  ; 3067: 8d 1c 36    ..6 :0267[1]
    lda #>raw_palettes                                                ; 306a: a9 14       ..  :026a[1]
    sta z_d                                                           ; 306c: 85 25       .%  :026c[1]
    lda #<raw_palettes                                                ; 306e: a9 34       .4  :026e[1]
    sta z_e                                                           ; 3070: 85 24       .$  :0270[1]
    ldy #0                                                            ; 3072: a0 00       ..  :0272[1]
.set_palette_again
    lda (z_e),y                                                       ; 3074: b1 24       .$  :0274[1]
    sta z_l                                                           ; 3076: 85 20       .   :0276[1]
    iny                                                               ; 3078: c8          .   :0278[1]
    lda (z_e),y                                                       ; 3079: b1 24       .$  :0279[1]
    sta z_h                                                           ; 307b: 85 21       .!  :027b[1]
    iny                                                               ; 307d: c8          .   :027d[1]
    tya                                                               ; 307e: 98          .   :027e[1]
    clc                                                               ; 307f: 18          .   :027f[1]
    ror a                                                             ; 3080: 6a          j   :0280[1]
    sec                                                               ; 3081: 38          8   :0281[1]
    sbc #1                                                            ; 3082: e9 01       ..  :0282[1]
    jsr do_set_palette                                                ; 3084: 20 50 19     P. :0284[1]
    cpy #16*2                                                         ; 3087: c0 20       .   :0287[1]   ; 16 colours - 2 bytes per colour
    bne set_palette_again                                             ; 3089: d0 e9       ..  :0289[1]
    jsr cls                                                           ; 308b: 20 4f 18     O. :028b[1]
.title_screen
    jsr force_repaint                                                 ; 308e: 20 5c 0c     \. :028e[1]   ; reset tile_map2, so everything redraws
    jsr clear_screen                                                  ; 3091: 20 4f 0c     O. :0291[1]
    ; copy from HL=title_screen_cells to DE=tile_map+$44 for 24 bytes, then add 8 bytes
    ; to DE and repeat 16 times
    lda #<tile_map                                                    ; 3094: a9 00       ..  :0294[1]   ; we're going to draw the title
    sta z_e                                                           ; 3096: 85 24       .$  :0296[1]
    lda #>tile_map                                                    ; 3098: a9 30       .0  :0298[1]
    sta z_d                                                           ; 309a: 85 25       .%  :029a[1]
    lda #<title_screen_cells                                          ; 309c: a9 69       .i  :029c[1]
    sta z_l                                                           ; 309e: 85 20       .   :029e[1]
    lda #>title_screen_cells                                          ; 30a0: a9 15       ..  :02a0[1]
    sta z_h                                                           ; 30a2: 85 21       .!  :02a2[1]
    lda #0                                                            ; 30a4: a9 00       ..  :02a4[1]
    sta z_b                                                           ; 30a6: 85 23       .#  :02a6[1]
    lda #&44                                                          ; 30a8: a9 44       .D  :02a8[1]
    sta z_c                                                           ; 30aa: 85 22       ."  :02aa[1]
    jsr add_de_bc                                                     ; 30ac: 20 1d 0f     .. :02ac[1]
    ; logo has 16 lines
    ldx #16                                                           ; 30af: a2 10       ..  :02af[1]
.title_pic_next_line
    lda #<24                                                          ; 30b1: a9 18       ..  :02b1[1]   ; bc = 24 = bytes per line
    sta z_c                                                           ; 30b3: 85 22       ."  :02b3[1]
    lda #>24                                                          ; 30b5: a9 00       ..  :02b5[1]
    sta z_b                                                           ; 30b7: 85 23       .#  :02b7[1]
    jsr copy_memory_loop                                              ; 30b9: 20 8f 0e     .. :02b9[1]
    lda #8                                                            ; 30bc: a9 08       ..  :02bc[1]   ; move to start of next line
    sta z_c                                                           ; 30be: 85 22       ."  :02be[1]
    lda #0                                                            ; 30c0: a9 00       ..  :02c0[1]
    sta z_b                                                           ; 30c2: 85 23       .#  :02c2[1]
    jsr add_de_bc                                                     ; 30c4: 20 1d 0f     .. :02c4[1]
    dex                                                               ; 30c7: ca          .   :02c7[1]
    bne title_pic_next_line                                           ; 30c8: d0 e7       ..  :02c8[1]
.restart_scrolling_message
    lda #0                                                            ; 30ca: a9 00       ..  :02ca[1]   ; first character in the string to show
    sta z_c                                                           ; 30cc: 85 22       ."  :02cc[1]
.scrolling_message_loop
    lda z_c                                                           ; 30ce: a5 22       ."  :02ce[1]
    pha                                                               ; 30d0: 48          H   :02d0[1]
    lda z_b                                                           ; 30d1: a5 23       .#  :02d1[1]
    pha                                                               ; 30d3: 48          H   :02d3[1]
    jsr force_animate                                                 ; 30d4: 20 fb 0b     .. :02d4[1]   ; update 2 sets of frames
    jsr repaint_screen                                                ; 30d7: 20 72 0c     r. :02d7[1]

    ; show the high score message
    ldx #screen_width_g/2-8                                           ; 30da: a2 08       ..  :02da[1]
    ldy #screen_height_g-5                                            ; 30dc: a0 13       ..  :02dc[1]
    jsr set_cursor_xy                                                 ; 30de: 20 68 18     h. :02de[1]
    lda #<high_score_message                                          ; 30e1: a9 49       .I  :02e1[1]
    sta z_l                                                           ; 30e3: 85 20       .   :02e3[1]
    lda #>high_score_message                                          ; 30e5: a9 15       ..  :02e5[1]
    sta z_h                                                           ; 30e7: 85 21       .!  :02e7[1]
    jsr print_message_hl                                              ; 30e9: 20 4f 0e     O. :02e9[1]

    ; show high score
    lda #<high_score                                                  ; 30ec: a9 24       .$  :02ec[1]
    sta z_e                                                           ; 30ee: 85 24       .$  :02ee[1]
    lda #>high_score                                                  ; 30f0: a9 36       .6  :02f0[1]
    sta z_d                                                           ; 30f2: 85 25       .%  :02f2[1]
    ldx #4                                                            ; 30f4: a2 04       ..  :02f4[1]
    jsr print_X_bcd_bytes                                             ; 30f6: 20 3a 17     :. :02f6[1]

    ; show the URL message
    ldx #screen_width_g/2-12                                          ; 30f9: a2 04       ..  :02f9[1]
    ldy #screen_height_g-3                                            ; 30fb: a0 15       ..  :02fb[1]
    jsr set_cursor_xy                                                 ; 30fd: 20 68 18     h. :02fd[1]
    lda #<url_message                                                 ; 3100: a9 30       .0  :0300[1]
    sta z_l                                                           ; 3102: 85 20       .   :0302[1]
    lda #>url_message                                                 ; 3104: a9 15       ..  :0304[1]
    sta z_h                                                           ; 3106: 85 21       .!  :0306[1]
    jsr print_message_hl                                              ; 3108: 20 4f 0e     O. :0308[1]

    pla                                                               ; 310b: 68          h   :030b[1]
    sta z_b                                                           ; 310c: 85 23       .#  :030c[1]
    pla                                                               ; 310e: 68          h   :030e[1]
    sta z_c                                                           ; 310f: 85 22       ."  :030f[1]
    lda #0                                                            ; 3111: a9 00       ..  :0311[1]   ; number of characters to skip
    sta z_e                                                           ; 3113: 85 24       .$  :0313[1]
    lda z_c                                                           ; 3115: a5 22       ."  :0315[1]
    sta z_b                                                           ; 3117: 85 23       .#  :0317[1]   ; number of characters to show on screen
    inc z_b                                                           ; 3119: e6 23       .#  :0319[1]
    lda #screen_width_g-1                                             ; 311b: a9 1f       ..  :031b[1]   ; see if some characters are being skipped
    sec                                                               ; 311d: 38          8   :031d[1]
    sbc z_c                                                           ; 311e: e5 22       ."  :031e[1]
    bcs show_scrolling_message                                        ; 3120: b0 0d       ..  :0320[1]
    lda #screen_width_g                                               ; 3122: a9 20       .   :0322[1]   ; we're showing all the characters
    sta z_b                                                           ; 3124: 85 23       .#  :0324[1]
    lda z_c                                                           ; 3126: a5 22       ."  :0326[1]
    sec                                                               ; 3128: 38          8   :0328[1]
    sbc #screen_width_g-1                                             ; 3129: e9 1f       ..  :0329[1]
    sta z_e                                                           ; 312b: 85 24       .$  :032b[1]   ; number of characters to skip
    lda #0                                                            ; 312d: a9 00       ..  :032d[1]
.show_scrolling_message
    tax                                                               ; 312f: aa          .   :032f[1]
    ldy #screen_height_g-1                                            ; 3130: a0 17       ..  :0330[1]
    jsr set_cursor_xy                                                 ; 3132: 20 68 18     h. :0332[1]
    lda #<attribution_message                                         ; 3135: a9 56       .V  :0335[1]
    sta z_l                                                           ; 3137: 85 20       .   :0337[1]
    lda #>attribution_message                                         ; 3139: a9 14       ..  :0339[1]
    sta z_h                                                           ; 313b: 85 21       .!  :033b[1]
    lda #0                                                            ; 313d: a9 00       ..  :033d[1]
    sta z_d                                                           ; 313f: 85 25       .%  :033f[1]
    jsr add_hl_de                                                     ; 3141: 20 e5 0e     .. :0341[1]   ; skip characters we're past showing
    jsr dec_hl                                                        ; 3144: 20 cf 0e     .. :0344[1]
    ldy #0                                                            ; 3147: a0 00       ..  :0347[1]
    lda (z_l),y                                                       ; 3149: b1 20       .   :0349[1]
    cmp #&ff                                                          ; 314b: c9 ff       ..  :034b[1]
    bne text_no_reset                                                 ; 314d: d0 03       ..  :034d[1]
    jmp restart_scrolling_message                                     ; 314f: 4c ca 02    L.. :034f[1]

.text_no_reset
    jsr inc_hl                                                        ; 3152: 20 bd 0e     .. :0352[1]
    ldx z_b                                                           ; 3155: a6 23       .#  :0355[1]
.text_next_char
    ldy #0                                                            ; 3157: a0 00       ..  :0357[1]
    lda (z_l),y                                                       ; 3159: b1 20       .   :0359[1]
    cmp #&ff                                                          ; 315b: c9 ff       ..  :035b[1]
    php                                                               ; 315d: 08          .   :035d[1]
    jsr inc_hl                                                        ; 315e: 20 bd 0e     .. :035e[1]
    plp                                                               ; 3161: 28          (   :0361[1]
    bne not_at_end_of_message                                         ; 3162: d0 05       ..  :0362[1]
    jsr dec_hl                                                        ; 3164: 20 cf 0e     .. :0364[1]
    lda #' '                                                          ; 3167: a9 20       .   :0367[1]   ; If we've reached the end of the string, pad it out with spaces
.not_at_end_of_message
    tay                                                               ; 3169: a8          .   :0369[1]
    lda z_c                                                           ; 316a: a5 22       ."  :036a[1]
    pha                                                               ; 316c: 48          H   :036c[1]
    lda z_b                                                           ; 316d: a5 23       .#  :036d[1]
    pha                                                               ; 316f: 48          H   :036f[1]
    tya                                                               ; 3170: 98          .   :0370[1]
    jsr print_char                                                    ; 3171: 20 6f 18     o. :0371[1]   ; show the character
    pla                                                               ; 3174: 68          h   :0374[1]
    sta z_b                                                           ; 3175: 85 23       .#  :0375[1]
    pla                                                               ; 3177: 68          h   :0377[1]
    sta z_c                                                           ; 3178: 85 22       ."  :0378[1]
    dex                                                               ; 317a: ca          .   :037a[1]
    bne text_next_char                                                ; 317b: d0 da       ..  :037b[1]
    inc z_c                                                           ; 317d: e6 22       ."  :037d[1]
    lda z_c                                                           ; 317f: a5 22       ."  :037f[1]
    pha                                                               ; 3181: 48          H   :0381[1]
    lda z_b                                                           ; 3182: a5 23       .#  :0382[1]
    pha                                                               ; 3184: 48          H   :0384[1]
    inc random_seed                                                   ; 3185: ee 11 36    ..6 :0385[1]
    jsr read_both_controls                                            ; 3188: 20 f1 16     .. :0388[1]
    pla                                                               ; 318b: 68          h   :038b[1]
    sta z_b                                                           ; 318c: 85 23       .#  :038c[1]
    pla                                                               ; 318e: 68          h   :038e[1]
    sta z_c                                                           ; 318f: 85 22       ."  :038f[1]
    lda z_h                                                           ; 3191: a5 21       .!  :0391[1]
    ora #keymap_any_fire                                              ; 3193: 09 cf       ..  :0393[1]
    cmp #&ff                                                          ; 3195: c9 ff       ..  :0395[1]
    bne new_game                                                      ; 3197: d0 03       ..  :0397[1]   ; wait until fire is pressed
    jmp scrolling_message_loop                                        ; 3199: 4c ce 02    L.. :0399[1]   ; update the scrolling text

.new_game
    jsr cls                                                           ; 319c: 20 4f 18     O. :039c[1]
; set the number of lives to 3
    lda #3                                                            ; 319f: a9 03       ..  :039f[1]
    sta lives                                                         ; 31a1: 8d 1e 36    ..6 :03a1[1]
    lda #<score                                                       ; 31a4: a9 20       .   :03a4[1]
    sta z_l                                                           ; 31a6: 85 20       .   :03a6[1]
    lda #>score                                                       ; 31a8: a9 36       .6  :03a8[1]
    sta z_h                                                           ; 31aa: 85 21       .!  :03aa[1]
    ldy #4                                                            ; 31ac: a0 04       ..  :03ac[1]
    lda #0                                                            ; 31ae: a9 00       ..  :03ae[1]
.reset_score
    sta (z_l),y                                                       ; 31b0: 91 20       .   :03b0[1]
    dey                                                               ; 31b2: 88          .   :03b2[1]
    bne reset_score                                                   ; 31b3: d0 fb       ..  :03b3[1]
.new_game_round
    jsr force_repaint                                                 ; 31b5: 20 5c 0c     \. :03b5[1]   ; reset tile_map2, so everything redraws
    jsr clear_screen                                                  ; 31b8: 20 4f 0c     O. :03b8[1]   ; zero tile array
    jsr repaint_screen                                                ; 31bb: 20 72 0c     r. :03bb[1]   ; repaint screen
    lda #screen_width_g / 2                                           ; 31be: a9 10       ..  :03be[1]   ; centre the player
    sta playerX1                                                      ; 31c0: 8d 10 36    ..6 :03c0[1]
    sta bulletX1                                                      ; 31c3: 8d 15 36    ..6 :03c3[1]
    lda #screen_height_g / 2                                          ; 31c6: a9 0c       ..  :03c6[1]
    sta playerY1                                                      ; 31c8: 8d 12 36    ..6 :03c8[1]
    sta bulletY1                                                      ; 31cb: 8d 17 36    ..6 :03cb[1]
    lda #4                                                            ; 31ce: a9 04       ..  :03ce[1]   ; aim player left
    sta player_dir                                                    ; 31d0: 8d 14 36    ..6 :03d0[1]
    sta bullet_dir                                                    ; 31d3: 8d 1a 36    ..6 :03d3[1]
    lda #2                                                            ; 31d6: a9 02       ..  :03d6[1]   ; start the game with fast growth
    sta allowed_fast_growth                                           ; 31d8: 8d 19 36    ..6 :03d8[1]
    jsr create_invader                                                ; 31db: 20 a9 07     .. :03db[1]   ; create two invaders at the start of the game
    jsr create_invader                                                ; 31de: 20 a9 07     .. :03de[1]
    lda #0                                                            ; 31e1: a9 00       ..  :03e1[1]
    sta game_tick                                                     ; 31e3: 8d 1d 36    ..6 :03e3[1]   ; reset_game_ticks
.game_loop
    jsr get_random                                                    ; 31e6: 20 3a 09     :. :03e6[1]   ; pull a random number
    and #%11111110                                                    ; 31e9: 29 fe       ).  :03e9[1]   ; invader/descender happens 1 in 128
    cmp #192                                                          ; 31eb: c9 c0       ..  :03eb[1]
    bne game_loop_b                                                   ; 31ed: d0 03       ..  :03ed[1]
    jsr create_invader                                                ; 31ef: 20 a9 07     .. :03ef[1]
.game_loop_b
    cmp #128                                                          ; 31f2: c9 80       ..  :03f2[1]
    bne game_loop_c                                                   ; 31f4: d0 03       ..  :03f4[1]
    jsr create_descender                                              ; 31f6: 20 83 07     .. :03f6[1]
.game_loop_c
    lda fast_growth                                                   ; 31f9: ad 13 36    ..6 :03f9[1]
    beq no_fast_growth                                                ; 31fc: f0 06       ..  :03fc[1]   ; if fast_growth counter is >0 then we grow every frame
    dec fast_growth                                                   ; 31fe: ce 13 36    ..6 :03fe[1]
    jmp do_game_evolve                                                ; 3201: 4c 0e 04    L.. :0401[1]

.no_fast_growth
    lda game_tick                                                     ; 3204: ad 1d 36    ..6 :0404[1]
    inc game_tick                                                     ; 3207: ee 1d 36    ..6 :0407[1]
    and #%00111111                                                    ; 320a: 29 3f       )?  :040a[1]   ; frequency of evolution
    bne do_game_move                                                  ; 320c: d0 06       ..  :040c[1]
.do_game_evolve
    jsr mould_evolve                                                  ; 320e: 20 ff 09     .. :040e[1]   ; evolve the mould
    jmp process_player                                                ; 3211: 4c 21 04    L!. :0411[1]

.do_game_move
    and #%00000001                                                    ; 3214: 29 01       ).  :0414[1]
    bne do_game_pause                                                 ; 3216: d0 06       ..  :0416[1]
    jsr mould_move                                                    ; 3218: 20 c5 0a     .. :0418[1]   ; move the mould
    jmp process_player                                                ; 321b: 4c 21 04    L!. :041b[1]

.do_game_pause
    jsr force_animate                                                 ; 321e: 20 fb 0b     .. :041e[1]
.process_player
    jsr repaint_screen                                                ; 3221: 20 72 0c     r. :0421[1]
    ldx #0                                                            ; 3224: a2 00       ..  :0424[1]   ; print score on top left
    ldy #0                                                            ; 3226: a0 00       ..  :0426[1]
    jsr set_cursor_xy                                                 ; 3228: 20 68 18     h. :0428[1]
    lda #<score                                                       ; 322b: a9 20       .   :042b[1]
    sta z_e                                                           ; 322d: 85 24       .$  :042d[1]
    lda #>score                                                       ; 322f: a9 36       .6  :042f[1]
    sta z_d                                                           ; 3231: 85 25       .%  :0431[1]
    ldx #4                                                            ; 3233: a2 04       ..  :0433[1]
    jsr print_X_bcd_bytes                                             ; 3235: 20 3a 17     :. :0435[1]
    ldx #screen_width_g - 2                                           ; 3238: a2 1e       ..  :0438[1]   ; print lives on top right
    ldy #0                                                            ; 323a: a0 00       ..  :043a[1]
    jsr set_cursor_xy                                                 ; 323c: 20 68 18     h. :043c[1]
    lda #'L'                                                          ; 323f: a9 4c       .L  :043f[1]
    jsr print_char                                                    ; 3241: 20 6f 18     o. :0441[1]
    lda lives                                                         ; 3244: ad 1e 36    ..6 :0444[1]
    clc                                                               ; 3247: 18          .   :0447[1]
    adc #'0'                                                          ; 3248: 69 30       i0  :0448[1]
    jsr print_char                                                    ; 324a: 20 6f 18     o. :044a[1]
    lda nothing_shot                                                  ; 324d: ad 16 36    ..6 :044d[1]   ; is the player busy?
    clc                                                               ; 3250: 18          .   :0450[1]
    adc #1                                                            ; 3251: 69 01       i.  :0451[1]
    and #%00011111                                                    ; 3253: 29 1f       ).  :0453[1]
    cmp #31                                                           ; 3255: c9 1f       ..  :0455[1]
    bcc player_active                                                 ; 3257: 90 10       ..  :0457[1]
    jsr create_invader                                                ; 3259: 20 a9 07     .. :0459[1]   ; player is slacking, so lets spawn some stuff
    jsr create_invader                                                ; 325c: 20 a9 07     .. :045c[1]
    jsr create_descender                                              ; 325f: 20 83 07     .. :045f[1]
    lda #2                                                            ; 3262: a9 02       ..  :0462[1]
    sta allowed_fast_growth                                           ; 3264: 8d 19 36    ..6 :0464[1]   ; fast grow the mould for a few frames
    lda #0                                                            ; 3267: a9 00       ..  :0467[1]
.player_active
    sta nothing_shot                                                  ; 3269: 8d 16 36    ..6 :0469[1]
    lda playerX1                                                      ; 326c: ad 10 36    ..6 :046c[1]   ; read in the current player location to BC
    sta z_b                                                           ; 326f: 85 23       .#  :046f[1]
    lda playerY1                                                      ; 3271: ad 12 36    ..6 :0471[1]
    sta z_c                                                           ; 3274: 85 22       ."  :0474[1]
    jsr find_tile                                                     ; 3276: 20 f3 0c     .. :0476[1]   ; get the tile location of the player, we need this to check if the player is alive. If the player is surrounded on UDLR then the player is dead
    ldy #0                                                            ; 3279: a0 00       ..  :0479[1]
    lda z_b                                                           ; 327b: a5 23       .#  :047b[1]
    cmp #0                                                            ; 327d: c9 00       ..  :047d[1]
    beq player_far_left                                               ; 327f: f0 0a       ..  :047f[1]   ; player is at far left, we can't check that direction
    dec z_l                                                           ; 3281: c6 20       .   :0481[1]
    lda (z_l),y                                                       ; 3283: b1 20       .   :0483[1]
    cmp #8                                                            ; 3285: c9 08       ..  :0485[1]
    bcc player_still_alive                                            ; 3287: 90 41       .A  :0487[1]   ; player is not surrounded on left
    inc z_l                                                           ; 3289: e6 20       .   :0489[1]
.player_far_left
    inc z_l                                                           ; 328b: e6 20       .   :048b[1]
    lda z_b                                                           ; 328d: a5 23       .#  :048d[1]
    cmp #screen_width_g - 1                                           ; 328f: c9 1f       ..  :048f[1]
    beq player_far_right                                              ; 3291: f0 06       ..  :0491[1]   ; player is far right, we can't check that direction
    lda (z_l),y                                                       ; 3293: b1 20       .   :0493[1]
    cmp #8                                                            ; 3295: c9 08       ..  :0495[1]
    bcc player_still_alive                                            ; 3297: 90 31       .1  :0497[1]   ; player is not surrounded on the right
.player_far_right
    lda #<(65536-33)                                                  ; 3299: a9 df       ..  :0499[1]
    sta z_e                                                           ; 329b: 85 24       .$  :049b[1]
    lda #>(65536-33)                                                  ; 329d: a9 ff       ..  :049d[1]
    sta z_d                                                           ; 329f: 85 25       .%  :049f[1]
    jsr add_hl_de                                                     ; 32a1: 20 e5 0e     .. :04a1[1]
    lda z_c                                                           ; 32a4: a5 22       ."  :04a4[1]
    cmp #0                                                            ; 32a6: c9 00       ..  :04a6[1]
    beq player_far_top                                                ; 32a8: f0 06       ..  :04a8[1]   ; player is at top of screem we can't check that direction
    lda (z_l),y                                                       ; 32aa: b1 20       .   :04aa[1]
    cmp #8                                                            ; 32ac: c9 08       ..  :04ac[1]
    bcc player_still_alive                                            ; 32ae: 90 1a       ..  :04ae[1]   ; player is not surrounded at the top
.player_far_top
    lda #<64                                                          ; 32b0: a9 40       .@  :04b0[1]
    sta z_e                                                           ; 32b2: 85 24       .$  :04b2[1]
    lda #>64                                                          ; 32b4: a9 00       ..  :04b4[1]
    sta z_d                                                           ; 32b6: 85 25       .%  :04b6[1]
    jsr add_hl_de                                                     ; 32b8: 20 e5 0e     .. :04b8[1]
    lda z_c                                                           ; 32bb: a5 22       ."  :04bb[1]
    cmp #screen_height_g - 1                                          ; 32bd: c9 17       ..  :04bd[1]
    beq player_far_bottom                                             ; 32bf: f0 06       ..  :04bf[1]   ; player is at bottom of screen, we can't check that direction
    lda (z_l),y                                                       ; 32c1: b1 20       .   :04c1[1]
    cmp #8                                                            ; 32c3: c9 08       ..  :04c3[1]
    bcc player_still_alive                                            ; 32c5: 90 03       ..  :04c5[1]   ; player is not surrounded from bottom
.player_far_bottom
    jmp player_dead                                                   ; 32c7: 4c df 07    L.. :04c7[1]   ; player is dead!

.player_still_alive
    jsr read_both_controls                                            ; 32ca: 20 f1 16     .. :04ca[1]   ; read both the keyboard [missing!] and joystick controls
    lda player_dir                                                    ; 32cd: ad 14 36    ..6 :04cd[1]
    sta z_l                                                           ; 32d0: 85 20       .   :04d0[1]   ; load the player direction into L (UDLR=1234)
    lda #0                                                            ; 32d2: a9 00       ..  :04d2[1]
    sta playing_sfx                                                   ; 32d4: 8d 1b 36    ..6 :04d4[1]   ; reset the sound effects
    lda control_mode                                                  ; 32d7: ad 1c 36    ..6 :04d7[1]   ; check the control mode (1fire 2fire)
    and #%00000001                                                    ; 32da: 29 01       ).  :04da[1]
    bne control_mode_2_fire                                           ; 32dc: d0 6b       .k  :04dc[1]
; ****************************************
; Single fire mode (1 firebutton)
; ****************************************
.f1_control_mode_1_fire
    lda z_h                                                           ; 32de: a5 21       .!  :04de[1]   ; 1fire mode
    bit keymap_U                                                      ; 32e0: 2c 19 0e    ,.. :04e0[1]
    bne F1_player_not_up_b                                            ; 32e3: d0 14       ..  :04e3[1]
    bit keymap_F1                                                     ; 32e5: 2c 1d 0e    ,.. :04e5[1]   ; up button is pressed
    beq fire_face_up                                                  ; 32e8: f0 09       ..  :04e8[1]
    lda z_c                                                           ; 32ea: a5 22       ."  :04ea[1]
    beq F1_player_not_up                                              ; 32ec: f0 09       ..  :04ec[1]
    dec z_c                                                           ; 32ee: c6 22       ."  :04ee[1]   ; move player up
    jmp F1_player_not_up                                              ; 32f0: 4c f7 04    L.. :04f0[1]

.fire_face_up
    lda #1                                                            ; 32f3: a9 01       ..  :04f3[1]   ; set fire direction to up
    sta z_l                                                           ; 32f5: 85 20       .   :04f5[1]
.F1_player_not_up
    lda z_h                                                           ; 32f7: a5 21       .!  :04f7[1]
.F1_player_not_up_b
    bit keymap_D                                                      ; 32f9: 2c 1a 0e    ,.. :04f9[1]
    bne F1_player_not_down_b                                          ; 32fc: d0 16       ..  :04fc[1]
    bit keymap_F1                                                     ; 32fe: 2c 1d 0e    ,.. :04fe[1]   ; down button pressed
    beq fire_face_down                                                ; 3301: f0 0b       ..  :0501[1]
    lda z_c                                                           ; 3303: a5 22       ."  :0503[1]
    cmp #screen_height_g-1                                            ; 3305: c9 17       ..  :0505[1]
    beq F1_player_not_down                                            ; 3307: f0 09       ..  :0507[1]
    inc z_c                                                           ; 3309: e6 22       ."  :0509[1]   ; move player down
    jmp F1_player_not_down                                            ; 330b: 4c 12 05    L.. :050b[1]

.fire_face_down
    lda #3                                                            ; 330e: a9 03       ..  :050e[1]   ; set fire direction to down
    sta z_l                                                           ; 3310: 85 20       .   :0510[1]
.F1_player_not_down
    lda z_h                                                           ; 3312: a5 21       .!  :0512[1]
.F1_player_not_down_b
    bit keymap_L                                                      ; 3314: 2c 1b 0e    ,.. :0514[1]
    bne F1_player_not_left_b                                          ; 3317: d0 14       ..  :0517[1]
    bit keymap_F1                                                     ; 3319: 2c 1d 0e    ,.. :0519[1]   ; left button pressed
    beq fire_face_left                                                ; 331c: f0 09       ..  :051c[1]
    lda z_b                                                           ; 331e: a5 23       .#  :051e[1]
    beq F1_player_not_left                                            ; 3320: f0 09       ..  :0520[1]
    dec z_b                                                           ; 3322: c6 23       .#  :0522[1]   ; move player left
    jmp F1_player_not_left                                            ; 3324: 4c 2b 05    L+. :0524[1]

.fire_face_left
    lda #4                                                            ; 3327: a9 04       ..  :0527[1]
    sta z_l                                                           ; 3329: 85 20       .   :0529[1]
.F1_player_not_left
    lda z_h                                                           ; 332b: a5 21       .!  :052b[1]
.F1_player_not_left_b
    bit keymap_R                                                      ; 332d: 2c 1c 0e    ,.. :052d[1]
    bne F1_player_not_right                                           ; 3330: d0 14       ..  :0530[1]
    bit keymap_F1                                                     ; 3332: 2c 1d 0e    ,.. :0532[1]   ; right button pressed
    beq fire_face_right                                               ; 3335: f0 0b       ..  :0535[1]
    lda z_b                                                           ; 3337: a5 23       .#  :0537[1]
    cmp #&1f                                                          ; 3339: c9 1f       ..  :0539[1]
    beq F1_player_not_right                                           ; 333b: f0 09       ..  :053b[1]
    inc z_b                                                           ; 333d: e6 23       .#  :053d[1]   ; move player right
    jmp F1_player_not_right                                           ; 333f: 4c 46 05    LF. :053f[1]

.fire_face_right
    lda #2                                                            ; 3342: a9 02       ..  :0542[1]
    sta z_l                                                           ; 3344: 85 20       .   :0544[1]
.F1_player_not_right
    jmp player_not_fire2                                              ; 3346: 4c bf 05    L.. :0546[1]   ; continue control processing

; ****************************************
; alt fire mode (2 firebutton)
; ****************************************
.control_mode_2_fire
    lda debounce_count                                                ; 3349: ad 29 36    .)6 :0549[1]
    beq debounce_check                                                ; 334c: f0 06       ..  :054c[1]
    dec debounce_count                                                ; 334e: ce 29 36    .)6 :054e[1]
    jmp player_not_pause                                              ; 3351: 4c 0a 06    L.. :0551[1]

.debounce_check
    lda z_h                                                           ; 3354: a5 21       .!  :0554[1]
    ora #keymap_any_fire                                              ; 3356: 09 cf       ..  :0556[1]
    cmp #&ff                                                          ; 3358: c9 ff       ..  :0558[1]
    beq debounce_ok                                                   ; 335a: f0 05       ..  :055a[1]
    lda #2                                                            ; 335c: a9 02       ..  :055c[1]
    sta debounce_count                                                ; 335e: 8d 29 36    .)6 :055e[1]   ; stop keys repeating too fast
.debounce_ok
    lda z_h                                                           ; 3361: a5 21       .!  :0561[1]
    bit keymap_U                                                      ; 3363: 2c 19 0e    ,.. :0563[1]
    bne player_not_up_b                                               ; 3366: d0 08       ..  :0566[1]
    lda z_c                                                           ; 3368: a5 22       ."  :0568[1]
    beq player_not_up                                                 ; 336a: f0 02       ..  :056a[1]
    dec z_c                                                           ; 336c: c6 22       ."  :056c[1]   ; move player up
.player_not_up
    lda z_h                                                           ; 336e: a5 21       .!  :056e[1]
.player_not_up_b
    bit keymap_D                                                      ; 3370: 2c 1a 0e    ,.. :0570[1]
    bne player_not_down_b                                             ; 3373: d0 0a       ..  :0573[1]
    lda z_c                                                           ; 3375: a5 22       ."  :0575[1]
    cmp #screen_height_g - 1                                          ; 3377: c9 17       ..  :0577[1]
    beq player_not_down                                               ; 3379: f0 02       ..  :0579[1]
    inc z_c                                                           ; 337b: e6 22       ."  :057b[1]   ; move player down
.player_not_down
    lda z_h                                                           ; 337d: a5 21       .!  :057d[1]
.player_not_down_b
    bit keymap_L                                                      ; 337f: 2c 1b 0e    ,.. :057f[1]
    bne player_not_left                                               ; 3382: d0 06       ..  :0582[1]
    lda z_b                                                           ; 3384: a5 23       .#  :0584[1]
    beq player_not_left                                               ; 3386: f0 02       ..  :0586[1]
    dec z_b                                                           ; 3388: c6 23       .#  :0588[1]   ; move player left
.player_not_left
    lda z_h                                                           ; 338a: a5 21       .!  :058a[1]
    bit keymap_R                                                      ; 338c: 2c 1c 0e    ,.. :058c[1]
    bne player_not_right_b                                            ; 338f: d0 0a       ..  :058f[1]
    lda z_b                                                           ; 3391: a5 23       .#  :0591[1]
    cmp #screen_width_g - 1                                           ; 3393: c9 1f       ..  :0593[1]
    beq player_not_right                                              ; 3395: f0 02       ..  :0595[1]
    inc z_b                                                           ; 3397: e6 23       .#  :0597[1]   ; move player right
.player_not_right
    lda z_h                                                           ; 3399: a5 21       .!  :0599[1]
.player_not_right_b
    bit keymap_F1                                                     ; 339b: 2c 1d 0e    ,.. :059b[1]
    bne player_not_fire_b                                             ; 339e: d0 0d       ..  :059e[1]
    lda z_l                                                           ; 33a0: a5 20       .   :05a0[1]   ; rotate player left
    sec                                                               ; 33a2: 38          8   :05a2[1]
    sbc #1                                                            ; 33a3: e9 01       ..  :05a3[1]
    bne player_dir_reset                                              ; 33a5: d0 02       ..  :05a5[1]
    lda #4                                                            ; 33a7: a9 04       ..  :05a7[1]
.player_dir_reset
    sta z_l                                                           ; 33a9: 85 20       .   :05a9[1]
.player_not_fire
    lda z_h                                                           ; 33ab: a5 21       .!  :05ab[1]
.player_not_fire_b
    bit keymap_F2                                                     ; 33ad: 2c 1e 0e    ,.. :05ad[1]
    bne player_not_fire2                                              ; 33b0: d0 0d       ..  :05b0[1]
    lda z_l                                                           ; 33b2: a5 20       .   :05b2[1]   ; rotate player right
    clc                                                               ; 33b4: 18          .   :05b4[1]
    adc #1                                                            ; 33b5: 69 01       i.  :05b5[1]
    cmp #5                                                            ; 33b7: c9 05       ..  :05b7[1]
    bne player_dir_reset2                                             ; 33b9: d0 02       ..  :05b9[1]
    lda #1                                                            ; 33bb: a9 01       ..  :05bb[1]
.player_dir_reset2
    sta z_l                                                           ; 33bd: 85 20       .   :05bd[1]
; ***************************************
; This section is used by both control modes
; ***************************************
.player_not_fire2
    lda z_h                                                           ; 33bf: a5 21       .!  :05bf[1]
    bit keymap_F3                                                     ; 33c1: 2c 1f 0e    ,.. :05c1[1]
    bne player_not_fire3                                              ; 33c4: d0 0d       ..  :05c4[1]
    lda control_mode                                                  ; 33c6: ad 1c 36    ..6 :05c6[1]   ; Fire 3 (enter) swaps control modes
    eor #&ff                                                          ; 33c9: 49 ff       I.  :05c9[1]
    sta control_mode                                                  ; 33cb: 8d 1c 36    ..6 :05cb[1]
    jsr debounce                                                      ; 33ce: 20 ca 0b     .. :05ce[1]   ; wait for fire to be released
    lda z_h                                                           ; 33d1: a5 21       .!  :05d1[1]
.player_not_fire3
    and #keymap_pause                                                 ; 33d3: 29 80       ).  :05d3[1]
    bne player_not_pause                                              ; 33d5: d0 33       .3  :05d5[1]
    lda z_c                                                           ; 33d7: a5 22       ."  :05d7[1]
    pha                                                               ; 33d9: 48          H   :05d9[1]
    lda z_b                                                           ; 33da: a5 23       .#  :05da[1]
    pha                                                               ; 33dc: 48          H   :05dc[1]
    lda z_l                                                           ; 33dd: a5 20       .   :05dd[1]
    pha                                                               ; 33df: 48          H   :05df[1]
    lda z_h                                                           ; 33e0: a5 21       .!  :05e0[1]
    pha                                                               ; 33e2: 48          H   :05e2[1]

    ; show the paused message
    ldx #screen_width_g/2-3                                           ; 33e3: a2 0d       ..  :05e3[1]
    ldy #screen_height_g/2                                            ; 33e5: a0 0c       ..  :05e5[1]
    jsr set_cursor_xy                                                 ; 33e7: 20 68 18     h. :05e7[1]
    lda #<paused_message                                              ; 33ea: a9 52       .R  :05ea[1]
    sta z_l                                                           ; 33ec: 85 20       .   :05ec[1]
    lda #>paused_message                                              ; 33ee: a9 15       ..  :05ee[1]
    sta z_h                                                           ; 33f0: 85 21       .!  :05f0[1]
    jsr print_message_hl                                              ; 33f2: 20 4f 0e     O. :05f2[1]
    jsr wait_for_fire                                                 ; 33f5: 20 e0 0b     .. :05f5[1]   ; wait for player to press fire
    jsr force_repaint                                                 ; 33f8: 20 5c 0c     \. :05f8[1]
    jsr repaint_screen                                                ; 33fb: 20 72 0c     r. :05fb[1]
    pla                                                               ; 33fe: 68          h   :05fe[1]
    sta z_h                                                           ; 33ff: 85 21       .!  :05ff[1]
    pla                                                               ; 3401: 68          h   :0601[1]
    sta z_l                                                           ; 3402: 85 20       .   :0602[1]
    pla                                                               ; 3404: 68          h   :0604[1]
    sta z_b                                                           ; 3405: 85 23       .#  :0605[1]
    pla                                                               ; 3407: 68          h   :0607[1]
    sta z_c                                                           ; 3408: 85 22       ."  :0608[1]
.player_not_pause
    lda player_dir                                                    ; 340a: ad 14 36    ..6 :060a[1]   ; check if we need to update the player sprite
    cmp z_l                                                           ; 340d: c5 20       .   :060d[1]
    bne player_moved                                                  ; 340f: d0 11       ..  :060f[1]
    lda playerX1                                                      ; 3411: ad 10 36    ..6 :0611[1]
    cmp z_b                                                           ; 3414: c5 23       .#  :0614[1]
    bne player_moved                                                  ; 3416: d0 0a       ..  :0616[1]
    lda playerY1                                                      ; 3418: ad 12 36    ..6 :0618[1]
    cmp z_c                                                           ; 341b: c5 22       ."  :061b[1]
    bne player_moved                                                  ; 341d: d0 03       ..  :061d[1]
    jmp player_unmoved                                                ; 341f: 4c 5c 06    L\. :061f[1]   ; player position/direction unchanged

.player_moved
    lda z_l                                                           ; 3422: a5 20       .   :0622[1]
    sta player_dir                                                    ; 3424: 8d 14 36    ..6 :0624[1]
    jsr find_tile                                                     ; 3427: 20 f3 0c     .. :0627[1]
    ldy #0                                                            ; 342a: a0 00       ..  :062a[1]
    lda (z_l),y                                                       ; 342c: b1 20       .   :062c[1]   ; check if direction player wants to move is empty
    bne player_unmoved                                                ; 342e: d0 2c       .,  :062e[1]
    lda z_c                                                           ; 3430: a5 22       ."  :0630[1]
    pha                                                               ; 3432: 48          H   :0632[1]
    lda z_b                                                           ; 3433: a5 23       .#  :0633[1]
    pha                                                               ; 3435: 48          H   :0635[1]
    lda playerX1                                                      ; 3436: ad 10 36    ..6 :0636[1]   ; update player location
    sta z_b                                                           ; 3439: 85 23       .#  :0639[1]
    lda playerY1                                                      ; 343b: ad 12 36    ..6 :063b[1]
    sta z_c                                                           ; 343e: 85 22       ."  :063e[1]
    jsr find_tile                                                     ; 3440: 20 f3 0c     .. :0640[1]
    lda #0                                                            ; 3443: a9 00       ..  :0643[1]   ; clear player sprite from old location
    ldy #0                                                            ; 3445: a0 00       ..  :0645[1]
    sta (z_l),y                                                       ; 3447: 91 20       .   :0647[1]
    jsr render_tile                                                   ; 3449: 20 10 0d     .. :0649[1]
    pla                                                               ; 344c: 68          h   :064c[1]
    sta z_b                                                           ; 344d: 85 23       .#  :064d[1]
    pla                                                               ; 344f: 68          h   :064f[1]
    sta z_c                                                           ; 3450: 85 22       ."  :0650[1]
    lda z_b                                                           ; 3452: a5 23       .#  :0652[1]
    sta playerX1                                                      ; 3454: 8d 10 36    ..6 :0654[1]
    lda z_c                                                           ; 3457: a5 22       ."  :0657[1]
    sta playerY1                                                      ; 3459: 8d 12 36    ..6 :0659[1]
.player_unmoved
    lda bulletX1                                                      ; 345c: ad 15 36    ..6 :065c[1]   ; get current bullet location
    sta z_b                                                           ; 345f: 85 23       .#  :065f[1]
    lda bulletY1                                                      ; 3461: ad 17 36    ..6 :0661[1]
    sta z_c                                                           ; 3464: 85 22       ."  :0664[1]
    jsr find_tile                                                     ; 3466: 20 f3 0c     .. :0666[1]
    lda #0                                                            ; 3469: a9 00       ..  :0669[1]   ; clear current bullet sprite
    ldy #0                                                            ; 346b: a0 00       ..  :066b[1]
    sta (z_l),y                                                       ; 346d: 91 20       .   :066d[1]
    jsr render_tile                                                   ; 346f: 20 10 0d     .. :066f[1]
    lda #4                                                            ; 3472: a9 04       ..  :0672[1]
    sta z_ixl                                                         ; 3474: 85 28       .(  :0674[1]
.bullet_recalc
    lda bullet_dir                                                    ; 3476: ad 1a 36    ..6 :0676[1]   ; bullet direction
    cmp #1                                                            ; 3479: c9 01       ..  :0679[1]
    beq bullet_up                                                     ; 347b: f0 0c       ..  :067b[1]
    cmp #2                                                            ; 347d: c9 02       ..  :067d[1]
    beq bullet_right                                                  ; 347f: f0 17       ..  :067f[1]
    cmp #3                                                            ; 3481: c9 03       ..  :0681[1]
    beq bullet_down                                                   ; 3483: f0 09       ..  :0683[1]
    cmp #4                                                            ; 3485: c9 04       ..  :0685[1]
    beq bullet_left                                                   ; 3487: f0 0a       ..  :0687[1]
.bullet_up
    dec z_c                                                           ; 3489: c6 22       ."  :0689[1]   ; up
    jmp bullet_check                                                  ; 348b: 4c 9a 06    L.. :068b[1]

.bullet_down
    inc z_c                                                           ; 348e: e6 22       ."  :068e[1]   ; down
    jmp bullet_check                                                  ; 3490: 4c 9a 06    L.. :0690[1]

.bullet_left
    dec z_b                                                           ; 3493: c6 23       .#  :0693[1]   ; left
    jmp bullet_check                                                  ; 3495: 4c 9a 06    L.. :0695[1]

.bullet_right
    inc z_b                                                           ; 3498: e6 23       .#  :0698[1]   ; right
.bullet_check
    lda z_b                                                           ; 349a: a5 23       .#  :069a[1]
    cmp #screen_width_g                                               ; 349c: c9 20       .   :069c[1]
    bcs bullet_restart                                                ; 349e: b0 16       ..  :069e[1]   ; if bullet has gone off screen we need to make a new one
    lda z_c                                                           ; 34a0: a5 22       ."  :06a0[1]
    cmp #screen_height_g                                              ; 34a2: c9 18       ..  :06a2[1]
    bcs bullet_restart                                                ; 34a4: b0 10       ..  :06a4[1]
    jsr find_tile                                                     ; 34a6: 20 f3 0c     .. :06a6[1]
    ldy #0                                                            ; 34a9: a0 00       ..  :06a9[1]
    lda (z_l),y                                                       ; 34ab: b1 20       .   :06ab[1]
    bne bullet_strike                                                 ; 34ad: d0 4d       .M  :06ad[1]
    dec z_ixl                                                         ; 34af: c6 28       .(  :06af[1]
    bne bullet_recalc                                                 ; 34b1: d0 c3       ..  :06b1[1]   ; move bullet again for next tick
    jmp bullet_draw                                                   ; 34b3: 4c c9 06    L.. :06b3[1]

.bullet_restart
    lda player_dir                                                    ; 34b6: ad 14 36    ..6 :06b6[1]   ; bullet has gone off screen, so create a new one at the player location
    sta bullet_dir                                                    ; 34b9: 8d 1a 36    ..6 :06b9[1]
    lda playerX1                                                      ; 34bc: ad 10 36    ..6 :06bc[1]
    sta z_b                                                           ; 34bf: 85 23       .#  :06bf[1]
    lda playerY1                                                      ; 34c1: ad 12 36    ..6 :06c1[1]
    sta z_c                                                           ; 34c4: 85 22       ."  :06c4[1]
    jsr find_tile                                                     ; 34c6: 20 f3 0c     .. :06c6[1]
.bullet_draw
    lda z_b                                                           ; 34c9: a5 23       .#  :06c9[1]   ; store bullet location
    sta bulletX1                                                      ; 34cb: 8d 15 36    ..6 :06cb[1]
    lda z_c                                                           ; 34ce: a5 22       ."  :06ce[1]
    sta bulletY1                                                      ; 34d0: 8d 17 36    ..6 :06d0[1]
    lda #5                                                            ; 34d3: a9 05       ..  :06d3[1]   ; draw the bullet sprite
    ldy #0                                                            ; 34d5: a0 00       ..  :06d5[1]
    sta (z_l),y                                                       ; 34d7: 91 20       .   :06d7[1]
    jsr render_tile                                                   ; 34d9: 20 10 0d     .. :06d9[1]
    lda playerX1                                                      ; 34dc: ad 10 36    ..6 :06dc[1]   ; reload the player location
    sta z_b                                                           ; 34df: 85 23       .#  :06df[1]
    lda playerY1                                                      ; 34e1: ad 12 36    ..6 :06e1[1]
    sta z_c                                                           ; 34e4: 85 22       ."  :06e4[1]
    jsr find_tile                                                     ; 34e6: 20 f3 0c     .. :06e6[1]
    lda player_dir                                                    ; 34e9: ad 14 36    ..6 :06e9[1]   ; draw the player sprite
    ldy #0                                                            ; 34ec: a0 00       ..  :06ec[1]
    sta (z_l),y                                                       ; 34ee: 91 20       .   :06ee[1]
    jsr render_tile                                                   ; 34f0: 20 10 0d     .. :06f0[1]
    lda playing_sfx                                                   ; 34f3: ad 1b 36    ..6 :06f3[1]   ; play the current sound effect (0=no sound)
    jsr chibi_sound                                                   ; 34f6: 20 12 1a     .. :06f6[1]
    jmp game_loop                                                     ; 34f9: 4c e6 03    L.. :06f9[1]

.bullet_strike
    tax                                                               ; 34fc: aa          .   :06fc[1]   ; players bullet has hit something
    lda z_c                                                           ; 34fd: a5 22       ."  :06fd[1]
    pha                                                               ; 34ff: 48          H   :06ff[1]
    lda z_b                                                           ; 3500: a5 23       .#  :0700[1]
    pha                                                               ; 3502: 48          H   :0702[1]
    ldy #0                                                            ; 3503: a0 00       ..  :0703[1]
    tya                                                               ; 3505: 98          .   :0705[1]   ; A=&00
    sta (z_l),y                                                       ; 3506: 91 20       .   :0706[1]
    jsr render_tile                                                   ; 3508: 20 10 0d     .. :0708[1]   ; remove the enemy from the tilemap
    lda z_l                                                           ; 350b: a5 20       .   :070b[1]
    pha                                                               ; 350d: 48          H   :070d[1]
    lda z_h                                                           ; 350e: a5 21       .!  :070e[1]
    pha                                                               ; 3510: 48          H   :0710[1]
    txa                                                               ; 3511: 8a          .   :0711[1]
    lda #<bcd_1                                                       ; 3512: a9 59       .Y  :0712[1]   ; seeker score
    sta z_l                                                           ; 3514: 85 20       .   :0714[1]
    lda #>bcd_1                                                       ; 3516: a9 15       ..  :0716[1]
    sta z_h                                                           ; 3518: 85 21       .!  :0718[1]
    lda #%10000001                                                    ; 351a: a9 81       ..  :071a[1]   ; seeker sound
    sta z_b                                                           ; 351c: 85 23       .#  :071c[1]
    txa                                                               ; 351e: 8a          .   :071e[1]
    cmp #10                                                           ; 351f: c9 0a       ..  :071f[1]
    beq apply_score                                                   ; 3521: f0 2e       ..  :0721[1]
    lda #<bcd_3                                                       ; 3523: a9 5d       .]  :0723[1]   ; blue mould score
    sta z_l                                                           ; 3525: 85 20       .   :0725[1]
    lda #>bcd_3                                                       ; 3527: a9 15       ..  :0727[1]
    sta z_h                                                           ; 3529: 85 21       .!  :0729[1]
    lda #%10000111                                                    ; 352b: a9 87       ..  :072b[1]   ; blue mould sound
    sta z_b                                                           ; 352d: 85 23       .#  :072d[1]
    txa                                                               ; 352f: 8a          .   :072f[1]
    cmp #9                                                            ; 3530: c9 09       ..  :0730[1]
    beq apply_score                                                   ; 3532: f0 1d       ..  :0732[1]
    lda #<bcd_5                                                       ; 3534: a9 61       .a  :0734[1]   ; green mould score
    sta z_l                                                           ; 3536: 85 20       .   :0736[1]
    lda #>bcd_5                                                       ; 3538: a9 15       ..  :0738[1]
    sta z_h                                                           ; 353a: 85 21       .!  :073a[1]
    lda #%10000111                                                    ; 353c: a9 87       ..  :073c[1]   ; green mould sound
    sta z_b                                                           ; 353e: 85 23       .#  :073e[1]
    txa                                                               ; 3540: 8a          .   :0740[1]
    cmp #8                                                            ; 3541: c9 08       ..  :0741[1]
    beq apply_score                                                   ; 3543: f0 0c       ..  :0743[1]
    lda #<bcd_20                                                      ; 3545: a9 65       .e  :0745[1]   ; invader/descender score
    sta z_l                                                           ; 3547: 85 20       .   :0747[1]
    lda #>bcd_20                                                      ; 3549: a9 15       ..  :0749[1]
    sta z_h                                                           ; 354b: 85 21       .!  :074b[1]
    lda #%10001111                                                    ; 354d: a9 8f       ..  :074d[1]   ; invader/descender sound
    sta z_b                                                           ; 354f: 85 23       .#  :074f[1]
.apply_score
    ldy #0                                                            ; 3551: a0 00       ..  :0751[1]
    lda z_b                                                           ; 3553: a5 23       .#  :0753[1]
    sta playing_sfx                                                   ; 3555: 8d 1b 36    ..6 :0755[1]   ; make a sound
    lda #<score                                                       ; 3558: a9 20       .   :0758[1]
    sta z_e                                                           ; 355a: 85 24       .$  :075a[1]
    lda #>score                                                       ; 355c: a9 36       .6  :075c[1]
    sta z_d                                                           ; 355e: 85 25       .%  :075e[1]
    ldx #4                                                            ; 3560: a2 04       ..  :0760[1]   ; add the score
    jsr bcd_add                                                       ; 3562: 20 56 17     V. :0762[1]
    pla                                                               ; 3565: 68          h   :0765[1]
    sta z_h                                                           ; 3566: 85 21       .!  :0766[1]
    pla                                                               ; 3568: 68          h   :0768[1]
    sta z_l                                                           ; 3569: 85 20       .   :0769[1]
    lda #0                                                            ; 356b: a9 00       ..  :076b[1]
    sta nothing_shot                                                  ; 356d: 8d 16 36    ..6 :076d[1]
    sta allowed_fast_growth                                           ; 3570: 8d 19 36    ..6 :0770[1]   ; player is busy, so stop fast growth
    jsr get_random                                                    ; 3573: 20 3a 09     :. :0773[1]
    pla                                                               ; 3576: 68          h   :0776[1]
    sta z_b                                                           ; 3577: 85 23       .#  :0777[1]
    pla                                                               ; 3579: 68          h   :0779[1]
    sta z_c                                                           ; 357a: 85 22       ."  :077a[1]
    jmp bullet_restart                                                ; 357c: 4c b6 06    L.. :077c[1]

.create_descender_b
    lsr a                                                             ; 357f: 4a          J   :077f[1]
    jmp create_descender_c                                            ; 3580: 4c 86 07    L.. :0780[1]

.create_descender
    jsr get_random                                                    ; 3583: 20 3a 09     :. :0783[1]   ; get a random column
.create_descender_c
    and #%00011111                                                    ; 3586: 29 1f       ).  :0786[1]
    cmp #screen_width_g                                               ; 3588: c9 20       .   :0788[1]
    bcs create_descender                                              ; 358a: b0 f7       ..  :078a[1]   ; get a number 0-screenwidth
    sta z_as                                                          ; 358c: 85 26       .&  :078c[1]
    lda #<tile_map                                                    ; 358e: a9 00       ..  :078e[1]
    sta z_l                                                           ; 3590: 85 20       .   :0790[1]
    lda #>tile_map                                                    ; 3592: a9 30       .0  :0792[1]
    sta z_h                                                           ; 3594: 85 21       .!  :0794[1]
    lda z_l                                                           ; 3596: a5 20       .   :0796[1]
    clc                                                               ; 3598: 18          .   :0798[1]
    adc z_as                                                          ; 3599: 65 26       e&  :0799[1]
    sta z_l                                                           ; 359b: 85 20       .   :079b[1]   ; column number (top of screen)
    lda #12                                                           ; 359d: a9 0c       ..  :079d[1]   ; descender sprite
    ldy #0                                                            ; 359f: a0 00       ..  :079f[1]
    sta (z_l),y                                                       ; 35a1: 91 20       .   :07a1[1]
    tya                                                               ; 35a3: 98          .   :07a3[1]   ; A=&00
    rts                                                               ; 35a4: 60          `   :07a4[1]

    ; unused?
    lsr a                                                             ; 35a5: 4a          J   :07a5[1]
    jmp create_invader_c                                              ; 35a6: 4c ac 07    L.. :07a6[1]

.create_invader
    jsr get_random                                                    ; 35a9: 20 3a 09     :. :07a9[1]   ; gat a random row
.create_invader_c
    and #%00011111                                                    ; 35ac: 29 1f       ).  :07ac[1]
    cmp #screen_height_g                                              ; 35ae: c9 18       ..  :07ae[1]
    bcs create_invader                                                ; 35b0: b0 f7       ..  :07b0[1]   ; get a number 0-screenheight
    sta z_b                                                           ; 35b2: 85 23       .#  :07b2[1]
    lda #<tile_map                                                    ; 35b4: a9 00       ..  :07b4[1]
    sta z_l                                                           ; 35b6: 85 20       .   :07b6[1]
    lda #>tile_map                                                    ; 35b8: a9 30       .0  :07b8[1]
    sta z_h                                                           ; 35ba: 85 21       .!  :07ba[1]
    lda #0                                                            ; 35bc: a9 00       ..  :07bc[1]
    sta z_c                                                           ; 35be: 85 22       ."  :07be[1]
    clc                                                               ; 35c0: 18          .   :07c0[1]
    ror z_b                                                           ; 35c1: 66 23       f#  :07c1[1]   ; multiply by 32 [moved to high byte and shift right 3 times]
    rol z_c                                                           ; 35c3: 26 22       &"  :07c3[1]
    ror z_b                                                           ; 35c5: 66 23       f#  :07c5[1]
    rol z_c                                                           ; 35c7: 26 22       &"  :07c7[1]
    ror z_b                                                           ; 35c9: 66 23       f#  :07c9[1]
    rol z_c                                                           ; 35cb: 26 22       &"  :07cb[1]
    lda #screen_width_g-1                                             ; 35cd: a9 1f       ..  :07cd[1]   ; far right of screen
    ora z_c                                                           ; 35cf: 05 22       ."  :07cf[1]
    sta z_c                                                           ; 35d1: 85 22       ."  :07d1[1]
    jsr add_hl_bc                                                     ; 35d3: 20 f3 0e     .. :07d3[1]
    lda #11                                                           ; 35d6: a9 0b       ..  :07d6[1]   ; invader sprite
    ldy #0                                                            ; 35d8: a0 00       ..  :07d8[1]
    sta (z_l),y                                                       ; 35da: 91 20       .   :07da[1]
    lda #0                                                            ; 35dc: a9 00       ..  :07dc[1]
    rts                                                               ; 35de: 60          `   :07de[1]

.player_dead
    lda #<1000                                                        ; 35df: a9 e8       ..  :07df[1]   ; player has been killed
    sta z_c                                                           ; 35e1: 85 22       ."  :07e1[1]
    lda #>1000                                                        ; 35e3: a9 03       ..  :07e3[1]
    sta z_b                                                           ; 35e5: 85 23       .#  :07e5[1]
.player_dead_spot_repeat
    lda z_c                                                           ; 35e7: a5 22       ."  :07e7[1]
    pha                                                               ; 35e9: 48          H   :07e9[1]
    lda z_b                                                           ; 35ea: a5 23       .#  :07ea[1]
    pha                                                               ; 35ec: 48          H   :07ec[1]   ; load in the address of the tilemap
    lda #<tile_map                                                    ; 35ed: a9 00       ..  :07ed[1]
    sta z_l                                                           ; 35ef: 85 20       .   :07ef[1]
    lda #>tile_map                                                    ; 35f1: a9 30       .0  :07f1[1]
    sta z_h                                                           ; 35f3: 85 21       .!  :07f3[1]
    jsr get_random                                                    ; 35f5: 20 3a 09     :. :07f5[1]   ; pick a random column between 0-31
    and #%00011111                                                    ; 35f8: 29 1f       ).  :07f8[1]
    clc                                                               ; 35fa: 18          .   :07fa[1]
    adc z_l                                                           ; 35fb: 65 20       e   :07fb[1]
    sta z_l                                                           ; 35fd: 85 20       .   :07fd[1]   ; shift to the random column
    lda #0                                                            ; 35ff: a9 00       ..  :07ff[1]
    sta z_b                                                           ; 3601: 85 23       .#  :0801[1]
.player_dead_spot_seek
    ldy #0                                                            ; 3603: a0 00       ..  :0803[1]
    lda (z_l),y                                                       ; 3605: b1 20       .   :0805[1]
    cmp #13                                                           ; 3607: c9 0d       ..  :0807[1]   ; check if the column is showing our gameover grime
    bne player_dead_found_spot                                        ; 3609: d0 16       ..  :0809[1]
    lda #<32                                                          ; 360b: a9 20       .   :080b[1]   ; if it is, move down until we find an empty spot
    sta z_e                                                           ; 360d: 85 24       .$  :080d[1]
    lda #>32                                                          ; 360f: a9 00       ..  :080f[1]
    sta z_d                                                           ; 3611: 85 25       .%  :0811[1]
    jsr add_hl_de                                                     ; 3613: 20 e5 0e     .. :0813[1]
    inc z_b                                                           ; 3616: e6 23       .#  :0816[1]
    lda z_b                                                           ; 3618: a5 23       .#  :0818[1]
    cmp #screen_height_g-1                                            ; 361a: c9 17       ..  :081a[1]
    beq player_dead_found_spot                                        ; 361c: f0 03       ..  :081c[1]   ; we've got to the end of the screen
    jmp player_dead_spot_seek                                         ; 361e: 4c 03 08    L.. :081e[1]

.player_dead_found_spot
    lda #13                                                           ; 3621: a9 0d       ..  :0821[1]
    ldy #0                                                            ; 3623: a0 00       ..  :0823[1]
    sta (z_l),y                                                       ; 3625: 91 20       .   :0825[1]   ; set the tile to our gameover grime
    pla                                                               ; 3627: 68          h   :0827[1]
    sta z_b                                                           ; 3628: 85 23       .#  :0828[1]
    pla                                                               ; 362a: 68          h   :082a[1]
    sta z_c                                                           ; 362b: 85 22       ."  :082b[1]
    lda z_c                                                           ; 362d: a5 22       ."  :082d[1]
    pha                                                               ; 362f: 48          H   :082f[1]
    lda z_b                                                           ; 3630: a5 23       .#  :0830[1]
    pha                                                               ; 3632: 48          H   :0832[1]
    lda z_c                                                           ; 3633: a5 22       ."  :0833[1]
    and #%00001111                                                    ; 3635: 29 0f       ).  :0835[1]
    bne player_dead_no_redraw                                         ; 3637: d0 21       .!  :0837[1]   ; only update the screen each 16 tiles
    lda z_c                                                           ; 3639: a5 22       ."  :0839[1]
    and #%11110000                                                    ; 363b: 29 f0       ).  :083b[1]   ; change the counter to a sound effect
    lsr a                                                             ; 363d: 4a          J   :083d[1]
    lsr a                                                             ; 363e: 4a          J   :083e[1]
    lsr a                                                             ; 363f: 4a          J   :083f[1]
    lsr a                                                             ; 3640: 4a          J   :0840[1]
    sta z_c                                                           ; 3641: 85 22       ."  :0841[1]
    lda z_b                                                           ; 3643: a5 23       .#  :0843[1]
    and #%00001111                                                    ; 3645: 29 0f       ).  :0845[1]
    asl a                                                             ; 3647: 0a          .   :0847[1]
    asl a                                                             ; 3648: 0a          .   :0848[1]
    asl a                                                             ; 3649: 0a          .   :0849[1]
    asl a                                                             ; 364a: 0a          .   :084a[1]
    ora z_c                                                           ; 364b: 05 22       ."  :084b[1]
    eor #%00111111                                                    ; 364d: 49 3f       I?  :084d[1]
    ora #%10000000                                                    ; 364f: 09 80       ..  :084f[1]
    jsr chibi_sound                                                   ; 3651: 20 12 1a     .. :0851[1]   ; make the sound
    jsr force_animate                                                 ; 3654: 20 fb 0b     .. :0854[1]
    jsr repaint_screen                                                ; 3657: 20 72 0c     r. :0857[1]   ; update the screen
.player_dead_no_redraw
    pla                                                               ; 365a: 68          h   :085a[1]
    sta z_b                                                           ; 365b: 85 23       .#  :085b[1]
    pla                                                               ; 365d: 68          h   :085d[1]
    sta z_c                                                           ; 365e: 85 22       ."  :085e[1]
    jsr dec_bc                                                        ; 3660: 20 c4 0e     .. :0860[1]
    lda z_b                                                           ; 3663: a5 23       .#  :0863[1]
    ora z_c                                                           ; 3665: 05 22       ."  :0865[1]
    beq player_dead_no_redraw_b                                       ; 3667: f0 03       ..  :0867[1]
    jmp player_dead_spot_repeat                                       ; 3669: 4c e7 07    L.. :0869[1]   ; continue the game over animation

.player_dead_no_redraw_b
    lda #0                                                            ; 366c: a9 00       ..  :086c[1]
    jsr chibi_sound                                                   ; 366e: 20 12 1a     .. :086e[1]   ; stop the sound
    lda #<tile_map                                                    ; 3671: a9 00       ..  :0871[1]
    sta z_l                                                           ; 3673: 85 20       .   :0873[1]
    lda #>tile_map                                                    ; 3675: a9 30       .0  :0875[1]
    sta z_h                                                           ; 3677: 85 21       .!  :0877[1]
    lda #<(768-1)                                                     ; 3679: a9 ff       ..  :0879[1]
    sta z_c                                                           ; 367b: 85 22       ."  :087b[1]
    lda #>(768-1)                                                     ; 367d: a9 02       ..  :087d[1]
    sta z_b                                                           ; 367f: 85 23       .#  :087f[1]
    lda #13                                                           ; 3681: a9 0d       ..  :0881[1]
    jsr set_memory                                                    ; 3683: 20 7e 0e     ~. :0883[1]
    jsr force_repaint                                                 ; 3686: 20 5c 0c     \. :0886[1]
    jsr repaint_screen                                                ; 3689: 20 72 0c     r. :0889[1]   ; we may not have actually filled to screen with grime, so lets force-fill it here
    lda #<&1000                                                       ; 368c: a9 00       ..  :088c[1]   ; wait a bit
    sta z_c                                                           ; 368e: 85 22       ."  :088e[1]
    lda #>&1000                                                       ; 3690: a9 10       ..  :0890[1]
    sta z_b                                                           ; 3692: 85 23       .#  :0892[1]
    jsr pause                                                         ; 3694: 20 70 09     p. :0894[1]
    dec lives                                                         ; 3697: ce 1e 36    ..6 :0897[1]   ; decrease the lives
    beq player_dead_no_redraw_c                                       ; 369a: f0 03       ..  :089a[1]
    jmp new_game_round                                                ; 369c: 4c b5 03    L.. :089c[1]   ; if the player has lives left, keep playing

.player_dead_no_redraw_c
    ldx #(screen_width_g/2)-7+1                                       ; 369f: a2 0a       ..  :089f[1]   ; print the game over message
    ldy #(screen_height_g/2)-3                                        ; 36a1: a0 09       ..  :08a1[1]
    jsr set_cursor_xy                                                 ; 36a3: 20 68 18     h. :08a3[1]
    lda #<youre_dead_message                                          ; 36a6: a9 0f       ..  :08a6[1]
    sta z_l                                                           ; 36a8: 85 20       .   :08a8[1]
    lda #>youre_dead_message                                          ; 36aa: a9 09       ..  :08aa[1]
    sta z_h                                                           ; 36ac: 85 21       .!  :08ac[1]
    jsr print_message_hl                                              ; 36ae: 20 4f 0e     O. :08ae[1]
    ldx #(screen_width_g/2)-8                                         ; 36b1: a2 08       ..  :08b1[1]   ; print the 'cos you suck' message
    ldy #(screen_height_g/2)+1                                        ; 36b3: a0 0d       ..  :08b3[1]
    jsr set_cursor_xy                                                 ; 36b5: 20 68 18     h. :08b5[1]
    lda #<cos_you_suck_message                                        ; 36b8: a9 1c       ..  :08b8[1]
    sta z_l                                                           ; 36ba: 85 20       .   :08ba[1]
    lda #>cos_you_suck_message                                        ; 36bc: a9 09       ..  :08bc[1]
    sta z_h                                                           ; 36be: 85 21       .!  :08be[1]
    jsr print_message_hl                                              ; 36c0: 20 4f 0e     O. :08c0[1]
    ; compare score with high score
    lda #<score                                                       ; 36c3: a9 20       .   :08c3[1]
    sta z_l                                                           ; 36c5: 85 20       .   :08c5[1]
    lda #>score                                                       ; 36c7: a9 36       .6  :08c7[1]
    sta z_h                                                           ; 36c9: 85 21       .!  :08c9[1]
    lda #<high_score                                                  ; 36cb: a9 24       .$  :08cb[1]
    sta z_e                                                           ; 36cd: 85 24       .$  :08cd[1]
    lda #>high_score                                                  ; 36cf: a9 36       .6  :08cf[1]
    sta z_d                                                           ; 36d1: 85 25       .%  :08d1[1]
    lda #4                                                            ; 36d3: a9 04       ..  :08d3[1]
    sta z_b                                                           ; 36d5: 85 23       .#  :08d5[1]
    jsr compare_bcd                                                   ; 36d7: 20 92 17     .. :08d7[1]   ; check if we have a new high score
    bcs game_over_wait_for_fire                                       ; 36da: b0 2d       .-  :08da[1]
    ldx #(screen_width_g/2)-7+1                                       ; 36dc: a2 0a       ..  :08dc[1]   ; print the 'new high score' message
    ldy #(screen_height_g/2)+4                                        ; 36de: a0 10       ..  :08de[1]
    jsr set_cursor_xy                                                 ; 36e0: 20 68 18     h. :08e0[1]
    lda #<new_high_score_message                                      ; 36e3: a9 2d       .-  :08e3[1]
    sta z_l                                                           ; 36e5: 85 20       .   :08e5[1]
    lda #>new_high_score_message                                      ; 36e7: a9 09       ..  :08e7[1]
    sta z_h                                                           ; 36e9: 85 21       .!  :08e9[1]
    jsr print_message_hl                                              ; 36eb: 20 4f 0e     O. :08eb[1]
    ; copy 4 byte score into the high score
    lda #<4                                                           ; 36ee: a9 04       ..  :08ee[1]
    sta z_c                                                           ; 36f0: 85 22       ."  :08f0[1]
    lda #>4                                                           ; 36f2: a9 00       ..  :08f2[1]
    sta z_b                                                           ; 36f4: 85 23       .#  :08f4[1]
    lda #<score                                                       ; 36f6: a9 20       .   :08f6[1]
    sta z_l                                                           ; 36f8: 85 20       .   :08f8[1]
    lda #>score                                                       ; 36fa: a9 36       .6  :08fa[1]
    sta z_h                                                           ; 36fc: 85 21       .!  :08fc[1]
    lda #<high_score                                                  ; 36fe: a9 24       .$  :08fe[1]
    sta z_e                                                           ; 3700: 85 24       .$  :0900[1]
    lda #>high_score                                                  ; 3702: a9 36       .6  :0902[1]
    sta z_d                                                           ; 3704: 85 25       .%  :0904[1]
    jsr copy_memory_loop                                              ; 3706: 20 8f 0e     .. :0906[1]
.game_over_wait_for_fire
    jsr wait_for_fire                                                 ; 3709: 20 e0 0b     .. :0909[1]   ; pause then restart the game
    jmp title_screen                                                  ; 370c: 4c 8e 02    L.. :090c[1]

.youre_dead_message
    equs "You're dead!"                                               ; 370f: 59 6f 75... You :090f[1]
    equb &ff                                                          ; 371b: ff          .   :091b[1]
.cos_you_suck_message
    equs "('cos you suck!)"                                           ; 371c: 28 27 63... ('c :091c[1]
    equb &ff                                                          ; 372c: ff          .   :092c[1]
.new_high_score_message
    equs "New Hiscore!"                                               ; 372d: 4e 65 77... New :092d[1]
    equb &ff                                                          ; 3739: ff          .   :0939[1]

.get_random
    tya                                                               ; 373a: 98          .   :093a[1]
    pha                                                               ; 373b: 48          H   :093b[1]
    lda random_seed                                                   ; 373c: ad 11 36    ..6 :093c[1]
    and #%00000111                                                    ; 373f: 29 07       ).  :093f[1]
    tay                                                               ; 3741: a8          .   :0941[1]
    lda random_source,y                                               ; 3742: b9 e9 16    ... :0942[1]
    eor random_seed                                                   ; 3745: 4d 11 36    M.6 :0945[1]
    sta z_as                                                          ; 3748: 85 26       .&  :0948[1]
    lda random_seed                                                   ; 374a: ad 11 36    ..6 :094a[1]
    and #%00111000                                                    ; 374d: 29 38       )8  :094d[1]
    lsr a                                                             ; 374f: 4a          J   :094f[1]
    lsr a                                                             ; 3750: 4a          J   :0950[1]
    lsr a                                                             ; 3751: 4a          J   :0951[1]
    tay                                                               ; 3752: a8          .   :0952[1]
    lda random_source,y                                               ; 3753: b9 e9 16    ... :0953[1]
    eor z_as                                                          ; 3756: 45 26       E&  :0956[1]
    sta z_as                                                          ; 3758: 85 26       .&  :0958[1]
    inc random_seed                                                   ; 375a: ee 11 36    ..6 :095a[1]
    lda random_seed_2                                                 ; 375d: ad 2a 36    .*6 :095d[1]
    tay                                                               ; 3760: a8          .   :0960[1]
    lda game_loop,y                                                   ; 3761: b9 e6 03    ... :0961[1]
    eor z_as                                                          ; 3764: 45 26       E&  :0964[1]
    sta z_as                                                          ; 3766: 85 26       .&  :0966[1]
    sta random_seed_2                                                 ; 3768: 8d 2a 36    .*6 :0968[1]
    pla                                                               ; 376b: 68          h   :096b[1]
    tay                                                               ; 376c: a8          .   :096c[1]
    lda z_as                                                          ; 376d: a5 26       .&  :096d[1]
    rts                                                               ; 376f: 60          `   :096f[1]

.pause
    jsr dec_bc                                                        ; 3770: 20 c4 0e     .. :0970[1]
    lda z_b                                                           ; 3773: a5 23       .#  :0973[1]
    ora z_c                                                           ; 3775: 05 22       ."  :0975[1]
    bne pause                                                         ; 3777: d0 f7       ..  :0977[1]   ; pause for BC ticks
    rts                                                               ; 3779: 60          `   :0979[1]

.add_de_32
    clc                                                               ; 377a: 18          .   :097a[1]
    lda #32                                                           ; 377b: a9 20       .   :097b[1]
    adc z_e                                                           ; 377d: 65 24       e$  :097d[1]
    sta z_e                                                           ; 377f: 85 24       .$  :097f[1]
    lda #0                                                            ; 3781: a9 00       ..  :0981[1]
    adc z_d                                                           ; 3783: 65 25       e%  :0983[1]
    sta z_d                                                           ; 3785: 85 25       .%  :0985[1]
    rts                                                               ; 3787: 60          `   :0987[1]

.sub_de_32
    sec                                                               ; 3788: 38          8   :0988[1]
    lda z_e                                                           ; 3789: a5 24       .$  :0989[1]
    sbc #32                                                           ; 378b: e9 20       .   :098b[1]
    sta z_e                                                           ; 378d: 85 24       .$  :098d[1]
    lda z_d                                                           ; 378f: a5 25       .%  :098f[1]
    sbc #0                                                            ; 3791: e9 00       ..  :0991[1]
    sta z_d                                                           ; 3793: 85 25       .%  :0993[1]
    rts                                                               ; 3795: 60          `   :0995[1]

.add_hl_32
    clc                                                               ; 3796: 18          .   :0996[1]
    lda #32                                                           ; 3797: a9 20       .   :0997[1]
    adc z_l                                                           ; 3799: 65 20       e   :0999[1]
    sta z_l                                                           ; 379b: 85 20       .   :099b[1]
    lda #0                                                            ; 379d: a9 00       ..  :099d[1]
    adc z_h                                                           ; 379f: 65 21       e!  :099f[1]
    sta z_h                                                           ; 37a1: 85 21       .!  :09a1[1]
    rts                                                               ; 37a3: 60          `   :09a3[1]

; unused
.sub_hl_32
    sec                                                               ; 37a4: 38          8   :09a4[1]
    lda z_l                                                           ; 37a5: a5 20       .   :09a5[1]
    sbc #32                                                           ; 37a7: e9 20       .   :09a7[1]
    sta z_l                                                           ; 37a9: 85 20       .   :09a9[1]
    lda z_h                                                           ; 37ab: a5 21       .!  :09ab[1]
    sbc #0                                                            ; 37ad: e9 00       ..  :09ad[1]
    sta z_h                                                           ; 37af: 85 21       .!  :09af[1]
    rts                                                               ; 37b1: 60          `   :09b1[1]

.sub_hl_64
    sec                                                               ; 37b2: 38          8   :09b2[1]
    lda z_l                                                           ; 37b3: a5 20       .   :09b3[1]
    sbc #64                                                           ; 37b5: e9 40       .@  :09b5[1]
    sta z_l                                                           ; 37b7: 85 20       .   :09b7[1]
    lda z_h                                                           ; 37b9: a5 21       .!  :09b9[1]
    sbc #0                                                            ; 37bb: e9 00       ..  :09bb[1]
    sta z_h                                                           ; 37bd: 85 21       .!  :09bd[1]
    rts                                                               ; 37bf: 60          `   :09bf[1]

.do_mould_seek
    lda z_h                                                           ; 37c0: a5 21       .!  :09c0[1]   ; load current location into DE
    sta z_d                                                           ; 37c2: 85 25       .%  :09c2[1]
    lda z_l                                                           ; 37c4: a5 20       .   :09c4[1]
    sta z_e                                                           ; 37c6: 85 24       .$  :09c6[1]
    lda playerX1                                                      ; 37c8: ad 10 36    ..6 :09c8[1]   ; compare to player X
    cmp z_b                                                           ; 37cb: c5 23       .#  :09cb[1]
    beq do_mould_move_skip_X                                          ; 37cd: f0 09       ..  :09cd[1]
    bcs do_mould_move_X_smaller                                       ; 37cf: b0 05       ..  :09cf[1]
    dec z_e                                                           ; 37d1: c6 24       .$  :09d1[1]   ; move left
    jmp do_mould_move_skip_X                                          ; 37d3: 4c d8 09    L.. :09d3[1]

.do_mould_move_X_smaller
    inc z_e                                                           ; 37d6: e6 24       .$  :09d6[1]   ; move right
.do_mould_move_skip_X
    lda playerY1                                                      ; 37d8: ad 12 36    ..6 :09d8[1]   ; compare to player Y
    cmp z_c                                                           ; 37db: c5 22       ."  :09db[1]
    beq do_mould_move_skip_Y                                          ; 37dd: f0 0b       ..  :09dd[1]
    bcs do_mould_move_Y_smaller                                       ; 37df: b0 06       ..  :09df[1]
    jsr sub_de_32                                                     ; 37e1: 20 88 09     .. :09e1[1]   ; move up
    jmp do_mould_move_skip_Y                                          ; 37e4: 4c ea 09    L.. :09e4[1]

.do_mould_move_Y_smaller
    jsr add_de_32                                                     ; 37e7: 20 7a 09     z. :09e7[1]   ; move down
.do_mould_move_skip_Y
    ldy #0                                                            ; 37ea: a0 00       ..  :09ea[1]
    lda (z_e),y                                                       ; 37ec: b1 24       .$  :09ec[1]
    beq seek_ok                                                       ; 37ee: f0 05       ..  :09ee[1]
    cmp #5                                                            ; 37f0: c9 05       ..  :09f0[1]   ; bullet
    beq seek_ok                                                       ; 37f2: f0 01       ..  :09f2[1]
    rts                                                               ; 37f4: 60          `   :09f4[1]

.seek_ok
    ldy #0                                                            ; 37f5: a0 00       ..  :09f5[1]
    lda (z_l),y                                                       ; 37f7: b1 20       .   :09f7[1]
    sta (z_e),y                                                       ; 37f9: 91 24       .$  :09f9[1]   ; move to the new location, clear the old one
    tya                                                               ; 37fb: 98          .   :09fb[1]   ; A=&00
    sta (z_l),y                                                       ; 37fc: 91 20       .   :09fc[1]
    rts                                                               ; 37fe: 60          `   :09fe[1]

; ***************************************
; evolve the mould (full tick)
; ***************************************
.mould_evolve
    lda #<tile_map2                                                   ; 37ff: a9 00       ..  :09ff[1]
    sta z_l                                                           ; 3801: 85 20       .   :0a01[1]
    lda #>tile_map2                                                   ; 3803: a9 33       .3  :0a03[1]
    sta z_h                                                           ; 3805: 85 21       .!  :0a05[1]
    lda #0                                                            ; 3807: a9 00       ..  :0a07[1]
    sta z_c                                                           ; 3809: 85 22       ."  :0a09[1]
.mould_evolve_next_y
    lda #0                                                            ; 380b: a9 00       ..  :0a0b[1]
    sta z_b                                                           ; 380d: 85 23       .#  :0a0d[1]
.mould_evolve_next_x
    ldy #0                                                            ; 380f: a0 00       ..  :0a0f[1]
    lda (z_l),y                                                       ; 3811: b1 20       .   :0a11[1]
    sta z_as                                                          ; 3813: 85 26       .&  :0a13[1]
    lda z_l                                                           ; 3815: a5 20       .   :0a15[1]
    pha                                                               ; 3817: 48          H   :0a17[1]
    lda z_h                                                           ; 3818: a5 21       .!  :0a18[1]
    pha                                                               ; 381a: 48          H   :0a1a[1]
    clc                                                               ; 381b: 18          .   :0a1b[1]
    lda #&fd                                                          ; 381c: a9 fd       ..  :0a1c[1]   ; subtract 768, because we want to see the previous state
    adc z_h                                                           ; 381e: 65 21       e!  :0a1e[1]
    sta z_h                                                           ; 3820: 85 21       .!  :0a20[1]
    lda z_as                                                          ; 3822: a5 26       .&  :0a22[1]
    cmp #8                                                            ; 3824: c9 08       ..  :0a24[1]
    beq mould_evolve_green                                            ; 3826: f0 33       .3  :0a26[1]   ; evolve a cell of green mould
    cmp #9                                                            ; 3828: c9 09       ..  :0a28[1]
    beq mould_evolve_blue                                             ; 382a: f0 3a       .:  :0a2a[1]   ; evolve a cell of blue mould
    cmp #&0c                                                          ; 382c: c9 0c       ..  :0a2c[1]
    bne mould_evolve_skip_a                                           ; 382e: d0 03       ..  :0a2e[1]
    jsr do_descender                                                  ; 3830: 20 21 0b     !. :0a30[1]   ; move a descender down
.mould_evolve_skip_a
    cmp #11                                                           ; 3833: c9 0b       ..  :0a33[1]
    bne mould_evolve_skip_b                                           ; 3835: d0 03       ..  :0a35[1]
    jsr do_invader                                                    ; 3837: 20 7d 0b     }. :0a37[1]   ; move an invader left
.mould_evolve_skip_b
    cmp #10                                                           ; 383a: c9 0a       ..  :0a3a[1]
    bne mould_evolve_next                                             ; 383c: d0 03       ..  :0a3c[1]
    jsr do_mould_seek                                                 ; 383e: 20 c0 09     .. :0a3e[1]   ; move a seeker towards the player
.mould_evolve_next
    pla                                                               ; 3841: 68          h   :0a41[1]
    sta z_h                                                           ; 3842: 85 21       .!  :0a42[1]
    pla                                                               ; 3844: 68          h   :0a44[1]
    sta z_l                                                           ; 3845: 85 20       .   :0a45[1]
    jsr inc_hl                                                        ; 3847: 20 bd 0e     .. :0a47[1]
    inc z_b                                                           ; 384a: e6 23       .#  :0a4a[1]
    lda z_b                                                           ; 384c: a5 23       .#  :0a4c[1]
    cmp #32                                                           ; 384e: c9 20       .   :0a4e[1]
    bne mould_evolve_next_x                                           ; 3850: d0 bd       ..  :0a50[1]
    inc z_c                                                           ; 3852: e6 22       ."  :0a52[1]
    lda z_c                                                           ; 3854: a5 22       ."  :0a54[1]
    cmp #24                                                           ; 3856: c9 18       ..  :0a56[1]
    bne mould_evolve_next_y                                           ; 3858: d0 b1       ..  :0a58[1]
    rts                                                               ; 385a: 60          `   :0a5a[1]

.mould_evolve_green
    lda #9                                                            ; 385b: a9 09       ..  :0a5b[1]   ; centre objects (seeker)
    sta z_ixl                                                         ; 385d: 85 28       .(  :0a5d[1]
    lda #8                                                            ; 385f: a9 08       ..  :0a5f[1]   ; edge objects (green)
    sta z_ixh                                                         ; 3861: 85 29       .)  :0a61[1]
    jmp do_mould_evolve                                               ; 3863: 4c 6e 0a    Ln. :0a63[1]

.mould_evolve_blue
    lda #10                                                           ; 3866: a9 0a       ..  :0a66[1]   ; centre object (seeker)
    sta z_ixl                                                         ; 3868: 85 28       .(  :0a68[1]
    lda #9                                                            ; 386a: a9 09       ..  :0a6a[1]   ; edge object (blue)
    sta z_ixh                                                         ; 386c: 85 29       .)  :0a6c[1]
.do_mould_evolve
    lda z_ixl                                                         ; 386e: a5 28       .(  :0a6e[1]   ; new centre spore
    ldy #0                                                            ; 3870: a0 00       ..  :0a70[1]
    sta (z_l),y                                                       ; 3872: 91 20       .   :0a72[1]
    inc z_l                                                           ; 3874: e6 20       .   :0a74[1]   ; move right
    lda z_l                                                           ; 3876: a5 20       .   :0a76[1]
    and #%00011111                                                    ; 3878: 29 1f       ).  :0a78[1]   ; see if we're off the screen
    beq mould_evolve_green_skip1                                      ; 387a: f0 08       ..  :0a7a[1]
    lda (z_l),y                                                       ; 387c: b1 20       .   :0a7c[1]
    bne mould_evolve_green_skip1                                      ; 387e: d0 04       ..  :0a7e[1]
    lda z_ixh                                                         ; 3880: a5 29       .)  :0a80[1]   ; new outer spore
    sta (z_l),y                                                       ; 3882: 91 20       .   :0a82[1]
.mould_evolve_green_skip1
    dec z_l                                                           ; 3884: c6 20       .   :0a84[1]   ; move left
    dec z_l                                                           ; 3886: c6 20       .   :0a86[1]
    lda z_l                                                           ; 3888: a5 20       .   :0a88[1]
    and #%00011111                                                    ; 388a: 29 1f       ).  :0a8a[1]
    cmp #%00011111                                                    ; 388c: c9 1f       ..  :0a8c[1]
    beq mould_evolve_green_skip2                                      ; 388e: f0 08       ..  :0a8e[1]
    lda (z_l),y                                                       ; 3890: b1 20       .   :0a90[1]   ; see if we're off screen
    bne mould_evolve_green_skip2                                      ; 3892: d0 04       ..  :0a92[1]
    lda z_ixh                                                         ; 3894: a5 29       .)  :0a94[1]   ; new outer spore
    sta (z_l),y                                                       ; 3896: 91 20       .   :0a96[1]
.mould_evolve_green_skip2
    inc z_l                                                           ; 3898: e6 20       .   :0a98[1]   ; move to centre
    jsr add_hl_32                                                     ; 389a: 20 96 09     .. :0a9a[1]   ; move down
    lda z_c                                                           ; 389d: a5 22       ."  :0a9d[1]
    cmp #24                                                           ; 389f: c9 18       ..  :0a9f[1]   ; see if we're off the bottom of the screen
    beq mould_evolve_green_skip3b                                     ; 38a1: f0 0c       ..  :0aa1[1]
    lda (z_l),y                                                       ; 38a3: b1 20       .   :0aa3[1]
    bne mould_evolve_green_skip3                                      ; 38a5: d0 04       ..  :0aa5[1]
    lda z_ixh                                                         ; 38a7: a5 29       .)  :0aa7[1]   ; new outer spore
    sta (z_l),y                                                       ; 38a9: 91 20       .   :0aa9[1]
.mould_evolve_green_skip3
    lda z_c                                                           ; 38ab: a5 22       ."  :0aab[1]   ; see if we're off screen
    beq mould_evolve_green_skip4                                      ; 38ad: f0 13       ..  :0aad[1]
.mould_evolve_green_skip3b
    lda #64                                                           ; 38af: a9 40       .@  :0aaf[1]   ; move up
    sta z_e                                                           ; 38b1: 85 24       .$  :0ab1[1]
    lda #0                                                            ; 38b3: a9 00       ..  :0ab3[1]
    sta z_d                                                           ; 38b5: 85 25       .%  :0ab5[1]
    jsr sub_hl_64                                                     ; 38b7: 20 b2 09     .. :0ab7[1]
    lda (z_l),y                                                       ; 38ba: b1 20       .   :0aba[1]
    bne mould_evolve_green_skip4                                      ; 38bc: d0 04       ..  :0abc[1]
    lda z_ixh                                                         ; 38be: a5 29       .)  :0abe[1]   ; new outer spore
    sta (z_l),y                                                       ; 38c0: 91 20       .   :0ac0[1]
.mould_evolve_green_skip4
    jmp mould_evolve_next                                             ; 38c2: 4c 41 0a    LA. :0ac2[1]

; ***************************************
; Move the mould (partial tick)
; ***************************************
.mould_move
    lda anim_frame                                                    ; 38c5: ad 1f 36    ..6 :0ac5[1]   ; force animation
    eor #%00010000                                                    ; 38c8: 49 10       I.  :0ac8[1]
    sta anim_frame                                                    ; 38ca: 8d 1f 36    ..6 :0aca[1]
    lda #<tile_map2                                                   ; 38cd: a9 00       ..  :0acd[1]
    sta z_l                                                           ; 38cf: 85 20       .   :0acf[1]
    lda #>tile_map2                                                   ; 38d1: a9 33       .3  :0ad1[1]
    sta z_h                                                           ; 38d3: 85 21       .!  :0ad3[1]
    lda #0                                                            ; 38d5: a9 00       ..  :0ad5[1]
    sta z_c                                                           ; 38d7: 85 22       ."  :0ad7[1]
.mould_move_nextY
    lda #0                                                            ; 38d9: a9 00       ..  :0ad9[1]
    sta z_b                                                           ; 38db: 85 23       .#  :0adb[1]
.mould_move_nextX
    ldy #0                                                            ; 38dd: a0 00       ..  :0add[1]
    lda (z_l),y                                                       ; 38df: b1 20       .   :0adf[1]
    sta z_as                                                          ; 38e1: 85 26       .&  :0ae1[1]
    clc                                                               ; 38e3: 18          .   :0ae3[1]
    lda #&fd                                                          ; 38e4: a9 fd       ..  :0ae4[1]   ; subtract 768, because we want to see the previous state.
    adc z_h                                                           ; 38e6: 65 21       e!  :0ae6[1]
    sta z_h                                                           ; 38e8: 85 21       .!  :0ae8[1]
    lda z_as                                                          ; 38ea: a5 26       .&  :0aea[1]
    cmp #&0c                                                          ; 38ec: c9 0c       ..  :0aec[1]
    bne mould_move_b                                                  ; 38ee: d0 03       ..  :0aee[1]
    jsr do_descender                                                  ; 38f0: 20 21 0b     !. :0af0[1]   ; move a descender down
.mould_move_b
    cmp #11                                                           ; 38f3: c9 0b       ..  :0af3[1]
    bne mould_move_c                                                  ; 38f5: d0 03       ..  :0af5[1]
    jsr do_invader                                                    ; 38f7: 20 7d 0b     }. :0af7[1]   ; move an invader left
.mould_move_c
    cmp #10                                                           ; 38fa: c9 0a       ..  :0afa[1]
    bne mould_move_next                                               ; 38fc: d0 03       ..  :0afc[1]
    jsr do_mould_seek                                                 ; 38fe: 20 c0 09     .. :0afe[1]   ; move a seeker towards the player
.mould_move_next
    clc                                                               ; 3901: 18          .   :0b01[1]
    lda #3                                                            ; 3902: a9 03       ..  :0b02[1]
    adc z_h                                                           ; 3904: 65 21       e!  :0b04[1]
    sta z_h                                                           ; 3906: 85 21       .!  :0b06[1]
    inc z_l                                                           ; 3908: e6 20       .   :0b08[1]
    inc z_b                                                           ; 390a: e6 23       .#  :0b0a[1]
    lda z_b                                                           ; 390c: a5 23       .#  :0b0c[1]
    cmp #32                                                           ; 390e: c9 20       .   :0b0e[1]
    bne mould_move_nextX                                              ; 3910: d0 cb       ..  :0b10[1]
    lda z_l                                                           ; 3912: a5 20       .   :0b12[1]
    bne mould_move_y_ok                                               ; 3914: d0 02       ..  :0b14[1]
    inc z_h                                                           ; 3916: e6 21       .!  :0b16[1]
.mould_move_y_ok
    inc z_c                                                           ; 3918: e6 22       ."  :0b18[1]
    lda z_c                                                           ; 391a: a5 22       ."  :0b1a[1]
    cmp #24                                                           ; 391c: c9 18       ..  :0b1c[1]
    bne mould_move_nextY                                              ; 391e: d0 b9       ..  :0b1e[1]
    rts                                                               ; 3920: 60          `   :0b20[1]

.do_descender
    lda z_c                                                           ; 3921: a5 22       ."  :0b21[1]
    cmp #screen_height_g-1                                            ; 3923: c9 17       ..  :0b23[1]
    bne do_decender_b                                                 ; 3925: d0 03       ..  :0b25[1]
    jmp zero_current                                                  ; 3927: 4c c4 0b    L.. :0b27[1]

.do_decender_b
    ldy #0                                                            ; 392a: a0 00       ..  :0b2a[1]
    lda (z_l),y                                                       ; 392c: b1 20       .   :0b2c[1]
    sta z_d                                                           ; 392e: 85 25       .%  :0b2e[1]
    lda z_c                                                           ; 3930: a5 22       ."  :0b30[1]
    pha                                                               ; 3932: 48          H   :0b32[1]
    lda z_b                                                           ; 3933: a5 23       .#  :0b33[1]
    pha                                                               ; 3935: 48          H   :0b35[1]
    lda z_l                                                           ; 3936: a5 20       .   :0b36[1]
    pha                                                               ; 3938: 48          H   :0b38[1]
    lda z_h                                                           ; 3939: a5 21       .!  :0b39[1]
    pha                                                               ; 393b: 48          H   :0b3b[1]
    jsr add_hl_32                                                     ; 393c: 20 96 09     .. :0b3c[1]   ; move down a line
    ldy #0                                                            ; 393f: a0 00       ..  :0b3f[1]
    lda (z_l),y                                                       ; 3941: b1 20       .   :0b41[1]   ; read in the object under the descender
    beq decender_done                                                 ; 3943: f0 1d       ..  :0b43[1]
    cmp #5                                                            ; 3945: c9 05       ..  :0b45[1]
    bcs player_ok_a                                                   ; 3947: b0 03       ..  :0b47[1]   ; see if the descender has hit the player
    jmp player_dead                                                   ; 3949: 4c df 07    L.. :0b49[1]

.player_ok_a
    bne no_zero_bullet                                                ; 394c: d0 02       ..  :0b4c[1]
    lda #0                                                            ; 394e: a9 00       ..  :0b4e[1]   ; don't copy player sprites!
.no_zero_bullet
    cmp #9                                                            ; 3950: c9 09       ..  :0b50[1]
    beq descender_to_green                                            ; 3952: f0 0c       ..  :0b52[1]   ; convert blue mould to green
    cmp #&0a                                                          ; 3954: c9 0a       ..  :0b54[1]
    beq descender_to_blue                                             ; 3956: f0 03       ..  :0b56[1]   ; convert seekers to blue mould
    jmp decender_done                                                 ; 3958: 4c 62 0b    Lb. :0b58[1]

.descender_to_blue
    lda #9                                                            ; 395b: a9 09       ..  :0b5b[1]   ; blue mould
    jmp decender_done                                                 ; 395d: 4c 62 0b    Lb. :0b5d[1]

.descender_to_green
    lda #8                                                            ; 3960: a9 08       ..  :0b60[1]   ; green mould
.decender_done
    sta z_as                                                          ; 3962: 85 26       .&  :0b62[1]
    lda z_d                                                           ; 3964: a5 25       .%  :0b64[1]
    sta (z_l),y                                                       ; 3966: 91 20       .   :0b66[1]
    pla                                                               ; 3968: 68          h   :0b68[1]
    sta z_h                                                           ; 3969: 85 21       .!  :0b69[1]
    pla                                                               ; 396b: 68          h   :0b6b[1]
    sta z_l                                                           ; 396c: 85 20       .   :0b6c[1]
    pla                                                               ; 396e: 68          h   :0b6e[1]
    sta z_b                                                           ; 396f: 85 23       .#  :0b6f[1]
    pla                                                               ; 3971: 68          h   :0b71[1]
    sta z_c                                                           ; 3972: 85 22       ."  :0b72[1]
    ldy #0                                                            ; 3974: a0 00       ..  :0b74[1]
    lda z_as                                                          ; 3976: a5 26       .&  :0b76[1]
    sta (z_l),y                                                       ; 3978: 91 20       .   :0b78[1]
    lda #0                                                            ; 397a: a9 00       ..  :0b7a[1]
    rts                                                               ; 397c: 60          `   :0b7c[1]

.do_invader
    lda z_l                                                           ; 397d: a5 20       .   :0b7d[1]
    and #%00011111                                                    ; 397f: 29 1f       ).  :0b7f[1]
    beq zero_current                                                  ; 3981: f0 41       .A  :0b81[1]   ; we've reached the left hand side of the screen, so remove the invader
    ldy #0                                                            ; 3983: a0 00       ..  :0b83[1]
    lda (z_l),y                                                       ; 3985: b1 20       .   :0b85[1]
    sta z_d                                                           ; 3987: 85 25       .%  :0b87[1]
    dec z_l                                                           ; 3989: c6 20       .   :0b89[1]
    lda (z_l),y                                                       ; 398b: b1 20       .   :0b8b[1]
    beq invader_done                                                  ; 398d: f0 0b       ..  :0b8d[1]
    cmp #5                                                            ; 398f: c9 05       ..  :0b8f[1]
    bcs player_ok_b                                                   ; 3991: b0 03       ..  :0b91[1]   ; see if the descender has hit the player
    jmp player_dead                                                   ; 3993: 4c df 07    L.. :0b93[1]

.player_ok_b
    bne invader_done                                                  ; 3996: d0 02       ..  :0b96[1]
    lda #0                                                            ; 3998: a9 00       ..  :0b98[1]   ; don't copy player sprites
.invader_done
    pha                                                               ; 399a: 48          H   :0b9a[1]
    ldy #0                                                            ; 399b: a0 00       ..  :0b9b[1]
    lda z_d                                                           ; 399d: a5 25       .%  :0b9d[1]
    sta (z_l),y                                                       ; 399f: 91 20       .   :0b9f[1]
    inc z_l                                                           ; 39a1: e6 20       .   :0ba1[1]
    pla                                                               ; 39a3: 68          h   :0ba3[1]
    sta z_d                                                           ; 39a4: 85 25       .%  :0ba4[1]
    cmp #8                                                            ; 39a6: c9 08       ..  :0ba6[1]
    bcs do_invader_no_spore                                           ; 39a8: b0 12       ..  :0ba8[1]   ; don't drop a spore on non-empty spaces
    jsr get_random                                                    ; 39aa: 20 3a 09     :. :0baa[1]   ; we drop spores at random
    and #%00011111                                                    ; 39ad: 29 1f       ).  :0bad[1]
    bne do_invader_no_spore                                           ; 39af: d0 0b       ..  :0baf[1]
    lda allowed_fast_growth                                           ; 39b1: ad 19 36    ..6 :0bb1[1]   ; we're making a spore, so speed up the growth for a few ticks
    sta fast_growth                                                   ; 39b4: 8d 13 36    ..6 :0bb4[1]
    lda #8                                                            ; 39b7: a9 08       ..  :0bb7[1]
    jmp do_invader_new_spore                                          ; 39b9: 4c be 0b    L.. :0bb9[1]   ; drop a new spore

.do_invader_no_spore
    lda z_d                                                           ; 39bc: a5 25       .%  :0bbc[1]
.do_invader_new_spore
    ldy #0                                                            ; 39be: a0 00       ..  :0bbe[1]
    sta (z_l),y                                                       ; 39c0: 91 20       .   :0bc0[1]
    tya                                                               ; 39c2: 98          .   :0bc2[1]   ; A=&00
    rts                                                               ; 39c3: 60          `   :0bc3[1]

.zero_current
    lda #0                                                            ; 39c4: a9 00       ..  :0bc4[1]
    tay                                                               ; 39c6: a8          .   :0bc6[1]   ; Y=&00
    sta (z_l),y                                                       ; 39c7: 91 20       .   :0bc7[1]   ; clear the cell
    rts                                                               ; 39c9: 60          `   :0bc9[1]

.debounce
    lda z_l                                                           ; 39ca: a5 20       .   :0bca[1]
    pha                                                               ; 39cc: 48          H   :0bcc[1]
    lda z_h                                                           ; 39cd: a5 21       .!  :0bcd[1]
    pha                                                               ; 39cf: 48          H   :0bcf[1]
.debounce2
    jsr read_both_controls                                            ; 39d0: 20 f1 16     .. :0bd0[1]
    lda z_h                                                           ; 39d3: a5 21       .!  :0bd3[1]
    cmp #&ff                                                          ; 39d5: c9 ff       ..  :0bd5[1]
    beq debounce2                                                     ; 39d7: f0 f7       ..  :0bd7[1]   ; wait for all keys to be released
    pla                                                               ; 39d9: 68          h   :0bd9[1]
    sta z_h                                                           ; 39da: 85 21       .!  :0bda[1]
    pla                                                               ; 39dc: 68          h   :0bdc[1]
    sta z_l                                                           ; 39dd: 85 20       .   :0bdd[1]
    rts                                                               ; 39df: 60          `   :0bdf[1]

.wait_for_fire
    jsr debounce                                                      ; 39e0: 20 ca 0b     .. :0be0[1]   ; wait for keys to be released
    lda z_l                                                           ; 39e3: a5 20       .   :0be3[1]
    pha                                                               ; 39e5: 48          H   :0be5[1]
    lda z_h                                                           ; 39e6: a5 21       .!  :0be6[1]
    pha                                                               ; 39e8: 48          H   :0be8[1]
.wait_for_fire2
    jsr read_both_controls                                            ; 39e9: 20 f1 16     .. :0be9[1]
    lda z_h                                                           ; 39ec: a5 21       .!  :0bec[1]
    ora #keymap_any_fire                                              ; 39ee: 09 cf       ..  :0bee[1]
    cmp #&ff                                                          ; 39f0: c9 ff       ..  :0bf0[1]
    beq wait_for_fire2                                                ; 39f2: f0 f5       ..  :0bf2[1]   ; wait for any key to be released
    pla                                                               ; 39f4: 68          h   :0bf4[1]
    sta z_h                                                           ; 39f5: 85 21       .!  :0bf5[1]
    pla                                                               ; 39f7: 68          h   :0bf7[1]
    sta z_l                                                           ; 39f8: 85 20       .   :0bf8[1]
    rts                                                               ; 39fa: 60          `   :0bfa[1]

.force_animate
    lda #<(768/6)                                                     ; 39fb: a9 80       ..  :0bfb[1]   ; we animate 1/6 tiles each time, this keeps each frame fast, and makes the frames that animate look 'random'
    sta z_c                                                           ; 39fd: 85 22       ."  :0bfd[1]
    lda #>(768/6)                                                     ; 39ff: a9 00       ..  :0bff[1]
    sta z_b                                                           ; 3a01: 85 23       .#  :0c01[1]
    lda #6                                                            ; 3a03: a9 06       ..  :0c03[1]
    sta z_e                                                           ; 3a05: 85 24       .$  :0c05[1]
    lda #0                                                            ; 3a07: a9 00       ..  :0c07[1]
    sta z_d                                                           ; 3a09: 85 25       .%  :0c09[1]
    inc z_b                                                           ; 3a0b: e6 23       .#  :0c0b[1]   ; we need to inc b for the loop to work
    lda #<tile_map2                                                   ; 3a0d: a9 00       ..  :0c0d[1]   ; we wipe tile_map2, to force an update of the tiles
    sta z_l                                                           ; 3a0f: 85 20       .   :0c0f[1]
    lda #>tile_map2                                                   ; 3a11: a9 33       .3  :0c11[1]
    sta z_h                                                           ; 3a13: 85 21       .!  :0c13[1]
    lda anim_tick                                                     ; 3a15: ad 28 36    .(6 :0c15[1]
    clc                                                               ; 3a18: 18          .   :0c18[1]
    adc #1                                                            ; 3a19: 69 01       i.  :0c19[1]
    cmp #6                                                            ; 3a1b: c9 06       ..  :0c1b[1]   ; see if the 6 sets have all been animated
    bne force_animate_update_l                                        ; 3a1d: d0 10       ..  :0c1d[1]
    lda anim_frame                                                    ; 3a1f: ad 1f 36    ..6 :0c1f[1]   ; all the frames have been animated, so we flip to showing the other frame
    eor #%00010000                                                    ; 3a22: 49 10       I.  :0c22[1]   ; we toggle bit 5, because there are 16 tiles max (0-15)
    sta anim_frame                                                    ; 3a24: 8d 1f 36    ..6 :0c24[1]
    lda #0                                                            ; 3a27: a9 00       ..  :0c27[1]   ; reset animation tick
    sta anim_tick                                                     ; 3a29: 8d 28 36    .(6 :0c29[1]
    jmp force_animate_again_b                                         ; 3a2c: 4c 37 0c    L7. :0c2c[1]

.force_animate_update_l
    sta anim_tick                                                     ; 3a2f: 8d 28 36    .(6 :0c2f[1]
    clc                                                               ; 3a32: 18          .   :0c32[1]
    adc z_l                                                           ; 3a33: 65 20       e   :0c33[1]
    sta z_l                                                           ; 3a35: 85 20       .   :0c35[1]
.force_animate_again_b
    ; need A=0 when loop starts
    ldy #0                                                            ; 3a37: a0 00       ..  :0c37[1]
    ldx #255                                                          ; 3a39: a2 ff       ..  :0c39[1]
.force_animate_again
    tya                                                               ; 3a3b: 98          .   :0c3b[1]
    cmp (z_l),y                                                       ; 3a3c: d1 20       .   :0c3c[1]   ; we don't mess with 0 tiles, as it slows things down and causes problems
    beq cell_skip                                                     ; 3a3e: f0 03       ..  :0c3e[1]
    txa                                                               ; 3a40: 8a          .   :0c40[1]
    sta (z_l),y                                                       ; 3a41: 91 20       .   :0c41[1]   ; set the 'oldtile' to 255... this forces a repaint
.cell_skip
    jsr add_hl_de                                                     ; 3a43: 20 e5 0e     .. :0c43[1]
    dec z_c                                                           ; 3a46: c6 22       ."  :0c46[1]
    bne force_animate_again                                           ; 3a48: d0 f1       ..  :0c48[1]
    dec z_b                                                           ; 3a4a: c6 23       .#  :0c4a[1]
    bne force_animate_again                                           ; 3a4c: d0 ed       ..  :0c4c[1]
    rts                                                               ; 3a4e: 60          `   :0c4e[1]

; clear the tilemap
.clear_screen
    lda #>tile_map                                                    ; 3a4f: a9 30       .0  :0c4f[1]
    sta z_h                                                           ; 3a51: 85 21       .!  :0c51[1]
    lda #<tile_map                                                    ; 3a53: a9 00       ..  :0c53[1]
    sta z_l                                                           ; 3a55: 85 20       .   :0c55[1]
    ldx #0                                                            ; 3a57: a2 00       ..  :0c57[1]
    jmp force_repaint_alt                                             ; 3a59: 4c 66 0c    Lf. :0c59[1]

; force a repaint of the whole tilemap (including blank spaces)
.force_repaint
    lda #>tile_map2                                                   ; 3a5c: a9 33       .3  :0c5c[1]
    sta z_h                                                           ; 3a5e: 85 21       .!  :0c5e[1]
    lda #<tile_map2                                                   ; 3a60: a9 00       ..  :0c60[1]
    sta z_l                                                           ; 3a62: 85 20       .   :0c62[1]
    ldx #&ff                                                          ; 3a64: a2 ff       ..  :0c64[1]
.force_repaint_alt
    lda #>(768-1)                                                     ; 3a66: a9 02       ..  :0c66[1]
    sta z_b                                                           ; 3a68: 85 23       .#  :0c68[1]
    lda #<(768-1)                                                     ; 3a6a: a9 ff       ..  :0c6a[1]
    sta z_c                                                           ; 3a6c: 85 22       ."  :0c6c[1]
    txa                                                               ; 3a6e: 8a          .   :0c6e[1]
    jmp set_memory                                                    ; 3a6f: 4c 7e 0e    L~. :0c6f[1]

.repaint_screen
    lda #screen_width_g - 1                                           ; 3a72: a9 1f       ..  :0c72[1]   ; we start at the right of the screen, so our loops end when they reach zero
    sta z_ixh                                                         ; 3a74: 85 29       .)  :0c74[1]
    lda #screen_height_g - 2                                          ; 3a76: a9 16       ..  :0c76[1]
    sta z_ixl                                                         ; 3a78: 85 28       .(  :0c78[1]
    jsr do_fill                                                       ; 3a7a: 20 9b 0c     .. :0c7a[1]
    lda #screen_width_g - 2                                           ; 3a7d: a9 1e       ..  :0c7d[1]
    sta z_ixh                                                         ; 3a7f: 85 29       .)  :0c7f[1]
    lda #screen_height_g - 1                                          ; 3a81: a9 17       ..  :0c81[1]
    sta z_ixl                                                         ; 3a83: 85 28       .(  :0c83[1]
    jsr do_fill                                                       ; 3a85: 20 9b 0c     .. :0c85[1]
    lda #screen_width_g - 1                                           ; 3a88: a9 1f       ..  :0c88[1]
    sta z_ixh                                                         ; 3a8a: 85 29       .)  :0c8a[1]
    lda #screen_height_g - 1                                          ; 3a8c: a9 17       ..  :0c8c[1]
    sta z_ixl                                                         ; 3a8e: 85 28       .(  :0c8e[1]
    jsr do_fill                                                       ; 3a90: 20 9b 0c     .. :0c90[1]
    lda #screen_width_g - 2                                           ; 3a93: a9 1e       ..  :0c93[1]
    sta z_ixh                                                         ; 3a95: 85 29       .)  :0c95[1]
    lda #screen_height_g - 2                                          ; 3a97: a9 16       ..  :0c97[1]
    sta z_ixl                                                         ; 3a99: 85 28       .(  :0c99[1]
.do_fill
    ldx z_ixl                                                         ; 3a9b: a6 28       .(  :0c9b[1]
.fill_c_again
    lda #0                                                            ; 3a9d: a9 00       ..  :0c9d[1]   ; unwrapped version of find_tile
    sta z_l                                                           ; 3a9f: 85 20       .   :0c9f[1]
    txa                                                               ; 3aa1: 8a          .   :0ca1[1]
    sta z_c                                                           ; 3aa2: 85 22       ."  :0ca2[1]
    clc                                                               ; 3aa4: 18          .   :0ca4[1]
    ror a                                                             ; 3aa5: 6a          j   :0ca5[1]
    ror z_l                                                           ; 3aa6: 66 20       f   :0ca6[1]
    ror a                                                             ; 3aa8: 6a          j   :0ca8[1]
    ror z_l                                                           ; 3aa9: 66 20       f   :0ca9[1]
    ror a                                                             ; 3aab: 6a          j   :0cab[1]
    ror z_l                                                           ; 3aac: 66 20       f   :0cac[1]
    clc                                                               ; 3aae: 18          .   :0cae[1]
    adc #>tile_map                                                    ; 3aaf: 69 30       i0  :0caf[1]
    sta z_h                                                           ; 3ab1: 85 21       .!  :0cb1[1]
    clc                                                               ; 3ab3: 18          .   :0cb3[1]
    lda z_h                                                           ; 3ab4: a5 21       .!  :0cb4[1]
    adc #3                                                            ; 3ab6: 69 03       i.  :0cb6[1]
    sta z_d                                                           ; 3ab8: 85 25       .%  :0cb8[1]
    lda z_l                                                           ; 3aba: a5 20       .   :0cba[1]
    sta z_e                                                           ; 3abc: 85 24       .$  :0cbc[1]
    lda z_ixh                                                         ; 3abe: a5 29       .)  :0cbe[1]
    tay                                                               ; 3ac0: a8          .   :0cc0[1]
.fill_b_again
    lda (z_l),y                                                       ; 3ac1: b1 20       .   :0cc1[1]   ; live tile
    cmp (z_e),y                                                       ; 3ac3: d1 24       .$  :0cc3[1]   ; compare new tile to old one
    beq fill_b_again_unchanged                                        ; 3ac5: f0 21       .!  :0cc5[1]
    sta (z_e),y                                                       ; 3ac7: 91 24       .$  :0cc7[1]   ; update old tile
    ora anim_frame                                                    ; 3ac9: 0d 1f 36    ..6 :0cc9[1]
    tax                                                               ; 3acc: aa          .   :0ccc[1]
    sty z_b                                                           ; 3acd: 84 23       .#  :0ccd[1]
    lda z_l                                                           ; 3acf: a5 20       .   :0ccf[1]
    pha                                                               ; 3ad1: 48          H   :0cd1[1]
    lda z_h                                                           ; 3ad2: a5 21       .!  :0cd2[1]
    pha                                                               ; 3ad4: 48          H   :0cd4[1]
    txa                                                               ; 3ad5: 8a          .   :0cd5[1]
    jsr show_tile                                                     ; 3ad6: 20 a5 17     .. :0cd6[1]
    pla                                                               ; 3ad9: 68          h   :0cd9[1]
    sta z_h                                                           ; 3ada: 85 21       .!  :0cda[1]   ; get source back
    clc                                                               ; 3adc: 18          .   :0cdc[1]
    adc #3                                                            ; 3add: 69 03       i.  :0cdd[1]   ; recalculate old tilemap pos
    sta z_d                                                           ; 3adf: 85 25       .%  :0cdf[1]
    pla                                                               ; 3ae1: 68          h   :0ce1[1]
    sta z_e                                                           ; 3ae2: 85 24       .$  :0ce2[1]   ; tilemaps are byte aligned
    sta z_l                                                           ; 3ae4: 85 20       .   :0ce4[1]
    ldy z_b                                                           ; 3ae6: a4 23       .#  :0ce6[1]
.fill_b_again_unchanged
    dey                                                               ; 3ae8: 88          .   :0ce8[1]
    dey                                                               ; 3ae9: 88          .   :0ce9[1]
    bpl fill_b_again                                                  ; 3aea: 10 d5       ..  :0cea[1]   ; see if we've gone past zero
    ldx z_c                                                           ; 3aec: a6 22       ."  :0cec[1]
    dex                                                               ; 3aee: ca          .   :0cee[1]
    dex                                                               ; 3aef: ca          .   :0cef[1]
    bpl fill_c_again                                                  ; 3af0: 10 ab       ..  :0cf0[1]   ; see if we've gone past zero
    rts                                                               ; 3af2: 60          `   :0cf2[1]

; convert a BC (XY) coordinate to a memory_location
.find_tile
    lda #0                                                            ; 3af3: a9 00       ..  :0cf3[1]
    sta z_l                                                           ; 3af5: 85 20       .   :0cf5[1]
    lda z_c                                                           ; 3af7: a5 22       ."  :0cf7[1]
    clc                                                               ; 3af9: 18          .   :0cf9[1]
    ror a                                                             ; 3afa: 6a          j   :0cfa[1]
    ror z_l                                                           ; 3afb: 66 20       f   :0cfb[1]
    ror a                                                             ; 3afd: 6a          j   :0cfd[1]
    ror z_l                                                           ; 3afe: 66 20       f   :0cfe[1]
    ror a                                                             ; 3b00: 6a          j   :0d00[1]
    ror z_l                                                           ; 3b01: 66 20       f   :0d01[1]
    clc                                                               ; 3b03: 18          .   :0d03[1]
    adc #>tile_map                                                    ; 3b04: 69 30       i0  :0d04[1]
    sta z_h                                                           ; 3b06: 85 21       .!  :0d06[1]
    lda z_l                                                           ; 3b08: a5 20       .   :0d08[1]
    clc                                                               ; 3b0a: 18          .   :0d0a[1]
    adc z_b                                                           ; 3b0b: 65 23       e#  :0d0b[1]
    sta z_l                                                           ; 3b0d: 85 20       .   :0d0d[1]
    rts                                                               ; 3b0f: 60          `   :0d0f[1]

; ***************************************
; draw the tile
; ***************************************
.render_tile
    jsr find_tile                                                     ; 3b10: 20 f3 0c     .. :0d10[1]
    lda (z_l),y                                                       ; 3b13: b1 20       .   :0d13[1]   ; get the tile number
    ora anim_frame                                                    ; 3b15: 0d 1f 36    ..6 :0d15[1]   ; read in our animation frame (0-15)
    jmp show_tile                                                     ; 3b18: 4c a5 17    L.. :0d18[1]

    ; unused debugging tools ('monitor')
    pha                                                               ; 3b1b: 48          H   :0d1b[1]   ; push A,X,Y onto the stack
    txa                                                               ; 3b1c: 8a          .   :0d1c[1]
    pha                                                               ; 3b1d: 48          H   :0d1d[1]
    tya                                                               ; 3b1e: 98          .   :0d1e[1]
    pha                                                               ; 3b1f: 48          H   :0d1f[1]
    tay                                                               ; 3b20: a8          .   :0d20[1]
    tsx                                                               ; 3b21: ba          .   :0d21[1]
    lda l0104,x                                                       ; 3b22: bd 04 01    ... :0d22[1]
    sta t_RetAddrL                                                    ; 3b25: 85 29       .)  :0d25[1]
    lda l0105,x                                                       ; 3b27: bd 05 01    ... :0d27[1]
    sta t_RetAddrH                                                    ; 3b2a: 85 2a       .*  :0d2a[1]
    ldy #1                                                            ; 3b2c: a0 01       ..  :0d2c[1]
    lda (z_ixh),y                                                     ; 3b2e: b1 29       .)  :0d2e[1]
    sta t_MemdumpL                                                    ; 3b30: 85 2e       ..  :0d30[1]
    iny                                                               ; 3b32: c8          .   :0d32[1]   ; Y=&02
    lda (z_ixh),y                                                     ; 3b33: b1 29       .)  :0d33[1]
    sta t_MemdumpH                                                    ; 3b35: 85 2f       ./  :0d35[1]
    iny                                                               ; 3b37: c8          .   :0d37[1]   ; Y=&03
    lda (z_ixh),y                                                     ; 3b38: b1 29       .)  :0d38[1]
    tax                                                               ; 3b3a: aa          .   :0d3a[1]
    jsr mem_dump_direct_b                                             ; 3b3b: 20 5a 0d     Z. :0d3b[1]
    tsx                                                               ; 3b3e: ba          .   :0d3e[1]
    inc l0104,x                                                       ; 3b3f: fe 04 01    ... :0d3f[1]
    inc l0104,x                                                       ; 3b42: fe 04 01    ... :0d42[1]
    inc l0104,x                                                       ; 3b45: fe 04 01    ... :0d45[1]
    lda l0104,x                                                       ; 3b48: bd 04 01    ... :0d48[1]
    cmp #3                                                            ; 3b4b: c9 03       ..  :0d4b[1]
    bcs mem_dump_no_inc_sp_h                                          ; 3b4d: b0 03       ..  :0d4d[1]
    inc l0105,x                                                       ; 3b4f: fe 05 01    ... :0d4f[1]
.mem_dump_no_inc_sp_h
    pla                                                               ; 3b52: 68          h   :0d52[1]   ; pull A,X,Y from the stack
    tay                                                               ; 3b53: a8          .   :0d53[1]
    pla                                                               ; 3b54: 68          h   :0d54[1]
    tax                                                               ; 3b55: aa          .   :0d55[1]
    pla                                                               ; 3b56: 68          h   :0d56[1]
    rts                                                               ; 3b57: 60          `   :0d57[1]

    ldy #8                                                            ; 3b58: a0 08       ..  :0d58[1]
.mem_dump_direct_b
    lda t_MemdumpH                                                    ; 3b5a: a5 2f       ./  :0d5a[1]
    sta t_MemdumpBH                                                   ; 3b5c: 85 31       .1  :0d5c[1]
    jsr print_hex                                                     ; 3b5e: 20 29 0e     ). :0d5e[1]
    lda t_MemdumpL                                                    ; 3b61: a5 2e       ..  :0d61[1]
    sta t_MemdumpBL                                                   ; 3b63: 85 30       .0  :0d63[1]
    jsr print_hex                                                     ; 3b65: 20 29 0e     ). :0d65[1]
    lda #':'                                                          ; 3b68: a9 3a       .:  :0d68[1]
    jsr print_char                                                    ; 3b6a: 20 6f 18     o. :0d6a[1]
    jsr newline                                                       ; 3b6d: 20 3f 19     ?. :0d6d[1]
    ldy #0                                                            ; 3b70: a0 00       ..  :0d70[1]
.mem_dump_again
    tya                                                               ; 3b72: 98          .   :0d72[1]
    pha                                                               ; 3b73: 48          H   :0d73[1]
.mem_dump_again_hex
    lda (t_MemdumpL),y                                                ; 3b74: b1 2e       ..  :0d74[1]
    jsr print_hex                                                     ; 3b76: 20 29 0e     ). :0d76[1]
    lda #' '                                                          ; 3b79: a9 20       .   :0d79[1]
    jsr print_char                                                    ; 3b7b: 20 6f 18     o. :0d7b[1]
    iny                                                               ; 3b7e: c8          .   :0d7e[1]
    tya                                                               ; 3b7f: 98          .   :0d7f[1]
    and #7                                                            ; 3b80: 29 07       ).  :0d80[1]
    bne mem_dump_again_hex                                            ; 3b82: d0 f0       ..  :0d82[1]
    pla                                                               ; 3b84: 68          h   :0d84[1]
    tay                                                               ; 3b85: a8          .   :0d85[1]
.mem_dump_again_char
    lda (t_MemdumpBL),y                                               ; 3b86: b1 30       .0  :0d86[1]
; BUG: this should be cmp #32
    cmp BUG_should_be_cmp_hash_32                                     ; 3b88: c5 01       ..  :0d88[1]
    bcc mem_dump_bad_char                                             ; 3b8a: 90 14       ..  :0d8a[1]
    cmp #&80                                                          ; 3b8c: c9 80       ..  :0d8c[1]
    bcs mem_dump_bad_char                                             ; 3b8e: b0 10       ..  :0d8e[1]
.mem_dump_again_char_ret
    jsr print_char                                                    ; 3b90: 20 6f 18     o. :0d90[1]
    iny                                                               ; 3b93: c8          .   :0d93[1]
    tya                                                               ; 3b94: 98          .   :0d94[1]
    and #7                                                            ; 3b95: 29 07       ).  :0d95[1]
    bne mem_dump_again_char                                           ; 3b97: d0 ed       ..  :0d97[1]
    jsr newline                                                       ; 3b99: 20 3f 19     ?. :0d99[1]
    dex                                                               ; 3b9c: ca          .   :0d9c[1]
    bne mem_dump_again                                                ; 3b9d: d0 d3       ..  :0d9d[1]
    rts                                                               ; 3b9f: 60          `   :0d9f[1]

.mem_dump_bad_char
    lda #'.'                                                          ; 3ba0: a9 2e       ..  :0da0[1]
    jmp mem_dump_again_char_ret                                       ; 3ba2: 4c 90 0d    L.. :0da2[1]

.monitor
    php                                                               ; 3ba5: 08          .   :0da5[1]
    pha                                                               ; 3ba6: 48          H   :0da6[1]
    lda #'a'                                                          ; 3ba7: a9 61       .a  :0da7[1]
    jsr print_A_colon                                                 ; 3ba9: 20 09 0e     .. :0da9[1]
    pla                                                               ; 3bac: 68          h   :0dac[1]
    pha                                                               ; 3bad: 48          H   :0dad[1]
    jsr print_hex_and_space                                           ; 3bae: 20 11 0e     .. :0dae[1]
    txa                                                               ; 3bb1: 8a          .   :0db1[1]   ; push X,Y onto the stack
    pha                                                               ; 3bb2: 48          H   :0db2[1]
    tya                                                               ; 3bb3: 98          .   :0db3[1]
    pha                                                               ; 3bb4: 48          H   :0db4[1]
    lda #'x'                                                          ; 3bb5: a9 78       .x  :0db5[1]
    jsr print_A_colon                                                 ; 3bb7: 20 09 0e     .. :0db7[1]
    txa                                                               ; 3bba: 8a          .   :0dba[1]
    jsr print_hex_and_space                                           ; 3bbb: 20 11 0e     .. :0dbb[1]
    lda #'y'                                                          ; 3bbe: a9 79       .y  :0dbe[1]
    jsr print_A_colon                                                 ; 3bc0: 20 09 0e     .. :0dc0[1]
    tya                                                               ; 3bc3: 98          .   :0dc3[1]
    jsr print_hex_and_space                                           ; 3bc4: 20 11 0e     .. :0dc4[1]
    lda #'s'                                                          ; 3bc7: a9 73       .s  :0dc7[1]
    jsr print_A_colon                                                 ; 3bc9: 20 09 0e     .. :0dc9[1]
    tsx                                                               ; 3bcc: ba          .   :0dcc[1]
    txa                                                               ; 3bcd: 8a          .   :0dcd[1]
    clc                                                               ; 3bce: 18          .   :0dce[1]
    adc #6                                                            ; 3bcf: 69 06       i.  :0dcf[1]
    jsr print_hex_and_space                                           ; 3bd1: 20 11 0e     .. :0dd1[1]
    lda #'f'                                                          ; 3bd4: a9 66       .f  :0dd4[1]
    jsr print_A_colon                                                 ; 3bd6: 20 09 0e     .. :0dd6[1]
    tsx                                                               ; 3bd9: ba          .   :0dd9[1]
    txa                                                               ; 3bda: 8a          .   :0dda[1]   ; add 4 to X
    clc                                                               ; 3bdb: 18          .   :0ddb[1]
    adc #4                                                            ; 3bdc: 69 04       i.  :0ddc[1]
    tax                                                               ; 3bde: aa          .   :0dde[1]
    lda l0100,x                                                       ; 3bdf: bd 00 01    ... :0ddf[1]
    jsr print_hex_and_space                                           ; 3be2: 20 11 0e     .. :0de2[1]
    lda #'p'                                                          ; 3be5: a9 70       .p  :0de5[1]
    jsr print_A_colon                                                 ; 3be7: 20 09 0e     .. :0de7[1]
    tsx                                                               ; 3bea: ba          .   :0dea[1]
    txa                                                               ; 3beb: 8a          .   :0deb[1]
    clc                                                               ; 3bec: 18          .   :0dec[1]
    adc #5                                                            ; 3bed: 69 05       i.  :0ded[1]
    pha                                                               ; 3bef: 48          H   :0def[1]
    tax                                                               ; 3bf0: aa          .   :0df0[1]
    lda l0101,x                                                       ; 3bf1: bd 01 01    ... :0df1[1]
    jsr print_hex                                                     ; 3bf4: 20 29 0e     ). :0df4[1]
    pla                                                               ; 3bf7: 68          h   :0df7[1]
    tax                                                               ; 3bf8: aa          .   :0df8[1]
    lda l0100,x                                                       ; 3bf9: bd 00 01    ... :0df9[1]
    jsr print_hex                                                     ; 3bfc: 20 29 0e     ). :0dfc[1]
    jsr newline                                                       ; 3bff: 20 3f 19     ?. :0dff[1]
    pla                                                               ; 3c02: 68          h   :0e02[1]   ; pull flags,A,X,Y from the stack
    tay                                                               ; 3c03: a8          .   :0e03[1]
    pla                                                               ; 3c04: 68          h   :0e04[1]
    tax                                                               ; 3c05: aa          .   :0e05[1]
    pla                                                               ; 3c06: 68          h   :0e06[1]
    plp                                                               ; 3c07: 28          (   :0e07[1]
    rts                                                               ; 3c08: 60          `   :0e08[1]

.print_A_colon
    jsr print_char                                                    ; 3c09: 20 6f 18     o. :0e09[1]
    lda #&3a                                                          ; 3c0c: a9 3a       .:  :0e0c[1]
    jmp print_char                                                    ; 3c0e: 4c 6f 18    Lo. :0e0e[1]

.print_hex_and_space
    jsr print_hex                                                     ; 3c11: 20 29 0e     ). :0e11[1]
    lda #&20                                                          ; 3c14: a9 20       .   :0e14[1]
    jmp print_char                                                    ; 3c16: 4c 6f 18    Lo. :0e16[1]

.keymap_U
    equb %00000001                                                    ; 3c19: 01          .   :0e19[1]   ; bitmask
.keymap_D
    equb %00000010                                                    ; 3c1a: 02          .   :0e1a[1]
.keymap_L
    equb %00000100                                                    ; 3c1b: 04          .   :0e1b[1]
.keymap_R
    equb %00001000                                                    ; 3c1c: 08          .   :0e1c[1]
.keymap_F1
    equb %00010000                                                    ; 3c1d: 10          .   :0e1d[1]
.keymap_F2
    equb %00100000                                                    ; 3c1e: 20              :0e1e[1]
.keymap_F3
    equb %01000000                                                    ; 3c1f: 40          @   :0e1f[1]
.keymap_PAUSE
    equb %10000000                                                    ; 3c20: 80          .   :0e20[1]

.not_bit0
    equb %11111110                                                    ; 3c21: fe          .   :0e21[1]
.not_bit1
    equb %11111101                                                    ; 3c22: fd          .   :0e22[1]
.not_bit2
    equb %11111011                                                    ; 3c23: fb          .   :0e23[1]
.not_bit3
    equb %11110111                                                    ; 3c24: f7          .   :0e24[1]
.not_bit4
    equb %11101111                                                    ; 3c25: ef          .   :0e25[1]
.not_bit5
    equb %11011111                                                    ; 3c26: df          .   :0e26[1]
.not_bit6
    equb %10111111                                                    ; 3c27: bf          .   :0e27[1]
.not_bit7
    equb %01111111                                                    ; 3c28: 7f          .   :0e28[1]

.print_hex
    pha                                                               ; 3c29: 48          H   :0e29[1]
    clc                                                               ; 3c2a: 18          .   :0e2a[1]
    and #&f0                                                          ; 3c2b: 29 f0       ).  :0e2b[1]
    ror a                                                             ; 3c2d: 6a          j   :0e2d[1]
    ror a                                                             ; 3c2e: 6a          j   :0e2e[1]
    ror a                                                             ; 3c2f: 6a          j   :0e2f[1]
    ror a                                                             ; 3c30: 6a          j   :0e30[1]
    jsr print_hex_digit                                               ; 3c31: 20 3d 0e     =. :0e31[1]
    pla                                                               ; 3c34: 68          h   :0e34[1]
    pha                                                               ; 3c35: 48          H   :0e35[1]
    and #&0f                                                          ; 3c36: 29 0f       ).  :0e36[1]
    jsr print_hex_digit                                               ; 3c38: 20 3d 0e     =. :0e38[1]
    pla                                                               ; 3c3b: 68          h   :0e3b[1]
    rts                                                               ; 3c3c: 60          `   :0e3c[1]

.print_hex_digit
    cmp #10                                                           ; 3c3d: c9 0a       ..  :0e3d[1]
    bcs print_hex_letter                                              ; 3c3f: b0 07       ..  :0e3f[1]
    clc                                                               ; 3c41: 18          .   :0e41[1]
    adc #'0'                                                          ; 3c42: 69 30       i0  :0e42[1]
    jsr print_char                                                    ; 3c44: 20 6f 18     o. :0e44[1]
    rts                                                               ; 3c47: 60          `   :0e47[1]

.print_hex_letter
    clc                                                               ; 3c48: 18          .   :0e48[1]
    adc #&37                                                          ; 3c49: 69 37       i7  :0e49[1]
    jsr print_char                                                    ; 3c4b: 20 6f 18     o. :0e4b[1]
    rts                                                               ; 3c4e: 60          `   :0e4e[1]

.print_message_hl
    ldy #0                                                            ; 3c4f: a0 00       ..  :0e4f[1]
.print_message_loop
    lda (z_l),y                                                       ; 3c51: b1 20       .   :0e51[1]
    cmp #&ff                                                          ; 3c53: c9 ff       ..  :0e53[1]
    beq return_1                                                      ; 3c55: f0 07       ..  :0e55[1]
    jsr print_char                                                    ; 3c57: 20 6f 18     o. :0e57[1]
    iny                                                               ; 3c5a: c8          .   :0e5a[1]
    jmp print_message_loop                                            ; 3c5b: 4c 51 0e    LQ. :0e5b[1]

.return_1
    rts                                                               ; 3c5e: 60          `   :0e5e[1]

; unused?
.read_char
    tya                                                               ; 3c5f: 98          .   :0e5f[1]
    pha                                                               ; 3c60: 48          H   :0e60[1]
.read_char_loop
    ; BUG: Should be $ffe0 for OSRDCH. It looks like this is C64 code to read from the
    ; keyboard.
    jsr BUG_c64_READ                                                  ; 3c61: 20 e4 ff     .. :0e61[1]
    beq read_char_loop                                                ; 3c64: f0 fb       ..  :0e64[1]
    sta t_a                                                           ; 3c66: 85 2b       .+  :0e66[1]
    pla                                                               ; 3c68: 68          h   :0e68[1]
    tay                                                               ; 3c69: a8          .   :0e69[1]
    lda t_a                                                           ; 3c6a: a5 2b       .+  :0e6a[1]
    rts                                                               ; 3c6c: 60          `   :0e6c[1]

; unused?
.swap_xy
    pha                                                               ; 3c6d: 48          H   :0e6d[1]   ; push A,X onto the stack
    txa                                                               ; 3c6e: 8a          .   :0e6e[1]
    pha                                                               ; 3c6f: 48          H   :0e6f[1]
    tya                                                               ; 3c70: 98          .   :0e70[1]
    tax                                                               ; 3c71: aa          .   :0e71[1]
    pla                                                               ; 3c72: 68          h   :0e72[1]   ; pull A,Y from the stack
    tay                                                               ; 3c73: a8          .   :0e73[1]
    pla                                                               ; 3c74: 68          h   :0e74[1]
    rts                                                               ; 3c75: 60          `   :0e75[1]

; unused?
.get_pos
    sec                                                               ; 3c76: 38          8   :0e76[1]
; BUG: Random call into middle of OS. This looks like C64 code. It is calling C64's
; PLOT routine, to get the cursor position
    jsr BUG_c64_PLOT                                                  ; 3c77: 20 0a e5     .. :0e77[1]
    jsr swap_xy                                                       ; 3c7a: 20 6d 0e     m. :0e7a[1]
    rts                                                               ; 3c7d: 60          `   :0e7d[1]

; Set memory to accumulator value from HL for BC bytes.
.set_memory
    ldy #0                                                            ; 3c7e: a0 00       ..  :0e7e[1]
    sta (z_l),y                                                       ; 3c80: 91 20       .   :0e80[1]
    lda z_l                                                           ; 3c82: a5 20       .   :0e82[1]
    clc                                                               ; 3c84: 18          .   :0e84[1]
    adc #1                                                            ; 3c85: 69 01       i.  :0e85[1]
    sta z_e                                                           ; 3c87: 85 24       .$  :0e87[1]
    lda #0                                                            ; 3c89: a9 00       ..  :0e89[1]
    adc z_h                                                           ; 3c8b: 65 21       e!  :0e8b[1]
    sta z_d                                                           ; 3c8d: 85 25       .%  :0e8d[1]
    ; fall through...

; copy memory from HL to DE for BC bytes
.copy_memory_loop
    ldy #0                                                            ; 3c8f: a0 00       ..  :0e8f[1]
    lda (z_l),y                                                       ; 3c91: b1 20       .   :0e91[1]
    sta (z_e),y                                                       ; 3c93: 91 24       .$  :0e93[1]
    inc z_l                                                           ; 3c95: e6 20       .   :0e95[1]
    bne c0e9b                                                         ; 3c97: d0 02       ..  :0e97[1]
    inc z_h                                                           ; 3c99: e6 21       .!  :0e99[1]
.c0e9b
    inc z_e                                                           ; 3c9b: e6 24       .$  :0e9b[1]
    bne c0ea1                                                         ; 3c9d: d0 02       ..  :0e9d[1]
    inc z_d                                                           ; 3c9f: e6 25       .%  :0e9f[1]
.c0ea1
    dec z_c                                                           ; 3ca1: c6 22       ."  :0ea1[1]
    bne copy_memory_loop                                              ; 3ca3: d0 ea       ..  :0ea3[1]
    lda z_b                                                           ; 3ca5: a5 23       .#  :0ea5[1]
    beq return_2                                                      ; 3ca7: f0 05       ..  :0ea7[1]
    dec z_b                                                           ; 3ca9: c6 23       .#  :0ea9[1]
    jmp copy_memory_loop                                              ; 3cab: 4c 8f 0e    L.. :0eab[1]

.return_2
    rts                                                               ; 3cae: 60          `   :0eae[1]

; unused?
.inc_bc
    inc z_c                                                           ; 3caf: e6 22       ."  :0eaf[1]
    bne return_3                                                      ; 3cb1: d0 02       ..  :0eb1[1]
    inc z_b                                                           ; 3cb3: e6 23       .#  :0eb3[1]
.return_3
    rts                                                               ; 3cb5: 60          `   :0eb5[1]

.inc_de
    inc z_e                                                           ; 3cb6: e6 24       .$  :0eb6[1]
    bne return_4                                                      ; 3cb8: d0 02       ..  :0eb8[1]
    inc z_d                                                           ; 3cba: e6 25       .%  :0eba[1]
.return_4
    rts                                                               ; 3cbc: 60          `   :0ebc[1]

.inc_hl
    inc z_l                                                           ; 3cbd: e6 20       .   :0ebd[1]
    bne return_5                                                      ; 3cbf: d0 02       ..  :0ebf[1]
    inc z_h                                                           ; 3cc1: e6 21       .!  :0ec1[1]
.return_5
    rts                                                               ; 3cc3: 60          `   :0ec3[1]

.dec_bc
    pha                                                               ; 3cc4: 48          H   :0ec4[1]
    lda z_c                                                           ; 3cc5: a5 22       ."  :0ec5[1]
    bne skip_dec1                                                     ; 3cc7: d0 02       ..  :0ec7[1]
    dec z_b                                                           ; 3cc9: c6 23       .#  :0ec9[1]
.skip_dec1
    dec z_c                                                           ; 3ccb: c6 22       ."  :0ecb[1]
    pla                                                               ; 3ccd: 68          h   :0ecd[1]
    rts                                                               ; 3cce: 60          `   :0ece[1]

.dec_hl
    pha                                                               ; 3ccf: 48          H   :0ecf[1]
    lda z_l                                                           ; 3cd0: a5 20       .   :0ed0[1]
    bne skip_dec2                                                     ; 3cd2: d0 02       ..  :0ed2[1]
    dec z_h                                                           ; 3cd4: c6 21       .!  :0ed4[1]
.skip_dec2
    dec z_l                                                           ; 3cd6: c6 20       .   :0ed6[1]
    pla                                                               ; 3cd8: 68          h   :0ed8[1]
    rts                                                               ; 3cd9: 60          `   :0ed9[1]

; unused?
.dec_de
    pha                                                               ; 3cda: 48          H   :0eda[1]
    lda z_e                                                           ; 3cdb: a5 24       .$  :0edb[1]
    bne skip_dec3                                                     ; 3cdd: d0 02       ..  :0edd[1]
    dec z_d                                                           ; 3cdf: c6 25       .%  :0edf[1]
.skip_dec3
    dec z_e                                                           ; 3ce1: c6 24       .$  :0ee1[1]
    pla                                                               ; 3ce3: 68          h   :0ee3[1]
    rts                                                               ; 3ce4: 60          `   :0ee4[1]

.add_hl_de
    clc                                                               ; 3ce5: 18          .   :0ee5[1]
    lda z_e                                                           ; 3ce6: a5 24       .$  :0ee6[1]
    adc z_l                                                           ; 3ce8: 65 20       e   :0ee8[1]
    sta z_l                                                           ; 3cea: 85 20       .   :0eea[1]
    lda z_d                                                           ; 3cec: a5 25       .%  :0eec[1]
    adc z_h                                                           ; 3cee: 65 21       e!  :0eee[1]
    sta z_h                                                           ; 3cf0: 85 21       .!  :0ef0[1]
    rts                                                               ; 3cf2: 60          `   :0ef2[1]

.add_hl_bc
    clc                                                               ; 3cf3: 18          .   :0ef3[1]
    lda z_c                                                           ; 3cf4: a5 22       ."  :0ef4[1]
    adc z_l                                                           ; 3cf6: 65 20       e   :0ef6[1]
    sta z_l                                                           ; 3cf8: 85 20       .   :0ef8[1]
    lda z_b                                                           ; 3cfa: a5 23       .#  :0efa[1]
    adc z_h                                                           ; 3cfc: 65 21       e!  :0efc[1]
    sta z_h                                                           ; 3cfe: 85 21       .!  :0efe[1]
    rts                                                               ; 3d00: 60          `   :0f00[1]

.sub_hl_bc
    sec                                                               ; 3d01: 38          8   :0f01[1]
    lda z_l                                                           ; 3d02: a5 20       .   :0f02[1]
    sbc z_c                                                           ; 3d04: e5 22       ."  :0f04[1]
    sta z_l                                                           ; 3d06: 85 20       .   :0f06[1]
    lda z_h                                                           ; 3d08: a5 21       .!  :0f08[1]
    sbc z_b                                                           ; 3d0a: e5 23       .#  :0f0a[1]
    sta z_h                                                           ; 3d0c: 85 21       .!  :0f0c[1]
    rts                                                               ; 3d0e: 60          `   :0f0e[1]

.sub_hl_de
    sec                                                               ; 3d0f: 38          8   :0f0f[1]
    lda z_l                                                           ; 3d10: a5 20       .   :0f10[1]
    sbc z_e                                                           ; 3d12: e5 24       .$  :0f12[1]
    sta z_l                                                           ; 3d14: 85 20       .   :0f14[1]
    lda z_h                                                           ; 3d16: a5 21       .!  :0f16[1]
    sbc z_d                                                           ; 3d18: e5 25       .%  :0f18[1]
    sta z_h                                                           ; 3d1a: 85 21       .!  :0f1a[1]
    rts                                                               ; 3d1c: 60          `   :0f1c[1]

.add_de_bc
    clc                                                               ; 3d1d: 18          .   :0f1d[1]
    lda z_c                                                           ; 3d1e: a5 22       ."  :0f1e[1]
    adc z_e                                                           ; 3d20: 65 24       e$  :0f20[1]
    sta z_e                                                           ; 3d22: 85 24       .$  :0f22[1]
    lda z_b                                                           ; 3d24: a5 23       .#  :0f24[1]
    adc z_d                                                           ; 3d26: 65 25       e%  :0f26[1]
    sta z_d                                                           ; 3d28: 85 25       .%  :0f28[1]
    rts                                                               ; 3d2a: 60          `   :0f2a[1]

.swap_nybbles
    asl a                                                             ; 3d2b: 0a          .   :0f2b[1]
    adc #&80                                                          ; 3d2c: 69 80       i.  :0f2c[1]
    rol a                                                             ; 3d2e: 2a          *   :0f2e[1]
    asl a                                                             ; 3d2f: 0a          .   :0f2f[1]
    adc #&80                                                          ; 3d30: 69 80       i.  :0f30[1]
    rol a                                                             ; 3d32: 2a          *   :0f32[1]
    rts                                                               ; 3d33: 60          `   :0f33[1]


.bitmap_font
    equb %00000000                                                    ; 3d34: 00          .   :0f34[1]
    equb %00000000                                                    ; 3d35: 00          .   :0f35[1]
    equb %00000000                                                    ; 3d36: 00          .   :0f36[1]
    equb %00000000                                                    ; 3d37: 00          .   :0f37[1]
    equb %00000000                                                    ; 3d38: 00          .   :0f38[1]
    equb %00000000                                                    ; 3d39: 00          .   :0f39[1]
    equb %00000000                                                    ; 3d3a: 00          .   :0f3a[1]
    equb %00000000                                                    ; 3d3b: 00          .   :0f3b[1]

    equb %00010000                                                    ; 3d3c: 10          .   :0f3c[1]
    equb %00011000                                                    ; 3d3d: 18          .   :0f3d[1]
    equb %00011000                                                    ; 3d3e: 18          .   :0f3e[1]
    equb %00011000                                                    ; 3d3f: 18          .   :0f3f[1]
    equb %00011000                                                    ; 3d40: 18          .   :0f40[1]
    equb %00000000                                                    ; 3d41: 00          .   :0f41[1]
    equb %00011000                                                    ; 3d42: 18          .   :0f42[1]
    equb %00000000                                                    ; 3d43: 00          .   :0f43[1]

    equb %00101000                                                    ; 3d44: 28          (   :0f44[1]
    equb %01101100                                                    ; 3d45: 6c          l   :0f45[1]
    equb %00101000                                                    ; 3d46: 28          (   :0f46[1]
    equb %00000000                                                    ; 3d47: 00          .   :0f47[1]
    equb %00000000                                                    ; 3d48: 00          .   :0f48[1]
    equb %00000000                                                    ; 3d49: 00          .   :0f49[1]
    equb %00000000                                                    ; 3d4a: 00          .   :0f4a[1]
    equb %00000000                                                    ; 3d4b: 00          .   :0f4b[1]

    equb %00000000                                                    ; 3d4c: 00          .   :0f4c[1]
    equb %00101000                                                    ; 3d4d: 28          (   :0f4d[1]
    equb %01111100                                                    ; 3d4e: 7c          |   :0f4e[1]
    equb %00101000                                                    ; 3d4f: 28          (   :0f4f[1]
    equb %01111100                                                    ; 3d50: 7c          |   :0f50[1]
    equb %00101000                                                    ; 3d51: 28          (   :0f51[1]
    equb %00000000                                                    ; 3d52: 00          .   :0f52[1]
    equb %00000000                                                    ; 3d53: 00          .   :0f53[1]

    equb %00011000                                                    ; 3d54: 18          .   :0f54[1]
    equb %00111110                                                    ; 3d55: 3e          >   :0f55[1]
    equb %01001000                                                    ; 3d56: 48          H   :0f56[1]
    equb %00111100                                                    ; 3d57: 3c          <   :0f57[1]
    equb %00010010                                                    ; 3d58: 12          .   :0f58[1]
    equb %01111100                                                    ; 3d59: 7c          |   :0f59[1]
    equb %00011000                                                    ; 3d5a: 18          .   :0f5a[1]
    equb %00000000                                                    ; 3d5b: 00          .   :0f5b[1]

    equb %00000010                                                    ; 3d5c: 02          .   :0f5c[1]
    equb %11000100                                                    ; 3d5d: c4          .   :0f5d[1]
    equb %11001000                                                    ; 3d5e: c8          .   :0f5e[1]
    equb %00010000                                                    ; 3d5f: 10          .   :0f5f[1]
    equb %00100000                                                    ; 3d60: 20              :0f60[1]
    equb %01000110                                                    ; 3d61: 46          F   :0f61[1]
    equb %10000110                                                    ; 3d62: 86          .   :0f62[1]
    equb %00000000                                                    ; 3d63: 00          .   :0f63[1]

    equb %00010000                                                    ; 3d64: 10          .   :0f64[1]
    equb %00101000                                                    ; 3d65: 28          (   :0f65[1]
    equb %00101000                                                    ; 3d66: 28          (   :0f66[1]
    equb %01110010                                                    ; 3d67: 72          r   :0f67[1]
    equb %10010100                                                    ; 3d68: 94          .   :0f68[1]
    equb %10001100                                                    ; 3d69: 8c          .   :0f69[1]
    equb %01110010                                                    ; 3d6a: 72          r   :0f6a[1]
    equb %00000000                                                    ; 3d6b: 00          .   :0f6b[1]

    equb %00001100                                                    ; 3d6c: 0c          .   :0f6c[1]
    equb %00011100                                                    ; 3d6d: 1c          .   :0f6d[1]
    equb %00110000                                                    ; 3d6e: 30          0   :0f6e[1]
    equb %00000000                                                    ; 3d6f: 00          .   :0f6f[1]
    equb %00000000                                                    ; 3d70: 00          .   :0f70[1]
    equb %00000000                                                    ; 3d71: 00          .   :0f71[1]
    equb %00000000                                                    ; 3d72: 00          .   :0f72[1]
    equb %00000000                                                    ; 3d73: 00          .   :0f73[1]

    equb %00011000                                                    ; 3d74: 18          .   :0f74[1]
    equb %00011000                                                    ; 3d75: 18          .   :0f75[1]
    equb %00110000                                                    ; 3d76: 30          0   :0f76[1]
    equb %00110000                                                    ; 3d77: 30          0   :0f77[1]
    equb %00110000                                                    ; 3d78: 30          0   :0f78[1]
    equb %00011000                                                    ; 3d79: 18          .   :0f79[1]
    equb %00011000                                                    ; 3d7a: 18          .   :0f7a[1]
    equb %00000000                                                    ; 3d7b: 00          .   :0f7b[1]

    equb %00011000                                                    ; 3d7c: 18          .   :0f7c[1]
    equb %00011000                                                    ; 3d7d: 18          .   :0f7d[1]
    equb %00001100                                                    ; 3d7e: 0c          .   :0f7e[1]
    equb %00001100                                                    ; 3d7f: 0c          .   :0f7f[1]
    equb %00001100                                                    ; 3d80: 0c          .   :0f80[1]
    equb %00011000                                                    ; 3d81: 18          .   :0f81[1]
    equb %00011000                                                    ; 3d82: 18          .   :0f82[1]
    equb %00000000                                                    ; 3d83: 00          .   :0f83[1]

    equb %00001000                                                    ; 3d84: 08          .   :0f84[1]
    equb %01001001                                                    ; 3d85: 49          I   :0f85[1]
    equb %00101010                                                    ; 3d86: 2a          *   :0f86[1]
    equb %00011100                                                    ; 3d87: 1c          .   :0f87[1]
    equb %00010100                                                    ; 3d88: 14          .   :0f88[1]
    equb %00100010                                                    ; 3d89: 22          "   :0f89[1]
    equb %01000001                                                    ; 3d8a: 41          A   :0f8a[1]
    equb %00000000                                                    ; 3d8b: 00          .   :0f8b[1]

    equb %00000000                                                    ; 3d8c: 00          .   :0f8c[1]
    equb %00011000                                                    ; 3d8d: 18          .   :0f8d[1]
    equb %00011000                                                    ; 3d8e: 18          .   :0f8e[1]
    equb %01111110                                                    ; 3d8f: 7e          ~   :0f8f[1]
    equb %00011000                                                    ; 3d90: 18          .   :0f90[1]
    equb %00011000                                                    ; 3d91: 18          .   :0f91[1]
    equb %00000000                                                    ; 3d92: 00          .   :0f92[1]
    equb %00000000                                                    ; 3d93: 00          .   :0f93[1]

    equb %00000000                                                    ; 3d94: 00          .   :0f94[1]
    equb %00000000                                                    ; 3d95: 00          .   :0f95[1]
    equb %00000000                                                    ; 3d96: 00          .   :0f96[1]
    equb %00000000                                                    ; 3d97: 00          .   :0f97[1]
    equb %00000000                                                    ; 3d98: 00          .   :0f98[1]
    equb %00011000                                                    ; 3d99: 18          .   :0f99[1]
    equb %00011000                                                    ; 3d9a: 18          .   :0f9a[1]
    equb %00110000                                                    ; 3d9b: 30          0   :0f9b[1]

    equb %00000000                                                    ; 3d9c: 00          .   :0f9c[1]
    equb %00000000                                                    ; 3d9d: 00          .   :0f9d[1]
    equb %00000000                                                    ; 3d9e: 00          .   :0f9e[1]
    equb %01111110                                                    ; 3d9f: 7e          ~   :0f9f[1]
    equb %01111110                                                    ; 3da0: 7e          ~   :0fa0[1]
    equb %00000000                                                    ; 3da1: 00          .   :0fa1[1]
    equb %00000000                                                    ; 3da2: 00          .   :0fa2[1]
    equb %00000000                                                    ; 3da3: 00          .   :0fa3[1]

    equb %00000000                                                    ; 3da4: 00          .   :0fa4[1]
    equb %00000000                                                    ; 3da5: 00          .   :0fa5[1]
    equb %00000000                                                    ; 3da6: 00          .   :0fa6[1]
    equb %00000000                                                    ; 3da7: 00          .   :0fa7[1]
    equb %00000000                                                    ; 3da8: 00          .   :0fa8[1]
    equb %00011000                                                    ; 3da9: 18          .   :0fa9[1]
    equb %00011000                                                    ; 3daa: 18          .   :0faa[1]
    equb %00000000                                                    ; 3dab: 00          .   :0fab[1]

    equb %00000010                                                    ; 3dac: 02          .   :0fac[1]
    equb %00000100                                                    ; 3dad: 04          .   :0fad[1]
    equb %00001000                                                    ; 3dae: 08          .   :0fae[1]
    equb %00010000                                                    ; 3daf: 10          .   :0faf[1]
    equb %00100000                                                    ; 3db0: 20              :0fb0[1]
    equb %01000000                                                    ; 3db1: 40          @   :0fb1[1]
    equb %10000000                                                    ; 3db2: 80          .   :0fb2[1]
    equb %00000000                                                    ; 3db3: 00          .   :0fb3[1]

    equb %01111100                                                    ; 3db4: 7c          |   :0fb4[1]
    equb %11000110                                                    ; 3db5: c6          .   :0fb5[1]
    equb %11010110                                                    ; 3db6: d6          .   :0fb6[1]
    equb %11010110                                                    ; 3db7: d6          .   :0fb7[1]
    equb %11010110                                                    ; 3db8: d6          .   :0fb8[1]
    equb %11000110                                                    ; 3db9: c6          .   :0fb9[1]
    equb %01111100                                                    ; 3dba: 7c          |   :0fba[1]
    equb %00000000                                                    ; 3dbb: 00          .   :0fbb[1]

    equb %00010000                                                    ; 3dbc: 10          .   :0fbc[1]
    equb %00011000                                                    ; 3dbd: 18          .   :0fbd[1]
    equb %00011000                                                    ; 3dbe: 18          .   :0fbe[1]
    equb %00011000                                                    ; 3dbf: 18          .   :0fbf[1]
    equb %00011000                                                    ; 3dc0: 18          .   :0fc0[1]
    equb %00011000                                                    ; 3dc1: 18          .   :0fc1[1]
    equb %00001000                                                    ; 3dc2: 08          .   :0fc2[1]
    equb %00000000                                                    ; 3dc3: 00          .   :0fc3[1]

    equb %00111100                                                    ; 3dc4: 3c          <   :0fc4[1]
    equb %01111110                                                    ; 3dc5: 7e          ~   :0fc5[1]
    equb %00000110                                                    ; 3dc6: 06          .   :0fc6[1]
    equb %00111100                                                    ; 3dc7: 3c          <   :0fc7[1]
    equb %01100000                                                    ; 3dc8: 60          `   :0fc8[1]
    equb %01111110                                                    ; 3dc9: 7e          ~   :0fc9[1]
    equb %00111100                                                    ; 3dca: 3c          <   :0fca[1]
    equb %00000000                                                    ; 3dcb: 00          .   :0fcb[1]

    equb %00111100                                                    ; 3dcc: 3c          <   :0fcc[1]
    equb %01111110                                                    ; 3dcd: 7e          ~   :0fcd[1]
    equb %00000110                                                    ; 3dce: 06          .   :0fce[1]
    equb %00011100                                                    ; 3dcf: 1c          .   :0fcf[1]
    equb %00000110                                                    ; 3dd0: 06          .   :0fd0[1]
    equb %01111110                                                    ; 3dd1: 7e          ~   :0fd1[1]
    equb %00111100                                                    ; 3dd2: 3c          <   :0fd2[1]
    equb %00000000                                                    ; 3dd3: 00          .   :0fd3[1]

    equb %00011000                                                    ; 3dd4: 18          .   :0fd4[1]
    equb %00111100                                                    ; 3dd5: 3c          <   :0fd5[1]
    equb %01100100                                                    ; 3dd6: 64          d   :0fd6[1]
    equb %11001100                                                    ; 3dd7: cc          .   :0fd7[1]
    equb %01111100                                                    ; 3dd8: 7c          |   :0fd8[1]
    equb %00001100                                                    ; 3dd9: 0c          .   :0fd9[1]
    equb %00001000                                                    ; 3dda: 08          .   :0fda[1]
    equb %00000000                                                    ; 3ddb: 00          .   :0fdb[1]

    equb %00111100                                                    ; 3ddc: 3c          <   :0fdc[1]
    equb %01111110                                                    ; 3ddd: 7e          ~   :0fdd[1]
    equb %01100000                                                    ; 3dde: 60          `   :0fde[1]
    equb %01111100                                                    ; 3ddf: 7c          |   :0fdf[1]
    equb %00000110                                                    ; 3de0: 06          .   :0fe0[1]
    equb %01111110                                                    ; 3de1: 7e          ~   :0fe1[1]
    equb %00111110                                                    ; 3de2: 3e          >   :0fe2[1]
    equb %00000000                                                    ; 3de3: 00          .   :0fe3[1]

    equb %00111100                                                    ; 3de4: 3c          <   :0fe4[1]
    equb %01111110                                                    ; 3de5: 7e          ~   :0fe5[1]
    equb %01100000                                                    ; 3de6: 60          `   :0fe6[1]
    equb %01111100                                                    ; 3de7: 7c          |   :0fe7[1]
    equb %01100110                                                    ; 3de8: 66          f   :0fe8[1]
    equb %01100110                                                    ; 3de9: 66          f   :0fe9[1]
    equb %00111100                                                    ; 3dea: 3c          <   :0fea[1]
    equb %00000000                                                    ; 3deb: 00          .   :0feb[1]

    equb %00111100                                                    ; 3dec: 3c          <   :0fec[1]
    equb %01111110                                                    ; 3ded: 7e          ~   :0fed[1]
    equb %00000110                                                    ; 3dee: 06          .   :0fee[1]
    equb %00001100                                                    ; 3def: 0c          .   :0fef[1]
    equb %00011000                                                    ; 3df0: 18          .   :0ff0[1]
    equb %00011000                                                    ; 3df1: 18          .   :0ff1[1]
    equb %00010000                                                    ; 3df2: 10          .   :0ff2[1]
    equb %00000000                                                    ; 3df3: 00          .   :0ff3[1]

    equb %00111100                                                    ; 3df4: 3c          <   :0ff4[1]
    equb %01100110                                                    ; 3df5: 66          f   :0ff5[1]
    equb %01100110                                                    ; 3df6: 66          f   :0ff6[1]
    equb %00111100                                                    ; 3df7: 3c          <   :0ff7[1]
    equb %01100110                                                    ; 3df8: 66          f   :0ff8[1]
    equb %01100110                                                    ; 3df9: 66          f   :0ff9[1]
    equb %00111100                                                    ; 3dfa: 3c          <   :0ffa[1]
    equb %00000000                                                    ; 3dfb: 00          .   :0ffb[1]

    equb %00111100                                                    ; 3dfc: 3c          <   :0ffc[1]
    equb %01100110                                                    ; 3dfd: 66          f   :0ffd[1]
    equb %01100110                                                    ; 3dfe: 66          f   :0ffe[1]
    equb %00111110                                                    ; 3dff: 3e          >   :0fff[1]
    equb %00000110                                                    ; 3e00: 06          .   :1000[1]
    equb %01111110                                                    ; 3e01: 7e          ~   :1001[1]
    equb %00111100                                                    ; 3e02: 3c          <   :1002[1]
    equb %00000000                                                    ; 3e03: 00          .   :1003[1]

    equb %00000000                                                    ; 3e04: 00          .   :1004[1]
    equb %00000000                                                    ; 3e05: 00          .   :1005[1]
    equb %00011000                                                    ; 3e06: 18          .   :1006[1]
    equb %00011000                                                    ; 3e07: 18          .   :1007[1]
    equb %00000000                                                    ; 3e08: 00          .   :1008[1]
    equb %00011000                                                    ; 3e09: 18          .   :1009[1]
    equb %00011000                                                    ; 3e0a: 18          .   :100a[1]
    equb %00000000                                                    ; 3e0b: 00          .   :100b[1]

    equb %00000000                                                    ; 3e0c: 00          .   :100c[1]
    equb %00000000                                                    ; 3e0d: 00          .   :100d[1]
    equb %00011000                                                    ; 3e0e: 18          .   :100e[1]
    equb %00011000                                                    ; 3e0f: 18          .   :100f[1]
    equb %00000000                                                    ; 3e10: 00          .   :1010[1]
    equb %00011000                                                    ; 3e11: 18          .   :1011[1]
    equb %00011000                                                    ; 3e12: 18          .   :1012[1]
    equb %00110000                                                    ; 3e13: 30          0   :1013[1]

    equb %00001100                                                    ; 3e14: 0c          .   :1014[1]
    equb %00011100                                                    ; 3e15: 1c          .   :1015[1]
    equb %00111000                                                    ; 3e16: 38          8   :1016[1]
    equb %01100000                                                    ; 3e17: 60          `   :1017[1]
    equb %00111000                                                    ; 3e18: 38          8   :1018[1]
    equb %00011100                                                    ; 3e19: 1c          .   :1019[1]
    equb %00001100                                                    ; 3e1a: 0c          .   :101a[1]
    equb %00000000                                                    ; 3e1b: 00          .   :101b[1]

    equb %00000000                                                    ; 3e1c: 00          .   :101c[1]
    equb %00000000                                                    ; 3e1d: 00          .   :101d[1]
    equb %01111110                                                    ; 3e1e: 7e          ~   :101e[1]
    equb %00000000                                                    ; 3e1f: 00          .   :101f[1]
    equb %00000000                                                    ; 3e20: 00          .   :1020[1]
    equb %01111110                                                    ; 3e21: 7e          ~   :1021[1]
    equb %00000000                                                    ; 3e22: 00          .   :1022[1]
    equb %00000000                                                    ; 3e23: 00          .   :1023[1]

    equb %01100000                                                    ; 3e24: 60          `   :1024[1]
    equb %01110000                                                    ; 3e25: 70          p   :1025[1]
    equb %00111000                                                    ; 3e26: 38          8   :1026[1]
    equb %00001100                                                    ; 3e27: 0c          .   :1027[1]
    equb %00111000                                                    ; 3e28: 38          8   :1028[1]
    equb %01110000                                                    ; 3e29: 70          p   :1029[1]
    equb %01100000                                                    ; 3e2a: 60          `   :102a[1]
    equb %00000000                                                    ; 3e2b: 00          .   :102b[1]

    equb %00111100                                                    ; 3e2c: 3c          <   :102c[1]
    equb %01110110                                                    ; 3e2d: 76          v   :102d[1]
    equb %00000110                                                    ; 3e2e: 06          .   :102e[1]
    equb %00011100                                                    ; 3e2f: 1c          .   :102f[1]
    equb %00000000                                                    ; 3e30: 00          .   :1030[1]
    equb %00011000                                                    ; 3e31: 18          .   :1031[1]
    equb %00011000                                                    ; 3e32: 18          .   :1032[1]
    equb %00000000                                                    ; 3e33: 00          .   :1033[1]

    equb %01111100                                                    ; 3e34: 7c          |   :1034[1]
    equb %11001110                                                    ; 3e35: ce          .   :1035[1]
    equb %10100110                                                    ; 3e36: a6          .   :1036[1]
    equb %10110110                                                    ; 3e37: b6          .   :1037[1]
    equb %11000110                                                    ; 3e38: c6          .   :1038[1]
    equb %11110000                                                    ; 3e39: f0          .   :1039[1]
    equb %01111100                                                    ; 3e3a: 7c          |   :103a[1]
    equb %00000000                                                    ; 3e3b: 00          .   :103b[1]

    equb %00011000                                                    ; 3e3c: 18          .   :103c[1]
    equb %00111100                                                    ; 3e3d: 3c          <   :103d[1]
    equb %01100110                                                    ; 3e3e: 66          f   :103e[1]
    equb %01100110                                                    ; 3e3f: 66          f   :103f[1]
    equb %01111110                                                    ; 3e40: 7e          ~   :1040[1]
    equb %01100110                                                    ; 3e41: 66          f   :1041[1]
    equb %00100100                                                    ; 3e42: 24          $   :1042[1]
    equb %00000000                                                    ; 3e43: 00          .   :1043[1]

    equb %00111100                                                    ; 3e44: 3c          <   :1044[1]
    equb %01100110                                                    ; 3e45: 66          f   :1045[1]
    equb %01100110                                                    ; 3e46: 66          f   :1046[1]
    equb %01111100                                                    ; 3e47: 7c          |   :1047[1]
    equb %01100110                                                    ; 3e48: 66          f   :1048[1]
    equb %01100110                                                    ; 3e49: 66          f   :1049[1]
    equb %00111100                                                    ; 3e4a: 3c          <   :104a[1]
    equb %00000000                                                    ; 3e4b: 00          .   :104b[1]

    equb %00111000                                                    ; 3e4c: 38          8   :104c[1]
    equb %01111100                                                    ; 3e4d: 7c          |   :104d[1]
    equb %11000000                                                    ; 3e4e: c0          .   :104e[1]
    equb %11000000                                                    ; 3e4f: c0          .   :104f[1]
    equb %11000000                                                    ; 3e50: c0          .   :1050[1]
    equb %01111100                                                    ; 3e51: 7c          |   :1051[1]
    equb %00111000                                                    ; 3e52: 38          8   :1052[1]
    equb %00000000                                                    ; 3e53: 00          .   :1053[1]

    equb %00111100                                                    ; 3e54: 3c          <   :1054[1]
    equb %01100100                                                    ; 3e55: 64          d   :1055[1]
    equb %01100110                                                    ; 3e56: 66          f   :1056[1]
    equb %01100110                                                    ; 3e57: 66          f   :1057[1]
    equb %01100110                                                    ; 3e58: 66          f   :1058[1]
    equb %01100100                                                    ; 3e59: 64          d   :1059[1]
    equb %00111000                                                    ; 3e5a: 38          8   :105a[1]
    equb %00000000                                                    ; 3e5b: 00          .   :105b[1]

    equb %00111100                                                    ; 3e5c: 3c          <   :105c[1]
    equb %01111110                                                    ; 3e5d: 7e          ~   :105d[1]
    equb %01100000                                                    ; 3e5e: 60          `   :105e[1]
    equb %01111000                                                    ; 3e5f: 78          x   :105f[1]
    equb %01100000                                                    ; 3e60: 60          `   :1060[1]
    equb %01111110                                                    ; 3e61: 7e          ~   :1061[1]
    equb %00111100                                                    ; 3e62: 3c          <   :1062[1]
    equb %00000000                                                    ; 3e63: 00          .   :1063[1]

    equb %00111000                                                    ; 3e64: 38          8   :1064[1]
    equb %01111100                                                    ; 3e65: 7c          |   :1065[1]
    equb %01100000                                                    ; 3e66: 60          `   :1066[1]
    equb %01111000                                                    ; 3e67: 78          x   :1067[1]
    equb %01100000                                                    ; 3e68: 60          `   :1068[1]
    equb %01100000                                                    ; 3e69: 60          `   :1069[1]
    equb %00100000                                                    ; 3e6a: 20              :106a[1]
    equb %00000000                                                    ; 3e6b: 00          .   :106b[1]

    equb %00111100                                                    ; 3e6c: 3c          <   :106c[1]
    equb %01100110                                                    ; 3e6d: 66          f   :106d[1]
    equb %11000000                                                    ; 3e6e: c0          .   :106e[1]
    equb %11000000                                                    ; 3e6f: c0          .   :106f[1]
    equb %11001100                                                    ; 3e70: cc          .   :1070[1]
    equb %01100110                                                    ; 3e71: 66          f   :1071[1]
    equb %00111100                                                    ; 3e72: 3c          <   :1072[1]
    equb %00000000                                                    ; 3e73: 00          .   :1073[1]

    equb %00100100                                                    ; 3e74: 24          $   :1074[1]
    equb %01100110                                                    ; 3e75: 66          f   :1075[1]
    equb %01100110                                                    ; 3e76: 66          f   :1076[1]
    equb %01111110                                                    ; 3e77: 7e          ~   :1077[1]
    equb %01100110                                                    ; 3e78: 66          f   :1078[1]
    equb %01100110                                                    ; 3e79: 66          f   :1079[1]
    equb %00100100                                                    ; 3e7a: 24          $   :107a[1]
    equb %00000000                                                    ; 3e7b: 00          .   :107b[1]

    equb %00010000                                                    ; 3e7c: 10          .   :107c[1]
    equb %00011000                                                    ; 3e7d: 18          .   :107d[1]
    equb %00011000                                                    ; 3e7e: 18          .   :107e[1]
    equb %00011000                                                    ; 3e7f: 18          .   :107f[1]
    equb %00011000                                                    ; 3e80: 18          .   :1080[1]
    equb %00011000                                                    ; 3e81: 18          .   :1081[1]
    equb %00001000                                                    ; 3e82: 08          .   :1082[1]
    equb %00000000                                                    ; 3e83: 00          .   :1083[1]

    equb %00001000                                                    ; 3e84: 08          .   :1084[1]
    equb %00001100                                                    ; 3e85: 0c          .   :1085[1]
    equb %00001100                                                    ; 3e86: 0c          .   :1086[1]
    equb %00001100                                                    ; 3e87: 0c          .   :1087[1]
    equb %01001100                                                    ; 3e88: 4c          L   :1088[1]
    equb %11111100                                                    ; 3e89: fc          .   :1089[1]
    equb %01111000                                                    ; 3e8a: 78          x   :108a[1]
    equb %00000000                                                    ; 3e8b: 00          .   :108b[1]

    equb %00100100                                                    ; 3e8c: 24          $   :108c[1]
    equb %01100110                                                    ; 3e8d: 66          f   :108d[1]
    equb %01101100                                                    ; 3e8e: 6c          l   :108e[1]
    equb %01111000                                                    ; 3e8f: 78          x   :108f[1]
    equb %01101100                                                    ; 3e90: 6c          l   :1090[1]
    equb %01100110                                                    ; 3e91: 66          f   :1091[1]
    equb %00100100                                                    ; 3e92: 24          $   :1092[1]
    equb %00000000                                                    ; 3e93: 00          .   :1093[1]

    equb %00100000                                                    ; 3e94: 20              :1094[1]
    equb %01100000                                                    ; 3e95: 60          `   :1095[1]
    equb %01100000                                                    ; 3e96: 60          `   :1096[1]
    equb %01100000                                                    ; 3e97: 60          `   :1097[1]
    equb %01100000                                                    ; 3e98: 60          `   :1098[1]
    equb %01111110                                                    ; 3e99: 7e          ~   :1099[1]
    equb %00111110                                                    ; 3e9a: 3e          >   :109a[1]
    equb %00000000                                                    ; 3e9b: 00          .   :109b[1]

    equb %01000100                                                    ; 3e9c: 44          D   :109c[1]
    equb %11101110                                                    ; 3e9d: ee          .   :109d[1]
    equb %11111110                                                    ; 3e9e: fe          .   :109e[1]
    equb %11010110                                                    ; 3e9f: d6          .   :109f[1]
    equb %11010110                                                    ; 3ea0: d6          .   :10a0[1]
    equb %11010110                                                    ; 3ea1: d6          .   :10a1[1]
    equb %01000100                                                    ; 3ea2: 44          D   :10a2[1]
    equb %00000000                                                    ; 3ea3: 00          .   :10a3[1]

    equb %01000100                                                    ; 3ea4: 44          D   :10a4[1]
    equb %11100110                                                    ; 3ea5: e6          .   :10a5[1]
    equb %11110110                                                    ; 3ea6: f6          .   :10a6[1]
    equb %11011110                                                    ; 3ea7: de          .   :10a7[1]
    equb %11001110                                                    ; 3ea8: ce          .   :10a8[1]
    equb %11000110                                                    ; 3ea9: c6          .   :10a9[1]
    equb %01000100                                                    ; 3eaa: 44          D   :10aa[1]
    equb %00000000                                                    ; 3eab: 00          .   :10ab[1]

    equb %00111000                                                    ; 3eac: 38          8   :10ac[1]
    equb %01101100                                                    ; 3ead: 6c          l   :10ad[1]
    equb %11000110                                                    ; 3eae: c6          .   :10ae[1]
    equb %11000110                                                    ; 3eaf: c6          .   :10af[1]
    equb %11000110                                                    ; 3eb0: c6          .   :10b0[1]
    equb %01101100                                                    ; 3eb1: 6c          l   :10b1[1]
    equb %00111000                                                    ; 3eb2: 38          8   :10b2[1]
    equb %00000000                                                    ; 3eb3: 00          .   :10b3[1]

    equb %00111000                                                    ; 3eb4: 38          8   :10b4[1]
    equb %01101100                                                    ; 3eb5: 6c          l   :10b5[1]
    equb %01100100                                                    ; 3eb6: 64          d   :10b6[1]
    equb %01111100                                                    ; 3eb7: 7c          |   :10b7[1]
    equb %01100000                                                    ; 3eb8: 60          `   :10b8[1]
    equb %01100000                                                    ; 3eb9: 60          `   :10b9[1]
    equb %00100000                                                    ; 3eba: 20              :10ba[1]
    equb %00000000                                                    ; 3ebb: 00          .   :10bb[1]

    equb %00111000                                                    ; 3ebc: 38          8   :10bc[1]
    equb %01101100                                                    ; 3ebd: 6c          l   :10bd[1]
    equb %11000110                                                    ; 3ebe: c6          .   :10be[1]
    equb %11000110                                                    ; 3ebf: c6          .   :10bf[1]
    equb %11001010                                                    ; 3ec0: ca          .   :10c0[1]
    equb %01110100                                                    ; 3ec1: 74          t   :10c1[1]
    equb %00111010                                                    ; 3ec2: 3a          :   :10c2[1]
    equb %00000000                                                    ; 3ec3: 00          .   :10c3[1]

    equb %00111100                                                    ; 3ec4: 3c          <   :10c4[1]
    equb %01100110                                                    ; 3ec5: 66          f   :10c5[1]
    equb %01100110                                                    ; 3ec6: 66          f   :10c6[1]
    equb %01111100                                                    ; 3ec7: 7c          |   :10c7[1]
    equb %01101100                                                    ; 3ec8: 6c          l   :10c8[1]
    equb %01100110                                                    ; 3ec9: 66          f   :10c9[1]
    equb %00100110                                                    ; 3eca: 26          &   :10ca[1]
    equb %00000000                                                    ; 3ecb: 00          .   :10cb[1]

    equb %00111100                                                    ; 3ecc: 3c          <   :10cc[1]
    equb %01111110                                                    ; 3ecd: 7e          ~   :10cd[1]
    equb %01100000                                                    ; 3ece: 60          `   :10ce[1]
    equb %00111100                                                    ; 3ecf: 3c          <   :10cf[1]
    equb %00000110                                                    ; 3ed0: 06          .   :10d0[1]
    equb %01111110                                                    ; 3ed1: 7e          ~   :10d1[1]
    equb %00111100                                                    ; 3ed2: 3c          <   :10d2[1]
    equb %00000000                                                    ; 3ed3: 00          .   :10d3[1]

    equb %00111100                                                    ; 3ed4: 3c          <   :10d4[1]
    equb %01111110                                                    ; 3ed5: 7e          ~   :10d5[1]
    equb %00011000                                                    ; 3ed6: 18          .   :10d6[1]
    equb %00011000                                                    ; 3ed7: 18          .   :10d7[1]
    equb %00011000                                                    ; 3ed8: 18          .   :10d8[1]
    equb %00011000                                                    ; 3ed9: 18          .   :10d9[1]
    equb %00001000                                                    ; 3eda: 08          .   :10da[1]
    equb %00000000                                                    ; 3edb: 00          .   :10db[1]

    equb %00100100                                                    ; 3edc: 24          $   :10dc[1]
    equb %01100110                                                    ; 3edd: 66          f   :10dd[1]
    equb %01100110                                                    ; 3ede: 66          f   :10de[1]
    equb %01100110                                                    ; 3edf: 66          f   :10df[1]
    equb %01100110                                                    ; 3ee0: 66          f   :10e0[1]
    equb %01100110                                                    ; 3ee1: 66          f   :10e1[1]
    equb %00111100                                                    ; 3ee2: 3c          <   :10e2[1]
    equb %00000000                                                    ; 3ee3: 00          .   :10e3[1]

    equb %00100100                                                    ; 3ee4: 24          $   :10e4[1]
    equb %01100110                                                    ; 3ee5: 66          f   :10e5[1]
    equb %01100110                                                    ; 3ee6: 66          f   :10e6[1]
    equb %01100110                                                    ; 3ee7: 66          f   :10e7[1]
    equb %01100110                                                    ; 3ee8: 66          f   :10e8[1]
    equb %00111100                                                    ; 3ee9: 3c          <   :10e9[1]
    equb %00011000                                                    ; 3eea: 18          .   :10ea[1]
    equb %00000000                                                    ; 3eeb: 00          .   :10eb[1]

    equb %01000100                                                    ; 3eec: 44          D   :10ec[1]
    equb %11000110                                                    ; 3eed: c6          .   :10ed[1]
    equb %11010110                                                    ; 3eee: d6          .   :10ee[1]
    equb %11010110                                                    ; 3eef: d6          .   :10ef[1]
    equb %11111110                                                    ; 3ef0: fe          .   :10f0[1]
    equb %11101110                                                    ; 3ef1: ee          .   :10f1[1]
    equb %01000100                                                    ; 3ef2: 44          D   :10f2[1]
    equb %00000000                                                    ; 3ef3: 00          .   :10f3[1]

    equb %11000110                                                    ; 3ef4: c6          .   :10f4[1]
    equb %01101100                                                    ; 3ef5: 6c          l   :10f5[1]
    equb %00111000                                                    ; 3ef6: 38          8   :10f6[1]
    equb %00111000                                                    ; 3ef7: 38          8   :10f7[1]
    equb %01101100                                                    ; 3ef8: 6c          l   :10f8[1]
    equb %11000110                                                    ; 3ef9: c6          .   :10f9[1]
    equb %01000100                                                    ; 3efa: 44          D   :10fa[1]
    equb %00000000                                                    ; 3efb: 00          .   :10fb[1]

    equb %00100100                                                    ; 3efc: 24          $   :10fc[1]
    equb %01100110                                                    ; 3efd: 66          f   :10fd[1]
    equb %01100110                                                    ; 3efe: 66          f   :10fe[1]
    equb %00111100                                                    ; 3eff: 3c          <   :10ff[1]
    equb %00011000                                                    ; 3f00: 18          .   :1100[1]
    equb %00011000                                                    ; 3f01: 18          .   :1101[1]
    equb %00001000                                                    ; 3f02: 08          .   :1102[1]
    equb %00000000                                                    ; 3f03: 00          .   :1103[1]

    equb %01111100                                                    ; 3f04: 7c          |   :1104[1]
    equb %11111100                                                    ; 3f05: fc          .   :1105[1]
    equb %00001100                                                    ; 3f06: 0c          .   :1106[1]
    equb %00011000                                                    ; 3f07: 18          .   :1107[1]
    equb %00110000                                                    ; 3f08: 30          0   :1108[1]
    equb %01111110                                                    ; 3f09: 7e          ~   :1109[1]
    equb %01111100                                                    ; 3f0a: 7c          |   :110a[1]
    equb %00000000                                                    ; 3f0b: 00          .   :110b[1]

    equb %00011100                                                    ; 3f0c: 1c          .   :110c[1]
    equb %00110000                                                    ; 3f0d: 30          0   :110d[1]
    equb %00110000                                                    ; 3f0e: 30          0   :110e[1]
    equb %00110000                                                    ; 3f0f: 30          0   :110f[1]
    equb %00110000                                                    ; 3f10: 30          0   :1110[1]
    equb %00110000                                                    ; 3f11: 30          0   :1111[1]
    equb %00011100                                                    ; 3f12: 1c          .   :1112[1]
    equb %00000000                                                    ; 3f13: 00          .   :1113[1]

    equb %10000000                                                    ; 3f14: 80          .   :1114[1]
    equb %01000000                                                    ; 3f15: 40          @   :1115[1]
    equb %00100000                                                    ; 3f16: 20              :1116[1]
    equb %00010000                                                    ; 3f17: 10          .   :1117[1]
    equb %00001000                                                    ; 3f18: 08          .   :1118[1]
    equb %00000100                                                    ; 3f19: 04          .   :1119[1]
    equb %00000010                                                    ; 3f1a: 02          .   :111a[1]
    equb %00000000                                                    ; 3f1b: 00          .   :111b[1]

    equb %00111000                                                    ; 3f1c: 38          8   :111c[1]
    equb %00001100                                                    ; 3f1d: 0c          .   :111d[1]
    equb %00001100                                                    ; 3f1e: 0c          .   :111e[1]
    equb %00001100                                                    ; 3f1f: 0c          .   :111f[1]
    equb %00001100                                                    ; 3f20: 0c          .   :1120[1]
    equb %00001100                                                    ; 3f21: 0c          .   :1121[1]
    equb %00111000                                                    ; 3f22: 38          8   :1122[1]
    equb %00000000                                                    ; 3f23: 00          .   :1123[1]

    equb %00011000                                                    ; 3f24: 18          .   :1124[1]
    equb %00011000                                                    ; 3f25: 18          .   :1125[1]
    equb %00011000                                                    ; 3f26: 18          .   :1126[1]
    equb %00011000                                                    ; 3f27: 18          .   :1127[1]
    equb %01111110                                                    ; 3f28: 7e          ~   :1128[1]
    equb %01111110                                                    ; 3f29: 7e          ~   :1129[1]
    equb %00011000                                                    ; 3f2a: 18          .   :112a[1]
    equb %00011000                                                    ; 3f2b: 18          .   :112b[1]

    equb %00011000                                                    ; 3f2c: 18          .   :112c[1]
    equb %00011000                                                    ; 3f2d: 18          .   :112d[1]
    equb %00011000                                                    ; 3f2e: 18          .   :112e[1]
    equb %00011000                                                    ; 3f2f: 18          .   :112f[1]
    equb %00111100                                                    ; 3f30: 3c          <   :1130[1]
    equb %00111100                                                    ; 3f31: 3c          <   :1131[1]
    equb %00011000                                                    ; 3f32: 18          .   :1132[1]
    equb %00011000                                                    ; 3f33: 18          .   :1133[1]

    equb %00011000                                                    ; 3f34: 18          .   :1134[1]
    equb %00011000                                                    ; 3f35: 18          .   :1135[1]
    equb %00011000                                                    ; 3f36: 18          .   :1136[1]
    equb %00011000                                                    ; 3f37: 18          .   :1137[1]
    equb %00011000                                                    ; 3f38: 18          .   :1138[1]
    equb %00011000                                                    ; 3f39: 18          .   :1139[1]
    equb %00011000                                                    ; 3f3a: 18          .   :113a[1]
    equb %00011000                                                    ; 3f3b: 18          .   :113b[1]

    equb %00000000                                                    ; 3f3c: 00          .   :113c[1]
    equb %00000000                                                    ; 3f3d: 00          .   :113d[1]
    equb %00111000                                                    ; 3f3e: 38          8   :113e[1]
    equb %00001100                                                    ; 3f3f: 0c          .   :113f[1]
    equb %01111100                                                    ; 3f40: 7c          |   :1140[1]
    equb %11001100                                                    ; 3f41: cc          .   :1141[1]
    equb %01111000                                                    ; 3f42: 78          x   :1142[1]
    equb %00000000                                                    ; 3f43: 00          .   :1143[1]

    equb %00100000                                                    ; 3f44: 20              :1144[1]
    equb %01100000                                                    ; 3f45: 60          `   :1145[1]
    equb %01111100                                                    ; 3f46: 7c          |   :1146[1]
    equb %01100110                                                    ; 3f47: 66          f   :1147[1]
    equb %01100110                                                    ; 3f48: 66          f   :1148[1]
    equb %01100110                                                    ; 3f49: 66          f   :1149[1]
    equb %00111100                                                    ; 3f4a: 3c          <   :114a[1]
    equb %00000000                                                    ; 3f4b: 00          .   :114b[1]

    equb %00000000                                                    ; 3f4c: 00          .   :114c[1]
    equb %00000000                                                    ; 3f4d: 00          .   :114d[1]
    equb %00111100                                                    ; 3f4e: 3c          <   :114e[1]
    equb %01100110                                                    ; 3f4f: 66          f   :114f[1]
    equb %01100000                                                    ; 3f50: 60          `   :1150[1]
    equb %01100110                                                    ; 3f51: 66          f   :1151[1]
    equb %00111100                                                    ; 3f52: 3c          <   :1152[1]
    equb %00000000                                                    ; 3f53: 00          .   :1153[1]

    equb %00001000                                                    ; 3f54: 08          .   :1154[1]
    equb %00001100                                                    ; 3f55: 0c          .   :1155[1]
    equb %01111100                                                    ; 3f56: 7c          |   :1156[1]
    equb %11001100                                                    ; 3f57: cc          .   :1157[1]
    equb %11001100                                                    ; 3f58: cc          .   :1158[1]
    equb %11001100                                                    ; 3f59: cc          .   :1159[1]
    equb %01111000                                                    ; 3f5a: 78          x   :115a[1]
    equb %00000000                                                    ; 3f5b: 00          .   :115b[1]

    equb %00000000                                                    ; 3f5c: 00          .   :115c[1]
    equb %00000000                                                    ; 3f5d: 00          .   :115d[1]
    equb %00111100                                                    ; 3f5e: 3c          <   :115e[1]
    equb %01100110                                                    ; 3f5f: 66          f   :115f[1]
    equb %01111110                                                    ; 3f60: 7e          ~   :1160[1]
    equb %01100000                                                    ; 3f61: 60          `   :1161[1]
    equb %00111100                                                    ; 3f62: 3c          <   :1162[1]
    equb %00000000                                                    ; 3f63: 00          .   :1163[1]

    equb %00011100                                                    ; 3f64: 1c          .   :1164[1]
    equb %00110110                                                    ; 3f65: 36          6   :1165[1]
    equb %00110000                                                    ; 3f66: 30          0   :1166[1]
    equb %00111000                                                    ; 3f67: 38          8   :1167[1]
    equb %00110000                                                    ; 3f68: 30          0   :1168[1]
    equb %00110000                                                    ; 3f69: 30          0   :1169[1]
    equb %00010000                                                    ; 3f6a: 10          .   :116a[1]
    equb %00000000                                                    ; 3f6b: 00          .   :116b[1]

    equb %00000000                                                    ; 3f6c: 00          .   :116c[1]
    equb %00000000                                                    ; 3f6d: 00          .   :116d[1]
    equb %00111100                                                    ; 3f6e: 3c          <   :116e[1]
    equb %01100110                                                    ; 3f6f: 66          f   :116f[1]
    equb %01100110                                                    ; 3f70: 66          f   :1170[1]
    equb %00111110                                                    ; 3f71: 3e          >   :1171[1]
    equb %00000110                                                    ; 3f72: 06          .   :1172[1]
    equb %00111100                                                    ; 3f73: 3c          <   :1173[1]

    equb %00100000                                                    ; 3f74: 20              :1174[1]
    equb %01100000                                                    ; 3f75: 60          `   :1175[1]
    equb %01101100                                                    ; 3f76: 6c          l   :1176[1]
    equb %01110110                                                    ; 3f77: 76          v   :1177[1]
    equb %01100110                                                    ; 3f78: 66          f   :1178[1]
    equb %01100110                                                    ; 3f79: 66          f   :1179[1]
    equb %00100100                                                    ; 3f7a: 24          $   :117a[1]
    equb %00000000                                                    ; 3f7b: 00          .   :117b[1]

    equb %00011000                                                    ; 3f7c: 18          .   :117c[1]
    equb %00000000                                                    ; 3f7d: 00          .   :117d[1]
    equb %00011000                                                    ; 3f7e: 18          .   :117e[1]
    equb %00011000                                                    ; 3f7f: 18          .   :117f[1]
    equb %00011000                                                    ; 3f80: 18          .   :1180[1]
    equb %00011000                                                    ; 3f81: 18          .   :1181[1]
    equb %00001000                                                    ; 3f82: 08          .   :1182[1]
    equb %00000000                                                    ; 3f83: 00          .   :1183[1]

    equb %00000110                                                    ; 3f84: 06          .   :1184[1]
    equb %00000000                                                    ; 3f85: 00          .   :1185[1]
    equb %00000100                                                    ; 3f86: 04          .   :1186[1]
    equb %00000110                                                    ; 3f87: 06          .   :1187[1]
    equb %00000110                                                    ; 3f88: 06          .   :1188[1]
    equb %00100110                                                    ; 3f89: 26          &   :1189[1]
    equb %01100110                                                    ; 3f8a: 66          f   :118a[1]
    equb %00111100                                                    ; 3f8b: 3c          <   :118b[1]

    equb %00100000                                                    ; 3f8c: 20              :118c[1]
    equb %01100000                                                    ; 3f8d: 60          `   :118d[1]
    equb %01100110                                                    ; 3f8e: 66          f   :118e[1]
    equb %01101100                                                    ; 3f8f: 6c          l   :118f[1]
    equb %01111000                                                    ; 3f90: 78          x   :1190[1]
    equb %01101100                                                    ; 3f91: 6c          l   :1191[1]
    equb %00100110                                                    ; 3f92: 26          &   :1192[1]
    equb %00000000                                                    ; 3f93: 00          .   :1193[1]

    equb %00010000                                                    ; 3f94: 10          .   :1194[1]
    equb %00011000                                                    ; 3f95: 18          .   :1195[1]
    equb %00011000                                                    ; 3f96: 18          .   :1196[1]
    equb %00011000                                                    ; 3f97: 18          .   :1197[1]
    equb %00011000                                                    ; 3f98: 18          .   :1198[1]
    equb %00011000                                                    ; 3f99: 18          .   :1199[1]
    equb %00001000                                                    ; 3f9a: 08          .   :119a[1]
    equb %00000000                                                    ; 3f9b: 00          .   :119b[1]

    equb %00000000                                                    ; 3f9c: 00          .   :119c[1]
    equb %00000000                                                    ; 3f9d: 00          .   :119d[1]
    equb %01101100                                                    ; 3f9e: 6c          l   :119e[1]
    equb %11111110                                                    ; 3f9f: fe          .   :119f[1]
    equb %11010110                                                    ; 3fa0: d6          .   :11a0[1]
    equb %11010110                                                    ; 3fa1: d6          .   :11a1[1]
    equb %11000110                                                    ; 3fa2: c6          .   :11a2[1]
    equb %00000000                                                    ; 3fa3: 00          .   :11a3[1]

    equb %00000000                                                    ; 3fa4: 00          .   :11a4[1]
    equb %00000000                                                    ; 3fa5: 00          .   :11a5[1]
    equb %00111100                                                    ; 3fa6: 3c          <   :11a6[1]
    equb %01100110                                                    ; 3fa7: 66          f   :11a7[1]
    equb %01100110                                                    ; 3fa8: 66          f   :11a8[1]
    equb %01100110                                                    ; 3fa9: 66          f   :11a9[1]
    equb %00100100                                                    ; 3faa: 24          $   :11aa[1]
    equb %00000000                                                    ; 3fab: 00          .   :11ab[1]

    equb %00000000                                                    ; 3fac: 00          .   :11ac[1]
    equb %00000000                                                    ; 3fad: 00          .   :11ad[1]
    equb %00111100                                                    ; 3fae: 3c          <   :11ae[1]
    equb %01100110                                                    ; 3faf: 66          f   :11af[1]
    equb %01100110                                                    ; 3fb0: 66          f   :11b0[1]
    equb %01100110                                                    ; 3fb1: 66          f   :11b1[1]
    equb %00111100                                                    ; 3fb2: 3c          <   :11b2[1]
    equb %00000000                                                    ; 3fb3: 00          .   :11b3[1]

    equb %00000000                                                    ; 3fb4: 00          .   :11b4[1]
    equb %00000000                                                    ; 3fb5: 00          .   :11b5[1]
    equb %00111100                                                    ; 3fb6: 3c          <   :11b6[1]
    equb %01100110                                                    ; 3fb7: 66          f   :11b7[1]
    equb %01100110                                                    ; 3fb8: 66          f   :11b8[1]
    equb %01111100                                                    ; 3fb9: 7c          |   :11b9[1]
    equb %01100000                                                    ; 3fba: 60          `   :11ba[1]
    equb %00100000                                                    ; 3fbb: 20              :11bb[1]

    equb %00000000                                                    ; 3fbc: 00          .   :11bc[1]
    equb %00000000                                                    ; 3fbd: 00          .   :11bd[1]
    equb %01111000                                                    ; 3fbe: 78          x   :11be[1]
    equb %11001100                                                    ; 3fbf: cc          .   :11bf[1]
    equb %11001100                                                    ; 3fc0: cc          .   :11c0[1]
    equb %01111100                                                    ; 3fc1: 7c          |   :11c1[1]
    equb %00001100                                                    ; 3fc2: 0c          .   :11c2[1]
    equb %00001000                                                    ; 3fc3: 08          .   :11c3[1]

    equb %00000000                                                    ; 3fc4: 00          .   :11c4[1]
    equb %00000000                                                    ; 3fc5: 00          .   :11c5[1]
    equb %00111000                                                    ; 3fc6: 38          8   :11c6[1]
    equb %01111100                                                    ; 3fc7: 7c          |   :11c7[1]
    equb %01100000                                                    ; 3fc8: 60          `   :11c8[1]
    equb %01100000                                                    ; 3fc9: 60          `   :11c9[1]
    equb %00100000                                                    ; 3fca: 20              :11ca[1]
    equb %00000000                                                    ; 3fcb: 00          .   :11cb[1]

    equb %00000000                                                    ; 3fcc: 00          .   :11cc[1]
    equb %00000000                                                    ; 3fcd: 00          .   :11cd[1]
    equb %00111100                                                    ; 3fce: 3c          <   :11ce[1]
    equb %01100000                                                    ; 3fcf: 60          `   :11cf[1]
    equb %00111100                                                    ; 3fd0: 3c          <   :11d0[1]
    equb %00000110                                                    ; 3fd1: 06          .   :11d1[1]
    equb %01111100                                                    ; 3fd2: 7c          |   :11d2[1]
    equb %00000000                                                    ; 3fd3: 00          .   :11d3[1]

    equb %00010000                                                    ; 3fd4: 10          .   :11d4[1]
    equb %00110000                                                    ; 3fd5: 30          0   :11d5[1]
    equb %00111100                                                    ; 3fd6: 3c          <   :11d6[1]
    equb %00110000                                                    ; 3fd7: 30          0   :11d7[1]
    equb %00110000                                                    ; 3fd8: 30          0   :11d8[1]
    equb %00111110                                                    ; 3fd9: 3e          >   :11d9[1]
    equb %00011100                                                    ; 3fda: 1c          .   :11da[1]
    equb %00000000                                                    ; 3fdb: 00          .   :11db[1]

    equb %00000000                                                    ; 3fdc: 00          .   :11dc[1]
    equb %00000000                                                    ; 3fdd: 00          .   :11dd[1]
    equb %00100100                                                    ; 3fde: 24          $   :11de[1]
    equb %01100110                                                    ; 3fdf: 66          f   :11df[1]
    equb %01100110                                                    ; 3fe0: 66          f   :11e0[1]
    equb %01100110                                                    ; 3fe1: 66          f   :11e1[1]
    equb %00111100                                                    ; 3fe2: 3c          <   :11e2[1]
    equb %00000000                                                    ; 3fe3: 00          .   :11e3[1]

    equb %00000000                                                    ; 3fe4: 00          .   :11e4[1]
    equb %00000000                                                    ; 3fe5: 00          .   :11e5[1]
    equb %00100100                                                    ; 3fe6: 24          $   :11e6[1]
    equb %01100110                                                    ; 3fe7: 66          f   :11e7[1]
    equb %01100110                                                    ; 3fe8: 66          f   :11e8[1]
    equb %00111100                                                    ; 3fe9: 3c          <   :11e9[1]
    equb %00011000                                                    ; 3fea: 18          .   :11ea[1]
    equb %00000000                                                    ; 3feb: 00          .   :11eb[1]

    equb %00000000                                                    ; 3fec: 00          .   :11ec[1]
    equb %00000000                                                    ; 3fed: 00          .   :11ed[1]
    equb %01000100                                                    ; 3fee: 44          D   :11ee[1]
    equb %11010110                                                    ; 3fef: d6          .   :11ef[1]
    equb %11010110                                                    ; 3ff0: d6          .   :11f0[1]
    equb %11111110                                                    ; 3ff1: fe          .   :11f1[1]
    equb %01101100                                                    ; 3ff2: 6c          l   :11f2[1]
    equb %00000000                                                    ; 3ff3: 00          .   :11f3[1]

    equb %00000000                                                    ; 3ff4: 00          .   :11f4[1]
    equb %00000000                                                    ; 3ff5: 00          .   :11f5[1]
    equb %11000110                                                    ; 3ff6: c6          .   :11f6[1]
    equb %01101100                                                    ; 3ff7: 6c          l   :11f7[1]
    equb %00111000                                                    ; 3ff8: 38          8   :11f8[1]
    equb %01101100                                                    ; 3ff9: 6c          l   :11f9[1]
    equb %11000110                                                    ; 3ffa: c6          .   :11fa[1]
    equb %00000000                                                    ; 3ffb: 00          .   :11fb[1]

    equb %00000000                                                    ; 3ffc: 00          .   :11fc[1]
    equb %00000000                                                    ; 3ffd: 00          .   :11fd[1]
    equb %00100100                                                    ; 3ffe: 24          $   :11fe[1]
    equb %01100110                                                    ; 3fff: 66          f   :11ff[1]
    equb %01100110                                                    ; 4000: 66          f   :1200[1]
    equb %00111110                                                    ; 4001: 3e          >   :1201[1]
    equb %00000110                                                    ; 4002: 06          .   :1202[1]
    equb %01111100                                                    ; 4003: 7c          |   :1203[1]

    equb %00000000                                                    ; 4004: 00          .   :1204[1]
    equb %00000000                                                    ; 4005: 00          .   :1205[1]
    equb %01111110                                                    ; 4006: 7e          ~   :1206[1]
    equb %00001100                                                    ; 4007: 0c          .   :1207[1]
    equb %00011000                                                    ; 4008: 18          .   :1208[1]
    equb %00110000                                                    ; 4009: 30          0   :1209[1]
    equb %01111110                                                    ; 400a: 7e          ~   :120a[1]
    equb %00000000                                                    ; 400b: 00          .   :120b[1]

    equb %00001000                                                    ; 400c: 08          .   :120c[1]
    equb %00001000                                                    ; 400d: 08          .   :120d[1]
    equb %00001000                                                    ; 400e: 08          .   :120e[1]
    equb %00001000                                                    ; 400f: 08          .   :120f[1]
    equb %01010110                                                    ; 4010: 56          V   :1210[1]
    equb %01010101                                                    ; 4011: 55          U   :1211[1]
    equb %01010111                                                    ; 4012: 57          W   :1212[1]
    equb %01110100                                                    ; 4013: 74          t   :1213[1]

    equb %00011000                                                    ; 4014: 18          .   :1214[1]
    equb %00000100                                                    ; 4015: 04          .   :1215[1]
    equb %00001000                                                    ; 4016: 08          .   :1216[1]
    equb %00011100                                                    ; 4017: 1c          .   :1217[1]
    equb %01010110                                                    ; 4018: 56          V   :1218[1]
    equb %01010101                                                    ; 4019: 55          U   :1219[1]
    equb %01010111                                                    ; 401a: 57          W   :121a[1]
    equb %01110100                                                    ; 401b: 74          t   :121b[1]

    equb %00000000                                                    ; 401c: 00          .   :121c[1]
    equb %00000000                                                    ; 401d: 00          .   :121d[1]
    equb %00000000                                                    ; 401e: 00          .   :121e[1]
    equb %00000000                                                    ; 401f: 00          .   :121f[1]
    equb %01111110                                                    ; 4020: 7e          ~   :1220[1]
    equb %01111110                                                    ; 4021: 7e          ~   :1221[1]
    equb %11111111                                                    ; 4022: ff          .   :1222[1]
    equb %11111111                                                    ; 4023: ff          .   :1223[1]

    equb %00011000                                                    ; 4024: 18          .   :1224[1]
    equb %00111100                                                    ; 4025: 3c          <   :1225[1]
    equb %00011000                                                    ; 4026: 18          .   :1226[1]
    equb %00011000                                                    ; 4027: 18          .   :1227[1]
    equb %00011000                                                    ; 4028: 18          .   :1228[1]
    equb %00011000                                                    ; 4029: 18          .   :1229[1]
    equb %01111110                                                    ; 402a: 7e          ~   :122a[1]
    equb %11111111                                                    ; 402b: ff          .   :122b[1]

    equb %00100010                                                    ; 402c: 22          "   :122c[1]
    equb %01110111                                                    ; 402d: 77          w   :122d[1]
    equb %01111111                                                    ; 402e: 7f          .   :122e[1]
    equb %01111111                                                    ; 402f: 7f          .   :122f[1]
    equb %00111110                                                    ; 4030: 3e          >   :1230[1]
    equb %00011100                                                    ; 4031: 1c          .   :1231[1]
    equb %00001000                                                    ; 4032: 08          .   :1232[1]
    equb %00000000                                                    ; 4033: 00          .   :1233[1]

.font_space
    equb %00000000                                                    ; 4034: 00          .   :1234[1]
    equb %00000000                                                    ; 4035: 00          .   :1235[1]
    equb %00000000                                                    ; 4036: 00          .   :1236[1]
    equb %00000000                                                    ; 4037: 00          .   :1237[1]
    equb %00000000                                                    ; 4038: 00          .   :1238[1]
    equb %00000000                                                    ; 4039: 00          .   :1239[1]
    equb %00000000                                                    ; 403a: 00          .   :123a[1]
    equb %00000000                                                    ; 403b: 00          .   :123b[1]

    equb %00000000                                                    ; 403c: 00          .   :123c[1]
    equb %00000000                                                    ; 403d: 00          .   :123d[1]
    equb %00000000                                                    ; 403e: 00          .   :123e[1]
    equb %00000000                                                    ; 403f: 00          .   :123f[1]
    equb %00000000                                                    ; 4040: 00          .   :1240[1]
    equb %00000000                                                    ; 4041: 00          .   :1241[1]
    equb %00000000                                                    ; 4042: 00          .   :1242[1]
    equb %00000000                                                    ; 4043: 00          .   :1243[1]

    equb %00000001                                                    ; 4044: 01          .   :1244[1]
    equb %00010000                                                    ; 4045: 10          .   :1245[1]
    equb %00010010                                                    ; 4046: 12          .   :1246[1]
    equb %00100101                                                    ; 4047: 25          %   :1247[1]
    equb %00100001                                                    ; 4048: 21          !   :1248[1]
    equb %01100101                                                    ; 4049: 65          e   :1249[1]
    equb %11110100                                                    ; 404a: f4          .   :124a[1]
    equb %10010110                                                    ; 404b: 96          .   :124b[1]

    equb %00001000                                                    ; 404c: 08          .   :124c[1]
    equb %10001000                                                    ; 404d: 88          .   :124d[1]
    equb %10000100                                                    ; 404e: 84          .   :124e[1]
    equb %01001110                                                    ; 404f: 4e          N   :124f[1]
    equb %11000100                                                    ; 4050: c4          .   :1250[1]
    equb %01101010                                                    ; 4051: 6a          j   :1251[1]
    equb %11110011                                                    ; 4052: f3          .   :1252[1]
    equb %10011110                                                    ; 4053: 9e          .   :1253[1]

    equb %11000000                                                    ; 4054: c0          .   :1254[1]
    equb %01101110                                                    ; 4055: 6e          n   :1255[1]
    equb %01111000                                                    ; 4056: 78          x   :1256[1]
    equb %11000011                                                    ; 4057: c3          .   :1257[1]
    equb %11011010                                                    ; 4058: da          .   :1258[1]
    equb %01111001                                                    ; 4059: 79          y   :1259[1]
    equb %01101110                                                    ; 405a: 6e          n   :125a[1]
    equb %11000100                                                    ; 405b: c4          .   :125b[1]

    equb %00000000                                                    ; 405c: 00          .   :125c[1]
    equb %00001000                                                    ; 405d: 08          .   :125d[1]
    equb %10000100                                                    ; 405e: 84          .   :125e[1]
    equb %01101001                                                    ; 405f: 69          i   :125f[1]
    equb %01101011                                                    ; 4060: 6b          k   :1260[1]
    equb %10001100                                                    ; 4061: 8c          .   :1261[1]
    equb %00001000                                                    ; 4062: 08          .   :1262[1]
    equb %00000000                                                    ; 4063: 00          .   :1263[1]

    equb %10010111                                                    ; 4064: 97          .   :1264[1]
    equb %11111100                                                    ; 4065: fc          .   :1265[1]
    equb %01100101                                                    ; 4066: 65          e   :1266[1]
    equb %00110010                                                    ; 4067: 32          2   :1267[1]
    equb %00100111                                                    ; 4068: 27          '   :1268[1]
    equb %00010010                                                    ; 4069: 12          .   :1269[1]
    equb %00010001                                                    ; 406a: 11          .   :126a[1]
    equb %00000001                                                    ; 406b: 01          .   :126b[1]

    equb %10010110                                                    ; 406c: 96          .   :126c[1]
    equb %11110010                                                    ; 406d: f2          .   :126d[1]
    equb %01101010                                                    ; 406e: 6a          j   :126e[1]
    equb %01001000                                                    ; 406f: 48          H   :126f[1]
    equb %01001010                                                    ; 4070: 4a          J   :1270[1]
    equb %10000100                                                    ; 4071: 84          .   :1271[1]
    equb %10000000                                                    ; 4072: 80          .   :1272[1]
    equb %00001000                                                    ; 4073: 08          .   :1273[1]

    equb %00000000                                                    ; 4074: 00          .   :1274[1]
    equb %00000001                                                    ; 4075: 01          .   :1275[1]
    equb %00010011                                                    ; 4076: 13          .   :1276[1]
    equb %01101101                                                    ; 4077: 6d          m   :1277[1]
    equb %01101001                                                    ; 4078: 69          i   :1278[1]
    equb %00010010                                                    ; 4079: 12          .   :1279[1]
    equb %00000001                                                    ; 407a: 01          .   :127a[1]
    equb %00000000                                                    ; 407b: 00          .   :127b[1]

    equb %00110010                                                    ; 407c: 32          2   :127c[1]
    equb %01100111                                                    ; 407d: 67          g   :127d[1]
    equb %11101001                                                    ; 407e: e9          .   :127e[1]
    equb %10110101                                                    ; 407f: b5          .   :127f[1]
    equb %00111100                                                    ; 4080: 3c          <   :1280[1]
    equb %11100001                                                    ; 4081: e1          .   :1281[1]
    equb %01100111                                                    ; 4082: 67          g   :1282[1]
    equb %00110000                                                    ; 4083: 30          0   :1283[1]

    equb %00000000                                                    ; 4084: 00          .   :1284[1]
    equb %00000000                                                    ; 4085: 00          .   :1285[1]
    equb %00000001                                                    ; 4086: 01          .   :1286[1]
    equb %00010010                                                    ; 4087: 12          .   :1287[1]
    equb %00010010                                                    ; 4088: 12          .   :1288[1]
    equb %00000001                                                    ; 4089: 01          .   :1289[1]
    equb %00000000                                                    ; 408a: 00          .   :128a[1]
    equb %00000000                                                    ; 408b: 00          .   :128b[1]

    equb %00000000                                                    ; 408c: 00          .   :128c[1]
    equb %00000000                                                    ; 408d: 00          .   :128d[1]
    equb %00001000                                                    ; 408e: 08          .   :128e[1]
    equb %10001100                                                    ; 408f: 8c          .   :128f[1]
    equb %10000100                                                    ; 4090: 84          .   :1290[1]
    equb %00001000                                                    ; 4091: 08          .   :1291[1]
    equb %00000000                                                    ; 4092: 00          .   :1292[1]
    equb %00000000                                                    ; 4093: 00          .   :1293[1]

    equb %01000000                                                    ; 4094: 40          @   :1294[1]
    equb %10010100                                                    ; 4095: 94          .   :1295[1]
    equb %00010010                                                    ; 4096: 12          .   :1296[1]
    equb %01000001                                                    ; 4097: 41          A   :1297[1]
    equb %01101000                                                    ; 4098: 68          h   :1298[1]
    equb %00010100                                                    ; 4099: 14          .   :1299[1]
    equb %10010010                                                    ; 409a: 92          .   :129a[1]
    equb %00001101                                                    ; 409b: 0d          .   :129b[1]

    equb %01000001                                                    ; 409c: 41          A   :129c[1]
    equb %00100100                                                    ; 409d: 24          $   :129d[1]
    equb %10000101                                                    ; 409e: 85          .   :129e[1]
    equb %00100000                                                    ; 409f: 20              :129f[1]
    equb %00110100                                                    ; 40a0: 34          4   :12a0[1]
    equb %00000010                                                    ; 40a1: 02          .   :12a1[1]
    equb %10010000                                                    ; 40a2: 90          .   :12a2[1]
    equb %00000011                                                    ; 40a3: 03          .   :12a3[1]

    equb %00001111                                                    ; 40a4: 0f          .   :12a4[1]
    equb %01011011                                                    ; 40a5: 5b          [   :12a5[1]
    equb %00011111                                                    ; 40a6: 1f          .   :12a6[1]
    equb %01111110                                                    ; 40a7: 7e          ~   :12a7[1]
    equb %11111000                                                    ; 40a8: f8          .   :12a8[1]
    equb %00011110                                                    ; 40a9: 1e          .   :12a9[1]
    equb %01011010                                                    ; 40aa: 5a          Z   :12aa[1]
    equb %00011111                                                    ; 40ab: 1f          .   :12ab[1]

    equb %10001000                                                    ; 40ac: 88          .   :12ac[1]
    equb %00001010                                                    ; 40ad: 0a          .   :12ad[1]
    equb %00001000                                                    ; 40ae: 08          .   :12ae[1]
    equb %00011111                                                    ; 40af: 1f          .   :12af[1]
    equb %01101110                                                    ; 40b0: 6e          n   :12b0[1]
    equb %10001000                                                    ; 40b1: 88          .   :12b1[1]
    equb %10001010                                                    ; 40b2: 8a          .   :12b2[1]
    equb %00000000                                                    ; 40b3: 00          .   :12b3[1]

    equb %00100001                                                    ; 40b4: 21          !   :12b4[1]
    equb %00110100                                                    ; 40b5: 34          4   :12b5[1]
    equb %01011010                                                    ; 40b6: 5a          Z   :12b6[1]
    equb %11110000                                                    ; 40b7: f0          .   :12b7[1]
    equb %01111000                                                    ; 40b8: 78          x   :12b8[1]
    equb %01101001                                                    ; 40b9: 69          i   :12b9[1]
    equb %00110100                                                    ; 40ba: 34          4   :12ba[1]
    equb %00000011                                                    ; 40bb: 03          .   :12bb[1]

    equb %00001000                                                    ; 40bc: 08          .   :12bc[1]
    equb %10000110                                                    ; 40bd: 86          .   :12bd[1]
    equb %11100001                                                    ; 40be: e1          .   :12be[1]
    equb %01101001                                                    ; 40bf: 69          i   :12bf[1]
    equb %11110000                                                    ; 40c0: f0          .   :12c0[1]
    equb %10110100                                                    ; 40c1: b4          .   :12c1[1]
    equb %11100001                                                    ; 40c2: e1          .   :12c2[1]
    equb %00001110                                                    ; 40c3: 0e          .   :12c3[1]

    equb %00000100                                                    ; 40c4: 04          .   :12c4[1]
    equb %00001101                                                    ; 40c5: 0d          .   :12c5[1]
    equb %00000011                                                    ; 40c6: 03          .   :12c6[1]
    equb %00000101                                                    ; 40c7: 05          .   :12c7[1]
    equb %00001110                                                    ; 40c8: 0e          .   :12c8[1]
    equb %00000101                                                    ; 40c9: 05          .   :12c9[1]
    equb %00001011                                                    ; 40ca: 0b          .   :12ca[1]
    equb %00001101                                                    ; 40cb: 0d          .   :12cb[1]

    equb %00000101                                                    ; 40cc: 05          .   :12cc[1]
    equb %00000110                                                    ; 40cd: 06          .   :12cd[1]
    equb %00001101                                                    ; 40ce: 0d          .   :12ce[1]
    equb %00000010                                                    ; 40cf: 02          .   :12cf[1]
    equb %00000111                                                    ; 40d0: 07          .   :12d0[1]
    equb %00000010                                                    ; 40d1: 02          .   :12d1[1]
    equb %00001001                                                    ; 40d2: 09          .   :12d2[1]
    equb %00000011                                                    ; 40d3: 03          .   :12d3[1]

    equb %00000000                                                    ; 40d4: 00          .   :12d4[1]
    equb %00000001                                                    ; 40d5: 01          .   :12d5[1]
    equb %00000001                                                    ; 40d6: 01          .   :12d6[1]
    equb %00010111                                                    ; 40d7: 17          .   :12d7[1]
    equb %01111111                                                    ; 40d8: 7f          .   :12d8[1]
    equb %00010001                                                    ; 40d9: 11          .   :12d9[1]
    equb %01010101                                                    ; 40da: 55          U   :12da[1]
    equb %00000001                                                    ; 40db: 01          .   :12db[1]

    equb %00001000                                                    ; 40dc: 08          .   :12dc[1]
    equb %10101010                                                    ; 40dd: aa          .   :12dd[1]
    equb %10001000                                                    ; 40de: 88          .   :12de[1]
    equb %11101111                                                    ; 40df: ef          .   :12df[1]
    equb %10001110                                                    ; 40e0: 8e          .   :12e0[1]
    equb %00001000                                                    ; 40e1: 08          .   :12e1[1]
    equb %00001000                                                    ; 40e2: 08          .   :12e2[1]
    equb %00000000                                                    ; 40e3: 00          .   :12e3[1]

    equb %00010001                                                    ; 40e4: 11          .   :12e4[1]
    equb %00110000                                                    ; 40e5: 30          0   :12e5[1]
    equb %01110000                                                    ; 40e6: 70          p   :12e6[1]
    equb %11111111                                                    ; 40e7: ff          .   :12e7[1]
    equb %11111111                                                    ; 40e8: ff          .   :12e8[1]
    equb %01010010                                                    ; 40e9: 52          R   :12e9[1]
    equb %00110000                                                    ; 40ea: 30          0   :12ea[1]
    equb %00000000                                                    ; 40eb: 00          .   :12eb[1]

    equb %00000000                                                    ; 40ec: 00          .   :12ec[1]
    equb %11000000                                                    ; 40ed: c0          .   :12ed[1]
    equb %11100000                                                    ; 40ee: e0          .   :12ee[1]
    equb %11111110                                                    ; 40ef: fe          .   :12ef[1]
    equb %11111110                                                    ; 40f0: fe          .   :12f0[1]
    equb %01001010                                                    ; 40f1: 4a          J   :12f1[1]
    equb %11000000                                                    ; 40f2: c0          .   :12f2[1]
    equb %00000000                                                    ; 40f3: 00          .   :12f3[1]

    equb %00000000                                                    ; 40f4: 00          .   :12f4[1]
    equb %00000001                                                    ; 40f5: 01          .   :12f5[1]
    equb %00000011                                                    ; 40f6: 03          .   :12f6[1]
    equb %00000111                                                    ; 40f7: 07          .   :12f7[1]
    equb %00000111                                                    ; 40f8: 07          .   :12f8[1]
    equb %00010011                                                    ; 40f9: 13          .   :12f9[1]
    equb %01100111                                                    ; 40fa: 67          g   :12fa[1]
    equb %00000000                                                    ; 40fb: 00          .   :12fb[1]

    equb %00000000                                                    ; 40fc: 00          .   :12fc[1]
    equb %00101010                                                    ; 40fd: 2a          *   :12fd[1]
    equb %00101110                                                    ; 40fe: 2e          .   :12fe[1]
    equb %01001110                                                    ; 40ff: 4e          N   :12ff[1]
    equb %10001110                                                    ; 4100: 8e          .   :1300[1]
    equb %00001100                                                    ; 4101: 0c          .   :1301[1]
    equb %00001000                                                    ; 4102: 08          .   :1302[1]
    equb %00000000                                                    ; 4103: 00          .   :1303[1]

    equb %11110000                                                    ; 4104: f0          .   :1304[1]
    equb %11110010                                                    ; 4105: f2          .   :1305[1]
    equb %11110100                                                    ; 4106: f4          .   :1306[1]
    equb %11110000                                                    ; 4107: f0          .   :1307[1]
    equb %11110000                                                    ; 4108: f0          .   :1308[1]
    equb %11110001                                                    ; 4109: f1          .   :1309[1]
    equb %11110000                                                    ; 410a: f0          .   :130a[1]
    equb %11110000                                                    ; 410b: f0          .   :130b[1]

    equb %11110000                                                    ; 410c: f0          .   :130c[1]
    equb %11110011                                                    ; 410d: f3          .   :130d[1]
    equb %11110000                                                    ; 410e: f0          .   :130e[1]
    equb %11110000                                                    ; 410f: f0          .   :130f[1]
    equb %11110010                                                    ; 4110: f2          .   :1310[1]
    equb %11111100                                                    ; 4111: fc          .   :1311[1]
    equb %11110000                                                    ; 4112: f0          .   :1312[1]
    equb %11110000                                                    ; 4113: f0          .   :1313[1]

    equb %00000000                                                    ; 4114: 00          .   :1314[1]
    equb %00000000                                                    ; 4115: 00          .   :1315[1]
    equb %00000000                                                    ; 4116: 00          .   :1316[1]
    equb %00000000                                                    ; 4117: 00          .   :1317[1]
    equb %00000000                                                    ; 4118: 00          .   :1318[1]
    equb %00000000                                                    ; 4119: 00          .   :1319[1]
    equb %00000000                                                    ; 411a: 00          .   :131a[1]
    equb %00000000                                                    ; 411b: 00          .   :131b[1]

    equb %00000000                                                    ; 411c: 00          .   :131c[1]
    equb %00000000                                                    ; 411d: 00          .   :131d[1]
    equb %00000000                                                    ; 411e: 00          .   :131e[1]
    equb %00000000                                                    ; 411f: 00          .   :131f[1]
    equb %00000000                                                    ; 4120: 00          .   :1320[1]
    equb %00000000                                                    ; 4121: 00          .   :1321[1]
    equb %00000000                                                    ; 4122: 00          .   :1322[1]
    equb %00000000                                                    ; 4123: 00          .   :1323[1]

    equb %00000000                                                    ; 4124: 00          .   :1324[1]
    equb %00000000                                                    ; 4125: 00          .   :1325[1]
    equb %00000000                                                    ; 4126: 00          .   :1326[1]
    equb %00000000                                                    ; 4127: 00          .   :1327[1]
    equb %00000000                                                    ; 4128: 00          .   :1328[1]
    equb %00000000                                                    ; 4129: 00          .   :1329[1]
    equb %00000000                                                    ; 412a: 00          .   :132a[1]
    equb %00000000                                                    ; 412b: 00          .   :132b[1]

    equb %00000000                                                    ; 412c: 00          .   :132c[1]
    equb %00000000                                                    ; 412d: 00          .   :132d[1]
    equb %00000000                                                    ; 412e: 00          .   :132e[1]
    equb %00000000                                                    ; 412f: 00          .   :132f[1]
    equb %00000000                                                    ; 4130: 00          .   :1330[1]
    equb %00000000                                                    ; 4131: 00          .   :1331[1]
    equb %00000000                                                    ; 4132: 00          .   :1332[1]
    equb %00000000                                                    ; 4133: 00          .   :1333[1]

    equb %00000000                                                    ; 4134: 00          .   :1334[1]
    equb %00000000                                                    ; 4135: 00          .   :1335[1]
    equb %00000000                                                    ; 4136: 00          .   :1336[1]
    equb %00000000                                                    ; 4137: 00          .   :1337[1]
    equb %00000000                                                    ; 4138: 00          .   :1338[1]
    equb %00000000                                                    ; 4139: 00          .   :1339[1]
    equb %00000000                                                    ; 413a: 00          .   :133a[1]
    equb %00000000                                                    ; 413b: 00          .   :133b[1]

    equb %00000000                                                    ; 413c: 00          .   :133c[1]
    equb %00000000                                                    ; 413d: 00          .   :133d[1]
    equb %00000000                                                    ; 413e: 00          .   :133e[1]
    equb %00000000                                                    ; 413f: 00          .   :133f[1]
    equb %00000000                                                    ; 4140: 00          .   :1340[1]
    equb %00000000                                                    ; 4141: 00          .   :1341[1]
    equb %00000000                                                    ; 4142: 00          .   :1342[1]
    equb %00000000                                                    ; 4143: 00          .   :1343[1]

    equb %00000001                                                    ; 4144: 01          .   :1344[1]
    equb %00010000                                                    ; 4145: 10          .   :1345[1]
    equb %00010010                                                    ; 4146: 12          .   :1346[1]
    equb %00100101                                                    ; 4147: 25          %   :1347[1]
    equb %00100001                                                    ; 4148: 21          !   :1348[1]
    equb %01100101                                                    ; 4149: 65          e   :1349[1]
    equb %11110100                                                    ; 414a: f4          .   :134a[1]
    equb %10010110                                                    ; 414b: 96          .   :134b[1]

    equb %00001000                                                    ; 414c: 08          .   :134c[1]
    equb %10001000                                                    ; 414d: 88          .   :134d[1]
    equb %10000100                                                    ; 414e: 84          .   :134e[1]
    equb %01001110                                                    ; 414f: 4e          N   :134f[1]
    equb %11000100                                                    ; 4150: c4          .   :1350[1]
    equb %01101010                                                    ; 4151: 6a          j   :1351[1]
    equb %11110011                                                    ; 4152: f3          .   :1352[1]
    equb %10011110                                                    ; 4153: 9e          .   :1353[1]

    equb %11000000                                                    ; 4154: c0          .   :1354[1]
    equb %01101110                                                    ; 4155: 6e          n   :1355[1]
    equb %01111000                                                    ; 4156: 78          x   :1356[1]
    equb %11000011                                                    ; 4157: c3          .   :1357[1]
    equb %11011010                                                    ; 4158: da          .   :1358[1]
    equb %01111001                                                    ; 4159: 79          y   :1359[1]
    equb %01101110                                                    ; 415a: 6e          n   :135a[1]
    equb %11000100                                                    ; 415b: c4          .   :135b[1]

    equb %00000000                                                    ; 415c: 00          .   :135c[1]
    equb %00001000                                                    ; 415d: 08          .   :135d[1]
    equb %10000100                                                    ; 415e: 84          .   :135e[1]
    equb %01101001                                                    ; 415f: 69          i   :135f[1]
    equb %01101011                                                    ; 4160: 6b          k   :1360[1]
    equb %10001100                                                    ; 4161: 8c          .   :1361[1]
    equb %00001000                                                    ; 4162: 08          .   :1362[1]
    equb %00000000                                                    ; 4163: 00          .   :1363[1]

    equb %10010111                                                    ; 4164: 97          .   :1364[1]
    equb %11111100                                                    ; 4165: fc          .   :1365[1]
    equb %01100101                                                    ; 4166: 65          e   :1366[1]
    equb %00110010                                                    ; 4167: 32          2   :1367[1]
    equb %00100111                                                    ; 4168: 27          '   :1368[1]
    equb %00010010                                                    ; 4169: 12          .   :1369[1]
    equb %00010001                                                    ; 416a: 11          .   :136a[1]
    equb %00000001                                                    ; 416b: 01          .   :136b[1]

    equb %10010110                                                    ; 416c: 96          .   :136c[1]
    equb %11110010                                                    ; 416d: f2          .   :136d[1]
    equb %01101010                                                    ; 416e: 6a          j   :136e[1]
    equb %01001000                                                    ; 416f: 48          H   :136f[1]
    equb %01001010                                                    ; 4170: 4a          J   :1370[1]
    equb %10000100                                                    ; 4171: 84          .   :1371[1]
    equb %10000000                                                    ; 4172: 80          .   :1372[1]
    equb %00001000                                                    ; 4173: 08          .   :1373[1]

    equb %00000000                                                    ; 4174: 00          .   :1374[1]
    equb %00000001                                                    ; 4175: 01          .   :1375[1]
    equb %00010011                                                    ; 4176: 13          .   :1376[1]
    equb %01101101                                                    ; 4177: 6d          m   :1377[1]
    equb %01101001                                                    ; 4178: 69          i   :1378[1]
    equb %00010010                                                    ; 4179: 12          .   :1379[1]
    equb %00000001                                                    ; 417a: 01          .   :137a[1]
    equb %00000000                                                    ; 417b: 00          .   :137b[1]

    equb %00110010                                                    ; 417c: 32          2   :137c[1]
    equb %01100111                                                    ; 417d: 67          g   :137d[1]
    equb %11101001                                                    ; 417e: e9          .   :137e[1]
    equb %10110101                                                    ; 417f: b5          .   :137f[1]
    equb %00111100                                                    ; 4180: 3c          <   :1380[1]
    equb %11100001                                                    ; 4181: e1          .   :1381[1]
    equb %01100111                                                    ; 4182: 67          g   :1382[1]
    equb %00110000                                                    ; 4183: 30          0   :1383[1]

    equb %00000000                                                    ; 4184: 00          .   :1384[1]
    equb %00000000                                                    ; 4185: 00          .   :1385[1]
    equb %00000001                                                    ; 4186: 01          .   :1386[1]
    equb %00010010                                                    ; 4187: 12          .   :1387[1]
    equb %00010010                                                    ; 4188: 12          .   :1388[1]
    equb %00000001                                                    ; 4189: 01          .   :1389[1]
    equb %00000000                                                    ; 418a: 00          .   :138a[1]
    equb %00000000                                                    ; 418b: 00          .   :138b[1]

    equb %00000000                                                    ; 418c: 00          .   :138c[1]
    equb %00000000                                                    ; 418d: 00          .   :138d[1]
    equb %00001000                                                    ; 418e: 08          .   :138e[1]
    equb %10001100                                                    ; 418f: 8c          .   :138f[1]
    equb %10000100                                                    ; 4190: 84          .   :1390[1]
    equb %00001000                                                    ; 4191: 08          .   :1391[1]
    equb %00000000                                                    ; 4192: 00          .   :1392[1]
    equb %00000000                                                    ; 4193: 00          .   :1393[1]

    equb %01000000                                                    ; 4194: 40          @   :1394[1]
    equb %10010100                                                    ; 4195: 94          .   :1395[1]
    equb %00010010                                                    ; 4196: 12          .   :1396[1]
    equb %01000001                                                    ; 4197: 41          A   :1397[1]
    equb %01101000                                                    ; 4198: 68          h   :1398[1]
    equb %00010100                                                    ; 4199: 14          .   :1399[1]
    equb %10010010                                                    ; 419a: 92          .   :139a[1]
    equb %00001101                                                    ; 419b: 0d          .   :139b[1]

    equb %01000001                                                    ; 419c: 41          A   :139c[1]
    equb %00100100                                                    ; 419d: 24          $   :139d[1]
    equb %10000101                                                    ; 419e: 85          .   :139e[1]
    equb %00100000                                                    ; 419f: 20              :139f[1]
    equb %00110100                                                    ; 41a0: 34          4   :13a0[1]
    equb %00000010                                                    ; 41a1: 02          .   :13a1[1]
    equb %10010000                                                    ; 41a2: 90          .   :13a2[1]
    equb %00000011                                                    ; 41a3: 03          .   :13a3[1]

    equb %00001111                                                    ; 41a4: 0f          .   :13a4[1]
    equb %01011011                                                    ; 41a5: 5b          [   :13a5[1]
    equb %00011111                                                    ; 41a6: 1f          .   :13a6[1]
    equb %01111110                                                    ; 41a7: 7e          ~   :13a7[1]
    equb %11111000                                                    ; 41a8: f8          .   :13a8[1]
    equb %00011110                                                    ; 41a9: 1e          .   :13a9[1]
    equb %01011010                                                    ; 41aa: 5a          Z   :13aa[1]
    equb %00011111                                                    ; 41ab: 1f          .   :13ab[1]

    equb %10001000                                                    ; 41ac: 88          .   :13ac[1]
    equb %00001010                                                    ; 41ad: 0a          .   :13ad[1]
    equb %00001000                                                    ; 41ae: 08          .   :13ae[1]
    equb %00011111                                                    ; 41af: 1f          .   :13af[1]
    equb %01101110                                                    ; 41b0: 6e          n   :13b0[1]
    equb %10001000                                                    ; 41b1: 88          .   :13b1[1]
    equb %10001010                                                    ; 41b2: 8a          .   :13b2[1]
    equb %00000000                                                    ; 41b3: 00          .   :13b3[1]

    equb %00100101                                                    ; 41b4: 25          %   :13b4[1]
    equb %01111000                                                    ; 41b5: 78          x   :13b5[1]
    equb %01101001                                                    ; 41b6: 69          i   :13b6[1]
    equb %11110000                                                    ; 41b7: f0          .   :13b7[1]
    equb %01011010                                                    ; 41b8: 5a          Z   :13b8[1]
    equb %00110100                                                    ; 41b9: 34          4   :13b9[1]
    equb %00010010                                                    ; 41ba: 12          .   :13ba[1]
    equb %00000001                                                    ; 41bb: 01          .   :13bb[1]

    equb %00001100                                                    ; 41bc: 0c          .   :13bc[1]
    equb %11000010                                                    ; 41bd: c2          .   :13bd[1]
    equb %11100001                                                    ; 41be: e1          .   :13be[1]
    equb %10110100                                                    ; 41bf: b4          .   :13bf[1]
    equb %11110000                                                    ; 41c0: f0          .   :13c0[1]
    equb %01101001                                                    ; 41c1: 69          i   :13c1[1]
    equb %11000010                                                    ; 41c2: c2          .   :13c2[1]
    equb %00001100                                                    ; 41c3: 0c          .   :13c3[1]

    equb %00000000                                                    ; 41c4: 00          .   :13c4[1]
    equb %00001010                                                    ; 41c5: 0a          .   :13c5[1]
    equb %00000101                                                    ; 41c6: 05          .   :13c6[1]
    equb %00001010                                                    ; 41c7: 0a          .   :13c7[1]
    equb %00000100                                                    ; 41c8: 04          .   :13c8[1]
    equb %00001010                                                    ; 41c9: 0a          .   :13c9[1]
    equb %00000101                                                    ; 41ca: 05          .   :13ca[1]
    equb %00001010                                                    ; 41cb: 0a          .   :13cb[1]

    equb %00000101                                                    ; 41cc: 05          .   :13cc[1]
    equb %00001010                                                    ; 41cd: 0a          .   :13cd[1]
    equb %00000101                                                    ; 41ce: 05          .   :13ce[1]
    equb %00001101                                                    ; 41cf: 0d          .   :13cf[1]
    equb %00000010                                                    ; 41d0: 02          .   :13d0[1]
    equb %00001101                                                    ; 41d1: 0d          .   :13d1[1]
    equb %00000010                                                    ; 41d2: 02          .   :13d2[1]
    equb %00001101                                                    ; 41d3: 0d          .   :13d3[1]

    equb %00000001                                                    ; 41d4: 01          .   :13d4[1]
    equb %01010101                                                    ; 41d5: 55          U   :13d5[1]
    equb %00010001                                                    ; 41d6: 11          .   :13d6[1]
    equb %01111111                                                    ; 41d7: 7f          .   :13d7[1]
    equb %00010111                                                    ; 41d8: 17          .   :13d8[1]
    equb %00000001                                                    ; 41d9: 01          .   :13d9[1]
    equb %00000001                                                    ; 41da: 01          .   :13da[1]
    equb %00000000                                                    ; 41db: 00          .   :13db[1]

    equb %00000000                                                    ; 41dc: 00          .   :13dc[1]
    equb %00001000                                                    ; 41dd: 08          .   :13dd[1]
    equb %00001000                                                    ; 41de: 08          .   :13de[1]
    equb %10001110                                                    ; 41df: 8e          .   :13df[1]
    equb %11101111                                                    ; 41e0: ef          .   :13e0[1]
    equb %10001000                                                    ; 41e1: 88          .   :13e1[1]
    equb %10101010                                                    ; 41e2: aa          .   :13e2[1]
    equb %00001000                                                    ; 41e3: 08          .   :13e3[1]

    equb %00010001                                                    ; 41e4: 11          .   :13e4[1]
    equb %00110000                                                    ; 41e5: 30          0   :13e5[1]
    equb %01110000                                                    ; 41e6: 70          p   :13e6[1]
    equb %11111111                                                    ; 41e7: ff          .   :13e7[1]
    equb %11111111                                                    ; 41e8: ff          .   :13e8[1]
    equb %00100101                                                    ; 41e9: 25          %   :13e9[1]
    equb %00110000                                                    ; 41ea: 30          0   :13ea[1]
    equb %00000000                                                    ; 41eb: 00          .   :13eb[1]

    equb %00000000                                                    ; 41ec: 00          .   :13ec[1]
    equb %11000000                                                    ; 41ed: c0          .   :13ed[1]
    equb %11100000                                                    ; 41ee: e0          .   :13ee[1]
    equb %11111111                                                    ; 41ef: ff          .   :13ef[1]
    equb %11111111                                                    ; 41f0: ff          .   :13f0[1]
    equb %10100100                                                    ; 41f1: a4          .   :13f1[1]
    equb %11000000                                                    ; 41f2: c0          .   :13f2[1]
    equb %00000000                                                    ; 41f3: 00          .   :13f3[1]

    equb %00010001                                                    ; 41f4: 11          .   :13f4[1]
    equb %00100011                                                    ; 41f5: 23          #   :13f5[1]
    equb %01000111                                                    ; 41f6: 47          G   :13f6[1]
    equb %10001111                                                    ; 41f7: 8f          .   :13f7[1]
    equb %10001111                                                    ; 41f8: 8f          .   :13f8[1]
    equb %10001011                                                    ; 41f9: 8b          .   :13f9[1]
    equb %01000101                                                    ; 41fa: 45          E   :13fa[1]
    equb %00110011                                                    ; 41fb: 33          3   :13fb[1]

    equb %11001100                                                    ; 41fc: cc          .   :13fc[1]
    equb %00101010                                                    ; 41fd: 2a          *   :13fd[1]
    equb %00011101                                                    ; 41fe: 1d          .   :13fe[1]
    equb %00011111                                                    ; 41ff: 1f          .   :13ff[1]
    equb %00011111                                                    ; 4200: 1f          .   :1400[1]
    equb %00101110                                                    ; 4201: 2e          .   :1401[1]
    equb %01001100                                                    ; 4202: 4c          L   :1402[1]
    equb %10001000                                                    ; 4203: 88          .   :1403[1]

    equb %11110000                                                    ; 4204: f0          .   :1404[1]
    equb %11110000                                                    ; 4205: f0          .   :1405[1]
    equb %11110100                                                    ; 4206: f4          .   :1406[1]
    equb %11110010                                                    ; 4207: f2          .   :1407[1]
    equb %11110000                                                    ; 4208: f0          .   :1408[1]
    equb %11110000                                                    ; 4209: f0          .   :1409[1]
    equb %11110000                                                    ; 420a: f0          .   :140a[1]
    equb %11110000                                                    ; 420b: f0          .   :140b[1]

    equb %11110000                                                    ; 420c: f0          .   :140c[1]
    equb %11110001                                                    ; 420d: f1          .   :140d[1]
    equb %11110010                                                    ; 420e: f2          .   :140e[1]
    equb %11110000                                                    ; 420f: f0          .   :140f[1]
    equb %11110000                                                    ; 4210: f0          .   :1410[1]
    equb %11110010                                                    ; 4211: f2          .   :1411[1]
    equb %11111100                                                    ; 4212: fc          .   :1412[1]
    equb %11110000                                                    ; 4213: f0          .   :1413[1]

    equb %00000000                                                    ; 4214: 00          .   :1414[1]
    equb %00000000                                                    ; 4215: 00          .   :1415[1]
    equb %00000000                                                    ; 4216: 00          .   :1416[1]
    equb %00000000                                                    ; 4217: 00          .   :1417[1]
    equb %00000000                                                    ; 4218: 00          .   :1418[1]
    equb %00000000                                                    ; 4219: 00          .   :1419[1]
    equb %00000000                                                    ; 421a: 00          .   :141a[1]
    equb %00000000                                                    ; 421b: 00          .   :141b[1]

    equb %00000000                                                    ; 421c: 00          .   :141c[1]
    equb %00000000                                                    ; 421d: 00          .   :141d[1]
    equb %00000000                                                    ; 421e: 00          .   :141e[1]
    equb %00000000                                                    ; 421f: 00          .   :141f[1]
    equb %00000000                                                    ; 4220: 00          .   :1420[1]
    equb %00000000                                                    ; 4221: 00          .   :1421[1]
    equb %00000000                                                    ; 4222: 00          .   :1422[1]
    equb %00000000                                                    ; 4223: 00          .   :1423[1]

    equb %00000000                                                    ; 4224: 00          .   :1424[1]
    equb %00000000                                                    ; 4225: 00          .   :1425[1]
    equb %00000000                                                    ; 4226: 00          .   :1426[1]
    equb %00000000                                                    ; 4227: 00          .   :1427[1]
    equb %00000000                                                    ; 4228: 00          .   :1428[1]
    equb %00000000                                                    ; 4229: 00          .   :1429[1]
    equb %00000000                                                    ; 422a: 00          .   :142a[1]
    equb %00000000                                                    ; 422b: 00          .   :142b[1]

    equb %00000000                                                    ; 422c: 00          .   :142c[1]
    equb %00000000                                                    ; 422d: 00          .   :142d[1]
    equb %00000000                                                    ; 422e: 00          .   :142e[1]
    equb %00000000                                                    ; 422f: 00          .   :142f[1]
    equb %00000000                                                    ; 4230: 00          .   :1430[1]
    equb %00000000                                                    ; 4231: 00          .   :1431[1]
    equb %00000000                                                    ; 4232: 00          .   :1432[1]
    equb %00000000                                                    ; 4233: 00          .   :1433[1]

.raw_palettes
    ; format: &0GBR
    equw 0                                                            ; 4234: 00 00       ..  :1434[1]
    equw &061f                                                        ; 4236: 1f 06       ..  :1436[1]
    equw &0f00                                                        ; 4238: 00 0f       ..  :1438[1]
    equw &0fac                                                        ; 423a: ac 0f       ..  :143a[1]
    equw &0900                                                        ; 423c: 00 09       ..  :143c[1]
    equw &0f27                                                        ; 423e: 27 0f       '.  :143e[1]
    equw &0518                                                        ; 4240: 18 05       ..  :1440[1]
    equw &061f                                                        ; 4242: 1f 06       ..  :1442[1]
    equw &08b0                                                        ; 4244: b0 08       ..  :1444[1]
    equw &0df2                                                        ; 4246: f2 0d       ..  :1446[1]
    equw &0aaa                                                        ; 4248: aa 0a       ..  :1448[1]
    equw &0bbb                                                        ; 424a: bb 0b       ..  :144a[1]
    equw &0ccc                                                        ; 424c: cc 0c       ..  :144c[1]
    equw &0ddd                                                        ; 424e: dd 0d       ..  :144e[1]
    equw &0eee                                                        ; 4250: ee 0e       ..  :1450[1]
    equw &0fff                                                        ; 4252: ff 0f       ..  :1452[1]

    equb 0, 0                                                         ; 4254: 00 00       ..  :1454[1]
.attribution_message
    equs "Written By Keith S, based on the DOS game by Mark Elendt.." ; 4256: 57 72 69... Wri :1456[1]
    equs ". Thanks to Shane O'Brien,Roland Rzasa,Brainslave,Sal Gund" ; 4290: 2e 20 54... . T :1490[1]
    equs "uz,Paul Barrick,Richard Farrell,Oleg Tcymbaliuk,Barry Whit" ; 42ca: 75 7a 2c... uz, :14ca[1]
    equs "e,Robsoft,Ervin Pajor and my other patreons"                ; 4304: 65 2c 52... e,R :1504[1]
    equb &ff                                                          ; 432f: ff          .   :152f[1]
.url_message
    equs "www.chibiakumas.com/6502"                                   ; 4330: 77 77 77... www :1530[1]
    equb &ff                                                          ; 4348: ff          .   :1548[1]
.high_score_message
    equs "HiScore:"                                                   ; 4349: 48 69 53... HiS :1549[1]
    equb &ff                                                          ; 4351: ff          .   :1551[1]
.paused_message
    equs "Paused"                                                     ; 4352: 50 61 75... Pau :1552[1]
    equb &ff                                                          ; 4358: ff          .   :1558[1]
    ; score values to add, in binary coded decimal
.bcd_1
    equb 0, 0, 0, 1                                                   ; 4359: 00 00 00... ... :1559[1]
.bcd_3
    equb 0, 0, 0, 3                                                   ; 435d: 00 00 00... ... :155d[1]
.bcd_5
    equb 0, 0, 0, 5                                                   ; 4361: 00 00 00... ... :1561[1]
.bcd_20
    equb 0, 0, 0, &20                                                 ; 4365: 00 00 00... ... :1565[1]
; The title screen 'GRIME' logo. Each row of the logo is 24 bytes wide.
.title_screen_cells
    equb 0,   0,   0,   9,   9,   0,   9,   9,   9,   0,   0,   9     ; 4369: 00 00 00... ... :1569[1]
    equb 0,   0,   9,   9,   9,   0,   9,   0,   9,   9,   0,   0     ; 4375: 00 00 09... ... :1575[1]
    equb 9,   0,   9,   0,   0,   9,   9,   0,   0,   9,   9,   0     ; 4381: 09 00 09... ... :1581[1]
    equb 9,   9,   0,   9,   0,   9,   9,   9,   0,   0,   9,   0     ; 438d: 09 09 00... ... :158d[1]
    equb 0,   9,   0, &0d, &0d,   0,   0, &0d, &0d,   0,   0, &0d     ; 4399: 00 09 00... ... :1599[1]
    equb 0,   0, &0d,   0, &0d,   0,   9,   0, &0d, &0d,   0,   9     ; 43a5: 00 00 0d... ... :15a5[1]
    equb 9,   0, &0d,   0,   0,   0,   0, &0d,   0, &0d,   0, &0d     ; 43b1: 09 00 0d... ... :15b1[1]
    equb 0, &0d,   0, &0d,   0, &0d,   0, &0d,   0,   0,   9,   0     ; 43bd: 00 0d 00... ... :15bd[1]
    equb 9,   0, &0d,   0, &0d, &0d,   0, &0d, &0d,   0,   0, &0d     ; 43c9: 09 00 0d... ... :15c9[1]
    equb 0, &0d,   0,   0,   0, &0d,   0, &0d, &0d,   0,   9,   0     ; 43d5: 00 0d 00... ... :15d5[1]
    equb 9,   0, &0d,   0,   0, &0d,   0, &0d,   0, &0d,   0, &0d     ; 43e1: 09 00 0d... ... :15e1[1]
    equb 0, &0d,   0,   9,   0, &0d,   0, &0d,   0,   0,   9,   0     ; 43ed: 00 0d 00... ... :15ed[1]
    equb 0,   9,   0, &0d, &0d,   0,   0, &0d,   0, &0d,   0, &0d     ; 43f9: 00 09 00... ... :15f9[1]
    equb 0, &0d,   0,   9,   0, &0d,   0,   0, &0d, &0d,   0,   9     ; 4405: 00 0d 00... ... :1605[1]
    equb 9,   0,   9,   0,   0,   9,   0,   0,   0,   0,   0,   0     ; 4411: 09 00 09... ... :1611[1]
    equb 9,   0,   0,   9,   9,   0,   0,   9,   0,   0,   9,   0     ; 441d: 09 00 00... ... :161d[1]
    equb 0,   9,   9,   9,   9,   0, &0d, &0d,   0, &0d, &0d, &0d     ; 4429: 00 09 09... ... :1629[1]
    equb 0,   0, &0d,   0,   0, &0d, &0d,   0,   9,   9,   9,   9     ; 4435: 00 00 0d... ... :1635[1]
    equb 0,   9,   9,   9,   0, &0d,   0,   0,   0, &0d,   0,   0     ; 4441: 00 09 09... ... :1641[1]
    equb 0, &0d,   0, &0d,   0,   0,   0, &0d,   0,   9,   9,   0     ; 444d: 00 0d 00... ... :164d[1]
    equb 0,   0,   9,   9,   0, &0d, &0d,   0,   0, &0d, &0d,   0     ; 4459: 00 00 09... ... :1659[1]
    equb 0, &0d,   0, &0d,   0,   0, &0d,   0,   9,   9,   9,   0     ; 4465: 00 0d 00... ... :1665[1]
    equb 9,   9,   9,   9,   0, &0d,   0, &0d,   0,   0,   0, &0d     ; 4471: 09 09 09... ... :1671[1]
    equb 0, &0d,   0, &0d,   0, &0d,   0,   0,   9,   9,   9,   9     ; 447d: 00 0d 00... ... :167d[1]
    equb 0,   9,   0,   9,   9,   0, &0d,   0,   0, &0d, &0d,   0     ; 4489: 00 09 00... ... :1689[1]
    equb 9,   0, &0d,   0,   0, &0d, &0d, &0d,   0,   9,   0,   0     ; 4495: 09 00 0d... ... :1695[1]
    equb 0,   0,   9,   9,   9,   9,   0,   9,   9,   0,   0,   9     ; 44a1: 00 00 09... ... :16a1[1]
    equb 9,   9,   0,   9,   9,   0,   0,   0,   9,   9,   9,   0     ; 44ad: 09 09 00... ... :16ad[1]
    equb 0,   0,   0,   9,   9,   9,   9,   9,   9,   9,   9,   9     ; 44b9: 00 00 00... ... :16b9[1]
    equb 0,   9,   9,   9,   9,   9,   9,   9,   0,   0,   9,   0     ; 44c5: 00 09 09... ... :16c5[1]
    equb 0,   0,   9,   0,   9,   0,   0,   9,   0,   9,   0,   0     ; 44d1: 00 00 09... ... :16d1[1]
    equb 9,   0,   0,   0,   9,   0,   0,   9,   0,   0,   0,   0     ; 44dd: 09 00 00... ... :16dd[1]
.random_source
    equb &8b, &0d, &1a, &52, &9c, &4e, &f6, &37                       ; 44e9: 8b 0d 1a... ... :16e9[1]

.read_both_controls
    lda #0                                                            ; 44f1: a9 00       ..  :16f1[1]
    sta system_via_ddrb                                               ; 44f3: 8d 42 fe    .B. :16f3[1]   ; port to read for fire button
    sta z_as                                                          ; 44f6: 85 26       .&  :16f6[1]
    jsr read_joystick_axes                                            ; 44f8: 20 10 17     .. :16f8[1]
    lda #1                                                            ; 44fb: a9 01       ..  :16fb[1]
    jsr read_joystick_axes                                            ; 44fd: 20 10 17     .. :16fd[1]
    lda system_via_orb_irb                                            ; 4500: ad 40 fe    .@. :1700[1]   ; fire button
    and #&10                                                          ; 4503: 29 10       ).  :1703[1]
    ora z_as                                                          ; 4505: 05 26       .&  :1705[1]
    eor #&ef                                                          ; 4507: 49 ef       I.  :1707[1]
    sta z_h                                                           ; 4509: 85 21       .!  :1709[1]
    lda #&ff                                                          ; 450b: a9 ff       ..  :170b[1]
    sta z_l                                                           ; 450d: 85 20       .   :170d[1]
    rts                                                               ; 450f: 60          `   :170f[1]

.read_joystick_axes
    sta adc_start_conversion_or_status                                ; 4510: 8d c0 fe    ... :1710[1]
.read_joystick_axes_wait_loop
    lda adc_start_conversion_or_status                                ; 4513: ad c0 fe    ... :1713[1]
    and #&80                                                          ; 4516: 29 80       ).  :1716[1]
    bne read_joystick_axes_wait_loop                                  ; 4518: d0 f9       ..  :1718[1]
    lda adc_read_data_high_byte                                       ; 451a: ad c1 fe    ... :171a[1]
    cmp #&df                                                          ; 451d: c9 df       ..  :171d[1]
    bcs read_joystick_dual_high                                       ; 451f: b0 0b       ..  :171f[1]
    cmp #&20                                                          ; 4521: c9 20       .   :1721[1]
    bcc read_joystick_dual_low                                        ; 4523: 90 0e       ..  :1723[1]
    clc                                                               ; 4525: 18          .   :1725[1]
    rol z_as                                                          ; 4526: 26 26       &&  :1726[1]
    clc                                                               ; 4528: 18          .   :1728[1]
    rol z_as                                                          ; 4529: 26 26       &&  :1729[1]
    rts                                                               ; 452b: 60          `   :172b[1]

.read_joystick_dual_high
    clc                                                               ; 452c: 18          .   :172c[1]
    rol z_as                                                          ; 452d: 26 26       &&  :172d[1]
    sec                                                               ; 452f: 38          8   :172f[1]
    rol z_as                                                          ; 4530: 26 26       &&  :1730[1]
    rts                                                               ; 4532: 60          `   :1732[1]

.read_joystick_dual_low
    sec                                                               ; 4533: 38          8   :1733[1]
    rol z_as                                                          ; 4534: 26 26       &&  :1734[1]
    clc                                                               ; 4536: 18          .   :1736[1]
    rol z_as                                                          ; 4537: 26 26       &&  :1737[1]
    rts                                                               ; 4539: 60          `   :1739[1]

.print_X_bcd_bytes
    ldy #0                                                            ; 453a: a0 00       ..  :173a[1]
.print_X_bcd_bytes_loop
    tya                                                               ; 453c: 98          .   :173c[1]
    pha                                                               ; 453d: 48          H   :173d[1]
    lda z_e                                                           ; 453e: a5 24       .$  :173e[1]
    pha                                                               ; 4540: 48          H   :1740[1]
    lda z_d                                                           ; 4541: a5 25       .%  :1741[1]
    pha                                                               ; 4543: 48          H   :1743[1]
    lda (z_e),y                                                       ; 4544: b1 24       .$  :1744[1]
    jsr print_bcd_byte                                                ; 4546: 20 80 17     .. :1746[1]
    pla                                                               ; 4549: 68          h   :1749[1]
    sta z_d                                                           ; 454a: 85 25       .%  :174a[1]
    pla                                                               ; 454c: 68          h   :174c[1]
    sta z_e                                                           ; 454d: 85 24       .$  :174d[1]
    pla                                                               ; 454f: 68          h   :174f[1]
    tay                                                               ; 4550: a8          .   :1750[1]
    iny                                                               ; 4551: c8          .   :1751[1]
    dex                                                               ; 4552: ca          .   :1752[1]
    bne print_X_bcd_bytes_loop                                        ; 4553: d0 e7       ..  :1753[1]
    rts                                                               ; 4555: 60          `   :1755[1]

.bcd_add
    txa                                                               ; 4556: 8a          .   :1756[1]
    tay                                                               ; 4557: a8          .   :1757[1]
    dey                                                               ; 4558: 88          .   :1758[1]
    php                                                               ; 4559: 08          .   :1759[1]
    sed                                                               ; 455a: f8          .   :175a[1]
    clc                                                               ; 455b: 18          .   :175b[1]
.bcd_add_loop
    lda (z_e),y                                                       ; 455c: b1 24       .$  :175c[1]
    adc (z_l),y                                                       ; 455e: 71 20       q   :175e[1]
    sta (z_e),y                                                       ; 4560: 91 24       .$  :1760[1]
    dex                                                               ; 4562: ca          .   :1762[1]
    beq bcd_add_done                                                  ; 4563: f0 04       ..  :1763[1]
    dey                                                               ; 4565: 88          .   :1765[1]
    jmp bcd_add_loop                                                  ; 4566: 4c 5c 17    L\. :1766[1]

.bcd_add_done
    plp                                                               ; 4569: 28          (   :1769[1]
    rts                                                               ; 456a: 60          `   :176a[1]

; unused
.bcd_sub
    txa                                                               ; 456b: 8a          .   :176b[1]
    tay                                                               ; 456c: a8          .   :176c[1]
    dey                                                               ; 456d: 88          .   :176d[1]
    php                                                               ; 456e: 08          .   :176e[1]
    sed                                                               ; 456f: f8          .   :176f[1]
    sec                                                               ; 4570: 38          8   :1770[1]
.bcd_sub_loop
    lda (z_e),y                                                       ; 4571: b1 24       .$  :1771[1]
    sbc (z_l),y                                                       ; 4573: f1 20       .   :1773[1]
    sta (z_e),y                                                       ; 4575: 91 24       .$  :1775[1]
    dex                                                               ; 4577: ca          .   :1777[1]
    beq bcd_sub_done                                                  ; 4578: f0 04       ..  :1778[1]
    dey                                                               ; 457a: 88          .   :177a[1]
    jmp bcd_sub_loop                                                  ; 457b: 4c 71 17    Lq. :177b[1]

.bcd_sub_done
    plp                                                               ; 457e: 28          (   :177e[1]
    rts                                                               ; 457f: 60          `   :177f[1]

.print_bcd_byte
    pha                                                               ; 4580: 48          H   :1780[1]
    and #&f0                                                          ; 4581: 29 f0       ).  :1781[1]
    jsr swap_nybbles                                                  ; 4583: 20 2b 0f     +. :1783[1]
    jsr print_bcd_digit                                               ; 4586: 20 8c 17     .. :1786[1]
    pla                                                               ; 4589: 68          h   :1789[1]
    and #&0f                                                          ; 458a: 29 0f       ).  :178a[1]
.print_bcd_digit
    clc                                                               ; 458c: 18          .   :178c[1]
    adc #&30                                                          ; 458d: 69 30       i0  :178d[1]
    jmp print_char                                                    ; 458f: 4c 6f 18    Lo. :178f[1]

.compare_bcd
    txa                                                               ; 4592: 8a          .   :1792[1]
    tay                                                               ; 4593: a8          .   :1793[1]
    dey                                                               ; 4594: 88          .   :1794[1]
    sed                                                               ; 4595: f8          .   :1795[1]
.compare_bcd_loop
    lda (z_l),y                                                       ; 4596: b1 20       .   :1796[1]
    cmp (z_e),y                                                       ; 4598: d1 24       .$  :1798[1]
    bne compare_bcd_done                                              ; 459a: d0 07       ..  :179a[1]
    dex                                                               ; 459c: ca          .   :179c[1]
    beq compare_bcd_done                                              ; 459d: f0 04       ..  :179d[1]
    dey                                                               ; 459f: 88          .   :179f[1]
    jmp compare_bcd_loop                                              ; 45a0: 4c 96 17    L.. :17a0[1]

.compare_bcd_done
    cld                                                               ; 45a3: d8          .   :17a3[1]
    rts                                                               ; 45a4: 60          `   :17a4[1]

.show_tile
    sta z_e                                                           ; 45a5: 85 24       .$  :17a5[1]   ; need A for colour later
    lda #0                                                            ; 45a7: a9 00       ..  :17a7[1]
    clc                                                               ; 45a9: 18          .   :17a9[1]
    rol z_e                                                           ; 45aa: 26 24       &$  :17aa[1]
    rol a                                                             ; 45ac: 2a          *   :17ac[1]
    rol z_e                                                           ; 45ad: 26 24       &$  :17ad[1]
    rol a                                                             ; 45af: 2a          *   :17af[1]
    rol z_e                                                           ; 45b0: 26 24       &$  :17b0[1]
    rol a                                                             ; 45b2: 2a          *   :17b2[1]
    rol z_e                                                           ; 45b3: 26 24       &$  :17b3[1]
    rol a                                                             ; 45b5: 2a          *   :17b5[1]
    sta z_d                                                           ; 45b6: 85 25       .%  :17b6[1]
    lda #<font_space                                                  ; 45b8: a9 34       .4  :17b8[1]
    sta z_l                                                           ; 45ba: 85 20       .   :17ba[1]
    lda #>font_space                                                  ; 45bc: a9 12       ..  :17bc[1]
    sta z_h                                                           ; 45be: 85 21       .!  :17be[1]
    lda z_b                                                           ; 45c0: a5 23       .#  :17c0[1]
    clc                                                               ; 45c2: 18          .   :17c2[1]
    tax                                                               ; 45c3: aa          .   :17c3[1]
    lda z_c                                                           ; 45c4: a5 22       ."  :17c4[1]
    clc                                                               ; 45c6: 18          .   :17c6[1]
    rol a                                                             ; 45c7: 2a          *   :17c7[1]
    rol a                                                             ; 45c8: 2a          *   :17c8[1]
    rol a                                                             ; 45c9: 2a          *   :17c9[1]
    tay                                                               ; 45ca: a8          .   :17ca[1]
    jsr add_hl_de                                                     ; 45cb: 20 e5 0e     .. :17cb[1]   ; calculate source position of tile data
    jsr get_screen_pos                                                ; 45ce: 20 db 17     .. :17ce[1]

    ; copy 16 bytes to screen meory for the tile
    ldy #&0f                                                          ; 45d1: a0 0f       ..  :17d1[1]   ; bytes in tile
.copy_to_screen_loop
    lda (z_l),y                                                       ; 45d3: b1 20       .   :17d3[1]   ; copy bytes to screen
    sta (z_e),y                                                       ; 45d5: 91 24       .$  :17d5[1]
    dey                                                               ; 45d7: 88          .   :17d7[1]
    bpl copy_to_screen_loop                                           ; 45d8: 10 f9       ..  :17d8[1]
    rts                                                               ; 45da: 60          `   :17da[1]

.get_screen_pos
    ; remember BC
    lda z_c                                                           ; 45db: a5 22       ."  :17db[1]
    pha                                                               ; 45dd: 48          H   :17dd[1]
    lda z_b                                                           ; 45de: a5 23       .#  :17de[1]
    pha                                                               ; 45e0: 48          H   :17e0[1]
    lda #0                                                            ; 45e1: a9 00       ..  :17e1[1]
    sta z_d                                                           ; 45e3: 85 25       .%  :17e3[1]
    txa                                                               ; 45e5: 8a          .   :17e5[1]
    clc                                                               ; 45e6: 18          .   :17e6[1]
    rol a                                                             ; 45e7: 2a          *   :17e7[1]
    rol z_d                                                           ; 45e8: 26 25       &%  :17e8[1]
    rol a                                                             ; 45ea: 2a          *   :17ea[1]
    rol z_d                                                           ; 45eb: 26 25       &%  :17eb[1]
    rol a                                                             ; 45ed: 2a          *   :17ed[1]
    rol z_d                                                           ; 45ee: 26 25       &%  :17ee[1]
    rol a                                                             ; 45f0: 2a          *   :17f0[1]
    rol z_d                                                           ; 45f1: 26 25       &%  :17f1[1]
    sta z_e                                                           ; 45f3: 85 24       .$  :17f3[1]
    tya                                                               ; 45f5: 98          .   :17f5[1]
    and #&f8                                                          ; 45f6: 29 f8       ).  :17f6[1]
    lsr a                                                             ; 45f8: 4a          J   :17f8[1]
    lsr a                                                             ; 45f9: 4a          J   :17f9[1]
    clc                                                               ; 45fa: 18          .   :17fa[1]
    sta z_b                                                           ; 45fb: 85 23       .#  :17fb[1]
    adc z_d                                                           ; 45fd: 65 25       e%  :17fd[1]
    sta z_d                                                           ; 45ff: 85 25       .%  :17ff[1]
    lda #0                                                            ; 4601: a9 00       ..  :1801[1]
    ror z_b                                                           ; 4603: 66 23       f#  :1803[1]
    ror a                                                             ; 4605: 6a          j   :1805[1]
    ror z_b                                                           ; 4606: 66 23       f#  :1806[1]
    ror a                                                             ; 4608: 6a          j   :1808[1]
    adc z_e                                                           ; 4609: 65 24       e$  :1809[1]
    sta z_e                                                           ; 460b: 85 24       .$  :180b[1]
    lda z_b                                                           ; 460d: a5 23       .#  :180d[1]
    adc z_d                                                           ; 460f: 65 25       e%  :180f[1]
    sta z_d                                                           ; 4611: 85 25       .%  :1811[1]
    lda #&41                                                          ; 4613: a9 41       .A  :1813[1]
    sta z_b                                                           ; 4615: 85 23       .#  :1815[1]
    lda #&c0                                                          ; 4617: a9 c0       ..  :1817[1]
    sta z_c                                                           ; 4619: 85 22       ."  :1819[1]
    jsr add_de_bc                                                     ; 461b: 20 1d 0f     .. :181b[1]
    ; recall BC
    pla                                                               ; 461e: 68          h   :181e[1]
    sta z_b                                                           ; 461f: 85 23       .#  :181f[1]
    pla                                                               ; 4621: 68          h   :1821[1]
    sta z_c                                                           ; 4622: 85 22       ."  :1822[1]
    rts                                                               ; 4624: 60          `   :1824[1]

    ; unused?
    jsr inc_de                                                        ; 4625: 20 b6 0e     .. :1825[1]
    rts                                                               ; 4628: 60          `   :1828[1]

.initialize_screen
    lda #&d8                                                          ; 4629: a9 d8       ..  :1829[1]
    sta video_ula_control                                             ; 462b: 8d 20 fe    . . :182b[1]
    ldx #crtc_horz_total                                              ; 462e: a2 00       ..  :182e[1]
.set_crtc_loop
    txa                                                               ; 4630: 8a          .   :1830[1]
    sta crtc_address_register                                         ; 4631: 8d 00 fe    ... :1831[1]
    lda crtc_register_values,x                                        ; 4634: bd 21 19    .!. :1834[1]
    sta crtc_register_data                                            ; 4637: 8d 01 fe    ... :1837[1]
    inx                                                               ; 463a: e8          .   :183a[1]
    txa                                                               ; 463b: 8a          .   :183b[1]
    cmp #&0f                                                          ; 463c: c9 0f       ..  :183c[1]
    bne set_crtc_loop                                                 ; 463e: d0 f0       ..  :183e[1]
.set_palette
    ldx #0                                                            ; 4640: a2 00       ..  :1840[1]
.set_palette_loop
    lda palette_values,x                                              ; 4642: bd 2f 19    ./. :1842[1]
    sta video_ula_palette                                             ; 4645: 8d 21 fe    .!. :1845[1]
    inx                                                               ; 4648: e8          .   :1848[1]
    txa                                                               ; 4649: 8a          .   :1849[1]
    cmp #&10                                                          ; 464a: c9 10       ..  :184a[1]
    bne set_palette_loop                                              ; 464c: d0 f4       ..  :184c[1]
    rts                                                               ; 464e: 60          `   :184e[1]

.cls
    ; HL=$4180
    lda #&80                                                          ; 464f: a9 80       ..  :184f[1]
    sta z_l                                                           ; 4651: 85 20       .   :1851[1]
    lda #&41                                                          ; 4653: a9 41       .A  :1853[1]
    sta z_h                                                           ; 4655: 85 21       .!  :1855[1]
    ; BC=80*200
    lda #&80                                                          ; 4657: a9 80       ..  :1857[1]
    sta z_c                                                           ; 4659: 85 22       ."  :1859[1]
    lda #&3e                                                          ; 465b: a9 3e       .>  :185b[1]
    sta z_b                                                           ; 465d: 85 23       .#  :185d[1]
    lda #0                                                            ; 465f: a9 00       ..  :185f[1]
    jsr set_memory                                                    ; 4661: 20 7e 0e     ~. :1861[1]
    ldx #0                                                            ; 4664: a2 00       ..  :1864[1]
    ldy #0                                                            ; 4666: a0 00       ..  :1866[1]
.set_cursor_xy
    txa                                                               ; 4668: 8a          .   :1868[1]
    sta cursorX                                                       ; 4669: 85 40       .@  :1869[1]
    tya                                                               ; 466b: 98          .   :186b[1]
    sta cursorY                                                       ; 466c: 85 41       .A  :186c[1]
    rts                                                               ; 466e: 60          `   :186e[1]

.print_char
    clc                                                               ; 466f: 18          .   :186f[1]
    sbc #&1f                                                          ; 4670: e9 1f       ..  :1870[1]
    sta z_c                                                           ; 4672: 85 22       ."  :1872[1]
    pha                                                               ; 4674: 48          H   :1874[1]   ; push A,X,Y onto the stack
    txa                                                               ; 4675: 8a          .   :1875[1]
    pha                                                               ; 4676: 48          H   :1876[1]
    tya                                                               ; 4677: 98          .   :1877[1]
    pha                                                               ; 4678: 48          H   :1878[1]
    lda z_h                                                           ; 4679: a5 21       .!  :1879[1]
    pha                                                               ; 467b: 48          H   :187b[1]
    lda z_l                                                           ; 467c: a5 20       .   :187c[1]
    pha                                                               ; 467e: 48          H   :187e[1]
    lda #0                                                            ; 467f: a9 00       ..  :187f[1]
    clc                                                               ; 4681: 18          .   :1881[1]
    rol z_c                                                           ; 4682: 26 22       &"  :1882[1]
    rol a                                                             ; 4684: 2a          *   :1884[1]
    rol z_c                                                           ; 4685: 26 22       &"  :1885[1]
    rol a                                                             ; 4687: 2a          *   :1887[1]
    rol z_c                                                           ; 4688: 26 22       &"  :1888[1]
    rol a                                                             ; 468a: 2a          *   :188a[1]
    sta z_b                                                           ; 468b: 85 23       .#  :188b[1]
    lda #<bitmap_font                                                 ; 468d: a9 34       .4  :188d[1]
    sta z_l                                                           ; 468f: 85 20       .   :188f[1]
    lda #>bitmap_font                                                 ; 4691: a9 0f       ..  :1891[1]
    sta z_h                                                           ; 4693: 85 21       .!  :1893[1]
    jsr add_hl_bc                                                     ; 4695: 20 f3 0e     .. :1895[1]
    lda #0                                                            ; 4698: a9 00       ..  :1898[1]
    sta z_d                                                           ; 469a: 85 25       .%  :189a[1]
    lda cursorX                                                       ; 469c: a5 40       .@  :189c[1]
    clc                                                               ; 469e: 18          .   :189e[1]
    adc #4                                                            ; 469f: 69 04       i.  :189f[1]
    clc                                                               ; 46a1: 18          .   :18a1[1]
    ; de = cursorX * 16
    rol a                                                             ; 46a2: 2a          *   :18a2[1]
    rol z_d                                                           ; 46a3: 26 25       &%  :18a3[1]
    rol a                                                             ; 46a5: 2a          *   :18a5[1]
    rol z_d                                                           ; 46a6: 26 25       &%  :18a6[1]
    rol a                                                             ; 46a8: 2a          *   :18a8[1]
    rol z_d                                                           ; 46a9: 26 25       &%  :18a9[1]
    rol a                                                             ; 46ab: 2a          *   :18ab[1]
    rol z_d                                                           ; 46ac: 26 25       &%  :18ac[1]
    sta z_e                                                           ; 46ae: 85 24       .$  :18ae[1]
    ; de = de + (cursorY/2) + (cursorY/2)*4 i.e. de += 5 * cursorY/2
    clc                                                               ; 46b0: 18          .   :18b0[1]
    lda cursorY                                                       ; 46b1: a5 41       .A  :18b1[1]
    sta z_b                                                           ; 46b3: 85 23       .#  :18b3[1]
    lda #0                                                            ; 46b5: a9 00       ..  :18b5[1]
    ror z_b                                                           ; 46b7: 66 23       f#  :18b7[1]
    ror a                                                             ; 46b9: 6a          j   :18b9[1]
    tax                                                               ; 46ba: aa          .   :18ba[1]
    adc z_e                                                           ; 46bb: 65 24       e$  :18bb[1]
    sta z_e                                                           ; 46bd: 85 24       .$  :18bd[1]
    lda z_b                                                           ; 46bf: a5 23       .#  :18bf[1]
    adc z_d                                                           ; 46c1: 65 25       e%  :18c1[1]
    sta z_d                                                           ; 46c3: 85 25       .%  :18c3[1]
    txa                                                               ; 46c5: 8a          .   :18c5[1]
    rol a                                                             ; 46c6: 2a          *   :18c6[1]
    rol z_b                                                           ; 46c7: 26 23       &#  :18c7[1]
    rol a                                                             ; 46c9: 2a          *   :18c9[1]
    rol z_b                                                           ; 46ca: 26 23       &#  :18ca[1]
    adc z_e                                                           ; 46cc: 65 24       e$  :18cc[1]
    sta z_e                                                           ; 46ce: 85 24       .$  :18ce[1]
    lda z_b                                                           ; 46d0: a5 23       .#  :18d0[1]
    adc z_d                                                           ; 46d2: 65 25       e%  :18d2[1]
    sta z_d                                                           ; 46d4: 85 25       .%  :18d4[1]
    lda #&41                                                          ; 46d6: a9 41       .A  :18d6[1]
    sta z_b                                                           ; 46d8: 85 23       .#  :18d8[1]
    lda #&80                                                          ; 46da: a9 80       ..  :18da[1]
    sta z_c                                                           ; 46dc: 85 22       ."  :18dc[1]
    jsr add_de_bc                                                     ; 46de: 20 1d 0f     .. :18de[1]
    ldy #8                                                            ; 46e1: a0 08       ..  :18e1[1]
.do_font_again
    tya                                                               ; 46e3: 98          .   :18e3[1]
    pha                                                               ; 46e4: 48          H   :18e4[1]
    dey                                                               ; 46e5: 88          .   :18e5[1]
    lda (z_l),y                                                       ; 46e6: b1 20       .   :18e6[1]
    tax                                                               ; 46e8: aa          .   :18e8[1]
    and #&f0                                                          ; 46e9: 29 f0       ).  :18e9[1]
    sta z_as                                                          ; 46eb: 85 26       .&  :18eb[1]
    jsr swap_nybbles                                                  ; 46ed: 20 2b 0f     +. :18ed[1]
    ora z_as                                                          ; 46f0: 05 26       .&  :18f0[1]
    sta (z_e),y                                                       ; 46f2: 91 24       .$  :18f2[1]
    tya                                                               ; 46f4: 98          .   :18f4[1]   ; add 8 to Y
    clc                                                               ; 46f5: 18          .   :18f5[1]
    adc #8                                                            ; 46f6: 69 08       i.  :18f6[1]
    tay                                                               ; 46f8: a8          .   :18f8[1]
    txa                                                               ; 46f9: 8a          .   :18f9[1]
    and #&0f                                                          ; 46fa: 29 0f       ).  :18fa[1]
    sta z_as                                                          ; 46fc: 85 26       .&  :18fc[1]
    jsr swap_nybbles                                                  ; 46fe: 20 2b 0f     +. :18fe[1]
    ora z_as                                                          ; 4701: 05 26       .&  :1901[1]
    sta (z_e),y                                                       ; 4703: 91 24       .$  :1903[1]
    pla                                                               ; 4705: 68          h   :1905[1]
    tay                                                               ; 4706: a8          .   :1906[1]
    dey                                                               ; 4707: 88          .   :1907[1]
    bne do_font_again                                                 ; 4708: d0 d9       ..  :1908[1]
    inc cursorX                                                       ; 470a: e6 40       .@  :190a[1]
    lda cursorX                                                       ; 470c: a5 40       .@  :190c[1]
    cmp #40                                                           ; 470e: c9 28       .(  :190e[1]
    bne not_next_line                                                 ; 4710: d0 03       ..  :1910[1]
    jsr newline                                                       ; 4712: 20 3f 19     ?. :1912[1]
.not_next_line
    pla                                                               ; 4715: 68          h   :1915[1]
    sta z_l                                                           ; 4716: 85 20       .   :1916[1]
    pla                                                               ; 4718: 68          h   :1918[1]
    sta z_h                                                           ; 4719: 85 21       .!  :1919[1]
    pla                                                               ; 471b: 68          h   :191b[1]   ; pull A,X,Y from the stack
    tay                                                               ; 471c: a8          .   :191c[1]
    pla                                                               ; 471d: 68          h   :191d[1]
    tax                                                               ; 471e: aa          .   :191e[1]
    pla                                                               ; 471f: 68          h   :191f[1]
    rts                                                               ; 4720: 60          `   :1920[1]

.crtc_register_values
    equb &7f, &50, &62, &28, &26, 0, &19, &22, 1, 7, &30, 0, 8, &30   ; 4721: 7f 50 62... .Pb :1921[1]
.palette_values
.palette0
    equb 3, &13                                                       ; 472f: 03 13       ..  :192f[1]
.palette1
    equb &22, &32, &43, &53, &62, &72                                 ; 4731: 22 32 43... "2C :1931[1]
.palette2
    equb &84, &94                                                     ; 4737: 84 94       ..  :1937[1]
.palette3
    equb &a0, &b0, &c4, &d4, &e0, &f0                                 ; 4739: a0 b0 c4... ... :1939[1]

.newline
    lda #0                                                            ; 473f: a9 00       ..  :193f[1]
    sta cursorX                                                       ; 4741: 85 40       .@  :1941[1]
    inc cursorY                                                       ; 4743: e6 41       .A  :1943[1]
    rts                                                               ; 4745: 60          `   :1945[1]

.do_one_palette
    lda (z_c),y                                                       ; 4746: b1 22       ."  :1946[1]
    and #&f0                                                          ; 4748: 29 f0       ).  :1948[1]
    ora z_as                                                          ; 474a: 05 26       .&  :194a[1]
    sta (z_c),y                                                       ; 474c: 91 22       ."  :194c[1]
    iny                                                               ; 474e: c8          .   :194e[1]
.return_6
    rts                                                               ; 474f: 60          `   :194f[1]

.do_set_palette
    cmp #4                                                            ; 4750: c9 04       ..  :1950[1]
    bcs return_6                                                      ; 4752: b0 fb       ..  :1952[1]
    sta z_as                                                          ; 4754: 85 26       .&  :1954[1]
    pha                                                               ; 4756: 48          H   :1956[1]   ; push A,X,Y onto the stack
    txa                                                               ; 4757: 8a          .   :1957[1]
    pha                                                               ; 4758: 48          H   :1958[1]
    tya                                                               ; 4759: 98          .   :1959[1]
    pha                                                               ; 475a: 48          H   :195a[1]
    lda z_as                                                          ; 475b: a5 26       .&  :195b[1]
    clc                                                               ; 475d: 18          .   :195d[1]
    rol a                                                             ; 475e: 2a          *   :195e[1]
    tay                                                               ; 475f: a8          .   :195f[1]
    lda z_l                                                           ; 4760: a5 20       .   :1960[1]
    and #&f0                                                          ; 4762: 29 f0       ).  :1962[1]
    jsr pal_colour_conversion                                         ; 4764: 20 e6 19     .. :1964[1]
    sta z_b                                                           ; 4767: 85 23       .#  :1967[1]   ; R
    lda z_l                                                           ; 4769: a5 20       .   :1969[1]
    and #&0f                                                          ; 476b: 29 0f       ).  :196b[1]   ; B
    jsr pal_colour_conversionR                                        ; 476d: 20 e1 19     .. :196d[1]
    sta z_l                                                           ; 4770: 85 20       .   :1970[1]
    lda z_h                                                           ; 4772: a5 21       .!  :1972[1]   ; G
    and #&0f                                                          ; 4774: 29 0f       ).  :1974[1]
    jsr pal_colour_conversionR                                        ; 4776: 20 e1 19     .. :1976[1]
    sta z_h                                                           ; 4779: 85 21       .!  :1979[1]
    lda #0                                                            ; 477b: a9 00       ..  :197b[1]
    clc                                                               ; 477d: 18          .   :197d[1]
    adc z_h                                                           ; 477e: 65 21       e!  :197e[1]   ; Add green * 9
    adc z_h                                                           ; 4780: 65 21       e!  :1980[1]
    adc z_h                                                           ; 4782: 65 21       e!  :1982[1]
    adc z_h                                                           ; 4784: 65 21       e!  :1984[1]
    adc z_h                                                           ; 4786: 65 21       e!  :1986[1]
    adc z_h                                                           ; 4788: 65 21       e!  :1988[1]
    adc z_h                                                           ; 478a: 65 21       e!  :198a[1]
    adc z_h                                                           ; 478c: 65 21       e!  :198c[1]
    adc z_h                                                           ; 478e: 65 21       e!  :198e[1]
    adc z_b                                                           ; 4790: 65 23       e#  :1990[1]   ; Add red * 3
    adc z_b                                                           ; 4792: 65 23       e#  :1992[1]
    adc z_b                                                           ; 4794: 65 23       e#  :1994[1]
    adc z_l                                                           ; 4796: 65 20       e   :1996[1]   ; Add blue
    sta z_c                                                           ; 4798: 85 22       ."  :1998[1]
    lda #0                                                            ; 479a: a9 00       ..  :199a[1]
    sta z_b                                                           ; 479c: 85 23       .#  :199c[1]
    lda #<colours                                                     ; 479e: a9 f7       ..  :199e[1]
    sta z_l                                                           ; 47a0: 85 20       .   :19a0[1]
    lda #>colours                                                     ; 47a2: a9 19       ..  :19a2[1]
    sta z_h                                                           ; 47a4: 85 21       .!  :19a4[1]
    jsr add_hl_bc                                                     ; 47a6: 20 f3 0e     .. :19a6[1]
    ldx #0                                                            ; 47a9: a2 00       ..  :19a9[1]
    lda (z_l,x)                                                       ; 47ab: a1 20       .   :19ab[1]
    sta z_as                                                          ; 47ad: 85 26       .&  :19ad[1]
    lda #<palette_address_table                                       ; 47af: a9 d9       ..  :19af[1]
    sta z_l                                                           ; 47b1: 85 20       .   :19b1[1]
    lda #>palette_address_table                                       ; 47b3: a9 19       ..  :19b3[1]
    sta z_h                                                           ; 47b5: 85 21       .!  :19b5[1]
    lda (z_l),y                                                       ; 47b7: b1 20       .   :19b7[1]
    sta z_c                                                           ; 47b9: 85 22       ."  :19b9[1]
    iny                                                               ; 47bb: c8          .   :19bb[1]
    lda (z_l),y                                                       ; 47bc: b1 20       .   :19bc[1]
    sta z_b                                                           ; 47be: 85 23       .#  :19be[1]
    ldy #0                                                            ; 47c0: a0 00       ..  :19c0[1]
    jsr do_one_palette                                                ; 47c2: 20 46 19     F. :19c2[1]
    jsr do_one_palette                                                ; 47c5: 20 46 19     F. :19c5[1]
    iny                                                               ; 47c8: c8          .   :19c8[1]
    iny                                                               ; 47c9: c8          .   :19c9[1]
    jsr do_one_palette                                                ; 47ca: 20 46 19     F. :19ca[1]
    jsr do_one_palette                                                ; 47cd: 20 46 19     F. :19cd[1]
    jsr set_palette                                                   ; 47d0: 20 40 18     @. :19d0[1]
    pla                                                               ; 47d3: 68          h   :19d3[1]   ; pull A,X,Y from the stack
    tay                                                               ; 47d4: a8          .   :19d4[1]
    pla                                                               ; 47d5: 68          h   :19d5[1]
    tax                                                               ; 47d6: aa          .   :19d6[1]
    pla                                                               ; 47d7: 68          h   :19d7[1]
    rts                                                               ; 47d8: 60          `   :19d8[1]

.palette_address_table
    equw palette0, palette1, palette2, palette3                       ; 47d9: 2f 19 31... /.1 :19d9[1]

.pal_colour_conversionR
    clc                                                               ; 47e1: 18          .   :19e1[1]
    rol a                                                             ; 47e2: 2a          *   :19e2[1]
    rol a                                                             ; 47e3: 2a          *   :19e3[1]
    rol a                                                             ; 47e4: 2a          *   :19e4[1]
    rol a                                                             ; 47e5: 2a          *   :19e5[1]
.pal_colour_conversion
    cmp #&50                                                          ; 47e6: c9 50       .P  :19e6[1]
    bcc return_with_zero                                              ; 47e8: 90 07       ..  :19e8[1]
    cmp #&a0                                                          ; 47ea: c9 a0       ..  :19ea[1]
    bcc return_with_one                                               ; 47ec: 90 06       ..  :19ec[1]
    lda #2                                                            ; 47ee: a9 02       ..  :19ee[1]
    rts                                                               ; 47f0: 60          `   :19f0[1]

.return_with_zero
    lda #0                                                            ; 47f1: a9 00       ..  :19f1[1]
    rts                                                               ; 47f3: 60          `   :19f3[1]

.return_with_one
    lda #1                                                            ; 47f4: a9 01       ..  :19f4[1]
    rts                                                               ; 47f6: 60          `   :19f6[1]

.colours
    equb 7, 3, 3, 1, 2, 2, 1, 2, 2, 5, 5, 1, 4, 0, 1, 2, 2, 2, 5, 5   ; 47f7: 07 03 03... ... :19f7[1]
    equb 1, 5, 5, 1, 4, 4, 0                                          ; 480b: 01 05 05... ... :1a0b[1]

.chibi_sound
    pha                                                               ; 4812: 48          H   :1a12[1]
    ; bug, should be lda #255
    lda BUG_should_be_immediate_FF                                    ; 4813: a5 ff       ..  :1a13[1]
    sta system_via_ddra                                               ; 4815: 8d 43 fe    .C. :1a15[1]
    pla                                                               ; 4818: 68          h   :1a18[1]
    beq silent                                                        ; 4819: f0 42       .B  :1a19[1]
    tax                                                               ; 481b: aa          .   :1a1b[1]
    lda #&cf                                                          ; 481c: a9 cf       ..  :1a1c[1]
    sta system_via_ora_ira                                            ; 481e: 8d 41 fe    .A. :1a1e[1]
    txa                                                               ; 4821: 8a          .   :1a21[1]
    and #&3f                                                          ; 4822: 29 3f       )?  :1a22[1]
    sta system_via_ora_ira                                            ; 4824: 8d 41 fe    .A. :1a24[1]
    txa                                                               ; 4827: 8a          .   :1a27[1]
    and #&40                                                          ; 4828: 29 40       )@  :1a28[1]
    asl a                                                             ; 482a: 0a          .   :1a2a[1]
    adc #&80                                                          ; 482b: 69 80       i.  :1a2b[1]
    rol a                                                             ; 482d: 2a          *   :1a2d[1]
    asl a                                                             ; 482e: 0a          .   :1a2e[1]
    adc #&80                                                          ; 482f: 69 80       i.  :1a2f[1]
    rol a                                                             ; 4831: 2a          *   :1a31[1]
    tay                                                               ; 4832: a8          .   :1a32[1]
    eor #&d4                                                          ; 4833: 49 d4       I.  :1a33[1]
    sta system_via_ora_ira                                            ; 4835: 8d 41 fe    .A. :1a35[1]
    lda #&ff                                                          ; 4838: a9 ff       ..  :1a38[1]
    sta system_via_ora_ira                                            ; 483a: 8d 41 fe    .A. :1a3a[1]
    txa                                                               ; 483d: 8a          .   :1a3d[1]
    and #&80                                                          ; 483e: 29 80       ).  :1a3e[1]
    beq sound_finish                                                  ; 4840: f0 10       ..  :1a40[1]
    lda #&df                                                          ; 4842: a9 df       ..  :1a42[1]
    sta system_via_ora_ira                                            ; 4844: 8d 41 fe    .A. :1a44[1]
    lda #&e7                                                          ; 4847: a9 e7       ..  :1a47[1]
    sta system_via_ora_ira                                            ; 4849: 8d 41 fe    .A. :1a49[1]
    tya                                                               ; 484c: 98          .   :1a4c[1]
    eor #&f4                                                          ; 484d: 49 f4       I.  :1a4d[1]
    sta system_via_ora_ira                                            ; 484f: 8d 41 fe    .A. :1a4f[1]
.sound_finish
    lda #8                                                            ; 4852: a9 08       ..  :1a52[1]
    sta system_via_orb_irb                                            ; 4854: 8d 40 fe    .@. :1a54[1]
    lda #0                                                            ; 4857: a9 00       ..  :1a57[1]
    sta system_via_orb_irb                                            ; 4859: 8d 40 fe    .@. :1a59[1]
    rts                                                               ; 485c: 60          `   :1a5c[1]

.silent
    lda #&ff                                                          ; 485d: a9 ff       ..  :1a5d[1]
    sta system_via_ora_ira                                            ; 485f: 8d 41 fe    .A. :1a5f[1]
    lda #&df                                                          ; 4862: a9 df       ..  :1a62[1]
    sta system_via_ora_ira                                            ; 4864: 8d 41 fe    .A. :1a64[1]
    rts                                                               ; 4867: 60          `   :1a67[1]

; final byte
    equb 0                                                            ; 4868: 00          .   :1a68[1]

    ; Copy the newly assembled block of code back to it's proper place in the binary
    ; file.
    ; (Note the parameter order: 'copyblock <start>,<end>,<dest>')
    copyblock start, *, &304b

    ; Clear the area of memory we just temporarily used to assemble the new block,
    ; allowing us to assemble there again if needed
    clear start, &1a69

    ; Set the program counter to the next position in the binary file.
    org &304b + (* - start)

.pydis_end

    assert &30 == '0'
    assert &0d == (screen_height_g/2)+1
    assert &10 == (screen_height_g/2)+4
    assert &09 == (screen_height_g/2)-3
    assert &0a == (screen_width_g/2)-7+1
    assert &08 == (screen_width_g/2)-8
    assert &20 == 16*2
    assert &00 == <&1000
    assert &df == <(65536-33)
    assert &ff == <(768-1)
    assert &80 == <(768/6)
    assert &40 == <(raw_bitmap_end - raw_bitmap)
    assert &e8 == <1000
    assert &18 == <24
    assert &20 == <32
    assert &04 == <4
    assert &40 == <64
    assert &56 == <attribution_message
    assert &59 == <bcd_1
    assert &65 == <bcd_20
    assert &5d == <bcd_3
    assert &61 == <bcd_5
    assert &34 == <bitmap_font
    assert &f7 == <colours
    assert &1c == <cos_you_suck_message
    assert &34 == <font_space
    assert &24 == <high_score
    assert &49 == <high_score_message
    assert &2d == <new_high_score_message
    assert &d9 == <palette_address_table
    assert &52 == <paused_message
    assert &00 == <raw_bitmap
    assert &34 == <raw_palettes
    assert &20 == <score
    assert &00 == <tile_map
    assert &00 == <tile_map2
    assert &69 == <title_screen_cells
    assert &30 == <url_message
    assert &0f == <youre_dead_message
    assert &10 == >&1000
    assert &ff == >(65536-33)
    assert &02 == >(768-1)
    assert &00 == >(768/6)
    assert &06 == >(raw_bitmap_end - raw_bitmap)
    assert &03 == >1000
    assert &00 == >24
    assert &00 == >32
    assert &00 == >4
    assert &00 == >64
    assert &14 == >attribution_message
    assert &15 == >bcd_1
    assert &15 == >bcd_20
    assert &15 == >bcd_3
    assert &15 == >bcd_5
    assert &0f == >bitmap_font
    assert &19 == >colours
    assert &09 == >cos_you_suck_message
    assert &12 == >font_space
    assert &36 == >high_score
    assert &15 == >high_score_message
    assert &09 == >new_high_score_message
    assert &19 == >palette_address_table
    assert &15 == >paused_message
    assert &30 == >raw_bitmap
    assert &14 == >raw_palettes
    assert &36 == >score
    assert &30 == >tile_map
    assert &33 == >tile_map2
    assert &15 == >title_screen_cells
    assert &15 == >url_message
    assert &09 == >youre_dead_message
    assert &192f == palette0
    assert &1931 == palette1
    assert &1937 == palette2
    assert &1939 == palette3
    assert &17 == screen_height_g - 1
    assert &16 == screen_height_g - 2
    assert &0c == screen_height_g / 2
    assert &17 == screen_height_g-1
    assert &15 == screen_height_g-3
    assert &13 == screen_height_g-5
    assert &0c == screen_height_g/2
    assert &1f == screen_width_g - 1
    assert &1e == screen_width_g - 2
    assert &10 == screen_width_g / 2
    assert &1f == screen_width_g-1
    assert &04 == screen_width_g/2-12
    assert &0d == screen_width_g/2-3
    assert &08 == screen_width_g/2-8
    assert &29 == t_RetAddrL

save pydis_start, pydis_end

; Stats:
;     Total size (Code + Data) = 6249 bytes
;     Code                     = 4143 bytes (66%)
;     Data                     = 2106 bytes (34%)
;
;     Number of instructions   = 2135
;     Number of data bytes     = 1771 bytes
;     Number of data words     = 40 bytes
;     Number of string bytes   = 295 bytes
;     Number of strings        = 7
