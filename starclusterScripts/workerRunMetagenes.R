## SOURCE IN SHARED .Rprofile WHICH CONTAINS SYNAPSE LOGIN HOOK,
## SETS COMMON SYNAPSE CACHE FOR ALL WORKERS, AND SETS COMMON LIBPATH
source("/shared/code/R/.Rprofile")
options(stringsAsFactors=F)

## TAKES FOR ARGUMENTS (PASSED FROM sgeKickoff.R)
#####
##   exprFile:  shared path to expression matrix
##   outputDir: the directory to output metagene files
##   startSeed: the first seed that this worker will run
##   endSeed:   the last seed gene that this worker will run
#####
myArgs <- commandArgs(trailingOnly=T)
exprFile <- myArgs[1]
outputDir <- myArgs[2]
startSeed <- as.numeric(myArgs[3])
endSeed <- as.numeric(myArgs[4])

## LIBRARIES HAVE BEEN INSTALL TO SHARED LIBPATH
require(cafr)
require(impute)

## GRAB EXPRESSION FILE
exprMat <- read.delim(exprFile, header=F, as.is=T)
rownames(exprMat) <- exprMat[, 1]
exprMat <- exprMat[, -1]
colnames(exprMat) <- exprMat[1, ]
exprMat <- exprMat[-1, ]
exprMat <- as.matrix(exprMat)

## IMPUTE MISSING VALUES, IF NECESSARY
exprMat[exprMat=="null"] <- NA
if( any(is.na(exprMat)) ){
  exprMat <- impute.knn(exprMat)$data
}

## RUN CAF FOR EACH SEED GENE AND OUTPUT FILE
for( seed in rownames(exprMat)[startSeed:endSeed] ){
  outVec <- CAFrun(exprMat, exprMat[seed,], verbose=T, sorting=F)

  ## FOR GENE SYMBOLS THAT INCLUDE / (MESSES WITH FILE OUTPUT)
  if( grepl("/", seed, fixed=T) ){
    dir.create(paste(outputDir, "/Attr-", dirname(seed), sep=""))
  }
  write.table(outVec, file=paste(outputDir, "/Attr-", seed, ".txt", sep=""), quote=F, sep="\t", row.names=F, col.names=F)
}



