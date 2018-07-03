library(Biobase)
library(crlmm)
library(dplyr)
library(purrr)
library(reshape2)

# Specify directories ---------------------------------------------------------

# Input directory
datadir <- "BENCHMARK"

# Output directory
outdir <- "R_Benchmark"
ldPath(outdir)
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

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

# Read raw .idats using sampleSheet information
raw_cnSet <- readIdatFiles(sampleSheet = samplesheet, arrayNames = arrayNames,
                           arrayInfoColNames = arrayInfo, saveDate = TRUE)

# Generate data frame with expression data set
batch <- as.Date(protocolData(raw_cnSet)[["ScanDate"]], 
                 "%m/%d/%Y %H:%M:%S %p") %>% factor()
levels(batch) <- 1:length(levels(batch))
dict <- data.frame(variable = sampleNames(protocolData(raw_cnSet)), batch)
raw_eset <- assayData(raw_cnSet) %>% as.list %>% map(as.data.frame) %>% map(melt)
raw_eset_batch <- map2(raw_eset, list(dict), left_join) %>%
  map(arrange, batch, variable)

# Save CSV --------------------------------------------------------------------

write.csv(raw_eset_batch[["G"]], file.path(outdir, "raw_green_data.csv"),
          na = "", row.names = FALSE)
write.csv(raw_eset_batch[["R"]], file.path(outdir, "raw_red_data.csv"),
          na = "", row.names = FALSE)