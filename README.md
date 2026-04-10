This README is designed to give your GitHub repository a professional, "industry-standard" feel. It clearly explains the architecture, the logic behind the modularization, and how a collaborator (or your future self) should navigate the project.

---

# Predicting Emotion in Music Using Audio Features 🎧

This project implements a multi-model machine learning pipeline to predict the **Valence** and **Energy** of music tracks across different genre groups. By modularizing the workflow, the project maintains a clear distinction between data processing, model training, and advanced interpretability (SHAP/PDP).

## 📂 Project Structure

```text
├── main.R                     # The central controller; run this to execute the full pipeline
├── scripts/
│   ├── 00_setup.R             # Environment configuration, library loading, and helper functions
│   ├── 01_load_and_eda.R      # Data ingestion, cleaning, and Exploratory Data Analysis
│   ├── 02_modeling.R          # Model training (LR, KNN, RF, XGBoost, Stacked Ensembles)
│   ├── 03_performance.R       # Global accuracy metrics (R², RMSE, Heatmaps)
│   ├── 04_diagnostics.R       # Model health (Residuals, Q-Q plots, Error analysis)
│   └── 05_interpretability.R  # Feature importance, SHAP divergence, and PDP plots
├── data/                      # Raw and processed datasets (ignored by git if large)
├── plots/                     # Automatically generated visualizations (Plots 01-23)
└── README.md                  # Project documentation
```

---

## ⚙️ Workflow & Script Flow

The project follows a linear, dependency-based pipeline controlled by `main.R`.

### 1. Initialization (`setup.R`)
* Loads required packages: `tidyverse`, `caret`, `xgboost`, `randomForest`, `pdp`, and `patchwork`.
* Defines global variables such as `targets <- c("valence", "energy")`.
* Sets the random seed to ensure reproducibility.

### 2. Data Engineering (`load_and_eda.R`)
* **Cleaning:** Handles missing values and scales audio features.
* **Segmentation:** Splits the dataset into genre-based groups (e.g., Rhythmic, Classical, Hard Rock).
* **EDA:** Generates initial distribution and correlation plots to understand the feature space.

### 3. Model Pipeline (`modeling.R`)
* Trains multiple regression models for every combination of **Genre Group** × **Target Variable**.
* **Models included:** Linear Regression, Elastic Net, KNN (with and without PCA), Random Forest, and XGBoost.
* **Ensembling:** Creates a `StackedEnsemble` using a Generalized Linear Model (GLM) to weigh the predictions of the base models.

### 4. Results & Validation (`performance.R` & `diagnostics.R`)
* **Performance:** Compares models using $R^2$ and $RMSE$. Includes a complexity-vs-performance analysis to see if "heavier" models (XGBoost) actually outperform simpler ones.
* **Diagnostics:** Generates "Model Health" reports. It loops through each model to create Residuals vs. Fitted and Q-Q plots to check for heteroscedasticity or non-normality in errors.

### 5. Interpretability (`interpretability.R`)
* **Feature Importance:** Uses Random Forest's `%IncMSE` to rank which audio features (like `acousticness` or `tempo`) matter most.
* **SHAP Divergence:** Uses XGBoost's SHAP values to explain how feature influence changes across different genres.
* **Partial Dependence Plots (PDP):** Visualizes the marginal effect of the top features on the predicted emotion, showing if the relationship is linear or non-linear.

---

## 🚀 Getting Started

1.  Clone the repository.
2.  Ensure you have the latest version of R and the necessary libraries installed.
3.  Open the project and run:
    ```r
    source("main.R")
    ```
4.  View all generated insights in the `/plots` folder.

## 📊 Key Findings
* **Genre Sensitivity:** Model performance and feature importance vary significantly between genre groups (e.g., "Danceability" is a stronger predictor for Rhythmic music than for Classical).
* **Ensemble Gain:** The Stacked Ensemble generally provides a ~3-5% boost in $R^2$ over the best individual base model.
