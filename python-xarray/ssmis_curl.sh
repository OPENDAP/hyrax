#!/bin/bash

granules_file="ssmis_granules.py"
dap_suffix=".ascii"
constraint="wind_speed%5B0%5D%5B143:1:304%5D%5B559:1:680%5D"
data_file="ssmis_curl.result.csv"


function run_curl(){
    cf_name=$1
    time -p curl -s -n -L -c ${cf_name} -b ${cf_name} ${dap_url}${dap_suffix}?${constraint} >> ${data_file}
}

function use_tea_uat {
    export server_url="http://ngap-west.opendap.org/opendap/ssmis/tea-uat"
    export granule_suffix=".dmrpp"
    echo "Using TEA in UAT"
}

function use_ngap_west {
    export server_url="http://ngap-west.opendap.org/opendap/ngap/providers/GHRC_CLOUD/collections/RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/"
    export granule_suffix=""
    echo "Using NGAP Service (us-west-2)"
}

function use_ngap_uat {
    export server_url="http://opendap.uat.earthdata.nasa.gov/providers/GHRC_CLOUD/collections/RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/"
    export granule_suffix=""
    echo "Using NGAP in UAT"
}



function run_ssmis() {
    mark=${1};

    use_ngap_uat
    cookie_file="${data_file}-cf-${mark}"

    echo "${mark} -- --  -- -- SSMIS wind_speed subset BEGIN"
    granules=`cat ${granules_file} | awk '{if(NR<91){n=split($0,s,"\"");if(NF==2){print s[3];}else{print s[2];}}}'`
    echo "${mark} Found "`echo "${granules}" | wc -l`" granules."
    count=0;
    for granule in ${granules}; do
        let "count++"
        log_mark="(${mark}-${count})"
        echo -n "."

        # echo "granule[${count}]: ${granule}"
        echo "${log_mark}-${granule}" >> ${data_file}.time # granule name in data file
        dap_url=${server_url}/${granule}${granule_suffix}
        run_curl "${cookie_file}" 2>> ${data_file}.time # time to execute in data file
        status=$?
        echo "status ${status}" >> ${data_file}.time # cURL status in data file
    done
    echo "${mark} -- --  -- -- SSMIS wind_speed subset END"
}

function curl_run1000() {

    rm -f ${data_file} ${data_file}.time ${data_file}-cf-*

    for i in {1..500}; do
        echo "----- LAP: $i Started: "`date`"  uTime: "`date "+%s"`
        for process in {1..8}; do
            run_ssmis "${i}-${process}" & 2>&1
        done
        wait;
    done
}



