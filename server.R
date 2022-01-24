#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

library(arrR)
library(stringr)
# library(terra)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  model_run <- eventReactive(input$run, {
    
    # check if files were uploaded
    validate(
      
      need(expr = input$starting, message = "Please select starting values .CSV file."), 
      
      need(expr = input$parameter, message = "Please select parameters .CSV file."),
      
    )
    
    withCallingHandlers(expr = {
      
      shinyjs::html("progress", "")
      
      message("...Starting the simulation at <", Sys.time(), ">... \n\n ...Please be patient... \n")
      
      dim_int <- as.integer(stringr::str_split(input$dimensions, pattern = ",", simplify = TRUE))
      
      grain_int <- as.integer(stringr::str_split(input$grain, pattern = ",", simplify = TRUE))
      
      starting_values <- arrR::read_parameters(file = input$starting$datapath)
      
      parameters <- arrR::read_parameters(file = input$parameter$datapath)
      
      input_seafloor <- arrR::setup_seafloor(dimensions = dim_int, grain = grain_int,
                                             reef = NULL, starting_values = starting_values,
                                             random = input$random, verbose = FALSE)
      
      input_fishpop <- arrR::setup_fishpop(seafloor = input_seafloor, starting_values = starting_values, 
                                           parameters = parameters, verbose = FALSE)
      
      result_temp <- arrR::run_simulation(seafloor = input_seafloor, fishpop = input_fishpop,
                                          movement = input$movement, parameters = parameters,
                                          max_i = input$max_i, min_per_i = input$min_per_i, seagrass_each = input$seagrass_each,
                                          save_each = input$save_each, return_burnin = TRUE, nutrients_input = NULL,
                                          verbose = FALSE)
      
      message("...Finishing the simulation at <", Sys.time(), ">...")
      
      return(result_temp)
      
    }, message = function(m) {shinyjs::html(id = "progress", html = m$message, add = TRUE)})
  })
  
  output$console_result <- renderPrint({
    
    print(model_run())
    
  })
  
  output$plot_result <- renderPlot({
    
    plot(model_run(), what = input$what, summarize = input$summarize)
    
  })
  
  output$download <- downloadHandler(
    
    filename = function() {paste0("mdl-rn_", Sys.Date(), ".rds")},

    content = function(file) {saveRDS(model_run(), file)})
  
})
