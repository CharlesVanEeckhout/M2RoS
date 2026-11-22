; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $005", ROMX[$4000], BANK[$5]

titleCreditsBank:

;------------------------------------------------------------------------------
; called by gameMode_boot
loadTitleScreen: ;{ 05:408F
    ld bc, $1000
    ld hl, gfx_titleScreen
    ld de, vramDest_titleChr
    call copyToVram
    ; Load HUD
    ld hl, hudBaseTilemap
    ld de, vramDest_statusBar
    ld b, $14
    .hudLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .hudLoop
    ; Load "Save" text
    ld hl, saveTextTilemap
    ld de, vramDest_itemText
    ld b, $14
    .saveTextLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .saveTextLoop
    ; Load title tilemap
    ld de, TILEMAP0
    ld hl, titleTilemap
    .titleTilemapLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        ld a, d
        cp $9c
    jr nz, .titleTilemapLoop

    ; Initialize window position
    ld a, $07
    ldh [rWX], a
    ld a, $88
    ldh [rWY], a
    ; Reset scroll
    xor a
    ld [scrollY], a
    ; Enable rendering (window disabled)
    ld a, $c3
    ldh [rLCDC], a
    ; Play title music
    ld a, $11
    ld [songRequest], a
    ; Clear variables
    xor a
    ld [title_clearSelected], a
    
    ; If loading from a file, have the Clear option be selected? Odd.
    ld a, [loadingFromFile]
    and a
    jr z, .endIf
        ld a, $01
        ld [title_clearSelected], a
    .endIf:

    ; Set countdown timer to max for flashing effect
    ld a, $ff
    ld [countdownTimerHigh], a
    ld [countdownTimerLow], a
    ; Set game mode to title
    ld a, _id_gameMode_Title
    ldh [hGameMode], a
ret ;}

hudBaseTilemap:  ; 05:40F0
    db $AF, $AF, $AF, $AF, $AF, $9E, $AF, $AF, $AF, $9F, $9E, $AF, $AF, $AF, $AF, $FF, $FF, $9E, $A3, $A0
saveTextTilemap: ; 05:4104
    db $FF, $D2, $C0, $D5, $C4, $DE, $DF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;------------------------------------------------------------------------------
