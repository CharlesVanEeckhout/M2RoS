; Sprite Pointers
samusSpritePointerTable:
    dw sprite_samusFaceScreen ; $00 - Facing screen
    dw sprite_samusStandRight ; $01 - Standing (right)
    dw sprite_samusStandRightAimUp ; $02 - Standing (right aiming up)
    dw sprite_samusRunRight_frame1 ; $03 - Running (right frame 1) Jump-start (right)
    dw sprite_samusRunRight_frame2 ; $04 - Running (right frame 2)
    dw sprite_samusRunRight_frame3 ; $05 - Running (right frame 3)
    dw sprite_samusRunRightShooting_frame1 ; $06 - Running (right firing forwards frame 1)
    dw sprite_samusRunRightShooting_frame2 ; $07 - Running (right firing forwards frame 2)
    dw sprite_samusRunRightShooting_frame3 ; $08 - Running (right firing forwards frame 3)
    dw sprite_samusJumpRight ; $09 - Jumping (facing right)
    dw sprite_samusJumpRightAimUp ; $0A - Jumping (facing right aiming up)
    dw sprite_samusCrouchRight ; $0B - Crouching (facing right)
    dw sprite_samusJumpRightAimDown ; $0C - Jumping (facing right aiming down)
    dw sprite_samusFaceScreen ; $0D - Facing screen (unused? duplicate)
    dw sprite_samusStandLeft ; $0E - Standing (left)
    dw sprite_samusStandLeftAimUp ; $0F - Standing (left aiming up)
    dw sprite_samusRunLeft_frame1 ; $10 - Running (left frame 1) Jump-start (left)
    dw sprite_samusRunLeft_frame2 ; $11 - Running (left frame 2)
    dw sprite_samusRunLeft_frame3 ; $12 - Running (left frame 3)
    dw sprite_samusRunLeftShooting_frame1 ; $13 - Running (left firing forwards frame 1)
    dw sprite_samusRunLeftShooting_frame2 ; $14 - Running (left firing forwards frame 2)
    dw sprite_samusRunLeftShooting_frame3 ; $15 - Running (left firing forwards frame 3)
    dw sprite_samusJumpLeft ; $16 - Jumping (facing left)
    dw sprite_samusJumpLeftAimUp ; $17 - Jumping (facing left aiming up)
    dw sprite_samusCrouchLeft ; $18 - Crouching (facing left)
    dw sprite_samusJumpLeftAimDown ; $19 - Jumping (facing left aiming down)
    dw sprite_samusJumpRight_frame1 ; $1A - Spin jump (right frame 1)
    dw sprite_samusJumpRight_frame2 ; $1B - Spin jump (right frame 2)
    dw sprite_samusJumpRight_frame3 ; $1C - Spin jump (right frame 3)
    dw sprite_samusJumpRight_frame4 ; $1D - Spin jump (right frame 4)
    dw sprite_samusMorphLeft_frame1 ; $1E - Morph (left frame 1)
    dw sprite_samusMorphLeft_frame2 ; $1F - Morph (left frame 2)
    dw sprite_samusMorphLeft_frame3 ; $20 - Morph (left frame 3)
    dw sprite_samusMorphLeft_frame4 ; $21 - Morph (left frame 4)
    dw sprite_samusJumpLeft_frame1 ; $22 - Spin jump (left frame 1)
    dw sprite_samusJumpLeft_frame2 ; $23 - Spin jump (left frame 2)
    dw sprite_samusJumpLeft_frame3 ; $24 - Spin jump (left frame 3)
    dw sprite_samusJumpLeft_frame4 ; $25 - Spin jump (left frame 4)
    dw sprite_samusMorphRight_frame1 ; $26 - Morph (right frame 1)
    dw sprite_samusMorphRight_frame2 ; $27 - Morph (right frame 2)
    dw sprite_samusMorphRight_frame3 ; $28 - Morph (right frame 3)
    dw sprite_samusMorphRight_frame4 ; $29 - Morph (right frame 4)
    dw sprite_samusBeam ; $2A - Beam (horizontal) (unused as the sprite is drawn manually)
    dw sprite_samusRunRightAimUp_frame1 ; $2B - Running (right aiming up frame 1)
    dw sprite_samusRunRightAimUp_frame2 ; $2C - Running (right aiming up frame 2)
    dw sprite_samusRunRightAimUp_frame3 ; $2D - Running (right aiming up frame 3)
    dw sprite_samusRunLeftAimUp_frame1 ; $2E - Running (left aiming up frame 1)
    dw sprite_samusRunLeftAimUp_frame2 ; $2F - Running (left aiming up frame 2)
    dw sprite_samusRunLeftAimUp_frame3 ; $30 - Running (left aiming up frame 3)
    dw sprite_samusBombExplosion_frame4 ; $31 - Bomb Explosion (frame 4)
    dw sprite_samusBombExplosion_frame3 ; $32 - Bomb Explosion (frame 3)
    dw sprite_samusBombExplosion_frame2 ; $33 - Bomb Explosion (frame 2)
    dw sprite_samusBombExplosion_frame1 ; $34 - Bomb Explosion (frame 1)
    dw sprite_samusBomb_frame1 ; $35 - Bomb (frame 1)
    dw sprite_samusBomb_frame2 ; $36 - Bomb (frame 2)
    dw sprite_samusSpiderLeft_frame1 ; $37 - Spider (left frame 1)
    dw sprite_samusSpiderLeft_frame2 ; $38 - Spider (left frame 2)
    dw sprite_samusSpiderLeft_frame3 ; $39 - Spider (left frame 3)
    dw sprite_samusSpiderLeft_frame4 ; $3A - Spider (left frame 4)
    dw sprite_samusSpiderRight_frame1 ; $3B - Spider (right frame 1)
    dw sprite_samusSpiderRight_frame2 ; $3C - Spider (right frame 2)
    dw sprite_samusSpiderRight_frame3 ; $3D - Spider (right frame 3)
    dw sprite_samusSpiderRight_frame4 ; $3E - Spider (right frame 4)
    dw sprite_samusHudMetroid_frame1 ; $3F - Metroid counter (frame 1)
    dw sprite_samusHudMetroid_frame2 ; $40 - Metroid counter (frame 2)
    dw sprite_samusUnknownMessage ; $41 - Unknown sprite
    dw sprite_samusSavePressStart ; $42 - "PRESS START" (Save text)
    dw sprite_samusSaveCompleted ; $43 - "COMPLETED" (Save text)
    dw sprite_samusHudLCounter ; $44 - L Counter (unused as the Metroid sprite is replaced manually in bank 0)


