#!/bin/bash

granules_file="ssmis_granules.py"
dap_suffix=".ascii"
req_var="wind_speed"
array_subset="%5B0%5D%5B143:1:304%5D%5B559:1:680%5D"
constraint="${req_var}${array_subset}"
result_file_base="ssmis_curl_result"


function run_curl(){
    out_file_base="${1}"
    cf_name="${2}"
    time -p curl -s -n -L -c ${cf_name} -b ${cf_name} ${dap_url}${dap_suffix}?${constraint} | grep -v "${req_var}" >> "${out_file_base}${dap_suffix}"
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

function use_localhost {
    export server_url="http://localhost:8080/ngap/providers/GHRC_CLOUD/collections/RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/"
    export granule_suffix=""
    echo "Using NGAP in UAT"
}



function run_ssmis() {
    lap=${1};
    pid=${2};
    mark="${lap}-${pid}";

    use_ngap_uat
    cookie_file="${result_file_base}-${pid}.cf"
    rm -f "${cookie_file}"

    log_file="${result_file_base}-${pid}"

    echo "${mark} -- --  -- -- SSMIS wind_speed subset BEGIN"
    granules=`cat ${granules_file} | awk '{if(NR<91){n=split($0,s,"\"");if(NF==2){print s[3];}else{print s[2];}}}'`
    echo "${mark} Found "`echo "${granules}" | wc -l`" granules."
    count=0;
    for granule in ${granules}; do
        let "count++"
        log_mark="(${mark}-${count})"
        echo -n "."

        # echo "granule[${count}]: ${granule}"
        echo "${log_mark}-${granule}" >> ${log_file}.time # granule name in time file
        dap_url=${server_url}/${granule}${granule_suffix}
        run_curl "${log_file}" "${cookie_file}" "${pid}" 2>> ${log_file}.time # time output in time file
        status=$?
        echo "status ${status}" >> ${log_file}.time # cURL status in time file
    done
    echo "${mark} -- --  -- -- SSMIS wind_speed subset END"
}

function curl_run1000() {

    rm -f ${result_file_base}*

    for i in {1..1000}; do
        echo "----- LAP: $i Started: "`date`"  uTime: "`date "+%s"`
        for process in {0..7}; do
            run_ssmis "${i}" "${process}" & 2>&1
        done
        wait;
    done
}



