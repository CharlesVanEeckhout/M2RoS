# Script by Alex W

import argparse
import csv

def csv2asm(infile, outdir, outname):
    pointerFile = open(outdir+'/'+outname+'Pointers.asm', 'w')
    constFile = open(outdir+'/'+outname+'Constants.asm', 'w')

    pointerFile.write('; This file was automatically generated from '+infile+'. Please do not edit this directly.\n')
    constFile.write('; This file was automatically generated from '+infile+'. Please do not edit this directly.\n')

    with open(infile, newline='') as f:
        i = 0
        reader = csv.reader(f)
        for row in reader:
            pointerFile.write('    dw '+row[0]+' ; '+row[2]+'\n')
            if row[1] != '':
                constFile.write('def '+row[1]+' = ${:02X} ; '.format(i)+row[2]+'\n')
            i += 1
            
    pointerFile.close()
    constFile.close()
    return


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-i','--infile', help='Input CSV file')
    ap.add_argument('-o','--outdir', default='.', help='Output directory for the asm files')
    ap.add_argument('-n','--outname', help='Output Filename Stem')
    args = ap.parse_args()

    csv2asm(args.infile, args.outdir, args.outname)


if __name__ == "__main__":
    main()
