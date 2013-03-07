## SOURCE IN SHARED .Rprofile WHICH CONTAINS SYNAPSE LOGIN HOOK,
## SETS COMMON SYNAPSE CACHE FOR ALL WORKERS, AND SETS COMMON LIBPATH
source("/shared/code/R/.Rprofile")

## TAKES FOR ARGUMENTS
#####
##   synId   : Synapse ID for TCGA dataset to create metagenes
##   numSeeds: number of seeds to run on each worker
#####
myArgs <- commandArgs(TRUE)
synId <- myArgs[1]
numSeeds <- as.numeric(myArgs[2])

require(synapseClient)
require(R.utils)

## CREATE AN OUTPUT DIRECTORY TO STORE RESULTS
outputPath <- file.path("/shared/output", synId)
if( !file.exists(outputPath) ){
  dir.create(outputPath)
}

## DOWNLOAD THE EXPRESSION MATRIX FOR SPECIFIED SYNAPSE ENTITY
mySynEnt <- downloadEntity(synId)
exprFile <- file.path(mySynEnt$cacheDir, mySynEnt$files)
totalSeeds <- countLines(exprFile) - 1

numJobs <- ceiling(totalSeeds/numSeeds)

## SPIN UP ALL JOBS NECESSARY
for( i in 1:numJobs ){
  startSeed <- (i-1)*numSeeds + 1
  if( i != numJobs ){
    stopSeed <- i*numSeeds
  } else{
    stopSeed <- totalSeeds
  }

  sgeCommand <- paste("qsub -V -wd /shared/code/repos/Re-Attractor-Metagenes/starclusterScripts -N ", synId, "-", i, " -b y -o /shared/tmp/eoFiles -e /shared/tmp/eoFiles /usr/bin/Rscript workerRunMetagenes.R ", exprFile, " ", outputPath, " ", startSeed, " ", stopSeed, sep="")

  if( i != totalSeeds/numSeeds ){
    system(sgeCommand)
  }
}
system("echo they all launched")


