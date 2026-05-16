import os
import importlib
modules = [importlib.import_module("scripts." + m) for m in [
    "extract_chr",
    "extract_maps",
    "extract_credits",
    "extract_doors",
    "extract_enemyData",
    "extract_tileset",
]]

VANILLA_ROM_PATH = "./Metroid2.gb"

def main():
    print('Removing previous resources from disassembly')
    for module in modules:
        module.clean()
    print('Success\n')

    print('Extracting resources from vanilla ROM')
    if not os.path.exists(VANILLA_ROM_PATH):
        print(f"Vanilla ROM file {VANILLA_ROM_PATH} was not found")
        exit()
    for module in modules:
        module.extract(VANILLA_ROM_PATH)
    print('Success')


if __name__ == "__main__":
    main()
