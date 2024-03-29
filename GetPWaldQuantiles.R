GetPWaldQuantiles <- function(coords=c(lon,lat)){
  #similar to GetResultsExpectiles
  #input is vector of dimension 2 specifying coordinates
  #load packages and set workind directory
  library(car)
  setwd('~')
  
  lon <- coords[1]
  lat <- coords[2]
  
  #load result file generated by EstimateQuantiles
  load(paste0('Daten/Ergebnisse/Quantiles_new/Quantile_preD_TRMM_025_025_ECMWF_24_1998-2017_'
              ,lon, '_',lat,'.Rdata'))
  
  #compute the pvalue of Wald test according to GitHub Repository Schmidtpk/PointFore
  ##if covarianve matrix is singular, an error occurs. This can happen. Therefore, tryCatch.
  ##NaN in pWald now mean that for these coordinates the covariance matrix has been sigular.
  out <- tryCatch({
    gmm <- res_quantiles$Res$gmm
    test_res <- linearHypothesis(gmm, 'Theta[2]=0')
    #pWald <- cbind(unname(attr(test_res, 'value')[1,1]), lon, lat)
    pWald <- cbind(test_res[2,3],lon,lat)
    print(pWald)
    return(pWald)
  }, error = function(cond) {
    message(cond)
    pWald <- cbind(NaN, lon, lat)
    print(pWald)
    return(pWald)
  }, warning = function(cond) {
    message(cond)
    pWald <- cbind(NaN, lon, lat)
    print(pWald)
    return(pWald)
  }
  )
  return(out)
}
