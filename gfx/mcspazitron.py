"""
'McSpazitron': 3(+1) color Atari sprite encoder
zulc22 2021
"""

import PIL, PIL.Image
import os

def getFilenamesByExt(dir:str, ext:str):
    return [ x for x in os.listdir(dir) if (x.endswith('.'+ext) and not x.endswith('.pal.png')) ]

# ANSIclc = "\033[39;49m"
# def setRGBColor(foreground:bool, color):
#     return f"\033[{ 38 if foreground else 48 };2;{ ';'.join([str(i) for i in color[0:3]]) }m"

pngFiles = getFilenamesByExt(".", "png")
ctiaPal = PIL.Image.open('ctia.pal.png').load()

for file in pngFiles:
    # print(f"Opening image {file}")
    im = PIL.Image.open(file).load()
    pal = [ im[0,x] for x in range(1,6) ]
    # print("Palette: ", end='')
    # for p in pal:
    #     print(f"{setRGBColor(True, p)}█", end='')
    # print(ANSIclc)
    # print("Finding first sprite")
    x1, y1 = 1,1
    x2, y2 = 9,1
    while im[1,y2] != pal[-1]:
        y2 += 1
    n='.'.join(file.split('.')[:-1])
    print(f"d{n}:")
    print(f"DB {y2-y1};px tall")
    for p in pal[:-2]:
        difs = []
        for y in range(0,0x10):
            for x in range(0,0x10,2):
                difs.append( (f"{hex(y)[-1]}{hex(x)[-1]}", (
                    abs( ctiaPal[x,y][0] - p[0] ) +
                    abs( ctiaPal[x,y][1] - p[1] ) +
                    abs( ctiaPal[x,y][2] - p[2] )
                )))
        difs.sort(key=lambda a : a[1])
        print(f"DB ${difs[0][0].upper()} ;C{pal.index(p)} (difd={difs[0][1]})")
    for i in range(len(pal)-2):
        print(f"DW d{n}C{i}")

    for p in pal[:-2]:
        #print(f"Seperating {setRGBColor(False,p)}{setRGBColor(True,[255,255,255])} color {pal.index(p)} {ANSIclc}")
        #print(setRGBColor(True,p),end='')
        print(f"d{'.'.join(file.split('.')[:-1])}C{pal.index(p)}:")
        for y in range(y1,y2):
            print("DB %",end='')
            for x in range(x1,x2):
                px = im[x,y] == p
                print("1" if px else "0", end='')
            print()
        # print(ANSIclc,end='')

