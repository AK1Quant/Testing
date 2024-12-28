# Load necessary libraries
library(ggplot2)
library(dplyr)

# Example model data
model_data <- data.frame(
  Period = c(201501, 201502, 201503, 201504, 201505, 201506),
  DependentVariable = c(100, 120, 110, 130, 125, 135),
  IndependentVariable1 = c(50, 55, 53, 57, 54, 56),
  IndependentVariable2 = c(75, 80, 78, 82, 79, 81)
)

# Convert Period to Date type for easier slicing
model_data <- model_data %>%
  mutate(
    YearMonth = as.Date(paste0(Period, "01"), format = "%Y%m%d"),
    Month = format(YearMonth, "%m"),
    Quarter = paste0("Q", ceiling(as.numeric(Month) / 3))
  )

# Melt data for easier plotting
library(reshape2)
melted_data <- melt(
  model_data,
  id.vars = c("YearMonth", "Month", "Quarter"),
  variable.name = "Variable",
  value.name = "Value"
)

# Box Plot: Month-wise
ggplot(melted_data, aes(x = Month, y = Value, fill = Variable)) +
  geom_boxplot() +
  facet_wrap(~Variable, scales = "free_y") +
  labs(
    title = "Month-wise Box Plot for Seasonality",
    x = "Month",
    y = "Value"
  ) +
  theme_minimal()

# Box Plot: Quarter-wise
ggplot(melted_data, aes(x = Quarter, y = Value, fill = Variable)) +
  geom_boxplot() +
  facet_wrap(~Variable, scales = "free_y") +
  labs(
    title = "Quarter-wise Box Plot for Seasonality",
    x = "Quarter",
    y = "Value"
  ) +
  theme_minimal()
