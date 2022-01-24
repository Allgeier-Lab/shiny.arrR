#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(waiter)

library(arrR)
library(stringr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  r <- reactiveValues(data = NULL, plot = NULL)
  
  observeEvent(input$run, {
    
    showNotification(ui = "Starting simulation", type = "message")

    waiter <- waiter::Waiter$new(id = "run")
    waiter$show()
    on.exit(waiter$hide())
    
    dim_int <- as.integer(stringr::str_split(input$dimensions, pattern = ",", simplify = TRUE))
    grain_int <- as.integer(stringr::str_split(input$grain, pattern = ",", simplify = TRUE))
    
    starting_values <- arrR::read_parameters(file = input$starting$datapath)
    parameters <- arrR::read_parameters(file = input$parameter$datapath)
    
    if (input$reef_x %in% c("NA", "NULL") || input$reef_y %in% c("NA", "NULL")) {
      
      reef_matrix <- NULL
      
    } else {
    
      reef_x <- as.integer(stringr::str_split(input$reef_x, pattern = ",", simplify = TRUE))
      reef_y <- as.integer(stringr::str_split(input$reef_y, pattern = ",", simplify = TRUE))
      
      reef_matrix <- matrix(data = c(reef_x, reef_y), ncol = 2, byrow = FALSE)
      
    }
    
    input_seafloor <- arrR::setup_seafloor(dimensions = dim_int, grain = grain_int,
                                           reef = reef_matrix, starting_values = starting_values,
                                           random = input$random, verbose = FALSE)
    
    input_fishpop <- arrR::setup_fishpop(seafloor = input_seafloor, starting_values = starting_values, 
                                         parameters = parameters, verbose = FALSE)
    
    r$data <- arrR::run_simulation(seafloor = input_seafloor, fishpop = input_fishpop,
                                   movement = input$movement, parameters = parameters,
                                   max_i = input$max_i, min_per_i = input$min_per_i, seagrass_each = input$seagrass_each,
                                   save_each = input$save_each, return_burnin = TRUE, nutrients_input = NULL,
                                   verbose = FALSE)
    
    showNotification(ui = "Finishing simulation", type = "message")
    
  })
  
  observeEvent(input$plot, { 
    
    if (is.null(r$data)) {
      showNotification(ui = "Run model first", type = "error")
      return()
    }
    
    showNotification(ui = "Plotting result", type = "message")
    
    waiter <- waiter::Waiter$new(id = "plot")
    waiter$show()
    on.exit(waiter$hide())
    
    r$plot <- plot(r$data, what = input$what, summarize = input$summarize)
    
  })
  
  output$console_result <- renderPrint({
    
    # check if files were uploaded
    validate(
      need(expr = input$starting, message = "Please select 'Starting values' .csv file.\n"),
      need(expr = input$parameter, message = "Please select 'Parameters' .csv file."),
    )
    
    if (is.null(r$data)) {return("Please click 'Run model'!")}
    print(r$data)
    
  })
  
  output$plot_result <- renderPlot({r$plot}, res = 96)
  
  output$download <- downloadHandler(

    filename = function() {paste0("mdl-rn_", Sys.Date(), ".rds")},

    content = function(file) {
      if (is.null(r$data)) showNotification(ui = "Run model first", type = "error")
      saveRDS(r$data, file)
    })
})
