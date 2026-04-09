# --- Environment Setup ---
needed <- c("tidyverse", "caret", "randomForest", "xgboost",
            "glmnet", "kknn", "mgcv", "splines",
            "corrplot", "ggrepel", "patchwork", "viridis", "pdp")

for (pkg in needed) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}

library(tidyverse)
library(caret)
library(randomForest)
library(xgboost)
library(glmnet)
library(kknn)
library(corrplot)
library(ggrepel)
library(patchwork)
library(viridis)
library(pdp)

set.seed(42)
dir.create("plots", showWarnings = FALSE)

# --- Helper Functions ---
get_metrics <- function(predicted, actual) {
  errors <- actual - predicted
  rmse   <- sqrt(mean(errors^2))
  mae    <- mean(abs(errors))
  r2     <- 1 - sum(errors^2) / sum((actual - mean(actual))^2)
  return(data.frame(RMSE = round(rmse, 4), MAE = round(mae, 4), R2 = round(r2, 4)))
}

split_data <- function(df, target) {
  features <- c(target, "popularity", "duration_ms", "explicit",
                "danceability", "loudness", "speechiness",
                "acousticness", "instrumentalness", "liveness", "tempo")
  df <- df %>% select(all_of(features)) %>% drop_na()
  
  idx   <- createDataPartition(df[[target]], p = 0.75, list = FALSE)
  train <- df[idx, ]
  test  <- df[-idx, ]
  
  num_cols <- setdiff(names(train), target)
  means    <- sapply(train[num_cols], mean); sds <- sapply(train[num_cols], sd)
  sds[sds == 0] <- 1
  
  train_sc <- train; test_sc <- test
  train_sc[num_cols] <- sweep(sweep(train[num_cols], 2, means, "-"), 2, sds, "/")
  test_sc[num_cols]  <- sweep(sweep(test[num_cols],  2, means, "-"), 2, sds, "/")
  
  list(train = train, test = test, train_scaled = train_sc, 
       test_scaled = test_sc, y_train = train[[target]], y_test = test[[target]])
}