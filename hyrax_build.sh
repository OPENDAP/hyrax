#!/bin/sh
#
# Build all of Hyrax given a fresh checkout from git.
# This is fairly rough...

function help {
    echo "Usage: $0 [options] where options are:"
    echo "-h: help; this message"
    echo "-v: verbose"
    echo "-n: print what would be done"
    echo "-2: DAP2 build"
    echo "-c: run make clean before the builds"
    echo "-d: run the distcheck targets for the C++ code"
    echo "-N: If the dependencies are present, build the <for-rpm> target (use with -N)"
    echo "-p prefix: use <prefix> as the build/install prefix"
}

args=`getopt hvn2cdNp: $*`
if test $? != 0
then
    help
    exit 2
fi

set -- $args

# Set verbose and dry_run to false

# Not sure about this way of handling prefix... Should we make it
# easier to build and install to /usr/local? 
export prefix=${prefix:-$PWD/build}

if echo $PATH | grep $prefix > /dev/null
then
    echo "PATH Already set"
else
    export PATH=$prefix/bin:$prefix/deps/bin:$PATH
fi

# This is needed for the linux builds; if using the deps libraries
# on linux, those directories also need to be on LD_LIBRARY_PATH.
# I'm not sure this is true... jhrg 1/2/13
# We do need this for icu-3.6 on AWS EC2 instances. jhrg 3/5/13
if echo $LD_LIBRARY_PATH | grep $prefix/lib:$prefix/deps/lib > /dev/null
then
    echo "LD_LIBRARY_PATH already set"
else
    export LD_LIBRARY_PATH=$prefix/lib:$prefix/deps/lib:$LD_LIBRARY_PATH
fi

verbose=""
dry_run="no"
dap2="no"
clean=""
distcheck=""
for_nasa_rpm=""

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
	-2)
	    dap2="yes"
	    shift;;
	-c)
	    clean="yes"
	    shift;;
	-d)
	    distcheck="yes"
	    shift;;
	-N)
	    for_nasa_rpm="for-rpm CONFIGURE_FLAGS=--disable-shared"
	    shift;;
	-p)
	    prefix=$2
	    shift; shift;;
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

# Two args "do_make_build <thing> <configure options>"
function do_make_build {
    verbose "Building in $1"

    # in a sub-shell
    (
    if cd $1
    then
	# shift first arg off so $* holds the remaining args
	shift

	if test ! -x configure
	then
	    do_command "autoreconf --force --install $verbose"
	fi
	if test ! -x configure -a -z "$dry_run"
	then
	    echo "Could not find or build configure script"
	    exit 1
	fi

	do_command "./configure $*"
	verbose "%%% configure status: $?"

	if test -n "$clean"
	then
	    do_command "make clean"
	fi

	do_command "make -j9"
	verbose "%%% make status: $?"

	# some of the bes/handler tests fail w/parallel builds
	do_command "make check -k"
	verbose "%%% check status: $?"

	do_command "make install"
	verbose "%%% install status: $?"

	if test -n "$distcheck"
	then
	    do_command "make distcheck -j9"
	    verbose "%%% distcheck status: $?"
	fi
    fi
    )
}

# Two args "do_build <thing> <configure options>"
function do_ant_build {
    verbose "Building in $1"

    # in a sub-shell
    (
    if cd $1
    then
	# shift first arg off so $* holds the remaining args
	shift
	if test ! -f build.xml
	then
	    echo "Could not find build.xml script"
	    exit 1
	fi

	do_command "ant server $*"
	verbose "%%% make status: $? (ant server $*)"

	if test -d $tomcat_webapps
	then
	    do_command "cp build/dist/opendap.war $tomcat_webapps"
	    verbose "%%% install status: $?"
	else
	    echo "Could not find $tomcat_webapps"
	    verbose "%%% install status: 2"
	fi

	do_command "ant check $*"
	verbose "%%% check status: $? (ant check $*)"
    fi
    )
}

# Put the hyrax deps build here?
if test -d hyrax-dependencies
then
    (
    verbose "Building the local dependencies"

    cd hyrax-dependencies
    # $for_nasa_rpm will contain the magic needed to make just the stuff
    # we need for the BES rpm for NASA (with static HDF4/hdfeos2, ...)
    do_command "make -j9 $for_nasa_rpm"

    # figure out the apache tomcat dir name based on the rev of tomcat's 
    # tar file in the 'extra_downloads' dir and replace if needed. This 
    # tests if the versions are not the same, not if one is newer than the
    # other.
    deps_tomcat_ver=`ls -1 extra_downloads/apache-tomcat-7.*.*.tar.gz | sed 's@.*\([0-9]\.[0-9]*\.[0-9]*\)\.tar.gz@\1@'`
    if test ! -d $prefix/apache-tomcat-$deps_tomcat_ver
    then
	verbose "Replacing tomcat with version $dep_tomcat_ver"
	# remove previous tomcat; add the new one
	rm $prefix/apache-tomcat-*
	do_command "tar -xzf extra_downloads/apache-tomcat-7.*.*.tar.gz -C $prefix"
    fi
    )

    # deps is used later with the BES build. If hyrax-dependencies is not
    # here, then assume the third-party packages are otherwise available.
    deps="--with-dependencies=$prefix/deps"
fi

prefix_arg=--prefix=$prefix

if test "$dap2" == "yes"
then
    libdap="libdap"
else
    libdap="libdap4"
fi

do_make_build $libdap $prefix_arg --enable-developer 2>&1 | tee $libdap.log

do_make_build bes $prefix_arg $deps --enable-developer 2>&1 | tee bes.log

tomcat_webapps=$prefix/apache-tomcat-7.*.*/webapps

do_ant_build olfs 2>&1 | tee olfs.log

