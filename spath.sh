#!/bin/sh
#
# Source this in the directory to be 'prefix' or pass the directory
# as the first param. Make this a command using 'alias.' e.g.
# alias spath='source ~/bin/spath.sh'

# Set 'prefix' to either the first argument or the current working directory.
# Can't use ${1:-...}; positional params don't work in the ${:-} syntax
prefix=$1
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
export LD_LIBRARY_PATH=$prefix/lib:$prefix/deps/lib

export TESTSUITEFLAGS=--jobs=9


tc=`ls -d -1 $prefix/apache-tomcat-* 2> /dev/null | grep -v '.*\.tar\.gz'`
if test -n "$tc"
then
    export TOMCAT_DIR=$tc
    export CATALINA_HOME=$TOMCAT_DIR
fi