; Metasprite Data:
sprite_samusHudLCounter: ; L counter
    db   0,  0, $36, $80
    db   0,  8, $0F, $80
    db METASPRITE_END

sprite_samusSaveCompleted: ; "COMPLETED"
    db   0,  0, $C2, $80
    db   0,  8, $CE, $80
    db   0, 16, $CC, $80
    db   0, 24, $CF, $80
    db   0, 32, $CB, $80
    db   0, 40, $C4, $80
    db   0, 48, $D3, $80
    db   0, 56, $C4, $80
    db   0, 64, $C3, $80
    db METASPRITE_END
sprite_samusSavePressStart: ; "PRESS START"
    db   0,  0, $CF, $00
    db   0,  8, $D1, $00
    db   0, 16, $C4, $00
    db   0, 24, $D2, $00
    db   0, 32, $D2, $00
    db   0, 48, $D2, $00
    db   0, 56, $D3, $00
    db   0, 64, $C0, $00
    db   0, 72, $D1, $00
    db   0, 80, $D3, $00
    db METASPRITE_END
sprite_samusUnknownMessage: ; Unknown. Possibly a message (like the two sprites above), but doesn't appear to match any obvious character mapping
    db   0,  0, $ED, $00
    db   0,  8, $EE, $00
    db   0, 16, $EF, $00
    db   0, 24, $F5, $00
    db   0, 32, $F5, $00
    db   0, 48, $F7, $00
    db   0, 56, $F8, $00
    db   0, 64, $F9, $00
    db   0, 72, $FA, $00
    db   0, 80, $FB, $00
    db METASPRITE_END

