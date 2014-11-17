#!/bin/sh
#
# Clone all of Hyrax from the OpenDAP organization page on GitHub
# This is fairly rough...

# Options: v: verbose; n: do nothing but print what would have been done

args=`getopt vn $*`
if [ $? != 0 ]
then
    echo "Usage: $0 [options] where options are:"
    echo "-v: verbose"
    echo "-n: print what would be done"
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
        -v)
            verbose="--verbose";
            shift;;
        -n)
            dry_run="yes";
            shift;;
        --)
            shift; break;;
    esac
done

function do_command {
    if test "$dry_run" = "yes"
    then
	echo "$1"
    else
	$1
    fi
}

repo_root=https://github.com/opendap

# These modules do not require dependencies from EPEL or elsewhere on 
# a supported OS
modules="csv_handler dap-server fileout_json freeform_handler gateway_module \
wcs_gateway_module xml_data_handler"

# These modules do require code that is not normally on OSX and CentOS
# NB: ncml_module uses ICU which is a problem on OSX; we treat it as a
# third-party dependency.
modules_epel="fileout_gdal fileout_netcdf fits_handler gdal_handler \
hdf4_handler hdf5_handler netcdf_handler ugrid_functions ncml_module"

# These modules are not currently delivered as part of Hyrax
# cdf_handler cedar_handler matlab_handler sql_handler wcs_gateway_module 

do_command "git clone $repo_root/libdap.git $verbose"

do_command "git clone $repo_root/bes.git $verbose"

do_command "git clone $repo_root/olfs.git $verbose"

mkdir -p modules

# in a sub-shell
(
if cd modules
then
    if test -n "$verbose"
    then
	echo "In modules subdir"
    fi

    for m in $modules
    do
	do_command "git clone $repo_root/$m.git $verbose"
    done

    for m in $modules_epel
    do
	do_command "git clone $repo_root/$m.git $verbose"
    done
fi
) # pop out of the 'cd modules' sub-shell
