library(shinythemes)
library(markdown)

shinyUI(navbarPage(theme = shinytheme("flatly"),
           "FiltPEDs Tool",
           
           # Main page -----------------------------------------------------------------
           tabPanel("Home",
                    img(src = "inmegen_logo.png", height = 100, width = 216.5),
                    h1("FiltPEDs Tool", align = "center"),
                    br(), br(), br(),
                    includeMarkdown("www/hometext.md"),
                    br(), br(), br(),
                    p(strong("Mantainer: "), "Sergio Villicaña Muñoz", align = "right"),
                    p(strong("Contact: "), "sergio.artsc@gmail.com", align = "right")
           ),
           
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
                        # Select filter to apply
                        radioButtons("filter_type", "Choose a filter type",
                                     choices = list("Variant ID" = "Variant",
                                                    "Ensembl ID" = "Ensembl",
                                                    "Gene symbol" = "Gene"),
                                     selected = "Variant"),
                        # Input filter
                        fileInput("filter", "Choose a txt/csv filter file (one value per line)",
                                  multiple = FALSE, accept = c(
                                    "text/comma-separated-values,text/plain"))
                      ),
                      
                      mainPanel(
                        h4("Summary table of features"),
                        tableOutput("anno_filter"),
                        textOutput("not_found")
                      )
                    )
           ),
           
           # Filter PED ----------------------------------------------------------------
           tabPanel("Filter PED",
                    
                    # Display name
                    titlePanel("Filter PED"),
                    
                    sidebarLayout(
                      sidebarPanel(
                        # Input MAP
                        fileInput("map", "Choose a MAP File", multiple = FALSE, accept = ".map"),
                        # Input PED
                        fileInput("ped", "Choose a PED File", multiple = FALSE, accept = ".ped"),
                        # Action button
                        actionButton("goButton", "Ready to filter")
                      ),
                      
                      mainPanel(
                        h4("Summary of MAP file"),
                        textOutput("map_info"),
                        br(),
                        h4("Summary of PED file"),
                        textOutput("ped_info"),
                        tableOutput("ped_table")
                      )
                    )
           ),
           
           # Download files ------------------------------------------------------------
           tabPanel("Download files",
                    # New MAP
                    downloadButton(outputId = "download_map",
                                   label = "Download new MAP"),
                    # New Annotation
                    downloadButton(outputId = "download_anno_new",
                                   label = "Download new annotation dataset"),
                    # New PED
                    downloadButton(outputId = "download_ped",
                                   label = "Download new PED")
           )
))