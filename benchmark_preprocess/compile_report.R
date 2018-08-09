# Create report
output_sufix <- "Reporte_benchmark"
file_name <- paste(output_sufix, "tex", sep = ".")

# Compile Rnw to Latex
knitr::knit("Reporte_benchmark.Rnw", output = file_name)

# Compile Latex to PDF
system(paste("pdflatex -interaction=nonstopmode", file_name))
# Add bibliography
system(paste("bibtex", output_sufix))
# Add figures names
system(paste("pdflatex -interaction=nonstopmode", file_name))
system(paste("pdflatex -interaction=nonstopmode", file_name))

# Delete not needed files
files <- list.files(pattern = output_sufix)
files <- files[!grepl(".pdf", files)]
files <- files[!grepl(".tex", files)]