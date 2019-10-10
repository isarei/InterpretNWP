#clear all, load packages, set working directory
rm(list=ls())

library(car)

setwd('~')

#import functions
source('RCode/GetPWaldExpectiles.R')
source('RCode/GetPWaldQuantiles.R')

#load meta inforation and get coordinates
load('RCode/TRMM_025x025_Metadata_Isabelle.Rdata')
coords <- cbind(TRMM_metainformation$longitude, TRMM_metainformation$latitude)

#apply GetPWaldExpectiles and GetPWaldQuantiles row-wise to coordinate matrix and specify coloumn names
#for the output dataframe
PWald_expectiles <- as.data.frame(t(apply(coords, 1, GetPWaldExpectiles)))
PWald_quantiles <- as.data.frame(t(apply(coords, 1, GetPWaldQuantiles)))

colnames(PWald_expectiles) <-c('PWald', 'lon', 'lat')
colnames(PWald_quantiles) <-c('PWald', 'lon', 'lat')

#save results as .Rdata
save(PWald_expectiles, file = 'Daten/Ergebnisse/PWaldExpectiles.Rdata')
save(PWald_quantiles, file = 'Daten/Ergebnisse/PWaldQuantiles.Rdata')

