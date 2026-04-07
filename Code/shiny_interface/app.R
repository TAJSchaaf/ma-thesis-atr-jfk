# Install pacman if not installed
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")

# Load required packages
pacman::p_load(
  "here", "tidyverse", "dplyr", "shiny", "bs4Dash", "patchwork", 
  "ggplot2", "scales"
)

# Select file with data
s1 <- read.csv((here::here("Code/shiny_interface/csv_files", "jfk-rif-104-10001-10000-thru-104-10215-10450.csv")), header = TRUE)
s2 <- read.csv((here::here("Code/shiny_interface/csv_files", "jfk-rif-104-10216-10000-thru-124-10032-10499.csv")), header = TRUE)
s3 <- read.csv((here::here("Code/shiny_interface/csv_files", "jfk-rif-124-10034-10000-thru-124-10187-10209.csv")), header = TRUE)
s4 <- read.csv((here::here("Code/shiny_interface/csv_files", "jfk-rif-124-10188-10000-thru-124-10332-10066.csv")), header = TRUE)
s5 <- read.csv((here::here("Code/shiny_interface/csv_files", "jfk-rif-124-10333-10000-thru-180-10025-10499.csv")), header = TRUE)
s6 <- read.csv((here::here("Code/shiny_interface/csv_files", "jfk-rif-180-10027-10000-thru-208-10001-10001.csv")), header = TRUE)

db <- rbind(s1, s2, s3, s4, s5, s6)

simple <- read.csv((here::here("Code/shiny_interface/csv_files", "2025_release.csv")), header = TRUE)

simple$name = substr(simple$name, start=1, stop=15)

make.names(names(db))


# Mutate to factors
db <- db %>%
  mutate(across(c(Document.Type, Originator, Current.Classification, Current.Status), as.factor))

# Add "19" to all 2-digit years, then convert
db$Document.Date <- gsub("/(\\d{2})$", "/19\\1", db$Document.Date)
db$Document.Date <- as.Date(db$Document.Date, format = "%m/%d/%Y")

db$PDF.Link <- paste("https://www.archives.gov/files/research/jfk/releases/2025/0318/", db$Record.Num, ".pdf", sep="")

db <- db[db$Record.Num %in% simple$name, ]

db <- db %>%
  dplyr::select(c(PDF.Link, Record.Num, Originator,  Pages, Current.Classification, Document.Date, Document.Type, To, From, Date.of.Review, Title, Comments))

# Define UI for application
ui <- bs4DashPage(
  # Application title
  title = "JFK Assassination Collection Document Sorter",
  help = NULL, # remove help checkbox
  header = bs4DashNavbar(
    title = "Project 2025 Index Visualiser",
    fixed = TRUE
  ),
  
  sidebar = bs4DashSidebar(
    skin = "light",
    title = "Menu",
    collapsed = FALSE,
    bs4SidebarMenu(
     
       # References Accordion Edition
      bs4SidebarMenuItem(
        "Sort Table", tabName = "edition", icon = icon("table")
      ),
      
      bs4SidebarMenuItem(
        "Visualizations", tabName = "general", icon = icon("chart-bar")
      )
    )
  ),
  
  body = bs4DashBody(
    tags$head(
      tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js"),
      tags$style(HTML("
        body {
          zoom: 1.1; /* Adjust the zoom level to make everything appear larger */
        }
        .content-wrapper {
          padding: 10px; /* Reduce padding if needed */
        }
      "))
    ),
    bs4TabItems(
      
      # Table page
      bs4TabItem(
        tabName = "edition",
        h2("Table"),
        # Create a new Row in the UI for selectInputs
        fluidRow(
          column(3,
                 selectInput("orig",
                             "Originator:",
                             c("All",
                               unique(as.character(db$Originator))))
          ),
          column(3,
                 selectInput("doctype",
                             "Document Type:",
                             c("All",
                               unique(as.character(db$Document.Type))))
          ),
          column(3,
                 selectInput("classi",
                             "Current Classification:",
                             c("All",
                               unique(as.character(db$Current.Classification))))
          )
        ),
        
        downloadButton("download_button", "Download the data .csv"),

        # Create a new row for the table
        DT::dataTableOutput("table"),
        plotOutput("distPlotLactul")
      ),
      # Main Page
      bs4TabItem(
        tabName = "general",
        h2("Project 2025 Index Visualiser")
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Step 1: Your normal filters
  filtered_data <- reactive({
    data <- db
    
    if (input$orig != "All") {
      data <- data[data$Originator == input$orig, ]
    }
    if (input$doctype != "All") {
      data <- data[data$Document.Type == input$doctype, ]
    }
    if (input$classi != "All") {
      data <- data[data$Current.Classification == input$classi, ]
    }
    
    # Convert URLs to clickable HTML
    data$PDF.Link <- paste0('<a href="', data$PDF.Link, '" target="_blank">View PDF</a>')
    data
  })
  
  
  # Step 2: Render DT with server-side processing turned on
  output$table <- DT::renderDataTable({
    DT::datatable(
      filtered_data(),
      escape = FALSE
    )
  })
  
  
  # Step 3: Download button obeys both your filters AND DT search
  output$download_button <- downloadHandler(
    filename = function() {
      "record_subset.csv"
    },
    content = function(file) {
      
      # Start with your filtered dataset
      data_to_export <- filtered_data()
      
      # If DT search has filtered further, apply that too
      if (!is.null(input$table_rows_all)) {
        data_to_export <- data_to_export[input$table_rows_all, ]
      }
      
      write.csv(data_to_export, file, row.names = FALSE)
    }
  )
}



# Run the application 
shinyApp(ui = ui, server = server)