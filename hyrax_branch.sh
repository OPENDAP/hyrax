#!/bin/sh
#
# Clean it all; not very elegant; -r == 'really clean' removes bin, lib, ...

args=`getopt vn $*`
if [ $? != 0 ]
then
    echo "Usage: $0 [options] where options are:"
    echo "-v: verbose"
    echo "-n: dry run; just show what would be done"
    exit 2
fi

set -- $args

# Set verbose and do_nothing to false
verbose="no"
dry_run="no"
for i in $*
do
    case "$i"
	in
        -v)
            verbose="yes";
            shift;;
        -n)
            dry_run="yes";
            shift;;
        --)
            shift; break;;
    esac
done

function do_command {
    if test "$dry_run" = "yes"
    then
	echo "$1"
    else
	if test "$verbose" = "yes"
	then
	    echo $1
	fi
	$1
    fi
}

if test "x$verbose" = "xyes"
then
    echo "Switching to branch $1"
fi

(do_command "cd libdap" && do_command "git checkout $1")

(do_command "cd bes" && do_command "git checkout $1")

(do_command "cd olfs" && do_command "git checkout $1")

# in a sub-shell
(
if cd modules
then
    for m in `ls -1`; do (do_command "cd $m" && do_command "git checkout $1"); done
fi
) # 'cd modules sub-shell
