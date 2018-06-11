library(Biobase)
library(crlmm)
library(hapmap370k)
library(ff)

########################
##### Reading data #####
########################

data.dir <- system.file("idatFiles", package="hapmap370k")
# Read in sample annotation info
samples <- read.csv(file.path(data.dir, "samples370k.csv"), as.is=TRUE)

# Read in .idats using sampleSheet information
RG <- readIdatFiles(samples, path=data.dir,
                    arrayInfoColNames=list(barcode=NULL,position="SentrixPosition"),saveDate=TRUE)
pd <- pData(RG)
arrayNames <- file.path(data.dir, unique(samples[, "SentrixPosition"]))
arrayInfo <- list(barcode=NULL, position="SentrixPosition")
# Generate dates as factors 
scandatetime <- strptime(protocolData(RG)[["ScanDate"]], "%m/%d/%Y %H:%M:%S %p")
datescanned <- substr(scandatetime, 1, 10)
scanbatch <- factor(datescanned)
levels(scanbatch) <- 1:16
scanbatch = as.character(scanbatch)

# Plot
par(mfrow=c(2,1), mai=c(0.4,0.4,0.4,0.1), oma=c(1,1,0,0))
boxplot(log2(exprs(channel(RG, "R"))), xlab="Array", ylab="", names=1:40,
        main="Red channel",outline=FALSE,las=2)
boxplot(log2(exprs(channel(RG, "G"))), xlab="Array", ylab="", names=1:40,
        main="Green channel",outline=FALSE,las=2)
mtext(expression(log[2](intensity)), side=2, outer=TRUE)
mtext("Array", side=1, outer=TRUE)

########################
###### Genotyping ######
########################

crlmmResult <- crlmmIllumina(sampleSheet=samples, arrayNames=arrayNames,
                             arrayInfoColNames=arrayInfo, cdfName="human370v1c",
                             batch=scanbatch)
crlmmResult <- crlmmIllumina(samples, path=data.dir, arrayInfoColNames=arrayInfo, saveDate=TRUE, cdfName="human370v1c")

plot(crlmmResult[["SNR"]][,], pch=as.numeric(scanbatch), xlab="Array", ylab="SNR",
     main="Signal-to-noise ratio per array",las=2)



