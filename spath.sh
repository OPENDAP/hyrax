#!/bin/bash
#
# Source this in the directory to be 'prefix' or pass the directory
# as the first param. Make this a command using 'alias.' e.g.
# alias spath='source ~/bin/spath.sh'

verbose=1

# Set 'prefix' to either the first argument or the current working directory.
# Can't use ${1:-...}; positional params don't work in the ${:-} syntax
prefix=$1
export prefix=${prefix:-$PWD/build}
test $verbose && echo "prefix: $prefix"

# undo this for a production build
export GZIP_ENV=--fast

if echo $PATH | grep $prefix > /dev/null
then
    test $verbose && echo "PATH: already set"
else
    export PATH=$prefix/bin:$prefix/deps/bin:$PATH
    test $verbose && echo "PATH: $PATH"
fi

# set the site config file, saving some typing and maybe some grief
# export CONFIG_SITE=$(pwd)/config.site

# This is needed for the linux builds; if using the deps libraries
# on linux, those directories also need to be on LD_LIBRARY_PATH.
# I'm not sure this is true... jhrg 1/2/13
# We do need this for icu-3.6 on AWS EC2 instances. jhrg 3/5/13

if ! echo $LD_LIBRARY_PATH | grep -q deps/lib
then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$prefix/deps/lib"
    test $verbose && echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
else
    test $verbose && echo "LD_LIBRARY_PATH: already set"
fi

if test -f /etc/redhat-release && grep -q '8\.' /etc/redhat-release
then
    echo "Found RHEL 8 or equivalent OS"

    test -d /usr/include/tirpc || echo "WARNING: tirpc header dir not at /usr/include/tirpc"
    
    if ! echo $CPPFLAGS | grep -q /usr/include/tirpc
    then
        export CPPFLAGS="$CPPFLAGS -I/usr/include/tirpc"
        test $verbose && echo "CPPFLAGS: $CPPFLAGS"
    else
        test $verbose && echo "CPPFLAGS: already set"
    fi

    if ! echo $LDFLAGS | grep -q tirpc
    then
        export LDFLAGS="$LDFLAGS -ltirpc"
        test $verbose && echo "LDFLAGS: $LDFLAGS"
    else
        test $verbose && echo "LDFLAGS: already set"
    fi
fi

export TESTSUITEFLAGS=--jobs=9

# I removed the apache tomcat dist from dependencies/downloads 
# because it was causing bloat. Assume that a typical nightly build
# has both the tar.gz and directory for tomcat. jhrg 4/28/14
#
# Added it back. The new tomcat 7 scripts don't require that 
# CATALINA_HOME is set, so this is really for TC 6 compat. jhrg 12/30/14
tc=`ls -d -1 $prefix/apache-tomcat-* 2> /dev/null | grep -v '.*\.tar\.gz' >2 /dev/null`
if test -n "$tc"
then
    export TOMCAT_DIR=$tc
    export CATALINA_HOME=$TOMCAT_DIR
fi
