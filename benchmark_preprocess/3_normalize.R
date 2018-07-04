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

# ff options
options(ffcaching="ffeachflush")

# Reading data ----------------------------------------------------------------

# Read in sample annotation info
samplesheet <- read.csv(file.path(datadir, "benchmark_samplesheet.csv"), 
                        skip = 6, as.is = TRUE)
manifest_raw <- read.csv(file.path(datadir, "Manifest", "CODIGO46_2017_01_20011739X343381_B1.csv"), 
                         as.is = TRUE, skip = 7)
batch <- read.csv(file.path(outdir, "sample-batch.csv"), 
                  as.is = TRUE, colClasses = c("character", "factor"))
arrayNames <- file.path(datadir, "intensity_data", 
                        samplesheet[["SentrixBarcode_A"]],
                        paste(samplesheet[["SentrixBarcode_A"]], 
                              samplesheet[["SentrixPosition_A"]], 
                              sep = "_"))

# Annotation data frame -------------------------------------------------------

anno_file <- manifest_raw %>%
  cbind(isSnp = TRUE) %>%
  rename(featureNames = Name, position = MapInfo, chromosome = Chr)

# Normalized data -------------------------------------------------------------

setwd(outdir)
cnSet <- genotype.Illumina(sampleSheet = samplesheet, arrayNames = arrayNames, 
                           call.method="krlmm", cdfName = "nopackage", 
                           anno = anno_file, genome = "hg19", batch = batch, 
                           quantile.method="between", nopackage.norm="quantile")

# Save RDS --------------------------------------------------------------------

saveRDS(cnSet, "normalize_data.rds")