sprite_samusBeam:
    db  -4, -4, $7E, $00
    db METASPRITE_END

sprite_samusMorphLeft_frame1:
    db   4, -8, $59, $00
    db   4,  0, $5A, $00
    db  12, -8, $69, $00
    db  12,  0, $6A, $00
    db METASPRITE_END
sprite_samusMorphLeft_frame2:
    db   3, -8, $5A, $20
    db   3,  0, $6A, $40
    db  11, -8, $59, $40
    db  11,  0, $69, $20
    db METASPRITE_END
sprite_samusMorphLeft_frame3:
    db   4, -8, $6A, $60
    db   4,  0, $69, $60
    db  12, -8, $5A, $60
    db  12,  0, $59, $60
    db METASPRITE_END
sprite_samusMorphLeft_frame4:
    db   3, -8, $69, $40
    db   3,  0, $59, $20
    db  11, -8, $6A, $20
    db  11,  0, $5A, $40
    db METASPRITE_END

sprite_samusMorphRight_frame1:
    db   4, -8, $5A, $20
    db   4,  0, $59, $20
    db  12, -8, $6A, $20
    db  12,  0, $69, $20
    db METASPRITE_END
sprite_samusMorphRight_frame2:
    db   3, -8, $6A, $60
    db   3,  0, $5A, $00
    db  11, -8, $69, $00
    db  11,  0, $59, $60
    db METASPRITE_END
sprite_samusMorphRight_frame3:
    db   4, -8, $69, $40
    db   4,  0, $6A, $40
    db  12, -8, $59, $40
    db  12,  0, $5A, $40
    db METASPRITE_END
sprite_samusMorphRight_frame4:
    db   3, -8, $59, $00
    db   3,  0, $69, $60
    db  11, -8, $5A, $60
    db  11,  0, $6A, $00
    db METASPRITE_END

sprite_samusJumpRight_frame1:
    db   0,-12, $50, $00
    db   0, -4, $51, $00
    db   0,  4, $52, $00
    db   8,-12, $60, $00
    db   8, -4, $61, $00
    db   8,  4, $62, $00
    db METASPRITE_END
sprite_samusJumpRight_frame2:
    db  -4, -8, $56, $60
    db  -4,  0, $55, $60
    db   4, -8, $64, $60
    db   4,  0, $63, $60
    db  12, -8, $54, $60
    db  12,  0, $53, $60
    db METASPRITE_END
sprite_samusJumpRight_frame3:
    db   0,-12, $62, $60
    db   0, -4, $61, $60
    db   0,  4, $60, $60
    db   8,-12, $52, $60
    db   8, -4, $51, $60
    db   8,  4, $50, $60
    db METASPRITE_END
sprite_samusJumpRight_frame4:
    db  -4, -8, $53, $00
    db  -4,  0, $54, $00
    db   4, -8, $63, $00
    db   4,  0, $64, $00
    db  12, -8, $55, $00
    db  12,  0, $56, $00
    db METASPRITE_END

sprite_samusJumpLeft_frame1:
    db   0,-12, $52, $20
    db   0, -4, $51, $20
    db   0,  4, $50, $20
    db   8,-12, $62, $20
    db   8, -4, $61, $20
    db   8,  4, $60, $20
    db METASPRITE_END
sprite_samusJumpLeft_frame2:
    db  -4, -8, $55, $40
    db  -4,  0, $56, $40
    db   4, -8, $63, $40
    db   4,  0, $64, $40
    db  12, -8, $53, $40
    db  12,  0, $54, $40
    db METASPRITE_END
