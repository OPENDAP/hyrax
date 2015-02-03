#!/bin/bash
#
# Use the scripts in the 'hyrax' repo to perform a nightly build

# This is normally run by root, which will likely not have /usr/local
# bin in its path.
PATH=/usr/local/bin:$PATH

source spath.sh

function help {
    echo "Usage: $0 [options]"
    echo "Options are:"
    echo "-h: help; this message"
    echo "-v: verbose"
    echo "-2: Build the dap2 code and bes/modules branches"
}

args=`getopt hv2 $*`
if [ $? != 0 ]
then
    help
    exit 2
fi

set -- $args

# Set verbose and do_nothing to false
verbose="no"
dap2_build=""

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
	    dap2_build="-2"
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

verbose "Cloning hyrax..."

./hyrax_clone.sh -v -D $dap2_build

# Using -v (verbose) is needed to get the status info in the logs.
# That information is used by hyrax_report.sh. The -c (clean) option
# only cleans our code; it does not force a rebuild of the
# dependencies if the are built (NB: -D suppresses getting our copy 
# of the deps from github.

verbose "Building hyrax..."

./hyrax_build.sh -v -c $dap2_build

verbose "Recording the build..."

./hyrax_report.sh -o centos_6 -r "`cat login.txt`"
