## SOURCE IN SHARED .Rprofile WHICH CONTAINS SYNAPSE LOGIN HOOK,
## SETS COMMON SYNAPSE CACHE FOR ALL WORKERS, AND SETS COMMON LIBPATH
source("/shared/code/R/.Rprofile")

## TAKES FOR ARGUMENTS
#####
##   synId   : Synapse ID for TCGA dataset to create metagenes
#####

myArgs <- commandArgs(TRUE)
synId <- myArgs[1]

require(synapseClient)
require(R.utils)

outputPath <- file.path("/shared/output", synId)

## INCLUDE RECURSIVE FOR GENE NAMES WITH "/"
attractorsFinished <- list.files(outputPath, pattern=".txt", recursive=T)

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

metagenes <- lapply(as.list(attractorsExpected), function(i){
  tmp <- as.numeric(readLines(file.path(outputPath, i)))
  if( length(tmp) == 0L ){
    return(NULL)
  } else{
    names(tmp) <- rownames(exprMat)
    return(sort(tmp, decreasing=T)[1:100])
  }
})
names(metagenes) <- sub(".txt", "", attractorsExpected, fixed=T)
save(metagenes, file=file.path(outputPath, "metagenes.rbin"))

## UPLOAD TO SYNAPSE
myFold <- createEntity(Folder(name=mySynEnt$annotations$acronym, parentId="syn1714112"))
myMG <- Data(name="metagenes.rbin", parentId=myFold$properties$id)

myMG <- addFile(myMG, file.path(outputPath, "metagenes.rbin"))
myMG <- storeEntity(myMG)

## ADD PROVENANCE - NEED LINK TO EXTERNAL URL TO COMPLETE THIS (POINTING TO GITHUB)
myAct <- Activity(name="Attractor Metagenes Scanning", used=list(list(entity=mySynEnt, wasExecuted=F)))
myAct <- createEntity(myAct)
generatedBy(myMG) <- myAct
myMG <- storeEntity(myMG)


