; WRAM

;;;; $C000..CFFF: WRAM bank 0 ;;;
;{
section "WRAM Bank 0 - OAM Buffer", wram0[$C000] ;{

OAM_MAX = $A0 ; 40 hardware sprites -> 160 bytes
wram_oamBuffer:: ds OAM_MAX ;{ $C000..9F: OAM Entries
;    + 0: Y position
;    + 1: X position
;    + 2: Tile number
;    + 3: Attributes
;         10: Palette
;         20: X flip
;         40: Y flip
;         80: Priority (set: behind background)
;}

;}

; $C0A0-$C1FF: Unused
; WARNING: Most OAM buffer routines do not appear to do proper of bounds checking,
;  meaning that if the OAM buffer overflows then then these RAM addresses could be corrupted.
;  Be advised.

section "WRAM Bank 0 - C200", wram0[$C200] ;{

ds 1 ; $C200 - Unused
ds 1 ; $C201 - Unused
ds 1 ; $C202 - Unused

; Tilemap pixel coordinate of a tile to read
tileY: ds 1 ; $C203 - Tile Y (see $22BC)
tileX: ds 1 ; $C204 - Tile X (see $22BC)

; Written to the hardward scroll registers
scrollY: ds 1 ; $C205 - Scroll Y
scrollX: ds 1 ; $C206 - Scroll X

;
def pTilemapDestLow  = $C215 ; Tilemap destination pointer based on the given xy coordinates in ([$C204], [$C203]) (see $22BC)
def pTilemapDestHigh = $C216 ;  "" (high byte)


def gameOver_LCDC_copy = $C219 ; LCD control mirror. Only set by death routine. This variable is pretty much useless, set to 0 on boot and to C3h by game over, checked for bitset 8 by $2266 (get tilemap value)
;{
;    v = emwdMsob
;
;    e: Enable LCD
;    m: Window tilemap base address. 0 = $9800, 1 = $9C00
;    w: Enable window
;    d: Tiles base address. 0 = $8800, 1 = $8000
;    M: BG tilemap base address. 0 = $9800, 1 = $9C00
;    s: Sprite size. 0 = 8x8, 1 = 8x16
;    o: Enable sprite
;    b: Enable BG. If CGB, then 0 additionally disables window regardless of w
;}
;
def unknown_C227 = $C227

;}

def enSprite_blobThrower = $C300
def spriteC300 = $C300 ;$C300..3D: Set to [$2:4FFE..503A] in $2:4DB1
;{
;    $C302/06: Set to DFh in $2:4EA1 if [$C382] = 0, set to E2h if [$C382] = 1, set to E3h if [$C382] = 2
;    $C30A/0E: Set to E1h in $2:4EA1 if [$C382] = 0
;    $C312/16/1A: XOR'd with 7 in $2:4EA1
;    $C322/2E: XOR'd with Dh in $2:4EA1
;    $C334: Set to E8h in $2:4EA1 if [$C382] = 0
;}
def queen_objectOAM = $C308 ; $C308..37: Metroid Queen neck/spit OAM. Ch slots of 4 bytes (Y, X, tile, attr)
def queen_bentNeckOAM_end = $C31C
def queen_wallOAM = $C338
def queen_wallOAM_body = $C338 ; $C338 - Queen Wall OAM (body portion) - 7 slots
def queen_wallOAM_head = $C354 ; $C354 - Queen Wall OAM (head portion) - 5 slots

def hitboxC360 = $C360 ;-$C363: Set to [$2:503B..3E] in $2:4DB1
;
def blobThrower_actionTimer = $C380 ; Cleared in $2:4DB1. Used as index in $2:4FD4
def blobThrower_waitTimer = $C381 ; Timer for $2:4EA1
def blobThrower_state = $C382 ; Valid values are 0, 1, 2, 3
; $C383 - unused?
; $C384 - unused?
; $C385 - unused?
def blobThrower_facingDirection = $C386 ; Set to Samus is right of enemy in $2:4F87
def blobThrowerBlob_unknownVar = $C387 ; Written to, but never read
def temp_spriteType = $C388 ; 02:4DD3 - Temp variable used to store the sprite type in the item AI (02:4DD3)

; Arachnus variables
def arachnus_jumpCounter = $C390
def arachnus_actionTimer = $C391 ; Set to 20h, 10h, and 04h
def arachnus_unknownVar  = $C392 ; Set to 5 in $2:513F (unwritten but never read?)
def arachnus_jumpStatus  = $C393 ; $00 - in jump arc, $80 - At the end of an arc, $81 - At the end of the last arc
def arachnus_health = $C394 ; Set in procedure at 02:511C
;$C395: unused
;$C396: unused

section "Queen Variables", wram0[$C3A0]
; Queen variables appear to start at $C3A0
queen_bodyY: ds 1 ; $C3A0 - Y position of the Queen's body (used for the setting the raster split and setting the hitbox)
queen_bodyXScroll: ds 1 ; $C3A1 - LCD interrupt handler scroll X (higher numbers -> body is more left)
queen_bodyHeight: ds 1 ; $C3A2 - Queen body height? (used for timing the bottom of the raster split)

queen_walkWaitTimer: ds 1 ; $C3A3 - If non-zero, decrements and pauses the Queen's walking animation (never written to?)
queen_walkCounter: ds 1 ; $C3A4 - Index into the queen's walk speed table
ds 1 ; $C3A5 - Unused? (perhaps the walk counter used to be a pointer?)

queen_pNeckPatternLow:  ds 1 ; $C3A6 - Pointer to the current working byte of the current neck pattern
queen_pNeckPatternHigh: ds 1 ; $C3A7 - "" (high byte)

queen_headX: ds 1 ;$C3A8 - X position of Metroid Queen's head on screen
queen_headY: ds 1 ;$C3A9 - Y position of Metroid Queen's head on screen

queen_pInterruptListLow:  ds 1 ; $C3AA - Pointer to LCD interrupt data
queen_pInterruptListHigh: ds 1 ; $C3AB -  "" (high byte)

queen_headBottomY: ds 1 ; $C3AC: Y position of the bottom of the visible portion of the queen's head
; Set to min(8Fh, [Y position of Metroid Queen's head on screen] + 26h])
queen_interruptList: ds 9 ;$C3AD..B5: LCD interrupt data: Initial slot for a y position, 4 slots of 2 bytes commands
;{
;    yy: Y position of initial interrupt ($C3AD)
;    x1 yy: Set scroll X and background palette to Queen's.          LCD interrupt Y position = yy. End
;    x2 yy: Update scroll X and background palette to default = 93h. LCD interrupt Y position = yy. End
;    x3 yy: Disable window display.                       LCD interrupt Y position = yy. End
;    x4 (or otherwise): Set status bar (disable window, scroll = (0, 70h). End interrupts for frame.
;    0x yy: Set next LCD interrupt position to yy, and end current interrupt
;    8x yy: Ignore yy and execute next interrupt command now.
;    FFh: End interrupts for frame (possibly unneeded with the x4 command)
;}

queen_neckXMovementSum: ds 1 ; $C3B6 - Neck related counter (X displacement counter?)
queen_neckYMovementSum: ds 1 ; $C3B7 - Neck related counter (Y displacement counter?)

queen_pOamScratchpadLow: ds 1 ; $C3B8 - Pointer used in constructing the sprite at C608
queen_pOamScratchpadHigh: ds 1 ; $C3B9
queen_neckDrawingState: ds 1 ; $C3BA - Neck drawing state: $00 - nothing, $01 - Extending, $02 - Retracting

queen_cameraDeltaX: ds 1 ; $C3BB - Change in camera X position from the last frame
queen_cameraDeltaY: ds 1 ; $C3BC - Change in camera Y position from the last frame

queen_walkControl: ds 1 ; $C3BD - 0x00 = Don't walk, 0x01: Walk forwards, 0x02: Walk backwards
queen_neckSelectionFlag: ds 1 ; $C3BE - Alternates between 0x00 and 0x01. Used to determine how to select neck patterns when the queen's health is high
queen_walkStatus: ds 1 ; $C3BF - 0x81 = "done walking forward", 0x82 = "done walking backward"
queen_neckControl: ds 1 ; $C3C0 - $00 - nothing, $01 - Extending, $02 - Retracting, $03 - In place (used when walking)
queen_neckStatus: ds 1 ; $C3C1 - 0x81 = "done extending", 0x82 = "done retracting"
queen_walkSpeed: ds 1 ; $C3C2 - Used for adjusting the queen's head's position

queen_state: ds 1 ; $C3C3 - Metroid Queen's state
queen_pNextStateLow:  ds 1 ; $C3C4 - Pointer to the next state number (low byte)
queen_pNextStateHigh: ds 1 ; $C3C5 -  "" (high byte)

queen_cameraX: ds 1 ; $C3C6 - Current camera position in room
queen_cameraY: ds 1 ; $C3C7 -  ""

queen_footFrame: ds 1 ; $C3C8 - Metroid Queen's foot animation frame. Very similar to the head. Cleared in $3:6E36
queen_footAnimCounter: ds 1 ; $C3C9 - Delay value until next frame

queen_headFrameNext: ds 1 ; $C3CA - Metroid Queen's head animation frame to draw. FFh = resume previous tilemap update, 0 = disabled, 1 = frame 0, 2 = frame 1, otherwise frame 2. Cleared in $3:6E36
queen_headFrame: ds 1 ; $C3CB - Currently display head frame of Queen

queen_neckPattern: ds 1 ; $C3CC - Index for the queen's neck swoop pattern
queen_pNeckPatternBaseLow:  ds 1 ; $C3CD - Pointer to the start of the currently active neck pattern
queen_pNeckPatternBaseHigh: ds 1 ; $C3CE -  "" (high byte)

queen_delayTimer: ds 1 ; $C3CF - Generic delay timer between states/actions
queen_stunTimer: ds 1 ; $C3D0 - Stun timer when hit with mouth open
queen_stomachBombedFlag: ds 1 ; $C3D1 - Flag set when the stomach is bombed (helps determine neck behavior)
queen_bodyPalette: ds 1 ; $C3D2 - LCD interrupt handler background palette. Palette is not written if zero
queen_health: ds 1 ; $C3D3 - Metroid Queen health

queen_deathArrayIndex: ds 1 ; $C3D4 - Queen death related (disintegration index?)
queen_deathAnimCounter: ds 1 ; $C3D5 - Counts down each time the 
queen_deathArray: ds 8 ; $C3D6..$C3DD - Queen table of disintegration bitmasks for death animation
queen_pDeathChrLow:  ds 1 ; $C3DE - VRAM pointer for Queen's disintegration animation
queen_pDeathChrHigh: ds 1 ; $C3DF -  "" high byte
queen_deathBitmask: ds 1 ; $C3E0 - Queen disintegration bitmask - Bitmask is applied if non-zero
ds 1 ; $C3E1 - Unused
ds 1 ; $C3E2 - Unused
queen_projectilesActiveFlag: ds 1 ; $C3E3 - Non-zero when projectiles are active
queen_projectileTempDirection: ds 1 ; $C3E4 - Temp storage for directional flags of projectile
queen_projectileChaseTimer: ds 1 ; $C3E5 - Decrementing timer used for keeping track of how often the projectiles change directions
queen_samusTargetPoints: ds 6 ; $C3E6-$C3EB - Array of 3 YX pairs that the Queen's projectiles chase

queen_pDeleteBodyLow:  ds 1 ; $C3EC - Pointer for deleting queen's body after dying
queen_pDeleteBodyHigh: ds 1 ; $C3ED -  "" high byte
queen_projectileChaseCounter: ds 1 ; $C3EE - Decrementing counter that keeps track of how many times the Queen's projectiles have to change their bearings
queen_lowHealthFlag: ds 1 ; $C3EF - Set to 1 when the Queen's health] < 50
queen_flashTimer: ds 1 ; $C3F0 - Timer for flashing effect when queen is hit
queen_midHealthFlag: ds 1 ; $C3F1 - Set to 1 when the Queen's health] < 100

queen_headDest: ds 1 ; $C3F2 - Metroid Queen's head lower half tilemap VRAM address low byte
queen_headSrcHigh: ds 1 ; $C3F3 - Metroid Queen's head lower half tilemap source address (bank 3)
queen_headSrcLow:  ds 1 ; $C3F4 - (rare instance of a big-endian variable!!)



loadEnemies_unusedVar = $C400 ; Written, but never read. Possibly meant to be a direction, but the assigned values don't make sense
loadEnemies_oscillator = $C401 ; Oscillates between 0 and 1 every frame. $00: Load enemies horizontally, else: Load enemies vertically
en_bgCollisionResult = $C402 ; Enemy tilemap collision routine return value (initialized to $11, $22, $44, or $88)

section "WRAM c407", wram0[$C407]
enemySolidityIndex: ds 1 ;$C407: Copy of enemySolidityIndex_canon (actually used by enemy code)

; This copy of the scrolling history appears to be used in the function that adjusts enemy positions due to scrolling
scrollHistory_A:
.y3: ds 1 ;$C408: Scroll Y three frames ago (according to $2:45CA)
.x3: ds 1 ;$C409: Scroll X three frames ago (according to $2:45CA)
.y2: ds 1 ;$C40A: Scroll Y two frames ago (according to $2:45CA)
.x2: ds 1 ;$C40B: Scroll X two frames ago (according to $2:45CA)
.y1: ds 1 ;$C40C: Scroll Y one frame ago (according to $2:45CA)
.x1: ds 1 ;$C40D: Scroll X one frame ago (according to $2:45CA)
unused_samusDirectionFromEnemy: ds 1 ;$C40E: Set to 0 if [$FFE2] < [Samus' X position on screen] else 2 by $2:45E4
; Screen edges used when loading enemies
bottomEdge_screen: ds 1 ; $C40F
bottomEdge_pixel: ds 1 ; $C410
topEdge_screen: ds 1 ; $C411
topEdge_pixel: ds 1 ; $C412
rightEdge_screen: ds 1 ; $C413
rightEdge_pixel: ds 1 ; $C414
leftEdge_screen: ds 1 ; $C415
leftEdge_pixel: ds 1 ; $C416

metroid_babyTouchingTile: ds 1 ; $C417 - The tile index the baby metroid is touching, according to the enemy BG collision function

def unused_romBankPlusOne = $C418 ; Set to [room bank+1] in $2:4000, never read
;
metroid_postDeathTimer = $C41B ; 90h*2 frame timer for waiting to restore the room's normal music
def metroid_state = $C41C ; General Metroid related state. $00 = inactive, $80 = dying/dead, others depend on the metroid type
;$C41D : Appears unused
def enemy_yPosMirror = $C41E ; Initial y position for the current working enemy for the current frame
def enemy_xPosMirror = $C41F ; Initial x position for the current working enemy for the current frame
;
def samus_hurtFlag = $C422 ; Samus damage flag
def samus_damageBoostDirection = $C423 ; Damage boost direction
;{
;    0: Up
;    1: Up-right
;    FFh: Up-left
;}
def samus_damageValue = $C424 ; Health to take from Samus

def numEnemies = $C425 ; Number of enemies (both currently active and offscreen)
def numActiveEnemies = $C426 ; Number of currently active enemies (used to exit drawEnemies early).
def numOffscreenEnemies = $C427 ; Number of offscreen enemies loaded in. Unused?
;
def unknown_C42D = $C42D ; en_bgCollisionResult for the Omega Metroid's fireball. Written to, but never read
def drawEnemy_yPos   = $C42E ; Set to enemy Y position in $1:5A9A
def drawEnemy_xPos   = $C42F ; Set to enemy X position in $1:5A9A
def drawEnemy_sprite = $C430 ; Set to enemy sprite ID in $1:5A9A. Used as index for pointer table at $1:5AB1
def drawEnemy_attr   = $C431 ; Set to XOR of enemy bytes 4/5/6 AND F0h in $1:5A9A

section "WRAM c432", wram0[$C432]
; This scroll history is used by the enemy loading code to determine if we've moved.
scrollHistory_B:
.y2: ds 1 ;$C432: Scroll Y two frames ago (according to $3:4000)
.y1: ds 1 ;$C433: Scroll Y one frame ago (according to $3:4000)
.x2: ds 1 ;$C434: Scroll X two frames ago (according to $3:4000)
.x1: ds 1 ;$C435: Scroll X one frame ago (according to $3:4000)
def loadSpawnFlagsRequest = $C436 ; Set to 0 to request - Executes $2:412F in $2:4000 if zero, set to 1 afterwards. Flag for updating $C540..7F. Cleared when exiting Metroid Queen's room, and when loading from save
def zeta_xProximityFlag = $C437 ; Set to 1 in the Zeta's AI if within $20 pixels on the x axis
def enemy_sameEnemyFrameFlag = $C438 ; Used to force enemies to update at 30 FPS, and handle enemy lag. Set to $00 if we'll start a new enemy frame next frame. Set to non-zero if the next enemy frame is a continuation of the current (enemy frame counter does not increment).
def enemiesLeftToProcess = $C439 ; Number of enemies left to process
def samus_onSolidSprite = $C43A ; Is Samus atop a solid sprite

section "WRAM C43B", wram0[$C43B]
baby_tempXpos: ds 1 ; $C43B: Used by the baby's AI so it's vertical collision detection can used the previous x position instead

; Temp variables used in enemy_seekSamus (03:6B44)
seekSamusTemp:
.enemyY: ds 1 ; $C43C: enemy Y pos + $10
.enemyX: ds 1 ; $C43D: enemy X pos + $10
.samusY: ds 1 ; $C43E: samus Y pos + $10
.samusX: ds 1 ; $C43F: samus X pos + $10

def saveLoadSpawnFlagsRequest = $C44B ; Request to execute $2:418C (save/load spawn/save flags). Set by doorExitStatus in the door script function
def scrollEnemies_numEnemiesLeft = $C44C ; Number of enemies left to process for scrolling the enemies
def enemy_testPointYPos = $C44D ; Test point for enemy collision (in camera-space)
def enemy_testPointXPos = $C44E ; Test point for enemy collision (in camera-space)
;;$C44E: Tile X relative to scroll X (see $2250)
def omega_tempSpriteType = $C44F ; Used to preserve sprite type when stunned
def enemy_pWramLow  = $C450 ; Enemy WRAM address in bank 3
def enemy_pWramHigh = $C451 ;  "" high byte

def enemy_pFirstEnemyLow  = $C452 ; Pointer of the first enemy to process for the next frame
def enemy_pFirstEnemyHigh = $C453 ;  - Used for making enemies lag instead of Samus
def drawEnemy_pLow  = $C454 ; Enemy data address for draw function (low byte)
def drawEnemy_pHigh = $C455 ; Enemy data address for draw function (high byte)
def loadEnemy_unusedVar_A = $C456 ; Set to the lower screen in the horizontal branch
def loadEnemy_unusedVar_B = $C457 ; Set to the right edge of the screen
def doorExitStatus = $C458 ; doorExitStatus - $2 is normal, $1 is if WARP or ENTER_QUEEN is used. Value is written to $C44B and then cleared. Different non-zero values have no purpose
def previousLevelBank = $C459 ; Previous level bank --- used during door transitions to make sure that the enemySaveFlags are saved to the correct location
;
metroid_samusXDir = $C45A ; Relative X direction of Samus from a metroid ($FF: up, $00: equal, $01: down)
metroid_samusYDir = $C45B ; Relative Y direction of Samus from a metroid ($FF: up, $00: equal, $01: down)
metroid_angleTableIndex = $C45C ; Used as index for table at $1:729C, value for $FFEA
metroid_absSamusDistY = $C45D ; abs(samusY-enemyY) (used for metroid seeking)
metroid_absSamusDistX = $C45E ; abs(samusX-enemyX) (used for metroid seeking)
metroid_slopeToSamusLow  = $C45F ; Metroid-Samus slope (100*dY/dX) (low byte)
metroid_slopeToSamusHigh = $C460 ; Metroid-Samus slope (100*dY/dX) (high byte)

loadEnemy_spawnFlagTemp = $C461 ; Temp storage of Enemy spawn flag during load routine

def omega_stunCounter = $C462 ; Omega Metroid stun counter
def cutsceneActive = $C463 ; Set to 1 if a cutscene is active (e.g. Metroid is appearing). Freezes time.
def alpha_stunCounter = $C464 ; Alpha Metroid stun counter
def metroid_fightActive = $C465 ; 0 = no fight, 1 = fight active, 2 = metroid exploding
; Checked and cleared in $2:4000, cleared in $2:412F

;$C466..69: Copied from [$D05D..60] if collision happened
enCollision_weaponType = $C466 ; Projectile type - Copied to [$C46D] if a collision occurred
enCollision_pEnemyLow  = $C467 ; Enemy data pointer of target enemy (if collision happens)
enCollision_pEnemyHigh = $C468
enCollision_weaponDir  = $C469 ; Projectile direction - Copied to [$C46E] if a collision occurred

;$C468 is a pointer compared against in $2:7DA0
def gamma_stunCounter = $C46A ; Gamma Metroid stun counter

def zeta_stunCounter = $C46C ; Zeta Metroid stun counter

enemy_weaponType = $C46D ; Set to FFh in $2:412F. Value for $D06F in $2:4DD3
;  Enemy-Samus/Beam collision results
; $00 - Power beam
; $01 - Ice
; $02 - Wave
; $03 - Spazer
; $04 - Plasma
; $09 - Bombs
; $10 - Screw
; $20 - Touch
; $FF - Nothing
enemy_weaponDir = $C46E ; Enemy-Beam collision direction results

def omega_waitCounter = $C46F ; Omega Metroid waiting counter of some sort
def omega_samusPrevHealth = $C470 ; Samus's previous health value (low byte only)

metroid_screwKnockbackDone = $C471 ; Set to 1 when a Metroid's screw attack knockback is finished.
; $C472: Unused?
def larva_hurtAnimCounter = $C473 ; Set to 3, counts down to 0 before resetting sprite type to $CE
def larva_bombState = $C474 ; Weird variable. Set to $02 when a metroid is bombed to prevent others from latching on to you for a bit. Set to $01 when touched normally, but never acknowledged elsewhere.
def larva_latchState = $C475 ; Larva Metroid variable: $02: Latched, $01: Flying away, $00: Unlatch

;
def enemy_tempSpawnFlag = $C477 ; Spawn flag for child object to be spawned
def omega_chaseTimerIndex = $C478 ; Selects duration of chase timer. Goes from 0,1,2,3,4,0,etc. Screw attack sets this to 3.
def hasMovedOffscreen = $C479 ; Temp variable for $2:452E (deactivateOffscreenEnemy)

; These two arrays follow the same format, but one is saved and the other is not.
def enemySpawnFlags = $C500 ;$C500..3F: Filled with FFh by $2:418C. Apparently off-screen enemy bytes for current map
def enemySaveFlags  = $C540 ;$C540..7F: Working copy of $C900 data for room bank. Apparently item/Metroid data bytes for current map
;{
;    For metroid:
;        1: Hatching
;        2: Dead
;        4: Alive
;        FFh: Not active
;    
;    For missile door:
;        1: Active
;        2: Destroyed
;        FFh: Not active
;        
;    For item:
;        1: Active
;        2: Collected
;        FFh: Not active
;
;    $1:7A6C:
;        Copies 40h bytes to $C900 + ([$C459] - 9) * 40h from $C540, only 02 and FEh are written, with 04 translated to FEh
;        Then writes out all of $C900..CABF to SRAM
;    
;    $2:418C:
;        If [$C459] != 0:
;            Copies 40h bytes to $C540 from $C900 + ([$C459] - 9) * 40h, only 02 and FEh are written, with 04/05 translated to FEh
;        Then copies 40h bytes to $C900 + ([$C459] - 9) * 40h from $C540
;    
;    $2:412F:
;        Copies 40h bytes to $C540 from $C900 + ([$C459] - 9) * 40h (verbatim)
;    
;    Read at $3:4205 (metroid checking if it should spawn?)
;}
;
def enemyDataSlots = $C600;..C7FF ; Enemy data. 20h byte slots
;{
;    + 0: If bits 0..3 clear, collision with projectiles/bombs/Samus is enabled. If zero, sprite set is not drawn. If FFh, enemy is deleted
;    + 1: Y position. Relative to screen top boundary - 10h. Value for $FFB7 in $30EA
;    + 2: X position. Relative to screen left boundary - 8. Value for $FFB8 in $30EA
;    + 3: Sprite ID. Value for $FFB9 in $30EA
;    + 4..Ch: Enemy header
;    {
;        + 5: Flip flags. Value for $FFBF in $30EA
;        {
;            20h: X flip
;            40h: Y flip
;        }
;
;        + Ch: Health
;    }
;    
;    + 11h: Initial health
;    
;    + 1Ch: Copy of enemy's $C500 byte
;    + 1Dh: Enemy map ID. Used to $C500
;    + 1Eh: AI pointer(?)
;}

; Enemy Data Slots used by Queen:
; - The Queen only cares about the first 4 bytes of each slot: status, Y, X, and ID (no AI pointer!)
; - Exception: Her projectiles use $C608 for something
; - Each slot has a hardcoded purpose
;                   Slot - Sprite ID
queenActor_body  = $C600 ; $F3 - Queen Body
queenActor_mouth = $C620 ; $F5/$F6/$F7 - Queen Mouth (closed/open/stunned)
queenActor_headL = $C640 ; $F1 - Head Left Half
queenActor_headR = $C660 ; $F2 - Head Right Half
queenActor_neckA = $C680 ; $F0 - Queen Neck <- This one get set to $82 when spitting Samus out?
;  ...
; $C720 - $F0 - Queen Neck
queenActor_spitA = $C740 ; $F2 - Queen Projectile
queenActor_spitB = $C760 ; $F2 - Queen Projectile
queenActor_spitC = $C780 ; $F2 - Queen Projectile
; Sprite ID $F4 is unused?
def enemyDataSlots_end = enemyDataSlots + $200

saveBuf_enemySaveFlags = $C900 ;$C900..CABF: Copied to/from SRAM ($B000 + [save slot] * 200h). 40h byte slots, one for each level data bank


;$CEC0..CFFF: Audio data
;{
;    ; Song / sound effect is requested by writing directly to $CEDC/$CEC0/$CEC7/$CFE5/$CED5/$CEDE
;    ; Audio is paused/unpaused by writing directly to $CFC7
;    ; The rest of audio data RAM is fully managed by code in bank 4
;    
;    $CEC0: Tone/sweep channel sound effect
;    {
def sfxRequest_square1 = $CEC0 ; Tone/sweep channel sound effect request
def sfxPlaying_square1 equ $CEC1 ; Tone/sweep channel sound effect playing
; {
    def sfx_square1_nothing                  equ $0 ; Nothing
    def sfx_square1_jumping                  equ $1 ; Jumping
    def sfx_square1_hijumping                equ $2 ; Hi-jumping
    def sfx_square1_screwAttacking           equ $3 ; Screw attacking
    def sfx_square1_standingTransition       equ $4 ; Uncrouching / turning around / landing / hurt by spike
    def sfx_square1_crouchingTransition      equ $5 ; Crouching / unmorphing
    def sfx_square1_morphingTransition       equ $6 ; Morphing
    def sfx_square1_shootingBeam             equ $7 ; Shooting beam
    def sfx_square1_shootingMissile          equ $8 ; Shooting missile
    def sfx_square1_shootingIceBeam          equ $9 ; Shooting ice beam
    def sfx_square1_shootingPlasmaBeam       equ $A ; Shooting plasma beam
    def sfx_square1_shootingSpazerBeam       equ $B ; Shooting spazer beam
    def sfx_square1_pickedUpMissileDrop      equ $C ; Picked up missile drop
    def sfx_square1_spiderBall               equ $D ; Spider ball
    def sfx_square1_pickedUpSmallEnergyDrop  equ $E ; Picked up small energy drop
    def sfx_square1_beamDink                 equ $F ; Shot missile door with beam (maybe certain enemies too?)
    def sfx_square1_10                       equ $10 ; (set in $2:6A14)
    def sfx_square1_11                       equ $11 ; Unused
    def sfx_square1_12                       equ $12 ; Unused
    def sfx_square1_bombLaid                 equ $13 ; Bomb laid
    def sfx_square1_14                       equ $14 ; Unused
    def sfx_square1_select                   equ $15 ; Option select / missile select
    def sfx_square1_shootingWaveBeam         equ $16 ; Shooting wave beam
    def sfx_square1_pickedUpLargeEnergyDrop  equ $17 ; Picked up large energy drop
    def sfx_square1_samusHealthChange        equ $18 ; Samus' health changed
    def sfx_square1_noMissileDudShot         equ $19 ; No missile dud shot
    def sfx_square1_1A                       equ $1A ; (set in $2:6BB2 and other places in bank 2)
    def sfx_square1_metroidCry               equ $1B ; Metroid cry
    def sfx_square1_saved                    equ $1C ; Saved
    def sfx_square1_variaSuitTransformation  equ $1D ; Varia suit transformation
    def sfx_square1_unpaused                 equ $1E ; Unpaused
    def sfx_square1_2D                       equ $2D ; Set in $2:79A8 (might be a hack to use 0Fh's sound effect playing routine by overflowing jump table in bank 4)
; }
;
def sfxTimer_square1 equ $CEC3 ; Tone/sweep channel sound effect timer
def samusHealthChangedOptionSetIndex equ $CEC4 ; Samus' health changed option set index. Only 2 is (meaningfully) used due to a bug (see $4:53F7)
;        {
;            0: No change
;            1: Alternate option set
;            2: Normal option set
;        }
;    }
;
;    $CEC7: Tone channel sound effect
;    {
def sfxRequest_square2 = $CEC7 ; Tone channel sound effect request
def sfxPlaying_square2 equ $CEC8 ; Tone channel sound effect playing
; {
    def sfx_square2_0                        equ 0 ; Nothing
    def sfx_square2_1                        equ 1 ; Nothing
    def sfx_square2_2                        equ 2 ; Nothing
    def sfx_square2_metroidQueenCry          equ 3 ; Metroid Queen cry
    def sfx_square2_babyMetroidClearingBlock equ 4 ; Baby Metroid hatched / clearing blocks
    def sfx_square2_babyMetroidCry           equ 5 ; Baby Metroid cry
    def sfx_square2_metroidQueenHurtCry      equ 6 ; Metroid Queen hurt cry
    def sfx_square2_7                        equ 7 ; Set in $2:6540 when $FFEF % 10h = 0
; }
;
def sfxTimer_square2 equ $CECA ; Tone channel sound effect timer

def square2_variableFrequency equ $CECC ; Variable tone channel frequency. Only the lower byte
;    }
;
;    $CECE..CED4: Would be the wave channel sound effect, but is unused (only cleared) and $CEE6/$CFE5 is used instead.
def sfxRequest_fakeWave equ $CECE
def sfxPlaying_fakeWave equ $CECF
;
;    $CED5: Noise channel sound effect
;    {
def sfxRequest_noise = $CED5 ; Noise channel sound effect request
def sfxPlaying_noise equ $CED6 ; Noise channel sound effect playing
;        {
;            FFh: Clear sound effect and disable noise channel
;            0: Nothing
;            1: Enemy shot
;            2: Enemy killed
;            3: Set in bank 2
;            4: Shot block destroyed
;            5: Metroid hurt
;            6: Samus hurt
;            7: Acid damage
;            8: Shot missile door with missile (maybe certain enemies too?)
;            9: Metroid Queen cry
;            Ah: Metroid Queen hurt cry
;            Bh: Samus killed
;            Ch: Bomb detonated
;            Dh: Metroid killed
;            Eh: Set in bank 2
;            Fh: Cleared save file
;            10h Footsteps
;            11h: Set in bank 2
;            12h: Set in bank 2
;            13h: Unused
;            14h: Set in bank 2
;            15h: Set in bank 2
;            16h: Baby Metroid hatched / clearing blocks
;            17h: Baby Metroid cry
;            18h: Set in bank 2
;            19h: Unused
;            1Ah: Set in bank 2
;        }
;
def sfxTimer_noise equ $CED8 ; Noise channel sound effect timer
;    }
;
def songRequest = $CEDC ; Song request
def songPlaying = $CEDD ; Song playing
;{
    def song_nothing                   equ 0 ; Nothing
    def song_babyMetroid               equ 1 ; Baby Metroid
    def song_metroidQueenBattle        equ 2 ; Metroid Queen battle
    def song_chozoRuins                equ 3 ; Chozo ruins
    def song_mainCaves                 equ 4 ; Main caves
    def song_subCaves1                 equ 5 ; Sub caves 1
    def song_subCaves2                 equ 6 ; Sub caves 2
    def song_subCaves3                 equ 7 ; Sub caves 3
    def song_finalCaves                equ 8 ; Final caves
    def song_metroidHive               equ 9 ; Metroid hive
    def song_itemGet                   equ $A ; Item-get
    def song_metroidQueenHallway       equ $B ; Metroid Queen hallway
    def song_metroidBattle             equ $C ; Metroid battle
    def song_subCaves4                 equ $D ; Sub caves 4
    def song_earthquake                equ $E ; Earthquake
    def song_killedMetroid             equ $F ; Killed Metroid
    def song_nothing_clone             equ $10 ; Nothing
    def song_title                     equ $11 ; Title
    def song_samusFanfare              equ $12 ; Samus fanfare
    def song_reachedTheGunship         equ $13 ; Reached the gunship
    def song_chozoRuins_clone          equ $14 ; Chozo ruins, same as 3
    def song_mainCaves_noIntro         equ $15 ; Main caves, no intro
    def song_subCaves1_noIntro         equ $16 ; Sub caves 1, no intro
    def song_subCaves2_noIntro         equ $17 ; Sub caves 2, no intro
    def song_subCaves3_noIntro         equ $18 ; Sub caves 3, no intro
    def song_finalCaves_clone          equ $19 ; Final caves, same as 8
    def song_metroidHive_clone         equ $1A ; Metroid hive, same as 9
    def song_itemGet_clone             equ $1B ; Item-get, same as Ah
    def song_metroidQueenHallway_clone equ $1C ; Metroid Queen hallway, same as Bh
    def song_metroidBattle_clone       equ $1D ; Metroid battle, same as Ch
    def song_subCaves4_noIntro         equ $1E ; Sub caves 4, no intro
    def song_metroidHive_withIntro     equ $1F ; Metroid hive with intro
    def song_missilePickup             equ $20 ; Missile pickup
;}
def songInterruptionRequest equ $CEDE ; Song interruption request
def songInterruptionPlaying equ $CEDF ; Song interruption playing
;{
    def songInterruption_itemGet       equ 1 ; Play item-get music
    def songInterruption_end_playing   equ 2 ; End song interruption
    def songInterruption_end_request   equ 3 ; End song interruption
    def songInterruption_missilePickup equ 5 ; Play missile pickup music
    def songInterruption_fadeOutMusic  equ 8 ; Fade out music
    def songInterruption_earthquake    equ song_earthquake ; Play earthquake music
    def songInterruption_clear         equ $FF ; Clear song interruption
;}

def sfxActive_square1 equ $CEE4 ; Tone/sweep channel sound effect is playing flag (checked by song handler)
def sfxActive_square2 equ $CEE5 ; Tone channel sound effect is playing flag (checked by song handler)
def sfxActive_wave equ $CEE6 ; Wave channel sound effect is playing flag (checked by song handler)
def sfxActive_noise equ $CEE7 ; Noise channel sound effect is playing flag (checked by song handler)
def resumeScrewAttackSoundEffectFlag equ $CEE8 ; Resume screw attack sound effect flag

def songProcessingState equ $CF00 ; $CF00..60: Song processing state
;    {
def songTranspose equ $CF00 ; Transpose
def songInstructionTimerArrayPointer equ $CF01 ; Instruction timer array pointer
def workingSoundChannel equ $CF03 ; Working sound channel (1/2/3/4)
def songChannelEnable_square1 equ $CF04 ; Song tone/sweep channel enable. Set to 1 if [$CF38] != 0 in $48A0
def songChannelEnable_square2 equ $CF05 ; Song tone channel enable. Set to 2 if [$CF41] != 0 in $48A0
def songChannelEnable_wave equ $CF06 ; Song wave channel enable. Set to 3 if [$CF4A] != 0 in $48A0
def songChannelEnable_noise equ $CF07 ; Song noise channel enable. Set to 4 if [$CF53] != 0 in $48A0
def songOptionsSetFlag_working equ $CF08 ; Working sound channel options set flag. Set by song instruction F1h. Checked to update channel sweep and sound length / wave pattern duty for tone(/sweep) channels
def songWavePatternDataPointer equ $CF09 ; Song wave pattern data pointer. 10h bytes
def songSweep_working equ $CF0B ; Working sound channel sweep / enable
def songEnable_working equ $CF0B ; Working sound channel sweep / enable
def songSoundLength_working equ $CF0C ; Working sound channel sound length / wave pattern duty
def songEnvelope_working equ $CF0D ; Working sound channel envelope / volume
def songVolume_working equ $CF0D ; Working sound channel envelope / volume
def songFrequency_working equ $CF0E ; Working sound channel frequency / noise channel polynomial counter
def songPolynomialCounter_working equ $CF0E ; Working sound channel frequency / noise channel polynomial counter
def songCounterControl_working equ $CF0F ; Working noise channel counter control (upper byte of working sound channel frequency)
def audioChannelOptions equ $CF10 ; $CF10..23: Audio channel options (low bytes correspond with $FF10..23, and code exploits this fact)
;        {
def songSweep_square1 equ $CF10 ; Tone/sweep channel sweep
def songSoundLength_square1 equ $CF11 ; Tone/sweep channel sound length / wave pattern duty
def songEnvelope_square1 equ $CF12 ; Tone/sweep channel envelope
def songFrequency_square1 equ $CF13 ; Tone/sweep channel frequency
;            $CF15: Unused
def songSoundLength_square2 equ $CF16 ; Tone channel sound length / wave pattern duty
def songEnvelope_square2 equ $CF17 ; Tone channel envelope
def songFrequency_square2 equ $CF18 ; Tone channel frequency
def songEnableOption_wave equ $CF1A ; Wave channel enable
def songSoundLength_wave equ $CF1B ; Wave channel sound length
def songVolume_wave equ $CF1C ; Wave channel volume (0 = mute, 20h = 100%, 40h = 50%, 60h = 25%)
def songFrequency_wave equ $CF1D ; Wave channel frequency
;            $CF1F: Unused
def songSoundLength_noise equ $CF20 ; Noise channel sound length
def songEnvelope_noise equ $CF21 ; Noise channel envelope
def songPolynomialCounter_noise equ $CF22 ; Noise channel polynomial counter
def songCounterControl_noise equ $CF23 ; Noise channel counter control
;        }
;
def songChannelInstructionPointer_square1 equ $CF26 ; Song tone/sweep channel instruction pointer
def songChannelInstructionPointer_square2 equ $CF28 ; Song tone channel instruction pointer
def songChannelInstructionPointer_wave equ $CF2A ; Song wave channel instruction pointer
def songChannelInstructionPointer_noise equ $CF2C ; Song noise channel instruction pointer
;        {
;            Instruction format:
;                00:          End of instruction list
;                ii:          For 9Fh <= ii <= F0h (only A0h..ACh is usable). Instruction timer = [[$CF01] + (ii & ~A0h)]
;                F1 ee ss ll: For non-wave channels.
;                                 Working sound channel envelope = ee
;                                 Working sound channel sweep = ss
;                                 Working sound channel wave pattern duty = ll & C0h
;                                 Working sound channel effect index / sound length = ll & ~C0h
;                F1 pppp vv:  For the wave channel.
;                                 Pointer to wave pattern data = pppp
;                                 Working sound channel volume = vv & 60h
;                                 Working sound channel effect index = vv & ~60h
;                F2 pppp:     Set tempo: $CF01 = pppp
;                F3 oo:       Set transpose: $CF00 = oo. (Add oo to any played music notes)
;                F4 nn:       Repeat from after this instruction nn times |: (sets $CF31/$CF33)
;                F5:          Repeat :| (decrements $CF31)
;                ii:          For ii >= F6h. Clear sound effects and song
;                ii:          For 00 < ii < 9Fh:
;                    01:      Rest. Mute working sound channel
;                    03:      Echo note. For non-noise channels. If fading out music: working sound channel envelope / volume = 8, else working sound channel envelope / volume = 66h. Set working sound channel frequency
;                    05:      Echo note. For non-noise channels. If fading out music: working sound channel envelope / volume = 8, else working sound channel envelope / volume = 46h. Set working sound channel frequency
;                    ii:      Otherwise. For non-noise channels. Working sound channel frequency = [music notes + [ii]], working sound channel envelope = [$CF35]
;                    ii:      Otherwise. For the noise channel:
;                                 Working sound channel sound length       = [$41BB + ii]
;                                 Working sound channel envelope           = [$41BB + ii + 1]
;                                 Working sound channel polynomial counter = [$41BB + ii + 2]
;                                 Working sound channel counter control    = [$41BB + ii + 3]
;        }
def songSoundChannelEffectTimer equ $CF2E ; Song sound channel effect timer. 11h frame timer (bug?) for indexing table at $4263/$4273/$4283. Shared across all sound channels(!)

def songProcessingStates equ $CF2F
;        {
;            $CF2F: Section pointer. Big endian(!). A 'section pointer' of 00F0 followed by pppp means to go to pppp, 0000 means end of list
;            $CF31: Repeat count
;            $CF33: Repeat point
;            $CF34: Instruction length
;            $CF35: Sound envelope / volume
;            $CF36: Instruction timer
;            $CF37: Effect index (non-noise) / sound length (noise)
;            {
;                ; Effect indices
;                2: World's most negligible effect
;                3: Vibrato
;                4: Chorus
;                6: Slide up - slow
;                7: Slide up - fast
;                8: Slide down
;                9: Tiny pitch up
;                Ah: Small pitch up
;            }
;        }
;        $CF38..40: Tone/sweep channel song processing state
;        $CF41..49: Tone channel song processing state
;        $CF4A..52: Wave channel song processing state
;        $CF53..5B: Noise channel song processing state
macro makeChannelSongProcessingState ; [label prefix], [base address]
    def songChannelSongProcessingState_\1 equ \2
    def songSectionPointer_\1 equ \2
    def songRepeatCount_\1 equ \2+2
    def songRepeatPoint_\1 equ \2+4
    def songInstructionLength_\1 equ \2+5
    def songNoteEnvelope_\1 equ \2+6
    def songNoteVolume_\1 equ \2+6
    def songInstructionTimer_\1 equ \2+7
    def songEffectIndex_\1 equ \2+8
endm
    makeChannelSongProcessingState working,$CF2F
    makeChannelSongProcessingState square1,$CF38
    makeChannelSongProcessingState square2,$CF41
    makeChannelSongProcessingState wave,$CF4A
    makeChannelSongProcessingState noise,$CF53

def songFadeoutTimer equ $CF5C ; Song fadeout timer. Set to D0h when initiating fading out music
;        {
;            0: Song play = song interruption request = 0, disable sound channels
;            10h: Sound envelope / volume = 13h
;            30h: Sound envelope / volume = 25h
;            70h: Sound envelope / volume = 45h. Disable noise channel. Wave channel volume = 60h
;            A0h: Sound envelope / volume = 65h
;        }
def ramCF5D equ $CF5D ; Set to tone/sweep sound envelope when fading out music. Never read
def ramCF5E equ $CF5E ; Set to tone sound envelope when fading out music. Never read
def ramCF5F equ $CF5F ; Set to wave volume when fading out music. Never read
def songFrequencyTweak_square2 equ $CF60 ; Tone channel frequency tweak. Set to 1 if [$5F30 + ([song request] - 1) * 2] & 1 in $48A0
;    }
def songProcessingStateBackup equ $CF61 ; $CF61..C1: Backup of song processing state (during song interruption)

def songPlayingBackup equ $CFC5 ; Backup of song playing (during song interruption)

def audioPauseControl equ $CFC7 ; Audio pause control
;{
    def audioPauseControl_pause equ 1 ; Pause (play pause sound effect, stop other music)
    def audioPauseControl_unpause equ 2 ; Unpause (play unpause sound effect)
;}
def audioPauseSoundEffectTimer equ $CFC8 ; Audio pause sound effect timer
def songSweepBackup_square1 equ $CFC9 ; Backup of tone/sweep channel sweep (during song interruption)

def sfxVariableFrequency_square1 equ $CFD1 ; Variable tone/sweep channel frequency. Only the lower byte. Used by metroid cry

def ramCFE3 equ $CFE3 ; Set to wave pattern data pointer by song instruction F1h. Never read
def sfxRequest_lowHealthBeep equ $CFE5 ; Low health beep / wave channel sound effect request
def sfxRequest_wave equ $CFE5 ; Low health beep / wave channel sound effect request
def sfxPlaying_lowHealthBeep equ $CFE6 ; Low health beep / wave channel sound effect playing
def sfxPlaying_wave equ $CFE6 ; Low health beep / wave channel sound effect playing
;    {
;        0: Samus' health >= 50
;        1: Samus' health < 10
;        2: Samus' health < 20
;        3: Samus' health < 30
;        4: Samus' health < 40
;        5: Samus' health < 50
;    }
def sfxPlayingBackup_lowHealthBeep equ $CFE7 ; Backup of low health beep sound effect playing (during song interruption)
def sfxTimer_wave equ $CFE8 ; Wave channel sound effect timer
def sfxLength_wave equ $CFE9 ; Wave channel sound effect length
;    $CFEA: Unused
def ramCFEB equ $CFEB ; Cleared by $43C4, otherwise unused
def audioChannelOutputStereoFlags equ $CFEC ; Audio channel output stereo flags
def audioChannelOutputStereoFlagsBackup equ $CFED ; Backup of audio channel output stereo flags (during song interruption)
def loudLowHealthBeepTimer equ $CFEE ; Loud low health beep timer
;}
;}
;
;
;;;; $D000..DFFF: WRAM bank 1 ;;;
section "WRAM bank 0 - D000", wramx[$d000]
;{
wramUnused_D000: ds 8 ; $D000..07: Unused

tempMetatile:
.topLeft:     ds 1 ; $D008: Metatile top-left
.topRight:    ds 1 ; $D009: Metatile top-right
.bottomLeft:  ds 1 ; $D00A: Metatile bottom-left
.bottomRight: ds 1 ; $D00B: Metatile bottom-right

def samusPrevYPixel = $D00C ; Samus' previous Y position. Used for scrolling, low byte only
def samusBeamCooldown = $D00D ; Auto-fire cooldown counter
def doorScrollDirection = $D00E ; Door transition direction
;{
;    1: Right
;    2: Left
;    4: Up
;    8: Down
;}
def samusAirDirection = $D00F ; Direction Samus is moving in air, used for spin-jumping, damage boosting, and bomb knockback
;{
;    FFh: Up-left
;    0: Up
;    1: Up-right
;}
def samus_jumpStartCounter = $D010 ; Counter for the beginning of Samus's jump state (used in the jumpStart pose)
def unused_D011 = $D011 ; Nothing. Only cleared
def weaponDirection = $D012 ; Direction of the projectile currently being processed
;
def samusPose = $D020 ; Samus' pose
;{
;    00: Standing
;    01: Jumping
;    02: Spin-jumping
;    03: Running (set to 83h when turning)
;    04: Crouching
;    05: Morphball
;    06: Morphball jumping
;    07: Falling
;    08: Morphball falling
;    09: Starting to jump
;    0A: Starting to spin-jump
;    0B: Spider ball rolling
;    0C: Spider ball falling
;    0D: Spider ball jumping
;    0E: Spider ball
;    0F: Knockback
;    10: Morphball knockback
;    11: Standing bombed
;    12: Morphball bombed
;    13: Facing screen
;    18: Being eaten by Metroid Queen
;    19: In Metroid Queen's mouth
;    1A: Being swallowed by Metroid Queen
;    1B: In Metroid Queen's stomach
;    1C: Escaping Metroid Queen
;    1D: Escaped Metroid Queen
;}
;
def samus_animationTimer = $D022
; Used by the running animation. 
;  Bits 4 and 5 select the animation frame. Clamped to be below $30. Typically incremented by 3 when running.
; Also used as a cooldown timer for certain actions (holding down to morph, up to stand, etc.)

def camera_scrollDirection = $D023 ; Direction of screen movement
;{
;    10: Right
;    20: Left
;    40: Up
;    80: Down
;}
def samus_fallArcCounter = $D024 ; Index into falling velocity arrays. Max value is $16
; $D025 - Unused?
def samus_jumpArcCounter = $D026 ; Index into jump velocity arrays. Values below $40 use a linear velocity case instead. Subtract by $40 before indexing an array with this.
prevSamusXPixel  = $D027 ; $D027: Samus' previous X position
prevSamusXScreen = $D028
prevSamusYPixel  = $D029 ; $D029: Samus' previous Y position
prevSamusYScreen = $D02A
def samusFacingDirection = $D02B ; Direction Samus is facing. Saved to SRAM, mirror of $D81E?
;{
;    0: Left
;    1: Right
;}
def samus_turnAnimTimer = $D02C ; Timer for turnaround animation (facing the screen). Used and decremented when MSB of samusPose is set.

; $D02D..30: Vertical offsets to test for Samus's horizontal collision
def collision_samusYOffset_A = $D02D
def collision_samusYOffset_B = $D02E
def collision_samusYOffset_C = $D02F
def collision_samusYOffset_D = $D030
; $D031: Unused. Was likely intended for as a RAM value for the 5th horizontal test point.

def projectileIndex = $D032 ; Index of working projectile
def samus_speedDown = $D033 ; Set by samus_moveVertical. Cleared by morph
def samus_speedDownTemp = $D034 ; Temp variable used by samus_moveVertical
def camera_speedRight = $D035 ; Screen right velocity
def camera_speedLeft  = $D036 ; Screen left velocity
def camera_speedUp    = $D037 ; Screen up velocity
def camera_speedDown  = $D038 ; Screen down velocity

def title_unusedD039 = $D039 ; Set to 0 by load title screen, otherwise unused
;
def samus_onscreenYPos = $D03B ; Samus' Y position on screen
def samus_onscreenXPos = $D03C ; Samus' X position on screen
def spiderContactState = $D03D ; Spider ball orientation
;{
; The game checks the following points on the spider ball
; Point Bitmasks
;   0    %0001
;   1    %0010                    2 _6_ 0
;   2    %0100                     /   \
;   3    %1000                    5|   |4
;   4    %0011                     \___/
;   5    %1100                    3  7  1
;   6    %0101
;   7    %1010
; Notice that the bitmasks for the sides are the OR'd sum of the bitmasks their
;  adjacent corners.
;
;    0: In air
;    1: Outside corner: Of left-facing wall and ceiling
;    2: Outside corner: Of left-facing wall and floor
;    3: Flat surface:   Left-facing wall
;    4: Outside corner: Of right-facing wall and ceiling
;    5: Flat surface:   Ceiling
;    6: Unused:         Top-left and bottom-right corners of ball in contact
;    7: Inside corner:  Of left-facing wall and ceiling
;    8: Outside corner: Of right-facing wall and floor
;    9: Unused:         Bottom-left and top-right corners of ball in contact
;    A: Flat surface:   Floor
;    B: Inside corner:  Of left-facing wall and floor
;    C: Flat surface:   Right-facing wall
;    D: Inside corner:  Of right-facing wall and ceiling
;    E: Inside corner:  Of right-facing wall and floor
;    F: Unused:         Embedded in solid
;}
;
def spiderBallDirection = $D042 ; Spider ball translational direction
;{
;    1: Right
;    2: Left
;    4: Up
;    8: Down
;}
;
def spiderDisplacement  = $D043 ; Distance moved by spider ball (non-directional)
def spiderRotationState = $D044 ; Spider ball rotational direction
;{
;    0: Not moving
;    1: Anti-clockwise
;    2: Clockwise
;}
def samusItems = $D045 ; Samus' equipment

def debugItemIndex = $D046 ; Debug screen selector index
def vramTransferFlag = $D047 ; VRAM tiles update flag (see $FFB1..B6, $2BA3, $27BA)
def waterContactFlag = $D048 ; Flag to tell if Samus is touching water
def samus_unmorphJumpTimer = $D049 ; Timer for allowing an unmorph jump. Decremented every frame. Written to in several places.
def bomb_mapYPixel = $D04A ; Bomb Y position in map-space (for BG collision)
def bomb_mapXPixel = $D04B ; Bomb X position in map-space (for BG collision)
def mapUpdate_unusedVar = $D04C ; Cleared by prepMapUpdate, set to FFh in prepMapUpdate or during screen transition when rendering a row/column of blocks. Never read
def samusActiveWeapon = $D04D ; Weapon equipped.  See also $D055
;{
;    0: Normal
;    1: Ice
;    2: Wave
;    3: Spazer
;    4: Plasma
;    8: Missile
;}
def bankRegMirror = $D04E ;Bank
def samusInvulnerableTimer = $D04F ; Invincibility timer
def samusEnergyTanks   = $D050 ; Samus' max health, in tanks,     see also $D817
def samusEnergyTanks   = $D050 ; Samus' max health, in tanks,     see also $D817
def samusCurHealthLow  = $D051 ; Samus' current health,           see also $D818/$D084
def samusCurHealthHigh = $D052 ; Samus' current health (in tanks) see also $D819/$D085

def samusCurMissilesLow  = $D053 ; Samus' missiles (low byte)     see also $D81C
def samusCurMissilesHigh = $D054 ; Samus' missiles (high byte)

def samusBeam = $D055 ; Current beam that Samus owns. See also $D04D/$D816
;{
;    0: Normal
;    1: Ice
;    2: Wave
;    3: Spazer
;    4: Plasma
;}
samusSolidityIndex = $D056 ; Samus solid block threshold
samus_screenSpritePriority = $D057 ; Room sprite priority
;{
;    0: Sprites over BG
;    1: BG over sprites
;}
def currentLevelBank = $D058 ; Bank for current room
def deathAnimTimer = $D059 ; Death sequence timer
def pDeathAltAnimBaseLow  = $D05A ; Base address of pixels to clear in Samus' VRAM tiles (for unused animation)
def pDeathAltAnimBaseHigh = $D05B
def samusSpriteCollisionProcessedFlag = $D05C ; Flag set when collision_samusEnemies ($32AB) is executed to prevent it from being executed unnecessarily

;$D05D..60: Collision information
; - Copied to $C466..69 by a generic enemy routine if the enemy pointer matches
collision_weaponType = $D05D ; Projectile type - Set to [$D08D] or an appropriate constant
collision_pEnemyLow  = $D05E ; Enemy data pointer of target enemy (if collision happens)
collision_pEnemyHigh = $D05F
collision_weaponDir  = $D060 ; Projectile direction - Set to [$D012] if shot
;
def acidContactFlag = $D062 ; Flag set every frame if Samus is touching acid.
def deathFlag = $D063 ; Dying flag
;{
;    0: Not dying
;    1: Dying
;    FFh: Dead
;}
samusTopOamOffset = $D064 ; Last OAM offset used by Samus, HUD, etc. Used in by door transition routine ($239C) to erase enemies
vramTransfer_srcBank = $D065 ; VRAM tiles update source bank (see $FFB1..B6, $2BA3)
countdownTimerLow = $D066;  ; Generic countdown timer used for
countdownTimerHigh = $D067; ;  various events
;{
;    Decremented during v-blank interrupt handler.
;    Set to 140h on loading Samus. Whilst set, Samus can't move when facing screen and low health beep doesn't play.
;    Set to 2Fh on door fade, cleared on Dh, used as index for palette fade.
;    Set to FFh on game over, reboots on 0.
;    Set to 160h by ability-get, 60h for missile-get, 0 for refill. Whilst set, varia suit and other pickups stall.
;    Set to FFFFh on load title screen. Checked as timer for title screen flashing
;    Used in many other places in bank 5
;}
;
enemySolidityIndex_canon = $D069 ; Canonicaly copy of the enemy solid block threshold (not used by enemy code, however)
;
unused_D06B = $D06B ; Unused. Cleared by loading save
def itemCollected = $D06C ; Item pickup being collected at the moment. Set to ([enemy sprite ID] - 81h) / 2 + 1 by $2:4DD3
;{
;    1: Plasma
;    2: Ice
;    3: Wave
;    4: Spazer
;    5: Bomb
;    6: Screw attack
;    7: Varia
;    8: Hi-jump
;    9: Space jump
;    Ah: Spider ball
;    Bh: Spring ball
;    Ch: Energy expansion
;    Dh: Missile expansion
;    Eh: Energy refill
;    Fh: Missile refill
;}
def itemCollectionFlag = $D06D ; Item collection flag. Stops the status bar from updating. Three values:
;{
;    $00 = No item is being collected
;    $FF = Set by Item AI to indicate an item is being collected
;    $03 = Set by handleItemPickup (00:372F) to tell the item AI that it's time to delete the item
;}

def maxOamPrevFrame = $D06E ; OAM slots used in by the previous frame

def itemOrb_collisionType = $D06F  ; Used (?) to override collision results during item collection
def itemOrb_pEnemyWramLow  = $D070 ;
def itemOrb_pEnemyWramHigh = $D071 ;

def samus_spinAnimationTimer = $D072 ; Animation timer for spinning. Incremented by general pose handler and door transitions.
def credits_textPointerLow  = $D073 ; Pointer to the working copy of the credits in SRAM. Stops being incremented when it hits the byte $F0. Character data is subtracted by $21 to adjust to almost-ASCII
def credits_textPointerHigh = $D074 ;
def credits_unusedVar = $D075 ; Cleared, but never read
def credits_nextLineReady = $D076 ; Flag to indicate that the next line of the credits is ready to be uploaded

def acidDamageValue = $D077 ; Acid damage. Saved to SRAM
def spikeDamageValue = $D078 ; Spike damage. Saved to SRAM
def loadingFromFile = $D079 ; 00h: loading new game, otherwise: loading from file. Adjusts behaviors relating to loading the font and if Samus stays facing the screen.
def title_clearSelected = $D07A ; 0: Start selected, 1: Clear selected
def titleStarY = $D07B ; Star Y position
def titleStarX = $D07C ; Star X position
def saveContactFlag = $D07D ; On save pillar flag
;{
;    0: Not on save pillar
;    FFh: On save pillar
;}
def bg_palette  = $D07E ; BG palette
def ob_palette0 = $D07F ; Object 0 palette
def ob_palette1 = $D080 ; Object 1 palette

def samusMaxMissilesLow  = $D081 ; Samus' max missiles, see also $D81A
def samusMaxMissilesHigh = $D082 ; Samus' max missiles (high byte)
def earthquakeTimer = $D083 ; Earthquake timer (how long the earthquake itself lasts)
def samusDispHealthLow  = $D084 ; Samus' health for display,   see also $D051/$D818
def samusDispHealthHigh = $D085 ; Samus' energy tanks for display, see also $D052/$D819
def samusDispMissilesLow  = $D086 ; Samus' missiles for display, see also $D053/$D81C
def samusDispMissilesHigh = $D087 ; Samus' missiles for display (high byte)
def saveMessageCooldownTimer = $D088 ; Cooldown timer for game save message (for displaying the "Completed" text)
def metroidCountReal = $D089 ; Real number of metroids remaining (BCD)
def beamSolidityIndex = $D08A ; Projectile solid block threshold
def queen_roomFlag = $D08B ; 11h: In Metroid Queen's room (set by screen transition command 8), other values less than 10h: not in Queen's room
def variaAnimationFlag = $D08C ; Flag for doing the varia-collection-style VRAM update (pixel-row by pixel-row) -- $00: off, $FF: on
def weaponType = $D08D ; Type of projectile currently being processed
def doorIndexLow  = $D08E ; Index of screen transition command set. Set to [$4300 + ([screen Y position high] * 10h + [screen X position high]) * 2] & ~800h by set up door transition
def doorIndexHigh = $D08F
def queen_eatingState = $D090 ; Metroid Queen eating pose
;{
;    Sets Samus pose = escaping Metroid Queen when 7, checked for 5/20h and set to 6 in in Metroid Queen's mouth
;    0: Otherwise                        - Set by Queen
;    1: Samus entering mouth             - Set by Samus collision
;    2: Mouth closing                    - Set by Samus pose handler
;    3: Mouth closed                     - Set by Queen
;    4: Bombed whilst mouth closed       - Set by bomb collision
;    5: Samus escaping bombed mouth      - Set by Queen
;    6: Swallowing Samus                 - Set by Samus pose handler
;    7: Bombed whilst swallowing Samus   - Set by bomb collision
;    8: Samus escaping bombed stomach    - Set by Queen
;    10h: Paralysed (can enter mouth)    - Set by beam collision
;    20h: Dying (from bombing the mouth) - Set by Queen
;    22h: Dying                          - Set by Queen
;}
def nextEarthquakeTimer = $D091 ; Time until next Metroid earthquake. Counts down in $100h frame intervals after killing a metroid.
def currentRoomSong = $D092 ; Song for room. Used when restoring song when loading a save and after some other events
def itemCollected_copy = $D093 ; Copy of $D06C, used by handleItemPickup (00:372F)
def unused_itemOrb_yPos = $D094 ; Written to by item orb AI, but never read?
def unused_itemOrb_xPos = $D095 ; Written to by item orb AI, but never read?
def metroidCountShuffleTimer = $D096 ; Metroids remaining shuffle timer
def credits_samusAnimState = $D097 ; Samus' animation state during the credits
def gameTimeMinutes = $D098 ; In-game timer, minutes
def gameTimeHours   = $D099 ; In-game timer, hours
def metroidCountDisplayed = $D09A ; Number of Metroids remaining (displayed, not real)
def fadeInTimer = $D09B ; Fade in timer. Max value of 3Fh, is set to zero when Dh reached
def credits_runAnimFrame   = $D09C ; Tracks current animation frame of run animation
def credits_runAnimCounter = $D09D ; Counts video frames between animation frames
def justStartedTransition = $D09E ; $00 = Normal, $FF = Just entered a screen transition
def credits_scrollingDone  = $D09F ; Flag to indicate if credits stopped scrolling (allows timer to display)
def debugFlag = $D0A0 ; Activates debug pause menu and other stuff
def samus_prevHealthLowByte = $D0A1 ; Previous value of health (low-byte)
def gameTimeSeconds = $D0A2 ; 256-frames long (~1/14 of a minute), not 60 frames long. In-game time, but not saved
def activeSaveSlot = $D0A3 ; Save slot
def title_showClearOption = $D0A4 ; Show clear save slot option flag
def songRequest_afterEarthquake = $D0A5 ; Song to play after earthquake
def sound_playQueenRoar = $D0A6 ; Enable Queen's distant roar as a sound effect
def metroidLCounterDisp = $D0A7 ; L Counter value to display (Metroids remaining in area)
def wramUnknown_D0A8 = $D0A8 ; Set to 0 by $239C
;
;$D0F9: Used in title
;
def credits_starArray = $D600 ; ds $20 (inadvertantly, only the first $10 bytes are properly initialized)
;
def doorScriptBuffer = $D700 ; to D73F: Screen transition commands (see $5:46E5)
	def doorScriptBufferSize = $40
;

section "WRAM SaveBuffer", wramx[$d800]
;$D800..25: Save data. Data loaded from $1:4E64..89 by game mode Bh, loaded from $A008..2D + save slot * 40h by game mode Ch
;{
saveBuffer: ; $26 bytes
saveBuf_samusYPixel:  ds 1 ; $D800: Samus' Y position
saveBuf_samusYScreen: ds 1 ; $D801: Samus' Y position
saveBuf_samusXPixel:  ds 1 ; $D802: Samus' X position
saveBuf_samusXScreen: ds 1 ; $D803: Samus' X position

saveBuf_cameraYPixel:  ds 1 ; $D804: Camera Y position
saveBuf_cameraYScreen: ds 1 ; $D805: Camera Y position
saveBuf_cameraXPixel:  ds 1 ; $D806: Camera X position
saveBuf_cameraXScreen: ds 1 ; $D807: Camera X position

; Implicitly bank 6
saveBuf_enGfxSrcLow:  ds 1 ; $D808: Enemy tiles source address (low byte)
saveBuf_enGfxSrcHigh: ds 1 ; $D809: Enemy tiles source address (high byte)

saveBuf_bgGfxSrcBank: ds 1 ; $D80A: Background tiles source bank
saveBuf_bgGfxSrcLow:  ds 1 ; $D80B: Background tiles source address (low byte)
saveBuf_bgGfxSrcHigh: ds 1 ; $D80C: Background tiles source address (high byte)

; Implicitly bank 8
saveBuf_tiletableSrcLow:  ds 1 ; $D80D: Metatile definitions source address (low byte)
saveBuf_tiletableSrcHigh: ds 1 ; $D80E: Metatile definitions source address (high byte)

; Implicitly bank 8
saveBuf_collisionSrcLow:  ds 1 ; $D80F: Tile properties source address (low byte)
saveBuf_collisionSrcHigh: ds 1 ; $D810: Tile properties source address (high byte)

saveBuf_currentLevelBank: ds 1 ; $D811: Bank for current room

saveBuf_samusSolidityIndex: ds 1 ; $D812: Samus solid block threshold
saveBuf_enemySolidityIndex: ds 1 ; $D813: Enemy solid block threshold
saveBuf_beamSolidityIndex:  ds 1 ; $D814: Projectile solid block threshold

saveBuf_samusItems: ds 1 ; $D815: Samus' equipment
saveBuf_samusBeam:  ds 1 ; $D816: Samus' beam

saveBuf_samusEnergyTanks: ds 1 ; $D817: Samus' max health in energy tanks
saveBuf_samusHealthLow:   ds 1 ; $D818: Samus' current health (low byte)
saveBuf_samusHealthHigh:  ds 1 ; $D819: Samus' current health (energy tanks)

saveBuf_samusMaxMissilesLow:  ds 1 ; $D81A: Samus' max missiles (low byte)
saveBuf_samusMaxMissilesHigh: ds 1 ; $D81B: Samus' max missiles (high byte)
saveBuf_samusCurMissilesLow:  ds 1 ; $D81C: Samus' missiles (low byte)
saveBuf_samusCurMissilesHigh: ds 1 ; $D81D: Samus' missiles (high byte)

saveBuf_samusFacingDirection: ds 1 ; $D81E: Direction Samus is facing

saveBuf_acidDamageValue:  ds 1 ; $D81F: Acid damage
saveBuf_spikeDamageValue: ds 1 ; $D820: Spike damage

saveBuf_metroidCountReal: ds 1 ; $D821: Real number of Metroids remaining

saveBuf_currentRoomSong: ds 1 ; $D822: Song for room

; Frames and seconds are not saved
saveBuf_gameTimeMinutes: ds 1 ; $D823: In-game timer, minutes
saveBuf_gameTimeHours:   ds 1 ; $D824: In-game timer, hours

saveBuf_metroidCountDisplayed: ds 1 ; $D825: Number of Metroids remaining
;}

section "Tiletable Array", wramx[$d900]
respawningBlockArray:: ds $100
;$D900..FF: Respawning block data. 10h byte slots
;{
;    + 0: Frame counter
;    + 1: Y position
;    + 2: X position
;}

tiletableArray:: ds $200 ;$DA00..DBFF: Metatile definitions
.end::
collisionArray:: ds $100 ;$DC00..FF: Tile properties. Indexed by tilemap value. Note that tilemap value < 4 is a respawning shot block
.end::
;{  mask - bitnum
;    01h : 0 Water (also causes morph ball sound effect glitch)
;    02h : 1 Half-solid floor (can jump through)
;    04h : 2 Half-solid ceiling (can fall through)
;    08h : 3 Spike
;    10h : 4 Acid
;    20h : 5 Shot block
;    40h : 6 Bomb block
;    80h : 7 Save pillar
;}
projectileArray:: ;$DD00..2F: Projectile data. 10h byte slots
.slotA: ds $10
.slotB: ds $10
.slotC: ds $10
.end:
;{
;    $DD00..1F: Beam slots
;    $DD20: Missile or beam slot
;    + 0: Type
;        0: Normal
;        1: Ice
;        2: Wave
;        3: Spazer
;        4: Plasma
;        7: Bomb beam? (see $2:52C6)
;        8: Missile
;        FFh: None
;    + 1: Direction
;        1: Right
;        2: Left
;        4: Up
;        8: Down
;    + 2: Y position
;    + 3: X position
;    + 4: Wave index
;    + 5: Frame counter
;}
bombArray:: ;$DD30..5F: Bomb data. 10h byte slots
.slotA: ds $10
.slotB: ds $10
.slotC: ds $10
.end:
;{
;    + 0: Type
;        1: Bomb
;        2: Bomb explosion
;        FFh: None
;    + 1: Bomb timer
;    + 2: Y position
;    + 3: X position
;}
wramUnused_DD60: ds $100 - $60 ;$DD60..FF: Unused

; List of metatiles from the map to update to VRAM
mapUpdateBuffer:: ds $100 ; $DE00..FF
mapUpdateFlag = mapUpdateBuffer + 1 ; $DE01
;{
;    + 0: VRAM background tilemap destination address.
;         - $00xx terminates update
;           - Thus, $DE01 is used as a flag that is cleared/checked in some places
;    + 2: Top-left tile
;    + 3: Top-right tile
;    + 4: Bottom-left tile
;    + 5: Bottom-right tile
;}
;$DF00..FF: Stack
;}