titleScreenRoutine: ;{ 05:4118
;{ Title display logic
    call OAMClear

; Handle flashing
    ; Set default palette
    ld a, $93
    ld [bg_palette], a
    ; Jump ahead if the lower 2 bits of the high byte aren't clear
    ld a, [countdownTimerHigh]
    and %00000011 ;$03
    jr nz, .endIf_A
        ; Jump ahead if the lower byte isn't less than $10
        ld a, [countdownTimerLow]
        cp $10
        jr nc, .endIf_A
            ; Only set the palette every other frame
            bit 1, a
            jr z, .endIf_A
                ; Flash
                ld a, $90
                ld [bg_palette], a
    .endIf_A:

; Handle logic and drawing of the title star
    ; if starX < 3 then don't move it
    ld a, [titleStarX]
    cp $03
    jr c, .endIf_B
        ; Move left
        sub $02
        ld [titleStarX], a
        ; Move down
        ld a, [titleStarY]
        add $01
        ld [titleStarY], a
        ; Pointless jump (evidence of a commented out else branch?)
        jr .endIf_B
    .endIf_B:

    ; Try respawning the title star
    ; if rDIV != hFrameCounter, skip ahead
    ldh a, [rDIV]
    ld b, a
    ldh a, [hFrameCounter]
    cp b
    jr nz, .endIf_C
        ; If frame is odd, skip ahead
        and $01
        jr nz, .endIf_C
            ; Reset position of star
            ; Y position is essentially random
            ld a, b
            ld [titleStarY], a
            ; Move to right side
            ld a, $ff
            ld [titleStarX], a
    .endIf_C:

    ; Draw the title star
    ld a, [titleStarY]
    ldh [hSpriteYPixel], a
    ld a, [titleStarX]
    ldh [hSpriteXPixel], a
    ; Get the base sprite number
    ld a, SPRITE_TITLE_STAR ;$06
    ldh [hSpriteId], a
    ; Toggle the lower bit of the sprite priority bit regularly -- but this does nothing??
    ;  Perhaps the original intent was to have the sprite flicker between sprites $06 and $05
    ldh a, [hFrameCounter]
    and %00000010
    srl a
    ldh [hSpriteAttr], a
    call drawNonGameSprite_longCall

; Draw cursor
    ; Set Y position
    ld a, $74 ; Aligned with START text (normal height)
    ldh [hSpriteYPixel], a
    ; Check if the clear option is selected
    ld a, [title_clearSelected]
    and a
    jr z, .endIf_D
        ld a, $80 ; Aligned with CLEAR text
        ldh [hSpriteYPixel], a
    .endIf_D:

    ; Set x position and attributes
    ld a, $38
    ldh [hSpriteXPixel], a
    xor a
    ldh [hSpriteAttr], a
    ; Get animation frame for cursor
    ;  Animate every 4 frames using two bits from the frame counter
    ldh a, [hFrameCounter]
    and %00001100
    rlca
    rlca
    ld e, a
    ld d, $00
    ld hl, titleCursorTable
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall

; Draw sprite for save number
    ld a, [activeSaveSlot]
    add SPRITE_TITLE_FILE_1 ;$23
    ldh [hSpriteId], a
    ; Y position is same as the cursor
    ; Also, the number sprites have a ridiculous baked-in x-offset
    call drawNonGameSprite_longCall

; Draw the start text
    ld a, $44
    ldh [hSpriteXPixel], a
    ld a, $74
    ldh [hSpriteYPixel], a
    ld a, SPRITE_TITLE_START ;$00
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    
; Draw the clear text
    ; Check if it's available
    ld a, [title_showClearOption]
    and a
    jr z, .endIf_E
        ; Show "Clear" text
        ld a, $80
        ldh [hSpriteYPixel], a
        ld a, SPRITE_TITLE_CLEAR ;$01
        ldh [hSpriteId], a
        call drawNonGameSprite_longCall
    .endIf_E:
    call OAMClear.unused
;} End of display logic for title
    
;{ Title input logic
    ; Toggle clear option when select is pressed
    ldh a, [hInputRisingEdge]
    cp PAD_SELECT
    jr nz, .endIf_F
        ; Play sound effect
        ld a, sfx_square1_select
        ld [sfxRequest_square1], a
        ; Toggle flag
        ld a, [title_showClearOption]
        xor $ff
        ld [title_showClearOption], a
    .endIf_F:
    
    ; If right is pressed, increment save slot
    ldh a, [hInputRisingEdge]
    cp PAD_RIGHT
    jr nz, .endIf_G
        ; Play sound effect
        ld a, sfx_square1_select
        ld [sfxRequest_square1], a
        ; Increment slot number
        ld a, [activeSaveSlot]
        inc a
        ld [activeSaveSlot], a
        ; Wrap back to zero
        cp $03
        jr nz, .endIf_G
            xor a
            ld [activeSaveSlot], a
    .endIf_G:

    ; If left is pressed, decrement save slot
    ldh a, [hInputRisingEdge]
    cp PAD_LEFT
    jr nz, .endIf_H
        ; Play sound effect
        ld a, sfx_square1_select
        ld [sfxRequest_square1], a
        ; Decrement slot number
        ld a, [activeSaveSlot]
        dec a
        ld [activeSaveSlot], a
        ; Wrap around to slot 3
        cp $ff
        jr nz, .endIf_H
            ld a, $02
            ld [activeSaveSlot], a
    .endIf_H:
    
    ; You must hold down for clear to be selected
    xor a
    ld [title_clearSelected], a
    ; Don't bother if the option isn't shown
    ld a, [title_showClearOption]
    and a
    jr z, .endIf_I
        ; Check if down is pressed
        ldh a, [hInputPressed]
        bit B_PAD_DOWN, a
        jr z, .endIf_I
            ; Set flag
            ld a, $01
            ld [title_clearSelected], a
            ; Check edge of input
            ldh a, [hInputRisingEdge]
            bit B_PAD_DOWN, a
            jr z, .endIf_I
                ; Play sound effect
                ld a, sfx_square1_select
                ld [sfxRequest_square1], a
    .endIf_I:

    ; Exit title routine if start is not pressed
    ldh a, [hInputRisingEdge]
    cp PAD_START
        ret nz
;} End of title input logic

    ; Clear debug flag
    xor a
    ld [debugFlag], a
    ; Flash
    ld a, $93
    ld [bg_palette], a
    ; Check if save is being deleted
    ld a, [title_clearSelected]
    and a
        jr nz, .clearSaveBranch

    ; Play sound
    ld a, sfx_square1_select
    ld [sfxRequest_square1], a
    ; Play Samus fanfare (made redundant later on by loadGame_samusData)
    ld a, $12
    ld [songRequest], a

    ; Initialize flag to loading a new game
    xor a
    ld [loadingFromFile], a
    ; Enable SRAM
    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a

; Check magic number
    ; WARNING: THIS CODE IS COMPLETELY BUSTED AND ONLY WORKS ON ACCIDENT.
    ; Explanation: This routine should check if the magic number in the
    ;  save file matches the one in the ROM. In practice, only the first
    ;  byte of the magic number needs to be correct.
    ;
    ; The `cp $08` after the comparison loop makes me think that that loop
    ;  is supposed to count the number of matching bytes between the two
    ;  magic numbers (since both should have a length of 8). However, no
    ;  such counting takes place, and the comparison is merely done against
    ;  whatever happened to be the last byte that loaded from the ROM instead.
    ;
    ; Thus:
    ; - This only prevents invalid save files from being loaded because the
    ;    first byte of the magic number ($01) happens to be less than $08.
    ; - This only allows valid save files to be loaded because the byte
    ;    immediately after the magic number in ROM ($0F) happens to be
    ;    greater than $08.
    ;
    ; In other words, you could easily break this code on accident.
    ;
    ; For a fun creepypasta, take an uninitialized SRAM, and modify the
    ;  first byte of one of the save files ($A000, $A040, or $A080) to be $01.
    
    ld hl, saveFile_magicNumber
    ; Get base address of save slot
    ; de = $A000 + (activeSaveSlot * $40)
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    ld e, a
    ld d, HIGH(saveData_baseAddr) ;$A0
    ; Loop until we find a mismatch between the magic number in ROM and the save slot
    .checkLoop:
        ld a, [hl+]
        ld b, a
        ld a, [de]
        inc de
        cp b
    jr z, .checkLoop
    ; Check if the last byte read from ROM was greater than $08
    ld a, b
    cp $08
    jr c, .endIf_J
        ld a, $ff
        ld [loadingFromFile], a
    .endIf_J:

    ; Save the last save slot used
    ld a, [activeSaveSlot]
    ld [saveLastSlot], a
    ; Disable SRAM
    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a
    ; New game
    ld a, _id_gameMode_newGame
    ldh [hGameMode], a
    ; If loading from a file, ignore the game mode being set to new game
    ld a, [loadingFromFile]
    and a
        ret z
    ; Load from file
    ld a, _id_gameMode_loadSave
    ldh [hGameMode], a
ret

; Clear file
.clearSaveBranch:
    ; Play sound effect
    ld a, sfx_noise_clearedSaveFile
    ld [sfxRequest_noise], a
    ; Get base address of save slot
    ; de = $A000 + (activeSaveSlot * $40)
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    ld l, a
    ld h, HIGH(saveData_baseAddr) ; $A0
    ; Enable SRAM
    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a
    ; Erase first two bytes (part w/the magic number)
    xor a
    ld [hl+], a
    ld [hl], a
    ; Disable SRAM
    ld [rRAMG], a
    ; Get rid of the clear option
    xor a
    ld [title_showClearOption], a
ret
;}

