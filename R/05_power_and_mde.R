primary_experiment <- readr::read_csv(
  "data/processed/hillstrom_primary_comparison.csv",
  show_col_types = FALSE
) %>%
  mutate(
    assignment = factor(
      assignment,
      levels = c("No email", "Men's email")
    )
  )

alpha <- 0.05
target_power <- 0.80

control_rate <- primary_experiment %>%
  filter(assignment == "No email") %>%
  summarise(rate = mean(conversion)) %>%
  pull(rate)

n_per_arm <- primary_experiment %>%
  count(assignment, name = "n") %>%
  summarise(n = min(n)) %>%
  pull(n)

target_lifts <- c(0.0025, 0.0050, 0.0075, 0.0100)

sample_size_table <- tibble::tibble(
  absolute_conversion_lift = target_lifts,
  control_conversion_rate = control_rate
) %>%
  rowwise() %>%
  mutate(
    required_n_per_arm = ceiling(
      stats::power.prop.test(
        p1 = control_conversion_rate,
        p2 = control_conversion_rate + absolute_conversion_lift,
        sig.level = alpha,
        power = target_power,
        alternative = "two.sided"
      )$n
    ),
    required_total_n = 2L * required_n_per_arm
  ) %>%
  ungroup()

power_at_lift <- function(absolute_lift) {
  stats::power.prop.test(
    n = n_per_arm,
    p1 = control_rate,
    p2 = control_rate + absolute_lift,
    sig.level = alpha,
    alternative = "two.sided"
  )$power
}

mde <- stats::uniroot(
  function(absolute_lift) power_at_lift(absolute_lift) - target_power,
  lower = 0.00001,
  upper = 0.05
)$root

design_mde <- tibble::tibble(
  control_conversion_rate = control_rate,
  individuals_per_arm = n_per_arm,
  alpha = 0.05,
  target_power = 0.80,
  minimum_detectable_effect = mde
)

power_curve <- tibble::tibble(
  absolute_conversion_lift = seq(0.001, 0.015, by = 0.00025)
) %>%
  mutate(
    power = vapply(
      absolute_conversion_lift,
      power_at_lift,
      numeric(1)
    )
  )

readr::write_csv(
  sample_size_table,
  "outputs/conversion_sample_size_scenarios.csv"
)

readr::write_csv(
  design_mde,
  "outputs/conversion_mde.csv"
)

power_plot <- ggplot2::ggplot(
  power_curve,
  ggplot2::aes(x = absolute_conversion_lift, y = power)
) +
  ggplot2::geom_hline(
    yintercept = target_power,
    linetype = "dashed",
    color = "#666666"
  ) +
  ggplot2::geom_vline(
    xintercept = mde,
    linetype = "dashed",
    color = "#666666"
  ) +
  ggplot2::geom_line(
    linewidth = 0.9,
    color = "#2171B5"
  ) +
  ggplot2::theme_classic() +
  ggplot2::scale_x_continuous(
    labels = scales::percent_format(accuracy = 0.1)
  ) +
  ggplot2::scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1)
  ) +
  ggplot2::labs(
    title = "Power to detect absolute conversion lift",
    subtitle = "Two-sided alpha = 0.05; approximately equal allocation",
    x = "Absolute conversion lift",
    y = "Statistical power"
  )

ggplot2::ggsave(
  "outputs/conversion_power_curve.png",
  power_plot,
  width = 8,
  height = 5,
  dpi = 300
)
