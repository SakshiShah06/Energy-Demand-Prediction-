library(shiny)
install.packages("tidyverse")
library(tidyverse)

model3 <- lm(log(total_energy_consumption) ~ ., data = train %>% select(-in.county))

# Define UI
ui <- fluidPage(
  titlePanel("Dataset Viewer & Predictor"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload your dataset (CSV format):", accept = c(".csv")),
      numericInput("nrows", "Number of rows to display:", value = 5, min = 1),
      actionButton("load_data", "Load Data"),
      actionButton("predict", "Generate Predictions")
    ),
    mainPanel(
      h3("Uploaded Dataset"),
      tableOutput("table"),        # Displays the first `n` rows of the dataset
      h3("Dataset with Predictions"),
      tableOutput("predictions")  # Displays the dataset with predictions
    )
  )
)

# Define Server
server <- function(input, output) {
  # Reactive expression to load and preprocess the uploaded dataset
  data <- reactive({
    req(input$file)  # Ensure a file is uploaded
    tryCatch({
      # Read the uploaded CSV file
      df <- read.csv(input$file$datapath)
      if (nrow(df) == 0 || ncol(df) == 0) {
        stop("The file is empty or improperly formatted.")
      }
      
      # Preprocess: Ensure the necessary columns exist
      required_columns <- c("month", "time", "in.sqft", "in.occupants", "in.bedrooms", 
                            "temp", "hum",
                            "in.cooling_setpoint", "in.heating_setpoint")
      if (!all(required_columns %in% colnames(df))) {
        stop("Dataset is missing required columns for prediction: ",
             paste(setdiff(required_columns, colnames(df)), collapse = ", "))
      }
       
      # Preprocessing: Convert cooling/heating setpoints to numeric and remove missing data
      df$in.cooling_setpoint <- as.numeric(gsub("[^0-9]", "", df$in.cooling_setpoint))
      df$in.heating_setpoint <- as.numeric(gsub("[^0-9]", "", df$in.heating_setpoint))
      df <- df %>% dplyr::mutate(
        in.occupants = as.numeric(gsub("[^0-9]", "", in.occupants))
      ) %>% tidyr::drop_na()
      df$time <- as.factor(df$time)
      
      # Return preprocessed dataset
      df
    }, error = function(e) {
      showNotification(as.character(e), type = "error")
      NULL
    })
  })
  
  # Reactive expression to generate predictions using model3
  predictions <- reactive({
    req(data())  # Ensure data is available
    tryCatch({
      df <- data()
      
      # Ensure predictors match model3
      predictors <- c("month", "time", "in.sqft", "in.occupants", "in.bedrooms", 
                      "temp", "hum", "in.county",
                      "in.cooling_setpoint", "in.heating_setpoint", "bldg_id")
     
      
      df <- df %>% dplyr::select(all_of(predictors))
      
      # Generate predictions using `model3`
      df$predicted_value <- exp(predict(model3, newdata = df))  
      
      # Return dataset with predictions
      df
    }, error = function(e) {
      showNotification(as.character(e), type = "error")
      NULL
    })
  })
  
  # Observe event to display uploaded data
  observeEvent(input$load_data, {
    if (!is.null(data())) {
      output$table <- renderTable({
        head(data(), n = input$nrows)
      })
    } else {
      showNotification("No data to display. Please upload a valid file.", type = "warning")
    }
  })
  
  # Observe event to display dataset with predictions
  observeEvent(input$predict, {
    if (!is.null(predictions())) {
      output$predictions <- renderTable({
        predictions()
      })
    } else {
      showNotification("Unable to generate predictions. Please ensure the file is valid.", type = "error")
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)
