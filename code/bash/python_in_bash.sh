#!/bin/bash
export bashvar=DIMA

python - <<EOF
Pvar = 'python var'
print Pvar
Bvar = '$bashvar'
print Bvar
EOF
