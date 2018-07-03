library(biomaRt)
library(dplyr)
library(stringr)
library(IRanges)
library(GenomicRanges)

# Specify directories ---------------------------------------------------------

# Input directory
datadir <- "BENCHMARK/Manifest"

# Output directory
outdir <- "R_Benchmark"

# Read manifest file ----------------------------------------------------------

manifest_raw <- read.csv(file.path(datadir, "CODIGO46_2017_01_20011739X343381_B1.csv"), 
                     as.is = TRUE, skip = 7)

# Clean snp name and select columns
manifest_renames <- manifest_raw %>% 
  select(IlmnID, Name, Chr, MapInfo, Source, SourceStrand) %>%
  mutate(Variant = sub(".*(rs[0-9]*).*", "\\1", Name))

# Add missing chromosomes
add_chr <- manifest_renames %>% 
  filter(Chr == 0, grepl(':', Variant)) %>% 
  mutate(Position = sub("(GSA-)*([0-9]*:[0-9]*).*", "\\2", Variant) %>% strsplit(":"),
         Chr = Position[[1]][1], MapInfo = strtoi(Position[[1]][2])) %>%
  select(-Position)
  
manifest_clean <- manifest_renames %>% anti_join(add_chr, by = "IlmnID") %>%
  bind_rows(add_chr)

# Select databases ------------------------------------------------------------

# SNP db
snp_db <- useMart("ENSEMBL_MART_SNP", dataset="hsapiens_snp", host="grch37.ensembl.org")
# Ensembl gene db
ensembl_db <- useMart("ensembl", dataset="hsapiens_gene_ensembl", host="grch37.ensembl.org")
# Get gene names --------------------------------------------------------------

# By SNP name
genes_by_snp_ensembl <- getBM(attributes = c("refsnp_id", "ensembl_gene_stable_id"),
                           filters = c("snp_filter"),
                           values = manifest_clean %>% filter(str_detect(Variant, "rs*")) %>% select(Variant),
                           mart = snp_db) %>%
  filter(ensembl_gene_stable_id != "")
genes_by_snp_hgnc <- getBM(attributes = c("ensembl_gene_id", "hgnc_symbol"),
                           filters = c("ensembl_gene_id"),
                           values = select(genes_by_snp_ensembl, ensembl_gene_stable_id),
                           mart = ensembl_db)
genes_by_snp <- genes_by_snp_ensembl %>%
  left_join(genes_by_snp_hgnc, by = c("ensembl_gene_stable_id" = "ensembl_gene_id")) %>%
  transmute(Variant = refsnp_id, Ensembl = ensembl_gene_stable_id, Gene = hgnc_symbol)

# By position
all_genes <- getBM(attributes = c("chromosome_name","start_position","end_position","ensembl_gene_id","hgnc_symbol"),
                   filters = c("chromosome_name"), values = list(c(1:22,"X","Y")), mart = ensembl_db)
all_genes_rd <- with(all_genes, GRanges(seqnames = chromosome_name, IRanges(start_position, end_position)))

filter_var <- manifest_clean %>%
  anti_join(genes_by_snp) %>%
  filter(!is.na(Chr) & !is.na(MapInfo))
filter_var_rd <- with(filter_var, GRanges(seqnames = Chr, IRanges(MapInfo, MapInfo)))

var_overlaps <- findOverlaps(filter_var_rd, all_genes_rd)

genes_by_pos <- data.frame(Variant = filter_var[queryHits(var_overlaps), "Variant"], 
                           all_genes[subjectHits(var_overlaps), c("ensembl_gene_id", "hgnc_symbol")] %>% 
                             rename(Ensembl = ensembl_gene_id, Gene = hgnc_symbol))

# Full merge

genes_by_snp_pos <- rbind(genes_by_snp, genes_by_pos)

anno_df <- left_join(manifest_clean, genes_by_snp_pos)

# Save annotation file

write.csv(anno_df, file.path(datadir, "annotation_file.csv"), 
          quote = FALSE, na = "")
