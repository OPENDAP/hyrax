#!/bin/bash

# SERVICE="https://ghrc.nsstc.nasa.gov/opendap"
SERVICE="https://ghrcdrive.nsstc.nasa.gov/pub"
SERVICE="http://balto.opendap.org/opendap"
SERVICE="http://balto.opendap.org/opendap/ssmis/dmrpp_s3"

FILES_TO_GET=$(
    cat <<EOF
${SERVICE}/f17_ssmis_20190101v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190102v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190103v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190104v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190105v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190106v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190107v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190108v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190109v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190110v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190111v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190112v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190113v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190114v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190115v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190116v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190117v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190118v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190119v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190120v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190121v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190122v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190123v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190124v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190125v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190126v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190127v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190128v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190129v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190130v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190131v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190201v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190202v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190203v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190204v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190205v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190206v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190207v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190208v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190209v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190210v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190211v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190212v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190213v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190214v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190215v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190216v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190217v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190218v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190219v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190220v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190221v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190222v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190223v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190224v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190225v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190226v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190227v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190228v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190301v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190302v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190303v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190304v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190305v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190306v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190308v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190309v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190310v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190311v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190312v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190313v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190314v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190315v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190316v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190317v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190318v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190319v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190320v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190321v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190322v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190323v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190324v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190325v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190326v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190327v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190328v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190329v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190330v7.nc.dmrpp
${SERVICE}/f17_ssmis_20190331v7.nc.dmrpp
EOF
)


for access in ${FILES_TO_GET}
do
    echo "\"${access}\",";
    # name=`basename ${access}`;
    # echo "name: ${name}";
    # curl -n --netrc-file ~/.netrc -c cookies -b cookies -L "${access}" > "${name}"
done

     
 
 
 
 
 
 