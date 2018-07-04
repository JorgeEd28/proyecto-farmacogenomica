library(dplyr)
library(ggplot2)

# Specify directories ---------------------------------------------------------

# Input directory
datadir <- "GenomeStudio"

# Output directory
outdir <- "R_Benchmark"

# Load files ------------------------------------------------------------------

map_1 <- read.table(file.path(datadir, "Benchmark", "PLINK_030718_0158", "Benchmark.map"), 
                    sep = "\t", colClasses = "character")
map_2 <- read.table(file.path(datadir, "MAPC46.MAP"), 
                    sep = "\t", colClasses = "character")
ped_1 <- read.table(file.path(datadir, "Benchmark", "PLINK_030718_0158", "Benchmark.ped"), 
                    sep = "\t", colClasses = "character")
ped_2 <- read.table(file.path(datadir, "MAPC46.PED"), 
                    sep = "\t", colClasses = "character")

# Compare MAPs ----------------------------------------------------------------

map_identical <- identical(map_1[2], map_2[2])
map_identical
if (!map_identical) {stop("Los MAP no son idénticos, no se pueden comparar PED")
}

# Compare PEDs ----------------------------------------------------------------

# Transpose data frames
ped_1_t <- as.data.frame(t(ped_1), stringsAsFactors = FALSE)
colnames(ped_1_t) <- ped_1_t[2,]
ped_1_t <- ped_1_t[-c(1:6),]

ped_2_t <- as.data.frame(t(ped_2), stringsAsFactors = FALSE)
colnames(ped_2_t) <- ped_2_t[2,]
ped_2_t <- ped_2_t[-c(1:6),]

not_equal_snp <- data.frame()
for(i in names(ped_1_t)){
  not_equal_snp[[i]] <- ifelse(ped_1_t[[i]] == ped_2_t[[i]], 0, 1)
}
