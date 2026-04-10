# Predicting Emotion in Music Using Audio Features 🎧

This project implements a multi-model machine learning pipeline to predict the **Valence** and **Energy** of music tracks across different genre groups. This repository features files dealing with data processing, model training, and advanced interpretability (SHAP/PDP).

---

## 📂 Project Structure

```text
├── main.R                     # The central controller; run this to execute the full pipeline
├── scripts/
│   ├── setup.R                # Environment configuration, library loading, and helper functions
│   ├── load_and_eda.R         # Data ingestion, cleaning, and Exploratory Data Analysis
│   ├── modeling.R             # Model training (LR, KNN, RF, XGBoost, Stacked Ensembles)
│   ├── performance.R          # Global accuracy metrics (R², RMSE, Heatmaps)
│   ├── diagnostics.R          # Model health (Residuals, Q-Q plots, Error analysis)
│   └── interpretability.R     # Feature importance, SHAP divergence, and PDP plots
├── data/                      # Raw and processed datasets (ignored by git if large)
├── plots/                     # Automatically generated visualizations (Plots 01-23)
└── README.md                  # Project documentation

```

## 📖 Key Terminology

To understand the outputs of this model, it is helpful to define the core emotional and technical concepts used throughout the analysis.

### 1. The Dimensional Model of Emotion
We utilize the **Russell Circumplex Model of Affect**, which maps musical emotion onto a two-dimensional coordinate system rather than using simple labels like "happy" or "sad."

* **Valence:** Represents the **perceived pleasantness** of the music. 
    * *High Valence:* Positive emotions (joy, cheerfulness, serenity).
    * *Low Valence:* Negative emotions (sadness, anger, depression).
* **Energy (Arousal):** Represents the **intensity and activity** level of the track.
    * *High Energy:* High intensity (excitement, chaos, tension).
    * *Low Energy:* Low intensity (calmness, lethargy, relaxation).

### 3. Audio Features (Predictors)
These are the technical "ingredients" the model uses to predict emotion:
* **Acousticness:** A confidence measure of whether the track is acoustic.
* **Danceability:** Describes how suitable a track is for dancing based on tempo, rhythm stability, and beat strength.
* **Instrumentalness:** Predicts whether a track contains no vocals.
* **Loudness:** The overall loudness of a track in decibels (dB).
* **Speechiness:** Detects the presence of spoken words in a track.
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
