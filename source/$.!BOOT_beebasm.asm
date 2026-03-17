; Constants
crtc_horz_total = 0
keymap_any_fire = %11001111
keymap_pause    = %10000000
screen_height_g = 24
screen_width_g  = 32

; Memory locations
z_l                             = &0020
z_h                             = &0021
z_c                             = &0022
z_b                             = &0023
z_e                             = &0024
z_d                             = &0025
z_as                            = &0026
z_ixl                           = &0028
z_ixh                           = &0029
loop_counter                    = &002a
temp_controls                   = &002b
joystick_enabled                = &002c
joystick_button_pressed         = &002d
cursorX                         = &0040
cursorY                         = &0041
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
crtc_address_register           = &fe00
crtc_register_data              = &fe01
video_ula_control               = &fe20
video_ula_palette               = &fe21
system_via_register_b           = $fe40
system_via_register_a           = &fe41
system_via_ddrb                 = &fe42
system_via_ddra                 = &fe43
system_via_register_a_no_handshake = &fe4f
adc_start_conversion_or_status  = &fec0
adc_read_data_high_byte         = &fec1

    org &3000

.pydis_start

.raw_bitmap
.tile_map

; ****************************************
.entry_point
    sei

    ; silence the initial beep
    lda #$ff
    sta system_via_ddra    
    lda #&9f                                ; set byte of data to send: 'tone 3 volume to silent'
    sta system_via_register_a               ; 
    lda #0                                  ;
    sta system_via_register_b               ; let the sound chip know there is data
    jsr return_0                            ; delay at least 8us (16 cycles)
    lda #8                                  ; for the hardware to deal with the data
    sta system_via_register_b               ; finish up (make inactive)
    
    ; relocation loop. Moves the code from $3000 to $200 for $1900 bytes
    lda #0
    sta z_c
    sta z_l
    sta z_e
    lda #&30
    sta z_h
    lda #&19
    sta z_b
    lda #2
    sta z_d
.loop
    ldy #0
    lda (z_l),y
    sta (z_e),y
    inc z_l
    bne skip_inc2
    inc z_h
.skip_inc2
    inc z_e
    bne skip_inc1
    inc z_d
.skip_inc1
    dec z_c
    bne loop
    lda z_b
    beq relocation_done
    dec z_b
    sec
    bcs loop                                                          ; ALWAYS branch
.return_0
    rts

.relocation_done
    jmp start

entry_length = * - entry_point

; ****************************************
; All the rest of the code runs from 0x200 upwards
; ****************************************
    org &0200 + entry_length

.start
    sei
    cld
    jsr initialize_screen

    ; Clear memory from $3000 for $640 bytes
    lda #>raw_bitmap
    sta z_h
    lda #<raw_bitmap
    sta z_l
    lda #<(raw_bitmap_end - raw_bitmap)
    sta z_c
    lda #>(raw_bitmap_end - raw_bitmap)
    sta z_b
    lda #0
    jsr set_memory

    lda #1                                                             ; control mode 0: fire+direction together sets your ships direction
    sta control_mode                                                   ; control mode 1: two 'fire' controls rotate your ship clockwise/anticlockwise
    lda #0
    sta joystick_enabled                                               ; disable joystick controls until fire pressed
    lda #>raw_palettes
    sta z_d
    lda #<raw_palettes
    sta z_e
    ldy #0
.set_palette_again
    lda (z_e),y
    sta z_l
    iny
    lda (z_e),y
    sta z_h
    iny
    tya
    clc
    ror a
    sec
    sbc #1
    jsr do_set_palette
    cpy #16*2                                                         ; 16 colours - 2 bytes per colour
    bne set_palette_again
    jsr cls
.title_screen
    jsr force_repaint                                                 ; reset tile_map2, so everything redraws
    jsr clear_screen
    ; copy from HL=title_screen_cells to DE=tile_map+$44 for 24 bytes, then add 8 bytes
    ; to DE and repeat 16 times
    lda #<tile_map                                                    ; we're going to draw the title
    sta z_e
    lda #>tile_map
    sta z_d
    lda #<title_screen_cells
    sta z_l
    lda #>title_screen_cells
    sta z_h
    lda #0
    sta z_b
    lda #&44
    sta z_c
    jsr add_de_bc
    ; logo has 16 lines
    ldx #16
.title_pic_next_line
    lda #<24                                                          ; bc = 24 = bytes per line
    sta z_c
    lda #>24
    sta z_b
    jsr copy_memory_loop
    lda #8                                                            ; move to start of next line
    sta z_c
    lda #0
    sta z_b
    jsr add_de_bc
    dex
    bne title_pic_next_line
.restart_scrolling_message

    ; start at BC = which character in the message to start printing at = negative of the screen width
    lda #0
    sec
    sbc #screen_width_g
    sta z_c
    lda #0
    sbc #0
    sta z_b
.scrolling_message_loop
    ; remember BC
    lda z_c
    pha
    lda z_b
    pha
    jsr force_animate                                                 ; update 2 sets of frames
    jsr repaint_screen

    ; show the high score message
    ldx #screen_width_g/2-8
    ldy #screen_height_g-5
    jsr set_cursor_xy
    lda #<high_score_message
    sta z_l
    lda #>high_score_message
    sta z_h
    jsr print_message_hl

    ; show high score
    lda #<high_score
    sta z_e
    lda #>high_score
    sta z_d
    ldx #4
    jsr print_X_bcd_bytes

    ; show the URL message
    ldx #screen_width_g/2-12
    ldy #screen_height_g-3
    jsr set_cursor_xy
    lda #<url_message
    sta z_l
    lda #>url_message
    sta z_h
    jsr print_message_hl

    ; recall BC
    pla
    sta z_b
    pla
    sta z_c

    ; BC = character position to start showing the message. 
    ; e.g. 0 means we show the first character

    ldx #0
    stx loop_counter
.next_char
    ldy #screen_height_g-1
    jsr set_cursor_xy
    lda z_c
    pha
    lda z_b
    pha
    ldy loop_counter
    jsr get_character
    cmp #&ff
    bne text_no_reset
    jmp restart_scrolling_message

.text_no_reset
    jsr print_char
    pla
    sta z_b
    pla
    sta z_c
    inc loop_counter
    ldx loop_counter
    cpx #screen_width_g
    bne next_char
    jsr inc_bc

    ; delay for 1000
    lda z_b
    pha
    lda z_c
    pha
    lda #<1000
    sta z_c
    lda #>1000
    sta z_b
    jsr pause
    pla
    sta z_c
    pla
    sta z_b

    inc random_seed
    jsr read_both_controls

    lda z_h
    ora #keymap_any_fire
    cmp #&ff
    bne new_game                                                      ; wait until fire is pressed
    jmp scrolling_message_loop                                        ; update the scrolling text

; ****************************************
; Get character from attribution_message at offset BC+y
; If the offset is before the start of the message, we return a space character
; ****************************************
.get_character  
    tya                                                             ; hl = bc + y
    clc
    adc z_c
    sta z_l
    lda z_b
    adc #0
    sta z_h
    bmi return_space                                                ; if hl < 0 then space

.not_at_end
    ; hl += ATTRIBUTION_MESSAGE
    lda #<attribution_message
    clc
    adc z_l
    sta z_l
    lda #>attribution_message
    adc z_h
    sta z_h

    ; return char at hl
    ldy #0
    lda (z_l),y
    rts

.return_space
    lda #' '
    rts

; ****************************************
.new_game
    jsr cls
    
    ; set the number of lives to 3
    lda #3
    sta lives
    
    lda #<score
    sta z_l
    lda #>score
    sta z_h
    ldy #4
    lda #0
.reset_score
    sta (z_l),y
    dey
    bne reset_score
.new_game_round
    jsr force_repaint                                                 ; reset tile_map2, so everything redraws
    jsr clear_screen                                                  ; zero tile array
    jsr repaint_screen                                                ; repaint screen
    lda #screen_width_g / 2                                           ; centre the player
    sta playerX1
    sta bulletX1
    lda #screen_height_g / 2
    sta playerY1
    sta bulletY1
    lda #4                                                            ; aim player left
    sta player_dir
    sta bullet_dir
    lda #2                                                            ; start the game with fast growth
    sta allowed_fast_growth
    jsr create_invader                                                ; create two invaders at the start of the game
    jsr create_invader
    lda #0
    sta game_tick                                                     ; reset_game_ticks
.game_loop
    jsr get_random                                                    ; pull a random number
    and #%11111110                                                    ; invader/descender happens 1 in 128
    cmp #192
    bne game_loop_b
    jsr create_invader
.game_loop_b
    cmp #128
    bne game_loop_c
    jsr create_descender
.game_loop_c
    lda fast_growth
    beq no_fast_growth                                                ; if fast_growth counter is >0 then we grow every frame
    dec fast_growth
    jmp do_game_evolve

.no_fast_growth
    lda game_tick
    inc game_tick
    and #%00111111                                                    ; frequency of evolution
    bne do_game_move
.do_game_evolve
    jsr mould_evolve                                                  ; evolve the mould
    jmp process_player

.do_game_move
    and #%00000001
    bne do_game_pause
    jsr mould_move                                                    ; move the mould
    jmp process_player

.do_game_pause
    jsr force_animate

    ; delay for 2000 otherwise the game is a little too fast imho
    lda z_b
    pha
    lda z_c
    pha
    lda #<2000
    sta z_c
    lda #>2000
    sta z_b
    jsr pause
    pla
    sta z_c
    pla
    sta z_b


.process_player
    jsr repaint_screen
    ldx #0                                                            ; print score on top left
    ldy #0
    jsr set_cursor_xy
    lda #<score
    sta z_e
    lda #>score
    sta z_d
    ldx #4
    jsr print_X_bcd_bytes
    ldx #screen_width_g - 2                                           ; print lives on top right
    ldy #0
    jsr set_cursor_xy
    lda #'L'
    jsr print_char
    lda lives
    clc
    adc #'0'
    jsr print_char
    lda nothing_shot                                                  ; is the player busy?
    clc
    adc #1
    and #%00011111
    cmp #31
    bcc player_active
    jsr create_invader                                                ; player is slacking, so lets spawn some stuff
    jsr create_invader
    jsr create_descender
    lda #2
    sta allowed_fast_growth                                           ; fast grow the mould for a few frames
    lda #0
.player_active
    sta nothing_shot
    lda playerX1                                                      ; read in the current player location to BC
    sta z_b
    lda playerY1
    sta z_c
    jsr find_tile                                                     ; get the tile location of the player, we need this to check if the player is alive. If the player is surrounded on UDLR then the player is dead
    ldy #0
    lda z_b
    cmp #0
    beq player_far_left                                               ; player is at far left, we can't check that direction
    dec z_l
    lda (z_l),y
    cmp #8
    bcc player_still_alive                                            ; player is not surrounded on left
    inc z_l
.player_far_left
    inc z_l
    lda z_b
    cmp #screen_width_g - 1
    beq player_far_right                                              ; player is far right, we can't check that direction
    lda (z_l),y
    cmp #8
    bcc player_still_alive                                            ; player is not surrounded on the right