;------------------------------------------------------------------------------
; Used by title
titleCursorTable: ; 05:42E1
    db SPRITE_TITLE_CURSOR_1 ;$02
    db SPRITE_TITLE_CURSOR_2 ;$03
    db SPRITE_TITLE_CURSOR_3 ;$04
    db SPRITE_TITLE_CURSOR_2 ;$03

;------------------------------------------------------------------------------
; Screen transitions
doorPointerTable:: ; 05:42E5
include "maps/door_macros.asm"
include "maps/doors.asm"
doorData_end: ; Label used by the LAMP editor

;------------------------------------------------------------------------------
; Game Mode $13 - Credits
creditsRoutine:: ;{ 05:55A3
    ; Set sprite pixel to Samus' position
    ldh a, [hSamusYPixel]
    ldh [hSpriteYPixel], a
    ldh a, [hSamusXPixel]
    ldh [hSpriteXPixel], a

    call credits_animateSamus
    call credits_scrollHandler
    call credits_drawTimer
    call credits_moveStars
    call credits_drawStars
    jp OAMClear.unused
;}

credits_drawTimer: ;{ 05:55BE
    ; Check if credits are done
    ld a, [credits_scrollingDone]
    and a
        ret z
    ; Draw hours
    ld a, $88
    ldh [hSpriteYPixel], a
    ld a, $42
    ldh [hSpriteXPixel], a
    ld a, [gameTimeHours]
    call credits_drawTimerDigits
    ; Draw minutes
    ld a, $56
    ldh [hSpriteXPixel], a
    ld a, [gameTimeMinutes]
    ; fallthrough
;}

