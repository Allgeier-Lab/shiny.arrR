#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#    https://rstudio.github.io/shinythemes/
#

# Check for console printing https://gist.github.com/jcheng5/3830244757f8ca25d4b00ce389ea41b3

library(shiny)
library(shinythemes)

library(arrR)
library(stringr)
library(terra)

#### User interface ####

ui <- fluidPage(theme = shinytheme(theme = "flatly"),
  
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
    
    tabPanel(title = "Import data",
             
      fluidRow(
        
        column(width = 6,
        
          fileInput(inputId = "starting", label = "Starting values (semicolon separated)", accept = ".csv")
        
        ), 
             
        column(width = 6,
               
          fileInput(inputId = "parameter", label = "Parameters (semicolon separated)", accept = ".csv")
             
        ),
      ), 
      
      fluidRow(
        
        column(width = 6,
        
          textInput(inputId = "dimensions", label = "Dimensions", value = "25,25",
                    placeholder = "Enter values separated by a comma..."),
          
          numericInput(inputId = "max_i", label = "Maximum iterations", value = 100, 
                       min = 0, step = 1),
          
          
          numericInput(inputId = "seagrass_each", label = "Run seagrass processes each iteration(s)", value = 1, 
                       min = 0, step = 1),
          
          numericInput(inputId = "random", label = "Random", value = 0.0, 
                       min = 0, max = 1, step = 0.1),
        
        ),
        
        column(width = 6,
               
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
        
        column(width = 12, align = "center",
              
          actionButton(inputId = "run", label = "Run model", icon = icon("running"))
        
        )
      )
    ),
    
    tabPanel(title = "Console Output",

      verbatimTextOutput("console_result")

    ),
    
    tabPanel(title = "Visualise results",

      fluidRow(

        column(width = 6,

          selectInput(inputId = "what", label = "What to plot", choices = c("seafloor", "fishpop"),
                      selected = "seafloor")

        ),

        column(width = 6,

          HTML("<br>"),

          checkboxInput(inputId = "summarize", label = "Summarize results", value = FALSE)

        )
      ),

      fluidRow(
        
        column(width = 12, align = "center",

          plotOutput("plot_result")

        )
      )
    )
  )
)

# Define server logic to plot various variables against mpg ----
server <- function(input, output, session) {
  
  model_run <- eventReactive(input$run, {
    
    # check if files were uploaded
    validate(
      
      need(expr = input$starting, message = "Please select starting values .CSV file."), 
      
      need(expr = input$parameter, message = "Please select parameters .CSV file."),
      
    )
    
    dim_int <- as.integer(stringr::str_split(input$dimensions, pattern = ",", simplify = TRUE))
    
    grain_int <- as.integer(stringr::str_split(input$grain, pattern = ",", simplify = TRUE))
    
    starting_values <- arrR::read_parameters(file = input$starting$datapath)

    parameters <- arrR::read_parameters(file = input$parameter$datapath)

    input_seafloor <- arrR::setup_seafloor(dimensions = dim_int, grain = grain_int,
                                           reef = NULL, starting_values = starting_values,
                                           random = input$random, verbose = TRUE)
    
    input_fishpop <- arrR::setup_fishpop(seafloor = input_seafloor, starting_values = starting_values, 
                                         parameters = parameters, verbose = TRUE)
    
    arrR::run_simulation(seafloor = input_seafloor, fishpop = input_fishpop, 
                         movement = input$movement, parameters = parameters, 
                         max_i = input$max_i, min_per_i = input$min_per_i, seagrass_each = input$seagrass_each,
                         save_each = input$save_each, return_burnin = TRUE, nutrients_input = NULL, 
                         verbose = TRUE)
    
  })

  output$console_result <- renderPrint({
    
    print(model_run())
  
  })
  
  output$plot_result <- renderPlot({
    
    plot(model_run(), what = input$what, summarize = input$summarize)
  
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
