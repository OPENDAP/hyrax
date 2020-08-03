
import xarray as xa
import sys

# Get the granule names
# from ssmis_granules import f16_ssmis_100
from grfn_granules import grfn_gunw_100

import os
import glob


def clean_cache():
    files = glob.glob('/tmp/hyrax_http/*')

    for f in files:
        try:
            # f.unlink()
            os.unlink(f)
        except OSError as e:
            print("Error: %s : %s" % (f, e.strerror))


base_url = ""
suffix = ""
f = False   # results output file

def ngap_service():
    global base_url
    global suffix
    # This is the base url for the NGAP service which is attached to prod.
    ngap_service_base = 'http://ngap-west.opendap.org/opendap/ngap/providers/GHRC_CLOUD/collections/' \
                        'RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/'
    base_url = ngap_service_base
    suffix = ""
    print("Using NGAP Service")


def s3_bucket():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to objects in an opendap S3 bucket called ngap-ssmis-west
    s3_bucket_base = "http://ngap-west.opendap.org/opendap/asf_grfn/s3/"
    base_url = s3_bucket_base
    suffix=".dmrpp"
    print("Using S3 Bucket: ${base_url}")


def tea():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to the TEA endpoint for PROD. URLs from TEA are cached.
    tea_prod_base = "http://ngap-west.opendap.org/opendap/asf_grfn/tea/"
    base_url = tea_prod_base
    suffix=".dmrpp"
    print("Using TEA: ${base_url}")


def granules():
    global base_url
    global suffix
    # This is the base URL for the collection of source netcdf-4 granule 
    # files.
    granule_files_base = "http://ngap-west.opendap.org/opendap/asf_grfn/granules/"
    base_url = granule_files_base
    suffix=""
    print("Using Granules: ${base_url}")


def get_the_things():
    import webob
    import time

    global base_url
    global suffix
    global f        # results file

    print("base_url: ", base_url)
    print("  suffix: ", suffix)

    # Allows us to visualize the dask progress for parallel operations
    from dask.diagnostics import ProgressBar

    ProgressBar().register()

    # OPeNDAP In the Cloud

    od_files = []

    for g in grfn_gunw_100:
        od_files.append(base_url + g + suffix)

    print("   first: ", od_files[0], '\n', "   last: ", od_files[-1])
    try:
        tic = time.perf_counter()

        cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords')

        cloud_ws = cloud_data['science_grids_data_amplitude'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))

        cloud_ws_mean = cloud_ws.mean(dim=['latitude', 'longitude'])

        print(cloud_ws_mean)

        if f:
            f.write(f"{time.perf_counter() - tic:0.4f},")
            f.write("success\n")

    except webob.exc.HTTPError as err:
        # See https://docs.pylonsproject.org/projects/webob/en/stable/api/exceptions.html#
        print("HTTPError: code: ", err.code, ": ", err.detail);
        print("Error: ", sys.exc_info()[0])
        if f:
            f.write(f"{time.perf_counter() - tic:0.4f},")
            f.write("fail\n")
    except:
        print("Error: ", sys.exc_info()[0])
        if f:
            f.write(f"{time.perf_counter() - tic:0.4f},")
            f.write("fail\n")


def main():
    import getopt

    global f        # results file

    try:
        # see https://docs.python.org/3.1/library/getopt.htm
        optlist, args = getopt.getopt(sys.argv[1:], 'sgntahd:')
    except:
        # print help information and exit:
        print("Options -d <datafile> -s s3, -g granules, -n ngap api, -t tea, -a all of s, g, n and t.")
        sys.exit(2)

    for o, a in optlist:
        if o in ("-h", "--help"):
            print("Options -d <datafile> -s s3, -g granules, -n ngap api, -t tea, -a all of s, g, n and t.")

        if o in ("-d",):
            print("Datafile name: ", a)
            f = open(a, "a")

        if o in ("-s", "-a"):
            print("###########################################")
            if f:
                f.write("s3,")
            s3_bucket()
            clean_cache()
            get_the_things()

        if o in ("-g", "-a"):
            print("###########################################")
            if f:
                f.write("granule,")
            granules()
            clean_cache()
            get_the_things()

        if o in ("-t", "-a"):
            print("###########################################")
            if f:
                f.write("tea,")
            tea()
            clean_cache()
            get_the_things()

        if o in ("-n", "-a"):
            print("###########################################")
            if f:
                f.write("ngap,")
            ngap_service()
            clean_cache()
            get_the_things()

    if f:
        f.close()


if __name__ == "__main__":
    main()
