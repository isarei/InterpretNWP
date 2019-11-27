import netCDF4
import os
import pandas as pd
import numpy as np
from datetime import datetime
from netCDF4 import Dataset


##WD
os.chdir('/pfs/imk/imk-tro/Gruppe_Knippertz/bn1998/Daten/Reanalyse/')

##Inputfile: hourly precipitation data for some number of years.
nc = netCDF4.Dataset('tp01012010_31122012.nc', 'r')


##Outputfile: total daily precipitation
dest = Dataset("daily_tp01012010_31122012.nc", "w", format="NETCDF4", persist = True)

time = dest.createDimension('time', None)
lat = dest.createDimension('latitude', 721)
lon = dest.createDimension('longitude', 1440)

times = dest.createVariable('time', 'int32', ('time',))

times.setncattr('units', 'hours since 1900-01-01 00:00:00')
times.setncattr('long_name', 'time')
times.setncattr('calendar', 'gregorian')

latitudes = dest.createVariable('latitude', 'f4', ('latitude',))
longitudes = dest.createVariable('longitude', 'f4', ('longitude',))


tp = dest.createVariable('tp', 'f8', ('time', 'latitude', 'longitude',))
tp.units = 'm'

latitudes[:] = nc.variables['latitude'][:]
longitudes[:] = nc.variables['longitude'][:]

##December 31st is not completely in current file! --> see calculations below
##entry 0 = 23-24 Uhr of December 31 of previous year
hours = nc.variables['time'][1:-23]
hmax = len(hours)

lons = nc.variables['longitude']
lats = nc.variables['latitude']
lonmax = len(lons)
latmax = len(lats)


var_tp = nc.variables['tp']

idx = 0

#Calculate daily TP
for h in range(1, hmax, 24):
    print(h)
    tp_hours = var_tp[h:h+24, :, :]

    tp_values_set = False

    for i in range(24):
        if not tp_values_set:
            tp_day = tp_hours[i, :, :]
            tp_values_set = True
        else:
            tp_day += tp_hours[i, :, :]

    tp[idx, :, :] = tp_day

    times[idx] = hours[h]


    ##Print date####################################################
    Time = nc.variables['time']
    dates = netCDF4.num2date(Time[1:-23], Time.units, Time.calendar)
    print(dates[h].strftime("%Y-%m-%d"))
    ################################################################d

    idx = idx + 1

##Calculate daily TP December 31st
#Load file, that contains 00.00 Uhr January 1st of next year
#(auskommentieren beim letzten vorhandenen File)
nc2 = netCDF4.Dataset('tp01012013_31122014.nc', 'r')

tp_values_set = False

tp_hours = var_tp[-23:, :, :]

for i in range(23):
    if not tp_values_set:
        tp_day = tp_hours[i, :, :]
        tp_values_set = True
    else:
        tp_day += tp_hours[i, :, :]

tp_day = tp_day + nc2.variables['tp'][0,:,:]

tp[idx, :, :] = tp_day
times[idx] = nc.variables['time'][-23]

##Print dates
dates = netCDF4.num2date(Time[-23], Time.units, Time.calendar)
print(dates.strftime("%Y-%m-%d"))


dest.close()
nc.close()
nc2.close()
