#!/bin/sh
#
# Clean it all; not very elegant

(cd libdap && make clean)

(cd bes && make clean)

# in a sub-shell
(
if cd modules
then
    for m in `ls -1`; do echo $m; (cd $m && make clean); done
fi
) # 'cd modules sub-shell

rm -rf bin etc include lib share var

