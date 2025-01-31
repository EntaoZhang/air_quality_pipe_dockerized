library(targets)
library(tarchetypes)

source("functions.R")

list(
  # Data targets
  tar_target(
    raw_data,
    datasets::airquality,
    packages = "datasets"
  ),
  
  tar_target(
    cleaned_data,
    clean_data(raw_data),
    packages = c("dplyr", "tidyr", "lubridate")
  ),
  
  # Analysis targets
  tar_target(
    summary_stats,
    summarize_data(cleaned_data),
    packages = c("dplyr", "lubridate")
  ),
  
  tar_target(
    corr_matrix,
    calculate_correlations(cleaned_data),
    packages = "dplyr"
  ),
  
  # Visualization targets
  tar_target(
    analysis_plots,
    create_plots(cleaned_data),
    format = "file",
    packages = "ggplot2"
  ),
  
  # Export targets
  tar_target(
    summary_csv,
    export_results(summary_stats, "results/summary_stats.csv"),
    format = "file",
    packages = "readr"
  ),
  
  tar_target(
    corr_xlsx,
    export_results(as.data.frame(corr_matrix), "results/correlations.xlsx", "xlsx"),
    format = "file",
    packages = "writexl"
  ),
  
  tar_target(
    report_rmd,
    {
      # Properly formatted Rmd content with correct YAML
      rmd_content <- c(
        "---",
        "title: 'Air Quality Report'",
        "output:",
        "  md_document:",
        "    variant: markdown_github",
        "params:",
        "  summary_stats: null",
        "  corr_matrix: null",
        "  analysis_plots: null",
        "---",
        "",
        "### Summary Statistics",
        "```{r sum, echo=FALSE}",
        "if (!is.null(params$summary_stats)) {",
        "  knitr::kable(params$summary_stats, caption = 'Summary Statistics')",
        "}",
        "```",
        "",
        "### Correlation Matrix", 
        "```{r cor, echo=FALSE}",
        "if (!is.null(params$corr_matrix)) {",
        "  knitr::kable(params$corr_matrix, caption = 'Correlation Matrix')",
        "}",
        "```"
      )
      
      dir.create("reports", showWarnings = FALSE, recursive = TRUE)
      writeLines(rmd_content, "reports/air_quality.Rmd")
      "reports/air_quality.Rmd"
    },
    format = "file",
    packages = c("rmarkdown", "knitr")  # Add required packages
  ),
  
  tar_target(
    final_report_md,
    {
      # Ensure results directory exists
      dir.create("results", showWarnings = FALSE, recursive = TRUE)
      
      # Render with explicit encoding and clean env
      rmarkdown::render(
        input = report_rmd,
        output_file = "air_quality.md",
        output_dir = "results",
        params = list(
          summary_stats = summary_stats,
          corr_matrix = corr_matrix,
          analysis_plots = analysis_plots
        ),
        envir = new.env(parent = globalenv())
      )
      file.path("results", "air_quality.md")
    },
    format = "file",
    packages = c("rmarkdown", "knitr")
  )
)