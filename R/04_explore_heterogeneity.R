primary_experiment <- readr::read_csv("data/processed/hillstrom_primary_comparison.csv", show_col_types = FALSE) %>%
  mutate(
    assignment = factor(assignment, levels = c("No email", "Men's email")),
    history_segment = factor(history_segment, ordered = TRUE)
  )

segment_effects <- primary_experiment %>%
  group_by(history_segment, assignment) %>%
  summarise(n = n(), conversions = sum(conversion), conversion_probability = mean(conversion), .groups = "drop") %>%
  select(history_segment, assignment, n, conversion_probability) %>%
  tidyr::pivot_wider(names_from = assignment, values_from = c(n, conversion_probability)) %>%
  transmute(
    history_segment,
    control_n = `n_No email`,
    treatment_n = `n_Men's email`,
    control_conversion = `conversion_probability_No email`,
    treatment_conversion = `conversion_probability_Men's email`,
    incremental_conversion = treatment_conversion - control_conversion,
    standard_error = sqrt(
      treatment_conversion * (1 - treatment_conversion) / treatment_n +
        control_conversion * (1 - control_conversion) / control_n
    ),
    lower_ci = incremental_conversion - 1.96 * standard_error,
    upper_ci = incremental_conversion + 1.96 * standard_error
  )
readr::write_csv(segment_effects, "outputs/exploratory_history_segment_effects.csv")

segment_plot <- ggplot2::ggplot(segment_effects, ggplot2::aes(x = history_segment, y = incremental_conversion)) +
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "#666666") +
  ggplot2::geom_errorbar(ggplot2::aes(ymin = lower_ci, ymax = upper_ci), width = 0.10, color = "#2171B5") +
  ggplot2::geom_point(size = 2.5, color = "#2171B5") +
  ggplot2::theme_classic() +ggplot2::scale_x_discrete(labels = c(
    "1) $0 - $100" = "$0–100",
    "2) $100 - $200" = "$100–200",
    "3) $200 - $350" = "$200–350",
    "4) $350 - $500" = "$350–500",
    "5) $500 - $750" = "$500–750",
    "6) $750 - $1,000" = "$750–1,000",
    "7) $1,000 +" = "$1,000+"
  )) +
  ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  ggplot2::labs(
    title = "Exploratory conversion lift by prior-spend segment",
    subtitle = "Men's email minus no email; unadjusted subgroup estimates",
    x = "Prior 12-month spend segment",
    y = "Incremental conversion probability"
  ) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30, hjust = 1))
ggplot2::ggsave("outputs/exploratory_conversion_lift_by_history.png", segment_plot, width = 9, height = 5.5, dpi = 300)
