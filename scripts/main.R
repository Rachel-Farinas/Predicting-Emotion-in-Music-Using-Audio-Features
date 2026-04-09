# ==============================================================================
# MAIN CONTROL SCRIPT
# ==============================================================================

# 1. Set Workspace
setwd("C:/Users/rachy/OneDrive/Documents/StatisticalLearning/Project")

# 2. Run Setup (Libraries & Functions)
source("scripts/00_setup.R")

# 3. Run EDA (Load & Visualize Data)
source("scripts/01_load_and_eda.R")

# 4. Train Models
source("scripts/02_modeling.R")

# 5. Evaluate & Explain
source("scripts/03_evaluation.R")

cat("\nDone! All plots saved in /plots and results saved to environment.\n")