targets <- c("valence", "energy")
all_results <- list(); all_residuals <- list()
rf_models <- list(); xgb_models <- list()

for (gname in names(groups)) {
  for (tgt in targets) {
    cat("\n>>> Training:", gname, "|", tgt, "\n")
    sp <- split_data(groups[[gname]], tgt)
    key <- paste(gname, tgt, sep = "_")
    results <- list()
    
    # --- Models ---
    # LM
    lm_fit <- lm(as.formula(paste(tgt, "~ .")), data = sp$train)
    lm_pred <- pmax(0, pmin(1, predict(lm_fit, sp$test)))
    results[["LinearRegression"]] <- get_metrics(lm_pred, sp$y_test)
    
    # RF
    rf_fit <- randomForest(as.formula(paste(tgt, "~ .")), data = sp$train, ntree = 300, importance = TRUE)
    rf_pred <- pmax(0, pmin(1, predict(rf_fit, sp$test)))
    results[["RandomForest"]] <- get_metrics(rf_pred, sp$y_test)
    rf_models[[key]] <- rf_fit
    
    # XGBoost
    dtrain <- xgb.DMatrix(as.matrix(sp$train_scaled[,-1]), label = sp$y_train)
    xgb_fit <- xgb.train(params = list(objective="reg:squarederror"), data = dtrain, nrounds = 100)
    xgb_pred <- pmax(0, pmin(1, predict(xgb_fit, as.matrix(sp$test_scaled[,-1]))))
    results[["XGBoost"]] <- get_metrics(xgb_pred, sp$y_test)
    xgb_models[[key]] <- list(model = xgb_fit, X_train = as.matrix(sp$train_scaled[,-1]))
    
    # ── Stacked Ensemble ─────────────────────────────────────────────
    # Level 1: 5-fold out-of-fold predictions on training set
    # Level 2: linear meta-learner trained on OOF predictions
    cat("  Stacked Ensemble...\n")
    
    n_train  <- nrow(sp$train)
    fold_ids <- sample(rep(1:5, length.out = n_train))
    
    oof_lm  <- numeric(n_train)
    oof_en  <- numeric(n_train)
    oof_knn <- numeric(n_train)
    oof_rf  <- numeric(n_train)
    oof_xgb <- numeric(n_train)
    
    for (fold in 1:5) {
      val_idx     <- which(fold_ids == fold)
      trn_idx     <- which(fold_ids != fold)
      fold_trn    <- sp$train[trn_idx, ]
      fold_val    <- sp$train[val_idx, ]
      fold_trn_sc <- sp$train_scaled[trn_idx, ]
      fold_val_sc <- sp$train_scaled[val_idx, ]
    
    all_results[[key]] <- bind_rows(results, .id = "Model") %>% mutate(Group = gname, Target = tgt)
    all_residuals[[key]] <- data.frame(Group=gname, Target=tgt, Actual=sp$y_test, Predicted=xgb_pred, Residual=sp$y_test-xgb_pred)
  }
}
master <- bind_rows(all_results)