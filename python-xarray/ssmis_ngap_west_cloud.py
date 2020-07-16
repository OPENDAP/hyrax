
import xarray as xa
import sys

# Get the granule names
from ssmis_granules import f16_ssmis_100

base_url=""
suffix=""

def ngap_service():
    global base_url
    global suffix
    # This is the base url for the NGAP service which is attached to prod.
    ngap_service_base = 'http://ngap-west.opendap.org/opendap/ngap/providers/GHRC_CLOUD/collections/RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/'
    base_url = ngap_service_base
    suffix=""
    print("Using NGAP Service")

def s3_bucket():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to objects in an opendap S3 bucket called ngap-ssmis-west
    s3_bucket_base = "http://ngap-west.opendap.org/opendap/ssmis/ngap-ssmis-west/"
    base_url = s3_bucket_base
    suffix=".dmrpp"
    print("Using S3 Bucket ngap-ssmis-west")

def tea():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to the TEA endpoint for PROD. THis is Not the NGAP service and will
    # not cache the signed S3 request URLs returned by TEA.
    tea_prod_base = "http://ngap-west.opendap.org/opendap/ssmis/ngap-prod/"
    base_url = tea_prod_base
    suffix=".dmrpp"
    print("Using TEA")


def granules():
    global base_url
    global suffix
    # This is the base URL for the collection of source netcdf-4 granule 
    # files.
    granule_files_base = "http://ngap-west.opendap.org/opendap/ssmis/granules/"
    base_url = granule_files_base
    suffix=""
    print("Using Granules")


def get_the_things():
    global base_url
    global suffix

    print("base_url: ",base_url)
    print("  suffix: ",suffix)

    # Allows us to visualize the dask progress for parallel operations
    from dask.diagnostics import ProgressBar

    ProgressBar().register()

    # OPeNDAP In the Cloud

    od_files = []

    for g in f16_ssmis_100:
        od_files.append(base_url + g + suffix)

    print("   first: ",od_files[0], '\n', "   last: ",od_files[-1])
    try:
        cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords')

        cloud_ws = cloud_data['wind_speed'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))

        cloud_ws_mean = cloud_ws.mean(dim=['latitude', 'longitude'])

        print(cloud_ws_mean)

    except:
        print("Error:", sys.exc_info()[0])

print("###########################################")
s3_bucket()
get_the_things()

print("###########################################")
granules()
get_the_things()

print("###########################################")
ngap_service()
get_the_things()

print("###########################################")
tea()
get_the_things()


