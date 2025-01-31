# Install required system libraries
FROM rocker/r-ver:4.4.2

# Install system dependencies and Pandoc
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libxml2-dev \
    wget && \
    wget https://github.com/jgm/pandoc/releases/download/2.19.2/pandoc-2.19.2-1-amd64.deb && \
    dpkg -i pandoc-2.19.2-1-amd64.deb && \
    rm pandoc-2.19.2-1-amd64.deb

# Install renv for package management
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org/')"

# Create project directory
WORKDIR /air_quality_pipe_dockerized


# Copy the rest of the project files
COPY . .

# Restore packages using renv
RUN R -e "renv::restore()"


# Create output directories
RUN mkdir -p results/plots

# Execute targets pipeline
CMD ["R", "-e", "targets::tar_make()"]
