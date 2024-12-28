# Example dataset (replace with your actual data)
period <- c(201501, 201502, 201503, 201504, 201505, 201506,
            201601, 201602, 201603, 201604, 201605, 201606)
dependent_var <- c(10, 15, 20, 25, 30, 35, 12, 18, 22, 28, 32, 37)  # Dependent variable
independent_var1 <- c(5, 8, 7, 12, 15, 18, 6, 9, 10, 13, 16, 20)   # Independent variable 1
independent_var2 <- c(2, 3, 4, 5, 6, 7, 2, 3, 4, 5, 6, 7)          # Independent variable 2
residuals <- c(1, -1, 0.5, -0.5, 1.2, -1.2, 0.8, -0.8, 0.4, -0.4, 1.5, -1.5) # Residuals

# Create a data frame
data <- data.frame(
  Period = period,
  Dependent = dependent_var,
  Independent1 = independent_var1,
  Independent2 = independent_var2,
  Residuals = residuals
)

# Automatically detect independent variables
independent_variables <- setdiff(names(data), c("Period", "Dependent", "Year", "Month", "Quarter", "MonthName", "QuarterName"))

# Check if data is monthly or quarterly based on Period (YYYYMM format)
is_monthly <- max(as.numeric(substr(data$Period, 5, 6))) <= 12

if (is_monthly) {
  # Extract year and month
  data$Year <- as.numeric(substr(data$Period, 1, 4))
  data$Month <- as.numeric(substr(data$Period, 5, 6))
  data$MonthName <- factor(format(as.Date(paste0("2000-", data$Month, "-01")), "%b"), 
                           levels = month.abb)  # Ensure correct month order
} else {
  # Extract year and quarter
  data$Year <- as.numeric(substr(data$Period, 1, 4))
  data$Quarter <- ceiling(as.numeric(substr(data$Period, 5, 6)) / 3)
  data$QuarterName <- factor(data$Quarter, labels = c("Q1", "Q2", "Q3", "Q4"))
}

# Plotting function for boxplots
library(ggplot2)
library(reshape2)

plot_boxplot <- function(group_col, title_suffix) {
  # Reshape data for plotting
  melted_data <- melt(data, id.vars = group_col, 
                      measure.vars = c("Dependent", independent_variables, "Residuals"))
  
  ggplot(melted_data, aes_string(x = group_col, y = "value", fill = "variable")) +
    geom_boxplot() +
    facet_wrap(~variable, scales = "free_y") +
    labs(title = paste("Boxplots by", title_suffix),
         x = title_suffix,
         y = "Value") +
    theme_minimal()
}

# Generate boxplots
if (is_monthly) {
  print(plot_boxplot("MonthName", "Month"))
} else {
  print(plot_boxplot("QuarterName", "Quarter"))
}

