# Load necessary library
library(fUnitRoots)

# Example data (replace with your actual data)
set.seed(123)
variables <- list(
  Residuals = rnorm(100),
  DependentVariable = rnorm(100),
  IndependentVariable1 = rnorm(100),
  IndependentVariable2 = rnorm(100)
)

# Initialize an empty data frame to store results
adf_results <- data.frame(
  Variable = character(),
  Type = character(),
  Lag = integer(),
  TestStatistic = numeric(),
  PValue = numeric(),
  Result = character(),
  stringsAsFactors = FALSE
)

# ADF test types
test_types <- c("c", "nc", "ct")  # "c" = constant, "nc" = no constant, "ct" = constant + trend

# Perform ADF test for all variables, types, and lags
for (variable_name in names(variables)) {
  variable_data <- variables[[variable_name]]
  
  for (test_type in test_types) {
    for (lag in 0:12) { # Adjust lags as needed
      adf_result <- adfTest(variable_data, lags = lag, type = test_type)
      p_value <- adf_result@test$p.value
      test_statistic <- adf_result@test$statistic
      
      # Make the decision based on the p-value
      decision <- ifelse(p_value < 0.05, "PASS", "FAIL")
      
      # Append results to the data frame
      adf_results <- rbind(adf_results, data.frame(
        Variable = variable_name,
        Type = test_type,
        Lag = lag,
        TestStatistic = test_statistic,
        PValue = p_value,
        Result = decision
      ))
    }
  }
}

# Print the full results
# cat("ADF Test Results:\n")
# print(adf_results)

# Format the output for easy readability
cat("\nFormatted ADF Test Results:\n")
print(format(adf_results, justify = "left"), row.names = FALSE)

