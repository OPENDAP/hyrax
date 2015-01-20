#!/bin/bash
#
# Use the scripts in the 'hyrax' repo to perform a nightly build

# This is normally run by root, which will likely not have /usr/local
# bin in its path.
PATH=/usr/local/bin:$PATH

source spath.sh

./hyrax_clone.sh -v -D

# Using -v (verbose) is needed to get the status info in the logs.
# That information is used by hyrax_report.sh. The -c (clean) option
# only cleans our code; it does not force a rebuild of the
# dependencies if the are built (NB: -D suppresses getting our copy 
# of the deps from github.

./hyrax_build.sh -v -c

./hyrax_report.sh -o centos_6 -r "`cat login.txt`"
