
"""
Test access to OPeNDAP within NGAP. This is part of getting
OPeNDAP access functioning for 'analysis in place' within the
NGAP environment.

jhrg 1/24/22
"""

import sys
import os
import glob
import webob
import time     # function run-times
import getopt   # for main()
import getpass  # for get_credentials()

import xarray as xa

from pydap.client import open_url
from pydap.cas.urs import setup_session

show_timing = False    # True shows the run-time for some functions


def get_credentials():
    """
    Read a username and password either from the environment variables USER and URS_PWORD
    or from the terminal.
    :return: A tuple (user, password)
    """
    username = os.environ.get('USER')
    password = os.environ.get('URS_PWORD')
    # Most machines do set USER, but URS_PWORD is suitably obscure
    if username is None or password is None:
        username = input("URS Username: ")
        password = getpass.getpass("URS Password: ")

    return username, password


def build_session(credentials, url):
    """
    Build a pydap.cmr.session object using the credentials and the URL. As a bonus,
    the session lets the OPeNDAP server know that this client can accept compressed
    responses. NB: This is HTTP-level response compression and not the HDF5/NetCDF4
    per-variable compression.
    :param credentials: A tuple of the username and password to use for the session.
    credentials[0] == the username, credentials[1] == the password.
    :param url: The URL tied to the session
    :return: The session object or None
    """
    session = setup_session(credentials[0], credentials[1], check_url=url)
    session.headers.update({'Accept-Encoding': 'deflate'})
    return session


def open_dataset(url, session):
    """
    Given a URL to a dataset in NGAP, open it using xarray. This function uses PyDAP to
    open the remote dataset via OPeNDAP.
    :param url: The URL - any opendap URL should work.
    :param session: A pydap.cmr.session object for the URL.
    :return: An xarray.Dataset that references the open dataset.
    """
    try:
        if show_timing:
            tic = time.perf_counter()

        # open_mfdataset() == open multi-file dataset.
        # both open_datasets and ...mfdataset use netcdf4 as the default engine and that
        # should be able to open DAP URLS. jhrg 1/24/22
        if session is not None:
            xa_ds = xa.open_dataset(url, engine='pydap', backend_kwargs={'session': session})
        else:
            xa_ds = xa.open_mfdataset(url, engine='pydap')

        return xa_ds

    except webob.exc.HTTPError as err:
        # See https://docs.pylonsproject.org/projects/webob/en/stable/api/exceptions.html#
        print("HTTPError: code: ", err.code, ": ", err.detail);
        print("Error: ", sys.exc_info()[0])

    except UnicodeError as err:
        # See https://docs.pylonsproject.org/projects/webob/en/stable/api/exceptions.html#
        print("UnicodeError - encoding: ", err.encoding, "  reason: ", err.reason, " object: ", type(err.object), " start: ", err.object[err.start]," end: ",err.end);
        print("Error: ", sys.exc_info()[0])

    except:
        print("Error: ", sys.exc_info()[0])

    finally:
        if show_timing:
            print(f"Time to open the url: {time.perf_counter() - tic:0.4f}\n")


def main():

    usage = "Options h: get help, l: login name, p: URS password, u: OPeNDAP URL"     # FIXME

    try:
        # see https://docs.python.org/3.1/library/getopt.htm
        optlist, args = getopt.getopt(sys.argv[1:], 'hl:p:u:')
    except:
        # print help information and exit:
        print(usage)
        sys.exit(2)

    url = ""
    username = ""
    password = ""
    session = False

    for o, a in optlist:
        if o in ("-h", "--help"):
            print(usage)

        if o == "-l":
            username = a

        if o == "-p":
            password = a

        if o == "-u":
            url = a

    if url is None:
        print("A URL is required")
        print(usage)
        sys.exit(2)

    if username != "" and password != "":
        session = build_session((username, password), url)

    xa_ds = open_dataset(url, session)

    # cloud_ws = cloud_data['wind_speed'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))
    # cloud_ws_mean = cloud_ws.mean(dim=['latitude', 'longitude'])
    # print(cloud_ws_mean)


if __name__ == "__main__":
    main()
