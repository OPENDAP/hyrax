#!/bin/bash
#
# Once a build has been run using hyrax_build.sh, analyze it's log files
# build up a comprehensive report and optionally upload that report to 
# the build database.

function help {
    echo "Usage: $0 [options] where options are:"
    echo "-h: help; this message"
    echo "-v: verbose"
    echo "-n: print what would be done"
    echo "-2: DAP2 only build - look for libdap.log, not libdap4.log"
    echo "-r <login>: record the build on test.opendap.org"
    echo "-o <os_name>: Use 'os_name' for the os name; blank otherwise"
    echo "-a <archive>: Where to store old log files? Default: 'logs/'"
}

args=`getopt hvn2r:o:a: $*`
if test $? != 0
then
    help
    exit 2
fi

set -- $args

# Set verbose and dry_run to false
verbose=""
dry_run="no"

record_build="no"
logs_archive="logs"
libdap="libdap4"

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
	    libdap="libdap"
	    shift;;
	-o)
	    os_name="$2"
	    shift; shift;;
	-r)
	    record_build="yes"
	    USER_PW="$2"
	    shift; shift;;
	-a)
	    logs_archive="$2"
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
	# if test -n "$verbose"; then echo "$*"; fi
	verbose "$*"
	$*
    fi
}

host_full=`hostname`
host="`hostname | sed 's/\([^\.]*\)\..*/\1/'`"

if test -n "$os_name"
then
    host=${host}_${os_name}
fi

date=`date +%Y.%m.%d`
platform=`${libdap}/conf/config.guess`

    # dap-server fileout_netcdf freeform_handler \
    # hdf4_handler hdf5_handler ncml_module netcdf_handler gateway_module \
    # csv_handler fits_handler xml_data_handler gdal_handler fileout_gdal \
    # ugrid_functions

for build_name in $libdap bes olfs
do
    verbose "Processing log for $build_name"

    # The word 'all' in the following name is kept because the scripts
    # that process these files are old - 2005 vintage - and used to support
    # logs for different targets. I want the scripts to continue to work
    # on the old logs. jhrg 12/31/14 
    make_log=${host}.${platform}.${build_name}.all.${date}

    echo "Build of ${build_name} on `date`" > $make_log
    echo "Built on ${host_full}, ${platform} (`uname -a`)" >> $make_log

    cat $build_name.log >> $make_log

    echo "_______________________________________________________" >> $make_log
    echo "Build completed at `date`." >> $make_log 2>&1

    # For all these status codes, 0 indicates success, 1 failure and N/A
    # means not applicable.

    build_status=`grep '^%%% make status: [0-9]*' $make_log | sed 's@.*: \([0-9]*\).*@\1@'`
    install_status=`grep '^%%% install status: [0-9]*' $make_log | sed 's@.*: \([0-9]*\).*@\1@'`
    check_status=`grep '^%%% check status: [0-9]*' $make_log | sed 's@.*: \([0-9]*\).*@\1@'`

    distcheck_status=`grep '^%%% distcheck status: [0-9]*' $make_log | sed 's@.*: \([0-9]*\).*@\1@'`
    rpm_status=`grep '^%%% rpm status: [0-9]*' $make_log | sed 's@.*: \([0-9]*\).*@\1@'`
    pkg_status=`grep '^%%% pkg status: [0-9]*' $make_log | sed 's@.*: \([0-9]*\).*@\1@'`

    # here we just do minimal sanity checking; if the above code found a 
    # value, it's assumed to be correct but if it's zero-length, something
    # went wrong with a required target
    if test -z "$build_status"; then build_status=1; fi
    if test -z "$check_status"; then check_status=1; fi
    if test -z "$install_status"; then install_status=1; fi

    # I made this N/A if it's zero length because the olfs-check
    # target is not going to set it. N/A won't make the NB summary
    # line red. That is, these are optional targets so if they have
    # no status recorded we assume they were not run.
    if test -z "$distcheck_status"; then distcheck_status="N/A"; fi
    if test -z "$rpm_status"; then rpm_status="N/A"; fi
    if test -z "$pkg_status"; then pkg_status="N/A"; fi

    results="compile: $build_status, check: $check_status, install: $install_status, distcheck: $distcheck_status, rpm: $rpm_status, pkg: $pkg_status"

    verbose "Results: $results"
    echo "Results: $results" >> $make_log 2>&1

    # now record the build on the test machine...
    if test "$record_build" = "yes"
    then
	verbose "Recording the build"
	do_command "curl --digest --user $USER_PW" "http://test.opendap.org/cgi-bin/build_recorder.pl?host=${host}&build=${build_name}&platform=${platform}&date=${date}&compile=${build_status}&check=${check_status}&install=${install_status}&distcheck=${distcheck_status}&rpm=${rpm_status}&pkg=${pkg_status}" 

        verbose "Upload the log file"
        do_command curl --digest --user $USER_PW -F name=${make_log} -F uploaded_file=@${make_log} http://test.opendap.org/cgi-bin/build_log_copy.pl 

    fi

    # keep some log file copies on the local host too...

    verbose "Updating log archive ($logs_archive)"

    if test ! -d $logs_archive
    then
	do_command mkdir $logs_archive
    fi

    very_old=`find $logs_archive -ctime +10 2> /dev/null`
    if test -n "$very_old"
    then
	do_command rm -f $very_old
    fi

    do_command mv $make_log $logs_archive 2> /dev/null

done
