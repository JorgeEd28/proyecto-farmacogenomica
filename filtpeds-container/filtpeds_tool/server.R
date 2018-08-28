library(dplyr)
library(shiny)

`%then%` <- shiny:::`%OR%`

options(shiny.maxRequestSize=2*1024^3, shiny.sanitize.errors = TRUE)

shinyServer(function(input, output) {
  # Initialize reactive variables
  v <- reactiveValues(filter_list = NULL, anno_probes = NULL, map = NULL,
                      new_map = NULL, index = NULL, anno_new = NULL, ped = NULL)
  
  # Annotation data -----------------------------------------------------------
  
  # Display data
  zz <- gzfile("www/annotation_file.csv.gz", "rt")
  anno <- read.csv(zz, colClasses = c("character", "character", "factor", 
                                      "integer", "character", "character"))
  
  output$annotation <- DT::renderDataTable(DT::datatable(
    anno,
    colnames = c(
      "Probe name",
      "Probe-variant name",
      "Chromosome",
      "Position",
      "Variant ID",
      "Ensembl ID",
      "Gene symbol"
    ),
    filter = 'top',
    options = list(search = list(regex = TRUE, caseInsensitive = FALSE))
  ))
  
  # Hide the loading message when the rest of the server function has executed
  hide(id = "loading-content", anim = TRUE, animType = "fade")
  
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
  output$anno_filter <- renderTable({
    
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
    validate(
      need(nrow(v$anno_probes) != 0,
           "No value of your filter list match with the annotation data.")
    )
    
    # Return summary table
    summary_table <- v$anno_probes %>% select(Variant, Ensembl, Gene) %>%
      group_by(Gene) %>% 
      summarize(Ensembl = paste(unique(Ensembl), collapse = ", "), 
                Variants = n_distinct(Variant)) %>%
      ungroup()
    return(summary_table)},
    striped = TRUE
  )
  
  # Return not matching filters
  output$not_found <- renderText({ 
    validate(
      need(!is.null(v$filter_list) & nrow(v$anno_probes) != 0,
           "Upload a valid filter file to start.")
    )
    
    not_found <- setdiff(v$filter_list,
                         v$anno_probes[[input$filter_type]])
    return(paste("Following", input$filter_type, 
                 "IDs were not found in annotation dataset:",
                 paste(not_found, collapse = ', ')))
  })
  
  # Filter PED ----------------------------------------------------------------
  
  # Read MAP
  observeEvent(input$goButton, {
    v$map <- input$map$datapath
    v$ped <- input$ped$datapath
  })
  
  # Print MAP info
  output$map_info <- renderText({
    # Ensure that values are available
    validate(
      need(!is.null(v$map), "Upload a MAP file.") %then%
        need(!is.null(v$filter_list) & nrow(v$anno_probes) != 0,
             "Upload a valid filter file.")
    )
    
    tryCatch(
      {
        v$map <- read.table(input$map$datapath, sep = "\t", as.is = TRUE)
      },
      error = function(e) {
        stop(safeError(e))
      }
    )
    validate(
      need(ncol(v$map) == 4, "MAP file must contain 4 columns. Try again.")
    )
    
    anno_probes_unique <- v$anno_probes %>% 
      group_by(IlmnID, Name, Chr, MapInfo, Variant) %>% 
      summarize(Ensembl = paste(unique(Ensembl), collapse = "|"), 
                Gene = paste(unique(Gene), collapse = "|")) %>%
      ungroup()
    
    # Filter
    map_extended <- v$map %>% 
      left_join(anno_probes_unique, by = c("V2" = "Name"))
    validate(
      need(nrow(map_extended) != 0,
           "MAP probes does not correspond with annotation data probes.")
    )
    
    # Generate new map
    v$new_map <- map_extended %>%
      transmute(V1 = V1, V2 = Variant, V3 = V3, V4 = V4) %>%
      filter(!is.na(V2))
    
    # Get index of filter variants
    v$index <- which(!is.na(map_extended[["Variant"]]))
    
    # New annotation
    v$anno_new <- map_extended %>% 
      select(-V1, -V2, -V3, -V4) %>%
      filter(!is.na(Variant))
    
    paste("Original MAP file had", nrow(v$map), 
          "variants. New MAP file has", nrow(v$new_map), "variants.")
  })
  
  # Read PED
  output$ped_info <- renderText({
    # Ensure that values are available
    validate(
      need(!is.null(v$ped), "Upload a PED file.") %then%
        need(!is.null(v$index), "Upload valid MAP and filter files.")
    )
    # Ensure that number of columns coincide with MAP
    n_col <- count.fields(input$ped$datapath, sep = "\t")
    validate(
      need(min(n_col) == max(n_col),
           "Your PED file has different number of rows per sample.") %then%
        need(6 + (nrow(v$map)*2) == min(n_col),
             "Your PED file and your MAP file does not coincide in number of features.")
    )
    
    # Define columns to read
    col <- sort(c(v$index*2 - 1, v$index*2) + 6)
    col <- c(1:6, col)
    
    tryCatch(
      {
        v$ped <- data.table::fread(input$ped$datapath, sep = "\t", 
                                   select = col, colClasses = "character",
                                   verbose = TRUE, data.table = FALSE)
      },
      error = function(e) {
        stop(safeError(e))
      }
    )
    
    paste("PED file was successfully filtered.
          PED file has", nrow(v$ped), "samples:")
  })
  
  # Print PED table
  output$ped_table <- renderTable({
    req(is.data.frame(v$ped))
    sum_ped <- v$ped %>%
      transmute("Family ID" = V1, "Sample ID" = V2, "Paternal ID" = V3,
                "Maternal ID" = V4, "Sex" = V5, "Affection" = V6)
    return(sum_ped)}, 
    striped = TRUE
  )
  
  # Download files ----------------------------------------------------------------
  
  # New MAP
  output$download_map <-
    downloadHandler(
      filename = input$map$name,
      content = function(file) {
        write.table(v$new_map, file, sep = "\t", col.names = FALSE, 
                    row.names = FALSE, quote = FALSE)
      }
    )
  
  # New Annotation
  output$download_anno_new <-
    downloadHandler(
      filename = function() {
        paste("annotation_file_", tools::file_path_sans_ext(input$map$name), 
              ".csv", sep = "")
      },
      content = function(file) {
        write.csv(v$anno_new, file, row.names = FALSE, quote = FALSE, na = "")
      }
    )
  
  # New PED
  output$download_ped <-
    downloadHandler(
      filename = input$ped$name,
      content = function(file) {
        write.table(v$ped, file, sep = "\t", col.names = FALSE, 
                    row.names = FALSE, quote = FALSE)
      }
    )
  
  # Report
  output$report <- 
    downloadHandler(
      filename = paste("filtpeds-report-", Sys.Date(), ".html", sep = ""),
      content = function(file) {
        # Copy the report file to a temporary directory before processing it
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.copy("www/report.Rmd", tempReport, overwrite = TRUE)
        
        # Set up parameters to pass to Rmd document
        params <- list(type = input$filter_type,
                       probes = v$anno_probes,
                       list = v$filter_list,
                       m1 = v$map,
                       m2 = v$new_map,
                       p = v$ped)
        
        # Knit the document
        rmarkdown::render(tempReport, output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv())
        )
      }
  )
})
