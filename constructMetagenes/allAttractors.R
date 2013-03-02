## FUNCTION TO GENERATE METAGENES BASED ON ALL FEATURES (SEEDS) IN A MATRIX
#####

allAttractors <- function(exprMat){
  require(cafr)
  require(impute)
  
  exprMat[exprMat=="null"] <- NA
  if( any(is.na(exprMat)) ){
    exprMat <- impute.knn(exprMat)$data
  }
  
  outputMat <- matrix(as.numeric(), nrow=nrow(exprMat), ncol=nrow(exprMat))
  rownames(outputMat) <- rownames(exprMat)
  colnames(outputMat) <- paste("Attr", rownames(exprMat), sep="-")
  
  for(seed in rownames(exprMat)){
    tmp <- CAFrun(exprMat, exprMat[seed,], verbose=F, sorting=F)
    outputMat[names(tmp), paste("Attr", seed, sep="-")] <- tmp
  }
  
  return(outputMat)
}
