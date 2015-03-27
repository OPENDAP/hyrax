#!/bin/sh
#
# Build rpms for Hyrax given a fresh checkout from git.
# This is fairly rough... Leaves the build host without 
# any installed rpms, however.

function help {
    echo "Usage: $0 [options] where options are:"
    echo "-h: help; this message"
    echo "-v: verbose"
    echo "-n: print what would be done"
    echo "-d dir: look in <dir> for the built RPMs; used by yum to install/test"
    echo "-r: run the rpm targets"
    echo "-R: Build the special nasa rpm - includes hdfeos2 and hdf4 via a static linking"
    echo "-p prefix: use <prefix> as the build/install prefix"
}

args=`getopt hvnrdRp: $*`
if test $? != 0
then
    help
    exit 2
fi

set -- $args

# Set verbose and dry_run to false

# Not sure about this way of handling prefix... Should we make it
# easier to build and install to /usr/local? 
prefix=${prefix:-$PWD/build}
vernose=""
dry_run="no"
rpm=""
nasa_rpm=""
RPM_DIR=""

for i in $*
do
    case "$i"
	in
	-h)
	    help
	    exit 0;;
        -v)
            verbose="--verbose"
            shift;;
        -n)
            dry_run="yes"
            shift;;
	-r)
	    rpm="yes"
	    shift;;
	-R)
	    nasa_rpm="yes"
	    shift;;
	-d)
	    RPM_DIR=$2
	    shift; shift;;
	-p)
	    prefix=$2
	    shift; shift;;
        --)
            shift; break;;
    esac
done

RPM_DIR="${RPM_DIR:-~/rpmbuild/RPMS/x86_64}"

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

# N args "do_make_rpm <dir/thing> <make options>"
function do_make {
    verbose "Building in $1"

    # in a sub-shell
    (
    if cd $1
    then
	shift
	do_command "make $*"
    else
	echo "Could not change to directgory $1"
    fi
    )
}


# Build the libdap RPMs
verbose "Building libdap RPMs..."

do_make "libdap4" -j9 rpm

verbose "Install the libdap RPMs sp we can build the BES ones..."

do_command "sudo yum --assumeyes install $RPM_DIR/{libdap*.rpm,libdap-devel*.rpm}"

verbose "Building bes RPMs..."

if test -n "$nasa_rpm"
then
    do_make "bes" -j9 nasarpm
else
    do_make "bes" -j rpm
fi

verbose "Testing the bes RPM install..."

# bes-devel-3.13.2-1.NASA.amzn1.x86_64.rpm
if test -n "$nasa_rpm"; then NASA=".NASA"; fi
do_command "sudo yum --assumeyes install $RPM_DIR/{bes-*$NASA.amzn1.x86_64.rpm}"

do_command "which besctl"
do_command "sudo besctl start"
do_command "bescmdln -x 'show version;'"

verbose "Cleaning up (removing installed RPMs)..."

do_command "sudo yum --assumeyes remove bes bes-devel libdap libdap-devel"

