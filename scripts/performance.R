# ==============================================================================
# 03_PERFORMANCE: GLOBAL MODEL COMPARISON
# ==============================================================================

cat("--- Generating Performance Visuals ---\n")

# ── Plot 07: R² Heatmap ─────────────────────────────────────────────────────
p7 <- ggplot(master, aes(x = Model, 
                         y = paste(Group, Target, sep = "\n"), 
                         fill = R2)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = R2), size = 3.5, fontface = "bold") +
  scale_fill_gradientn(colors = c("#d73027", "#fee08b", "#1a9850"), limits = c(0, 1), name = "R²") +
  labs(title = "R² Heatmap — All Models & Groups", x = "Model", y = NULL) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("plots/07_r2_heatmap.png", p7, width = 11, height = 7, dpi = 150)

# ── Plot 08: RMSE Bar Chart ─────────────────────────────────────────────────
p8 <- ggplot(master, aes(x = reorder(Model, RMSE), y = RMSE, fill = Target)) +
  geom_col(position = "dodge", alpha = 0.85) +
  facet_wrap(~Group, ncol = 1, scales = "free_y") +
  coord_flip() +
  scale_fill_manual(values = c(valence = "#4e9af1", energy = "#e85d04")) +
  labs(title = "RMSE by Model and Group", x = NULL, y = "RMSE") +
  theme_bw(base_size = 12)

ggsave("plots/08_rmse_bars.png", p8, width = 10, height = 11, dpi = 150)

# ── Plot 10: Complexity vs R² ──────────────────────────────────────────────
complexity_order <- c("LinearRegression" = 1, "ElasticNet" = 2, "KNN" = 3, 
                      "KNN_PCA" = 3.5, "RandomForest" = 4, "XGBoost" = 5, "StackedEnsemble" = 6)

p10 <- master %>%
  filter(Target == "valence") %>%
  mutate(Complexity = complexity_order[Model]) %>%
  filter(!is.na(Complexity)) %>%
  ggplot(aes(x = Complexity, y = R2, color = Group, group = Group)) +
  geom_line(linewidth = 1.2) + geom_point(size = 4) +
  scale_x_continuous(breaks = c(1, 2, 3, 3.5, 4, 5, 6),
                     labels = c("Linear", "ElasticNet", "KNN", "KNN+PCA", "RF", "XGBoost", "Stacked")) +
  scale_color_manual(values = c("#4e9af1", "#e85d04", "#06d6a0")) +
  labs(title = "Model Complexity vs Valence R²", x = "Model Complexity", y = "Test R²") +
  theme_bw(base_size = 13)

ggsave("plots/10_complexity_vs_r2.png", p10, width = 9, height = 6, dpi = 150)

# ── Plot 22: Ensemble Comparison ───────────────────────────────────────────
p22 <- master %>%
  mutate(IsEnsemble = ifelse(Model == "StackedEnsemble", "Stacked Ensemble", "Base Model")) %>%
  ggplot(aes(x = reorder(Model, R2), y = R2, fill = IsEnsemble)) +
  geom_col(alpha = 0.85) +
  facet_grid(Group ~ Target) + coord_flip() +
  scale_fill_manual(values = c("Stacked Ensemble" = "#ff6b6b", "Base Model" = "#4e9af1"), name = NULL) +
  labs(title = "Stacked Ensemble vs Base Models", x = NULL, y = "R2") +
  theme_bw(base_size = 11) + theme(legend.position = "bottom")

ggsave("plots/22_stacked_ensemble_comparison.png", p22, width = 13, height = 11, dpi = 150)