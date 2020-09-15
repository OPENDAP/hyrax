#!/bin/bash

granules_file="ssmis_granules.py"
dap_suffix=".ascii"
constraint="wind_speed%5B143:1:304%5D%5B559:1:680%5D"
data_file="ssmis_result.csv"


function run_curl(){
    time -p curl -s -L -c cookie -b cookie ${dap_url}${dap_suffix}?${constraint} >> ${data_file}  >> ${data_file}
}


function run_ssmis() {
    server_url="http://ngap-west.opendap.org/opendap/ssmis/tea-uat"
    granule_suffix=".dmrpp"

    echo "# -- --  -- -- SSMIS wind_speed subset BEGIN"
    granules=`cat ${granules_file} | awk '{if(NR<91){n=split($0,s,"\"");if(NF==2){print s[3];}else{print s[2];}}}'`
    echo "Found "`echo "${granules}" | wc -l`" granules."
    count=0;
    for granule in ${granules}; do
        let "count++"
        echo "granule[${count}]: ${granule}"
        echo "${granule}" >> ${data_file}.time # granule name in data file
        dap_url=${server_url}/${granule}${granule_suffix}
        run_curl 2> ${data_file}.time # time to execute in data file
        status=$?
        echo "status ${status}" >> ${data_file}.time # cURL status in data file
    done
    echo "# -- --  -- -- SSMIS wind_speed subset END"
}

function curl_run1000) {

    rm -f ${data_file}

    for i in {1..1000}; do
        echo "----- LAP: $i Started: "`date`"  ut: "`date "+%s"`
        run_ssmis
    done

}
