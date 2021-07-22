
import xarray as xa
import sys

# Get the granule names
from ssmis_granules import f16_ssmis_100
from pydap.client import open_url
from pydap.cas.urs import setup_session
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

# -l switch
def ngap_localhost():
    global base_url
    global suffix
    # This is the base url for the NGAP service which is attached to prod.
    ngap_service_base = 'http://localhost:8080/opendap/ngap/providers/GHRC_CLOUD/collections/' \
                        'RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/'
    base_url = ngap_service_base
    suffix = ""
    print("Using NGAP Service (localhost:8080)")

# -n switch
def ngap_service_west():
    global base_url
    global suffix
    # This is the base url for the NGAP service which is attached to prod.
    ngap_service_base = 'http://ngap-west.opendap.org/opendap/ngap/providers/GHRC_CLOUD/collections/' \
                        'RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/'
    base_url = ngap_service_base
    suffix = ""
    print("Using NGAP Service (us-west-2)")

# -m switch
def ngap_service_uat():
    global base_url
    global suffix
    # This is the base url for the NGAP service which is attached to prod.
    ngap_service_base = 'https://opendap.uat.earthdata.nasa.gov/providers/GHRC_CLOUD/collections/' \
                        'RSS%20SSMIS%20OCEAN%20PRODUCT%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/'
    base_url = ngap_service_base
    suffix = ""
    print("Using NGAP Service (UAT)")

# -s switch
def s3_bucket():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to objects in an opendap S3 bucket called ngap-ssmis-west
    s3_bucket_base = "http://ngap-west.opendap.org/opendap/ssmis/ngap-ssmis-west/"
    base_url = s3_bucket_base
    suffix=".dmrpp"
    print("Using S3 Bucket ngap-ssmis-west")


# -t switch
def tea_prod():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to the TEA endpoint for PROD. URLs from TEA are cached.
    tea_prod_base = "http://ngap-west.opendap.org/opendap/ssmis/tea-prod/"
    base_url = tea_prod_base
    suffix=".dmrpp"
    print("Using TEA in PROD")

# -u switch
def tea_uat():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to the TEA endpoint for PROD. URLs from TEA are cached.
    tea_prod_base = "http://ngap-west.opendap.org/opendap/ssmis/tea-uat/"
    base_url = tea_prod_base
    suffix=".dmrpp"
    print("Using TEA in UAT")

# -p switch
def tea_apigw():
    global base_url
    global suffix

    # This is the base URL for the collection of dmr++ files whose dmrpp:href urls
    # point to the TEA endpoint for PROD. URLs from TEA are cached.
    tea_prod_base = "http://ngap-west.opendap.org/opendap/ssmis/tea-apigw/"
    base_url = tea_prod_base
    suffix=".dmrpp"
    print("Using TEA in API Gateway")

# -g switch
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
    import webob
    import time

    global base_url
    global suffix
    global f        # results file

    print("base_url: ", base_url, sep="")
    print("  suffix: ", suffix, sep="")

    username = os.environ.get('USER')
    password = os.environ.get('PWORD')

    # print("username: ",username,sep="")
    # print("password: ",password,sep="")

    do_auth = True
    if username is not None and password is not None :
        print("Using credentials for '", username, "'", sep="")
    else:
        print("No (complete) authentication credentials available.")
        do_auth = False


    # Allows us to visualize the dask progress for parallel operations
    from dask.diagnostics import ProgressBar

    ProgressBar().register()

    # OPeNDAP In the Cloud

    od_files = []

    for g in f16_ssmis_100:
        od_files.append(base_url + g + suffix)

    print("   first:", od_files[0], '\n', "   last:", od_files[-1])
    try:
        tic = time.perf_counter()

        if do_auth:
            session = setup_session(username, password, check_url=od_files[0])
            session.headers.update({'Accept-Encoding': 'deflate'})
            cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords', backend_kwargs={'session': session})
        else:
            cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords')

        cloud_ws = cloud_data['wind_speed'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))

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

    except UnicodeError as err:
        # See https://docs.pylonsproject.org/projects/webob/en/stable/api/exceptions.html#
        print("UnicodeError - encoding: ", err.encoding, "  reason: ", err.reason, " object: ", type(err.object), " start: ", err.object[err.start]," end: ",err.end);
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


    hr = "---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  "
    run_id="id_not_set "
    global f        # results file

    usage="Options -i <run_id> -d <datafile> -s s3, -g granules, -n ngap api (us-west-2+prod), -m ngap api (UAT), -t tea, -u tea-uat, -p tea-apigw -a all of s, g, n and t."

    try:
        # see https://docs.python.org/3.1/library/getopt.htm
        optlist, args = getopt.getopt(sys.argv[1:], 'mlsgntahupd:i:')
    except:
        # print help information and exit:
        print(usage)
        sys.exit(2)

    for o, a in optlist:

        if o in ("-h", "--help"):
            print(usage)

        if o == "-i":
            run_id=a

        if o == "-d":
            print("Datafile name: ", a)
            f = open(a, "a")

        if o in ("-s", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("s3,")
            s3_bucket()
            clean_cache()
            get_the_things()

        if o in ("-g", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("granule,")
            granules()
            clean_cache()
            get_the_things()

        if o in ("-l", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("ngap_localhost,")
            ngap_localhost()
            clean_cache()
            get_the_things()

        if o in ("-t", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("tea_prod,")
            tea_prod()
            clean_cache()
            get_the_things()

        if o in ("-u", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("tea_uat,")
            tea_uat()
            clean_cache()
            get_the_things()

        if o in ("-p", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("tea_apigw,")
            tea_apigw()
            clean_cache()
            get_the_things()

        if o in ("-n", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("ngap_west,")
            ngap_service_west()
            clean_cache()
            get_the_things()

        if o in ("-m", "-a"):
            print(hr)
            print("Run ID:", run_id)
            if f:
                f.write("ngap_uat,")
            ngap_service_uat()
            clean_cache()
            get_the_things()

    if f:
        f.close()


if __name__ == "__main__":
    main()
