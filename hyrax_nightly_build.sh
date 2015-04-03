#!/bin/bash
#
# Use the scripts in the 'hyrax' repo to perform a nightly build

function help {
    echo "Usage: $0 [options]"
    echo "Edit the lines at the end of this script to set up"
    echo "different builds like ones that make the custom NASA"
    echo "rpm files."
    echo "Options are:"
    echo "-h: help; this message"
    echo "-p: install prefix, default is `PWD`/build"
    echo "-v: verbose"
    echo "-n: dry run"
    echo "-r: record the build"
}

args=`getopt hp:vnr $*`
if [ $? != 0 ]
then
    help
    exit 2
fi

set -- $args

# Set verbose and do_nothing to false
verbose="no"
record="no"
dry_run="no"
prefix=""

for i in $*
do
    case "$i"
	in
	-h)
	    help
	    exit 0;;
	-p)
	    prefix="$2"
	    shift; shift;;
        -v)
            verbose="yes"
            shift;;
	-n)
	    dry_run="yes"
	    shift;;
	-r)
	    record="yes"
	    shift;;
        --)
            shift; break;;
    esac
done

# This code duplicates the spath.sh code so this shell will be set correctly

export prefix=${prefix:-$PWD/build}

if echo $PATH | grep $prefix > /dev/null
then
    echo "PATH Already set"
else
    export PATH=$prefix/bin:$PATH
fi

# This is needed for the linux builds; if using the deps libraries
# on linux, those directories also need to be on LD_LIBRARY_PATH.
# I'm not sure this is true... jhrg 1/2/13
# We do need this for icu-3.6 on AWS EC2 instances. jhrg 3/5/13
export LD_LIBRARY_PATH=$prefix/lib:$prefix/deps/lib

# Assume Tomcat 7 or greater and thus no need for CATALINA_HOME to
# be set. jhrg 2/3/15

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
	# if test -n "$verbose"; then echo "$*"; fi
	verbose "$*"
	$*
    fi
}

verbose "Cloning hyrax..."

# -D: Don't clone/pull the hyrax-dependencies repo.
# -v: verbose
do_command ./hyrax_clone.sh -v -D

verbose "Building hyrax..."

# -v: verbose; needed to get the status info in the logs. That
# information is used by hyrax_report.sh.
# -c:clean; only cleans our code; it does not force a rebuild of the
# dependencies if the are built
# -d Run the distcheck target
# -N Build the for-rpm target in the hyrax-depedencies
do_command ./hyrax_build.sh -v -c -d -N

if test "$record" = "yes"
then
    verbose "Recording the build..."
    do_command ./hyrax_report.sh -o centos_6_master -r "`cat login.txt`"
fi
