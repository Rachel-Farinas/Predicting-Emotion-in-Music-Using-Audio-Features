# ==============================================================================
# 05_INTERPRETABILITY: SHAP, IMPORTANCE, AND PDP
# ==============================================================================

cat("--- Running Interpretability Suite (SHAP/PDP) ---\n")

# ── 1. RANDOM FOREST IMPORTANCE ──────────────────────────────────────────────
cat("--- Plotting RF feature importance ---\n")
for (key in names(rf_models)) {
  gname <- sub("_(valence|energy)$", "", key)
  tgt   <- ifelse(grepl("valence", key), "valence", "energy")
  
  imp_df <- as.data.frame(randomForest::importance(rf_models[[key]])) %>%
    rownames_to_column("Feature") %>%
    rename(Importance = `%IncMSE`) %>%
    arrange(desc(Importance)) %>% 
    head(10)
  
  p_imp <- ggplot(imp_df, aes(x = reorder(Feature, Importance), y = Importance, fill = Importance)) +
    geom_col(alpha = 0.85) + 
    coord_flip() + 
    scale_fill_viridis_c(option = "C", direction = -1) +
    labs(title = paste("RF Importance —", gname, "|", toupper(tgt)),
         subtitle = "% increase in MSE when feature is permuted",
         x = NULL, y = "% Increase in MSE") + 
    theme_bw(base_size = 12) +
    theme(legend.position = "none")
  
  ggsave(paste0("plots/12_importance_rf_", key, ".png"), p_imp, width = 8, height = 5)
}

# ── 2. SHAP ANALYSIS (XGBOOST) ───────────────────────────────────────────────
cat("--- Computing and plotting SHAP divergence ---\n")

shap_rows2 <- list()
for (sgname in names(groups)) {
  skey <- paste0(sgname, "_valence")
  if (!is.null(xgb_models[[skey]])) {
    sX  <- xgb_models[[skey]]$X_train
    sm  <- xgb_models[[skey]]$model
    contrib <- predict(sm, sX, predcontrib = TRUE)
    contrib <- contrib[, colnames(contrib) != "BIAS"]
    mean_abs <- colMeans(abs(contrib))
    shap_rows2[[sgname]] <- data.frame(
      feature = names(mean_abs), group = sgname, shap = as.numeric(mean_abs)
    )
  }
}

shap_wide <- bind_rows(shap_rows2) %>%
  pivot_wider(names_from = group, values_from = shap, values_fill = 0) %>%
  rename(base = feature)

gcols <- intersect(c("G1_Rhythmic","G2_Classical","G3_HardRock"), names(shap_wide))
shap_wide$max_diff       <- apply(shap_wide[, gcols], 1, function(r) max(r) - min(r))
shap_wide$dominant_group <- apply(shap_wide[, gcols], 1, function(r) gcols[which.max(r)])
write_csv(shap_wide, "shap_divergence_enhanced.csv")

# Long format for plotting
shap_long <- shap_wide %>%
  select(base, all_of(gcols)) %>%
  pivot_longer(-base, names_to = "Group", values_to = "SHAP_Importance")

# Plot 14a: Importance per group
p14a <- ggplot(shap_long, aes(x = reorder(base, SHAP_Importance), y = SHAP_Importance, fill = Group)) +
  geom_col(position = "dodge", alpha = 0.85) +
  coord_flip() +
  scale_fill_manual(values = c(G1_Rhythmic = "#4e9af1", G2_Classical = "#e85d04", G3_HardRock = "#06d6a0")) +
  labs(title = "SHAP Feature Importance by Genre Group (Valence)", x = NULL, y = "Mean |SHAP|") +
  theme_bw(base_size = 12)

ggsave("plots/14a_shap_importance_by_group.png", p14a, width = 11, height = 7, dpi = 150)

# Plot 14b: Divergence
p14b <- ggplot(shap_wide %>% arrange(desc(max_diff)), aes(x = reorder(base, max_diff), y = max_diff, fill = dominant_group)) +
  geom_col(alpha = 0.85) +
  coord_flip() +
  scale_fill_manual(values = c(G1_Rhythmic = "#4e9af1", G2_Classical = "#e85d04", G3_HardRock = "#06d6a0")) +
  labs(title = "SHAP Cross-Group Divergence", x = NULL, y = "Max SHAP Difference Across Groups") +
  theme_bw(base_size = 12)

ggsave("plots/14b_shap_divergence.png", p14b, width = 10, height = 6, dpi = 150)

# ── 3. PARTIAL DEPENDENCE PLOTS (PDP) ────────────────────────────────────────
cat("--- Generating Partial Dependence Plots (PDP) ---\n")

for (key in names(rf_models)) {
  
  group_name <- sub("_(valence|energy)$", "", key)
  target_tgt <- ifelse(grepl("valence$", key), "valence", "energy")
  
  current_rf   <- rf_models[[key]]
  current_data <- groups[[group_name]]
  
  imp_table <- as.data.frame(randomForest::importance(current_rf))
  imp_col <- ifelse("%IncMSE" %in% colnames(imp_table), "%IncMSE", colnames(imp_table)[1])
  top_features <- rownames(imp_table)[order(imp_table[[imp_col]], decreasing = TRUE)][1:2]
  
  cat("Processing PDP for:", key, "\n")
  
  for (feat in top_features) {
    pd_raw <- pdp::partial(current_rf, pred.var = feat, train = current_data,
                           pred.fun = function(object, newdata) predict(object, newdata))
    
    pd_df <- as.data.frame(pd_raw)
    colnames(pd_df) <- c("feature_val", "yhat")
    
    p_pdp <- ggplot(pd_df, aes(x = feature_val, y = yhat)) +
      geom_line(color = "#e85d04", linewidth = 1.2) +
      geom_point(color = "#e85d04", size = 2) +
      scale_y_continuous(limits = c(0, 1)) + 
      labs(title = paste("PDP:", feat, "on", toupper(target_tgt)),
           subtitle = paste("Genre Group:", group_name),
           x = feat, y = paste("Predicted", target_tgt)) +
      theme_bw(base_size = 12)
    
    ggsave(paste0("plots/15_pdp_", group_name, "_", target_tgt, "_", feat, ".png"), p_p