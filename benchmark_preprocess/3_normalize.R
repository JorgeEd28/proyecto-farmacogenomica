library(Biobase)
library(crlmm)
library(dplyr)
library(purrr)
library(reshape2)
library(ff)

# Specify directories ---------------------------------------------------------

# ff options
options(ffcaching="ffeachflush")

# Input directory
datadir <- "BENCHMARK"

# Output directory
outdir <- "R_Benchmark"
ldPath(outdir)

# Reading data ----------------------------------------------------------------

# Read in sample annotation info
samplesheet <- read.csv(file.path(datadir, "benchmark_samplesheet.csv"), 
                        skip = 6, as.is = TRUE)
manifest_raw <- read.csv(file.path(datadir, "Manifest", "CODIGO46_2017_01_20011739X343381_B1.csv"), 
                         as.is = TRUE, skip = 7)
batch_file <- read.csv(file.path(outdir, "sample-batch.csv"), 
                  colClasses = "character")
arrayNames <- file.path(datadir, "intensity_data", 
                        samplesheet[["SentrixBarcode_A"]],
                        paste(samplesheet[["SentrixBarcode_A"]], 
                              samplesheet[["SentrixPosition_A"]], 
                              sep = "_"))

# Annotation data frame -------------------------------------------------------

# Annotation file MUST be named as "anno" (issue in crlmm package)
anno <- cbind(manifest_raw, isSnp = TRUE) %>% 
  rename(featureNames = IlmnID, position = MapInfo, chromosome = Chr) %>%
  filter(!Name %in% c("Extension", "Hybridization", "Non-Polymorphic", 
                      "Non-Specific Binding", "Staining", "Stringency"))
# "anno" MUST have rownames as the featureNames (issue in crlmm package)
rownames(anno) <- anno[["featureNames"]]

batch <- select(samplesheet, Sample_ID) %>% 
  left_join(batch_file, by = c("Sample_ID" = "variable")) %>% 
  with(batch)

# Normalized data -------------------------------------------------------------

cnSet <- genotype.Illumina(sampleSheet = samplesheet, arrayNames = arrayNames, 
                           call.method="krlmm", cdfName = "nopackage", 
                           anno = anno, genome = "hg19", batch = batch, 
                           quantile.method="within", nopackage.norm="quantile")

# Save RDS --------------------------------------------------------------------

saveRDS(cnSet, file.path(outdir, "normalize_data.rds"))