sprite_samusJumpLeft_frame3:
    db   0,-12, $60, $40
    db   0, -4, $61, $40
    db   0,  4, $62, $40
    db   8,-12, $50, $40
    db   8, -4, $51, $40
    db   8,  4, $52, $40
    db METASPRITE_END
sprite_samusJumpLeft_frame4:
    db  -4, -8, $54, $20
    db  -4,  0, $53, $20
    db   4, -8, $64, $20
    db   4,  0, $63, $20
    db  12, -8, $56, $20
    db  12,  0, $55, $20
    db METASPRITE_END

sprite_samusFaceScreen:
    db -20,-12, $00, $00
    db -20, -4, $01, $00
    db -20,  4, $02, $00
    db -12,-12, $10, $00
    db -12, -4, $11, $00
    db -12,  4, $12, $00
    db  -4,-12, $20, $00
    db  -4, -4, $21, $00
    db  -4,  4, $22, $00
    db   4,-12, $30, $00
    db   4, -4, $31, $00
    db   4,  4, $32, $00
    db  12,-12, $40, $00
    db  12, -4, $41, $00
    db  12,  4, $42, $00
    db METASPRITE_END

sprite_samusStandRight:
    db -20, -8, $03, $00
    db -20,  0, $04, $00
    db -12, -8, $13, $00
    db -12,  0, $14, $00
    db  -7,  6, $09, $00
    db  -4, -8, $23, $00
    db  -4,  0, $24, $00
    db   4, -8, $34, $00
    db   4,  0, $35, $00
    db  12,-16, $43, $00
    db  12, -8, $44, $00
    db  12,  0, $45, $00
    db METASPRITE_END
sprite_samusStandLeft:
    db -20, -8, $04, $20
    db -20,  0, $06, $00
    db -12, -8, $15, $00
    db -12,  0, $16, $00
    db  -7,-13, $09, $20
    db  -4, -8, $25, $00
    db  -4,  0, $26, $00
    db   4, -8, $35, $20
    db   4,  0, $34, $20
    db  12, -8, $45, $20
    db  12,  0, $44, $20
    db  12,  8, $43, $20
    db METASPRITE_END

sprite_samusStandRightAimUp:
    db -26, -2, $08, $00
    db -20, -8, $17, $00
    db -20,  0, $18, $00
    db -12, -8, $27, $00
    db -12,  0, $28, $00
    db  -4, -8, $37, $00
    db  -4,  0, $38, $00
    db   4, -8, $34, $00
    db   4,  0, $35, $00
    db  12,-16, $43, $00
    db  12, -8, $44, $00
    db  12,  0, $45, $00
    db METASPRITE_END
sprite_samusStandLeftAimUp:
    db -26, -6, $08, $00
    db -20, -8, $47, $00
    db -20,  0, $48, $00
    db -12, -8, $57, $00
    db -12,  0, $58, $00
    db  -4, -8, $38, $20
    db  -4,  0, $37, $20
    db   4, -8, $35, $20
    db   4,  0, $34, $20
    db  12, -8, $45, $20
    db  12,  0, $44, $20
    db  12,  8, $43, $20
    db METASPRITE_END

sprite_samusRunRight_frame1:
    db -20, -4, $0A, $00
    db -20,  4, $0B, $00
    db -12,-12, $19, $00
    db -12, -4, $1A, $00
    db -12,  4, $1B, $00
    db  -4, -4, $2A, $00
    db  -4,  4, $2B, $00
    db   4,-12, $39, $00
    db   4, -4, $3A, $00
    db   4,  4, $3B, $00
    db  12,-12, $49, $00
    db  12, -4, $4A, $00
    db METASPRITE_END
sprite_samusRunRight_frame2:
    db -20, -7, $0E, $00
    db -20,  1, $04, $00
    db -12, -7, $1E, $00
    db -12,  1, $1F, $00
    db  -4,-20, $2E, $00
    db  -4,-12, $2F, $00
    db  -4, -4, $4E, $00
    db   4,-20, $3E, $00
    db   4,-12, $3F, $00
    db   4, -4, $5E, $00
    db   4,  4, $5F, $00
    db  12, -4, $6E, $00
    db  12,  4, $6F, $00
    db METASPRITE_END
