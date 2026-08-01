# Hillstrom Randomized Email Experiment

An end-to-end R workflow for analyzing a real randomized email experiment using the Hillstrom MineThatData Email Analytics Challenge dataset.

**Rendered analysis report:** 
[https://carlos-orellana-heredia.github.io/hillstrom-email-experiment/](https://carlos-orellana-heredia.github.io/hillstrom-email-experiment/)

## Analytical question

Among customers eligible for the campaign, what was the effect of the Men's email on conversion and spend over the following two weeks, compared with receiving no email?

The primary comparison is **Men's email versus no email**. The Women's email arm is retained for contextual descriptive reporting but is not treated as a second primary hypothesis.

## Why this project exists

This case study demonstrates a practical experimentation workflow: define the treatment and outcomes, check randomized-group balance, estimate incremental effects with uncertainty, distinguish statistical from practical significance, and conduct a limited exploratory segmentation analysis.

The data come from a public email test with 64,000 customers randomly assigned to Men's email, Women's email, or no email. The raw source CSV is not tracked in this repository. `R/01_load_and_prepare_data.R` downloads it from the original source when absent.

## Workflow

1. `R/01_load_and_prepare_data.R` downloads, validates, and prepares the public data.
2. `R/02_check_randomization.R` evaluates baseline balance for the primary comparison.
3. `R/03_estimate_experiment_effects.R` estimates incremental visit, conversion, and spend outcomes.
4. `R/04_explore_heterogeneity.R` estimates exploratory conversion lift by prior-spend segment.

Run the complete analysis with:

```r
source("run_all.R")
```

All `ggplot2` figures use `theme_classic()`.

## Outcomes and interpretation

- **Primary outcome:** conversion probability within two weeks.
- **Business outcome:** incremental spend per customer within two weeks.
- **Engagement outcome:** website visit probability within two weeks.

Because assignment was randomized, the unadjusted between-group differences identify intention-to-treat effects under standard assumptions. The segmentation analysis is descriptive and exploratory; it does not establish a targeting rule by itself.

## Repository layout

```text
R/              Analysis scripts
data/raw/       Downloaded source data; excluded from Git
data/processed/ Clean analytical datasets created by the workflow
outputs/        Tables and figures created by the workflow
docs/           Rendered analysis report and documentation
```

## Data source and attribution

Kevin Hillstrom, *MineThatData E-Mail Analytics and Data Mining Challenge* (2008):
[https://blog.minethatdata.com/2008/03/minethatdata-e-mail-analytics-and-data.html](https://blog.minethatdata.com/2008/03/minethatdata-e-mail-analytics-and-data.html)

## Packages

`dplyr`, `readr`, `tidyr`, `ggplot2`, `cobalt`, `broom`, `scales`, `knitr`, and `rmarkdown`.
