navbarPage(
  "Filter PEDs App",
  
  # View and filter annotation ------------------------------------------------
  tabPanel(
    "Annotation",
    # Display name
    titlePanel("Annotation dataset"),
    
    # Display table
    DT::dataTableOutput("annotation"),
    
    # Download button
    downloadButton(outputId = "download_filtered",
                   label = "Download Filtered Data")
  ),
  
  # Upload MAP, PED & filter --------------------------------------------------
  tabPanel(
    "Upload files",
    # Display name
    titlePanel("Uploading Files"),
    
    # Input MAP
    fileInput( "map", "Choose a MAP File", multiple = FALSE, accept = "tsv"),
    
    # Input MAP
    fileInput("ped", "Choose a PED File", multiple = FALSE, accept = "tsv"),
    
    # Input filter
    fileInput("filter", "Choose a filter file (values separated by commas)",
              multiple = FALSE, accept = "csv"),
    
    # Select filter to apply
    radioButtons("radio", "Choose a filter",
                 choices = list("Variant name" = 1,
                                "Ensembl ID" = 2,
                                "Gene symbol" = 3),
                 selected = 1)
  )
)
