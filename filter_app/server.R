library(dplyr)

options(shiny.maxRequestSize=150*1024^2)

function(input, output) {
  # Initialize reactive variables
  v <- reactiveValues(filter_list = NULL, anno_probes = NULL)
  
  # Annotation data -----------------------------------------------------------
  
  # Display data
  zz <- gzfile("annotation_file.csv.gz", "rt")
  anno <- read.csv(zz, colClasses = c("character", "character", "factor", 
                                      "integer", "character", "character"))
  output$annotation <- DT::renderDataTable(DT::datatable(
    anno,
    colnames = c(
      "Probe name",
      "Probe-variant name",
      "Chromosome",
      "Position",
      "Variant name",
      "Ensembl ID",
      "Gene symbol"
    ),
    filter = 'top',
    options = list(search = list(regex = TRUE, caseInsensitive = FALSE))
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
        write.csv(anno[input[["annotation_rows_all"]],], file, 
                  row.names = FALSE, quote = FALSE, na = "")
      }
    )
  
  # Upload filter data --------------------------------------------------------
  
  # Output table
  output$contents <- renderTable({
    
    # Ensure that values are available
    req(input$filter)
    
    # Read lines of file
    tryCatch(
      {
        v$filter_list <- readLines(input$filter$datapath)
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    
    # Activate comparison when click in button
    v$anno_probes <- anno %>% filter((!!sym(input$filter_type)) %in% v$filter_list)
    
    # Return summary table
    summary_table <- v$anno_probes %>% select(Variant, Ensembl, Gene) %>%
      group_by(Gene) %>% 
      summarize(Ensembl = paste(unique(Ensembl), collapse = ", "), 
                Variants = n_distinct(Variant)) %>%
      ungroup()
    return(summary_table)
  })
  
  # Return not matching filters
  output$not_found <- renderText({ 
    if(is.null(v$anno_probes)){
      return("Upload a filter file to start")
    }
    not_found <- setdiff(v$filter_list,
                         v$anno_probes[[input$filter_type]])
    return(paste("Following", input$filter_type, 
                "IDs were not found in annotation dataset:",
                paste(not_found, collapse = ', ')))
    
    # return(paste("Following", input$filter_type,
    #              "IDs were not found in annotation dataset:",
    #              not_found))
  })
}

# Read MAP
# probes <- read.table(input$map$datapath, sep = "\t", 
#                      colClasses = c("NULL", "character", "NULL", "NULL"))