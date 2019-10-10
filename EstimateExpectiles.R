EstimateExpectiles <- function(file) {
  #the argument file is a string specifying a file name of an .Rdata file
  #specify the working directory so that the data is accesable in the next step
  setwd('~')
  
  #load packages
  library(tidyverse)
  library(PointFore)
  library(snow)
  library(Rmpi)
  
  #check if result file already exists. If not do the computations
  #load data file, apply EstimateFunctional with iden.fct=expectiles to a vector of observations Y
  #and a vector of forecasts X. Further specify specification model, stateVariable and instruments
  #save the result in res (it will be a list containing p-values and Test statistics of JTest and WaldTest,
  #estimated values for theta, vector of states)
  #extract further information that you might need later 
  #like estimated quantile level (state and theta plugged into linear model)
  #save everything in .Rdata file
  if (!file.exists(paste('Daten/Ergebnisse/Expectiles_new/Expectile_', 
                         file, sep =''))) {
    load(paste("Daten/24/",file, sep=''))
    res <- estimate.functional(iden.fct = expectiles, Y = precipData$OBS, 
                              X = precipData$HRES,
                              model = probit_linear,
                              theta0 = c(0,0),
                              stateVariable = precipData$HRES,
                              instruments = c('X', 'lag(Y,2)'))
    theta <- summary(res)$coefficients[,1]
    f <- PointFore::probit_linear(res$stateVariable, theta)
  
    res_expectiles <- list('AvForcLvl'= mean(f), 'AvState'=mean(res$stateVariable), 
             'Res'=res, 'theta'= theta)
    save(res_expectiles , file=paste('Daten/Ergebnisse/Expectiles_new/Expectile_', 
                                   file, sep =''))
    }
  else {print('File already exists')}
}


##save plot(res) as pdf
#pdf(paste("RCode/Plots/PlotExpextiles_", file, '.pdf', sep=''))
#print(plot(res))
#dev.off()
