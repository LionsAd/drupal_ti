#!/bin/bash

cat <<EOF > /tmp/simpletest-result.txt
 ERROR: Test group not found: DrupalTI
1 fails
EOF

cat /tmp/simpletest-result.txt
egrep -i -q "([0-9]+ fails)|(PHP Fatal error)|([0-9]+ exceptions)" /tmp/simpletest-result.txt && exit 1
exit 0
