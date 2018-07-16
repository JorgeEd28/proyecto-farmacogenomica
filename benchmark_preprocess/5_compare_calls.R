library(Biobase)
library(crlmm)
library(dplyr)
library(ggplot2)
library(purrr)
library(stringr)
library(reshape2)
library(ff)

# Specify directories ---------------------------------------------------------

# Input directory
datadir <- "GenomeStudio"

# Output directory
outdir <- "R_Benchmark"

# Load files ------------------------------------------------------------------

# CRLMM calls
cnSet <- readRDS(file.path(outdir, "normalize_data.rds"))
open(calls(cnSet))
calls_crlmm <- as.data.frame(as.ffdf(calls(cnSet)))

# GenomeStudio calls
calls_gs <- read.csv(file.path(datadir, "calls_genomestudio.csv"), as.is = TRUE)

# Annotation file
anno_df <- read.csv(file.path(outdir, "annotation_file.csv"), as.is = TRUE)

# Check order of data ---------------------------------------------------------
calls_crlmm_var <- data.frame(IlmnID = rownames(calls_crlmm), 
                              stringsAsFactors = FALSE)
calls_crlmm_var <- calls_crlmm_var %>% 
  left_join(anno_df %>% select(IlmnID, Name))

calls_identical <- identical(calls_crlmm_var[["Name"]], calls_gs[["Name"]])
if (!calls_identical) {stop("Las variantes no son idénticas, no se pueden comparar las llamadas")
}

# Prepare data ----------------------------------------------------------------

# Clean rows and column names from CRLMM
rownames(calls_crlmm) <- c()

# Clean column names from GenomeStudio
colnames(calls_gs) <- sub("*(.GType)", "", colnames(calls_gs))
calls_gs <- select(calls_gs, -Name)

# Recode genotyped
dict = c("AA" = 1, "AB" = 2, "BB" = 3)
calls_gs_recode <- calls_gs %>%
  mutate_all(funs(recode(., !!!dict)))

# Compare calls ---------------------------------------------------------------

diff_allele <- data.frame(row.names = 1:nrow(calls_crlmm))
for(i in names(calls_crlmm)){
  diff_allele[[i]] <- abs(calls_crlmm[[i]] - calls_gs_recode[[i]])
}


#colnames(calls_crlmm) <- sub("^X[0-9]*?", "", colnames(calls_crlmm))