sprite_samusRunRight_frame3:
    db -20, -4, $0D, $00
    db -20,  4, $0B, $00
    db -12,-12, $1C, $00
    db -12, -4, $1D, $00
    db -12,  4, $0C, $00
    db  -4, -4, $2D, $00
    db   4, -4, $3D, $00
    db  12,-12, $4C, $00
    db  12, -4, $4D, $00
    db METASPRITE_END

sprite_samusRunLeft_frame1:
    db -20,-12, $0B, $20
    db -20, -4, $0A, $20
    db -12,-12, $1B, $20
    db -12, -4, $1A, $20
    db -12,  4, $19, $20
    db  -4,-12, $2B, $20
    db  -4, -4, $2A, $20
    db   4,-12, $3B, $20
    db   4, -4, $3A, $20
    db   4,  4, $39, $20
    db  12, -4, $4A, $20
    db  12,  4, $49, $20
    db METASPRITE_END
sprite_samusRunLeft_frame2:
    db -20,-10, $04, $20
    db -20, -2, $0E, $20
    db -12,-10, $1F, $20
    db -12, -2, $1E, $20
    db  -4, -4, $4E, $20
    db  -4,  4, $2F, $20
    db  -4, 12, $2E, $20
    db   4,-12, $5F, $20
    db   4, -4, $5E, $20
    db   4,  4, $3F, $20
    db   4, 12, $3E, $20
    db  12,-12, $6F, $20
    db  12, -4, $6E, $20
    db METASPRITE_END
sprite_samusRunLeft_frame3:
    db -20,-12, $0B, $20
    db -20, -4, $0D, $20
    db -12,-12, $0C, $20
    db -12, -4, $1D, $20
    db -12,  4, $1C, $20
    db  -4, -4, $2D, $20
    db   4, -4, $3D, $20
    db  12, -4, $4D, $20
    db  12,  4, $4C, $20
    db METASPRITE_END

sprite_samusRunRightShooting_frame1:
    db -20, -4, $0A, $00
    db -20,  4, $0B, $00
    db -12,-12, $19, $00
    db -12, -4, $1A, $00
    db -12,  4, $66, $00
    db -11, 11, $09, $00
    db  -4, -4, $2A, $00
    db  -4,  4, $2B, $00
    db   4,-12, $39, $00
    db   4, -4, $3A, $00
    db   4,  4, $3B, $00
    db  12,-12, $49, $00
    db  12, -4, $4A, $00
    db METASPRITE_END
sprite_samusRunRightShooting_frame2:
    db -19, -5, $0A, $00
    db -19,  3, $0B, $00
    db -11,-13, $19, $00
    db -11, -5, $1A, $00
    db -11,  3, $66, $00
    db -10, 10, $09, $00
    db  -4,-20, $2E, $00
    db  -4,-12, $2F, $00
    db  -4, -4, $4E, $00
    db   4,-20, $3E, $00
    db   4,-12, $3F, $00
    db   4, -4, $5E, $00
    db   4,  4, $5F, $00
    db  12, -4, $6E, $00
    db  12,  4, $6F, $00
    db METASPRITE_END
sprite_samusRunRightShooting_frame3:
    db -20, -4, $0A, $00
    db -20,  4, $0B, $00
    db -12,-12, $19, $00
    db -12, -4, $1A, $00
    db -12,  4, $66, $00
    db -11, 11, $09, $00
    db  -4, -4, $2D, $00
    db   4, -4, $3D, $00
    db  12,-12, $4C, $00
    db  12, -4, $4D, $00
    db METASPRITE_END

