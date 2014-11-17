#!/bin/sh
#
# Clean it all; not very elegant; -r == 'really clean' removes bin, lib, ...

args=`getopt r $*`
if [ $? != 0 ]
then
    echo "Usage: $0 [options] where options are:"
    echo "-r: really clean; remove bin, libs, ..., too"
    exit 2
fi

set -- $args

# Set verbose and do_nothing to false
vernose=""
realclean=""
for i in $*
do
    case "$i"
	in
        -r)
            reallyclean="yes";
            shift;;
        --)
            shift; break;;
    esac
done


(cd libdap && make clean)

(cd bes && make clean)

# FIXME jhrg 11/17/14
# (cd olfs && ant clean)

# in a sub-shell
(
if cd modules
then
    for m in `ls -1`; do echo $m; (cd $m && make clean); done
fi
) # 'cd modules sub-shell

if test -n "$reallyclean"
then
    rm -rf bin etc include lib share var
fi
