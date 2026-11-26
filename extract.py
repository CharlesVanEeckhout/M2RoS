import os
import importlib
MODULES = [importlib.import_module("scripts." + m) for m in [
    "extract_chr",
    "extract_maps",
    "extract_credits",
    "extract_doors",
    "extract_enemyData",
    "extract_tileset",
]]
OPTIMIZE_MODULES = [importlib.import_module("scripts." + m) for m in [
    "optimize_credits",
    "optimize_doors",
]]

VANILLA_ROM_PATH = "./Metroid2.gb"

def main():
    print('Removing previous resources from disassembly')
    for module in MODULES:
        module.clean()
    print('Success\n')

    print('Extracting resources from vanilla ROM')
    if not os.path.exists(VANILLA_ROM_PATH):
        print(f"Vanilla ROM file {VANILLA_ROM_PATH} was not found")
        exit()
    for module in MODULES:
        module.extract(VANILLA_ROM_PATH)
    print('Success\n')
    
    print('Optimizing extracted resources')
    for optimize_module in OPTIMIZE_MODULES:
        optimize_module.main()
    print('Success')


if __name__ == "__main__":
    main()
