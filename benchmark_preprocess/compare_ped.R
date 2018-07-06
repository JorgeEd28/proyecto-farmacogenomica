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
map_2 <- read.table(file.path(datadir, "Benchmark_C46.map"), 
                    sep = "\t", colClasses = "character")
ped_1 <- read.table(file.path(datadir, "Benchmark", "PLINK_030718_0158", "Benchmark.ped"), 
                    sep = "\t", colClasses = "character")
ped_2 <- read.table(file.path(datadir, "Benchmark_C46.ped"), 
                    sep = "\t", colClasses = "character")

# Compare MAPs ----------------------------------------------------------------

map_identical <- identical(map_1[2], map_2[2])
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

# Compare
not_equal_snp <- data.frame(row.names = 1:nrow(ped_1_t))
for(i in names(ped_1_t)){
  not_equal_snp[[i]] <- ifelse(ped_1_t[[i]] == ped_2_t[[i]], 0, 1)
}

# Analysis by sample ----------------------------------------------------------

prop_not_equal_snp <- data.frame(muestra = colnames(not_equal_snp),
                                 proporcion = colMeans(not_equal_snp), 
                                 row.names = NULL) 

# Plots -----------------------------------------------------------------------

# Bar plot
prop_bar <- ggplot(prop_not_equal_snp, aes(x = reorder(muestra, -proporcion), y = proporcion, fill = proporcion)) +
  geom_bar(stat = "identity", show.legend=F) + theme_minimal() + 
  labs(x = "Microarreglo", y = "Proporción")

# Density plot
prop_dens <- ggplot(prop_not_equal_snp, aes(proporcion, color = "blue", fill="blue")) +
  geom_density(alpha = 0.5, show.legend=F) +
  labs(x = "Microarreglo", y = "Densidad")

# Save RDS --------------------------------------------------------------------

# Save PNG
png(file.path(outdir, "prop_not_equal_snp_barplot.png"), width = 2400, height = 1200, res = 300)
print(prop_bar)
dev.off()

png(file.path(outdir, "prop_not_equal_snp_density.png"), width = 2400, height = 1200, res = 300)
print(prop_dens)
dev.off()

# Save RDS and CSV
saveRDS(prop_bar, file.path(outdir, "prop_not_equal_snp_barplot.rds"))
saveRDS(prop_dens, file.path(outdir, "prop_not_equal_snp_density.rds"))
