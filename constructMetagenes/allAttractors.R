## FUNCTION TO GENERATE METAGENES BASED ON ALL FEATURES (SEEDS) IN A MATRIX
#####

allAttractors <- function(exprMat){
  require(cafr)
  require(impute)
  
  exprMat[exprMat=="null"] <- NA
  if( any(is.na(exprMat)) ){
    exprMat <- impute.knn(exprMat)$data
  }
  
  outList <- mclapply(as.list(rownames(exprMat)), function(seed){
    CAFrun(exprMat, exprMat[seed,], verbose=F, sorting=F)
  })
  names(outList) <- paste("Attr", rownames(exprMat), sep="-")
  
  return(outList)
}
