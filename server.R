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
  
  observeEvent(input$ref, {
    showModal(ui = modalDialog("Esquivel, K.E., Hesselbarth, M.H.K., Allgeier, J.E. 
                               Mechanistic support for increased primary production around 
                               artificial reefs. In press. Ecological Applications",
                               title = "Citation information", size = "l",
                               footer = modalButton("Close"), easyClose = TRUE))})
  
  r <- reactiveValues(data = NULL, plot = NULL)
  
  observeEvent(input$run, {
  
    if (is.null(input$starting) || is.null(input$parameter)) {
      
      showNotification(ui = "Please provide .csv files", type = "error")
      
    } else {
      
      tryCatch(expr = {
    
        showNotification(ui = paste0("<", format(Sys.time(), "%X"), "> ...Starting..."), 
                         type = "message")
    
        waiter <- waiter::Waiter$new(id = "run")
        waiter$show()
        on.exit(waiter$hide())
        
        helper_mdlrn(input = input, r = r)
        
        showNotification(ui = paste0("<", format(Sys.time(), "%X"), "> ...Finishing..."), 
                         type = "message")
        
      }, error = function(e) {showNotification(ui = paste("Error:", e), type = "error")},
         warning = function(w) {showNotification(ui = paste("Error:", w), type = "error")}
      )
    }
  })
  
  observeEvent(input$plot, { 
    
    if (is.null(r$data)) {
      showNotification(ui = "Run model first", type = "error")
      return(NULL)
    }
    
    showNotification(ui = "Plotting result...", type = "message")
    
    waiter <- waiter::Waiter$new(id = "plot")
    waiter$show()
    on.exit(waiter$hide())
    
    r$plot <- plot(r$data, what = input$what, summarize = input$summarize)
    
    showNotification(ui = "...Result plotted", type = "message")
    
  })
  
  output$console_result <- renderPrint({
    
    if (is.null(r$data)) {return("...No model run simulated yet...")}
    print(r$data)
    
  })
  
  output$plot_result <- renderPlot({r$plot}, res = 96)
  
  output$download <- downloadHandler(

    filename = function() {paste0("mdl-rn_", Sys.Date(), ".rds")},

    content = function(file) {
      if (is.null(r$data)) {showNotification(ui = "Downloading 'NULL'", type = "warning")}
      if (!is.null(r$data)) {showNotification(ui = "Downloading model run", type = "message")}
      saveRDS(r$data, file)
    })
  
})
