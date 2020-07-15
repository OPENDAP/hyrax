
import xarray as xa
import sys

# Get the granule names
from ssmis_granules_opendap import f16_ssmis_100
from ssmis_granules_opendap import base_url

# Allows us to visualize the dask progress for parallel operations
from dask.diagnostics import ProgressBar

ProgressBar().register()

# OPeNDAP In the Cloud

od_files = []

for g in f16_ssmis_100:
    od_files.append(base_url + g)

print(od_files[0], '\n', od_files[-1])

try:
    cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords')

    cloud_ws = cloud_data['wind_speed'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))

    cloud_ws_mean = cloud_ws.mean(dim=['latitude', 'longitude'])

    print(cloud_ws_mean)

except:
    print("Error:", sys.exc_info()[0])

