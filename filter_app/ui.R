navbarPage(
  "Filter PEDs App",
  
  # View and filter annotation ------------------------------------------------
  tabPanel("Annotation",
           
           # Display name
           titlePanel("Annotation dataset"),
           
           # Display table
           DT::dataTableOutput("annotation"),
           
           # Download button
           downloadButton(outputId = "download_filtered",
                          label = "Download Filtered Data")
  ),
  
  # Upload filter data --------------------------------------------------------
  tabPanel("Select filters",
           
           # Display name
           titlePanel("Select filters"),
           
           sidebarLayout(
             sidebarPanel(
               # Input filter
               fileInput("filter", "Choose a txt/csv filter file (one value per line)",
                         multiple = FALSE, accept = c(
                           "text/comma-separated-values,text/plain")),
               
               # Select filter to apply
               radioButtons("filter_type", "Choose a filter",
                            choices = list("Variant name" = "Variant",
                                           "Ensembl ID" = "Ensembl",
                                           "Gene symbol" = "Gene"),
                            selected = "Variant")
             ),
             
             mainPanel(
               h4(paste("Summary table of features")),
               tableOutput("anno_filter"),
               textOutput("not_found")
             )
           )
  ),
  
  # Filter PED ----------------------------------------------------------------
  tabPanel("Filter PED",
           
           # Input MAP
           fileInput("map", "Choose a MAP File", multiple = FALSE, accept = ".map"),
           # Input PED
           fileInput("ped", "Choose a PED File", multiple = FALSE, accept = ".ped"),
           tableOutput("contents")
  )
)