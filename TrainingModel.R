# Load dataset and capture parsing issues
wine_data <- read.csv("data/wines_SPA.csv", colClasses = c(
  winery = "character",
  wine = "character",
  year = "character",
  rating = "numeric",
  num_reviews = "numeric",
  country = "character",
  region = "character",
  type = "factor",
  body = "factor",
  acidity = "factor",
  price = "numeric"
))

# Check for parsing issues
problems(wine_data)

# Display the structure of the dataset
str(wine_data)

# View the first few rows of the dataset
head(wine_data)

# View the dataset in a separate viewer window
View(wine_data)

# Load necessary packages
library(caTools)

# Ensure reproducibility
set.seed(123)

# Create a partition index
split <- sample.split(wine_data_clean$price, SplitRatio = 0.8)

# Split the data into training and testing sets
train_data <- subset(wine_data_clean, split == TRUE)
test_data <- subset(wine_data_clean, split == FALSE)

# Display the structure of the training and testing sets
dim(test_data)
dim(train_data)

# Load necessary packages
library(boot)

# Ensure reproducibility
set.seed(123)

# Function to calculate the statistic of interest
bootstrap_stat <- function(data, indices) {
  sample_data <- data[indices, ]  # Resample with replacement
  return(mean(sample_data$price)) # Calculate the mean of the price variable
}

# Perform bootstrapping
bootstrap_results <- boot(data = wine_data_clean, statistic = bootstrap_stat, R = 1000)

# Summary of bootstrap results
print(bootstrap_results)

# Plot the bootstrap distribution
plot(bootstrap_results)

# Ensure 'type' is a factor
wine_data_clean$type <- as.factor(wine_data_clean$type)

# Load necessary packages
library(caret)

# Split the data into training and testing sets
set.seed(123)  # For reproducibility
train_index <- createDataPartition(wine_data_clean$type, p = 0.8, list = FALSE, times = 1)
train_data <- wine_data_clean[train_index, ]
test_data <- wine_data_clean[-train_index, ]

# Remove factor variables with only one level
single_level_factors <- sapply(train_data, function(x) is.factor(x) && length(unique(x)) == 1)
train_data <- train_data[, !single_level_factors]

# Ensure the same columns are removed from test_data
test_data <- test_data[, colnames(train_data)]

# Define the training control
train_control <- trainControl(method = "cv", number = 10)

train_index <- createDataPartition(wine_data_clean$type, p = 0.8, list = FALSE, times = 1)
train_data <- wine_data_clean[train_index, ]
test_data <- wine_data_clean[-train_index, ]

# Decision Tree
dt_model <- train(type ~ ., data = train_data, method = "rpart", trControl = train_control)


# KNN Classification
knn_model <- train(type ~ ., data = train_data, method = "knn", trControl = train_control, tuneLength = 10)

# Display model results
print(dt_model)
print(knn_model)

# Compare model performances using resampling
results <- resamples(list(
  Decision_Tree = dt_model,
  KNN = knn_model
))

# Summary of the results
summary(results)

# Boxplots of the results
bwplot(results)

# Dot plots of the results
dotplot(results)
