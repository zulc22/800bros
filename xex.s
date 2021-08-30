; XEX (A8)

DW $FFFF ; first block

DW CODE_start, CODE_end+1

BASE $1000
CODE_start:
INCLUDE "code.s"
CODE_end: