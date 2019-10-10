GetPWaldExpectiles <- function(coords=c(lon,lat)){
  #see GetPWaldQuantiles for more information
  
  library(car)
  
  setwd('~')
  
  lon <- coords[1]
  lat <- coords[2]
  
  load(paste0('Daten/Ergebnisse/Expectiles_new/Expectile_preD_TRMM_025_025_ECMWF_24_1998-2017_'
              ,lon, '_',lat,'.Rdata'))
  
  out <- tryCatch({
    gmm <- res_expectiles$Res$gmm
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
