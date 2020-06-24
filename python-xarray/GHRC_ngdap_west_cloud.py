
import xarray as xa
import getpass
from pydap.cas.urs import setup_session

# Get the granule names
import ssmis_granules

# Allows us to visualize the dask progress for parallel operations
from dask.diagnostics import ProgressBar

ProgressBar().register()

# OPeNDAP In the Cloud

base_url = 'http://ngap-west.opendap.org/opendap/ngap/providers/GHRC_CLOUD/collections/RSS%20SSMIS%20OCEAN%20PRODUCT' \
           '%20GRIDS%20DAILY%20FROM%20DMSP%20F16%20NETCDF%20V7/granules/'

od_files = []

for g in ssmis_granules.f16_ssmis_100:
    od_files.append(base_url + g)

print(od_files[0], '\n', od_files[-1])

username = input("URS Username: ")
password = getpass.getpass("URS Password: ")
# Hack, pass the first URL to get the session setup
session = setup_session(username, password, check_url=od_files[0])

while True:
    cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords',
                                   backend_kwargs={'session': session})

    cloud_ws = cloud_data['wind_speed'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))

    cloud_ws_mean = cloud_ws.mean(dim=['latitude', 'longitude'])
    cloud_ws_mean.plot.line()

