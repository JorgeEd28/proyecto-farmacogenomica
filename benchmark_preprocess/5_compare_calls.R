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

# Arrange order of data -------------------------------------------------------
calls_crlmm_var <- data.frame(IlmnID = rownames(calls_crlmm), 
                              stringsAsFactors = FALSE)
calls_crlmm_var <- calls_crlmm_var %>% 
  left_join(anno_df %>% select(IlmnID, Name) %>% unique())

calls_gs <- calls_gs %>%
  arrange(factor(Name, levels = calls_crlmm_var[["Name"]]))

calls_identical <- identical(calls_crlmm_var[["Name"]], calls_gs[["Name"]])
if (!calls_identical) {stop("Las variantes no son idénticas, no se pueden comparar las llamadas")
}

# Prepare data ----------------------------------------------------------------

# Clean rows and column names from CRLMM
rownames(calls_crlmm) <- c()

# Clean column names from GenomeStudio
colnames(calls_gs) <- sub("*(.GType)", "", colnames(calls_gs))
calls_gs <- select(calls_gs, -Name)

# Reshape calls matrix
melt_calls_gs <- calls_gs
colnames(melt_calls_gs) <- sub("^X[0-9]*?", "", colnames(melt_calls_gs))
melt_calls_gs <- melt(melt_calls_gs, measure.vars = colnames(melt_calls_gs),
                      variable.name = "Microarreglo", value.name = "Genotipo")

# Recode genotyped
dict = c("AA" = 1, "AB" = 2, "BB" = 3)
calls_gs_recode <- calls_gs %>%
  mutate_all(funs(recode(., !!!dict)))

# Compare calls ---------------------------------------------------------------

diff_allele <- data.frame(row.names = 1:nrow(calls_crlmm))
for(i in names(calls_crlmm)){
  diff_allele[[i]] <- abs(calls_crlmm[[i]] - calls_gs_recode[[i]])
}
diff_allele[is.na(diff_allele)] <- 2
colnames(diff_allele) <- sub("^X[0-9]*?", "", colnames(calls_crlmm))

# Analysis by sample ----------------------------------------------------------

# Proportion of alleles of SNPs different in both PED
prop_by_sample <- data.frame(muestra = colnames(diff_allele),
                             proporcion = colMeans(diff_allele)/2,
                             row.names = NULL)

# Analysis by snp -------------------------------------------------------------

# Annotate PED with variants
diff_snp <- diff_allele
diff_snp[diff_snp == 2] <- 1
# Get frequency table, delete variantes with 0 and 1 frequency
frec_by_snp <- data.frame(variante = calls_crlmm_var[["Name"]],
                          frecuencia = rowSums(diff_snp)) %>%
  arrange(desc(frecuencia))
# Get number of different by frequency
frec_by_n_variants <- frec_by_snp %>% group_by(frecuencia) %>% 
  summarize(n_variantes = n()) %>% ungroup() %>% arrange(desc(frecuencia))

# Plots -----------------------------------------------------------------------

# Distribution of genotype calls
dist_geno <- ggplot(melt_calls_gs, aes(x = Microarreglo, fill = Genotipo)) +
  geom_bar() + theme_minimal() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Microarreglo", y = "Número de variantes")

# Bar plot by sample
prop_bar <- ggplot(prop_by_sample, aes(x = reorder(muestra, -proporcion), y = proporcion, fill = proporcion)) +
  geom_bar(stat = "identity", show.legend=F) + theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Microarreglo", y = "Proporción")

# Density plot by sample
prop_dens <- ggplot(prop_by_sample, aes(x = proporcion, y = ..scaled.., color = "blue", fill="blue")) +
  geom_density(alpha = 0.5, show.legend=F, adjust = 1) + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Proporción", y = "Densidad")

# Bar plot by variant (top 10)
frec_bar <- ggplot(frec_by_snp[1:20,], aes(x = reorder(variante, -frecuencia), y = frecuencia, fill = frecuencia)) +
  geom_bar(stat = "identity", show.legend=F) + theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(x = "Variante", y = "Frecuencia")

# Save RDS --------------------------------------------------------------------

# Save PNG
png(file.path(outdir, "dist_geno.png"), width = 2400, height = 1200, res = 300)
print(dist_geno)
dev.off()

png(file.path(outdir, "prop_diff_by_sample_barplot_r_gs.png"), width = 2400, height = 1200, res = 300)
print(prop_bar)
dev.off()

png(file.path(outdir, "prop_diff_by_sample_density_r_gs.png"), width = 2400, height = 1200, res = 300)
print(prop_dens)
dev.off()

png(file.path(outdir, "frec_diff_by_snp_barplot_r_gs.png"), width = 2400, height = 1200, res = 300)
print(frec_bar)
dev.off()

# Save RDS and CSV
saveRDS(dist_geno, file.path(outdir, "dist_geno.rds"))
saveRDS(prop_bar, file.path(outdir, "prop_diff_by_sample_barplot_r_gs.rds"))
saveRDS(prop_dens, file.path(outdir, "prop_diff_by_sample_density_r_gs.rds"))
saveRDS(frec_bar, file.path(outdir, "frec_diff_by_snp_barplot_r_gs.rds"))

write.csv(prop_by_sample, file.path(outdir, "prop_diff_by_sample_r_gs.csv"),
          quote = FALSE, row.names = FALSE)
write.csv(frec_by_snp, file.path(outdir, "frec_diff_by_snp_r_gs.csv"),
          quote = FALSE, row.names = FALSE)
write.csv(frec_by_n_variants, file.path(outdir, "frec_diff_by_n_variants_r_gs.csv"),
          quote = FALSE, row.names = FALSE)
