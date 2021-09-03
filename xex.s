; XEX (A8)

DW $FFFF ; first block

DW CODE_start, CODE_end ; +1 

BASE $2000
CODE_start:
INCLUDE "code.s"

DB 0
CODE_end: