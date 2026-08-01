primary_experiment <- readr::read_csv("data/processed/hillstrom_primary_comparison.csv", show_col_types = FALSE) %>%
  mutate(assignment = factor(assignment, levels = c("No email", "Men's email")))
all_arms <- readr::read_csv("data/processed/hillstrom_all_arms.csv", show_col_types = FALSE) %>%
  mutate(assignment = factor(assignment, levels = c("No email", "Men's email", "Women's email")))

estimate_binary_effect <- function(data, outcome, label) {
  summary_data <- data %>%
    group_by(assignment) %>%
    summarise(n = n(), events = sum(.data[[outcome]]), mean_outcome = mean(.data[[outcome]]), .groups = "drop")

  control <- summary_data %>% filter(assignment == "No email")
  treated <- summary_data %>% filter(assignment == "Men's email")
  difference <- treated$mean_outcome - control$mean_outcome
  se <- sqrt(treated$mean_outcome * (1 - treated$mean_outcome) / treated$n + control$mean_outcome * (1 - control$mean_outcome) / control$n)
  z_value <- difference / se

  tibble(
    outcome = label,
    control_n = control$n,
    treatment_n = treated$n,
    control_value = control$mean_outcome,
    treatment_value = treated$mean_outcome,
    incremental_effect = difference,
    lower_ci = difference - 1.96 * se,
    upper_ci = difference + 1.96 * se,
    p_value = 2 * stats::pnorm(-abs(z_value))
  )
}

estimate_spend_effect <- function(data) {
  summary_data <- data %>%
    group_by(assignment) %>%
    summarise(n = n(), mean_outcome = mean(spend), variance = var(spend), .groups = "drop")

  control <- summary_data %>% filter(assignment == "No email")
  treated <- summary_data %>% filter(assignment == "Men's email")
  difference <- treated$mean_outcome - control$mean_outcome
  se <- sqrt(treated$variance / treated$n + control$variance / control$n)
  degrees_freedom <- (treated$variance / treated$n + control$variance / control$n)^2 /
    ((treated$variance / treated$n)^2 / (treated$n - 1) + (control$variance / control$n)^2 / (control$n - 1))
  critical_value <- stats::qt(0.975, df = degrees_freedom)

  tibble(
    outcome = "Spend per customer (USD)",
    control_n = control$n,
    treatment_n = treated$n,
    control_value = control$mean_outcome,
    treatment_value = treated$mean_outcome,
    incremental_effect = difference,
    lower_ci = difference - critical_value * se,
    upper_ci = difference + critical_value * se,
    p_value = 2 * stats::pt(-abs(difference / se), df = degrees_freedom)
  )
}

primary_effects <- bind_rows(
  estimate_binary_effect(primary_experiment, "conversion", "Conversion probability"),
  estimate_binary_effect(primary_experiment, "visit", "Visit probability"),
  estimate_spend_effect(primary_experiment)
)
readr::write_csv(primary_effects, "outputs/primary_effect_estimates.csv")

all_arm_summary <- all_arms %>%
  group_by(assignment) %>%
  summarise(
    individuals = n(),
    visit_probability = mean(visit),
    conversion_probability = mean(conversion),
    spend_per_customer = mean(spend),
    .groups = "drop"
  )
readr::write_csv(all_arm_summary, "outputs/all_arm_summary.csv")

conversion_plot_data <- all_arm_summary %>%
  select(assignment, conversion_probability) %>%
  mutate(outcome = "Conversion probability", value = conversion_probability)

conversion_plot <- ggplot2::ggplot(conversion_plot_data, ggplot2::aes(x = assignment, y = value, fill = assignment)) +
  ggplot2::geom_col(width = 0.65) +
  ggplot2::geom_text(ggplot2::aes(label = scales::percent(value, accuracy = 0.01)), vjust = -0.35, size = 3.6) +
  ggplot2::theme_classic() +
  ggplot2::scale_fill_manual(values = c("#9E9E9E", "#2171B5", "#6BAED6")) +
  ggplot2::scale_y_continuous(labels = scales::percent_format(), expand = ggplot2::expansion(mult = c(0, 0.12))) +
  ggplot2::labs(title = "Conversion probability by randomized email assignment", x = NULL, y = "Conversion probability", fill = NULL)
ggplot2::ggsave("outputs/conversion_by_assignment.png", conversion_plot, width = 8, height = 5, dpi = 300)
