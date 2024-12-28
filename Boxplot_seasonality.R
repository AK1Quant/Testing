model_input <- data.frame(
  period = c(201501, 201502, 201503, 201504, 201505, 201506),
  Y = c(10, 15, 12, 11, 14, 13),        # Dependent variable
  X1 = c(5, 6, 5, 6, 7, 6),             # Independent variable 1
  X2 = c(3, 4, 3, 4, 3, 5)              # Independent variable 2
)

generate_boxplots <- function(data, dependent_var, independent_vars, period_col = "period") {
  # Load required libraries
  library(ggplot2)
  library(dplyr)
  
  # Ensure the period column is in the correct format
  if (!all(nchar(data[[period_col]]) == 6)) {
    stop("Ensure the period column is in the YYYYMM format")
  }
  
  # Extract the month as a factor
  data <- data %>%
    mutate(Month = factor(substr(as.character(!!sym(period_col)), 5, 6),
                          levels = sprintf("%02d", 1:12),
                          labels = c("JAN", "FEB", "MAR", "APR", "MAY", "JUN", 
                                     "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")))
  
  # Calculate residuals (Assuming a linear model for simplicity)
  model <- lm(reformulate(independent_vars, dependent_var), data = data)
  data$Residuals <- residuals(model)
  
  # Combine variables of interest for plotting
  plot_vars <- c(dependent_var, "Residuals", independent_vars)
  
  # Create boxplots for each variable grouped by Month
  for (var in plot_vars) {
    p <- ggplot(data, aes(x = Month, y = !!sym(var))) +
      geom_boxplot(fill = "skyblue", color = "darkblue", alpha = 0.7) +
      labs(title = paste("Boxplot of", var), x = "Month", y = var) +
      theme_minimal()
    
    print(p)
  }
}

# Example usage:
# Assuming `model_input` is your dataset with `period`, dependent, and independent variables:
# generate_boxplots(model_input, dependent_var = "Y", independent_vars = c("X1", "X2"), period_col = "period")

generate_boxplots(
  data = model_input,
  dependent_var = "Y",
  independent_vars = c("X1", "X2"),
  period_col = "period"
)
