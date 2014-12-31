#!/bin/sh
#
# Clone all of Hyrax from the OpenDAP organization page on GitHub
# This is fairly rough...

function help {
    echo "Usage: $0 [options] where options are:"
    echo "-h: help; this message"
    echo "-v: verbose"
    echo "-n: print what would be done"
    echo "-D: Do not get the hyrax-dependencies repo"
}

args=`getopt hvnD $*`
if [ $? != 0 ]
then
    help
    exit 2
fi

set -- $args

# Set verbose and do_nothing to false
vernose="";
dry_run="no"
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
	# if test -n "$verbose"; then echo "$*"; fi
	verbose "$*"
	$*
    fi
}

repo_root=https://github.com/opendap

# A kludge; assume that if ncdump is _not_ found, then we should
# build the dependencies from our own collection of tar balls.
# 
# Disabled for now, but use 'if ! which ncdump > /dev/null 2>&1 && ...
#
# jhrg 12/29/14

if test ! -d hyrax-dependencies
then 
    do_command "git clone $repo_root/hyrax-dependencies.git $verbose"
else
    (
    cd hyrax-dependencies
    verbose "In hyrax-dependencies..."
    do_command "git pull $verbose"
    )
fi

if test ! -d libdap
then 
    do_command "git clone $repo_root/libdap.git $verbose"
else
    (
    cd libdap
    verbose "In libdap..."
    do_command "git pull $verbose"
    )
fi

if test ! -d bes
then
    do_command "git clone $repo_root/bes.git $verbose"
else
    (
    cd bes
    verbose "In bes..."
    do_command "git pull $verbose"
    )
fi

if test ! -d olfs
then
    do_command "git clone $repo_root/olfs.git $verbose"
else
    (
    cd olfs
    verbose "In olfs..."
    do_command "git pull $verbose"
    )
fi

# Do the submodule init/update in a sub-shell
(
if cd bes 2> /dev/null
then
    verbose "In bes repo..."

    if test ! -f configure.ac
    then
	do_command "ln -s configure_modules.ac configure.ac"
    fi

    # Kludge: Use csv_handler as a sentinel; if it's code is present
    # assume this all has been run and just run 'pull' for all of the
    # submodules.
    if test ! -f modules/csv_handler/configure.ac
    then
	do_command "git submodule init"
	do_command "git submodule update"
	do_command "git submodule foreach" 'git checkout master'
    else
	do_command "git submodule foreach" 'git pull' $verbose
    fi
else
    verbose "No bes repo; cannot update submodules"
fi
) # pop out of the 'cd bes' sub-shell
