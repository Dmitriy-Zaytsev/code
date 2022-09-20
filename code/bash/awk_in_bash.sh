#!/bin/bash
read -r -d '' VAR_READ << 'EOF'
function f(a,b) {
print a
print b
c = "end"
#return c
}

BEGIN {
c = "start"
print "start"
f(1, 5)
print c
}

EOF

gawk -f <(echo -E "$VAR_READ") - "$@"
