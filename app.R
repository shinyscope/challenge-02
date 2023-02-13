library(shiny)
library(tidyverse)

ui <- fluidPage(
  titlePanel("Shiny App"),
  # sidebarPanel("This app lets you upload data, calculate the mean, run analisys and download the data"
  # ),
  
  mainPanel(
    
    #creates different tabs for each step
    tabsetPanel(type = "tab",
                tabPanel("Upload",
                         sidebarPanel(
                           #upload
                           fileInput("upload", "Upload a csv file", accept = c(".csv")),
                           #selecting columns for calculation
                           selectizeInput("cols", "Select Columns:",
                                          choices = '',
                                          multiple = TRUE),
                           #calculate button
                           actionButton("calculate", "Calculate Mean")
                           
                           
                           # verbatimTextOutput("mean") ##this will list means below the "calculate mean" button
                         ),
                         tableOutput("table"),
                         #-----------------Download file-----------------
                         uiOutput("downloadBtn")
                ),
                
                tabPanel("Original Data",
                         tableOutput("data")),
                tabPanel("Analysis")
    )
  )
)

server <- function(input, output, session) {
  
  #uploading a file
  data <- reactive({
    req(input$upload)
    
    ext <- tools::file_ext(input$upload$name)
    switch(ext,
           csv = vroom::vroom(input$upload$datapath, delim = ","),
           validate("Invalid file; Please upload a .csv or .tsv file")
    )
  })
  
  # in second tab you can see the original uploaded data
  output$data <- renderTable({
    if(is.null(input$upload)){
      return("Upload some data first")
    }
    read.table(input$upload$datapath, sep = ",", header = TRUE)
    
  })
  # -----------------Manipulate dataframe---------------------
  modified_data <- reactiveVal(NULL)
  
  #---------- select columns & calculate the mean 
  observe({
    numeric_cols <- colnames(data())[sapply(data(), is.numeric)] #this only selects numeric columns
    updateSelectizeInput(session, "cols", choices =  numeric_cols) # all columns: updateSelectizeInput(session, "cols", choices = colnames(data()))
  })
  
  #it seems to calculate the mean correctly
  
  result <- eventReactive(input$calculate, {
    dataframe <- data()
    columns <- dataframe[,input$cols]
    dataframe$mean <- rowMeans(columns)
    #
    return(dataframe)
  })
  
  # output function look for action in the above function
  #for calculating the mean and return the result
  
  output$table <- renderTable({
    if(is.null(result())){return()}
    result()
  })
  
  #-----------------Download File-----------------
  observeEvent(input$upload, {
    output$downloadBtn <- renderUI({
      downloadButton("downloadData", "Download Data")
    })
  })
  
  # CSV file is named modified_data_YYYY-MM-DD.csv
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("modified_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(result(), file, row.names = FALSE)
    })
  
}

shinyApp(ui, server)