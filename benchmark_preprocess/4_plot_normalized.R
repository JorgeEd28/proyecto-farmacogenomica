library(Biobase)
library(crlmm)
library(dplyr)
library(ggplot2)
library(purrr)
library(reshape2)
library(ff)

# Specify directories ---------------------------------------------------------

# ff options
options(ffcaching="ffeachflush")

# Directory
dir <- "R_Benchmark"
ldPath(dir)

# Create data frames ----------------------------------------------------------

cnSet <- readRDS(file.path(dir, "normalize_data.rds")); cnSet
batch <- read.csv(file.path(dir, "sample-batch.csv"), 
  colClasses = c("character", "factor"))

# Open ff files
open(assayData(cnSet)[["alleleA"]])
open(assayData(cnSet)[["alleleB"]])

# Convert ff to data frame
norm_red_data <- as.data.frame(as.ffdf(assayData(cnSet)[["alleleA"]]))
norm_green_data <- as.data.frame(as.ffdf(assayData(cnSet)[["alleleB"]]))
colnames(norm_red_data) <- sub("^X[0-9]*?", "", colnames(norm_red_data))
colnames(norm_green_data) <- sub("^X[0-9]*?", "", colnames(norm_green_data))

# Melt and add batch
norm_red_data <- norm_red_data %>%
  melt() %>%
  filter(!is.na(value), value != 0) %>%
  left_join(batch)
norm_green_data <- norm_green_data %>%
  melt() %>%
  filter(!is.na(value), value != 0) %>%
  left_join(batch)

# Order variables
order_variables <- batch %>%
  arrange(batch) %>% with(variable)

norm_red_data[["variable"]] <- factor(norm_red_data[["variable"]], 
                                     levels = order_variables)
norm_green_data[["variable"]] <- factor(norm_green_data[["variable"]], 
                                       levels = order_variables)

# Plot normalized data --------------------------------------------------------

# Red channel
norm_red_boxplot <- ggplot(norm_red_data, aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Green channel
norm_green_boxplot <- ggplot(norm_green_data, aes(x = variable, y = log2(value), fill = batch)) + 
  geom_boxplot(alpha=0.5) + scale_fill_brewer(palette = "Dark2") +
  theme(axis.text.x = element_text(angle = 90)) + xlab("Microarreglo") +
  labs(x = "Microarreglo", y = expression(paste("log"[2], "(intensidad)")))

# Get statistics --------------------------------------------------------------

norm_red_statistis <- norm_red_data %>% 
  group_by(variable) %>%
  summarize(mean = mean(value), variance = var(value), 
            IQR = IQR(value), median = median(value), na.rm = TRUE)

norm_green_statistis <- norm_green_data %>% 
  group_by(variable) %>%
  summarize(mean = mean(value), variance = var(value), 
            IQR = IQR(value), median = median(value))

# Save RDS --------------------------------------------------------------------

# Save PNG
png(file.path(dir, "norm_red_boxplot.png"), width = 2400, height = 1200, res = 300)
print(norm_red_boxplot)
dev.off()

png(file.path(dir, "norm_green_boxplot.png"), width = 2400, height = 1200, res = 300)
print(norm_green_boxplot)
dev.off()

# Save RDS and CSV
saveRDS(norm_red_boxplot, file.path(dir, "norm_red_boxplot.rds"))
saveRDS(norm_green_boxplot, file.path(dir, "norm_green_boxplot.rds"))

write.csv(norm_red_statistis, file.path(dir, "norm_red_statistics.csv"),
          na = "", row.names = FALSE, quote = FALSE)
write.csv(norm_green_statistis, file.path(dir, "norm_green_statistics.csv"),
          na = "", row.names = FALSE, quote = FALSE)
