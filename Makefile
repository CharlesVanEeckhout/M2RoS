# Constants
ENEMY_SCRIPT_OUT = $(foreach f,\
	spritePointers \
	headerPointers \
	hitboxPointers \
	damageValues \
	nameConstants,\
	SRC/data/enemy_$(f).asm)

SAMUS_SCRIPT_OUT = $(foreach f,\
	bgHitboxTop \
	blockReformHeightTable \
	bombedFallingPoseTransitionTable \
	bombPoseTransitionTable \
	cannonYOffsetByPose \
	damagePoseTransitionTable \
	drawJumpTable \
	horizontalYOffsets \
	poseConstants \
	poseJumpTable \
	possibleShotDirections \
	spriteHitboxTopTable,\
	SRC/samus/samus_$(f).asm)

GENERAL_SCRIPT_OUT = $(foreach f,\
	sprites_credits,\
	SRC/data/$(f)Pointers.asm SRC/data/$(f)Constants.asm)

ALL_CODE = $(shell find SRC/ -type f \( -iname '*.asm' -o -iname '*.chr' \))

# Targets
all: out/M2RoS.gb

#%.2bpp: %.png
#	rgbgfx -o $@ $<

#%.1bpp: %.png
#	rgbgfx -d 1 -o $@ $<

$(ENEMY_SCRIPT_OUT): SRC/data/enemies.csv
	python scripts/enemy_csv2asm.py -i $< -o SRC/data

$(SAMUS_SCRIPT_OUT): SRC/samus/samus.csv
	python scripts/samus_csv2asm.py -i $< -o SRC/samus

$(GENERAL_SCRIPT_OUT): SRC/data/sprites_credits.csv
	python scripts/general_csv2asm.py -i $< -o SRC/data -n sprites_credits

out/game.o: SRC/game.asm out $(ENEMY_SCRIPT_OUT) $(SAMUS_SCRIPT_OUT) $(GENERAL_SCRIPT_OUT) $(ALL_CODE)
	rgbasm -o $@ -Weverything -I SRC/ $<

out/M2RoS.gb: out/game.o
	rgblink -n out/M2RoS.sym -m out/M2RoS.map -o $@ $<
	rgbfix -v $@

	md5sum $@
	diff --brief $@ Metroid2.gb

out:
	mkdir $@

clean:
	rm -f out/game.o out/M2RoS.gb out/M2RoS.sym out/M2RoS.map $(ENEMY_SCRIPT_OUT) $(SAMUS_SCRIPT_OUT) $(GENERAL_SCRIPT_OUT)
#	find . \( -iname '*.1bpp' -o -iname '*.2bpp' \) -exec rm {} +
