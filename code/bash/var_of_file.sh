#!/bin/bash
ALLVAR="A=AAA
B=BBB
C=CCC
"
echo A:$A B:$B C:$C
export `(echo $ALLVAR)`
echo A:$A B:$B C:$C
