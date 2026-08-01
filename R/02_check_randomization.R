primary_experiment <- readr::read_csv("data/processed/hillstrom_primary_comparison.csv", show_col_types = FALSE) %>%
  mutate(
    assignment = factor(assignment, levels = c("No email", "Men's email")),
    history_segment = factor(history_segment, ordered = TRUE),
    zip_code = factor(zip_code),
    channel = factor(channel)
  )

balance_formula <- treatment_mens ~ recency + history + mens + womens + zip_code + newbie + channel
balance <- cobalt::bal.tab(balance_formula, data = primary_experiment, un = TRUE, binary = "std")

balance_table <- balance$Balance %>%
  as.data.frame() %>%
  tibble::rownames_to_column("baseline_characteristic") %>%
  transmute(
    baseline_characteristic,
    standardized_mean_difference = Diff.Un,
    absolute_standardized_mean_difference = abs(Diff.Un),
    balanced_at_0_10 = absolute_standardized_mean_difference < 0.10
  )
readr::write_csv(balance_table, "outputs/randomization_balance.csv")

love_plot <- cobalt::love.plot(
  balance,
  abs = TRUE,
  thresholds = c(m = 0.10),
  var.order = "unadjusted",
  colors = "#2C7FB8",
  sample.names = "Randomized groups"
) +
  ggplot2::theme_classic() +
  ggplot2::labs(
    title = "Baseline balance in the primary randomized comparison",
    x = "Absolute standardized mean difference",
    y = NULL
  )
ggplot2::ggsave("outputs/randomization_love_plot.png", love_plot, width = 8, height = 5, dpi = 300)
