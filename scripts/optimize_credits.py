from pathlib import Path
import re

FILE_PATH = Path("./SRC/data/credits.asm")

VALUE_OFFSET = -0x21


def main():
    with open(FILE_PATH, "r") as f:
        out = f.read()

    # add VALUE_OFFSET to all db hex values
    for m in re.finditer(r"\$([\da-fA-F]{2})", out):
        value = int(m[1], 16)
        value = (value + VALUE_OFFSET) & 0xff
        out = out[:m.start(1)] + f"{value:02X}" + out[m.end(1):]

    with open(FILE_PATH, "w") as f:
        f.write(out)


if __name__ == "__main__":
    main()
