FROM docker.io/rocker/rstudio:4.5.1
# FROM docker.io/rocker/rstudio:4.3.3

RUN sudo apt-get update && apt-get install -y libglpk-dev libgdal-dev gdal-bin libproj-dev \
                      libgeos-dev libudunits2-dev

# Install R libraries
RUN R -e "install.packages(c('tidyverse', \
                             'ggplot2', 'cowplot', \
                             'qs', 'viridis', \
                             'rstudioapi', \
                             'Seurat', 'SeuratObject', \
                             'harmony', 'glue', 'patchwork', 'magrittr', 'dplyr', \
                             'reshape2', 'pheatmap', 'purrr', 'Matrix', 'tidyverse', \
                             'shiny', 'rlist', 'rdist', 'stringr', 'scCustomize', \
                             'patchwork', 'FNN', 'rnndescent', 'remotes', 'remotes', \
                             'ggrepel', 'sf', 'BiocManager', \
                             repos='http://cloud.r-project.org'), \
                             Ncpus=8L)"

# RUN R -e "BiocManager::install(version = '3.21', ask = FALSE)"
RUN R -e "BiocManager::install(c('UCell'), ask = FALSE)"
# RUN R -e "if (!require('remotes', quietly = TRUE)) install.packages('remotes')"
RUN R -e "remotes::install_github('genecell/COSGR', dependencies = TRUE)"

# podman build -f Dockerfile -t rstudio-ext1 .
# podman save -o /mnt/disks/common2/images/rstudio-ext1.tar rstudio-ext1:latest
# sudo chmod -R 777 /mnt/disks/common2

