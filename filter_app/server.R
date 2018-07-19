function(input, output) {
  # Display data
  zz <- gzfile("annotation_file.csv.gz", "rt")
  data <- read.csv(zz, as.is = TRUE)
  output$annotation <- DT::renderDataTable(DT::datatable(
    data,
    colnames = c(
      "Probe name",
      "Probe-variant name",
      "Chromosome",
      "Position",
      "Variant name",
      "Ensembl ID",
      "Gene symbol"
    ),
    filter = 'top'
  ))
  
  # Save filter data
  output$filtered_row <-
    renderPrint({
      input[["annotation_rows_all"]]
    })
  
  # Download filter data
  output$download_filtered <-
    downloadHandler(
      filename = "annotation_file_filter.csv",
      content = function(file) {
        write.csv(data[input[["annotation_rows_all"]],],
                  file,
                  row.names = FALSE,
                  quote = FALSE,
                  na = "")
      }
    )
}