#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(shinyjs)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinythemes::shinytheme(theme = "flatly"),
  
  shinyjs::useShinyjs(),    
  
  # titlePanel(h3("Artifical Reefs in R", align = "center")), 
            
  HTML("<center><img src='logo.png' width='100'></center>"),
            
  tabsetPanel(
              
    tabPanel(title = "General background", 
             
      column(width = 12, align = "left",
        
        h3("Overview"),  
                              
        HTML("To get a BibTex entry, please use <span style='font-family:courier;'>citation('arrR')</span>. 
             For more information, please see <a href='https://allgeier-lab.github.io/arrR'>https://allgeier-lab.github.io/arrR</a>.<br><br>
             
             The goal of <i>arrR</i> is to simulate seagrass primary production around 
             artificial reefs (ARs) using an individual-based simulation model 
             (IBM, DeAngelis and Grimm, 2014). The grid-based simulation environment 
             (also referred to as seafloor) is populated by fish individuals all belonging 
             to the same species. <br><br>
             
             Seagrass primary production is simulated using a single-nutrient primary 
             of nutrients by fish individuals follows principles of bioenergetics 
             production model adapted from DeAngelis (1992). Consumption and excretion 
             (Schreck and Moyle, 1990). <br><br>
             
             <center><img src='concept.png' width='650'></center>"),
             
             h4("References"),
             
             HTML("DeAngelis, D.L., 1992. Dynamics of Nutrient Cycling and Food Webs. Springer 
             Netherlands, Dordrecht. <https://doi.org/10.1007/978-94-011-2342-6><br> 
             
             DeAngelis, D.L., Grimm, V., 2014. Individual-based models in ecology after 
             four decades. F1000Prime Reports 6, 1–6. <https://doi.org/10.12703/P6-39><br>
             
             Schreck, C.B., Moyle, P.B. (Eds.), 1990. Methods for fish biology. 
             American Fisheries Society, Bethesda, MD, USA.")
             
      )
    ),
             
    tabPanel(title = "Run model",
                      
      fluidRow(
                        
        column(width = 6, align = "left",
                               
          HTML("<br>"),
                               
          fileInput(inputId = "starting", label = "Starting values (semicolon separated)", accept = ".csv"),
                               
          HTML("<br><br>"),
          
          textInput(inputId = "dimensions", label = "Dimensions", value = "25,25",
                    placeholder = "Enter values separated by a comma..."),
          
          numericInput(inputId = "max_i", label = "Maximum iterations", value = 100, 
                       min = 0, step = 1),
          
          numericInput(inputId = "seagrass_each", label = "Run seagrass processes each iteration(s)", value = 1, 
                       min = 0, step = 1),
          
          numericInput(inputId = "random", label = "Random", value = 0.0, 
                       min = 0, max = 1, step = 0.1),
                               
        ),
                        
        column(width = 6, align = "left",
                               
          HTML("<br>"),  
                               
          fileInput(inputId = "parameter", label = "Parameters (semicolon separated)", accept = ".csv"),
          
          HTML("<br><br>"),     
          
          textInput(inputId = "grain", label = "Grain", value = "1,1",
                    placeholder = "Enter values separated by a comma..."), 
          
          numericInput(inputId = "min_per_i", label = "Minutes per iteration", value = 120, 
                       min = 0, step = 5),
          
          numericInput(inputId = "save_each", label = "Save results each iteration(s)", value = 1, 
                       min = 0, step = 1),
          
          selectInput(inputId = "movement", label = "Movement", choices = c("rand", "attr"), 
                      selected = "rand")
                               
        )
      ), 
                      
      # adding some white space
      HTML("<br><br>"),
                        
      fluidRow(
                          
        column(width = 2, align = "left",
                                 
          actionButton(inputId = "run", label = "Run model", icon = icon("running")), 
          
          HTML("<br><br>"),
          
          downloadButton("download", "Download results")
                                 
        ),
                          
        column(width = 4, align = "center",
                                 
          verbatimTextOutput("progress")
                                 
        ),
                          
        column(width = 6, align = "left",
                                 
          verbatimTextOutput("console_result")
                                 
        )
      )
    ),
             
    tabPanel(title = "Visualise results",
                      
      column(width = 2, align = "center",
                             
        selectInput(inputId = "what", label = "What to plot", choices = c("seafloor", "fishpop"),
                    selected = "seafloor"), 
                             
        checkboxInput(inputId = "summarize", label = "Summarize results", value = FALSE)
                             
      ), 
                      
      column(width = 10, align = "center",
                             
        plotOutput("plot_result")
                             
      )
    )
  )
))
