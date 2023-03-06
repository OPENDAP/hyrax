# https://ghrc.nsstc.nasa.gov/opendap/globalir/data/2020/0525/globir.20146.0000
from netCDF4 import Dataset
import xarray as xa
import dask

# Allows us to visualize the dask progress for parallel operations
from dask.diagnostics import ProgressBar

ProgressBar().register()

# url = 'https://ghrc.nsstc.nasa.gov/opendap/ssmis/f17/daily/data/2019/f17_ssmis_2019'
#
# from datetime import date, timedelta
#
# files = []
# d = date.fromisoformat('2019-01-01')
# str(d.day).zfill(2) + str(d.month).zfill(2)
# # + timedelta(days=1)
# while True:
#
#     if d.month == 3 and d.day == 7:
#         d = d + timedelta(days=1)
#         continue
#
#     files.append(f'{url}{str(d.month).zfill(2)}{str(d.day).zfill(2)}v7.nc')
#     d = d + timedelta(days=1)
#
#     if d.month == 4:
#         break
#
# print(files)
# data = xa.open_mfdataset(files, parallel=True, combine='by_coords')
# data
#
# ws = data['wind_speed'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))
# print(ws.data)
#
# ws_mean = ws.mean(dim=['latitude', 'longitude'])
# ws_mean.plot.line()

## OPeNDAP In the Cloud

import requests

# CMR Link to use
# https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1625128926-GHRC_CLOUD&temporal=2019-01-01T10:00:00Z,2019-12-31T23:59:59Z
r = requests.get(
    'https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1625128926-GHRC_CLOUD&temporal=2019-01-01T10:00:00Z,2019-04-01T00:00:00Z&pageSize=365')
response_body = r.json()

od_files = []
for itm in response_body['items']:
    for urls in itm['umm']['RelatedUrls']:
        if 'OPeNDAP' in urls['Description']:
            od_files.append(urls['URL'])

print(od_files)

import getpass

username = input("URS Username: ")
password = getpass.getpass("URS Password: ")

from pydap.client import open_url
from pydap.cas.urs import setup_session

ds_url = od_files[0]
session = setup_session(username, password, check_url=ds_url)

# data = xa.open_mfdataset(od_files,engine='pydap',parallel=True, backend_kwargs={'session':session})
cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords',
                               backend_kwargs={'session': session})
cloud_data

cloud_ws = cloud_data['wind_speed'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))
cloud_ws.data

cloud_ws_mean = cloud_ws.mean(dim=['latitude', 'longitude'])
cloud_ws_mean.plot.line()
ws_mean.plot.line()

