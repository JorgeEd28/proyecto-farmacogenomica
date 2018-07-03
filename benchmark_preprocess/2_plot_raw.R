library(Biobase)
library(crlmm)
library(dplyr)
library(ggplot2)
library(purrr)
library(reshape2)

# Specify directories ---------------------------------------------------------

dir <- "R_Benchmark"

# Reading CSV -----------------------------------------------------------------

raw_red_data <- read.csv(file.path(dir, "raw_red_data.csv"), 
                         colClasses = c("factor", "integer", "factor"))
raw_green_data <- read.csv(file.path(dir, "raw_green_data.csv"), 
                           colClasses = c("factor", "integer", "factor"))

# Plot raw data ---------------------------------------------------------------

# Red channel
raw_red_boxplot <- ggplot(raw_red_data, aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Green channel
raw_green_boxplot <- ggplot(raw_green_data, aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Save RDS --------------------------------------------------------------------

# Save PNG
png(file.path(dir, "raw_red_boxplot.png"), width = 2400, height = 1200, res = 300)
print(raw_red_boxplot)
dev.off()

png(file.path(dir, "raw_green_boxplot.png"), width = 2400, height = 1200, res = 300)
print(raw_green_boxplot)
dev.off()

# Save RDS
saveRDS(raw_red_boxplot, file.path(dir, "raw_red_boxplot.rds"))
saveRDS(raw_green_boxplot, file.path(dir, "raw_green_boxplot.rds"))
