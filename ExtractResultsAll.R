#Clear all and set working directory
rm(list=ls())
setwd('~')

#load packages
library(car)

#import functions
source('RCode/GetResultsQuantiles.R')
source('RCode/GetResultsExpectiles.R')

#load the file with meta information described in the README to get all the coordinates
#save coordinates row-wise in a matrix
load('RCode/TRMM_025x025_Metadata_Isabelle.Rdata')
coords <- cbind(TRMM_metainformation$longitude, TRMM_metainformation$latitude)
print(coords)

###Local Test
#coords <- t(matrix(data=c(-179.875, -49.875, -150.875, -30.875, -150.875, 30.625,
#                        -110.625, 10.875, -5.125,-20.125,25.375,20.375,145.125,-5.625),
#                 nrow = 2, ncol = 7))

#apply GetResultsQuantiles and GetResultsExpectiles row-wise to the coordinate matrix
res_quantiles <- as.data.frame(t(apply(coords, 1, GetResultsQuantiles)))
res_expectiles <- as.data.frame(t(apply(coords, 1, GetResultsExpectiles)))

#specify names of the columns in the result data frames
colnames(res_quantiles) <- c('lon', 'lat', 'theta1', 'theta2', 'p_opt', #'p_wald',
                               's_mean', 's_ninety')
colnames(res_expectiles) <- c('lon', 'lat', 'theta1', 'theta2', 'p_opt', #'p_wald',
                                's_mean', 's_ninety')

#save the results as .Rdata
save(res_quantiles, file = 'Daten/Ergebnisse/Res_quantiles.Rdata')
save(res_expectiles, file = 'Daten/Ergebnisse/Res_expectiles.Rdata')
