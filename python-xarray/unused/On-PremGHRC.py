from netCDF4 import Dataset
import xarray as xa
import dask

# Allows us to visualize the dask progress for parallel operations
from dask.diagnostics import ProgressBar

ProgressBar().register()

# from dask.distributed import Client
# client = Client(memory_limit=10e10, processes=False) # Note: was 6e9 
# client"n

# https://goldsmr4.gesdisc.eosdis.nasa.gov/opendap/MERRA2/M2T1NXFLX.5.12.4/contents.html

url = 'https://goldsmr4.gesdisc.eosdis.nasa.gov/opendap/MERRA2/M2T1NXFLX.5.12.4/1984/11/MERRA2_100.tavg1_2d_flx_Nx.198411'

from datetime import date, timedelta

files = []
d = date.fromisoformat('1984-11-01')
while True:

    files.append(f'{url}{str(d.day).zfill(2)}.nc4')
    d = d + timedelta(days=1)

    if d.month == 12:
        break

files

import getpass

username = input("URS Username: ")
password = getpass.getpass("URS Password: ")

from pydap.client import open_url
from pydap.cas.urs import setup_session

ds_url = files[0]
session = setup_session(username, password, check_url=ds_url)
gesdisc_data = xa.open_mfdataset(files, engine='pydap', parallel=True, combine='by_coords',
                                 backend_kwargs={'session': session})
gesdisc_data
hflux = gesdisc_data.HFLUX.sel(lat=slice(-53.99, -14), lon=slice(140, 170))
hflux_mean = hflux.mean(dim=['lat', 'lon'])
hflux_mean.plot.line()

