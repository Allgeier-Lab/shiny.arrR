helper_mdlrn <- function(input, r) { 
  
  # grab dimensions and grain from string input
  dim_int <- as.integer(stringr::str_split(input$dimensions, pattern = ",", simplify = TRUE))
  grain_int <- as.integer(stringr::str_split(input$grain, pattern = ",", simplify = TRUE))
  
  # import parameters and starting values from provided files
  starting_values <- arrR::read_parameters(file = input$starting$datapath)
  parameters <- arrR::read_parameters(file = input$parameter$datapath)
  
  # calculate all iteration/time related arguments
  max_i <- (60 * 24 * input$days) / input$min_per_i
  
  seagrass_each <- (24 / (input$min_per_i / 60)) * input$seagrass_each
  
  save_each <- (24 / (input$min_per_i / 60)) * input$save_each
  
  # check if reef needs to be created from input string
  if (input$reef_x %in% c("NA", "NULL") || input$reef_y %in% c("NA", "NULL")) {
    
    reef_matrix <- NULL
    
  } else {
    
    reef_x <- as.integer(stringr::str_split(input$reef_x, pattern = ",", simplify = TRUE))
    reef_y <- as.integer(stringr::str_split(input$reef_y, pattern = ",", simplify = TRUE))
    
    reef_matrix <- matrix(data = c(reef_x, reef_y), ncol = 2, byrow = FALSE)
    
  }
  
  # setup seafloor
  input_seafloor <- arrR::setup_seafloor(dimensions = dim_int, grain = grain_int,
                                         reef = reef_matrix, starting_values = starting_values,
                                         random = input$random, verbose = FALSE)
  
  # setup fishpop
  input_fishpop <- arrR::setup_fishpop(seafloor = input_seafloor, starting_values = starting_values, 
                                       parameters = parameters, verbose = FALSE)
  
  # run model
  r$data <- arrR::run_simulation(seafloor = input_seafloor, fishpop = input_fishpop,
                                 movement = input$movement, parameters = parameters,
                                 max_i = max_i, min_per_i = input$min_per_i, seagrass_each = seagrass_each,
                                 save_each = save_each, verbose = FALSE)
  
  return(r)
}
