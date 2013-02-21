#!/usr/bin/env python
"""
file:   test.py
author: Scott Wales (scott.wales@unimelb.edu.au)

Create plots from the UM's oasis output.

Oasis lets you capture the fields sent & recieved by each coupled component by
selcting the EXPOUT use instead of EXPORTED in the namcouple file.

Unfortunately the UM defines the field as a 1D array as if it was an
unstructured grid, which is difficult to work with. This script converts the
field back to two dimensions & plots the field at each timestep.

~~~

Copyright 2013 ARC Centre of Excellence for Climate System Science

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
import netCDF4 as nc
import matplotlib.pyplot as plt

file = nc.Dataset('SOLAR_out.1950-02-01T00:00:00.nc')

time = file.variables['time'][:]
data = file.variables['SOLAR'][...]

data = data.reshape((40,1,145,192))

for i in range(0,40):
    plt.title(time[i])
    plt.contourf(data[i,0,:,:])
    plt.savefig('umsolar%03d.png'%i)