sprite_samusRunLeftShooting_frame1:
    db -20,-12, $0B, $20
    db -20, -4, $0D, $20
    db -12,-12, $2C, $20
    db -12, -4, $1D, $20
    db -12,  4, $1C, $20
    db -11,-19, $09, $20
    db  -4,-12, $2B, $20
    db  -4, -4, $2A, $20
    db   4,-12, $3B, $20
    db   4, -4, $3A, $20
    db   4,  4, $39, $20
    db  12, -4, $4A, $20
    db  12,  4, $49, $20
    db METASPRITE_END
sprite_samusRunLeftShooting_frame2:
    db -19,-11, $0B, $20
    db -19, -3, $0D, $20
    db -11,-11, $2C, $20
    db -11, -3, $1D, $20
    db -11,  5, $1C, $20
    db -10,-18, $09, $20
    db  -4, -4, $4E, $20
    db  -4,  4, $2F, $20
    db  -4, 12, $2E, $20
    db   4,-12, $5F, $20
    db   4, -4, $5E, $20
    db   4,  4, $3F, $20
    db   4, 12, $3E, $20
    db  12,-12, $6F, $20
    db  12, -4, $6E, $20
    db METASPRITE_END
sprite_samusRunLeftShooting_frame3:
    db -20,-12, $0B, $20
    db -20, -4, $0D, $20
    db -12,-12, $2C, $20
    db -12, -4, $1D, $20
    db -12,  4, $1C, $20
    db -11,-19, $09, $20
    db  -4, -4, $2D, $20
    db   4, -4, $3D, $20
    db  12, -4, $4D, $20
    db  12,  4, $4C, $20
    db METASPRITE_END

sprite_samusJumpRight:
    db -12, -8, $03, $00
    db -12,  0, $04, $00
    db  -4, -8, $13, $00
    db  -4,  0, $14, $00
    db   1,  6, $09, $00
    db   4,-16, $4F, $00
    db   4, -8, $5C, $00
    db   4,  0, $5D, $00
    db  12,-16, $6B, $00
    db  12, -8, $6C, $00
    db  12,  0, $6D, $00
    db METASPRITE_END
sprite_samusJumpLeft:
    db -12, -8, $04, $20
    db -12,  0, $06, $00
    db  -4, -8, $15, $00
    db  -4,  0, $16, $00
    db   1,-14, $09, $20
    db   4, -8, $5B, $20
    db   4,  0, $4B, $20
    db   4,  8, $4F, $20
    db  12, -8, $6D, $20
    db  12,  0, $6C, $20
    db  12,  8, $6B, $20
    db METASPRITE_END

sprite_samusJumpRightAimUp:
    db -17, -2, $08, $00
    db -12, -8, $17, $00
    db -12,  0, $18, $00
    db  -4, -8, $27, $00
    db  -4,  0, $28, $00
    db   4,-16, $4F, $00
    db   4, -8, $5C, $00
    db   4,  0, $46, $00
    db  12,-16, $6B, $00
    db  12, -8, $6C, $00
    db  12,  0, $6D, $00
    db METASPRITE_END
sprite_samusJumpLeftAimUp:
    db -17, -6, $08, $00
    db -12, -8, $47, $00
    db -12,  0, $48, $00
    db  -4, -8, $57, $00
    db  -4,  0, $58, $00
    db   4, -8, $46, $20
    db   4,  0, $5C, $20
    db   4,  8, $4F, $20
    db  12, -8, $6D, $20
    db  12,  0, $6C, $20
    db  12,  8, $6B, $20
    db METASPRITE_END

sprite_samusCrouchRight:
    db -10, -8, $03, $00
    db -10,  0, $04, $00
    db  -2, -8, $13, $00
    db  -2,  0, $14, $00
    db   3,  6, $09, $00
    db   4, -8, $67, $00
    db   4,  0, $68, $00
    db  12,-16, $76, $00
    db  12, -8, $77, $00
    db  12,  0, $78, $00
    db METASPRITE_END
