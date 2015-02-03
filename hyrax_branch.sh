#!/bin/sh
#
# For each of the three projects (libdap, bes, olfs) and the bes
# submodules, set the current branch to be 

function help {
    echo "Usage: $0 [options] <branch name>, where it's assumed you're using libdap4"
    echo "unless you supply the -2 switch."
    echo "Options are:"
    echo "-h: help; this message"
    echo "-v: verbose"
    echo "-2: Use libdap, not libdap4"
    echo "-n: dry run; just show what would be done"
}

args=`getopt hv2n $*`
if [ $? != 0 ]
then
    help
    exit 2
fi

set -- $args

# Set verbose and do_nothing to false
verbose="no"
dry_run="no"
libdap="libdap4"

for i in $*
do
    case "$i"
	in
	-h)
	    help
	    exit 0;;
        -v)
            verbose="yes"
            shift;;
	-2)
	    libdap="libdap"
	    shift;;
        -n)
            dry_run="yes"
            shift;;
        --)
            shift; break;;
    esac
done

function verbose {
    if test -n "$verbose"
    then
        echo "$*"
    fi
}

function do_command {
    if test "$dry_run" = "yes"
    then
	echo "$*"
    else
	verbose "$*"
	$*
    fi
}

verbose "Switching to branch $1"

if test -d $libdap
then
verbose "$libdap: "
(do_command "cd $libdap" && do_command "git checkout $1")
fi

if test -d bes
then
verbose "bes: "
(do_command "cd bes" && do_command "git checkout $1")
(do_command "cd bes" && do_command "git submodule foreach" 'git checkout' $1)
fi

if test -d olfs
then
verbose "olfs: "
(do_command "cd olfs" && do_command "git checkout $1")
fi
