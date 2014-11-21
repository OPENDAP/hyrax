#!/bin/sh
#
# Build all of Hyrax given a fresh checkout from git.
# This is fairly rough...

# Options: v: verbose; n: do nothing but print what would have been done

args=`getopt vnp: $*`
if test $? != 0
then
    echo "Usage: $0 [options] where options are:"
    echo "-v: verbose"
    echo "-n: print what would be done"
    exit 2
fi

set -- $args

# Set verbose and dry_run to false
prefix=${prefix:-$PWD}
vernose="";
dry_run="no"
for i in $*
do
    case "$i"
	in
        -v)
            verbose="--verbose";
            shift;;
        -n)
            dry_run="yes";
            shift;;
	-p)
	    prefix=$2;
	    shift; shift;;
        --)
            shift; break;;
    esac
done

function do_command {
    if test "$dry_run" = "yes"
    then
	echo "$*"
    else
	if test -n "$verbose"
	then
	    echo "$*"
	fi
	$*
    fi
}

# Two args "do_make_build <thing> <configure options>"
function do_make_build {
    if test -n "$verbose"
    then
	echo "Building in $1"
    fi

    # in a sub-shell
    (
    if cd $1
    then
	# shift first arg off so $* holds the rmaining args
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

	do_command "make -j9"
	do_command "make install"
    fi
    )
}

# Two args "do_build <thing> <configure options>"
function do_ant_build {
    if test -n "$verbose"
    then
	echo "Building in $1"
    fi

    # in a sub-shell
    (
    if cd $1
    then
	# shift first arg off so $* holds the rmaining args
	shift
	if test ! -f build.xml
	then
	    echo "Could not find build.xml script"
	    exit 1
	fi

	do_command "ant server $*"

	if test -d $tomcat_webapps
	then
	    do_command "cp build/dist/opendap.war $tomcat_webapps"
	else
	    echo "Could not find $tomcat_webapps"
	fi
    fi
    )
}

prefix_arg=--prefix=$prefix

do_make_build libdap $prefix_arg --enable-developer

do_make_build bes $prefix_arg --enable-developer

tomcat_webapps=$prefix/apache-tomcat-7.0.29/webapps
do_ant_build olfs

modules="csv_handler dap-server fileout_json freeform_handler gateway_module \
ncml_module wcs_gateway_module xml_data_handler"

icu_arg=--with-icu-prefix=$prefix/deps

# in a sub-shell
(
if cd modules
then
    for m in $modules
    do
	do_make_build $m $prefix_arg --disable-option-checking $icu_arg
    done
fi
) # 'cd modules sub-shell

# These modules do require code that is not normally on OSX or CentOS
modules_epel="fileout_gdal fileout_netcdf fits_handler \
gdal_handler hdf4_handler hdf5_handler netcdf_handler ugrid_functions"

netcdf_arg=--with-netcdf=$prefix/deps
hdf4_arg=--with-hdf4=$prefix/deps
hdf5_arg=--with-hdf5=$prefix/deps
fits_arg=--with-cfits=$prefix/deps
gdal_arg=--with-gdal=$prefix/deps
ugrid_arg=--with-gridfields=$prefix/deps

# in a sub-shell
(
if cd modules
then
    for m in $modules_epel
    do
	do_make_build $m $prefix_arg $ugrid_arg $gdal_arg $fits_arg $icu_arg $hdf5_arg $hdf4_arg $netcdf_arg
    done
fi
) # 'cd modules sub-shell

