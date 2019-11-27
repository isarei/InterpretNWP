#!/usr/bin/env python
# coding: utf8

import netCDF4
import os
import pandas as pd
import numpy as np
from datetime import datetime
import rpy2
import rpy2.robjects as ro
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri
from rpy2.robjects.conversion import localconverter
import sys
from multiprocessing import Pool




##get all forecasts for given locations
##lon: Index from 0 to 1439, lat: Index from 0 to 399
def combine_forecasts(lon,lat):
    #Save Forecast-file-names in 'files'
    ##Directory where 24ahead daily precipitation forecasts are (can be in sepearate files for every month for instance)
    os.chdir('/Daten/24PrecipForecasts')
    files = os.listdir()
    files.sort()

    #initialize data frame for date, lon, lat, forecast
    #Get the forecast values with the function get_forecasts
    df_total = pd.DataFrame({'dates':[], 'lon':[],'lat':[], 'HRES':[]})
    for file in files:
        print(file)
        nc = netCDF4.Dataset(file, 'r')
        df_total = df_total.append(get_forecasts(lon, lat, nc), ignore_index=True)
        nc.close()
    return(df_total)


##Retrieves forecast from given nc file for given lon, lat
##lon: Index von 0 bis 1439, lat index von 0 bis 399
def get_forecasts(lon, lat, nc):
    #Convert dates
    Time = nc.variables['time']
    dates = netCDF4.num2date(Time[:], Time.units, Time.calendar)
    times_new = ["" for x in range(len(dates))]
    for i in range(0,len(dates)):
        times_new[i] = dates[i].strftime("%Y-%m-%d")

    #get times in original format
    times = nc.variables['time'][:]

    ##Get lon and lat vector to write coordinates in data frame, not index
    #lats from -40 to 40
    lats = nc.variables['latitude'][:]
    latselect = np.logical_and(lats>-40.25,lats<40)
    lats = nc.variables['latitude'][latselect]
    #lons
    lons = nc.variables['longitude'][:]

    #initialize array to save forecasts in
    temp = np.array([])

    help = nc.variables['tp'][:,latselect,lon]
    #get forecast for everyday
    for time in range(len(times)):
        temp = np.append(temp, help[time, lat])

    #save date, lon, lat, forecast in dataframe and return
    if lons[lon]<180:
        df = pd.DataFrame({'dates':times_new, 'lon':np.repeat(lons[lon], len(times_new)),
               'lat':np.repeat(lats[lat], len(times_new)), 'HRES':temp})
        return(df)
    if lons[lon]>=180:
        lons[lon] = lons[lon] - 360
        df = pd.DataFrame({'dates':times_new, 'lon':np.repeat(lons[lon], len(times_new)),
               'lat':np.repeat(lats[lat], len(times_new)), 'HRES':temp})
        return(df)


##Retrieves observation
##lon: Index von 0 bis 1439, lat index von 0 bis 399
def get_obs(lon, lat):
    os.chdir('Daten/Reanalyse')
    nc = netCDF4.Dataset('TP_Reanalysis_summed_daily/daily_tp01012007_30122018.nc', 'r')

    #Convert dates; 3287: Take dates sinve 2007!!
    Time = nc.variables['time']
    dates = netCDF4.num2date(Time[:], Time.units, Time.calendar)
    times_new = ["" for x in range(len(dates))]
    for i in range(0,len(dates)):
        times_new[i] = dates[i].strftime("%Y-%m-%d")

    times = nc.variables['time'][:]

    ##Get lon and lat vector to write coordinates in data frame, not index
    #lats from -50 to 50
    lats = nc.variables['latitude'][:]
    latselect = np.logical_and(lats>-40.25,lats<40)
    lats = nc.variables['latitude'][latselect]
    #lons
    lons = nc.variables['longitude'][:]


    OBS = np.array([])

    help = nc.variables['tp'][:,latselect,lon]
    for time in range(len(times)):
        print(time)
        OBS = np.append(OBS, help[time, lat])

    if lons[lon]<180:
        df = pd.DataFrame({'dates':times_new, 'lon':np.repeat(lons[lon], len(times_new)),
                       'lat':np.repeat(lats[lat], len(times_new)), 'OBS':OBS})
        return(df)
    if lons[lon]>=180:
        lons[lon] = lons[lon] - 360
        df = pd.DataFrame({'dates':times_new, 'lon':np.repeat(lons[lon], len(times_new)),
                       'lat':np.repeat(lats[lat], len(times_new)), 'OBS':OBS})
        return(df)

    nc.close()


##Saves an R Data Frame with dates, lon, lat, HRES and OBS in it
##lon: Index from 0 to 1439, lat: Index from 0 to 399
def combine_HRES_OBS(lon, lat):
    os.chdir('Daten/Reanalyse')
    ##Open netCDF file for getting a lat and lon vector in order to print coordinates and not indices in file name
    ##File with daily total precipitation 
    nc = netCDF4.Dataset('TP_Reanalysis_summed_daily/daily_tp01012007_30122018.nc', 'r')
    #lats from -50 to 50
    lats = nc.variables['latitude'][:]
    latselect = np.logical_and(lats>-40.25,lats<40)
    lats = nc.variables['latitude'][latselect]
    #lons
    lons = nc.variables['longitude'][:]
    nc.close()

    if lons[lon]>=180:
        lons[lon] = lons[lon] - 360
        print(lons[lon])

    if os.path.exists('TP/precip_era5_025_025_24_2007-2018_' + '%g'%(lons[lon]) + '_' + '%g'%(lats[lat]) + '.Rdata') == False:
        res = combine_forecasts(lon,lat)
        res_o = get_obs(lon,lat)

        res['HRES'] = res['HRES'].shift(-1)
        res = res.drop(res.index[-1])

        if len(res['lon'])==len(res_o['lon']):
            print('dimensions ok')
            res['OBS'] = res_o['OBS']
        else:
            print('wrong dimensions')


        with localconverter(ro.default_converter + pandas2ri.converter):
            rdata = ro.conversion.py2rpy(res)
        ro.r.assign("precip", rdata)
        ro.r("save(precip, file='{}')".format('TP/precip_era5_025_025_24_2007-2018_' + '%g'%(lons[lon]) + '_' + '%g'%(lats[lat]) + '.Rdata'))
    else:
        print('File already exists')

##Read input arguments
lon = int(sys.argv[1])
clustersize = int(sys.argv[2])

##Generate coordinate pairs as input to pool.starmap
coords = []
for i in range(320):
    coords.append([lon, i])

##Parallel apply combine_HRES_OBS to coords
with Pool(processes=clustersize) as pool:
    pool.starmap(combine_HRES_OBS, coords)
    pool.close()
