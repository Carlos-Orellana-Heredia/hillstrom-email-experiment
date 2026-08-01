required_packages <- c("dplyr", "readr", "tidyr", "ggplot2", "cobalt", "broom", "scales", "knitr", "rmarkdown")

missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0L) {
  stop("Install the missing packages before running this project: ", paste(missing_packages, collapse = ", "))
}

invisible(lapply(required_packages, library, character.only = TRUE))

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs", recursive = TRUE, showWarnings = FALSE)
dir.create("docs", recursive = TRUE, showWarnings = FALSE)
