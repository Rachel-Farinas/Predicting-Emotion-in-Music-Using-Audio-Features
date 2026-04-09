# ==============================================================================
# 04_DIAGNOSTICS: RESIDUAL ANALYSIS
# ==============================================================================

cat("--- Running Diagnostics & Residual Plots ---\n")

all_resid_df <- bind_rows(all_residuals)

for (gname in names(groups)) {
  for (tgt in targets) {
    df <- all_resid_df %>% filter(Group == gname, Target == tgt)
    label <- paste(gname, toupper(tgt), sep = " | ")
    
    # Residuals vs Fitted
    pa <- ggplot(df, aes(x = Predicted, y = Residual)) +
      geom_point(alpha = 0.3, color = "#3a86ff", size = 0.8) +
      geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
      geom_smooth(method = "loess", se = TRUE, color = "darkred", linewidth = 0.8) +
      labs(title = paste("Residuals vs Fitted —", label), x = "Predicted", y = "Residual") +
      theme_bw(base_size = 12)
    
    # Actual vs Predicted
    pb <- ggplot(df, aes(x = Actual, y = Predicted)) +
      geom_point(alpha = 0.3, color = "#06d6a0", size = 0.8) +
      geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
      labs(title = paste("Actual vs Predicted —", label), x = "Actual", y = "Predicted") +
      theme_bw(base_size = 12)
    
    # Q-Q Plot
    pc <- ggplot(df, aes(sample = Residual)) +
      stat_qq(alpha = 0.4, color = "#8338ec") + stat_qq_line(color = "red") +
      labs(title = paste("Q-Q Plot —", label)) +
      theme_bw(base_size = 12)
    
    combined <- pa + pb + pc
    filename <- paste0("plots/11_residuals_", gsub(" ", "_", gname), "_", tgt, ".png")
    ggsave(filename, combined, width = 15, height = 5, dpi = 150)
  }
}