sprite_samusCrouchLeft:
    db -10, -8, $04, $20
    db -10,  0, $06, $00
    db  -2, -8, $15, $00
    db  -2,  0, $16, $00
    db   3,-13, $09, $20
    db   4, -8, $7A, $20
    db   4,  0, $79, $20
    db  12, -8, $78, $20
    db  12,  0, $77, $20
    db  12,  8, $76, $20
    db METASPRITE_END

sprite_samusJumpRightAimDown:
    db -12, -8, $70, $00
    db -12,  0, $71, $00
    db  -4, -8, $72, $00
    db  -4,  0, $73, $00
    db   4,-16, $4F, $00
    db   4, -8, $74, $00
    db   4,  0, $75, $00
    db  12,-16, $6B, $00
    db  12, -8, $6C, $00
    db  12,  0, $3C, $00
    db METASPRITE_END
sprite_samusJumpLeftAimDown:
    db -12, -8, $71, $20
    db -12,  0, $70, $20
    db  -4, -8, $73, $20
    db  -4,  0, $72, $20
    db   4, -8, $65, $20
    db   4,  0, $74, $20
    db   4,  8, $4F, $20
    db  12, -8, $3C, $20
    db  12,  0, $6C, $20
    db  12,  8, $6B, $20
    db METASPRITE_END

sprite_samusRunRightAimUp_frame1:
    db -26, -2, $08, $00
    db -20, -8, $17, $00
    db -20,  0, $18, $00
    db -12, -8, $27, $00
    db -12,  0, $28, $00
    db  -4, -5, $2A, $00
    db  -4,  3, $2B, $00
    db   4,-13, $39, $00
    db   4, -5, $3A, $00
    db   4,  3, $3B, $00
    db  12,-13, $49, $00
    db  12, -5, $4A, $00
    db METASPRITE_END
sprite_samusRunRightAimUp_frame2:
    db -25, -2, $08, $00
    db -19, -8, $17, $00
    db -19,  0, $18, $00
    db -11, -8, $27, $00
    db -11,  0, $28, $00
    db  -4,-21, $2E, $00
    db  -4,-13, $2F, $00
    db  -4, -5, $4E, $00
    db   4,-21, $3E, $00
    db   4,-13, $3F, $00
    db   4, -5, $5E, $00
    db   4,  3, $5F, $00
    db  12, -5, $6E, $00
    db  12,  3, $6F, $00
    db METASPRITE_END
sprite_samusRunRightAimUp_frame3:
    db -26, -2, $08, $00
    db -20, -8, $17, $00
    db -20,  0, $18, $00
    db -12, -8, $27, $00
    db -12,  0, $28, $00
    db  -4, -5, $2D, $00
    db   4, -5, $3D, $00
    db  12,-13, $4C, $00
    db  12, -5, $4D, $00
    db METASPRITE_END

sprite_samusRunLeftAimUp_frame1:
    db -26, -6, $08, $00
    db -20, -8, $47, $00
    db -20,  0, $48, $00
    db -12, -8, $57, $00
    db -12,  0, $58, $00
    db  -4,-11, $2B, $20
    db  -4, -3, $2A, $20
    db   4,-11, $3B, $20
    db   4, -3, $3A, $20
    db   4,  5, $39, $20
    db  12, -3, $4A, $20
    db  12,  5, $49, $20
    db METASPRITE_END
sprite_samusRunLeftAimUp_frame2:
    db -25, -6, $08, $00
    db -19, -8, $47, $00
    db -19,  0, $48, $00
    db -11, -8, $57, $00
    db -11,  0, $58, $00
    db  -4, -3, $4E, $20
    db  -4,  5, $2F, $20
    db  -4, 13, $2E, $20
    db   4,-11, $5F, $20
    db   4, -3, $5E, $20
    db   4,  5, $3F, $20
    db   4, 13, $3E, $20
    db  12,-11, $6F, $20
    db  12, -3, $6E, $20
    db METASPRITE_END