.player_far_right
    lda #<(65536-33)
    sta z_e
    lda #>(65536-33)
    sta z_d
    jsr add_hl_de
    lda z_c
    cmp #0
    beq player_far_top                                                ; player is at top of screem we can't check that direction
    lda (z_l),y
    cmp #8
    bcc player_still_alive                                            ; player is not surrounded at the top
.player_far_top
    lda #<64
    sta z_e
    lda #>64
    sta z_d
    jsr add_hl_de
    lda z_c
    cmp #screen_height_g - 1
    beq player_far_bottom                                             ; player is at bottom of screen, we can't check that direction
    lda (z_l),y
    cmp #8
    bcc player_still_alive                                            ; player is not surrounded from bottom
.player_far_bottom
    jmp player_dead                                                   ; player is dead!

.player_still_alive
    jsr read_both_controls                                            ; read both the keyboard and joystick controls
    lda player_dir
    sta z_l                                                           ; load the player direction into L (UDLR=1234)
    lda #0
    sta playing_sfx                                                   ; reset the sound effects
    lda control_mode                                                  ; check the control mode (1fire 2fire)
    and #%00000001
    bne control_mode_2_fire
    ; fall through...

; ****************************************
; Single fire mode (1 firebutton)
; ****************************************
.f1_control_mode_1_fire
    lda z_h                                                           ; 1fire mode
    bit keymap_U
    bne F1_player_not_up_b
    bit keymap_F1                                                     ; up button is pressed
    beq fire_face_up
    lda z_c
    beq F1_player_not_up
    dec z_c                                                           ; move player up
    jmp F1_player_not_up

.fire_face_up
    lda #1                                                            ; set fire direction to up
    sta z_l
.F1_player_not_up
    lda z_h
.F1_player_not_up_b
    bit keymap_D
    bne F1_player_not_down_b
    bit keymap_F1                                                     ; down button pressed
    beq fire_face_down
    lda z_c
    cmp #screen_height_g-1
    beq F1_player_not_down
    inc z_c                                                           ; move player down
    jmp F1_player_not_down

.fire_face_down
    lda #3                                                            ; set fire direction to down
    sta z_l
.F1_player_not_down
    lda z_h
.F1_player_not_down_b
    bit keymap_L
    bne F1_player_not_left_b
    bit keymap_F1                                                     ; left button pressed
    beq fire_face_left
    lda z_b
    beq F1_player_not_left
    dec z_b                                                           ; move player left
    jmp F1_player_not_left

.fire_face_left
    lda #4
    sta z_l
.F1_player_not_left
    lda z_h
.F1_player_not_left_b
    bit keymap_R
    bne F1_player_not_right
    bit keymap_F1                                                     ; right button pressed
    beq fire_face_right
    lda z_b
    cmp #&1f
    beq F1_player_not_right
    inc z_b                                                           ; move player right
    jmp F1_player_not_right

.fire_face_right
    lda #2
    sta z_l
.F1_player_not_right
    jmp player_not_fire2                                              ; continue control processing

; ****************************************
; alt fire mode (2 firebutton)
; ****************************************
.control_mode_2_fire
    lda debounce_count
    beq debounce_check
    dec debounce_count
    jmp player_not_pause

.debounce_check
    lda z_h
    ora #keymap_any_fire
    cmp #&ff
    beq debounce_ok
    lda #2
    sta debounce_count                                                ; stop keys repeating too fast
.debounce_ok
    lda z_h
    bit keymap_U
    bne player_not_up_b
    lda z_c
    beq player_not_up
    dec z_c                                                           ; move player up
.player_not_up
    lda z_h
.player_not_up_b
    bit keymap_D
    bne player_not_down_b
    lda z_c
    cmp #screen_height_g - 1
    beq player_not_down
    inc z_c                                                           ; move player down
.player_not_down
    lda z_h
.player_not_down_b
    bit keymap_L
    bne player_not_left
    lda z_b
    beq player_not_left
    dec z_b                                                           ; move player left
.player_not_left
    lda z_h
    bit keymap_R
    bne player_not_right_b
    lda z_b
    cmp #screen_width_g - 1
    beq player_not_right
    inc z_b                                                           ; move player right
.player_not_right
    lda z_h
.player_not_right_b
    bit keymap_F1
    bne player_not_fire_b
    lda z_l                                                           ; rotate player left
    sec
    sbc #1
    bne player_dir_reset
    lda #4
.player_dir_reset
    sta z_l
.player_not_fire
    lda z_h
.player_not_fire_b
    bit keymap_F2
    bne player_not_fire2
    lda z_l                                                           ; rotate player right
    clc
    adc #1
    cmp #5
    bne player_dir_reset2
    lda #1
.player_dir_reset2
    sta z_l
    ; fall through...

; ***************************************
; This section is used by both control modes
; ***************************************
.player_not_fire2
    lda z_h
    bit keymap_F3
    bne player_not_fire3
    lda control_mode                                                  ; fire 3 swaps control modes
    eor #&ff
    sta control_mode
    jsr debounce                                                      ; wait for fire to be released
    lda z_h
.player_not_fire3
    and #keymap_pause
    bne player_not_pause
    lda z_c
    pha
    lda z_b
    pha
    lda z_l
    pha
    lda z_h
    pha

    ; show the paused message
    ldx #screen_width_g/2-3
    ldy #screen_height_g/2
    jsr set_cursor_xy
    lda #<paused_message
    sta z_l
    lda #>paused_message
    sta z_h
    jsr print_message_hl
    jsr wait_for_fire                                                 ; wait for player to press fire
    jsr force_repaint
    jsr repaint_screen
    pla
    sta z_h
    pla
    sta z_l
    pla
    sta z_b
    pla
    sta z_c
.player_not_pause
    lda player_dir                                                    ; check if we need to update the player sprite
    cmp z_l
    bne player_moved
    lda playerX1
    cmp z_b
    bne player_moved
    lda playerY1
    cmp z_c
    bne player_moved
    jmp player_unmoved                                                ; player position/direction unchanged

; ****************************************
.player_moved
    lda z_l
    sta player_dir
    jsr find_tile
    ldy #0
    lda (z_l),y                                                       ; check if direction player wants to move is empty
    bne player_unmoved
    lda z_c
    pha
    lda z_b
    pha
    lda playerX1                                                      ; update player location
    sta z_b
    lda playerY1
    sta z_c
    jsr find_tile
    lda #0                                                            ; clear player sprite from old location
    ldy #0
    sta (z_l),y
    jsr render_tile
    pla
    sta z_b
    pla
    sta z_c
    lda z_b
    sta playerX1
    lda z_c
    sta playerY1
.player_unmoved
    lda bulletX1                                                      ; get current bullet location
    sta z_b
    lda bulletY1
    sta z_c
    jsr find_tile
    lda #0                                                            ; clear current bullet sprite
    ldy #0
    sta (z_l),y
    jsr render_tile
    lda #4
    sta z_ixl
    ; fall through...

; ****************************************
.bullet_recalc
    lda bullet_dir                                                    ; bullet direction
    cmp #1
    beq bullet_up
    cmp #2
    beq bullet_right
    cmp #3
    beq bullet_down
    cmp #4
    beq bullet_left
.bullet_up
    dec z_c                                                           ; up
    jmp bullet_check

.bullet_down
    inc z_c                                                           ; down
    jmp bullet_check

.bullet_left
    dec z_b                                                           ; left
    jmp bullet_check

.bullet_right
    inc z_b                                                           ; right
.bullet_check
    lda z_b
    cmp #screen_width_g
    bcs bullet_restart                                                ; if bullet has gone off screen we need to make a new one
    lda z_c
    cmp #screen_height_g
    bcs bullet_restart
    jsr find_tile
    ldy #0
    lda (z_l),y
    bne bullet_strike
    dec z_ixl
    bne bullet_recalc                                                 ; move bullet again for next tick
    jmp bullet_draw

; ****************************************
.bullet_restart
    lda player_dir                                                    ; bullet has gone off screen, so create a new one at the player location
    sta bullet_dir
    lda playerX1
    sta z_b
    lda playerY1
    sta z_c
    jsr find_tile
.bullet_draw
    lda z_b                                                           ; store bullet location
    sta bulletX1
    lda z_c
    sta bulletY1
    lda #5                                                            ; draw the bullet sprite
    ldy #0
    sta (z_l),y
    jsr render_tile
    lda playerX1                                                      ; reload the player location
    sta z_b
    lda playerY1
    sta z_c
    jsr find_tile
    lda player_dir                                                    ; draw the player sprite
    ldy #0
    sta (z_l),y
    jsr render_tile
    lda playing_sfx                                                   ; play the current sound effect (0=no sound)
    jsr chibi_sound
    jmp game_loop

; ****************************************
.bullet_strike
    tax                                                               ; players bullet has hit something
    lda z_c
    pha
    lda z_b
    pha
    ldy #0
    tya                                                               ; A=&00
    sta (z_l),y
    jsr render_tile                                                   ; remove the enemy from the tilemap
    lda z_l
    pha
    lda z_h
    pha
    txa
    lda #<bcd_1                                                       ; seeker score
    sta z_l
    lda #>bcd_1
    sta z_h
    lda #%10000001                                                    ; seeker sound
    sta z_b
    txa
    cmp #10
    beq apply_score
    lda #<bcd_3                                                       ; blue mould score
    sta z_l
    lda #>bcd_3
    sta z_h
    lda #%10000111                                                    ; blue mould sound
    sta z_b
    txa
    cmp #9
    beq apply_score
    lda #<bcd_5                                                       ; green mould score
    sta z_l
    lda #>bcd_5
    sta z_h
    lda #%10000111                                                    ; green mould sound
    sta z_b
    txa
    cmp #8
    beq apply_score
    lda #<bcd_20                                                      ; invader/descender score
    sta z_l
    lda #>bcd_20
    sta z_h
    lda #%10001111                                                    ; invader/descender sound
    sta z_b
.apply_score
    ldy #0
    lda z_b
    sta playing_sfx                                                   ; make a sound
    lda #<score
    sta z_e
    lda #>score
    sta z_d
    ldx #4                                                            ; add the score
    jsr bcd_add
    pla
    sta z_h
    pla
    sta z_l
    lda #0
    sta nothing_shot
    sta allowed_fast_growth                                           ; player is busy, so stop fast growth
    jsr get_random
    pla
    sta z_b
    pla
    sta z_c
    jmp bullet_restart

; ****************************************
.create_descender_b
    lsr a
    jmp create_descender_c

; ****************************************
.create_descender
    jsr get_random                                                    ; get a random column
.create_descender_c
    and #%00011111
    cmp #screen_width_g
    bcs create_descender                                              ; get a number 0-screenwidth
    sta z_as
    lda #<tile_map
    sta z_l
    lda #>tile_map
    sta z_h
    lda z_l
    clc
    adc z_as
    sta z_l                                                           ; column number (top of screen)
    lda #12                                                           ; descender sprite
    ldy #0
    sta (z_l),y
    tya                                                               ; A=&00
    rts

