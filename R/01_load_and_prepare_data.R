raw_path <- "data/raw/hillstrom_email_experiment.csv"
source_url <- paste0(
  "http://www.minethatdata.com/",
  "Kevin_Hillstrom_MineThatData_E-MailAnalytics_",
  "DataMiningChallenge_2008.03.20.csv"
)

if (!file.exists(raw_path)) {
  download.file(source_url, raw_path, mode = "wb")
}

raw <- readr::read_csv(raw_path, show_col_types = FALSE)

required_columns <- c(
  "recency", "history_segment", "history", "mens", "womens", "zip_code",
  "newbie", "channel", "segment", "visit", "conversion", "spend"
)
missing_columns <- setdiff(required_columns, names(raw))
if (length(missing_columns) > 0L) {
  stop("Missing expected columns: ", paste(missing_columns, collapse = ", "))
}

experiment <- raw %>%
  mutate(
    assignment = factor(
      segment,
      levels = c("No E-Mail", "Mens E-Mail", "Womens E-Mail"),
      labels = c("No email", "Men's email", "Women's email")
    ),
    history_segment = factor(history_segment, ordered = TRUE),
    zip_code = factor(zip_code),
    channel = factor(channel),
    treatment_mens = as.integer(assignment == "Men's email")
  )

primary_experiment <- experiment %>%
  filter(assignment %in% c("No email", "Men's email")) %>%
  droplevels()

readr::write_csv(experiment, "data/processed/hillstrom_all_arms.csv")
readr::write_csv(primary_experiment, "data/processed/hillstrom_primary_comparison.csv")
