#' @importFrom datasets airquality
NULL

# Data Cleaning -----------------------------------------------------------

#' Clean and transform air quality data
#' @param raw_data Input data frame (default: airquality)
#' @return Processed data frame
#' @export
clean_data <- function(raw_data = datasets::airquality) {
  raw_data %>%
    dplyr::mutate(
      Date = lubridate::ymd(paste("1973", Month, Day, sep = "-")),
      Ozone = replace(Ozone, Ozone < 0, NA),
      Temp_C = round((Temp - 32) * 5/9, 1)
    ) %>%
    tidyr::drop_na(Ozone, Solar.R) %>%
    dplyr::select(-Month, -Day)
}

# Analysis ----------------------------------------------------------------

#' Generate summary statistics
#' @param cleaned_data Processed data frame
#' @return Summary tibble
#' @export
summarize_data <- function(cleaned_data) {
  cleaned_data %>%
    dplyr::group_by(Month = lubridate::month(Date, label = TRUE)) %>%
    dplyr::summarise(
      Mean_Ozone = mean(Ozone, na.rm = TRUE),
      Max_Temp = max(Temp, na.rm = TRUE),
      .groups = "drop"
    )
}

#' Calculate variable correlations
#' @param cleaned_data Processed data frame
#' @return Correlation matrix
#' @export
calculate_correlations <- function(cleaned_data) {
  cleaned_data %>%
    dplyr::select(Ozone, Solar.R, Wind, Temp) %>%
    stats::cor(use = "complete.obs")
}

# Visualization -----------------------------------------------------------

#' Create and save diagnostic plots
#' @param cleaned_data Processed data frame
#' @return Vector of plot file paths
#' @export
create_plots <- function(cleaned_data) {
  dir.create("results/plots", showWarnings = FALSE, recursive = TRUE)
  plot_paths <- list()
  
  # Existing plots
  ozone_time <- ggplot2::ggplot(cleaned_data, ggplot2::aes(Date, Ozone)) +
    ggplot2::geom_line(color = "steelblue") +
    ggplot2::labs(title = "Ozone Levels Over Time")
  plot_paths <- c(plot_paths, save_plot(ozone_time, "results/plots/ozone_time.png"))
  
  temp_dist <- ggplot2::ggplot(cleaned_data, ggplot2::aes(Temp_C)) +
    ggplot2::geom_histogram(fill = "salmon", bins = 15) +
    ggplot2::labs(title = "Temperature Distribution (℃)")
  plot_paths <- c(plot_paths, save_plot(temp_dist, "results/plots/temp_dist.png"))
  
  ozone_wind <- ggplot2::ggplot(cleaned_data, ggplot2::aes(Wind, Ozone)) +
    ggplot2::geom_point(alpha = 0.6) +
    ggplot2::geom_smooth(method = "lm") +
    ggplot2::labs(title = "Ozone vs Wind Speed")
  plot_paths <- c(plot_paths, save_plot(ozone_wind, "results/plots/ozone_wind.png"))
  
  # New Plot 1: Ozone by Month Boxplot
  ozone_month <- ggplot2::ggplot(cleaned_data, 
                                 ggplot2::aes(x = lubridate::month(Date, label = TRUE), y = Ozone)) +
    ggplot2::geom_boxplot(fill = "lightblue") +
    ggplot2::labs(x = "Month", title = "Monthly Ozone Distribution")
  plot_paths <- c(plot_paths, save_plot(ozone_month, "results/plots/ozone_month.png"))
  
  # New Plot 2: Solar Radiation vs Temperature
  solar_temp <- ggplot2::ggplot(cleaned_data, ggplot2::aes(Solar.R, Temp_C)) +
    ggplot2::geom_point(alpha = 0.7, color = "darkgreen") +
    ggplot2::geom_smooth(method = "loess", color = "red") +
    ggplot2::labs(x = "Solar Radiation", y = "Temperature (℃)", 
                  title = "Solar Radiation vs Temperature")
  plot_paths <- c(plot_paths, save_plot(solar_temp, "results/plots/solar_temp.png"))
  
  unlist(plot_paths)
}

#' Save a ggplot to specified path
#' @param plot_obj ggplot object to save
#' @param path Output file path
#' @param width Plot width in inches
#' @param height Plot height in inches
#' @return Path to saved plot
#' @export
save_plot <- function(plot_obj, path, width = 10, height = 6) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  ggplot2::ggsave(path, plot = plot_obj, width = width, height = height, dpi = 300)
  return(path)
}

# Export ------------------------------------------------------------------

#' Save analysis outputs
#' @param object R object to save
#' @param path Output path
#' @param format File format ("csv" or "xlsx")
#' @export
export_results <- function(object, path, format = "csv") {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  
  switch(format,
         "csv" = readr::write_csv(object, path),
         "xlsx" = writexl::write_xlsx(object, path),
         stop("Unsupported format. Use 'csv' or 'xlsx'")
  )
  return(path)
}