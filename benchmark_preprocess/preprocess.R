library(Biobase)
library(crlmm)
library(dplyr)
library(purrr)
library(reshape2)
library(ff)

# Specify directories ---------------------------------------------------------

# Input directory
datadir <- "BENCHMARK"

# Output directory
outdir <- "R_Benchmark"
ldPath(outdir)
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# ff options
options(ffcaching="ffeachflush")

# Reading data ----------------------------------------------------------------

# Read in sample annotation info
samplesheet <- read.csv(file.path(datadir, "benchmark_samplesheet.csv"), 
                        skip = 6, as.is = TRUE)
arrayNames <- file.path(datadir, "intensity_data", 
                        samplesheet[["SentrixBarcode_A"]],
                        paste(samplesheet[["SentrixBarcode_A"]], 
                              samplesheet[["SentrixPosition_A"]], 
                              sep = "_"))
arrayInfo <- list(barcode = "SentrixBarcode_A", position="SentrixPosition_A")

# Normalized data
cnSet <- genotype.Illumina(sampleSheet = samplesheet, arrayNames = arrayNames, 
                           cdfName = "nopackage", batch = batch)

# Plot normalized data --------------------------------------------------------
plot(crlmmResult[["SNR"]][,], pch=as.numeric(scanbatch), xlab="Array", ylab="SNR",
     main="Signal-to-noise ratio per array",las=2)
hist(crlmmResult[["SNR"]][,])
plot(density(crlmmResult[["SNR"]][,]))



