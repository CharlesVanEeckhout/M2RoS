import os


def byte_lines(data, per_row=16):
    data = [data[i:i+per_row] for i in range(0, len(data), per_row)]
    out = ""
    for line in data:
        out += "    db " + ", ".join([f"${byte:02X}" for byte in line]) + "\n"
    return out

class CollisionEntry:
    def __init__(self, gb_bank, gb_address, size, path):
        self.rom_address = (gb_bank * 0x4000) + (gb_address & 0x3fff)
        self.size = size
        self.path = "./SRC/tilesets/" + path + "_collision.asm"

class MetatilesEntry:
    def __init__(self, gb_bank, gb_address, size, path):
        self.rom_address = (gb_bank * 0x4000) + (gb_address & 0x3fff)
        self.size = size
        self.path = "./SRC/tilesets/" + path + "_metatiles.asm"

data_list = [
    CollisionEntry(0x8,0x4080, 0x100, "finalLab"),
    CollisionEntry(0x8,0x4180, 0x100, "plantBubbles"),
    CollisionEntry(0x8,0x4280, 0x100, "ruinsInside"),
    CollisionEntry(0x8,0x4380, 0x100, "queen"),
    CollisionEntry(0x8,0x4480, 0x100, "caveFirst"),
    CollisionEntry(0x8,0x4580, 0x100, "surface"),
    CollisionEntry(0x8,0x4680, 0x100, "lavaCaves"),
    CollisionEntry(0x8,0x4780, 0x100, "ruinsExt"),
    
    MetatilesEntry(0x8,0x4880, 0x200, "plantBubbles"),
    MetatilesEntry(0x8,0x4a80, 0x200, "ruinsInside"),
    MetatilesEntry(0x8,0x4c80, 0x200, "finalLab"),
    MetatilesEntry(0x8,0x4e80, 0x200, "queen"),
    MetatilesEntry(0x8,0x5080, 0x200, "caveFirst"),
    MetatilesEntry(0x8,0x5280, 0x200, "surface"),
    MetatilesEntry(0x8,0x5480, 0x114, "lavaCavesMid"),
    MetatilesEntry(0x8,0x5594, 0x114, "lavaCavesEmpty"),
    MetatilesEntry(0x8,0x56a8, 0x114, "lavaCavesFull"),
    MetatilesEntry(0x8,0x57bc, 0x200, "ruinsExt"),
]

def extract():
    rom = open("./Metroid2.gb", "rb")
    for data in data_list:
        rom.seek(data.rom_address)
        asm = rom.read(data.size)
        file_content = byte_lines(asm)
        with open(data.path, "w") as f:
            f.write(file_content)
    rom.close()

def clean():
    for data in data_list:
        if os.path.exists(data.path):
            os.remove(data.path)

# EoF