; ****************************************
    ; unused
.create_invader_b
    lsr a
    jmp create_invader_c

; ****************************************
.create_invader
    jsr get_random                                                    ; gat a random row
.create_invader_c
    and #%00011111
    cmp #screen_height_g
    bcs create_invader                                                ; get a number 0-screenheight
    sta z_b
    lda #<tile_map
    sta z_l
    lda #>tile_map
    sta z_h
    lda #0
    sta z_c
    clc
    ror z_b                                                           ; multiply by 32 [moved to high byte and shift right 3 times]
    rol z_c
    ror z_b
    rol z_c
    ror z_b
    rol z_c
    lda #screen_width_g-1                                             ; far right of screen
    ora z_c
    sta z_c
    jsr add_hl_bc
    lda #11                                                           ; invader sprite
    ldy #0
    sta (z_l),y
    lda #0
    rts

; ****************************************
.player_dead
    lda #<1000                                                        ; player has been killed
    sta z_c
    lda #>1000
    sta z_b
.player_dead_spot_repeat
    lda z_c
    pha
    lda z_b
    pha                                                               ; load in the address of the tilemap
    lda #<tile_map
    sta z_l
    lda #>tile_map
    sta z_h
    jsr get_random                                                    ; pick a random column between 0-31
    and #%00011111
    clc
    adc z_l
    sta z_l                                                           ; shift to the random column
    lda #0
    sta z_b
.player_dead_spot_seek
    ldy #0
    lda (z_l),y
    cmp #13                                                           ; check if the column is showing our gameover grime
    bne player_dead_found_spot
    lda #<32                                                          ; if it is, move down until we find an empty spot
    sta z_e
    lda #>32
    sta z_d
    jsr add_hl_de
    inc z_b
    lda z_b
    cmp #screen_height_g-1
    beq player_dead_found_spot                                        ; we've got to the end of the screen
    jmp player_dead_spot_seek

.player_dead_found_spot
    lda #13
    ldy #0
    sta (z_l),y                                                       ; set the tile to our gameover grime
    pla
    sta z_b
    pla
    sta z_c
    lda z_c
    pha
    lda z_b
    pha
    lda z_c
    and #%00001111
    bne player_dead_no_redraw                                         ; only update the screen each 16 tiles
    lda z_c
    and #%11110000                                                    ; change the counter to a sound effect
    lsr a
    lsr a
    lsr a
    lsr a
    sta z_c
    lda z_b
    and #%00001111
    asl a
    asl a
    asl a
    asl a
    ora z_c
    eor #%00111111
    ora #%10000000
    jsr chibi_sound                                                   ; make the sound
    jsr force_animate
    jsr repaint_screen                                                ; update the screen
.player_dead_no_redraw
    pla
    sta z_b
    pla
    sta z_c
    jsr dec_bc
    lda z_b
    ora z_c
    beq player_dead_no_redraw_b
    jmp player_dead_spot_repeat                                       ; continue the game over animation

.player_dead_no_redraw_b
    lda #0
    jsr chibi_sound                                                   ; stop the sound
    lda #<tile_map
    sta z_l
    lda #>tile_map
    sta z_h
    lda #<(768-1)
    sta z_c
    lda #>(768-1)
    sta z_b
    lda #13
    jsr set_memory
    jsr force_repaint
    jsr repaint_screen                                                ; we may not have actually filled to screen with grime, so lets force-fill it here
    lda #<&1000                                                       ; wait a bit
    sta z_c
    lda #>&1000
    sta z_b
    jsr pause
    dec lives                                                         ; decrease the lives
    beq player_dead_no_redraw_c
    jmp new_game_round                                                ; if the player has lives left, keep playing

.player_dead_no_redraw_c
    ldx #(screen_width_g/2)-7+1                                       ; print the game over message
    ldy #(screen_height_g/2)-3
    jsr set_cursor_xy
    lda #<youre_dead_message
    sta z_l
    lda #>youre_dead_message
    sta z_h
    jsr print_message_hl
    ldx #(screen_width_g/2)-8                                         ; print the 'cos you suck' message
    ldy #(screen_height_g/2)+1
    jsr set_cursor_xy
    lda #<cos_you_suck_message
    sta z_l
    lda #>cos_you_suck_message
    sta z_h
    jsr print_message_hl
    ; compare score with high score
    lda #<score
    sta z_l
    lda #>score
    sta z_h
    lda #<high_score
    sta z_e
    lda #>high_score
    sta z_d
    lda #4
    sta z_b
    jsr compare_bcd                                                   ; check if we have a new high score
    bcs game_over_wait_for_fire
    ldx #(screen_width_g/2)-7+1                                       ; print the 'new high score' message
    ldy #(screen_height_g/2)+4
    jsr set_cursor_xy
    lda #<new_high_score_message
    sta z_l
    lda #>new_high_score_message
    sta z_h
    jsr print_message_hl
    ; copy 4 byte score into the high score
    lda #<4
    sta z_c
    lda #>4
    sta z_b
    lda #<score
    sta z_l
    lda #>score
    sta z_h
    lda #<high_score
    sta z_e
    lda #>high_score
    sta z_d
    jsr copy_memory_loop
.game_over_wait_for_fire
    jsr wait_for_fire                                                 ; pause then restart the game
    jmp title_screen

; ****************************************
.youre_dead_message
    equs "You're dead!"
    equb &ff
.cos_you_suck_message
    equs "('cos you suck!)"
    equb &ff
.new_high_score_message
    equs "New Hiscore!"
    equb &ff

