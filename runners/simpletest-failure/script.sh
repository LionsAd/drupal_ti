#!/bin/bash

cat <<EOF > /tmp/simpletest-result.txt
 ERROR: Test group not found: DrupalTI
1 fails
EOF

cat /tmp/simpletest-result.txt
egrep -i "([1-9]+ fail)|(Fatal error)|([1-9]+ exception)" /tmp/simpletest-result.txt && exit 1
exit 0
