EstimateQuantiles <- function(file) {
  #the argument file is a string specifying a file name of an .Rdata file
  #specify the working directory so that the data is accesable in the next step
  setwd('/pfs/imk/imk-tro/Gruppe_Knippertz/bn1998')
  
  #load packages
  library(tidyverse)
  library(PointFore)
  library(snow)
  library(Rmpi)
  
  #check if result file already exists. If not do the computations
  #load data file, apply EstimateFunctional with iden.fct=quantiles to a vector of observations Y
  #and a vector of forecasts X. Further specify specification model, stateVariable and instruments
  #save the result in res (it will be a list containing p-values and Test statistics of JTest and WaldTest,
  #estimated values for theta, vector of states)
  #extract further information that you might need later 
  #like estimated quantile level (state and theta plugged into linear model)
  #save everything in .Rdata file
  if(!file.exists(paste('Daten/Ergebnisse/Quantiles_new/Quantile_', file, sep =''))){
    load(paste("Daten/24/",file, sep=''))
    res <- estimate.functional(iden.fct = quantiles, Y = precipData$OBS, 
                               X = precipData$HRES,
                              model = probit_linear,
                              theta0 = c(0,0),
                              stateVariable = precipData$HRES,
                              instruments = c('X', 'lag(Y,2)'))
    theta <- summary(res)$coefficients[,1]
    f <- PointFore::probit_linear(res$stateVariable, theta)
  
    res_quantiles <- list('AvForcLvl'= mean(f), 'AvState'=mean(res$stateVariable), 
             'Res'=res, 'theta'= theta)
    save(res_quantiles , file=paste('Daten/Ergebnisse/Quantiles_new/Quantile_', file,
                                     sep =''))
  }
  else {print('File already exists')}
}