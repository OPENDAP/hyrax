
import xarray as xa

# Get the granule names
import airs_granules

# Allows us to visualize the dask progress for parallel operations
from dask.diagnostics import ProgressBar

ProgressBar().register()

# OPeNDAP In the Cloud

base_url = 'http://ngap-west.opendap.org/opendap/dmrpp/s3/airs/'

od_files = []

for g in airs_granules.airs_366:
    od_files.append(base_url + g)

print('URL start and end:\n', od_files[0], '\n', od_files[-1])

cloud_data = xa.open_mfdataset(od_files[0:2], data_vars='CloudTopPres_A', engine='pydap', parallel=True, combine='by_coords')

print('Completed the xarray open_mfdataset\n')

cloud_ws = cloud_data['CloudTopPres_A'].sel(Latitude=slice(-53.99, -14), Longitude=slice(140, 170))

print('Completed the CloudTopPres_A selection\n')

cloud_ws_mean = cloud_ws.mean(dim=['Latitude', 'Longitude'])

print('Computed the mean of the CloudTopPres_A values\n')
print(cloud_ws_mean)

# cloud_ws_mean.plot.line()


