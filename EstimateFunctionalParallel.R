#Clear all
rm(list=ls())
#Packages
library(tidyverse)
library(PointFore)
library(snow)
library(Rmpi)

#Directory
#setwd("/Users/isa/Documents/UNI/Master/Masterarbeit")
setwd('/pfs/imk/imk-tro/Gruppe_Knippertz/bn1998/Daten/24')

#Import
source('~/RCode/EstimateQuantiles.R')
source('~/RCode/EstimateExpectiles.R')


#Argumente lesen
args <- commandArgs(trailingOnly = TRUE)
print(args)
clustersize <- as.numeric(args[1])  #specifies number of nodes used in makeCluster below
splittotal  <- as.numeric(args[2])  #specifies total number of data files
splitpart   <- as.numeric(args[3])  #files a splitted into groups; specifies number of files in each group
splitpartin <- as.numeric(args[4])  #specfies the group of files thats currently worked with(is a number from 1 to splittotal/splitpart) 

#Files
#files <- list.files('/pfs/imk/imk-tro/Gruppe_Knippertz/bn1998/Daten/24')
#weniger Files zum Testen
#files <- files[200001:576000]

#Take all files and then only the files in the current group
files <- list.files()
files <- files[(splitpartin*splitpart-splitpart+1):(splitpartin*splitpart)]

#Print files in current group (just for testing)
cat("\n")
print(files)
cat("\n")

##Apply EstimateQuantile and EstimateExpectiles to the current group of files
#Cluster
cl <- makeCluster(clustersize, type = "MPI")
clusterExport(cl,c('EstimateQuantiles', 'EstimateExpectiles'))
clusterApplyLB(cl, files, EstimateQuantiles)
clusterApplyLB(cl, files, EstimateExpectiles)
stopCluster(cl)

