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
library(waiter)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinythemes::shinytheme(theme = "flatly"),
  
  # titlePanel(h3("Artifical Reefs in R", align = "center")), 
            
  HTML("<center><img src='logo.png' width='100'></center>"),
            
  tabsetPanel(selected = "Run model",
    tabPanel(title = "General background", 
      fluidRow(
        column(width = 12, align = "center", 
        
          HTML("<br><br>"),
          actionButton(inputId = "ref", label = "Show citation", icon = icon("book"))
        
        )
      ),
      
      fluidRow(
      
        column(width = 12, align = "left",
          
          h3("Overview"),  
                                
          HTML("The goal of <b>arrR</b> is to simulate seagrass primary production around 
               artificial reefs (ARs) using an individual-based simulation model 
               (IBM, DeAngelis and Grimm, 2014). The grid-based simulation environment 
               (also referred to as seafloor) is populated by fish individuals, currently all belonging 
               to the same species. Seagrass primary production is simulated using a single-nutrient primary production 
               model adapted from DeAngelis (1992). Consumption and excretion of nutrients 
               by fish individuals follows principles of bioenergetics (Schreck and Moyle, 1990). <br><br>
               
               For more information, please see <a href='https://allgeier-lab.github.io/arrR'> https://allgeier-lab.github.io/arrR</a>.
               
               <center><figure>
               <img src='concept.png' width='650' caption='xxx'>
               <figcaption>Schematic overview of model concept (Adapted from DeAngelis 1992).</figcaption>
               </figure></center>"),
          
          h4("References"),
               
          HTML("DeAngelis, D.L., 1992. Dynamics of Nutrient Cycling and Food Webs. Springer 
               Netherlands, Dordrecht. <https://doi.org/10.1007/978-94-011-2342-6><br> 
               
               DeAngelis, D.L., Grimm, V., 2014. Individual-based models in ecology after 
               four decades. F1000Prime Reports 6, 1–6. <https://doi.org/10.12703/P6-39><br>
               
               Schreck, C.B., Moyle, P.B. (Eds.), 1990. Methods for fish biology. 
              American Fisheries Society, Bethesda, MD, USA.")
               
        )
      )
    ),
             
    tabPanel(title = "Run model",
      fluidRow(
        column(width = 12, align = "center", 
      
          HTML("<br><p style='border:5px; border-style:solid; border-color:#B1E1F1; 
               padding: 0.5em;'>Please type <span style='font-family:courier;'>?setup_seafloor()</span>, 
               <span style='font-family:courier;'>?setup_fishpop()</span>, or 
               <span style='font-family:courier;'>?run_simulation()</span> in your 
               <span style='font-family:courier;'>R</span> console for help.</p>")
              
        )
      ),       
             
      fluidRow(
        column(width = 3, align = "left",
          HTML("<br>"),
                                 
          fileInput(inputId = "starting", label = "Starting values (semicolon separated)", 
                    accept = ".csv"),
                               
          textInput(inputId = "dimensions", label = "Dimensions", value = "25,25",
                    placeholder = "Enter values separated by a comma..."),
          
          textInput(inputId = "reef_x", label = "AR x coords", value = "-1,0,1,0,0",
                    placeholder = "Enter values separated by a comma..."),
          
          # MH: Rename in days and internally calculate to iterations?
          
          numericInput(inputId = "days", label = "Total simulation time (Days)", value = 30, 
                       min = 0, step = 1),
          
          numericInput(inputId = "seagrass_each", label = "Simulate seagrass processes each day(s)", value = 1, 
                       min = 0, step = 1),
          
          numericInput(inputId = "random", label = "Stochasticity starting values", value = 0.0, 
                       min = 0, max = 1, step = 0.1),
                                 
          ),
                          
        column(width = 3, align = "left",
          HTML("<br>"),  
                                 
          fileInput(inputId = "parameter", label = "Parameters (semicolon separated)", 
                    accept = ".csv"),
          
          textInput(inputId = "grain", label = "Grain", value = "1,1",
                    placeholder = "Enter values separated by a comma..."), 
          
          textInput(inputId = "reef_y", label = "AR y coords", value = "0,1,0,-1,0",
                    placeholder = "Enter values separated by a comma..."),
          
          numericInput(inputId = "min_per_i", label = "Minutes per iteration", value = 120, 
                       min = 0, step = 5),
          
          numericInput(inputId = "save_each", label = "Save results each day(s)", value = 1, 
                       min = 0, step = 1),
          
          selectInput(inputId = "movement", label = "Movement", choices = c("rand", "attr"), 
                      selected = "rand")
                                 
        ),
          
        column(width = 6, align = "left", 
          HTML("<br><br>"),

          verbatimTextOutput("console_result")  
            
        )
      ), 
    
      fluidRow(
        column(width = 6, align = "right",
          HTML("<br><br>"),  
          waiter::use_waiter(),
          
          actionButton(inputId = "run", label = "Run model", icon = icon("running"))
        
        ), 
        
        column(width = 6, align = "left",
               
          HTML("<br><br>"),
               
          downloadButton("download", "Download results"), 
        
        )
      )
    ),
             
    tabPanel(title = "Visualise results",
      column(width = 2, align = "center",
                             
        selectInput(inputId = "what", label = "What to plot", choices = c("seafloor", "fishpop"),
                    selected = "seafloor"), 
                             
        checkboxInput(inputId = "summarize", label = "Summarize results", value = FALSE), 
        
        HTML("<br><br>"),
        
        actionButton(inputId = "plot", label = "Plot results", icon = icon("brush"))
                             
      ), 
                      
      column(width = 10, align = "center",
                             
        plotOutput("plot_result")
                             
      )
    )
  )
))
