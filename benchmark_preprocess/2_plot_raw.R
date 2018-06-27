library(Biobase)
library(crlmm)
library(dplyr)
library(ggplot2)
library(purrr)
library(reshape2)

# Specify directories ---------------------------------------------------------

dir <- "R_Benchmark"

# Reading RDS -----------------------------------------------------------------

raw_eset_batch <- readRDS(file.path(dir, "raw_eset.rds"))

# Plot raw data ---------------------------------------------------------------

# Red channel
raw_red <- ggplot(raw_eset_batch[["R"]], aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Green channel
raw_green <- ggplot(raw_eset_batch[["G"]], aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Save RDS --------------------------------------------------------------------

# Save PNG
png(file.path(dir, "raw_red.png"), width = 2400, height = 1200, res = 300)
print(raw_red)
dev.off()

png(file.path(dir, "raw_green.png"), width = 2400, height = 1200, res = 300)
print(raw_green)
dev.off()

# Save RDS
saveRDS(raw_red, file.path(dir, "raw_red.rds"))
saveRDS(raw_green, file.path(dir, "raw_green.rds"))
