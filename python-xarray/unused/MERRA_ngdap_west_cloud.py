
# to run this in a bare environment, set up the environment thusly:
# conda install xarray dask requests
# pip install pydap

import xarray as xa

# Get the granule names
import merra_granules

# Allows us to visualize the dask progress for parallel operations
from dask.diagnostics import ProgressBar

ProgressBar().register()

# OPeNDAP In the Cloud

base_url = 'http://ngap-west.opendap.org/opendap/dmrpp/s3/merra2/'

od_files = []

for g in merra_granules.merra2:
    od_files.append(base_url + g)

print('URL start and end:\n', od_files[0], '\n', od_files[-1])

# Removed this: data_vars='Var_DHDT_ANA',
cloud_data = xa.open_mfdataset(od_files, engine='pydap', parallel=True, combine='by_coords')

print('Completed the xarray open_mfdataset\n')

cloud_ws = cloud_data['Var_DHDT_ANA'].sel(lat=slice(-53.99, -14), lon=slice(140, 170))

print('Completed the Var_DHDT_ANA selection\n')

cloud_ws_mean = cloud_ws.mean(dim=['lat', 'lon'])

print('Computed the mean of the Var_DHDT_ANA values\n')
print(cloud_ws_mean)

# cloud_ws_mean.plot.line()


