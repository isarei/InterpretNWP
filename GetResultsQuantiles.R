GetResultsQuantiles <- function(coords = c(lon,lat)) {
  #see GetResultsExpectiles for more information (everything works analogously except 
  #for taking the result files generated with EstimateQuntiles instead of EstimateExpectiles)
  
  setwd('/pfs/imk/imk-tro/Gruppe_Knippertz/bn1998')
  library(car)
  
  lon <- coords[1]
  lat <- coords[2]
  
  load(paste0('Daten/Ergebnisse/Quantiles_new/Quantile_preD_TRMM_025_025_ECMWF_24_1998-2017_'
              ,lon, '_',lat,'.Rdata'))
  #Theta
  theta_1_q <- res_quantiles$theta[[1]]
  theta_2_q <- res_quantiles$theta[[2]]
  
  #Pvalue JTest
  helpvar <- summary(res_quantiles$Res)
  pvalue <- helpvar$Jtest$test[1,2]
  
  #Pvalue Wald
  #out <- tryCatch({
  #  gmm <- res_quantiles$Res$gmm
  #  pWald <- linearHypothesis(gmm, 'Theta[2]=0')
  #  return(pWald[2,3])
  #}, error = function(cond) {
  #  message(cond)
  #  pWald <- NaN
  #  return(pWald)
  #}, warning = function(cond) {
  #  message(cond)
  #  pWald <- NaN
  #  return(pWald)
  #}
  #)
  
  #State
  s_ninety <- quantile(res_quantiles$Res$stateVariable, 0.9)
  s_mean <- res_quantiles$AvState
  
  #Put Return calue together
  res_q <- t(c(lon, lat, theta_1_q, theta_2_q, pvalue, #out, 
               s_mean, s_ninety)) 
  
  return(res_q)
}