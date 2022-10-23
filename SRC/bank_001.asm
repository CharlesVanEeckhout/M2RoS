; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

; 01:4000
include "data/sprites_samus.asm"

VBlank_updateStatusBar: ;{ 01:493E
    ; Exit if the queen's head is being animated (vblank time optimization?)
    ld a, [queen_headFrameNext]
    and a
        ret nz
    ; Don't update while an item is being collected
    ld a, [itemCollected]
    and a
        ret nz
    ld a, [itemCollectionFlag]
    and a
        ret nz

; Draw energy tanks {
    ; Prep energy tank graphics
    ld hl, hHUD_tank1
    ; Fill buffer with blank spaces
    ld a, $af ; Blank space
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    
    ; Check max energy
    ld a, [samusEnergyTanks]
    and a
    jr z, .else_A
        ; Pre-fill buffer with empty tanks
        ld b, a
        ld hl, hHUD_tank1
        ld a, $9c ; Empty tank
    
        .loop_A: ; Loop for max tanks
            ld [hl+], a
            dec b
        jr nz, .loop_A
    
        ld a, [samusDispHealthHigh]
        and a
        jr z, .endIf_A
            ; Fill buffer with full tanks
            ld b, a
            ld hl, hHUD_tank1
            ld a, $9d ; Filled tank
        
            .loop_B: ; Loop for full tanks
                ld [hl+], a
                dec b
            jr nz, .loop_B
    
            jr .endIf_A
    .else_A:
        ; Draw E
        ld a, $aa ; E
        ldh [hHUD_tank1], a
    .endIf_A:

    ; Adjust draw destination depending on if in the Queen fight or not
    ; (the HUD in the Queen's room is on the normal BG layer, since her head uses the window layer)
    ld hl, vramDest_queenStatusBar
    ld a, [queen_roomFlag]
    cp $11
    jr z, .endIf_B
        ld a, $07
        ldh [rWX], a
        ld hl, vramDest_statusBar
    .endIf_B:

    ; Draw enery tanks
    ldh a, [hHUD_tank5]
    ld [hl+], a
    ldh a, [hHUD_tank4]
    ld [hl+], a
    ldh a, [hHUD_tank3]
    ld [hl+], a
    ldh a, [hHUD_tank2]
    ld [hl+], a
    ldh a, [hHUD_tank1]
    ld [hl+], a
    ld a, $9e ; Dash
    ld [hl+], a
;}

    ; Draw Samus' health (tens digit)
    ld a, [samusDispHealthLow]
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ; Ones digit
    ld a, [samusDispHealthLow]
    and $0f
    add $a0
    ld [hl+], a
    
    ; Skip over missile icon (drawn previously)
    inc hl
    inc hl
    inc hl
    
    ; Draw Samus' missiles (hundreds digit)
    ld a, [samusDispMissilesHigh]
    and $0f
    add $a0
    ld [hl+], a
    ; Tens digit
    ld a, [samusDispMissilesLow]
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ; Ones digit
    ld a, [samusDispMissilesLow]
    and $0f
    add $a0
    ld [hl+], a
    
    ; Skip over metroid icon
    inc hl
    inc hl
    inc hl
    inc hl

; Draw Metroid counter in corner {
    ; Check if paused
    ldh a, [gameMode]
    cp $08
    jr z, .else_C
        ld a, [metroidCountShuffleTimer]
        and a
        jr nz, .else_D
            ; Draw normal metroid counter (tens digit)
            ld a, [metroidCountDisplayed]
            and $f0
            swap a
            add $a0
            ld [hl+], a
            ; Ones digit
            ld a, [metroidCountDisplayed]
            and $0f
            add $a0
            ld [hl], a
            ret
        .else_D:
            ; Draw scrambled metroid counter
            dec a
            ld [metroidCountShuffleTimer], a
            cp $80 ; Wait until counter is less than $80 before scrambling
                ret nc
            ; Tens digit
            ldh a, [rDIV]
            add $10
            daa
            and $f0
            swap a
            add $a0
            ld [hl+], a
            ; Ones digit
            ldh a, [rDIV]
            inc a
            daa
            and $0f
            add $a0
            ld [hl], a
            ret
    .else_C:
        ld a, [metroidLCounterDisp]
        cp $ff
        jr z, .else_E
            ; Draw normal L counter (tens digit)
            and $f0
            swap a
            add $a0
            ld [hl+], a
            ; Ones digit
            ld a, [metroidLCounterDisp]
            and $0f
            add $a0
            ld [hl], a
            ret
        .else_E:
            ; Draw blank L counter "--"
            ld a, $9e ; Dash
            ld [hl+], a
            ld [hl], a
            ret
;}
;} end proc

adjustHudValues:: ;{ 01:4A2B - Adjusts displayed health and missiles
    ; Clamp ones digit of health to decimal range
    ld a, [samusCurHealthLow]
    and $0f
    cp $0a
    jr c, .endIf_A
        ld a, [samusCurHealthLow]
        and $f0
        add $09
        ld [samusCurHealthLow], a
    .endIf_A:

    ; Clamp tens digit of health to decimal range
    ld a, [samusCurHealthLow]
    and $f0
    cp $a0
    jr c, .endIf_B
        ld a, [samusCurHealthLow]
        and $0f
        add $90
        ld [samusCurHealthLow], a
    .endIf_B:

; Adjust health {
    ; Check health high byte 
    ld a, [samusCurHealthHigh]
    ld b, a
    ld a, [samusDispHealthHigh]
    cp b
        jr z, .checkHealthLowByte
        jr nc, .decrementDisplayedHealth
    jr .incrementDisplayedHealth

.checkHealthLowByte:
    ; Check health low byte
    ld a, [samusCurHealthLow]
    ld b, a
    ld a, [samusDispHealthLow]
    cp b
        jr z, .checkMissileHighByte
        jr nc, .decrementDisplayedHealth
    ; Fallthrough to .incrementDisplayedHealth

.incrementDisplayedHealth: ; Increment displayed health
    ; Increment low byte
    ld a, [samusDispHealthLow]
    add $01
    daa
    ld [samusDispHealthLow], a
    ; Carry
    ld a, [samusDispHealthHigh]
    adc $00
    daa
    ld [samusDispHealthHigh], a
    
    ; Check if no sound effect is playing
    ld a, [sfxPlaying_square1]
    and a
    jr nz, .checkMissileHighByte
        ; Play sound every 4 frames
        ldh a, [frameCounter]
        and $03
        jr nz, .checkMissileHighByte
            ld a, $18
            ld [sfxRequest_square1], a
    jr .checkMissileHighByte

.decrementDisplayedHealth: ; Decrement displayed health
    ; Decrement low byte
    ld a, [samusDispHealthLow]
    sub $01
    daa
    ld [samusDispHealthLow], a
    ; Carry
    ld a, [samusDispHealthHigh]
    sbc $00
    daa
    ld [samusDispHealthHigh], a
    
    ; Check if no sound effect is playing
    ld a, [sfxPlaying_square1]
    and a
    jr nz, .checkMissileHighByte
        ; Play sound every 4 frames
        ldh a, [frameCounter]
        and $03
        jr nz, .checkMissileHighByte
            ld a, $18
            ld [sfxRequest_square1], a
    ; Fallthrough to .checkMissileHighByte
;}

 ; Adjust missiles {
.checkMissileHighByte: 
    ; Check missile high byte
    ld a, [samusCurMissilesHigh]
    ld b, a
    ld a, [samusDispMissilesHigh]
    cp b
        jr z, .checkMissileLowByte
        jr nc, .decrementDisplayedMissiles
    jr .incrementDisplayedMissiles

.checkMissileLowByte: ; Check missile low byte
    ld a, [samusCurMissilesLow]
    ld b, a
    ld a, [samusDispMissilesLow]
    cp b
        ret z
        jr nc, .decrementDisplayedMissiles
    ; Fallthrough to .incrementDisplayedMissiles

.incrementDisplayedMissiles: ; Increment displayed missile count
    ; Increment low byte
    ld a, [samusDispMissilesLow]
    add $01
    daa
    ld [samusDispMissilesLow], a
    ; Carry
    ld a, [samusDispMissilesHigh]
    adc $00
    daa
    ld [samusDispMissilesHigh], a

    ; Play sound every 4 frames
    ldh a, [frameCounter]
    and $03
    ret nz
        ld a, $0c
        ld [sfxRequest_square1], a
ret

.decrementDisplayedMissiles: ; Decrement displayed missile count
    ; Decrement low byte
    ld a, [samusDispMissilesLow]
    sub $01
    daa
    ld [samusDispMissilesLow], a
    ; Carry
    ld a, [samusDispMissilesHigh]
    sbc $00
    daa
    ld [samusDispMissilesHigh], a
ret
;}
;} end proc

; Debug Menu drawing routine (note this procedure has two entrances
debug_drawNumber: ;{ 01:4AFC 
.twoDigit: ; Display a two-sprite number
    ldh [hTemp.b], a
    swap a
    and $0f
    add $a0 ; Adjust value for display
    call .drawSprite
    ldh a, [hTemp.b]
.oneDigit: ; 01:4B09 - Display a one-sprite number
    and $0f
    add $a0 ; Adjust value for display
    call .drawSprite
ret

.drawSprite: ; 01:4B11
    ; Save sprite tile to temp
    ldh [hTemp.a], a

    ; Load WRAM address to HL
    ld h, HIGH(wram_oamBuffer) ; $C0
    ldh a, [hOamBufferIndex]
    ld l, a

    ; Write Y and X positions
    ldh a, [hSpriteYPixel]
    ld [hl+], a
    ldh a, [hSpriteXPixel]
    ld [hl+], a

    ; Update x position for next sprite
    add $08
    ldh [hSpriteXPixel], a

    ; Write tile number and sprite attributes
    ldh a, [hTemp.a]
    ld [hl+], a
    ldh a, [hSpriteAttr]
    ld [hl+], a
    ; Save OAM buffer value
    ld a, l
    ldh [hOamBufferIndex], a
ret ;}

; Render Metroid sprite on the HUD
drawHudMetroid:: ;{ 01:4B2C
    ; Set sprite to default HUD Y position
    ld a, $98
    ldh [hSpriteYPixel], a

    ; Logic for raising the Y position
    ; Don't raise the HUD metroid if in the Queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr z, .endIf
        ; Do raise the the HUD metroid
        ; ...if standing on save point
        ld a, [saveContactFlag]
        and a
            jr nz, .then
        ; ...or if a major item is being collected
        ld a, [itemCollected_copy]
        and a
        jr z, .endIf
            cp $0b ; Threshold between major items and refills
            jr nc, .endIf
        .then:
            ; Then render the metroid counter 8 pixels up
            ld a, $90
            ldh [hSpriteYPixel], a
    .endIf:

    ; Set x position
    ld a, $80
    ldh [hSpriteXPixel], a
    ld a, $01
    ld [samus_screenSpritePriority], a
    
    ; Animate the metroid every 16 frames
    ldh a, [frameCounter]
    and $10
    swap a
    add $3f
    ldh [hSpriteId], a
    ; Draw the sprite
    call drawSamusSprite
ret ;}

; Draws a sprite from Samus's sprite bank
drawSamusSprite: ;{ 01:4B62
    ; Unnecessary bank switch (indicates this routine was originally in bank 0)
    switchBank samusSpritePointerTable
    
    ; Index into sprite pointer table
    ldh a, [hSpriteId]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, samusSpritePointerTable
    add hl, de
    ; Load pointer from table
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    
    ; Prep HL
    ld h, HIGH(wram_oamBuffer) ; $C0
    ldh a, [hOamBufferIndex]
    
    ; Store x and y offsets of sprite in B and C
    ld l, a
    ldh a, [hSpriteYPixel]
    ld b, a
    ldh a, [hSpriteXPixel]
    ld c, a

    .spriteLoop:
        ; No sprite flipping logic here
        ; Load y coordinate
        ld a, [de]
        cp METASPRITE_END ; Exit if at the end of the sprite
            jr z, .exit
        add b
        ld [hl+], a
        
        ; Load x coordinate
        inc de        
        ld a, [de]
        add c
        ld [hl+], a
        
        ; Load tile number
        inc de
        ld a, [de]
        ld [hl+], a
        ; Load sprite attribute byte
        inc de
        
        ; Set PAL1 bit or leave it alone
        ldh a, [hSpriteAttr]
        and a
        jr z, .else_A
            ld a, [de]
            set OAMB_PAL1, a
            jr .endIf_A
        .else_A:
            ld a, [de]
        .endIf_A:
        
        ; Adjust priority depending on screen
        ld [hl], a
        ld a, [samus_screenSpritePriority]
        and a
        jr nz, .endIf_B
            ld a, [hl]
            set OAMB_PRI, a
            ld [hl], a
        .endIf_B:
        
        ; Adjust indeces for next loop iteration
        inc hl
        ld a, l
        ldh [hOamBufferIndex], a
        inc de
    jr .spriteLoop
    .exit:
ret ;}

clearUnusedOamSlots: ;{ 01:4BB3
    ; Compare max index of previous and current frames
    ldh a, [hOamBufferIndex]
    ld b, a
    ld a, [maxOamPrevFrame]
    ld c, a
    cp b
    ; Jump ahead if we used more sprites on the current frame
    jr c, .endIf
        ; If the previous frame used more sprites, then clear those sprites out
        ld h, HIGH(wram_oamBuffer)
        ldh a, [hOamBufferIndex]
        ld l, a
        ; Loop until we reach the max index from the previous frame
        .loop:
            xor a
            ld [hl+], a
            ld a, l
            cp c
        jr c, .loop
    .endIf:
    ; Update max index
    ldh a, [hOamBufferIndex]
    ld [maxOamPrevFrame], a
ret ;}

clearAllOam: ;{ 00:4BCE
    ; Write 0 to all OAM data
    ld hl, wram_oamBuffer
    .clearLoop:
        xor a
        ld [hl+], a
        ld a, l
        cp OAM_MAX
    jr c, .clearLoop
ret ;}

; Draw Samus function and sub-routines {

; Function has two entry points (one ignores invulnerability frame blinking)
drawSamus: ;{ 01:4BD9 Draw Samus
; Entry point 1
    ; Check if damage frames are active
    ld a, [samusInvulnerableTimer]
    and a
    jr z, .endIf_A
        dec a
        ld [samusInvulnerableTimer], a
        ; 4 frames on, 4 frames off
        ldh a, [frameCounter]
        bit 2, a
            ret z
    .endIf_A:
    
    ; Check if touching acid
    ld a, [acidContactFlag]
    and a
    jr z, .endIf_B
        ; 4 frames on, 4 frames off
        ldh a, [frameCounter]
        bit 2, a
            ret z
    .endIf_B:

.ignoreDamageFrames ; 01:4BF3 - Entry point 2
    ld a, [samusPose]
    bit 7, a
        jp nz, drawSamus_faceScreen

    ; Convert facing direction into a dummy input
    ; (Note: nybbles are swapped for array-indexing purposes)
    ld b, $01 ; Right
    ld a, [samusFacingDirection]
    and a
    jr nz, .endIf_C
        ld b, $02 ; Left
    .endIf_C:

    ; Check if cutsence is active (e.g. a metroid is transforming)
    ld a, [cutsceneActive]
    and a
    jr z, .else_D
        ; Load dummy input to temp
        ld a, b
        ldh [hTemp.a], a
        jr .endIf_D
    .else_D:
        ; Load input into temp variable
        ldh a, [hInputPressed]
        and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
        swap a ; Swap nybbles for array-indexing purposes
        ; OR the dummy input into the temp variable as well
        or b
        ldh [hTemp.a], a
    .endIf_D:
    
    ; Jump to the appropriate draw routine
    ld a, [samusPose]
    rst $28
        dw drawSamus_standing   ; $00 - Standing
        dw drawSamus_jump       ; $01 - Jumping
        dw drawSamus_spinJump   ; $02 - Spin-jumping
        dw drawSamus_run        ; $03 - Running (set to 83h when turning)
        dw drawSamus_crouch     ; $04 - Crouching
        dw drawSamus_morph      ; $05 - Morphball
        dw drawSamus_morph      ; $06 - Morphball jumping
        dw drawSamus_jump       ; $07 - Falling
        dw drawSamus_morph      ; $08 - Morphball falling
        dw drawSamus_jumpStart  ; $09 - Starting to jump
        dw drawSamus_jumpStart  ; $0A - Starting to spin-jump
        dw drawSamus_spider     ; $0B - Spider ball rolling
        dw drawSamus_spider     ; $0C - Spider ball falling
        dw drawSamus_spider     ; $0D - Spider ball jumping
        dw drawSamus_spider     ; $0E - Spider ball
        dw drawSamus_knockback  ; $0F - Knockback
        dw drawSamus_morph      ; $10 - Morphball knockback
        dw drawSamus_knockback  ; $11 - Standing bombed
        dw drawSamus_morph      ; $12 - Morphball bombed
        dw drawSamus_faceScreen ; $13 - Facing screen
        dw drawSamus_faceScreen ; $14   
        dw drawSamus_faceScreen ; $15   
        dw drawSamus_faceScreen ; $16   
        dw drawSamus_faceScreen ; $17   
        dw drawSamus_morph      ; $18 - Being eaten by Metroid Queen
        dw drawSamus_morph      ; $19 - In Metroid Queen's mouth
        dw drawSamus_morph      ; $1A - Being swallowed by Metroid Queen
        dw drawSamus_morph      ; $1B - In Metroid Queen's stomach
        dw drawSamus_morph      ; $1C - Escaping Metroid Queen
        dw drawSamus_morph      ; $1D - Escaped Metroid Queen
;}

drawSamus_knockback: ;{ 01:4C59 - $0F, $11: Knockback
    ; Index = facing direction
    ld d, $00
    ld a, [samusFacingDirection]
    ld e, a
    ld hl, .knockbackTable
    add hl, de
    ; Load sprite
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.knockbackTable: ; 02:4C69
    db $16, $09
;}

drawSamus_spider: ;{ 01:4C6B - $0B-$0E: Spider Ball
    ; Multiply facing direction by 4
    ld a, [samusFacingDirection]
    and $01
    sla a
    sla a
    ld b, a
    ; Get animation frame
    ld a, [samus_spinAnimationTimer]
    and %00001100 ; $0C
    srl a
    srl a
    ; Index into table
    add b
    ld e, a
    ld d, $00
    ; Load sprite ID
    ld hl, .spiderTable
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.spiderTable: ; 02:4C8C
    db $37, $38, $39, $3a ; Left
    db $3b, $3c, $3d, $3e ; Right
;}

drawSamus_morph: ;{ 01:4C94 - Morph poses
    ; Get sub-table depending on facing direction
    ld a, [samusFacingDirection]
    and $01
    sla a
    sla a
    ld b, a
    ; Get index into table
    ld a, [samus_spinAnimationTimer]
    and %00001100 ; $0C
    srl a
    srl a
    add b
    ld e, a
    ld d, $00
    ; Load sprite index from table
    ld hl, .morphTable
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.morphTable: ; 01:4CB5
    db $1e, $1f, $20, $21 ; Left
    db $26, $27, $28, $29 ; Right
;}

drawSamus_jump: ;{ 01:4CBD - $01, $07: Jumping and falling
    ; Index into table using input + facing direction
    ld d, $00
    ldh a, [hTemp.a]
    ld e, a
    ld hl, jumpSpriteTable
    add hl, de
    ; Get sprite ID
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common ;}

drawSamus_jumpStart: ;{ 01:4CCC - $09, $0A: Jump Start
    ld a, $03 ; Right
    ldh [hSpriteId], a
    ld a, [samusFacingDirection]
    and a
        jp nz, drawSamus_common
    ld a, $10 ; Left
    ldh [hSpriteId], a
jp drawSamus_common ;}

jumpSpriteTable: ; 01:4CDE
; Value read is based on input and facing direction
;                                U    U              D    D
;       x    R    L    x    U    R    L    x    D    R    L    x    x    x    x    x
    db $00, $09, $16, $00, $00, $0a, $17, $00, $00, $0c, $19, $00, $00, $00, $00, $00

drawSamus_spinJump: ;{ 01:4CEE - $02: Spin jump
    ld a, [samusFacingDirection]
    and a
    jp z, .else
        ld hl, .spinRightTable
        jp .endIf
    .else:
        ld hl, .spinLeftTable
    .endIf:

    ; Spin fast if we have either space jump or screw attack
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    jr nz, .spinFast
        ; Slow spin
        ; Get index into table
        ld a, [samus_spinAnimationTimer]
        srl a
        and %00001100
        srl a
        srl a
        ld e, a
        ld d, $00
        add hl, de
        ; Load sprite ID
        ld a, [hl]
        ldh [hSpriteId], a
        jp drawSamus_common
    .spinFast:
        ; Get index into table
        ld a, [samus_spinAnimationTimer]
        srl a
        and %00000011
        ld e, a
        ld d, $00
        add hl, de
        ; Load sprite ID
        ld a, [hl]
        ldh [hSpriteId], a
        jp drawSamus_common

; Spin tables
.spinRightTable: ; 01:4D2B
    db $1A, $1B, $1C, $1D ; Right
.spinLeftTable: ; 01:4D2F
    db $22, $23, $24, $25 ; Left
;}

drawSamus_faceScreen: ;{ 00:4D33 - $13-$17: Facing the screen
    ; Fade-in logic
    ld a, [countdownTimerLow]
    and a
    jr z, .endIf
        ; Skip rendering 1 out of 4 frames
        ldh a, [frameCounter]
        and $03
        ret z
    .endIf:
    ; Load sprite ID
    ld a, $00
    ldh [hSpriteId], a
jp drawSamus_common ;}

drawSamus_standing: ;{ $00: Standing
    ; Index into table using input + facing direction
    ld d, $00
    ldh a, [hTemp.a]
    ld e, a
    ld hl, .standingTable
    add hl, de
    ; Load sprite ID
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.standingTable: ; 01:4D54
; Value read is based on input and facing direction
;                                U    U              D    D
;       x    R    L    x    U    R    L    x    D    R    L    x    x    x    x    x
    db $00, $01, $0e, $00, $00, $02, $0f, $00, $00, $01, $0e, $00, $00, $00, $00, $00, $00
;}

drawSamus_crouch: ;{ $04 - Crouching
    ld a, $0b ; Right
    ldh [hSpriteId], a
    ld a, [samusFacingDirection]
    and a
        jp nz, drawSamus_common
    ld a, $18 ; Left
    ldh [hSpriteId], a
jp drawSamus_common ;}

drawSamus_run: ;{ 01:4D77 - $03: Running
    ; Clamp run animation counter so it never equals or exceeds $30
    ld a, [samus_animationTimer]
    cp $30
    jr c, .endIf_A
        xor a
        ld [samus_animationTimer], a
    .endIf_A:

    ; Play stepping sound
    ld a, [samus_animationTimer]
    and $07
    jr nz, .endIf_B
        ; Don't interrupt currently playing sounds
        ld a, [sfxRequest_noise]
        and a
        jr nz, .endIf_B
            ld a, $10
            ld [sfxRequest_noise], a
    .endIf_B:

    ; Get index into table
    ;  Multiply facing direction by 4 to get the pertinent sub-table
    ld a, [samusFacingDirection]
    and $01
    sla a
    sla a
    ld b, a
    ; Convert run animation timer to table index
    ld a, [samus_animationTimer]
    and $30
    swap a
    add b
    ld e, a
    ld d, $00

    ; Get base address of table
    ld hl, .runningTableNormal
    ldh a, [hInputPressed]
    bit PADB_UP, a
    jr z, .else_C
        ld hl, .runningTableAimingUp
        jr .endIf_C
    .else_C:
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr z, .endIf_C
            ld hl, .runningTableShooting
    .endIf_C:
    add hl, de

    ; Load sprite ID
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

; The fourth frame in these tables is just padding
.runningTableNormal: ; 01:4DC7 - Normal
    db $10, $11, $12, $00 ; Left
    db $03, $04, $05, $00 ; Right
.runningTableShooting: ; 01:4DCF - Firing forwards
    db $13, $14, $15, $00 ; Left
    db $06, $07, $08, $00 ; Right
.runningTableAimingUp: ; 01:4DD7 - Aiming up
    db $2e, $2f, $30, $00 ; Left
    db $2b, $2c, $2d, $00 ; Right
;}

; All the above drawSamus procedures jump here
drawSamus_common: ;{ 01:4DDF
    ; Load sprite priority bit
    call loadScreenSpritePriorityBit

    ; Set x pos
    ldh a, [hCameraXPixel]
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    ldh [hSpriteXPixel], a
    ld [samus_onscreenXPos], a
    ; Set y pos
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $62
    ldh [hSpriteYPixel], a
    ld [samus_onscreenYPos], a

    ; Set the sprite attribute
    xor a
    ldh [hSpriteAttr], a

    ; If in contact with acid or being hurt, set attribute byte to non-zero
    ld a, [acidContactFlag]
    and a
    jr nz, .then
        ld a, [samusInvulnerableTimer]
        and a
        jr z, .endIf
    .then: ; I'd use else here, but these branches aren't mutually exclusive
        ld a, $01
        ldh [hSpriteAttr], a
    .endIf:
    
    ; Adjust y position
    call drawSamus_earthquakeAdjustment
    ; Draw Samus herself
    call drawSamusSprite
    
    ; Clear variables
    xor a
    ldh [hSpriteAttr], a
    ld [samus_screenSpritePriority], a
ret ;}
;}

;------------------------------------------------------------------------------
; New game
; - Transfers initial savegame from ROM to save buffer in WRAM
createNewSave: ;{ 01:4E1C
    ; Clear flag
    xor a
    ld [loadingFromFile], a
    
    ; Copy initial save file to save buffer
    ld hl, initialSaveFile
    ld de, saveBuffer
    ld b, $26
    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .loadLoop
    
    ; Set game mode
    ld a, $02 ; "gameMode_LoadA"
    ldh [gameMode], a
ret ;}

; Copies savegame from SRAM to save buffer in WRAM
loadSaveFile: ;{ 01:4E33
    ; Double check to make sure we're loading from a file
    ;  (this is supposed to be set if we're here)
    ld a, [loadingFromFile]
    and a
        jr z, createNewSave

    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    
    ; HL = saveData_baseAddr + activeSaveSlot*64
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    add $08
    ld l, a
    ld h, HIGH(saveData_baseAddr)
    
    ; Copy save file to save buffer
    ld de, saveBuffer
    ld b, $26
    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .loadLoop

    ; Disable SRAM
    ld a, $00
    ld [$0000], a
    
    ; Load the save flags for enemies
    call loadEnemySaveFlags_longJump ; Indirect call to 01:7AB9 (in this same bank!)
    
    ld a, $02 ; for "gameMode_LoadA"
    ldh [gameMode], a
ret ;}

;------------------------------------------------------------------------------
; Initial savegame
initialSaveFile: ; 01:4E64
include "data/initialSave.asm"

; Samus projectile and bomb functions/tables {

samusShoot: ;{ 01:4E8A
    ; Fire if the B button was just pressed
    ldh a, [hInputRisingEdge]
    bit PADB_B, a
    jr nz, .endIf_A
        ; Or, check if the B button is being held
        ldh a, [hInputPressed]
        bit PADB_B, a
            ret z
        ; Increment the cooldown counter
        ld a, [samusBeamCooldown]
        inc a
        ld [samusBeamCooldown], a
        ; Exit if less than $10
        cp $10
            ret c
    .endIf_A:

.spazerLoop: ; Loop point for firing all three spazer beams
    ; Exit if in turnaround animation
    ld a, [samusPose]
    bit 7, a
        ret nz
    
    ; Load possible shot directions for the current pose
    ld hl, samus_possibleShotDirections
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ; Exit if no shooting is permitted
    and a
        ret z
    ; Branch if it's a bomb-laying pose
    cp $80
        jp z, samus_layBomb
    ; Save table entry to B
    ld b, a
    
    ; Clear beam cooldown
    xor a
    ld [samusBeamCooldown], a
    
; Determine beam firing direction
    ; AND input bits with permitted direction
    ldh a, [hInputPressed]
    swap a
    and b
    jr nz, .else_B
        ; If no bits match, set firing direction to facing direction
        ld c, $01 ; Right
        ld a, [samusFacingDirection]
        and a
        jr nz, .endIf_B
            ld c, $02 ; Left
            jr .endIf_B
    .else_B:
        ; If bits match, get the direction based on this table
        ld hl, samus_shotDirectionPriorityTable
        ld e, a
        ld d, $00
        add hl, de
        ld a, [hl]
        ld c, a
    .endIf_B:
    ; Save firing direction to temp
    ld a, c
    ldh [hTemp.b], a

; Get Y offset
    ; Load the Y offset of Samus's cannon for her current pose
    ld hl, samus_cannonYOffsetByPose
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld b, a
    ; Load the Y offset of the cannon for her current aiming direction
    ld hl, samus_cannonYOffsetByAimDirection
    ld a, c
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ; Add the two Y offsets
    add b
    ; Make adjustment
    sub $04
    ; Save Y result to temp and the B register
    ld b, a
    ldh [hTemp.c], a

; Get X offset
    ; samus_cannonXOffsetTable[firingDirection*2 + samusFacingDirection]
    ld hl, samus_cannonXOffsetTable
    sla c ; Multiply firing direction by 2
    ld a, [samusFacingDirection]
    add c
    ; Restore firing direction to its unmultiplied value
    srl c
    ; Load X offset
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ; Make adjustment
    sub $04
    ; Save X result to temp
    ldh [hTemp.a], a
    
    ; Take a separate branch if using plasma
    ld a, [samusActiveWeapon]
    cp $04 ; Plasma
        jp z, .plasmaBranch
    
    ; Unsure why .spazerLoop: is not here
    
    ; Projectile slot is returned in HL
    call getFirstEmptyProjectileSlot
    ; Exit if past the last projectile slot
    ld a, l
    swap a
    cp (projectileArray.end >> 4) & $0F ; $03
        ret z
    
    ; Check if using missiles
    ld a, [samusActiveWeapon]
    cp $08 ; Missiles
    jr nz, .endIf_C
        ; If so, check if we have any missiles
        ld a, [samusCurMissilesLow]
        ld b, a
        ld a, [samusCurMissilesHigh]
        or b
        jr nz, .endIf_D
            ; If not, play sound effect and exit
            ld a, $19
            ld [sfxRequest_square1], a
            ret
        .endIf_D:
        ; Decrement missile count
        ld a, [samusCurMissilesLow]
        sub $01
        daa
        ld [samusCurMissilesLow], a
        ld a, [samusCurMissilesHigh]
        sbc $00
        daa
        ld [samusCurMissilesHigh], a
    .endIf_C:
    
; Save weapon
    ; Write weapon type
    ld a, [samusActiveWeapon]
    ld [hl+], a
    ; Write direction
    ldh a, [hTemp.b]
    ld [hl+], a
    ; Write y position
    ldh a, [hTemp.c]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [hl+], a
    ; Write x position
    ldh a, [hTemp.a]
    ld b, a
    ldh a, [hSamusXPixel]
    add b
    ld [hl+], a
    ; Write wave index
    ldh a, [frameCounter]
    and $10
    srl a
    ld [hl+], a
    ; Write frame counter
    xor a
    ld [hl], a
    
    ; Check if using Spazer
    ld a, [samusActiveWeapon]
    cp $03 ; Spazer
    jr nz, .endIf_E
        ; If so, loop back around if not past the last projectile slot
        ld a, l
        cp LOW(projectileArray.slotC) ; $20
        jp c, .spazerLoop
    .endIf_E:
    
    ; Load beam sound from table
    ld hl, beamSoundTable
    ld a, [samusActiveWeapon]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [sfxRequest_square1], a
ret

.plasmaBranch: ;{ Plasma case
    ; Exit if first slot is active
    ld hl, projectileArray
    ld a, [hl]
    cp $ff
        ret nz

    .plasmaLoop:
        ; Check if direction is horizontal or vertical
        ldh a, [hTemp.b]
        cp $04
        jr nc, .else_F
            ; If horizontal, adjust x position
            ; Subtract 8 from the x position
            ldh a, [hTemp.a]
            sub $08
            ldh [hTemp.a], a
            ; Add $10 to x position if this is the first slot
            ld a, l
            and a
            jr z, .endIf_F
                ldh a, [hTemp.a]
                add $10
                ldh [hTemp.a], a
                jr .endIf_F
        .else_F:
            ; If vertical, adjust y position
            ; Subtract 8 from the y position
            ldh a, [hTemp.c]
            sub $08
            ldh [hTemp.c], a
            ; Add $10 to y position if this is the first slot
            ld a, l
            and a
            jr z, .endIf_F
                ldh a, [hTemp.c]
                add $10
                ldh [hTemp.c], a
        .endIf_F:
        
    ; Save weapon
        ; Save weapon type
        ld a, [samusActiveWeapon]
        ld [hl+], a
        ; Save direction
        ldh a, [hTemp.b]
        ld [hl+], a
        ; Save y position
        ldh a, [hTemp.c]
        ld b, a
        ldh a, [hSamusYPixel]
        add b
        ld [hl+], a
        ; Save x position
        ldh a, [hTemp.a]
        ld b, a
        ldh a, [hSamusXPixel]
        add b
        ld [hl+], a
        ; Save wave index (?)
        ldh a, [frameCounter]
        and $10
        srl a
        ld [hl+], a
        ; Save frame counter
        xor a
        ld [hl], a
        
        ; Iterate to next beam slot
        ld a, l
        and $f0
        add $10
        ld l, a
        ; Exit loop if past the last slot
        cp $30
    jp c, .plasmaLoop
    
    ; Load beam sound from table
    ld hl, beamSoundTable
    ld a, [samusActiveWeapon]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [sfxRequest_square1], a
ret ;}
;} end of samusShoot

beamSoundTable: ;{ 01:4FE5
    db $07 ; 0: Normal
    db $09 ; 1: Ice
    db $16 ; 2: Wave
    db $0B ; 3: Spazer
    db $0A ; 4: Plasma
    db $07 ; 5: x
    db $07 ; 6: x
    db $07 ; 7: x
    db $08 ; 8: Missile
;}

getFirstEmptyProjectileSlot: ;{ 01:4FEE
    ; Init HL
    ld hl, projectileArray
    ; Missiles only use the last slot
    ld a, [samusActiveWeapon]
    cp $08
    jr nz, .endIf
        ld a, (projectileArray.slotC >> 4) & $0F ;$02
        swap a
        ld l, a
    .endIf
    
    ; Loop to find first open slot
    .loop:
        ; Exit if slot is open
        ld a, [hl]
        cp $ff
            ret z
        ; Iterate to next slot
        ld de, $0010
        add hl, de
        ; Exit if at the end of the slots
        ld a, l
        swap a
        cp (projectileArray.end >> 4) & $0F ; $03
    jr nz, .loop
ret ;}

;------------------------------------------------------------------------------
; Beam handler
handleProjectiles: ;{ 01:500D
    ; Initialize the projectile index
    xor a
    ld [projectileIndex], a

.bigLoop: ; Loop back to here for each projectile
    ; Get the address for the current projectile
    ld a, HIGH(projectileArray) ; $DD
    ld h, a
    ldh [hBeam_pHigh], a
    ld a, [projectileIndex]
    swap a
    ld l, a
    ldh [hBeam_pLow], a
    
    ; Load projectile type
    ld a, [hl+]
    ldh [hBeam_type], a
    ld [weaponType], a
    ; Skip to next projectile if beam is inactive
    cp $ff
        jp z, .nextProjectile
        
    ; Load direction
    ld a, [hl+]
    ldh [hTemp.a], a
    ld [weaponDirection], a
    ; Load y position
    ld a, [hl+]
    ldh [hTemp.b], a
    ; Load x position
    ld a, [hl+]
    ldh [hTemp.c], a
    ; Load wave index
    ld a, [hl+]
    ldh [hBeam_waveIndex], a
    ; Load and increment frame counter
    ld a, [hl+]
    inc a
    ldh [hBeam_frameCouter], a
    
    ; Branch according to beam type
    ldh a, [hBeam_type]
    cp $02 ; Wave
        jp z, .waveBranch
    cp $03 ; Spazer
        jr z, .spazerBranch
    cp $08 ; Missile
        jp z, .missileBranch
    jp .defaultBranch ; Default projectile (ice, power, plasma)

.spazerBranch: ;{ Spazer
    ; Act based on direction
    ldh a, [hTemp.a]
    ; Right
    bit 0, a
    jr z, .endIf_A
        call .spazer_splitVertically
        ; Move, adjusting for camera speed
        ldh a, [hTemp.c]
        add $04
        ld hl, camera_speedRight
        add [hl]
        ldh [hTemp.c], a
        jr .spazerEnd
    .endIf_A:
        
    ; Left
    bit 1, a
    jr z, .endIf_B
        call .spazer_splitVertically
        ; Move, adjusting for camera speed
        ldh a, [hTemp.c]
        sub $04
        ld hl, camera_speedLeft
        sub [hl]
        ldh [hTemp.c], a
        jr .spazerEnd
    .endIf_B:

    ; Up
    bit 2, a
    jr z, .endIf_C
        call .spazer_splitHorizontally
        ; Move, adjusting for camera speed
        ldh a, [hTemp.b]
        sub $04
        ld hl, camera_speedUp
        sub [hl]
        ldh [hTemp.b], a
        jr .spazerEnd
    .endIf_C:

    ; Down
    ; Default case (bit 3, a)
        call .spazer_splitHorizontally
        ; Move, adjusting for camera speed
        ldh a, [hTemp.b]
        add $04
        ld hl, camera_speedDown
        add [hl]
        ldh [hTemp.b], a
        
    .spazerEnd:
jp .commonBranch

.spazer_splitVertically: ;{ Spazer subroutine
    ; Limit spread to first few frames
    ldh a, [hBeam_frameCouter]
    cp $05
        ret nc
    ; Middle beam doesn't move sideways
    ld a, l
    and $f0
    cp LOW(projectileArray.slotB) ; $10
        ret z
    ; Check if 1st or 3rd beam
    cp LOW(projectileArray.slotA) ; $00
    jr nz, .else_D
        ; First beam moves up
        ldh a, [hTemp.b]
        sub $02
        ldh [hTemp.b], a
        ret
    .else_D:
        ; Third beam moves down
        ldh a, [hTemp.b]
        add $02
        ldh [hTemp.b], a
        ret
;} end proc

.spazer_splitHorizontally: ;{ Spazer subroutine
    ; Limit spread to first few frames
    ldh a, [hBeam_frameCouter]
    cp $05
        ret nc
    ; Middle beam doesn't move sideways
    ld a, l
    and $f0
    cp LOW(projectileArray.slotB) ; $10
        ret z
    ; Check if 1st or 3rd beam
    cp LOW(projectileArray.slotA) ; $00
    jr nz, .else_E
        ; First beam moves left
        ldh a, [hTemp.c]
        sub $02
        ldh [hTemp.c], a
        ret
    .else_E:
        ; Third beam moves right
        ldh a, [hTemp.c]
        add $02
        ldh [hTemp.c], a
        ret
;} end proc
;} end Spazer case

.waveBranch: ;{ Wave
    ; Read from wave tranverse velocity table
    .waveLoop:
        ld hl, .waveSpeedTable
        ldh a, [hBeam_waveIndex]
        ld e, a
        ld d, $00
        add hl, de
        ld a, [hl]
        ; Reset to beginning of table if value is $80
        cp $80
            jr nz, .break
        xor a
        ldh [hBeam_waveIndex], a
    jr .waveLoop
    .break:
    ld b, a ; Save result from table

    ; Check direction
    ldh a, [hTemp.a]
    and %1100 ; $0C ; Check if moving vertically
    jr nz, .else_F
        ; Horizontal case
        ; Adjust vertical position of wave
        ldh a, [hTemp.b]
        add b
        ldh [hTemp.b], a
        ; Increment wave index
        ldh a, [hBeam_waveIndex]
        inc a
        ldh [hBeam_waveIndex], a
        ; Check direction
        ldh a, [hTemp.a]
        bit 1, a
        jr nz, .else_G
            ; Move right
            ldh a, [hTemp.c]
            add $02
            ld hl, camera_speedRight ; Adjust for camera velocity
            add [hl]
            ldh [hTemp.c], a
            jr .endIf_F
        .else_G:
            ; Move left
            ldh a, [hTemp.c]
            sub $02
            ld hl, camera_speedLeft ; Adjust for camera velocity
            sub [hl]
            ldh [hTemp.c], a
            jr .endIf_F
    
    .else_F:
        ; Vertical case
        ; Adjust horizontal position of wave
        ldh a, [hTemp.c]
        add b
        ldh [hTemp.c], a
        ; Increment wave index
        ldh a, [hBeam_waveIndex]
        inc a
        ldh [hBeam_waveIndex], a
        ; Check direction
        ldh a, [hTemp.a]
        bit 2, a
        jr nz, .else_H
            ; Move down
            ldh a, [hTemp.b]
            add $02
            ld hl, camera_speedDown ; Adjust for camera velocity
            add [hl]
            ldh [hTemp.b], a
            jr .endIf_F
        .else_H:
            ; Move up
            ldh a, [hTemp.b]
            sub $02
            ld hl, camera_speedUp ; Adjust for camera velocity
            sub [hl]
            ldh [hTemp.b], a
    .endIf_F:

    ; Save wave beam projectile to WRAM
    ; Get WRAM pointer for current projectile
    ldh a, [hBeam_pLow]
    ld l, a
    ldh a, [hBeam_pHigh]
    ld h, a
    inc hl
    inc hl
    ; Save Y position
    ldh a, [hTemp.b]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [tileY], a
    ; Save X position
    ldh a, [hTemp.c]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [tileX], a
    ; Save wave index
    ldh a, [hBeam_waveIndex]
    ld [hl], a
    
    ; Only check background collision every other frame
    ldh a, [frameCounter]
    and $01
        jp z, .checkEnemies
    
    ; Check background collision
    call getTileIndex.projectile
    ; Check if solid to beams
    ld hl, beamSolidityIndex
    cp [hl]
        jp nc, .checkEnemies ; Block not solid to beams
    
    ; Check if block is destructible
    ; Tiles $00-$03 are hardcoded as respawning blocks
    cp $04
    jr nc, .else_I
        call destroyRespawningBlock
        jp .nextProjectile
    .else_I:
        ; Check if block type is shot
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_shot, a
        jp z, .nextProjectile
            ld a, $ff ; Unnecessarily setting the tile to write
            call destroyBlock
        jp .nextProjectile
; end case

.waveSpeedTable: ; 01:5183 - Wave speed table (transverse velocity)
    db $00, $07, $05, $02, $00, $fe, $fb, $f9, $00, $f9, $fb, $fe, $00, $02, $05, $07
    db $80

.waveSpeedTable_alt: ; 01:5194 - Unused (alternate wave table -- motion blur makes it looks very spazer-like)
    db $0A, $F6, $F6, $0A, $0A, $F6, $F6, $0A, $0A, $F6, $F6, $0A, $80
;}

.missileSpeedTable: ; 01:51A1 - Missile speed table (first value in array is unused)
    db $00, $00, $01, $00, $00, $01, $00, $01, $00, $01, $00, $01, $01, $01, $01, $02
    db $01, $02, $01, $02, $02, $02, $02, $03, $02, $02, $03, $02, $03, $03, $03, $03
    db $04, $FF
.missileSpeedTable_end:

.missileBranch: ;{ Missile
    ; Use projectile frame counter as index into table
    ldh a, [hBeam_frameCouter]
    ld e, a
    ld d, $00
    ld hl, .missileSpeedTable
    add hl, de
    ld a, [hl]
    ; Check if at the end of the table
    cp $ff
    jr nz, .endif_J
        ; Decrement value so it doesn't overflow on the next tick
        ldh a, [hBeam_frameCouter]
        dec a
        ldh [hBeam_frameCouter], a
        ; Load second to last value from table
        ld a, [.missileSpeedTable_end - 2]
    .endif_J:
    ld b, a ; Save speed to B
    
    ; Handle directions
    ldh a, [hTemp.a]
    bit 0, a
    jr z, .endif_K
        ; Go right
        ldh a, [hTemp.c]
        add b
        ld hl, camera_speedRight
        add [hl]
        ldh [hTemp.c], a
        jp .commonBranch
    .endif_K:
    
    bit 1, a
    jr z, .endif_L
        ; Go left
        ldh a, [hTemp.c]
        sub b
        ld hl, camera_speedLeft
        sub [hl]
        ldh [hTemp.c], a
        jp .commonBranch
    .endif_L:
    
    bit 2, a
    jr z, .endif_M
        ; Go up
        ldh a, [hTemp.b]
        sub b
        ld hl, camera_speedUp
        sub [hl]
        ldh [hTemp.b], a
        jr .commonBranch
    .endif_M:

    ; bit 3, a
        ; Go down
        ldh a, [hTemp.b]
        add b
        ld hl, camera_speedDown
        add [hl]
        ldh [hTemp.b], a
        jr .commonBranch
;} End missile case

.defaultBranch: ;{ Default projectile
    ; Handle directions
    ldh a, [hTemp.a]
    bit 0, a
    jr z, .endIf_N
        ; Move right
        ldh a, [hTemp.c]
        add $04 ; Plasma speed
        ld hl, camera_speedRight ; Adjust for camera
        add [hl]
        ldh [hTemp.c], a
        ; Check if Plasma beam
        ldh a, [hBeam_type]
        cp $04
        jr nz, .commonBranch
            ldh a, [hTemp.c]
            add $02 ; Default speed
            ldh [hTemp.c], a
            jr .commonBranch
    .endIf_N:
    
    bit 1, a
    jr z, .endIf_O
        ; Move left
        ldh a, [hTemp.c]
        sub $04 ; Plasma speed
        ld hl, camera_speedLeft
        sub [hl]
        ldh [hTemp.c], a
        ; Check if Plasma beam
        ldh a, [hBeam_type]
        cp $04
        jr nz, .commonBranch
            ldh a, [hTemp.c]
            sub $02 ; Default speed
            ldh [hTemp.c], a
            jr .commonBranch
    .endIf_O:
        
    bit 2, a
    jr z, .endIf_P
        ; Move up
        ldh a, [hTemp.b]
        sub $04 ; Plasma speed
        ld hl, camera_speedUp
        sub [hl]
        ldh [hTemp.b], a
        ; Check if Plasma beam
        ldh a, [hBeam_type]
        cp $04
        jr nz, .commonBranch
            ldh a, [hTemp.b]
            sub $02 ; Default speed
            ldh [hTemp.b], a
            jr .commonBranch
    .endIf_P:
    
    ; bit 3, a
        ; Move down
        ldh a, [hTemp.b]
        add $04 ; Plasma speed
        ld hl, camera_speedDown
        add [hl]
        ldh [hTemp.b], a
        ; Check if Plasma beam
        ldh a, [hBeam_type]
        cp $04
        jr nz, .commonBranch
            ldh a, [hTemp.b]
            add $02 ; Default speed
            ldh [hTemp.b], a
    ; Fall through to .commonBranch
;} end normal beam case

.commonBranch: ; Common projectile code
    ; HL = WRAM address of working projectile
    ldh a, [hBeam_pLow]
    ld l, a
    ldh a, [hBeam_pHigh]
    ld h, a
    inc hl
    inc hl
    
    ; Save Y
    ldh a, [hTemp.b]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [tileY], a
    
    ; Save X
    ldh a, [hTemp.c]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [tileX], a
    
    ; Save wave index
    ldh a, [hBeam_waveIndex]
    ld [hl+], a
    ; Save projectile frame counter
    ldh a, [hBeam_frameCouter]
    ld [hl], a
    
    ; Only check BG collision every other frame
    ldh a, [frameCounter]
    and $01
    jr z, .else_Q
        ; Perform BG collision
        call getTileIndex.projectile
        ; Skip ahead if tile is intangible to beams
        ld hl, beamSolidityIndex
        cp [hl]
        jr nc, .else_Q
            ; Tiles $00-$03 are hardcoded as respawning blocks
            cp $04
            jr nc, .else_R
                call c, destroyRespawningBlock
                jr .endIf_R
            .else_R:
                ; Check if block type is shot
                ld h, HIGH(collisionArray)
                ld l, a
                ld a, [hl]
                bit blockType_shot, a
                jp z, .endIf_R
                    ld a, $ff ; Unnecessarily setting the tile to write
                    call destroyBlock
            .endIf_R:
            
            ; Special cases for different beam types
            ldh a, [hBeam_type]
            cp $07 ; Bomb beam
                call z, bombBeam_layBomb
            
            ; This gives the spazer/plasma beam the wall-clip property
            cp $03 ; Spazer
                jr z, .nextProjectile
            cp $04 ; Plasma
                jr z, .nextProjectile
            
            ; Delete projectile (power, ice, missiles)
            ldh a, [hBeam_pLow]
            ld l, a
            ldh a, [hBeam_pHigh]
            ld h, a
            ; Set to inactive
            ld a, $ff
            ld [hl], a
            jr .endIf_Q
    .else_Q:
    
; Wave beam skips ahead to here
    .checkEnemies: ; Enemy processing
        call collision_projectileEnemies ; Projectile-enemy collision routine
        jr nc, .endIf_Q
            ; Delete projectile
            ld a, HIGH(projectileArray) ; $DD
            ld h, a
            ldh [hBeam_pHigh], a
            ld a, [projectileIndex]
            swap a
            ld l, a
            ; Set to inactive
            ld a, $ff
            ld [hl], a
    .endIf_Q:
    
    .nextProjectile: ; Next projectile
    ; Increment projectile index
    ld a, [projectileIndex]
    inc a
    ld [projectileIndex], a
    ; Exit if past the last projectile
    cp projectileArray.end >> 4 & $0F ; $03
    jp c, .bigLoop
ret ;}

; Draw projectiles
drawProjectiles: ;{ 01:5300
    ; Init projectile index
    ld a, $00
    ld [projectileIndex], a

    .projectileLoop:
        ; Convert index into pointer
        ld hl, projectileArray
        ld a, [projectileIndex]
        swap a
        ld e, a
        ld d, $00
        add hl, de
        
        ; Load weapon type to D, check if slot is used
        ld a, [hl+]
        ld d, a
        cp $ff
        jp z, .nextProjectile
            ; Load direction to C
            ld a, [hl+]
            ld c, a
            ; Load Y pos, adjust for camera
            ld a, [scrollY]
            ld b, a
            ld a, [hl+]
            sub b
            ldh [hSpriteYPixel], a
            ; Load X pos, adjust for camera
            ld a, [scrollX]
            ld b, a
            ld a, [hl]
            sub b
            ldh [hSpriteXPixel], a
            ; Set attribute
            xor a
            ldh [hSpriteAttr], a
            ; Check if missile
            ld a, d
            cp $08
            jr nz, .else_A
                ; Missile case
                push hl
                    ; Load sprite tile for direction
                    ld hl, .missileSpriteTileTable
                    ld a, c
                    ld e, a
                    ld d, $00
                    add hl, de
                    ld a, [hl]
                    ldh [hSpriteId], a
                    ; Load sprite attribute for direction
                    ld hl, .missileSpriteAttributeTable
                    ld a, c
                    ld e, a
                    ld d, $00
                    add hl, de
                    ld a, [hl]
                    ldh [hSpriteAttr], a
                pop hl
                jr .endIf_A
            .else_A:
                ; Beam case
                ld a, $7e ; Horizontal sprite
                ldh [hSpriteId], a
                ld a, c
                and %0011 ; Left or right
                jr nz, .endIf_A
                    ld a, $7f ; Vertical sprite
                    ldh [hSpriteId], a
            .endIf_A:
            
            ; Check if sprite is offscreen
            ldh a, [hSpriteXPixel]
            cp $08
            jr c, .else_B
                ldh a, [hSpriteXPixel]
                cp $a4
                jr nc, .else_B
                    ldh a, [hSpriteYPixel]
                    cp $0c
                    jr c, .else_B
                        ldh a, [hSpriteYPixel]
                        cp $94
                        jr nc, .else_B
                            ; Set HL to current top of OAM buffer
                            ld h, HIGH(wram_oamBuffer)
                            ldh a, [hOamBufferIndex]
                            ld l, a
                            ; Write the things
                            ldh a, [hSpriteYPixel]
                            ld [hl+], a
                            ldh a, [hSpriteXPixel]
                            ld [hl+], a
                            ldh a, [hSpriteId]
                            ld [hl+], a
                            ldh a, [hSpriteAttr]
                            ld [hl+], a
                            ; Update the OAM buffer index
                            ld a, l
                            ldh [hOamBufferIndex], a
                            ; Clear working sprite attribute (why?)
                            xor a
                            ldh [hSpriteAttr], a
                            jr .endIf_B
            .else_B:
                ; Abort rendering
                dec hl
                dec hl
                dec hl
                ; Delete projectile
                ld a, $ff
                ld [hl], a
            .endIf_B:
        .nextProjectile:
        ; Move on to next projectile if it exists
        ld a, [projectileIndex]
        inc a
        ld [projectileIndex], a
        cp (projectileArray.end >> 4 & $0F) ; $03
    jp c, .projectileLoop
ret

; 01:539D - Missile sprite table
.missileSpriteTileTable:
    ;        R    L         U                   D
    db $00, $98, $98, $00, $99, $00, $00, $00, $99
; 01:53A6 - Missile attribute table
.missileSpriteAttributeTable:
    ;        R    L         U                   D
    db $00, $00, $20, $00, $00, $00, $00, $00, $40
;}

;------------------------------------------------------------------------------
; Bomb stuff

; Bomb beam code
bombBeam_layBomb: ;{ 01:53AF
    ; Find first open bomb slot (if available)
    ld hl, bombArray
    .loop:
        ; Exit loop successfully if slot in inactive
        ld a, [hl]
        cp $ff
            jr z, .break
        ; Iterate to next slot
        ld de, $0010
        add hl, de
        ; Exit without laying a bomb if we're past the last slot
        ld a, l
        swap a
        cp bombArray.end >> 4 & $0F ; $06
    jr nz, .loop
        ret
    .break:

    ; Set bomb type
    ld a, $01
    ld [hl+], a
    ; Set timer
    ld a, $60
    ld [hl+], a
    ; Set y pos
    ldh a, [hTemp.b]
    add $04
    ld [hl+], a
    ; Set x pos
    ldh a, [hTemp.c]
    add $04
    ld [hl+], a
    ; Play sound
    ld a, $13
    ld [sfxRequest_square1], a
ret ;}

samus_layBomb: ;{ 01:53D9 - Lay bombs
    ; Exit if Samus doesn't have bombs
    ld a, [samusItems]
    bit itemBit_bomb, a
        ret z
    
    ; Exit if B was not just pressed
    ldh a, [hInputRisingEdge]
    bit PADB_B, a
        ret z
    
    ; Find first open bomb slot (if available)
    ld hl, bombArray
    .loop:
        ; Exit loop successfully if slot in inactive
        ld a, [hl]
        cp $ff
            jr z, .break
        ; Iterate to next slot
        ld de, $0010
        add hl, de
        ; Exit without laying a bomb if we're past the last slot
        ld a, l
        swap a
        cp $06
    jr nz, .loop
        ret ; Return without laying a bomb
    .break:

    ; Set bomb type
    ld a, $01
    ld [hl+], a
    ; Set timer
    ld a, $60
    ld [hl+], a
    ; Set ypos
    ldh a, [hSamusYPixel]
    add $26
    ld [hl+], a
    ; Set xpos
    ldh a, [hSamusXPixel]
    add $10
    ld [hl+], a
    ; Play sound
    ld a, $13
    ld [sfxRequest_square1], a
ret ;}

; Draw bombs and call collision functions upon explosion
drawBombs: ;{ 01:540E
    ; Init projectile index
    xor a
    ld [projectileIndex], a

    .bombLoop:
        ; Get address for current bomb
        ld hl, bombArray ; $dd30
        ld a, [projectileIndex]
        swap a
        add l
        ld l, a
        
        ; Load bomb type (skip ahead if inactive)
        ld a, [hl+]
        ldh [hTemp.a], a
        cp $ff
        jr z, .nextBomb
            ; Load timer to C
            ld a, [hl+]
            ld c, a
            
            ; Load bomb y pos and adjust to map space
            ld a, [scrollY]
            ld b, a
            ld a, [hl+]
            ld [bomb_mapYPixel], a
            sub b
            ldh [hSpriteYPixel], a
            
            ; Load bomb y pos and adjust to map space
            ld a, [scrollX]
            ld b, a
            ld a, [hl]
            ld [bomb_mapXPixel], a
            sub b
            ldh [hSpriteXPixel], a
            
            ; Check if horizontally onscreen
            ldh a, [hSpriteXPixel]
            cp $b0
            jr nc, .else_A
                ; Check if vertically onscreen
                ldh a, [hSpriteYPixel]
                cp $b0
                jr nc, .else_A
                    ; Check if a bomb or explosion
                    ldh a, [hTemp.a]
                    cp $01
                    jr nz, .else_B
                        ; Bomb case
                        ; Flicker between $35 and $36 every 8 frames
                        ld a, c
                        and $08
                        sla a
                        swap a
                        add $35
                        ldh [hSpriteId], a
                        ; Draw sprite
                        call drawSamusSprite
                        jr .nextBomb
                    .else_B:
                        ; Explosion case
                        ld a, c
                        cp $08
                        jr nz, .else_C
                            ; Fresh explosion
                            ; Try destroying blocks if not being eaten
                            ld a, [samusPose]
                            cp pose_beingEaten ; $18
                                call c, bombs_samusAndBGCollision
                            
                            ; SpriteId = Timer/2 + $31
                            ld a, c
                            srl a
                            add $31
                            ldh [hSpriteId], a
                            ; Draw sprite
                            call drawSamusSprite
                            
                            ; Do enemy collision
                            call collision_bombEnemies
                            
                            ; Play explosion sound
                            ld a, $0c
                            ld [sfxRequest_noise], a
                            jr .nextBomb
                        .else_C:
                            ; Not-fresh explosion
                            ; SpriteId = Timer/2 + $31
                            ld a, c
                            srl a
                            add $31
                            ldh [hSpriteId], a
                            ; Draw sprite
                            call drawSamusSprite
                            jr .nextBomb
            
            .else_A:
                ; Delete bomb
                dec hl
                dec hl
                dec hl
                ld a, $ff
                ld [hl], a        
        .nextBomb:
        
        ; Iterate to next bomb
        ld a, [projectileIndex]
        inc a
        ld [projectileIndex], a
        ; Exit if all bombs have been processed
        cp $03
    jp nz, .bombLoop
ret ;}

; Process timers and call other functions for bombs
handleBombs: ;{ 00:549D
    ; Init projectile index
    xor a
    ld [projectileIndex], a

    .bombLoop:
        ld hl, bombArray
        ld a, [projectileIndex]
        swap a
        add l
        ld l, a
        
        ; Load bomb type
        ld a, [hl+]
        ld b, a
        ; Skip to next bomb if inactive
        cp $ff
        jr z, .nextBomb
            ; Decrement timer
            ld a, [hl]
            dec a
            ld [hl], a
            ; Check if timer has reached zero
            jr nz, .nextBomb
                ; If so, check if it's a bomb or an explosion
                ld a, b
                cp $01
                jr z, .else
                    ; If it's an explosion, set it to inactive
                    dec hl
                    ld a, $ff
                    ld [hl], a
                    jr .nextBomb
                .else:
                    ; If it's a bomb, turn it into an explosion
                    dec hl
                    ld a, $02
                    ld [hl+], a
                    ld a, $08
                    ld [hl], a
        .nextBomb:
        
        ; Iterate to next bomb
        ld a, [projectileIndex]
        inc a
        ld [projectileIndex], a
        ; Exit if all bombs have been processed
        cp $03
    jr nz, .bombLoop

    call drawBombs
ret ;}

; Bombs - Destroy blocks
bombs_samusAndBGCollision: ;{ 01:54D7
    ; Save registers
    push bc
    push de
    push hl
    
    ; Check if Samus is in vertical range of bomb
    ldh a, [hSpriteYPixel]
    ld b, a
    ld a, [samus_onscreenYPos]
    sub $20
    cp b
    jr nc, .endIf_A
        ld a, [samus_onscreenYPos]
        add $20
        cp b
        jr c, .endIf_A
            ; Check if Samus in horizontal range of bomb
            ldh a, [hSpriteXPixel]
            ld b, a
            ld a, [samus_onscreenXPos]
            sub $10
            cp b
            jr nc, .endIf_A
                ld a, [samus_onscreenXPos]
                add $10
                cp b
                jr c, .endIf_A
                    ; Set damage boost direction
                    ; Default to left
                    ld c, $ff
                    ; Compare positions
                    ld a, [samus_onscreenXPos]
                    sub b
                    jr c, .endIf_B
                        ; Set to straight up
                        ld c, $00
                        jr z, .endIf_B
                            ; Set to right
                            ld c, $01
                    .endIf_B:
                    ld a, c
                    ld [samusAirDirection], a
                    
                    ; Set jump counter
                    ld a, $40
                    ld [samus_jumpArcCounter], a
                    
                    ; Set pose from table
                    ld a, [samusPose]
                    ld e, a
                    ld d, $00
                    ld hl, samus_bombPoseTable
                    add hl, de
                    ld a, [hl]
                    ld [samusPose], a
    .endIf_A:

    ; Set coordinates for top tile above
    ld a, [bomb_mapYPixel]
    sub $10
    ld [tileY], a
    ld a, [bomb_mapXPixel]
    ld [tileX], a
    ; Perform collision check
    call getTileIndex.projectile
    cp $04
    jr nc, .else_C
        ; Note: Tiles $00-$03 default to respawning blocks
        call destroyRespawningBlock
        jr .endIf_C
    .else_C:
        ; Check if tile type is bombable
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, .endIf_D
            ld a, $ff ; Unnecessarily setting the tile to write
            call destroyBlock
        .endIf_D:
    .endIf_C:

    ; Set coordinates for center tile
    ld a, [bomb_mapYPixel]
    ld [tileY], a
    ; Perform collision check
    call getTileIndex.projectile
    cp $04
    jr nc, .else_E
        call destroyRespawningBlock
        jr .endIf_E
    .else_E:
        ; Check if tile type is bombable
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, .endIf_F
            ld a, $ff
            call destroyBlock
        .endIf_F:
    .endIf_E:

    ; Set coordinates for bottom tile
    ld a, [bomb_mapYPixel]
    add $10
    ld [tileY], a
    ; Perform collision check
    call getTileIndex.projectile
    cp $04
    jr nc, .else_G
        call destroyRespawningBlock
        jr .endIf_G
    .else_G:
        ; Check if tile type is bombable
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, .endIf_H
            ld a, $ff
            call destroyBlock
        .endIf_H:
    .endIf_G:

    ; Set coordinates for right tile
    ld a, [bomb_mapYPixel]
    ld [tileY], a
    ld a, [bomb_mapXPixel]
    add $10
    ld [tileX], a
    ; Perform collision check
    call getTileIndex.projectile
    cp $04
    jr nc, .else_I
        call destroyRespawningBlock
        jr .endIf_I
    .else_I:
        ; Check if tile type is bombable
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, .endIf_J
            ld a, $ff
            call destroyBlock
        .endIf_J:
    .endIf_I:

    ; Set coordinates for left tile
    ld a, [bomb_mapXPixel]
    sub $10
    ld [tileX], a
    ; Perform collision check
    call getTileIndex.projectile
    cp $04
    jr nc, .else_K
        call destroyRespawningBlock
        jr .endIf_K
    .else_K:
        ; Check if tile type is bombable
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, .endIf_L
            ld a, $ff
            call destroyBlock
        .endIf_L:
    .endIf_K:
    
    ; Restore registers
    pop hl
    pop de
    pop bc
ret ;}

samus_bombPoseTable: ;{ 01:55DD - Samus-bombed pose transition table
    db $11 ; $00 - Standing
    db $11 ; $01 - Jumping
    db $11 ; $02 - Spin-jumping
    db $11 ; $03 - Running (set to 83h when turning)
    db $11 ; $04 - Crouching
    db $12 ; $05 - Morphball
    db $12 ; $06 - Morphball jumping
    db $11 ; $07 - Falling
    db $12 ; $08 - Morphball falling
    db $11 ; $09 - Starting to jump
    db $11 ; $0A - Starting to spin-jump
    db $12 ; $0B - Spider ball rolling
    db $12 ; $0C - Spider ball falling
    db $12 ; $0D - Spider ball jumping
    db $12 ; $0E - Spider ball
    db $11 ; $0F - Knockback
    db $12 ; $10 - Morphball knockback
    db $11 ; $11 - Standing bombed
    db $12 ; $12 - Morphball bombed
    db $11 ; $13 - Facing screen
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $12 ; $18 - Being eaten by Metroid Queen
    db $12 ; $19 - In Metroid Queen's mouth
    db $1A ; $1A - Being swallowed by Metroid Queen
    db $1B ; $1B - In Metroid Queen's stomach
    db $1C ; $1C - Escaping Metroid Queen
    db $1D ; $1D - Escaped Metroid Queen
;}

samus_cannonXOffsetTable: ;{ 01:55FB - Projectile X offsets
; Column index into table is based off of facing direction
; Row index is based off of your facing direction of the samus_shotDirectionPriorityTable
    ;   L    R  <- Facing direction  v-- Aiming direction
    db $00, $00
    db $18, $1C ; Right - The opposing L/R directions are used when
    db $04, $08 ; Left  - firing backwards while damage boosting
    db $10, $10
    db $0E, $12 ; Up
    db $10, $10
    db $10, $10
    db $10, $10
    db $0D, $13 ; Down
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
;}

samus_cannonYOffsetByPose: ;{ 01:561D - Projectile y-offsets per pose
    db $17 ; $00 - Standing
    db $1F ; $01 - Jumping
    db $00 ; $02 - Spin-jumping
    db $14 ; $03 - Running (set to 83h when turning)
    db $21 ; $04 - Crouching
    db $00 ; $05 - Morphball
    db $00 ; $06 - Morphball jumping
    db $1D ; $07 - Falling
    db $00 ; $08 - Morphball falling
    db $15 ; $09 - Starting to jump
    db $15 ; $0A - Starting to spin-jump
    db $00 ; $0B - Spider ball rolling
    db $00 ; $0C - Spider ball falling
    db $00 ; $0D - Spider ball jumping
    db $00 ; $0E - Spider ball
    db $1F ; $0F - Knockback
    db $00 ; $10 - Morphball knockback
    db $1F ; $11 - Standing bombed
    db $00 ; $12 - Morphball bombed
;}

samus_cannonYOffsetByAimDirection: ;{ 01:5630 - Projectile y offset due to firing direction
    db $00 ; $00 
    db $00 ; $01 - Right
    db $00 ; $02 - Left
    db $00 ; $03 
    db $F0 ; $04 - Up
    db $00 ; $05 
    db $00 ; $06 
    db $00 ; $07 
    db $08 ; $08 - Down
    db $00 ; $09 
    db $00 ; $0A 
    db $00 ; $0B 
    db $00 ; $0C 
    db $00 ; $0D 
    db $00 ; $0E 
    db $00 ; $0F 
    db $1F ; $10 - ? Morph ?
    db $00 ; $11 
    db $00 ; $12 
;}

samus_shotDirectionPriorityTable: ;{ 01:5643 - Shot direction based on directional input
    db $00 ; ---- ; This entry shouldn't be referenced
    db $01 ; ---r
    db $02 ; --l-
    db $01 ; --lr
    db $04 ; -u--
    db $04 ; -u-r
    db $04 ; -ul-
    db $04 ; -ulr
    db $08 ; d---
    db $08 ; d--r
    db $08 ; d-l-
    db $08 ; d-lr
    db $08 ; du--
    db $08 ; du-r
    db $08 ; dul-
    db $08 ; dulr
;}

samus_possibleShotDirections: ;{ 01:5653
; $00 = Shots not permitted in this pose
; $80 = Use bombs in this pose
; %0000dulr - Set these bits to permit shooting in this direction

    db $07 ; $00 - Standing
    db $0F ; $01 - Jumping
    db $00 ; $02 - Spin-jumping
    db $07 ; $03 - Running (set to 83h when turning)
    db $03 ; $04 - Crouching
    db $80 ; $05 - Morphball
    db $80 ; $06 - Morphball jumping
    db $0F ; $07 - Falling
    db $80 ; $08 - Morphball falling
    db $0F ; $09 - Starting to jump
    db $0F ; $0A - Starting to spin-jump
    db $80 ; $0B - Spider ball rolling
    db $80 ; $0C - Spider ball falling
    db $80 ; $0D - Spider ball jumping
    db $80 ; $0E - Spider ball
    db $0F ; $0F - Knockback
    db $80 ; $10 - Morphball knockback
    db $0F ; $11 - Standing bombed
    db $80 ; $12 - Morphball bombed
    db $00 ; $13 - Facing screen
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $00 ; $18 - Being eaten by Metroid Queen
    db $80 ; $19 - In Metroid Queen's mouth
    db $00 ; $1A - Being swallowed by Metroid Queen
    db $80 ; $1B - In Metroid Queen's stomach
    db $00 ; $1C - Escaping Metroid Queen
    db $80 ; $1D - Escaped Metroid Queen
;}

;} end of Samus' projectile and bomb functions

;------------------------------------------------------------------------------

destroyRespawningBlock: ;{ 01:5671
    ld hl, respawningBlockArray
    .findLoop:
        ; Exit successfully loop if frame counter is zero (slot is inactive)
        ld a, [hl]
        and a
            jr z, .break
        ; Iterate to next block
        ld a, l
        add $10
        ld l, a
        ; Exit if we're at the end of the page
        cp $00
            ret z
    jr .findLoop
    .break:

    ; Set frame counter
    ld a, $01
    ld [hl+], a
    ; Set Y pos
    ld a, [tileY]
    ld [hl+], a
    ; Set X pos
    ld a, [tileX]
    ld [hl+], a
    ; Request sound effect
    ld a, $04
    ld [sfxRequest_noise], a
ret ;}

handleRespawningBlocks: ;{ 01:5692
    ld hl, respawningBlockArray
    .loop:
        ; Skip block if timer is zero
        ld a, [hl]
        and a
        jr z, .nextBlock
            ; Increment frame counter
            inc a
            ld [hl+], a
            ; Compare scroll y and tile y
            ld a, [scrollY]
            ld b, a
            ld a, [hl+]
            ld [tileY], a
            sub b
            and $f0
            cp $c0 ; Remove from table if offscreen
                jr z, .removeBlock
        
            ; Compare scroll x and tile x
            ld a, [scrollX]
            ld b, a
            ld a, [hl]
            ld [tileX], a
            sub b
            and $f0
            cp $d0 ; Remove from table if offscreen
                jr z, .removeBlock
        
            dec hl
            dec hl
            ld a, [hl]
            cp $02
                jp z, destroyBlock.frame_A
            cp $07
                jp z, destroyBlock.frame_B
            cp $0d
                jr z, destroyBlock.empty ; Deleted
            cp $f6
                jp z, destroyBlock.frame_B
            cp $fa
                jr z, destroyBlock.frame_A
            cp $fe
                jr z, destroyBlock.reform ; Reformed
        
            jr .nextBlock
        
        .removeBlock: ; Clear the block from the array
            ld a, l
            and $f0
            ld l, a
            ; Clear timer for block
            xor a
            ld [hl], a
    
    .nextBlock:
        ld a, l
        and $f0
        add $10
        ld l, a
        and a
    jr nz, .loop
ret ;}

destroyBlock: ; 01:56E9
.empty: ; Destroy block (frame 3 - empty)
    call getTilemapAddress
    ; Load return arg into HL
    ld a, [pTilemapDestLow]
    and $de ; Bit-fiddling to ensure it's the top-left corner of the tile?
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f ; Distance in memory between top-right and bottom-left tile

    .waitLoop_A:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_A

    .waitLoop_B:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_B

    ; Destroy block (turn to blank)
    ld a, $ff
    ld [hl+], a
    ld [hl], a
    add hl, de
    ld [hl+], a
    ld [hl], a
    ; Play sound
    ld a, $04
    ld [sfxRequest_noise], a
ret

.reform: ; 01:5712 - Fully restore block (frame 6)
    xor a
    ld [hl], a
    call getTilemapAddress
    ld a, [pTilemapDestLow]
    and $de
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f

    .waitLoop_C:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_C

    .waitLoop_D:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_D

    xor a
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
    ; Hurt Samus if applicable
    ld a, [samusInvulnerableTimer]
    and a
        ret nz
    call .hurtSamus
ret

.frame_A: ; Destroy block (frames 1, 5)
    call getTilemapAddress
    ld a, [pTilemapDestLow]
    and $de
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f

    .waitLoop_E:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_E

    .waitLoop_F:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_F

    ld a, $04
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
ret

.frame_B: ; Destroy block (frames 2, 4)
    call getTilemapAddress
    ld a, [pTilemapDestLow]
    and $de
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f

    .waitLoop_G:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_G

    .waitLoop_H:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_H

    ld a, $08
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
ret

.hurtSamus: ; 01:5790
    ; Index into height table using Samus' pose
    ld hl, .samusHeightTable
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ; Save height
    ld a, [hl]
    ld b, a

    ; Bounds checking for y position
    ld a, [tileY]
    sub $10
    and $f0
    ld c, a
    ldh [hTemp.a], a
    ldh a, [hSamusYPixel]
    add $18
    sub c
    cp b
        jr nc, .exit
    ; Bounds checking for x position
    ld a, [tileX]
    sub $08
    and $f0
    ld b, a
    ldh [hTemp.b], a
    ldh a, [hSamusXPixel]
    add $0c
    sub b
    cp $18
        jr nc, .exit
    ; Set damage boosting direction depending of x position
    cp $0c
    jr nc, .else
        ld a, $ff ; Left
        ld [samus_damageBoostDirection], a
        jr .endIf
    .else:
        ld a, $01 ; Right
        ld [samus_damageBoostDirection], a
    .endIf:
    ; Hurt samus
    ld a, $01
    ld [samus_hurtFlag], a
    ld a, $02
    ld [samus_damageValue], a
    call destroyRespawningBlock

    .exit:
ret

.samusHeightTable: ; 01:57DF
    db $20 ; $00 - Standing
    db $20 ; $01 - Jumping
    db $20 ; $02 - Spin-jumping
    db $20 ; $03 - Running (set to 83h when turning)
    db $20 ; $04 - Crouching
    db $10 ; $05 - Morphball
    db $10 ; $06 - Morphball jumping
    db $20 ; $07 - Falling
    db $10 ; $08 - Morphball falling
    db $20 ; $09 - Starting to jump
    db $20 ; $0A - Starting to spin-jump
    db $10 ; $0B - Spider ball rolling
    db $10 ; $0C - Spider ball falling
    db $10 ; $0D - Spider ball jumping
    db $10 ; $0E - Spider ball
    db $20 ; $0F - Knockback
    db $10 ; $10 - Morphball knockback
    db $20 ; $11 - Standing bombed
    db $10 ; $12 - Morphball bombed

;------------------------------------------------------------------------------
; Handle window height, save text, earthquake, low heath beep, fade in, and Metroid Queen cry
miscIngameTasks: ;{ 01:57F2
;{ Handle window display stuff
    ; Decrement cooldown
    ld a, [saveMessageCooldownTimer]
    and a
    jr z, .endIf_A
        dec a
        ld [saveMessageCooldownTimer], a
    .endIf_A:

    ; Skip this if in the Queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr z, .endIf_B
        ldh a, [rLCDC]
        bit 5, a
        jr nz, .endIf_C
            set 5, a ; Enable window display
            ldh [rLCDC], a
        .endIf_C:
        
        ld a, $88 ; Default window position
        ldh [rWY], a
        ; Check different cases for raising the window
        ld a, [saveContactFlag] ; Only unset by door transitions and this function
        and a
        jr nz, .else_D
            ; Check if item being collected
            ld a, [itemCollected_copy]
            and a
            jr z, .endIf_B
                ld a, [itemCollected_copy]
                cp $0b ; Check if not a common item or refill
                jr nc, .endIf_B
                    ld a, $80 ; Higher window position
                    ldh [rWY], a
                    jr .endIf_B
        .else_D:
            ; Touching a save point
            ld a, $80 ; Higher window position
            ldh [rWY], a
            ; Don't allow saving while "Completed" is displayed
            ld a, [saveMessageCooldownTimer]
            and a
            jr nz, .endIf_E
                ; Check input
                ldh a, [hInputRisingEdge]
                cp PADF_START
                jr nz, .endIf_E
                    ; Save!
                    ld a, $09
                    ldh [gameMode], a
                    ; Let the "Completed" message show
                    ld a, $ff
                    ld [saveMessageCooldownTimer], a
            .endIf_E:

            ; Draw completed text when timer is non-zero
            ld a, [saveMessageCooldownTimer]
            and a
            jr z, .else_F
                ; Draw save "Completed" sprite
                ld a, $98
                ldh [hSpriteYPixel], a
                ld a, $44
                ldh [hSpriteXPixel], a
                ld a, $43
                ldh [hSpriteId], a
                call drawSamusSprite
                jr .endIf_B
            .else_F:
                ; Clear flag
                xor a
                ld [saveContactFlag], a
                ; Draw blinking "Press Start" sprite
                ldh a, [frameCounter]
                bit 3, a
                jr z, .endIf_B
                    ld a, $98
                    ldh [hSpriteYPixel], a
                    ld a, $44
                    ldh [hSpriteXPixel], a
                    ld a, $42
                    ldh [hSpriteId], a
                    call drawSamusSprite
    .endIf_B: ;}

;{ Earthquake stuff
    ; Only do this stuff once every 256 frames
    ldh a, [frameCounter]
    and a
    jr nz, .endIf_G
        ; Check if this is non-zero
        ld a, [nextEarthquakeTimer]
        and a
        jr z, .endIf_G
            ; Decrement timer
            dec a
            ld [nextEarthquakeTimer], a
            jr nz, .endIf_G
                ; Activate earthquake
                ld a, $ff
                ld [earthquakeTimer], a
                ld a, $0e
                ld [songInterruptionRequest], a
                ; Special case for last metroid (Queen)
                ld a, [metroidCountReal]
                cp $01
                jr nz, .endIf_G
                    ld a, $60
                    ld [earthquakeTimer], a
    .endIf_G: ;}

;{ Handle low health beep
    ; Only play the low-health beep after the intro has finished
    ld a, [samusPose]
    cp pose_faceScreen
    jr nz, .then_H
        ld a, [countdownTimerLow]
        ld b, a
        ld a, [countdownTimerHigh]
        or b
        jr nz, .endIf_H
        .then_H:
            ; Skip ahead if health isn't below 50
            ld a, [samusCurHealthHigh]
            and a
            jr nz, .else_I
                ld a, [samusCurHealthLow]
                cp $50
                jr nc, .else_I
                    ; Check if health decreased from the last frame
                    ld b, a
                    ld a, [$d0a1]
                    cp b
                    jr z, .endIf_H
                        ; Queue up new sound effect based on tens digit
                        ld a, b
                        ld [$d0a1], a
                        and $f0
                        swap a
                        inc a
                        ld [$cfe5], a
                        jr .endIf_H
            .else_I:
                ; Check if not already clear
                ld a, [$cfe6]
                and a
                jr z, .endIf_H
                    ; Clear the low health beep
                    ld a, $ff
                    ld [$cfe5], a
    .endIf_H: ;}

; Handle fade-in
    ld a, [fadeInTimer]
    and a
        call nz, fadeIn

; Handle Queen's roar
    ld a, [sound_playQueenRoar]
    and a
    jr z, .else_J
        ; Only roar every 128 frames
        ldh a, [frameCounter]
        and $7f
        jr nz, .else_J
            ld a, $17
            ld [sfxRequest_noise], a
    .else_J:
ret ;}

; Item message pointers and strings:
itemTextPointerTable: ; 01:58F1
    include "data/itemNames.asm"

drawEnemies: ; Draw enemies - 01:5A11
    ; Exit if there are no enemies to render
    ld a, [numActiveEnemies]
    and a
        ret z

    ld hl, $c600
    ld a, l
    ld [$c454], a
    ld a, h
    ld [$c455], a

    jr_001_5a21:
        ld a, [hl]
        and a
            call z, drawEnemySprite
        ld a, [$c454]
        ld l, a
        ld a, [$c455]
        ld h, a
        ld de, $0020
        add hl, de
        ld a, l
        ld [$c454], a
        ld a, h
        ld [$c455], a
        cp $c8
    jr nz, jr_001_5a21
ret

; Render enemy sprite
drawEnemySprite: ; 01:5A3F
    call drawEnemySprite_getInfo
    ld a, [$c430]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, enemySpritePointerTable ;$5ab1
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a

    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a

    ld a, [$c42e]
    ld b, a
    ld a, [$c42f]
    ld c, a

    .spriteLoop:
        ld a, [de]
        cp METASPRITE_END
            jr z, .exit
    
        ld a, [$c431]
        bit 6, a
        jr z, .else_A
            ld a, [de]
            cpl
            sub $07
            jr .endIf_A
        .else_A:
            ld a, [de]
        .endIf_A:
    
        add b
        ld [hl+], a
        inc de
        ld a, [$c431]
        bit 5, a
        jr z, .else_B
            ld a, [de]
            cpl
            sub $07
            jr .endIf_B
        .else_B:
            ld a, [de]
        .endIf_B:
    
        add c
        ld [hl+], a
        inc de
        ld a, [de]
        ld [hl+], a
        inc de
        push hl
        ld hl, $c431
        ld a, [de]
        xor [hl]
        pop hl
        ld [hl+], a
        ld a, l
        ldh [hOamBufferIndex], a
        inc de
    jr .spriteLoop

    .exit:
ret

; Get base information for enemy sprite to render
drawEnemySprite_getInfo: ; 01:5A9A
    inc l
    ; y pos
    ld a, [hl+]
    ld [$c42e], a
    ; x pos
    ld a, [hl+]
    ld [$c42f], a
    ; sprite type
    ld a, [hl+]
    ld [$c430], a
    ; Attributes
    ld a, [hl+] ; Base attributes
    xor [hl] ; Normal attributes
    inc l
    xor [hl] ; Stun counter
    and $f0
    ld [$c431], a
ret

; 01:5AB1
enemySpritePointerTable:
    include "data/enemy_spritePointers.asm"
    include "data/sprites_enemies.asm"

;------------------------------------------------------------------------------
; Alpha Metroid - get angle based on relative positions
alpha_getAngle: ; 01:70BA - called from bank 2
    call metroid_getDistanceAndDirection
    call alpha_getAngleFromTable
    ret

metroid_getDistanceAndDirection: ; 01:70C1
    ld hl, hEnemy.yPos
    ld a, [hl]
    add $10
    ld b, a
    ld a, [samus_onscreenYPos]
    sub b
    jr c, .else_A
        ld b, $00
        jr z, .endIf_A
            inc b
            jr .endIf_A
    .else_A:
        cpl
        inc a
        ld b, $ff
    .endIf_A:

    ld [metroid_absSamusDistY], a
    ld a, b
    ld [metroid_samusYDir], a
    inc l
    ld a, [hl]
    add $10
    ld b, a
    ld a, [samus_onscreenXPos]
    sub b
    jr c, .else_B
        ld b, $00
        jr z, .endIf_B
            inc b
            jr .endIf_B
    .else_B:
        cpl
        inc a
        ld b, $ff
    .endIf_B:

    ld [metroid_absSamusDistX], a
    ld a, b
    ld [metroid_samusXDir], a
ret


alpha_getAngleFromTable: ; 01:70FE
    ld a, [metroid_samusXDir]
    and a
        jr z, .pickVerticalDirection
    ld c, a
    ld a, [metroid_samusYDir]
    and a
        jr z, .pickHorizontalDirection

    ; Determine base table index for quadrant
    inc a
    jr z, .else_A
        inc c
        jr z, .else_B
            ld a, $04 ; Bottom right quadrant
            jr .endIf_A
        .else_B:
            ld a, $09 ; Bottom left quadrant
            jr .endIf_A
    .else_A:
        inc c
        jr z, .else_C
            ld a, $0e ; Top right quadrant
            jr .endIf_A
        .else_C:
            ld a, $13 ; Top left quadrant
    .endIf_A:

    ld [metroid_angleTableIndex], a
    call metroid_getSlopeToSamus ; Do some arithmetic
    call alpha_adjustAngle ; Adjust the angle index

.getAngleFromTable:
    ld a, [metroid_angleTableIndex]
    ld e, a
    ld d, $00
    ld hl, alpha_angleTable
    add hl, de
    ld a, [hl]
    ld [hEnemy.state], a
ret

    .pickHorizontalDirection:
        ld a, [metroid_samusXDir]
        dec a
        jr z, .else_D
            ld a, $01 ; Left
            jr .setTableIndex
        .else_D:
            xor a ; Right
            jr .setTableIndex
    .pickVerticalDirection:
        ld a, [metroid_samusYDir]
        dec a
        jr z, .else_E
            ld a, $03 ; Up
            jr .setTableIndex
        .else_E:
            ld a, $02 ; Down
.setTableIndex:
    ld [metroid_angleTableIndex], a
    jr .getAngleFromTable
; end proc

alpha_angleTable: ; 01:7158
    ; $00 - Cardinal directions
    db $00, $01, $02, $03
    ; $04 - Bottom right quadrant
    db $00, $04, $05, $06, $02
    ; $09 - Bottom left quadrant
    db $01, $07, $08, $09, $02
    ; $0E - Top right quadrant
    db $00, $0A, $0B, $0C, $03
    ; $13 - Top left quadrant
    db $01, $0D, $0E, $0F, $03

; Returns (100*dY)/dX
metroid_getSlopeToSamus: ; { 01:7170
    ; Multiply Y distance by $64 (100 in decimal)
    ld b, $64
    ld a, [metroid_absSamusDistY]
    ld e, a
    call math_multiply_B_E_to_HL
    ; Divide that result by the X distance
    ld a, [metroid_absSamusDistX]
    ld c, a
    call math_divide_HL_by_C
    ; Save result in HL to
    ld a, l
    ld [metroid_slopeToSamusLow], a
    ld a, h
    ld [metroid_slopeToSamusHigh], a
ret ;}

; Adjusts the travel angle of the Alpha Metroid from one of the cardinal angles
alpha_adjustAngle: ; 01:7189
    ld a, [metroid_slopeToSamusHigh]
    and a
    jr nz, .else_A
        ld a, [metroid_slopeToSamusLow]
        cp $14
            jr c, .add_0
        cp $3c
            jr c, .add_1
        cp $c8
            jr c, .add_2
        jr .add_3
    .else_A:
        cp $02
        jr z, .else_B
            jr nc, .add_4
            jr .add_3
        .else_B:
            ld a, [metroid_slopeToSamusLow]
            cp $58
                jr nc, .add_4
            jr .add_3

    .add_0: ; Keep horizontal
        ld b, $00
        jr .exit
    .add_1: ; Shallow angle
        ld b, $01
        jr .exit
    .add_2: ; Diagonal
        ld b, $02
        jr .exit
    .add_3: ; Steep angle
        ld b, $03
        jr .exit
    .add_4: ; Vertical
        ld b, $04
.exit:
    ld a, [metroid_angleTableIndex]
    add b
    ld [metroid_angleTableIndex], a
ret

; Alpha Metroid speed/direction vectors
; Load a (Y,X) sign-magnitude velocity pair to BC
alpha_getSpeedVector: ; 01:71CB
    ld hl, .jumpTable
    ld a, [hEnemy.state] ; $EA - Metroid angle
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld h, d
    ld l, a
    jp hl
    
    .jumpTable: ; 01:71DB
        dw func_71FB ; $00 - Right                 (3,0)
        dw func_71FF ; $01 - Left                 (-3,0)
        dw func_7203 ; $02 - Down                  (0,3)
        dw func_7207 ; $03 - Up                    (0,-3)
        dw func_720B ; $04 - Bottom right quadrant (3,1)
        dw func_720F ; $05 -  ""                   (2,2)
        dw func_7213 ; $06 -  ""                   (1,3)
        dw func_7217 ; $07 - Bottom left quadrant (-3,1)
        dw func_721B ; $08 -  ""                  (-2,2)
        dw func_721F ; $09 -  ""                  (-1,3)
        dw func_7223 ; $0A - Upper right quadrant (3,-1)
        dw func_7227 ; $0B -  ""                  (2,-2)
        dw func_722B ; $0C -  ""                  (1,-3)
        dw func_722F ; $0D - Upper left quadrant (-3,-1)
        dw func_7233 ; $0E -  ""                 (-2,-2)
        dw func_7237 ; $0F -  ""                 (-1,-3)

func_71FB: ld bc, $0003
    ret
func_71FF: ld bc, $0083
    ret
func_7203: ld bc, $0300
    ret
func_7207: ld bc, $8300
    ret

func_720B: ld bc, $0103
    ret
func_720F: ld bc, $0202
    ret
func_7213: ld bc, $0301
    ret

func_7217: ld bc, $0183
    ret
func_721B: ld bc, $0282
    ret
func_721F: ld bc, $0381
    ret

func_7223: ld bc, $8103
    ret
func_7227: ld bc, $8202
    ret
func_722B: ld bc, $8301
    ret

func_722F: ld bc, $8183
    ret
func_7233: ld bc, $8282
    ret
func_7237: ld bc, $8381
    ret

;------------------------------------------------------------------------------
; Gamma Metroid - get angle based on relative positions
;  Also used by the Omega Metroids' fireballs
gamma_getAngle: ; 01:723B
    call metroid_getDistanceAndDirection
    call gamma_getAngleFromTable ; Get angle
ret

gamma_getAngleFromTable: ; 01:7242
    ld a, [metroid_samusXDir]
    and a
        jr z, .pickVerticalDirection
    ld c, a
    ld a, [metroid_samusYDir]
    and a
        jr z, .pickHorizontalDirection

    ; Determine base table index for quadrant
    inc a
    jr z, .else_A
        inc c
        jr z, .else_B
            ld a, $04 ; Bottom right quadrant
            jr .endIf_A
        .else_B:
            ld a, $0b ; Bottom left quadrant
            jr .endIf_A
    .else_A:
        inc c
        jr z, .else_C
            ld a, $12 ; Top right quadrant
            jr .endIf_A
        .else_C:
            ld a, $19 ; Top left quadrant
    .endIf_A:

    ld [metroid_angleTableIndex], a
    call metroid_getSlopeToSamus ; Do some arithmetic
    call gamma_adjustAngle

.getAngleFromTable:
    ld a, [metroid_angleTableIndex]
    ld e, a
    ld d, $00
    ld hl, gamma_angleTable
    add hl, de
    ld a, [hl]
    ld [hEnemy.state], a
ret

    .pickHorizontalDirection:
        ld a, [metroid_samusXDir]
        dec a
        jr z, .else_D
            ld a, $01 ; Left
            jr .setTableIndex
        .else_D:
            xor a ; Right
            jr .setTableIndex
    .pickVerticalDirection:
        ld a, [metroid_samusYDir]
        dec a
        jr z, .else_E
            ld a, $03 ; Up
            jr .setTableIndex
        .else_E:
            ld a, $02 ; Down
.setTableIndex:
    ld [metroid_angleTableIndex], a
    jr .getAngleFromTable
; end proc

gamma_angleTable: ; 01:729C - Gamma angle table
    ; $00 - Cardinal directions
    db $00, $01, $02, $03
    ; $04 - Bottom right quadrant
    db $00, $04, $05, $06, $07, $08, $02
    ; $0B - Bottom left quadrant
    db $01, $09, $0A, $0B, $0C, $0D, $02
    ; $12 - Top right quadrant
    db $00, $0E, $0F, $10, $11, $12, $03
    ; $19 - Top left quadrant
    db $01, $13, $14, $15, $16, $17, $03

gamma_adjustAngle:
    ld a, [metroid_slopeToSamusHigh]
    and a
    jr nz, .else_A
        ld a, [metroid_slopeToSamusLow]
        cp $0c
            jr c, .add_0
        cp $26
            jr c, .add_1
        cp $4b
            jr c, .add_2
        cp $96
            jr c, .add_3
        jr .add_4
    .else_A:
        cp $03
        jr z, .else_B
            jr nc, .add_6
            cp $01
                jr z, .else_C ; Odd jump
            jr nc, .add_5
            jr .add_4
        .else_B:
            ld a, [metroid_slopeToSamusLow]
            cp $20
                jr nc, .add_6
            jr .add_5

        .else_C: ; Odd jump
            ld a, [metroid_slopeToSamusLow]
            cp $2c
                jr nc, .add_5
            jr .add_4

    .add_0: ; Keep horizontal
        ld b, $00
        jr .exit
    .add_1:
        ld b, $01 ; Shallow angle
        jr .exit
    .add_2:
        ld b, $02 ; Less shallow angle
        jr .exit
    .add_3: ; Diagonal
        ld b, $03
        jr .exit
    .add_4:
        ld b, $04 ; Steep angle
        jr .exit
    .add_5:
        ld b, $05 ; Even steeper angle
        jr .exit
    .add_6: ; Vertical
        ld b, $06
.exit:
    ld a, [metroid_angleTableIndex]
    add b
    ld [metroid_angleTableIndex], a
ret

; Gamma Metroid speed/direction vectors
; Load a (Y,X) sign-magnitude velocity pair to BC
gamma_getSpeedVector: ; 01:7319
    ld hl, .jumpTable
    ld a, [hEnemy.state]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld h, d
    ld l, a
    jp hl

    .jumpTable: ; 01:7329
        dw func_7359 ; $00 - Right
        dw func_735D ; $01 - Left
        dw func_7361 ; $02 - Down
        dw func_7365 ; $03 - Up
        dw func_7369 ; $04 - Bottom right quadrant
        dw func_736D ; $05
        dw func_7371 ; $06
        dw func_7375 ; $07
        dw func_7379 ; $08
        dw func_737D ; $09 - Bottom left quadrant
        dw func_7381 ; $0A
        dw func_7385 ; $0B
        dw func_7389 ; $0C
        dw func_738D ; $0D
        dw func_7391 ; $0E - Top right quadrant
        dw func_7395 ; $0F
        dw func_7399 ; $10
        dw func_739D ; $11
        dw func_73A1 ; $12
        dw func_73A5 ; $13 - Top left quadrant
        dw func_73A9 ; $14
        dw func_73AD ; $15
        dw func_73B1 ; $16
        dw func_73B5 ; $17

func_7359: ld bc, $0004
    ret
func_735D: ld bc, $0084
    ret
func_7361: ld bc, $0400
    ret
func_7365: ld bc, $8400
    ret

func_7369: ld bc, $0104
    ret
func_736D: ld bc, $0204
    ret
func_7371: ld bc, $0303
    ret
func_7375: ld bc, $0402
    ret
func_7379: ld bc, $0401
    ret

func_737D: ld bc, $0184
    ret
func_7381: ld bc, $0284
    ret
func_7385: ld bc, $0383
    ret
func_7389: ld bc, $0482
    ret
func_738D: ld bc, $0481
    ret

func_7391: ld bc, $8104
    ret
func_7395: ld bc, $8204
    ret
func_7399: ld bc, $8303
    ret
func_739D: ld bc, $8402
    ret
func_73A1: ld bc, $8401
    ret

func_73A5: ld bc, $8184
    ret
func_73A9: ld bc, $8284
    ret
func_73AD: ld bc, $8383
    ret
func_73B1: ld bc, $8482
    ret
func_73B5: ld bc, $8481
    ret

; HL = B * E
math_multiply_B_E_to_HL: ; { 01:73B9
    ; B is set to $64 before entry
    ; E is metroid_absSamusDistY
    
    ; Init result
    ld hl, $0000
    ; Init 
    ld c, l
    
    ; This multiplication loop is roughly equivalent to this pseudo-code (thanks PJ):
    ; hl = 0
    ; if [e] & 80h:
    ;     hl += [b] * 80h
    ; if [e] & 40h:
    ;     hl += [b] * 40h
    ; if [e] & 20h:
    ;     hl += [b] * 20h
    ; ...
    
    ; Loop 8 times for each bit of the operands
    ld a, $08
    .loop:
        ; Divide BC by 2
        srl b
        rr c
        
        ; Add BC to HL if the corresponding bit in E is set
        sla e
        jr nc, .endIf
            add hl, bc
        .endIf:
        
        ; Decrement loop counter
        dec a
    jr nz, .loop
ret ;}

; division 
; HL = HL / C
; DE = (HL % C) * 2 (remainder)
math_divide_HL_by_C: ; { 01:73CC
    ; C is metroid_absSamusDistX entering this
    
    ; Exit if HL = 0
    ld a, h
    or l
        ret z

    ; Init upper bytes of DEHL
    ld de, $0000
    ; Loop counter
    ld b, $10
    
    ; This loop here is equivalent to doing long division in binary.
    ; Proving this equivalence is an exercise left to the reader.
    ; NOTE: Dividing by zero will result in a value of 0xFFFF
    
    ; DEHL * 2
    sla l
    rl h
    rl e
    rl d
    .loop:
        ; Check if DE - C >= 0
        ld a, e
        sub c
        ld a, d
        sbc $00
        jr c, .endIf
            ; If so, then DE = DE - C
            ld a, e
            sub c
            ld e, a
            ld a, d
            sbc $00
            ld d, a
        .endIf:
        ccf ; Invert the carry flag
        ; If (DE >= C) then (DEHL << 1) & 1
        ;  else (DEHL << 1)
        rl l
        rl h
        rl e
        rl d
        dec b
    jr nz, .loop
ret ;}

;------------------------------------------------------------------------------
; Draws sprites for title and credits
drawNonGameSprite: ;{ 01:73F7
    ; Index into sprite pointer table
    ldh a, [hSpriteId]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, creditsSpritePointerTable
    add hl, de
    ; Load pointer from table
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ; Prep HL
    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a
    ; Store x and y offsets of sprite in B and C
    ldh a, [hSpriteYPixel]
    ld b, a
    ldh a, [hSpriteXPixel]
    ld c, a

    .spriteLoop:
        ; Load y coordinate
        ld a, [de]
        cp METASPRITE_END
            jr z, .exit
        ; Handle y flipping
        ldh a, [hSpriteAttr]
        bit OAMB_YFLIP, a
        jr z, .else_A
            ld a, [de]
            cpl
            sub $07
            jr .endIf_A
        .else_A:
            ld a, [de]
        .endIf_A:
        ; Add y offset and store
        add b
        ld [hl+], a

        ; Load x coordinate
        inc de
        ldh a, [hSpriteAttr]
        bit OAMB_XFLIP, a
        jr z, .else_B
            ld a, [de]
            cpl
            sub $07
            jr .endIf_B
        .else_B:
            ld a, [de]
        .endIf_B:
    
        add c
        ld [hl+], a
        ; Load tile number
        inc de
        ld a, [de]
        ld [hl+], a
        ; Load sprite attribute byte
        inc de
        push hl
            ld hl, hSpriteAttr
            ld a, [de]
            xor [hl]
        pop hl
        ld [hl+], a
        ; Adjust indeces for next loop iteration
        ld a, l ; Assumes OAM buffer address is $00 aligned?
        ldh [hOamBufferIndex], a
        inc de
    jr .spriteLoop

    .exit:
ret ;}

; 01:744A
include "data/sprites_credits.asm" ; Also title

;------------------------------------------------------------------------------

earthquake_adjustScroll: ;{ 01:79EF: Handle earthquake (called from bank 0)
    ; Exit if earthquake not active
    ld a, [earthquakeTimer]
    and a
        ret z

    ; Value of A oscillates between 1 and -1 every two frames
    and $02
    dec a
    ld b, a
    ; Adjust scroll
    ld a, [scrollY]
    add b
    ld [scrollY], a

    ; Decrement earthquake timer every two frames
    ldh a, [frameCounter]
    and $01
        ret nz
    ld a, [earthquakeTimer]
    dec a
    ld [earthquakeTimer], a
        ret nz
; Actions once earthquake is finished
    ; Clear earthquake sound
    xor a
    ld [songInterruptionPlaying], a
    
    ; Check if in Queen fight
    ld a, [queen_roomFlag]
    cp $10
    jr nc, .else_A
        ; If not in Queen fight, check if a song is queued-up to restart
        ld a, [songRequest_afterEarthquake]
        and a
        jr z, .else_B
            ; Restore music
            ld [songRequest], a
            ld [currentRoomSong], a
            xor a
            ld [songRequest_afterEarthquake], a
            ret
        .else_B:
            ; End isolated sound effect
            ld a, $03
            ld [songInterruptionRequest], a
            ret
    .else_A:
        ; If in Queen's room, start playing the baby metroid music
        ld a, $01
        ld [songRequest], a
        ret
;}

drawSamus_earthquakeAdjustment: ;{ 01:7A34
    ld a, [earthquakeTimer]
    and a
        ret z
    ; Alternate between +1 and -1 pixel based on timer (every 4 frames)
    and %00000100 ; $04
    srl a
    dec a
    ld b, a
    ; Add adjustment
    ldh a, [hSpriteYPixel]
    add b
    ldh [hSpriteYPixel], a
ret ;}

fadeIn: ;{ 01:7A45
    ld hl, .fadeTable
    ; Use upper nybble as index into .fadeTable
    ld a, [fadeInTimer]
    and $f0
    swap a
    ld e, a
    ld d, $00
    add hl, de
    ; Load palette
    ld a, [hl]
    ld [bg_palette], a
    ld [ob_palette0], a
    ; Decrement timer
    ld a, [fadeInTimer]
    dec a
    ld [fadeInTimer], a
    ; Set timer to zero once we reach $0E
    cp $0e
        ret nc
    xor a
    ld [fadeInTimer], a
ret

.fadeTable: ; 01:7A69
    db $93, $e7, $fb
;}

saveEnemyFlagsToSRAM: ; 01:7A6C
    ld d, $00
    ld a, [previousLevelBank]
    sub $09
    swap a
    add a
    add a
    ld e, a
    rl d
    ld hl, saveBuf_enemySaveFlags
    add hl, de
    ld de, enemySaveFlags
    ld b, $40

    ; Save active enemy save flags to save buffer
    .bufferLoop:
        ld a, [de]
        cp $02
            jr z, .case_A
        cp $fe
            jr z, .case_A
        cp $04
            jr nz, .case_B
        ld a, $fe
    
        .case_A:
            ld [hl], a
        .case_B:
            inc l
            inc e
            dec b
    jr nz, .bufferLoop

    ; Enable SRAM
    ld a, $0a
    ld [$0000], a

    ld de, saveData_objList_baseAddr
    ld a, [activeSaveSlot]
    add a
    add d
    ld d, a
    ld hl, saveBuf_enemySaveFlags
    ld bc, $01c0

    .saveLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .saveLoop

    ; Disable SRAM
    xor a
    ld [$0000], a
ret

; Loads enemy save flags from SRAM to a WRAM buffer.
loadEnemySaveFlags: ; 01:7AB9
    ld a, $0a
    ld [$0000], a
    ld de, saveBuf_enemySaveFlags
    ld bc, $01c0
    ld hl, saveData_objList_baseAddr
    ld a, [activeSaveSlot]
    add a
    add h
    ld h, a

    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .loadLoop

    ld a, $00
    ld [$0000], a
    
    xor a
    ld [loadSpawnFlagsRequest], a
ret

saveFileToSRAM: ; 01:7ADF
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a

    ld hl, saveFile_magicNumber
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    ld e, a
    ld d, HIGH(saveData_baseAddr)
    ld b, $08

    .loop_A: ; Copy magic number to save file
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .loop_A

    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    add $08
    ld l, a
    ld h, HIGH(saveData_baseAddr)
    
    ldh a, [hSamusYPixel]
    ld [hl+], a
    ldh a, [hSamusYScreen]
    ld [hl+], a
    ldh a, [hSamusXPixel]
    ld [hl+], a
    ldh a, [hSamusXScreen]
    ld [hl+], a
    ldh a, [hCameraYPixel]
    ld [hl+], a
    ldh a, [hCameraYScreen]
    ld [hl+], a
    ldh a, [hCameraXPixel]
    ld [hl+], a
    ldh a, [hCameraXScreen]
    ld [hl+], a

    ld de, saveBuffer + $08
    ld b, $0d
    .loop_B: ; Save graphics pointers and such
        ld a, [de]
        inc de
        ld [hl+], a
        dec b
    jr nz, .loop_B

    ld a, [samusItems]
    ld [hl+], a
    ld a, [samusBeam]
    ld [hl+], a
    ld a, [samusEnergyTanks]
    ld [hl+], a
    ld a, [samusCurHealthLow]
    ld [hl+], a
    ld a, [samusCurHealthHigh]
    ld [hl+], a
    ld a, [samusMaxMissilesLow]
    ld [hl+], a
    ld a, [samusMaxMissilesHigh]
    ld [hl+], a
    ld a, [samusCurMissilesLow]
    ld [hl+], a
    ld a, [samusCurMissilesHigh]
    ld [hl+], a
    ld a, [samusFacingDirection]
    ld [hl+], a
    ld a, [acidDamageValue]
    ld [hl+], a
    ld a, [spikeDamageValue]
    ld [hl+], a
    ld a, [metroidCountReal]
    ld [hl+], a
    ld a, [currentRoomSong]
    ld [hl+], a
    ld a, [gameTimeMinutes]
    ld [hl+], a
    ld a, [gameTimeHours]
    ld [hl+], a
    ld a, [metroidCountDisplayed]
    ld [hl], a
    ; Disable SRAM
    ld a, $00
    ld [$0000], a

    call saveEnemyFlagsToSRAM
    
    ; Play save sound effect
    ld a, $1c
    ld [sfxRequest_square1], a
    ; But why write to this twice?
    ld a, $1c
    ld [sfxRequest_square1], a
    ; Turn game mode back to main
    ld a, $04
    ldh [gameMode], a
ret

; 1:7B87 - Freespace (filled with $00)