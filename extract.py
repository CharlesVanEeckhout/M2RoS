import os

from scripts import extract_chr
from scripts import extract_maps


print('Removing previous resources from disassembly')
extract_chr.clean()
extract_maps.clean()
print('Success\n')

print('Extracting resources from vanilla ROM')
if not os.path.exists("./Metroid2.gb"):
    print('Vanilla ROM file ./Metroid2.gb was not found')
    exit()
extract_chr.extract()
extract_maps.extract()
print('Success')
