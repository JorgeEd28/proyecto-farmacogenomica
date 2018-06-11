# Cargar librería
library(dplyr)
library(fuzzyjoin)
library(stringr)

Names <- read.csv("path/to/file", stringsAsFactors = FALSE)
Genes_raw <- read.csv("path/to/file", stringsAsFactors = FALSE)

# Reorganizar Genes column
Genes <- Genes_raw %>% stack() %>%
  filter(values != "") %>%
  transmute(Name = str_replace_all(values, c(" ", "\xca"), ""), Gene = as.character(ind))

# Join
Genes_Names <- regex_left_join(Names, Genes) %>% 
  select(-Name.x) %>% rename(Variante = Name.y)
not_find <- anti_join(Genes, Genes_Names %>% filter(Variante != "") %>% unique(), 
                      by = c("Name" = "Variante"))

# Guardar df
write.csv(Genes_Names, "path/to/file.csv")