library(dplyr)
library(ggplot2)
library(UpSetR)

# Specify directories ---------------------------------------------------------

# PED and MAP directory
pedmap.dir <- "GenomeStudio"

# Samplesheet directory
samp.dir <- "BENCHMARK"

# Output directory
out.dir <- "R_Benchmark"

# Load files ------------------------------------------------------------------

# Load the PED and MAP files
map <- read.table(file.path(pedmap.dir, "Benchmark_C46.map"), sep = "\t",
                  colClasses = "character")
ped <- read.table(file.path(pedmap.dir, "Benchmark_C46.ped"), sep = "\t",
                  colClasses = "character")

# Load the samplesheet
samp <- read.csv(file.path(samp.dir, "benchmark_samplesheet.csv"), 
                 skip = 6, as.is = TRUE)

# Extract replicates only ----------------------------------------------------

# Get replication samples
replicates <- samp %>% filter(Replicates != "")
rownames(replicates) <- replicates[["Sample_ID"]]
replicates <- select(replicates, Replicates)

# Compare sample lines -------------------------------------------------------

# Transpose data frames
ped_t <- as.data.frame(t(ped), stringsAsFactors = FALSE)
colnames(ped_t) <- ped_t[2, ]
ped_t <- ped_t[-c(1:6), ]

# Compare genotype calls between samples and its replicates
diff.allele <- data.frame(row.names = 1:nrow(ped_t))
for(i in rownames(replicates)){
  diff.allele[[i]] <- ifelse(ped_t[[i]] == ped_t[[replicates[i,]]], 0, 1)
}

# Analysis by sample ----------------------------------------------------------

# Proportion of different calls between sample and its replicate
prop.by.sample <- data.frame(muestra = colnames(diff.allele),
                             proporcion = colMeans(diff.allele),
                             row.names = NULL)

# Analysis by SNP -------------------------------------------------------------

# Get SNP name
# Each variant in the MAP file appears twice in the PED file
diff.allele.annotated <- cbind(variante = rep(map[[2]], each = 2), diff.allele)

# Group rows by SNPs
diff.snp.annotated <- diff.allele.annotated %>% group_by(variante) %>%
  summarise_all(max)

# Get frequency table, delete variants with 0 and 1 frequency
freq.by.snp <- data.frame(variante = diff.snp.annotated[[1]],
                          frecuencia = rowSums(diff.snp.annotated[-1])) %>%
  filter(!frecuencia %in% c(0,1)) %>%
  arrange(desc(frecuencia))

# Get number of different alleles for each variant
feq.by.n.variants <- freq.by.snp %>% group_by(frecuencia) %>%
  summarize(n.variantes = n()) %>% ungroup() %>% arrange(desc(frecuencia))

# Get samples with shared genotypes between sample and replicate for each SNP
#shared.snp.samps <- apply(diff.snp.annotated[-1], 1, function(x) which(x == 0))
#names(shared.snp.samps) <- diff.snp.annotated$variante

# Plots -----------------------------------------------------------------------

# Bar plot by sample
prop.bar <- ggplot(prop.by.sample, aes(x = reorder(muestra, -proporcion), y = proporcion, fill = proporcion)) +
  geom_bar(stat = "identity", show.legend = F) + theme_minimal() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Microarreglo", y = "Proporción")

# Density plot by sample
prop.dens <- ggplot(prop.by.sample, aes(x = proporcion, y = ..scaled.., color = "blue", fill = "blue")) +
  geom_density(alpha = 0.5, show.legend = F) + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Proporción", y = "Densidad")

# Bar plot by variant (top 10)
freq.bar <- ggplot(freq.by.snp[1:20,], aes(x = reorder(variante, -frecuencia), y = frecuencia, fill = frecuencia)) +
  geom_bar(stat = "identity", show.legend = F) + theme_minimal() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Proporción", y = "Densidad")

# UpSet plot of shared variants between sample and replicate
# Plot needs to be saved right away, UpSet doesn't support assigning the plot to a variable
png(file.path(outdir, "replicates_shared_snp_isec_plot.png"), width = 2400, height = 1200, res = 300)
upset(fromList(shared.snp.samps), order.by = "freq", nsets = 10,
                   mainbar.y.label = "Samples per intersection",
                   sets.x.label = "Samples per variant",
                   main.bar.color = "dodgerblue", sets.bar.color = "violetred3")
dev.off()

# Save RDS --------------------------------------------------------------------

# Save PNG
png(file.path(out.dir, "replicates_prop_diff_by_sample_barplot.png"), width = 2400, height = 1200, res = 300)
print(prop.bar)
dev.off()

png(file.path(outdir, "replicates_prop_diff_by_sample_density.png"), width = 2400, height = 1200, res = 300)
print(prop.dens)
dev.off()

png(file.path(outdir, "replicates_freq_diff_by_snp_barplot.png"), width = 2400, height = 1200, res = 300)
print(freq.bar)
dev.off()

# Save RDS and CSV
saveRDS(prop.bar, file.path(outdir, "replicates_prop_diff_by_sample_barplot.rds"))
saveRDS(prop.dens, file.path(outdir, "replicates_prop_diff_by_sample_density.rds"))
saveRDS(freq.bar, file.path(outdir, "replicates_freq_diff_by_snp_barplot.rds"))

write.csv(prop.by.sample, file.path(outdir, "replicates_prop_diff_by_sample.csv"),
          quote = FALSE, row.names = FALSE)
write.csv(frec.by.snp, file.path(outdir, "replicates_freq_diff_by_snp.csv"),
          quote = FALSE, row.names = FALSE)
write.csv(frec.by.n.variants, file.path(outdir, "replicates_frec_diff_by_n_variants.csv"),
          quote = FALSE, row.names = FALSE)
