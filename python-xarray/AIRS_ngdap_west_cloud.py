
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

print(od_files[0], '\n', od_files[-1])

cloud_data = xa.open_mfdataset(od_files[0:2], engine='pydap', parallel=True, combine='by_coords')

cloud_ws = cloud_data['CloudTopPres_A'].sel(latitude=slice(-53.99, -14), longitude=slice(140, 170))

cloud_ws_mean = cloud_ws.mean(dim=['latitude', 'longitude'])
cloud_ws_mean.plot.line()


