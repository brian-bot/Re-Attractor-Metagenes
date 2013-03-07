## SOURCE IN SHARED .Rprofile WHICH CONTAINS SYNAPSE LOGIN HOOK,
## SETS COMMON SYNAPSE CACHE FOR ALL WORKERS, AND SETS COMMON LIBPATH
source("/shared/code/R/.Rprofile")

## TAKES FOR ARGUMENTS
#####
##   synId   : Synapse ID for TCGA dataset to create metagenes
#####

# myArgs <- commandArgs(TRUE)
# synId <- myArgs[1]
synId <- "syn417767"

require(synapseClient)
require(R.utils)

outputPath <- file.path("/shared/output", synId)

## INCLUDE RECURSIVE FOR GENE NAMES WITH "/"
attractorsFinished <- list.files(outputPath, recursive=T)

mySynEnt <- downloadEntity(synId)
exprFile <- file.path(mySynEnt$cacheDir, mySynEnt$files)

exprMat <- read.delim(exprFile, header=F, as.is=T)
rownames(exprMat) <- exprMat[, 1]
exprMat <- exprMat[, -1]
colnames(exprMat) <- exprMat[1, ]
exprMat <- exprMat[-1, ]
exprMat <- as.matrix(exprMat)

attractorsExpected <- paste("Attr-", rownames(exprMat), ".txt", sep="")

stopifnot(attractorsExpected %in% attractorsFinished)

## CREATE THE MASTER METAGENE MATRIX AND PUSH TO SYNAPSE
outFile <- file.path(outputPath, paste(tolower(mySynEnt$annotations$acronym), "Metagenes.txt", sep=""))
system(paste("touch", outFile))
for( i in attractorsExpected[1:5] ){
  write.table(rbind(c(sub(".txt", "", i, fixed=T), readLines(file.path(outputPath, i)))),
              file=outFile, append=T, quote=F, sep="\t", row.names=F, col.names=F)
}


