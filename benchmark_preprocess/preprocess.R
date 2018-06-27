library(Biobase)
library(crlmm)
library(hapmap370k)
library(dplyr)
library(ggplot2)
library(purrr)
library(reshape2)

# Specify directories ---------------------------------------------------------

# Input directory
datadir <- "BENCHMARK"

# Output directory
outdir <- paste("R_Benchmark/")
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
  map(.f = arrange, batch, variable)

# Plot raw data ---------------------------------------------------------------

# Red channel
ggplot(raw_eset_batch[["R"]], aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Green channel
ggplot(raw_eset_batch[["G"]], aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Preprocessing and genotyping ------------------------------------------------

# Load package ff
library(ff)
options(ffcaching="ffeachflush")

# Normalized data
cnSet <- genotype.Illumina(sampleSheet = samplesheet, arrayNames = arrayNames,
                           arrayInfoColNames = arrayInfo, cdfName = "human370v1c",
                           batch = batch)

# Plot normalized data --------------------------------------------------------
plot(crlmmResult[["SNR"]][,], pch=as.numeric(scanbatch), xlab="Array", ylab="SNR",
     main="Signal-to-noise ratio per array",las=2)
hist(crlmmResult[["SNR"]][,])
plot(density(crlmmResult[["SNR"]][,]))



