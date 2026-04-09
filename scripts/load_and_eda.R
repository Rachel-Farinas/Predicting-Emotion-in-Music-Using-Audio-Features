# --- Load Data ---
data <- read_csv("dataset.csv", show_col_types = FALSE)
names(data) <- gsub(" ", "_", names(data))
data$explicit <- as.integer(data$explicit == "True")

# --- Define Groups ---
groups <- list(
  G1_Rhythmic  = data %>% filter(track_genre %in% c("salsa", "reggae", "reggaeton")),
  G2_Classical = data %>% filter(track_genre %in% c("opera", "classical", "piano")),
  G3_HardRock  = data %>% filter(track_genre %in% c("punk-rock", "heavy-metal", "punk"))
)

all_groups <- bind_rows(groups, .id = "Group_ID") %>%
  mutate(Group = recode(Group_ID, "G1_Rhythmic"="G1: Rhythmic", 
                        "G2_Classical"="G2: Classical", "G3_HardRock"="G3: Hard Rock"))

# --- EDA Plotting ---
cat("\n--- Plotting EDA ---\n")

# Combine all 3 groups with a label
all_groups <- bind_rows(
  g1_data %>% mutate(Group = "G1: Rhythmic"),
  g2_data %>% mutate(Group = "G2: Classical"),
  g3_data %>% mutate(Group = "G3: Hard Rock")
)

# ── Plot 1: Valence distribution per group ─────────────────────────────────
p1 <- ggplot(all_groups, aes(x = valence, fill = Group)) +
  geom_histogram(bins = 40, color = "white", alpha = 0.85) +
  facet_wrap(~Group, ncol = 1) +
  scale_fill_manual(values = c("#4e9af1", "#e85d04", "#06d6a0")) +
  labs(title = "Valence Distribution by Genre Group",
       subtitle = "Higher valence = more positive/happy songs",
       x = "Valence", y = "Count") +
  theme_bw(base_size = 13) +
  theme(legend.position = "none")

ggsave("plots/01_valence_distribution.png", p1, width = 8, height = 9, dpi = 150)

# ── Plot 2: Energy distribution per group ──────────────────────────────────
p2 <- ggplot(all_groups, aes(x = energy, fill = Group)) +
  geom_histogram(bins = 40, color = "white", alpha = 0.85) +
  facet_wrap(~Group, ncol = 1) +
  scale_fill_manual(values = c("#4e9af1", "#e85d04", "#06d6a0")) +
  labs(title = "Energy Distribution by Genre Group",
       subtitle = "Higher energy = louder, faster, more intense songs",
       x = "Energy", y = "Count") +
  theme_bw(base_size = 13) +
  theme(legend.position = "none")

ggsave("plots/02_energy_distribution.png", p2, width = 8, height = 9, dpi = 150)

# ── Plot 3: Circumplex scatter (Valence vs Energy) ─────────────────────────
p3 <- ggplot(all_groups, aes(x = valence, y = energy, color = track_genre)) +
  geom_point(alpha = 0.15, size = 0.8) +
  geom_density_2d(linewidth = 0.4, alpha = 0.8) +
  facet_wrap(~Group) +
  labs(title = "Circumplex Model of Affect: Valence vs Energy",
       subtitle = "Based on Russell (1980) — each point is one song",
       x = "Valence (positive <-> negative)",
       y = "Energy (calm <-> intense)",
       color = "Genre") +
  theme_bw(base_size = 12) +
  theme(legend.position = "bottom")

ggsave("plots/03_circumplex_scatter.png", p3, width = 12, height = 5, dpi = 150)

# ── Plot 4: Boxplots — Valence and Energy by group ─────────────────────────
p4a <- ggplot(all_groups, aes(x = Group, y = valence, fill = Group)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.2) +
  scale_fill_manual(values = c("#4e9af1", "#e85d04", "#06d6a0")) +
  labs(title = "Valence by Genre Group", x = NULL, y = "Valence") +
  theme_bw(base_size = 13) +
  theme(legend.position = "none")

p4b <- ggplot(all_groups, aes(x = Group, y = energy, fill = Group)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.2) +
  scale_fill_manual(values = c("#4e9af1", "#e85d04", "#06d6a0")) +
  labs(title = "Energy by Genre Group", x = NULL, y = "Energy") +
  theme_bw(base_size = 13) +
  theme(legend.position = "none")

p4 <- p4a + p4b
ggsave("plots/04_boxplots_valence_energy.png", p4, width = 12, height = 5, dpi = 150)

# ── Plot 5: Correlation matrix per group ───────────────────────────────────
num_vars <- c("popularity", "danceability", "energy", "loudness",
              "speechiness", "acousticness", "instrumentalness",
              "liveness", "valence", "tempo")

png("plots/05_correlation_G1_Rhythmic.png", width = 800, height = 700)
cor_g1 <- cor(g1_data %>% select(all_of(num_vars)) %>% drop_na())
corrplot(cor_g1, method = "color", type = "upper", tl.col = "black",
         tl.srt = 45, addCoef.col = "black", number.cex = 0.7,
         title = "Correlations — G1: Rhythmic", mar = c(0,0,2,0))
dev.off()

png("plots/05_correlation_G2_Classical.png", width = 800, height = 700)
cor_g2 <- cor(g2_data %>% select(all_of(num_vars)) %>% drop_na())
corrplot(cor_g2, method = "color", type = "upper", tl.col = "black",
         tl.srt = 45, addCoef.col = "black", number.cex = 0.7,
         title = "Correlations — G2: Classical", mar = c(0,0,2,0))
dev.off()

png("plots/05_correlation_G3_HardRock.png", width = 800, height = 700)
cor_g3 <- cor(g3_data %>% select(all_of(num_vars)) %>% drop_na())
corrplot(cor_g3, method = "color", type = "upper", tl.col = "black",
         tl.srt = 45, addCoef.col = "black", number.cex = 0.7,
         title = "Correlations — G3: Hard Rock", mar = c(0,0,2,0))
dev.off()

# ── Plot 6: Feature means per group (radar-style bar chart) ────────────────
feature_means <- all_groups %>%
  group_by(Group) %>%
  summarise(
    Danceability    = mean(danceability),
    Energy          = mean(energy),
    Loudness_norm   = (mean(loudness) - min(all_groups$loudness)) /
      (max(all_groups$loudness) - min(all_groups$loudness)),
    Speechiness     = mean(speechiness),
    Acousticness    = mean(acousticness),
    Instrumentalness = mean(instrumentalness),
    Liveness        = mean(liveness),
    Valence         = mean(valence),
    Tempo_norm      = (mean(tempo) - min(all_groups$tempo)) /
      (max(all_groups$tempo) - min(all_groups$tempo))
  ) %>%
  pivot_longer(-Group, names_to = "Feature", values_to = "Mean")

p6 <- ggplot(feature_means, aes(x = Feature, y = Mean, fill = Group)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c("#4e9af1", "#e85d04", "#06d6a0")) +
  labs(title = "Average Feature Values by Genre Group",
       subtitle = "Louder, Tempo normalised to 0-1 for comparison",
       x = NULL, y = "Mean Value") +
  theme_bw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("plots/06_feature_means_by_group.png", p6, width = 12, height = 6, dpi = 150)