; ****************************************
; See [this algorithm](https://github.com/bbbradsmith/prng_6502/blob/master/galois16.s)
.get_random
    txa                                         ; remember X
    pha                                         ;
    ldx #8                                      ;
    lda random_seed                             ;
.bit_loop
    asl a                                       ;
    rol random_seed_2                           ;
    bcc skip_eor                                ;
    eor #$2d                                    ;
.skip_eor
    dex                                         ;
    bne bit_loop                                ;
    sta random_seed                             ;
    pla                                         ; recall X
    tax                                         ;
    lda random_seed                             ;
    rts                                         ;

; ****************************************
.pause
    jsr dec_bc
    lda z_b
    ora z_c
    bne pause                                                         ; pause for BC ticks
    rts

; ****************************************
.add_de_32
    clc
    lda #32
    adc z_e
    sta z_e
    lda #0
    adc z_d
    sta z_d
    rts

.sub_de_32
    sec
    lda z_e
    sbc #32
    sta z_e
    lda z_d
    sbc #0
    sta z_d
    rts

.add_hl_32
    clc
    lda #32
    adc z_l
    sta z_l
    lda #0
    adc z_h
    sta z_h
    rts

; unused
.sub_hl_32
    sec
    lda z_l
    sbc #32
    sta z_l
    lda z_h
    sbc #0
    sta z_h
    rts

.sub_hl_64
    sec
    lda z_l
    sbc #64
    sta z_l
    lda z_h
    sbc #0
    sta z_h
    rts

; ****************************************
.do_mould_seek
    lda z_h                                                           ; load current location into DE
    sta z_d
    lda z_l
    sta z_e
    lda playerX1                                                      ; compare to player X
    cmp z_b
    beq do_mould_move_skip_X
    bcs do_mould_move_X_smaller
    dec z_e                                                           ; move left
    jmp do_mould_move_skip_X

.do_mould_move_X_smaller
    inc z_e                                                           ; move right
.do_mould_move_skip_X
    lda playerY1                                                      ; compare to player Y
    cmp z_c
    beq do_mould_move_skip_Y
    bcs do_mould_move_Y_smaller
    jsr sub_de_32                                                     ; move up
    jmp do_mould_move_skip_Y

.do_mould_move_Y_smaller
    jsr add_de_32                                                     ; move down
.do_mould_move_skip_Y
    ldy #0
    lda (z_e),y
    beq seek_ok
    cmp #5                                                            ; bullet
    beq seek_ok
    rts

.seek_ok
    ldy #0
    lda (z_l),y
    sta (z_e),y                                                       ; move to the new location, clear the old one
    tya                                                               ; A=&00
    sta (z_l),y
    rts

; ***************************************
; evolve the mould (full tick)
; ***************************************
.mould_evolve
    lda #<tile_map2
    sta z_l
    lda #>tile_map2
    sta z_h
    lda #0
    sta z_c
.mould_evolve_next_y
    lda #0
    sta z_b
.mould_evolve_next_x
    ldy #0
    lda (z_l),y
    sta z_as
    lda z_l
    pha
    lda z_h
    pha
    clc
    lda #&fd                                                          ; subtract 768, because we want to see the previous state
    adc z_h
    sta z_h
    lda z_as
    cmp #8
    beq mould_evolve_green                                            ; evolve a cell of green mould
    cmp #9
    beq mould_evolve_blue                                             ; evolve a cell of blue mould
    cmp #&0c
    bne mould_evolve_skip_a
    jsr do_descender                                                  ; move a descender down
.mould_evolve_skip_a
    cmp #11
    bne mould_evolve_skip_b
    jsr do_invader                                                    ; move an invader left
.mould_evolve_skip_b
    cmp #10
    bne mould_evolve_next
    jsr do_mould_seek                                                 ; move a seeker towards the player
.mould_evolve_next
    pla
    sta z_h
    pla
    sta z_l
    jsr inc_hl
    inc z_b
    lda z_b
    cmp #32
    bne mould_evolve_next_x
    inc z_c
    lda z_c
    cmp #24
    bne mould_evolve_next_y
    rts

; ****************************************
.mould_evolve_green
    lda #9                                                            ; centre objects (seeker)
    sta z_ixl
    lda #8                                                            ; edge objects (green)
    sta z_ixh
    jmp do_mould_evolve

; ****************************************
.mould_evolve_blue
    lda #10                                                           ; centre object (seeker)
    sta z_ixl
    lda #9                                                            ; edge object (blue)
    sta z_ixh
.do_mould_evolve
    lda z_ixl                                                         ; new centre spore
    ldy #0
    sta (z_l),y
    inc z_l                                                           ; move right
    lda z_l
    and #%00011111                                                    ; see if we're off the screen
    beq mould_evolve_green_skip1
    lda (z_l),y
    bne mould_evolve_green_skip1
    lda z_ixh                                                         ; new outer spore
    sta (z_l),y
.mould_evolve_green_skip1
    dec z_l                                                           ; move left
    dec z_l
    lda z_l
    and #%00011111
    cmp #%00011111
    beq mould_evolve_green_skip2
    lda (z_l),y                                                       ; see if we're off screen
    bne mould_evolve_green_skip2
    lda z_ixh                                                         ; new outer spore
    sta (z_l),y
.mould_evolve_green_skip2
    inc z_l                                                           ; move to centre
    jsr add_hl_32                                                     ; move down
    lda z_c
    cmp #24                                                           ; see if we're off the bottom of the screen
    beq mould_evolve_green_skip3b
    lda (z_l),y
    bne mould_evolve_green_skip3
    lda z_ixh                                                         ; new outer spore
    sta (z_l),y
.mould_evolve_green_skip3
    lda z_c                                                           ; see if we're off screen
    beq mould_evolve_green_skip4
.mould_evolve_green_skip3b
    lda #64                                                           ; move up
    sta z_e
    lda #0
    sta z_d
    jsr sub_hl_64
    lda (z_l),y
    bne mould_evolve_green_skip4
    lda z_ixh                                                         ; new outer spore
    sta (z_l),y
.mould_evolve_green_skip4
    jmp mould_evolve_next

; ***************************************
; Move the mould (partial tick)
; ***************************************
.mould_move
    lda anim_frame                                                    ; force animation
    eor #%00010000
    sta anim_frame
    lda #<tile_map2
    sta z_l
    lda #>tile_map2
    sta z_h
    lda #0
    sta z_c
.mould_move_nextY
    lda #0
    sta z_b
.mould_move_nextX
    ldy #0
    lda (z_l),y
    sta z_as
    clc
    lda #&fd                                                          ; subtract 768, because we want to see the previous state.
    adc z_h
    sta z_h
    lda z_as
    cmp #&0c
    bne mould_move_b
    jsr do_descender                                                  ; move a descender down
.mould_move_b
    cmp #11
    bne mould_move_c
    jsr do_invader                                                    ; move an invader left
.mould_move_c
    cmp #10
    bne mould_move_next
    jsr do_mould_seek                                                 ; move a seeker towards the player
.mould_move_next
    clc
    lda #3
    adc z_h
    sta z_h
    inc z_l
    inc z_b
    lda z_b
    cmp #32
    bne mould_move_nextX
    lda z_l
    bne mould_move_y_ok
    inc z_h
.mould_move_y_ok
    inc z_c
    lda z_c
    cmp #24
    bne mould_move_nextY
    rts

; ****************************************
.do_descender
    lda z_c
    cmp #screen_height_g-1
    bne do_decender_b
    jmp zero_current

.do_decender_b
    ldy #0
    lda (z_l),y
    sta z_d
    lda z_c
    pha
    lda z_b
    pha
    lda z_l
    pha
    lda z_h
    pha
    jsr add_hl_32                                                     ; move down a line
    ldy #0
    lda (z_l),y                                                       ; read in the object under the descender
    beq decender_done
    cmp #5
    bcs player_ok_a                                                   ; see if the descender has hit the player
    jmp player_dead

.player_ok_a
    bne no_zero_bullet
    lda #0                                                            ; don't copy player sprites!
.no_zero_bullet
    cmp #9
    beq descender_to_green                                            ; convert blue mould to green
    cmp #&0a
    beq descender_to_blue                                             ; convert seekers to blue mould
    jmp decender_done

.descender_to_blue
    lda #9                                                            ; blue mould
    jmp decender_done

.descender_to_green
    lda #8                                                            ; green mould
.decender_done
    sta z_as
    lda z_d
    sta (z_l),y
    pla
    sta z_h
    pla
    sta z_l
    pla
    sta z_b
    pla
    sta z_c
    ldy #0
    lda z_as
    sta (z_l),y
    lda #0
    rts

; ****************************************
.do_invader
    lda z_l
    and #%00011111
    beq zero_current                                                  ; we've reached the left hand side of the screen, so remove the invader
    ldy #0
    lda (z_l),y
    sta z_d
    dec z_l
    lda (z_l),y
    beq invader_done
    cmp #5
    bcs player_ok_b                                                   ; see if the descender has hit the player
    jmp player_dead

.player_ok_b
    bne invader_done
    lda #0                                                            ; don't copy player sprites
.invader_done
    pha
    ldy #0
    lda z_d
    sta (z_l),y
    inc z_l
    pla
    sta z_d
    cmp #8
    bcs do_invader_no_spore                                           ; don't drop a spore on non-empty spaces
    jsr get_random                                                    ; we drop spores at random
    and #%00011111
    bne do_invader_no_spore
    lda allowed_fast_growth                                           ; we're making a spore, so speed up the growth for a few ticks
    sta fast_growth
    lda #8
    jmp do_invader_new_spore                                          ; drop a new spore

.do_invader_no_spore
    lda z_d
.do_invader_new_spore
    ldy #0
    sta (z_l),y
    tya                                                               ; A=&00
    rts

; ****************************************
.zero_current
    lda #0
    tay                                                               ; Y=&00
    sta (z_l),y                                                       ; clear the cell
    rts

; ****************************************
.debounce
    lda z_l
    pha
    lda z_h
    pha
.debounce2
    jsr read_both_controls
    lda z_h
    cmp #&ff
    beq debounce2                                                     ; wait for all keys to be released
    pla
    sta z_h
    pla
    sta z_l
    rts

; ****************************************
.wait_for_fire
    jsr debounce                                                      ; wait for keys to be released
    lda z_l
    pha
    lda z_h
    pha
.wait_for_fire2
    jsr read_both_controls
    lda z_h
    ora #keymap_any_fire
    cmp #&ff
    beq wait_for_fire2                                                ; wait for any fire key to be released
    pla
    sta z_h
    pla
    sta z_l
    rts

; ****************************************
.force_animate
    lda #<(768/6)                                                     ; we animate 1/6 tiles each time, this keeps each frame fast, and makes the frames that animate look 'random'
    sta z_c
    lda #>(768/6)
    sta z_b
    lda #6
    sta z_e
    lda #0
    sta z_d
    inc z_b                                                           ; we need to inc b for the loop to work
    lda #<tile_map2                                                   ; we wipe tile_map2, to force an update of the tiles
    sta z_l
    lda #>tile_map2
    sta z_h
    lda anim_tick
    clc
    adc #1
    cmp #6                                                            ; see if the 6 sets have all been animated
    bne force_animate_update_l
    lda anim_frame                                                    ; all the frames have been animated, so we flip to showing the other frame
    eor #%00010000                                                    ; we toggle bit 5, because there are 16 tiles max (0-15)
    sta anim_frame
    lda #0                                                            ; reset animation tick
    sta anim_tick
    jmp force_animate_again_b

.force_animate_update_l
    sta anim_tick
    clc
    adc z_l
    sta z_l
.force_animate_again_b
    ; need A=0 when loop starts
    ldy #0
    ldx #255
.force_animate_again
    tya
    cmp (z_l),y                                                       ; we don't mess with 0 tiles, as it slows things down and causes problems
    beq cell_skip
    txa
    sta (z_l),y                                                       ; set the 'oldtile' to 255... this forces a repaint
.cell_skip
    jsr add_hl_de
    dec z_c
    bne force_animate_again
    dec z_b
    bne force_animate_again
    rts

; ****************************************
; clear the tilemap
; ****************************************
.clear_screen
    lda #>tile_map
    sta z_h
    lda #<tile_map
    sta z_l
    ldx #0
    jmp force_repaint_alt

; force a repaint of the whole tilemap (including blank spaces)
.force_repaint
    lda #>tile_map2
    sta z_h
    lda #<tile_map2
    sta z_l
    ldx #&ff
.force_repaint_alt
    lda #>(768-1)
    sta z_b
    lda #<(768-1)
    sta z_c
    txa
    jmp set_memory

; ****************************************
.repaint_screen
    lda #screen_width_g - 1                                           ; we start at the right of the screen, so our loops end when they reach zero
    sta z_ixh
    lda #screen_height_g - 2
    sta z_ixl
    jsr do_fill
    lda #screen_width_g - 2
    sta z_ixh
    lda #screen_height_g - 1
    sta z_ixl
    jsr do_fill
    lda #screen_width_g - 1
    sta z_ixh
    lda #screen_height_g - 1
    sta z_ixl
    jsr do_fill
    lda #screen_width_g - 2
    sta z_ixh
    lda #screen_height_g - 2
    sta z_ixl
.do_fill
    ldx z_ixl
.fill_c_again
    lda #0                                                            ; unwrapped version of find_tile
    sta z_l
    txa
    sta z_c
    clc
    ror a
    ror z_l
    ror a
    ror z_l
    ror a
    ror z_l
    clc
    adc #>tile_map
    sta z_h
    clc
    lda z_h
    adc #3
    sta z_d
    lda z_l
    sta z_e
    lda z_ixh
    tay
.fill_b_again
    lda (z_l),y                                                       ; live tile
    cmp (z_e),y                                                       ; compare new tile to old one
    beq fill_b_again_unchanged
    sta (z_e),y                                                       ; update old tile
    ora anim_frame
    tax
    sty z_b
    lda z_l
    pha
    lda z_h
    pha
    txa
    jsr show_tile
    pla
    sta z_h                                                           ; get source back
    clc
    adc #3                                                            ; recalculate old tilemap pos
    sta z_d
    pla
    sta z_e                                                           ; tilemaps are byte aligned
    sta z_l
    ldy z_b
.fill_b_again_unchanged
    dey
    dey
    bpl fill_b_again                                                  ; see if we've gone past zero
    ldx z_c
    dex
    dex
    bpl fill_c_again                                                  ; see if we've gone past zero
    rts

; ****************************************
; convert a BC (XY) coordinate to a memory_location
; ****************************************
.find_tile
    lda #0
    sta z_l
    lda z_c
    clc
    ror a
    ror z_l
    ror a
    ror z_l
    ror a
    ror z_l
    clc
    adc #>tile_map
    sta z_h
    lda z_l
    clc
    adc z_b
    sta z_l
    rts

; ***************************************
; draw the tile
; ***************************************
.render_tile
    jsr find_tile
    lda (z_l),y                                                       ; get the tile number
    ora anim_frame                                                    ; read in our animation frame (0-15)
    jmp show_tile

; ****************************************
.keymap_U
    equb %00000001                                                    ; bitmask
.keymap_D
    equb %00000010
.keymap_L
    equb %00000100
.keymap_R
    equb %00001000
.keymap_F1
    equb %00010000
.keymap_F2
    equb %00100000
.keymap_F3
    equb %01000000
.keymap_PAUSE
    equb %10000000

; ****************************************
.not_bit0
    equb %11111110
.not_bit1
    equb %11111101
.not_bit2
    equb %11111011
.not_bit3
    equb %11110111
.not_bit4
    equb %11101111
.not_bit5
    equb %11011111
.not_bit6
    equb %10111111
.not_bit7
    equb %01111111

; ****************************************
.print_hex
    pha
    clc
    and #&f0
    ror a
    ror a
    ror a
    ror a
    jsr print_hex_digit
    pla
    pha
    and #&0f
    jsr print_hex_digit
    pla
    rts

.print_hex_digit
    cmp #10
    bcs print_hex_letter
    clc
    adc #'0'
    jsr print_char
    rts

.print_hex_letter
    clc
    adc #&37
    jsr print_char
    rts

; ****************************************
.print_message_hl
    ldy #0
.print_message_loop
    lda (z_l),y
    cmp #&ff
    beq return_1
    jsr print_char
    iny
    jmp print_message_loop

.return_1
    rts

; ****************************************
; Set memory to accumulator value from HL for BC bytes.
.set_memory
    ldy #0
    sta (z_l),y
    lda z_l
    clc
    adc #1
    sta z_e
    lda #0
    adc z_h
    sta z_d
    ; fall through...

; copy memory from HL to DE for BC bytes
.copy_memory_loop
    ldy #0
    lda (z_l),y
    sta (z_e),y
    inc z_l
    bne c0e9b
    inc z_h
.c0e9b
    inc z_e
    bne c0ea1
    inc z_d
.c0ea1
    dec z_c
    bne copy_memory_loop
    lda z_b
    beq return_2
    dec z_b
    jmp copy_memory_loop

.return_2
    rts

; ****************************************
.inc_bc
    inc z_c
    bne return_3
    inc z_b
.return_3
    rts

; unused
.inc_de
    inc z_e
    bne return_4
    inc z_d
.return_4
    rts

.inc_hl
    inc z_l
    bne return_5
    inc z_h
.return_5
    rts

.dec_bc
    pha
    lda z_c
    bne skip_dec1
    dec z_b
.skip_dec1
    dec z_c
    pla
    rts

.dec_hl
    pha
    lda z_l
    bne skip_dec2
    dec z_h
.skip_dec2
    dec z_l
    pla
    rts

; unused
.dec_de
    pha
    lda z_e
    bne skip_dec3
    dec z_d
.skip_dec3
    dec z_e
    pla
    rts

.add_hl_de
    clc
    lda z_e
    adc z_l
    sta z_l
    lda z_d
    adc z_h
    sta z_h
    rts

.add_hl_bc
    clc
    lda z_c
    adc z_l
    sta z_l
    lda z_b
    adc z_h
    sta z_h
    rts

; unused
.sub_hl_bc
    sec
    lda z_l
    sbc z_c
    sta z_l
    lda z_h
    sbc z_b
    sta z_h
    rts

; unused
.sub_hl_de
    sec
    lda z_l
    sbc z_e
    sta z_l
    lda z_h
    sbc z_d
    sta z_h
    rts

.add_de_bc
    clc
    lda z_c
    adc z_e
    sta z_e
    lda z_b
    adc z_d
    sta z_d
    rts

; ****************************************
.bitmap_font
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00010000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00000000
    equb %00011000
    equb %00000000

    equb %00101000
    equb %01101100
    equb %00101000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00101000
    equb %01111100
    equb %00101000
    equb %01111100
    equb %00101000
    equb %00000000
    equb %00000000

    equb %00011000
    equb %00111110
    equb %01001000
    equb %00111100
    equb %00010010
    equb %01111100
    equb %00011000
    equb %00000000

    equb %00000010
    equb %11000100
    equb %11001000
    equb %00010000
    equb %00100000
    equb %01000110
    equb %10000110
    equb %00000000

    equb %00010000
    equb %00101000
    equb %00101000
    equb %01110010
    equb %10010100
    equb %10001100
    equb %01110010
    equb %00000000

    equb %00001100
    equb %00011100
    equb %00110000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00011000
    equb %00011000
    equb %00110000
    equb %00110000
    equb %00110000
    equb %00011000
    equb %00011000
    equb %00000000

    equb %00011000
    equb %00011000
    equb %00001100
    equb %00001100
    equb %00001100
    equb %00011000
    equb %00011000
    equb %00000000

    equb %00001000
    equb %01001001
    equb %00101010
    equb %00011100
    equb %00010100
    equb %00100010
    equb %01000001
    equb %00000000

    equb %00000000
    equb %00011000
    equb %00011000
    equb %01111110
    equb %00011000
    equb %00011000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00110000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %01111110
    equb %01111110
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00000000

    equb %00000010
    equb %00000100
    equb %00001000
    equb %00010000
    equb %00100000
    equb %01000000
    equb %10000000
    equb %00000000

    equb %01111100
    equb %11000110
    equb %11010110
    equb %11010110
    equb %11010110
    equb %11000110
    equb %01111100
    equb %00000000

    equb %00010000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00001000
    equb %00000000

    equb %00111100
    equb %01111110
    equb %00000110
    equb %00111100
    equb %01100000
    equb %01111110
    equb %00111100
    equb %00000000

    equb %00111100
    equb %01111110
    equb %00000110
    equb %00011100
    equb %00000110
    equb %01111110
    equb %00111100
    equb %00000000

    equb %00011000
    equb %00111100
    equb %01100100
    equb %11001100
    equb %01111100
    equb %00001100
    equb %00001000
    equb %00000000

    equb %00111100
    equb %01111110
    equb %01100000
    equb %01111100
    equb %00000110
    equb %01111110
    equb %00111110
    equb %00000000

    equb %00111100
    equb %01111110
    equb %01100000
    equb %01111100
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00111100
    equb %01111110
    equb %00000110
    equb %00001100
    equb %00011000
    equb %00011000
    equb %00010000
    equb %00000000

    equb %00111100
    equb %01100110
    equb %01100110
    equb %00111100
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00111100
    equb %01100110
    equb %01100110
    equb %00111110
    equb %00000110
    equb %01111110
    equb %00111100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00110000

    equb %00001100
    equb %00011100
    equb %00111000
    equb %01100000
    equb %00111000
    equb %00011100
    equb %00001100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %01111110
    equb %00000000
    equb %00000000
    equb %01111110
    equb %00000000
    equb %00000000

    equb %01100000
    equb %01110000
    equb %00111000
    equb %00001100
    equb %00111000
    equb %01110000
    equb %01100000
    equb %00000000

    equb %00111100
    equb %01110110
    equb %00000110
    equb %00011100
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00000000

    equb %01111100
    equb %11001110
    equb %10100110
    equb %10110110
    equb %11000110
    equb %11110000
    equb %01111100
    equb %00000000

    equb %00011000
    equb %00111100
    equb %01100110
    equb %01100110
    equb %01111110
    equb %01100110
    equb %00100100
    equb %00000000

    equb %00111100
    equb %01100110
    equb %01100110
    equb %01111100
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00111000
    equb %01111100
    equb %11000000
    equb %11000000
    equb %11000000
    equb %01111100
    equb %00111000
    equb %00000000

    equb %00111100
    equb %01100100
    equb %01100110
    equb %01100110
    equb %01100110
    equb %01100100
    equb %00111000
    equb %00000000

    equb %00111100
    equb %01111110
    equb %01100000
    equb %01111000
    equb %01100000
    equb %01111110
    equb %00111100
    equb %00000000

    equb %00111000
    equb %01111100
    equb %01100000
    equb %01111000
    equb %01100000
    equb %01100000
    equb %00100000
    equb %00000000

    equb %00111100
    equb %01100110
    equb %11000000
    equb %11000000
    equb %11001100
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00100100
    equb %01100110
    equb %01100110
    equb %01111110
    equb %01100110
    equb %01100110
    equb %00100100
    equb %00000000

    equb %00010000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00001000
    equb %00000000

    equb %00001000
    equb %00001100
    equb %00001100
    equb %00001100
    equb %01001100
    equb %11111100
    equb %01111000
    equb %00000000

    equb %00100100
    equb %01100110
    equb %01101100
    equb %01111000
    equb %01101100
    equb %01100110
    equb %00100100
    equb %00000000

    equb %00100000
    equb %01100000
    equb %01100000
    equb %01100000
    equb %01100000
    equb %01111110
    equb %00111110
    equb %00000000

    equb %01000100
    equb %11101110
    equb %11111110
    equb %11010110
    equb %11010110
    equb %11010110
    equb %01000100
    equb %00000000

    equb %01000100
    equb %11100110
    equb %11110110
    equb %11011110
    equb %11001110
    equb %11000110
    equb %01000100
    equb %00000000

    equb %00111000
    equb %01101100
    equb %11000110
    equb %11000110
    equb %11000110
    equb %01101100
    equb %00111000
    equb %00000000

    equb %00111000
    equb %01101100
    equb %01100100
    equb %01111100
    equb %01100000
    equb %01100000
    equb %00100000
    equb %00000000

    equb %00111000
    equb %01101100
    equb %11000110
    equb %11000110
    equb %11001010
    equb %01110100
    equb %00111010
    equb %00000000

    equb %00111100
    equb %01100110
    equb %01100110
    equb %01111100
    equb %01101100
    equb %01100110
    equb %00100110
    equb %00000000

    equb %00111100
    equb %01111110
    equb %01100000
    equb %00111100
    equb %00000110
    equb %01111110
    equb %00111100
    equb %00000000

    equb %00111100
    equb %01111110
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00001000
    equb %00000000

    equb %00100100
    equb %01100110
    equb %01100110
    equb %01100110
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00100100
    equb %01100110
    equb %01100110
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00011000
    equb %00000000

    equb %01000100
    equb %11000110
    equb %11010110
    equb %11010110
    equb %11111110
    equb %11101110
    equb %01000100
    equb %00000000

    equb %11000110
    equb %01101100
    equb %00111000
    equb %00111000
    equb %01101100
    equb %11000110
    equb %01000100
    equb %00000000

    equb %00100100
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00011000
    equb %00011000
    equb %00001000
    equb %00000000

    equb %01111100
    equb %11111100
    equb %00001100
    equb %00011000
    equb %00110000
    equb %01111110
    equb %01111100
    equb %00000000

    equb %00011100
    equb %00110000
    equb %00110000
    equb %00110000
    equb %00110000
    equb %00110000
    equb %00011100
    equb %00000000

    equb %10000000
    equb %01000000
    equb %00100000
    equb %00010000
    equb %00001000
    equb %00000100
    equb %00000010
    equb %00000000

    equb %00111000
    equb %00001100
    equb %00001100
    equb %00001100
    equb %00001100
    equb %00001100
    equb %00111000
    equb %00000000

    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %01111110
    equb %01111110
    equb %00011000
    equb %00011000

    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00111100
    equb %00111100
    equb %00011000
    equb %00011000

    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000

    equb %00000000
    equb %00000000
    equb %00111000
    equb %00001100
    equb %01111100
    equb %11001100
    equb %01111000
    equb %00000000

    equb %00100000
    equb %01100000
    equb %01111100
    equb %01100110
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00111100
    equb %01100110
    equb %01100000
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00001000
    equb %00001100
    equb %01111100
    equb %11001100
    equb %11001100
    equb %11001100
    equb %01111000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00111100
    equb %01100110
    equb %01111110
    equb %01100000
    equb %00111100
    equb %00000000

    equb %00011100
    equb %00110110
    equb %00110000
    equb %00111000
    equb %00110000
    equb %00110000
    equb %00010000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00111100
    equb %01100110
    equb %01100110
    equb %00111110
    equb %00000110
    equb %00111100

    equb %00100000
    equb %01100000
    equb %01101100
    equb %01110110
    equb %01100110
    equb %01100110
    equb %00100100
    equb %00000000

    equb %00011000
    equb %00000000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00001000
    equb %00000000

    equb %00000110
    equb %00000000
    equb %00000100
    equb %00000110
    equb %00000110
    equb %00100110
    equb %01100110
    equb %00111100

    equb %00100000
    equb %01100000
    equb %01100110
    equb %01101100
    equb %01111000
    equb %01101100
    equb %00100110
    equb %00000000

    equb %00010000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00001000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %01101100
    equb %11111110
    equb %11010110
    equb %11010110
    equb %11000110
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00111100
    equb %01100110
    equb %01100110
    equb %01100110
    equb %00100100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00111100
    equb %01100110
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00111100
    equb %01100110
    equb %01100110
    equb %01111100
    equb %01100000
    equb %00100000

    equb %00000000
    equb %00000000
    equb %01111000
    equb %11001100
    equb %11001100
    equb %01111100
    equb %00001100
    equb %00001000

    equb %00000000
    equb %00000000
    equb %00111000
    equb %01111100
    equb %01100000
    equb %01100000
    equb %00100000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00111100
    equb %01100000
    equb %00111100
    equb %00000110
    equb %01111100
    equb %00000000

    equb %00010000
    equb %00110000
    equb %00111100
    equb %00110000
    equb %00110000
    equb %00111110
    equb %00011100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00100100
    equb %01100110
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00100100
    equb %01100110
    equb %01100110
    equb %00111100
    equb %00011000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %01000100
    equb %11010110
    equb %11010110
    equb %11111110
    equb %01101100
    equb %00000000

    equb %00000000
    equb %00000000
    equb %11000110
    equb %01101100
    equb %00111000
    equb %01101100
    equb %11000110
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00100100
    equb %01100110
    equb %01100110
    equb %00111110
    equb %00000110
    equb %01111100

    equb %00000000
    equb %00000000
    equb %01111110
    equb %00001100
    equb %00011000
    equb %00110000
    equb %01111110
    equb %00000000

    equb %00001000
    equb %00001000
    equb %00001000
    equb %00001000
    equb %01010110
    equb %01010101
    equb %01010111
    equb %01110100

    equb %00011000
    equb %00000100
    equb %00001000
    equb %00011100
    equb %01010110
    equb %01010101
    equb %01010111
    equb %01110100

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %01111110
    equb %01111110
    equb %11111111
    equb %11111111

    equb %00011000
    equb %00111100
    equb %00011000
    equb %00011000
    equb %00011000
    equb %00011000
    equb %01111110
    equb %11111111

    equb %00100010
    equb %01110111
    equb %01111111
    equb %01111111
    equb %00111110
    equb %00011100
    equb %00001000
    equb %00000000

; ****************************************
.sprites
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000001
    equb %00010000
    equb %00010010
    equb %00100101
    equb %00100001
    equb %01100101
    equb %11110100
    equb %10010110

    equb %00001000
    equb %10001000
    equb %10000100
    equb %01001110
    equb %11000100
    equb %01101010
    equb %11110011
    equb %10011110

    equb %11000000
    equb %01101110
    equb %01111000
    equb %11000011
    equb %11011010
    equb %01111001
    equb %01101110
    equb %11000100

    equb %00000000
    equb %00001000
    equb %10000100
    equb %01101001
    equb %01101011
    equb %10001100
    equb %00001000
    equb %00000000

    equb %10010111
    equb %11111100
    equb %01100101
    equb %00110010
    equb %00100111
    equb %00010010
    equb %00010001
    equb %00000001

    equb %10010110
    equb %11110010
    equb %01101010
    equb %01001000
    equb %01001010
    equb %10000100
    equb %10000000
    equb %00001000

    equb %00000000
    equb %00000001
    equb %00010011
    equb %01101101
    equb %01101001
    equb %00010010
    equb %00000001
    equb %00000000

    equb %00110010
    equb %01100111
    equb %11101001
    equb %10110101
    equb %00111100
    equb %11100001
    equb %01100111
    equb %00110000

    equb %00000000
    equb %00000000
    equb %00000001
    equb %00010010
    equb %00010010
    equb %00000001
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00001000
    equb %10001100
    equb %10000100
    equb %00001000
    equb %00000000
    equb %00000000

    equb %01000000
    equb %10010100
    equb %00010010
    equb %01000001
    equb %01101000
    equb %00010100
    equb %10010010
    equb %00001101

    equb %01000001
    equb %00100100
    equb %10000101
    equb %00100000
    equb %00110100
    equb %00000010
    equb %10010000
    equb %00000011

    equb %00001111
    equb %01011011
    equb %00011111
    equb %01111110
    equb %11111000
    equb %00011110
    equb %01011010
    equb %00011111

    equb %10001000
    equb %00001010
    equb %00001000
    equb %00011111
    equb %01101110
    equb %10001000
    equb %10001010
    equb %00000000

    equb %00100001
    equb %00110100
    equb %01011010
    equb %11110000
    equb %01111000
    equb %01101001
    equb %00110100
    equb %00000011

    equb %00001000
    equb %10000110
    equb %11100001
    equb %01101001
    equb %11110000
    equb %10110100
    equb %11100001
    equb %00001110

    equb %00000100
    equb %00001101
    equb %00000011
    equb %00000101
    equb %00001110
    equb %00000101
    equb %00001011
    equb %00001101

    equb %00000101
    equb %00000110
    equb %00001101
    equb %00000010
    equb %00000111
    equb %00000010
    equb %00001001
    equb %00000011

    equb %00000000
    equb %00000001
    equb %00000001
    equb %00010111
    equb %01111111
    equb %00010001
    equb %01010101
    equb %00000001

    equb %00001000
    equb %10101010
    equb %10001000
    equb %11101111
    equb %10001110
    equb %00001000
    equb %00001000
    equb %00000000

    equb %00010001
    equb %00110000
    equb %01110000
    equb %11111111
    equb %11111111
    equb %01010010
    equb %00110000
    equb %00000000

    equb %00000000
    equb %11000000
    equb %11100000
    equb %11111110
    equb %11111110
    equb %01001010
    equb %11000000
    equb %00000000

    equb %00000000
    equb %00000001
    equb %00000011
    equb %00000111
    equb %00000111
    equb %00010011
    equb %01100111
    equb %00000000

    equb %00000000
    equb %00101010
    equb %00101110
    equb %01001110
    equb %10001110
    equb %00001100
    equb %00001000
    equb %00000000

    equb %11110000
    equb %11110010
    equb %11110100
    equb %11110000
    equb %11110000
    equb %11110001
    equb %11110000
    equb %11110000

    equb %11110000
    equb %11110011
    equb %11110000
    equb %11110000
    equb %11110010
    equb %11111100
    equb %11110000
    equb %11110000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000001
    equb %00010000
    equb %00010010
    equb %00100101
    equb %00100001
    equb %01100101
    equb %11110100
    equb %10010110

    equb %00001000
    equb %10001000
    equb %10000100
    equb %01001110
    equb %11000100
    equb %01101010
    equb %11110011
    equb %10011110

    equb %11000000
    equb %01101110
    equb %01111000
    equb %11000011
    equb %11011010
    equb %01111001
    equb %01101110
    equb %11000100

    equb %00000000
    equb %00001000
    equb %10000100
    equb %01101001
    equb %01101011
    equb %10001100
    equb %00001000
    equb %00000000

    equb %10010111
    equb %11111100
    equb %01100101
    equb %00110010
    equb %00100111
    equb %00010010
    equb %00010001
    equb %00000001

    equb %10010110
    equb %11110010
    equb %01101010
    equb %01001000
    equb %01001010
    equb %10000100
    equb %10000000
    equb %00001000

    equb %00000000
    equb %00000001
    equb %00010011
    equb %01101101
    equb %01101001
    equb %00010010
    equb %00000001
    equb %00000000

    equb %00110010
    equb %01100111
    equb %11101001
    equb %10110101
    equb %00111100
    equb %11100001
    equb %01100111
    equb %00110000

    equb %00000000
    equb %00000000
    equb %00000001
    equb %00010010
    equb %00010010
    equb %00000001
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00001000
    equb %10001100
    equb %10000100
    equb %00001000
    equb %00000000
    equb %00000000

    equb %01000000
    equb %10010100
    equb %00010010
    equb %01000001
    equb %01101000
    equb %00010100
    equb %10010010
    equb %00001101

    equb %01000001
    equb %00100100
    equb %10000101
    equb %00100000
    equb %00110100
    equb %00000010
    equb %10010000
    equb %00000011

    equb %00001111
    equb %01011011
    equb %00011111
    equb %01111110
    equb %11111000
    equb %00011110
    equb %01011010
    equb %00011111

    equb %10001000
    equb %00001010
    equb %00001000
    equb %00011111
    equb %01101110
    equb %10001000
    equb %10001010
    equb %00000000

    equb %00100101
    equb %01111000
    equb %01101001
    equb %11110000
    equb %01011010
    equb %00110100
    equb %00010010
    equb %00000001

    equb %00001100
    equb %11000010
    equb %11100001
    equb %10110100
    equb %11110000
    equb %01101001
    equb %11000010
    equb %00001100

    equb %00000000
    equb %00001010
    equb %00000101
    equb %00001010
    equb %00000100
    equb %00001010
    equb %00000101
    equb %00001010

    equb %00000101
    equb %00001010
    equb %00000101
    equb %00001101
    equb %00000010
    equb %00001101
    equb %00000010
    equb %00001101

    equb %00000001
    equb %01010101
    equb %00010001
    equb %01111111
    equb %00010111
    equb %00000001
    equb %00000001
    equb %00000000

    equb %00000000
    equb %00001000
    equb %00001000
    equb %10001110
    equb %11101111
    equb %10001000
    equb %10101010
    equb %00001000

    equb %00010001
    equb %00110000
    equb %01110000
    equb %11111111
    equb %11111111
    equb %00100101
    equb %00110000
    equb %00000000

    equb %00000000
    equb %11000000
    equb %11100000
    equb %11111111
    equb %11111111
    equb %10100100
    equb %11000000
    equb %00000000

    equb %00010001
    equb %00100011
    equb %01000111
    equb %10001111
    equb %10001111
    equb %10001011
    equb %01000101
    equb %00110011

    equb %11001100
    equb %00101010
    equb %00011101
    equb %00011111
    equb %00011111
    equb %00101110
    equb %01001100
    equb %10001000

    equb %11110000
    equb %11110000
    equb %11110100
    equb %11110010
    equb %11110000
    equb %11110000
    equb %11110000
    equb %11110000

    equb %11110000
    equb %11110001
    equb %11110010
    equb %11110000
    equb %11110000
    equb %11110010
    equb %11111100
    equb %11110000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000
    equb %00000000

; ****************************************
.raw_palettes
    ; format: &0GRB
    equw &0000
    equw &061f
    equw &0f00
    equw &0fac
    equw &0900
    equw &0f27
    equw &0518
    equw &061f
    equw &08b0
    equw &0df2
    equw &0aaa
    equw &0bbb
    equw &0ccc
    equw &0ddd
    equw &0eee
    equw &0fff

; ****************************************
.attribution_message
    equs "Written By Keith S, based on the DOS game by Mark Elendt. "
    equs "Fixes for the BBC Micro by TobyLobster. Thanks to Shane O'Brien,"
    equs "Roland Rzasa,Brainslave,Sal Gunduz,Paul Barrick,"
    equs "Richard Farrell,Oleg Tcymbaliuk,Barry White,Robsoft,"
    equs "Ervin Pajor and my other patreons"
    equs "                                "
    equb &ff
.url_message
    equs "www.chibiakumas.com/6502"
    equb &ff
.high_score_message
    equs "HiScore:"
    equb &ff
.paused_message
    equs "Paused"
    equb &ff

; ****************************************
    ; score values to add, in binary coded decimal
.bcd_1
    equb 0, 0, 0, 1
.bcd_3
    equb 0, 0, 0, 3
.bcd_5
    equb 0, 0, 0, 5
.bcd_20
    equb 0, 0, 0, &20

; ****************************************
; The title screen 'GRIME' logo. Each row of the logo is 24 bytes wide.
; ****************************************
.title_screen_cells
    equb 0,   0,   0,   9,   9,   0,   9,   9,   9,   0,   0,   9,   0,   0,   9,   9,   9,   0,   9,   0,   9,   9,   0,   0
    equb 9,   0,   9,   0,   0,   9,   9,   0,   0,   9,   9,   0,   9,   9,   0,   9,   0,   9,   9,   9,   0,   0,   9,   0
    equb 0,   9,   0, &0d, &0d,   0,   0, &0d, &0d,   0,   0, &0d,   0,   0, &0d,   0, &0d,   0,   9,   0, &0d, &0d,   0,   9
    equb 9,   0, &0d,   0,   0,   0,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0,   0,   9,   0
    equb 9,   0, &0d,   0, &0d, &0d,   0, &0d, &0d,   0,   0, &0d,   0, &0d,   0,   0,   0, &0d,   0, &0d, &0d,   0,   9,   0
    equb 9,   0, &0d,   0,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0,   9,   0, &0d,   0, &0d,   0,   0,   9,   0
    equb 0,   9,   0, &0d, &0d,   0,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0,   9,   0, &0d,   0,   0, &0d, &0d,   0,   9
    equb 9,   0,   9,   0,   0,   9,   0,   0,   0,   0,   0,   0,   9,   0,   0,   9,   9,   0,   0,   9,   0,   0,   9,   0
    equb 0,   9,   9,   9,   9,   0, &0d, &0d,   0, &0d, &0d, &0d,   0,   0, &0d,   0,   0, &0d, &0d,   0,   9,   9,   9,   9
    equb 0,   9,   9,   9,   0, &0d,   0,   0,   0, &0d,   0,   0,   0, &0d,   0, &0d,   0,   0,   0, &0d,   0,   9,   9,   0
    equb 0,   0,   9,   9,   0, &0d, &0d,   0,   0, &0d, &0d,   0,   0, &0d,   0, &0d,   0,   0, &0d,   0,   9,   9,   9,   0
    equb 9,   9,   9,   9,   0, &0d,   0, &0d,   0,   0,   0, &0d,   0, &0d,   0, &0d,   0, &0d,   0,   0,   9,   9,   9,   9
    equb 0,   9,   0,   9,   9,   0, &0d,   0,   0, &0d, &0d,   0,   9,   0, &0d,   0,   0, &0d, &0d, &0d,   0,   9,   0,   0
    equb 0,   0,   9,   9,   9,   9,   0,   9,   9,   0,   0,   9,   9,   9,   0,   9,   9,   0,   0,   0,   9,   9,   9,   0
    equb 0,   0,   0,   9,   9,   9,   9,   9,   9,   9,   9,   9,   0,   9,   9,   9,   9,   9,   9,   9,   0,   0,   9,   0
    equb 0,   0,   9,   0,   9,   0,   0,   9,   0,   9,   0,   0,   9,   0,   0,   0,   9,   0,   0,   9,   0,   0,   0,   0

; ****************************************
.read_joystick
    ; check the fire button
    lda system_via_register_b                                         ; get fire button
    and #&10                                                          ; just the fire button
    eor #&10                                                          ; invert so 1=pressed, 0=not pressed
    beq not_pressed
    sta joystick_enabled
.not_pressed
    sta joystick_button_pressed

    lda joystick_enabled
    beq return_8
    lda #&0F                                                          ; set write bits 0-3, read bits 4-7
    sta system_via_ddrb                                               ; i.e. standard bit pattern to read fire button in bit 4
    lda #0
    sta z_as                                                          ; zero result
    jsr read_joystick_axis
    lda #1
    jsr read_joystick_axis

    lda joystick_button_pressed
    ora z_as                                                          ; return with A containing both the directions and fire, z_as is just the directions
.return_8
    rts
    
; ****************************************
.read_joystick_axis
    sta adc_start_conversion_or_status                                ; start conversion

    ; wait for conversion to finish
.read_joystick_axis_wait_loop
    lda adc_start_conversion_or_status
    bmi read_joystick_axis_wait_loop
    
    lda adc_read_data_high_byte                                       ; read result
    cmp #&df
    bcs read_joystick_axis_high
    cmp #&20
    bcc read_joystick_axis_low
    
    ; axis is in neutral position, two zero bits '00' are shifted into result
    asl z_as
    asl z_as
    rts

.read_joystick_axis_high
    ; two bits '01' are shifted into result
    asl z_as
    sec
    rol z_as
    rts

.read_joystick_axis_low
    ; two bits '10' are shifted into result
    sec
    rol z_as
    asl z_as
    rts

; ****************************************
.print_X_bcd_bytes
    ldy #0
.print_X_bcd_bytes_loop
    tya
    pha
    lda z_e
    pha
    lda z_d
    pha
    lda (z_e),y
    jsr print_bcd_byte
    pla
    sta z_d
    pla
    sta z_e
    pla
    tay
    iny
    dex
    bne print_X_bcd_bytes_loop
    rts

; ****************************************
.bcd_add
    txa
    tay
    dey
    php
    sed
    clc
.bcd_add_loop
    lda (z_e),y
    adc (z_l),y
    sta (z_e),y
    dex
    beq bcd_add_done
    dey
    jmp bcd_add_loop

.bcd_add_done
    plp
    rts

; ****************************************
; unused
.bcd_sub
    txa
    tay
    dey
    php
    sed
    sec
.bcd_sub_loop
    lda (z_e),y
    sbc (z_l),y
    sta (z_e),y
    dex
    beq bcd_sub_done
    dey
    jmp bcd_sub_loop

.bcd_sub_done
    plp
    rts

; ****************************************
.print_bcd_byte
    pha
    and #&f0
    lsr a
    lsr a
    lsr a
    lsr a    
    jsr print_bcd_digit
    pla
    and #&0f
.print_bcd_digit
    clc
    adc #&30
    jmp print_char

.compare_bcd
    txa
    tay
    dey
    sed
.compare_bcd_loop
    lda (z_l),y
    cmp (z_e),y
    bne compare_bcd_done
    dex
    beq compare_bcd_done
    dey
    jmp compare_bcd_loop

.compare_bcd_done
    cld
    rts

; ****************************************
.show_tile
    ; HL = A * 16
    asl a
    sta z_l
    lda #0
    rol a
    rol z_l
    rol a
    rol z_l
    rol a
    rol z_l
    rol a
    sta z_h

    ; HL += sprites
    lda #<sprites
    clc
    adc z_l
    sta z_l
    lda #>sprites
    adc z_h
    sta z_h

    ; X = B
    ldx z_b

    ; Y = C * 8
    lda z_c
    asl a
    rol a
    rol a
    tay

    jsr get_screen_pos                                                ; DE = screen address

    ; copy 16 bytes to screen memory for the tile
    ldy #&0f                                                          ; bytes in tile
.copy_to_screen_loop
    lda (z_l),y                                                       ; copy bytes to screen
    sta (z_e),y
    dey
    lda (z_l),y                                                       ; copy bytes to screen
    sta (z_e),y
    dey
    bpl copy_to_screen_loop
    rts

; ****************************************
; Set DE = screen address of tile coordinates (X,Y)
.get_screen_pos
    ; DE = X * 16
    lda #0
    sta z_d
    txa
    asl a
    rol a
    rol a
    rol a
    rol z_d
    sta z_e

    ; DE += row * 640       (row = Y/8)
    tya
    and #&f8
    lsr a
    lsr a
    tay
    lda screen_row_addresses,y
    clc
    adc z_e
    sta z_e
    lda screen_row_addresses+1,y
    adc z_d
    sta z_d

    ; DE += &41C0  (offset to screen address)
    lda #&c0
    clc
    adc z_e
    sta z_e
    lda #&41
    adc z_d
    sta z_d
    rts

.screen_row_addresses
    equw 0 * 640
    equw 1 * 640
    equw 2 * 640
    equw 3 * 640
    equw 4 * 640
    equw 5 * 640
    equw 6 * 640
    equw 7 * 640
    equw 8 * 640
    equw 9 * 640
    equw 10 * 640
    equw 11 * 640
    equw 12 * 640
    equw 13 * 640
    equw 14 * 640
    equw 15 * 640
    equw 16 * 640
    equw 17 * 640
    equw 18 * 640
    equw 19 * 640
    equw 20 * 640
    equw 21 * 640
    equw 22 * 640
    equw 23 * 640
    equw 24 * 640
    equw 25 * 640
    equw 26 * 640
    equw 27 * 640
    equw 28 * 640
    equw 29 * 640
    equw 30 * 640
    equw 31 * 640

; ****************************************
.initialize_screen
    lda #&d8
    sta video_ula_control
    ldx #crtc_horz_total
.set_crtc_loop
    txa
    sta crtc_address_register
    lda crtc_register_values,x
    sta crtc_register_data
    inx
    txa
    cmp #&0f
    bne set_crtc_loop
.set_palette
    ldx #0
.set_palette_loop
    lda palette_values,x
    sta video_ula_palette
    inx
    txa
    cmp #&10
    bne set_palette_loop
    rts

; ****************************************
.cls
    ; HL=$4180
    lda #&80
    sta z_l
    lda #&41
    sta z_h
    ; BC=80*200
    lda #&80
    sta z_c
    lda #&3e
    sta z_b
    lda #0
    jsr set_memory
    ldx #0
    ldy #0
.set_cursor_xy
    txa
    sta cursorX
    tya
    sta cursorY
    rts

; ****************************************
.print_char
    clc
    sbc #&1f
    sta z_c

    pha                                                               ; push A,X,Y onto the stack
    txa
    pha
    tya
    pha

    lda z_h                                                           ; puch HL onto the stack
    pha
    lda z_l
    pha

    lda #0                                                            ; BC = char * 8
    asl z_c
    rol a
    rol z_c
    rol a
    rol z_c
    rol a
    sta z_b

    ; HL = bitmap_font + BC
    lda #<bitmap_font
    sta z_l
    lda #>bitmap_font
    sta z_h
    jsr add_hl_bc
    
    ; DE = (cursorX + 4) * 16
    lda #0
    sta z_d
    lda cursorX
    clc
    adc #4
    asl a
    rol a
    rol a
    rol z_d
    rol a
    rol z_d
    sta z_e

    ; DE += row * 640       (row = Y/8)
    lda cursorY
    asl a
    tay
    lda screen_row_addresses,y
    clc
    adc z_e
    sta z_e
    lda screen_row_addresses+1,y
    adc z_d
    sta z_d

    ; DE += &4180 = screen address
    lda #&80
    clc
    adc z_e
    sta z_e
    lda #&41
    adc z_d
    sta z_d

    ldy #8
.do_font_again
    tya
    pha

    dey
    lda (z_l),y         ; read from font
    tax                 ;
    and #&f0            ; get top four bits
    sta z_as            ;
    lsr a
    lsr a
    lsr a
    lsr a
    ora z_as            ; add in top four bits, a copy of the bottom four bits
    sta (z_e),y         ; store on screen
    
    ; move to next cell on screen
    tya                                                               ; add 8 to Y
    clc
    adc #8
    tay
    
    txa                 ; 
    and #&0f            ; get bottom four bits
    sta z_as            ;
    asl a
    asl a
    asl a
    asl a
    ora z_as            ; add in bottom four bits, a copy of the top four bits
    sta (z_e),y         ; store on screen

    pla
    tay
    dey                 ; move to next row up
    bne do_font_again
    
    inc cursorX
    lda cursorX
    cmp #40
    bne not_next_line
    jsr newline
.not_next_line
    pla                                                               ; pull HL from the stack
    sta z_l
    pla
    sta z_h

    pla                                                               ; pull A,X,Y from the stack
    tay
    pla
    tax
    pla
    rts

; ****************************************
.crtc_register_values
    equb &7f, &50, &62, &28, &26, 0, &19, &22, 1, 7, &30, 0, 8, &30

; ****************************************
.palette_values
.palette0
    equb &03, &13
.palette1
    equb &22, &32, &43, &53, &62, &72
.palette2
    equb &84, &94
.palette3
    equb &a0, &b0, &c4, &d4, &e0, &f0

; ****************************************
.newline
    lda #0
    sta cursorX
    inc cursorY
    rts

; ****************************************
.do_one_palette
    lda (z_c),y
    and #&f0
    ora z_as
    sta (z_c),y
    iny
.return_6
    rts

; ****************************************
.do_set_palette
    cmp #4                                                            ; A=palette index. We only have four colours.
    bcs return_6
    sta z_as
    
    pha                                                               ; push A,X,Y onto the stack
    txa
    pha
    tya
    pha

    lda z_as
    clc
    rol a
    tay                                                               ; Y = 2*palette index
    lda z_l                                                           ; first byte of two bytes in format: &0GRB ?
    and #&f0                                                          ; top nybble
    jsr pal_colour_conversion
    sta z_b                                                           ; R
    lda z_l
    and #&0f                                                          ; B
    jsr pal_colour_conversionR
    sta z_l
    lda z_h                                                           ; G
    and #&0f
    jsr pal_colour_conversionR
    sta z_h
    lda #0
    clc
    adc z_h                                                           ; Add green * 9
    adc z_h
    adc z_h
    adc z_h
    adc z_h
    adc z_h
    adc z_h
    adc z_h
    adc z_h
    adc z_b                                                           ; Add red * 3
    adc z_b
    adc z_b
    adc z_l                                                           ; Add blue
    sta z_c
    lda #0
    sta z_b
    lda #<colour_indices
    sta z_l
    lda #>colour_indices
    sta z_h
    jsr add_hl_bc
    ldx #0
    lda (z_l,x)
    sta z_as
    lda #<palette_address_table
    sta z_l
    lda #>palette_address_table
    sta z_h
    lda (z_l),y
    sta z_c
    iny
    lda (z_l),y
    sta z_b
    ldy #0
    jsr do_one_palette
    jsr do_one_palette
    iny
    iny
    jsr do_one_palette
    jsr do_one_palette
    jsr set_palette
    pla                                                               ; pull A,X,Y from the stack
    tay
    pla
    tax
    pla
    rts

; ****************************************
.palette_address_table
    equw palette0,palette1,palette2,palette3

; ****************************************
.pal_colour_conversionR
    asl a
    rol a
    rol a
    rol a
    ; fall through...
    
; ****************************************
; return 0 if <5
;        1 if <10
;        2 otherwise
.pal_colour_conversion
    cmp #&50
    bcc return_with_zero
    cmp #&a0
    bcc return_with_one
    lda #2
    rts

; ****************************************
.return_with_zero
    lda #0
    rts

; ****************************************
.return_with_one
    lda #1
    rts

; ****************************************
.colour_indices
    equb 7, 3, 3, 1, 2, 2, 1, 2, 2, 5, 5, 1, 4, 0, 1, 2, 2, 2, 5, 5
    equb 1, 5, 5, 1, 4, 4, 0

; ****************************************
.chibi_sound
    pha
    lda #$ff                                ; set all bits to write
    sta system_via_ddra                     ; for data direction register a
    pla
    ; A as binary is 'abpppppp' where p = pitch, a = noise, b = volume
    ; 0 means silent
    beq silent
    
    ; send pitch for channel 1
    tax
    lda #&cf
    jsr send_byte_to_sound_chip             ; sends frequency F0-F3 of in lowest 4 bits
    txa
    and #&3f
    jsr send_byte_to_sound_chip             ; sends frequency F4-F9 of in lowest 6 bits

    ; set volume required
    txa
    ldy #&d0                                ; Y = 11010000 = channel 1 full volume
    and #&40                                ; extract the volume bit
    bne got_volume_byte_in_y
    ldy #&d6                                ; Y = 11010110 = channel 1 quieter volume
.got_volume_byte_in_y
    tya
    jsr send_byte_to_sound_chip             ; sends volume for channel 1

    ; check for noise
    txa
    bpl return_7                            ; if no noise required, branch (done)

    ; noise control
    lda #&e7                                ; 11100111 = noise control, white noise, frequency set by channel 1
    jsr send_byte_to_sound_chip             ; sends noise control byte
    
    ; set noise volume
    tya                                     ;
    ora #&f0                                ; 1111xxxx = set noise volume to xxxx
    eor #4                                  ; invert the volume for the noise (loud tone=quiet noise and vice versa)
    jmp send_byte_to_sound_chip             ; sends noise volume

.silent
    lda #&df                                ; 11011111 = channel 1 volume silent
    jsr send_byte_to_sound_chip
    lda #&ff                                ; 11111111 = noise volume silent
    ; fall through...
    
.send_byte_to_sound_chip
    sta system_via_register_a_no_handshake  ; send byte A to chip
    lda #0                                  ;
    sta system_via_register_b               ; let the sound chip know there is data
    jsr return_7                            ; delay at least 8us (16 cycles)
    lda #8                                  ; for the hardware to deal with the data
    sta system_via_register_b               ; finish up (make inactive)
.return_7
    rts

; ****************************************
.read_both_controls
    ; Return with a byte z_h whose 8 bits are the state of the controls:
    ;
    ;  Two bits for each direction axis:
    ;
    ;       00 - neutral
    ;       01 - high
    ;       10 - low
    ;
    ; Left right axis in bits 0,1
    ;    Up down axis in bits 2,3
    ;
    ;  First 'fire' button/key in bit 4
    ; Second 'fire' in bit 5
    ;  Third 'fire' in bit 6
    ;       'Pause' in bit 7
    ;
    ; z_h holds the bits of the controls (0=pressed)

    jsr read_joystick
    sta temp_controls                    ; remember the joystick state
    jsr read_keyboard
    ora temp_controls                    ; combine the keyboard and joystick state
    pha                                  ; A contains all controls (1 means pressed)
    and #&0f
    sta z_as                             ; just the directions [not needed?]
    pla

    eor #&ff                             ; invert all the controls
    sta z_h                              ; store in z_h (0 means pressed)
    rts

key_code_escape                       = $70
key_code_colon                        = $48
key_code_slash                        = $68
key_code_close_square_bracket         = $58

key_code_p                            = $37
key_code_space                        = $62
key_code_return                       = $49
key_code_x                            = $42
key_code_z                            = $61

key_code_k                            = $46
key_code_m                            = $65

; ****************************************
.keys_to_test
    equb key_code_p
    equb key_code_space
    equb key_code_colon
    equb key_code_close_square_bracket
    equb key_code_x
    equb key_code_z
    equb key_code_slash
.keys_to_test_end

.key_states
.key_state_p
    equb 0
.key_state_space    
    equb 0
.key_state_colon
    equb 0
.key_state_return
    equb 0
.key_state_x
    equb 0
.key_state_z
    equb 0
.key_state_slash
    equb 0


; ****************************************
.read_keyboard
    ; To test for individual key presses, we must first write 3 to system_via_register_b,
    ; which turns off regular keyboard scanning, and on via port A set bits 0-6 to be
    ; output (we will write to bits 0-6 which key we are interested in) and bit 7 to
    ; input (we read the boolean result).
    ;
    lda #3                              ;
    sta system_via_register_b           ; Disable keyboard auto scanning
    lda #$7f                            ;
    sta system_via_ddra                 ; Set System VIA Port A to output on bits 0-6, and input on bit 7

    ; We read the keys in a loop to see if they are currently pressed or released.
    ldx #keys_to_test_end - keys_to_test - 1 ;
.read_key_loop
    lda key_states,X                    ;
    lda keys_to_test,X                  ;
    sta system_via_register_a_no_handshake ; Say which key we are interested in (write to System VIA Port A)
    lda system_via_register_a_no_handshake ; Read key state (read from System VIA Port A)
    and #$80                            ; just the top bit reflects key state
                                        ; 0 means up, $80 means down
    sta key_states,X                    ; Record results
    dex                                 ;
    bpl read_key_loop                   ;

    ; finish up, restore state
    lda #$ff                            ;
    sta system_via_ddra                 ; Set System VIA Port A to output on all bits 0-7
    lda #11                             ; Enable keyboard auto scanning
    sta system_via_register_b           ;

    ; convert key_states into z_as
    lda #0
    asl key_state_p
    rol a                               ; bit 7 = pause
    clc
    rol a                               ; bit 6 = fire3 = change control mode [not used for now]
    asl key_state_return
    rol a                               ; bit 5 = fire2
    asl key_state_space
    rol a                               ; bit 4 = fire
    asl key_state_x
    rol a                               ; bit 3 = right
    asl key_state_z
    rol a                               ; bit 2 = left
    asl key_state_slash
    rol a                               ; bit 1 = down
    asl key_state_colon
    rol a                               ; bit 0 = up

    pha
    and #$0f
    sta z_as                            ; z_as just contains the directions
    pla                                 ; A contains all the controls
    rts

; ****************************************
; final byte
; ****************************************
    equb 0
end = *

    ; Copy the newly assembled block of code back to it's proper place in the binary
    ; file.
    ; (Note the parameter order: 'copyblock <start>,<end>,<dest>')
    copyblock start, *, &3000+entry_length

    ; Clear the area of memory we just temporarily used to assemble the new block,
    ; allowing us to assemble there again if needed
    clear start, end

    ; Set the program counter to the next position in the binary file.
    org &3000 + entry_length + (* - start)

.pydis_end

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