sprite_samusRunLeftAimUp_frame3:
    db -26, -6, $08, $00
    db -20, -8, $47, $00
    db -20,  0, $48, $00
    db -12, -8, $57, $00
    db -12,  0, $58, $00
    db  -4, -3, $2D, $20
    db   4, -3, $3D, $20
    db  12, -3, $4D, $20
    db  12,  5, $4C, $20
    db METASPRITE_END

sprite_samusBombExplosion_frame1:
    db  -4, -4, $8E, $00
    db METASPRITE_END
sprite_samusBombExplosion_frame2:
    db -12,-12, $8B, $00
    db -12, -4, $8C, $00
    db -12,  4, $8B, $20
    db  -4,-12, $8D, $00
    db  -4,  4, $8D, $20
    db   4,-12, $8B, $40
    db   4, -4, $8C, $40
    db   4,  4, $8B, $60
    db METASPRITE_END
sprite_samusBombExplosion_frame3:
    db  -8, -8, $84, $00
    db  -8,  0, $84, $20
    db   0, -8, $84, $40
    db   0,  0, $84, $60
    db METASPRITE_END
sprite_samusBombExplosion_frame4:
    db -16,-16, $80, $00
    db -16, -8, $81, $00
    db -16,  0, $81, $20
    db -16,  8, $80, $20
    db  -8,-16, $82, $00
    db  -8, -8, $83, $00
    db  -8,  0, $83, $20
    db  -8,  8, $82, $20
    db   0,-16, $82, $40
    db   0, -8, $83, $40
    db   0,  0, $83, $60
    db   0,  8, $82, $60
    db   8,-16, $80, $40
    db   8, -8, $81, $40
    db   8,  0, $81, $60
    db   8,  8, $80, $60
    db METASPRITE_END

sprite_samusBomb_frame1:
    db  -4, -4, $90, $00
    db METASPRITE_END
sprite_samusBomb_frame2:
    db  -4, -4, $91, $00
    db METASPRITE_END

sprite_samusSpiderLeft_frame1:
    db   4, -8, $05, $00
    db   4,  0, $07, $00
    db  12, -8, $33, $00
    db  12,  0, $29, $00
    db METASPRITE_END
sprite_samusSpiderLeft_frame2:
    db   3, -8, $07, $20
    db   3,  0, $29, $40
    db  11, -8, $05, $40
    db  11,  0, $33, $20
    db METASPRITE_END
sprite_samusSpiderLeft_frame3:
    db   4, -8, $29, $60
    db   4,  0, $33, $60
    db  12, -8, $07, $60
    db  12,  0, $05, $60
    db METASPRITE_END
sprite_samusSpiderLeft_frame4:
    db   3, -8, $33, $40
    db   3,  0, $05, $20
    db  11, -8, $29, $20
    db  11,  0, $07, $40
    db METASPRITE_END

sprite_samusSpiderRight_frame1:
    db   4, -8, $07, $20
    db   4,  0, $05, $20
    db  12, -8, $29, $20
    db  12,  0, $33, $20
    db METASPRITE_END
sprite_samusSpiderRight_frame2:
    db   3, -8, $29, $60
    db   3,  0, $07, $00
    db  11, -8, $33, $00
    db  11,  0, $05, $60
    db METASPRITE_END
sprite_samusSpiderRight_frame3:
    db   4, -8, $33, $40
    db   4,  0, $29, $40
    db  12, -8, $05, $40
    db  12,  0, $07, $40
    db METASPRITE_END
sprite_samusSpiderRight_frame4:
    db   3, -8, $05, $00
    db   3,  0, $33, $60
    db  11, -8, $07, $60
    db  11,  0, $29, $00
    db METASPRITE_END

sprite_samusHudMetroid_frame1:
    db   0,  0, $9A, $00
    db   0,  8, $9A, $20
    db METASPRITE_END
sprite_samusHudMetroid_frame2:
    db   0,  0, $9B, $00
    db   0,  8, $9B, $20
    db METASPRITE_END
