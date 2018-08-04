library(dplyr)
library(ggplot2)
library(UpSetR)

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

# Compare by allele by SNPs
diff_allele <- data.frame(row.names = 1:nrow(ped_1_t))
for(i in names(ped_1_t)){
  diff_allele[[i]] <- ifelse(ped_1_t[[i]] == ped_2_t[[i]], 0, 1)
}

# Analysis by sample ----------------------------------------------------------

# Proportion of alleles of SNPs different in both PED
prop_by_sample <- data.frame(muestra = colnames(diff_allele),
                             proporcion = colMeans(diff_allele),
                             row.names = NULL) 

# Analysis by snp -------------------------------------------------------------

# Annotate PED with variants
diff_allele_annotated <- cbind(variante = rep(map_1[[2]], each = 2), diff_allele)
# Group alleles by SNPs
diff_snp_annotated <- diff_allele_annotated %>% group_by(variante) %>%
  summarise_all(max)
# Get frequency table, delete variantes with 0 and 1 frequency
frec_by_snp <- data.frame(variante = diff_snp_annotated[[1]],
                          frecuencia = rowSums(diff_snp_annotated[-1])) %>%
  arrange(desc(frecuencia))
# Get number of different by frequency
frec_by_n_variants <- frec_by_snp %>% group_by(frecuencia) %>% 
  summarize(n_variantes = n()) %>% ungroup() %>% arrange(desc(frecuencia))

# Get the samples with shared genotypes between PEDs for each SNP
shared_snp_samps <- apply(diff_snp_annotated[-1], 1, function(x) which(x == 0))
names(shared_snp_samps) <- diff_snp_annotated$variante

# Plots -----------------------------------------------------------------------

# Bar plot by sample
prop_bar <- ggplot(prop_by_sample, aes(x = reorder(muestra, -proporcion), y = proporcion, fill = proporcion)) +
  geom_bar(stat = "identity", show.legend=F) + theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Microarreglo", y = "Proporción")

# Density plot by sample
prop_dens <- ggplot(prop_by_sample, aes(x = proporcion, y = ..scaled.., color = "blue", fill="blue")) +
  geom_density(alpha = 0.5, show.legend=F) + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Proporción", y = "Densidad")

# Bar plot by variant (top 20)
frec_bar <- ggplot(frec_by_snp[1:20,], aes(x = reorder(variante, -frecuencia), y = frecuencia, fill = frecuencia)) +
  geom_bar(stat = "identity", show.legend=F) + theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Variante", y = "Frecuencia")

# Bar plot for frequency with most variants (top 20)
var_frec <- ggplot(frec_by_n_variants, aes(x = frecuencia, y = n_variantes, fill = n_variantes)) + 
  geom_bar(stat = "identity", show.legend=F) + theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90)) + 
  labs(x = "Frecuencia", y = "Número de variantes")

# UpSet plot of shared variants between both PEDs in all samples
# Plot needs to be saved right away, UpSet doesn't support assigning the plot to a variable
png(file.path(outdir, "isec_plot.png"), width = 2400, height = 1200, res = 300)
upset(fromList(shared_snp_samps), order.by = "freq", nsets = 10, 
      mainbar.y.label = "Samples per intersection", 
      sets.x.label = "Samples per variant", 
      main.bar.color = "dodgerblue", sets.bar.color = "violetred3")
dev.off()

# Save RDS --------------------------------------------------------------------

# Save PNG
png(file.path(outdir, "prop_diff_by_sample_barplot.png"), width = 2400, height = 1200, res = 300)
print(prop_bar)
dev.off()

png(file.path(outdir, "prop_diff_by_sample_density.png"), width = 2400, height = 1200, res = 300)
print(prop_dens)
dev.off()

png(file.path(outdir, "frec_diff_by_snp_barplot.png"), width = 2400, height = 1200, res = 300)
print(frec_bar)
dev.off()

png(file.path(outdir, "frec_diff_by_n_variants_barplot.png"), width = 2400, height = 1200, res = 300)
print(var_frec)
dev.off()

# Save RDS and CSV
saveRDS(prop_bar, file.path(outdir, "prop_diff_by_sample_barplot.rds"))
saveRDS(prop_dens, file.path(outdir, "prop_diff_by_sample_density.rds"))
saveRDS(frec_bar, file.path(outdir, "frec_diff_by_snp_barplot.rds"))
saveRDS(var_frec, file.path(outdir, "frec_diff_by_n_variants_barplot.rds"))

write.csv(prop_by_sample, file.path(outdir, "prop_diff_by_sample.csv"),
          quote = FALSE, row.names = FALSE)
write.csv(frec_by_snp, file.path(outdir, "frec_diff_by_snp.csv"),
          quote = FALSE, row.names = FALSE)
write.csv(frec_by_n_variants, file.path(outdir, "frec_diff_by_n_variants.csv"),
          quote = FALSE, row.names = FALSE)