; Draw two digits of ending timer
credits_drawTimerDigits: ;{ 05:4000
    ; Temp storage for timer number
    ldh [hTemp.b], a
    ; Extract the tens digit
    swap a
    or $f0 ; Adjust the value for display
    call credits_drawOneDigit
    ; Reload timer value from temp
    ldh a, [hTemp.b]
    or $f0 ; Adjust the value for display
    ; fallthrough

; Draw one digit of ending timer
credits_drawOneDigit: ;{ 05:4015
    ; Temp storage for the digit to be displayed
    ldh [hTemp.a], a
    ; HL = oam buffer pointer
    ld h, HIGH(wram_oamBuffer)
    ldh a, [hOamBufferIndex]
    ld l, a
    ; Write y pixel
    ldh a, [hSpriteYPixel]
    ld [hl+], a
    ; Write x pixel
    ldh a, [hSpriteXPixel]
    ld [hl+], a
    ; Increment X pixel position for next digit
    add $08
    ldh [hSpriteXPixel], a
    ; Reload tile number from temp, write tile number
    ldh a, [hTemp.a]
    ld [hl+], a
    ; Write sprite attribute
    ldh a, [hSpriteAttr]
    ld [hl+], a
    ; Store final value of oam index
    ld a, l
    ldh [hOamBufferIndex], a
ret ;}

credits_moveStars: ;{ 05:55DC - Move the stars during the credits
    ; Iterate through all 16 stars
    ld hl, credits_starArray
    ld b, $10
    .starLoop:
        ; Move down every 4th frame
        ldh a, [hFrameCounter]
        and $03
        jr nz, .endIf_A
            ; move down one pixel
            ld a, [hl]
            add $01
            ld [hl], a
            ; Loop stars back to the top
            cp $a0
            jr c, .endIf_A
                ld a, $10
                ld [hl], a
        .endIf_A:
        
        ; Get x coordinate
        inc hl
        ; Move left every frame
        ld a, [hl]
        sub $01
        ld [hl], a
        ; Once the stars reach the left edge
        cp $f8
        jr c, .endIf_B
            ; Warp them back to the right edge
            ld a, $a8
            ld [hl], a
        .endIf_B:
        
        ; Get y coordinate of next star
        inc hl
        ; Check loop counter
        dec b
    jr nz, .starLoop
ret
;}

credits_drawStars: ;{ 05:5603 - Draw stars to the OAM buffer during credits
    ; Iterate through all 16 stars
    ld hl, credits_starArray
    ld b, $10
    .starLoop:
        ; Load y pos and x pos of star
        ld a, [hl+]
        ldh [hSpriteYPixel], a
        ld a, [hl+]
        ldh [hSpriteXPixel], a
        ; LSB of loop counter determines if star graphic is $1B or $1C
        ld a, b
        and $01
        add SPRITE_CREDITS_STAR_SMALL ;$1B
        ldh [hSpriteId], a
        ; push/pop variables to avoid clobbering
        push hl
        push bc
            call drawNonGameSprite_longCall
        pop bc
        pop hl
        ; Check loop counter
        dec b
    jr nz, .starLoop
ret
;}

;------------------------------------------------------------------------------
; Animate Samus during credits
credits_animateSamus: ;{ 05:5620
    ld a, [credits_samusAnimState]
    rst LOW(RST_28)
        dw .standingStart     ; 00
        dw .running           ; 01
        dw $0000              ; 02
        dw .spinRising        ; 03
        dw .spinFalling       ; 04
        dw .suitless_kneeling ; 05
        ; States $6-$12 are Samus untying her hair
        dw .untying_frameA ; $06
        dw .untying_frameB ; $07
        dw .untying_frameC ; $08
        dw .untying_frameD ; $09
        dw .untying_frameE ; $0A
        dw .untying_frameF ; $0B
        dw .untying_frameG ; $0C
        dw .untying_frameH ; $0D
        dw .untying_frameI ; $0E
        dw .untying_frameJ ; $0F
        dw .untying_frameK ; $10
        dw .untying_frameL ; $11
        dw .untying_frameM ; $12
        
        dw .suited_kneeling    ; $13
        dw .suited_standingEnd ; $14
        dw .hairWaving         ; $15

; Animation state functions {
.hairWaving: ; $15 - Animate Suitless Samus's hair flowing
    ; Animate every 16th frame
    ldh a, [hFrameCounter]
    and $10
    swap a
    ; Add 0 or 1 to this base index of the hair waving animation
    add $13
    jp credits_drawSamus

.suited_standingEnd: ; $14 - Draw Suited Samus standing
    ; Stand forever
    ld a, $0a
    jp credits_drawSamus

.suited_kneeling: ; $13 - Draw Suited Samus kneeling
    ld a, $08
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set countdown timer for next state (for no reason?)
    ld a, $30
    ld [countdownTimerLow], a
    ; Incrment state to suited_standingEnd
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameA: ; $06 - Draw Suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameB: ; $07 - Draw suitless Samus reaching up to her hair
    ld a, $0c
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $10
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameC: ; $08 - Draw suitless Samus untying her hair
    ld a, $0d
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameD: ; $09 - Draw suitless Samus reaching up to her hair (lower her hand, I guess)
    ld a, $0c
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameE: ; $0A - Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameF: ; $0B - Draw suitless Samus turning her head left
    ld a, $0e
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameG: ; $0C - Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameH: ; $0D - Draw suitless Samus turning her head right
    ld a, $0f
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameI: ; $0E - Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $0a
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameJ: ; $0F - Draw suitless Samus turning her head left
    ld a, $0e
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $0a
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameK: ; $10 - Draw suitless Samus unfurling her hair (frame 1)
    ld a, $10
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $0a
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameL: ; $11 - Draw suitless Samus unfurling her hair (frame 2)
    ld a, $11
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $20
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameM: ; $12 - Draw suitless Samus unfurling her hair (frame 3)
    ld a, $12
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set next state to hair waving
    ld a, $15
    ld [credits_samusAnimState], a
ret

.suitless_kneeling: ; $05 - Draw suitless Samus kneeling
    ld a, $09
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $30
    ld [countdownTimerLow], a
    ; Increment state to untying animation
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.spinFalling: ; $04 - Draw Samus spin jumping (falling)
    ; Move down
    ldh a, [hSamusYPixel]
    add $03
    ldh [hSamusYPixel], a
    ; Frame to Render = 4 + (hFrameCounter mod 4)
    ldh a, [hFrameCounter]
    and $03
    add $04
    call credits_drawSamus
    ; Detect when Samus hits the ground (what ground?)
    ldh a, [hSamusYPixel]
    and $fc ; Ignore the lower bits to give some leeway
    cp $60
        ret nz

    ; Set timer for next state
    ld a, $20
    ld [countdownTimerLow], a
    ; Select ending
    ld a, [gameTimeHours]
    cp $03
    jr nc, .else_A
        ; Best ending - Suitless kneeling -> hair untying
        ld a, [credits_samusAnimState]
        inc a
        ld [credits_samusAnimState], a
        ret
    .else_A:
        ; Second best - Suited kneeling -> suited standing
        ld a, $13
        ld [credits_samusAnimState], a
        ret
; end state

.spinRising: ; $03 - Draw Samus spin jumping (rising)
    ; Move Samus up until she reaches a certain point
    ldh a, [hSamusYPixel]
    and $f0 ; Ignore the lower bits to give some leeway
    cp $e0
    jr z, .endIf_B
        ; Move up
        ldh a, [hSamusYPixel]
        sub $03
        ldh [hSamusYPixel], a
    .endIf_B:
    ; Frame to Render = 4 + (hFrameCounter mod 4)
    ldh a, [hFrameCounter]
    and $03
    add $04
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Increment state to falling
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.standingStart: ; $00 - Draw suited Samus standing
    ld a, $0a
    call credits_drawSamus
    ; Worst ending (>= 7 hours) - Samus only stands
    ld a, [gameTimeHours]
    cp $07
        ret nc
    ; Wait for timer to expire ($FF frames, as set in prepareCreditsRoutine)
    ld a, [countdownTimerLow]
    and a
        ret nz

    ; Initialize counters for running animation
    xor a
    ld [credits_runAnimCounter], a
    ld [credits_runAnimFrame], a
    ; Set timer to $1200 (4608 frames, or 76.8 seconds)
    ld [countdownTimerLow], a ; Shouldn't this be countdownTimerLow?
    ld a, $12
    ld [countdownTimerHigh], a
    ; Increment state to running
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.running: ; $01 - Draw Samus running
    ; Increment counter between animation frames
    ld a, [credits_runAnimCounter]
    inc a
    ld [credits_runAnimCounter], a
    cp $06
    jr c, .endIf_C
        ; Reset counter
        xor a
        ld [credits_runAnimCounter], a
        ; Increment frame being displayed (in range 0-3)
        ld a, [credits_runAnimFrame]
        inc a
        ld [credits_runAnimFrame], a
        cp $04
        jr nz, .endIf_C
            ld a, $00
            ld [credits_runAnimFrame], a
    .endIf_C:

    ld a, [credits_runAnimFrame]
    call credits_drawSamus

    ; Second-worst ending: (between 5 and 7 hours)
    ; - Samus never stops running, so we never move on from this animation procedure
    ld a, [gameTimeHours]
    cp $05
        ret nc
    ; Keep running until credits stop
    ld a, [credits_scrollingDone]
    and a
        ret z

    ; Set timer for next state to $0040
    xor a
    ld [countdownTimerHigh], a
    ld a, $40
    ld [countdownTimerLow], a
    ; Set anim state to jumping
    ld a, [credits_samusAnimState]
    inc a
    inc a
    ld [credits_samusAnimState], a
ret

;}
;}

;------------------------------------------------------------------------------
credits_paletteFade: ; 05:5877
    db $ff, $ff, $fb, $eb, $e7, $a7, $a3, $93

; Game Mode $12 - Prepare Credits
prepareCredits: ;{ 05:587F
    ld hl, credits_paletteFade
    ; countdownTimer is set to $FF by missile refill
    ld a, [countdownTimerLow]
    and a
    jr z, .endIf_A
        ; Use upper 3 bits of countdownTimer to index into credits_paletteFade
        ; - Iterates through the list from end to beginning
        and $f0
        swap a
        srl a
        ld e, a
        ld d, $00
        add hl, de
        ; Set palette
        ld a, [hl]
        ld [bg_palette], a
        ld [ob_palette0], a
        ld [ob_palette1], a
        ; Fadeout until countdown timer reaches $0E
        ld a, [countdownTimerLow]
        cp $0e
            ret nc
        ; Clear timer
        xor a
        ld [countdownTimerLow], a
        ; Remove the low health beep sound
        ld a, $ff
        ld [sfxRequest_lowHealthBeep], a
    .endIf_A:

    ; Disable LCD
    ld a, $03
    ldh [rLCDC], a
    ; Reset palette
    ld a, $93
    ld [bg_palette], a
    ld [ob_palette0], a
    ld a, $43
    ld [ob_palette1], a

    call clearTilemaps
    ; Clear OAM buffer
    ld hl, wram_oamBuffer + $FF ; $C0FF
    ld a, $ff
    ld c, $01
    ld b, $00
    .loop_A:
            ld [hl-], a
            dec b
        jr nz, .loop_A
        dec c
    jr nz, .loop_A

    ; Load various graphics
    ld bc, $0200
    ld hl, gfx_creditsFont
    ld de, vramDest_creditsFont
    call copyToVram
    
    ld bc, $1000
    ld hl, gfx_creditsSprTiles
    ld de, vramDest_creditsSpriteChr
    call copyToVram
    
    ld bc, $0100
    ld hl, gfx_theEnd
    ld de, vramDest_theEnd
    call copyToVram
    
    ld bc, $0100
    ld hl, gfx_creditsNumbers
    ld de, vramDest_creditsNumbers
    call copyToVram
    
    ; Initialize credits text pointer
    ld a, LOW(creditsText)
    ld [credits_textPointerLow], a
    ld a, HIGH(creditsText)
    ld [credits_textPointerHigh], a
    
    ; Initialize star array
    ld hl, credits_starPositions
    ld de, credits_starArray
    ld b, $10
    .loop_B:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .loop_B

    call loadCreditsText

    ; Reset scroll
    xor a
    ld [scrollY], a
    ld [scrollX], a

    ; Reactivate display
    ld a, $c3
    ldh [rLCDC], a

    ; Set timer for initial animation state (standing still in suit)
    ld a, $ff
    ld [countdownTimerLow], a
    ; Set Samus' position
    ld a, $60
    ldh [hSamusYPixel], a
    ld a, $88
    ldh [hSamusXPixel], a
    ; Play credits music
    ld a, $13
    ld [songRequest], a
    ; Init animation state
    xor a
    ld [credits_samusAnimState], a
    ; Move to credits game mode
    ld a, _id_gameMode_Credits
    ldh [hGameMode], a
ret
;}

;------------------------------------------------------------------------------
; Lets VBlank_drawCreditsLine know when another line is ready to be displayed
credits_scrollHandler: ;{ 05:593E
    ; Load credits text pointer
    ld a, [credits_textPointerLow]
    ld l, a
    ld a, [credits_textPointerHigh]
    ld h, a
    ; Load character
    ld a, [hl]
    ; Check if we're at the end of the credits
    cp $f0
    jr nz, .else
        ld a, $01
        ld [credits_scrollingDone], a
        ret
    .else:
        ; Only scroll every 4th frame
        ldh a, [hFrameCounter]
        and $03
            ret nz
        ; Scroll a pixel
        ld a, [scrollY]
        inc a
        ld [scrollY], a
        ; Exit unless we're on an 8-pixel boundary
        ld a, [scrollY]
        and $07
            ret nz
        ; Adjust cursor position
        ld a, [scrollY]
        add $a0 ; Set Y cursor to just below the bottom of the screen
        ld [tileY], a
        ld a, $08 ; Set X cursor position to near the left edge
        ld [tileX], a
        call getTilemapAddress
        ; Queue up the next line to draw
        ld a, BANK(creditsText)
        ld [vramTransfer_srcBank], a
        ld a, [pTilemapDestLow]
        ldh [hVramTransfer.destAddrLow], a
        ld a, [pTilemapDestHigh]
        ldh [hVramTransfer.destAddrHigh], a
        ld a, $14
        ldh [hVramTransfer.sizeLow], a
        xor a
        ldh [hVramTransfer.sizeHigh], a
        ; check if newline
        ld a, [hl]
        cp $f1
        jr .isNewline
            ld a, l
            ldh [hVramTransfer.srcAddrLow], a
            ld a, h
            ldh [hVramTransfer.srcAddrHigh], a
            ld de, $0014
            add hl, de
            jr .exit
        .isNewline:
            ld a, LOW(.newline)
            ldh [hVramTransfer.srcAddrLow], a
            ld a, HIGH(.newline)
            ldh [hVramTransfer.srcAddrHigh], a
            inc hl
        .exit:
        ld a, l
        ld [credits_textPointerLow], a
        ld a, h
        ld [credits_textPointerHigh], a

        ld a, $ff
        ld [vramTransferFlag], a
        ret
.newline:
    ds 14
;} end proc

;------------------------------------------------------------------------------
credits_drawSamus: ;{ 05:5989
    rst LOW(RST_28)
        dw .run_frameA ; 00 - Samus running
        dw .run_frameB ; 01 - Samus running
        dw .run_frameC ; 02 - Samus running
        dw .run_frameD ; 03 - Samus running
        
        dw .jump_frameA ; 04 - Spin jump
        dw .jump_frameB ; 05 - Spin jump
        dw .jump_frameC ; 06 - Spin jump
        dw .jump_frameD ; 07 - Spin jump
        
        dw .suited_kneeling   ; 08 - Suited Samus kneeling (ready to jump)
        dw .suitless_kneeling ; 09 - Suitless Samus kneeling
        dw .suited_standing   ; 0A - Suited Samus standing
        
        dw .suitless_frameA ; 0B - Suitless Samus hair up, hand down
        dw .suitless_frameB ; 0C - Suitless Samus reaching up to hair
        dw .suitless_frameC ; 0D - Suitless Samus untying bun
        dw .suitless_frameD ; 0E - Suitless Samus head turned left
        dw .suitless_frameE ; 0F - Suitless Samus head turned right
        dw .suitless_frameF ; 10 - Suitless Samus hair unfurling 1
        dw .suitless_frameG ; 11 - Suitless Samus hair unfurling 2
        dw .suitless_frameH ; 12 - Suitless Samus hair unfurling 3
        
        dw .hairWaving_frameA ; 13 - Suitless Samus hair waving 1
        dw .hairWaving_frameB ; 14 - Suitless Samus hair waving 2

; Functions called by table {
.run_frameA:
    ld a, SPRITE_CREDITS_SUITED_RUNNING_TOP_1 ;$08
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, SPRITE_CREDITS_SUITED_RUNNING_BOTTOM_1 ;$0b
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall


.run_frameB:
    ld a, SPRITE_CREDITS_SUITED_RUNNING_TOP_2 ;$09
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, SPRITE_CREDITS_SUITED_RUNNING_BOTTOM_2 ;$0c
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.run_frameC:
    ld a, SPRITE_CREDITS_SUITED_RUNNING_TOP_3 ;$0a
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Flip bottom, adjust position
    ld a, OAM_XFLIP
    ldh [hSpriteAttr], a
    ldh a, [hSpriteXPixel]
    dec a
    ldh [hSpriteXPixel], a
    ld a, SPRITE_CREDITS_SUITED_RUNNING_BOTTOM_1 ;$0b
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Clear flip
    xor a
    ldh [hSpriteAttr], a
ret

.run_frameD:
    ld a, SPRITE_CREDITS_SUITED_RUNNING_TOP_2 ;$09
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Flip bottom
    ld a, OAM_XFLIP
    ldh [hSpriteAttr], a
    ld a, SPRITE_CREDITS_SUITED_RUNNING_BOTTOM_2 ;$0c
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Clear flip
    xor a
    ldh [hSpriteAttr], a
ret

.jump_frameA:
    ld a, SPRITE_CREDITS_SPINJUMP_1 ;$1f
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.jump_frameB:
    ld a, SPRITE_CREDITS_SPINJUMP_2 ;$20
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.jump_frameC:
    ld a, SPRITE_CREDITS_SPINJUMP_3 ;$21
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.jump_frameD:
    ld a, SPRITE_CREDITS_SPINJUMP_4 ;$22
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.suited_standing:
    ld a, SPRITE_CREDITS_SUITED_STANDING ;$07
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.suited_kneeling:
    ld a, SPRITE_CREDITS_SUITED_KNEELING ;$12
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.suitless_kneeling:
    ld a, SPRITE_CREDITS_SUITLESS_KNEELING ;$11
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.suitless_frameA:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_1 ;$0e
    jr .suitless_common

.suitless_frameB:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_1 ;$0e
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, SPRITE_CREDITS_SUITLESS_ARM_2 ;$13
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, SPRITE_CREDITS_SUITLESS_BOTTOM ;$10
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.suitless_frameC:
    ld a, SPRITE_CREDITS_SUITLESS_ARM_3 ;$14
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, SPRITE_CREDITS_SUITLESS_BOTTOM ;$10
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall

.suitless_frameD:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_2 ;$15
    jr .suitless_common

.suitless_frameE:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_3 ;$16
    jr .suitless_common

.suitless_frameF:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_4 ;$17
    jr .suitless_common

.suitless_frameG:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_5 ;$18
    jr .suitless_common

.suitless_frameH:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_6 ;$19
    jr .suitless_common

.hairWaving_frameA:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_5 ;$18
    jr .suitless_common

.hairWaving_frameB:
    ld a, SPRITE_CREDITS_SUITLESS_HEAD_7 ;$1a
.suitless_common:
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, SPRITE_CREDITS_SUITLESS_ARM_1 ;$0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, SPRITE_CREDITS_SUITLESS_BOTTOM ;$10
    ldh [hSpriteId], a
    jp drawNonGameSprite_longCall
;}
;}

; Set of initial positions for stars
credits_starPositions: ;{ 05:5B14
    ;  ( y, x )
    db $28, $90
    db $18, $70
    db $68, $30
    db $50, $88
    db $40, $18
    db $18, $20
    db $90, $68
    db $48, $40
;}

; 05:5B34 -- Title screen tilemap
titleTilemap: include "data/title_tilemap.asm"

; 05:5F34 - Includes credits font, item font, and sprite numbers
;  The title screen assumes these for files are contiguous
gfx_titleScreen:     incbin "gfx/titleCredits/titleScreen.chr",   0,$A00
gfx_creditsFont:     incbin "gfx/titleCredits/creditsFont.chr",   0,$300
gfx_itemFont:        incbin "gfx/titleCredits/itemFont.chr",      0,$200
gfx_creditsNumbers:  incbin "gfx/titleCredits/creditsNumbers.chr",0,$100

; 05:6F34
gfx_creditsSprTiles: incbin "gfx/titleCredits/creditsSprTiles.chr"

; 05:7E34
gfx_theEnd: incbin "gfx/titleCredits/theEnd.chr"

; 06:7920
creditsText: include "data/credits.asm"
bank5_freespace: ; 05:7F34 -- filled with $00 (nop)

;EoF
