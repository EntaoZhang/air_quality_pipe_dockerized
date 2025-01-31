# `Workshop II` Final Project2024/2025 : Reproducible pipelines with Docker

---

## Part I: Introduction
### Project Overview
This project implements a **reproducible data analysis pipeline** to analyze air quality measurements from New York (May-September 1973). The pipeline demonstrates modern data science practices including workflow automation, containerization, and CI/CD integration.

### Dataset
Uses R's built-in `airquality` dataset containing:
  - 153 daily measurements
  - 6 variables:
  - Ozone (ppb)
  - Solar.R (langley)
  - Wind (mph)
  - Temp (°F)
  - Month (1-12)
  - Day (1-31)

### Key Importance
1. Implements complete **end-to-end analysis** from raw data to report
2. Demonstrates **reproducible research** through:
  - Dependency management (`renv`)
   - Containerization (Docker)
   - Workflow automation (`targets`)
3. Provides template for **production-grade data pipelines**
4. Implements CI/CD through GitHub Actions

## Part II: Implementation

### Workflow Architecture
**Core components**:
1. `targets` pipeline with 8 interconnected stages:
  - Data ingestion
  - Cleaning (`clean_data()`)
   - Statistical analysis (`summarize_data()`)
   - Correlation analysis (`calculate_correlations()`)
   - Visualization (`create_plots()`)
   - Report generation
   - Results export

2. Key R Packages:
   - `dplyr/tidyr` for data wrangling
   - `ggplot2` for visualization
   - `rmarkdown` for reporting
   - `writexl` for Excel export

### Execution Methods
**1. Docker Execution**:


#### Step 0: install `Docker` and then git clone the repository to local machine
```{bash}
git clone https://github.com/EntaoZhang/air_quality_pipe_dockerized.git
cd path/to/working/directory
```

#### Step 1: Build the image
```{bash}
docker build -t airquality-analysis .
```

#### pipeline

```{bash}
docker run --rm -v $(pwd)/results:/air_quality_pipe_dockerized/results airquality-analysis
```

**2. GitHub Actions CI/CD**:
- Automatic pipeline execution on:
  - Push to `main` branch
  - Pull requests to `main`
- Artifacts produced:
  - Analysis results in `results/` directory
  - Rendered markdown report

#### Outputs
**Generated Artifacts**:
```
results/
├── air_quality.md          # Final report
├── correlations.xlsx       # Correlation matrix
├── summary_stats.csv       # Statistical summary
└── plots/
    ├── ozone_time.png      # Time series
    ├── temp_dist.png       # Histogram
    ├── ozone_wind.png      # Scatterplot
    ├── ozone_month.png     # Boxplot
    └── solar_temp.png      # Regression plot
```

**Report Features**:
- Interactive parameterization
- Automated table generation
- Version-controlled outputs
- Container-reproducible results

#### Key Implementation Details
1. **Dependency Management**:
   - System libraries pre-installed in Docker
   - R packages managed through `renv`

2. **Pipeline Resilience**:
   - Automatic directory creation
   - NA handling in data cleaning
   - Explicit package declarations per target

3. **Visualization System**:
   - Standardized plot dimensions (10x6 inches)
   - 300 DPI resolution
   - Themed ggplot2 outputs

4. **CI/CD Optimization**:
   - Docker layer caching
   - Artifact retention policy
   - Automatic resource cleanup
