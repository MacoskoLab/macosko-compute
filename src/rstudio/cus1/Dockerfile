FROM docker.io/rocker/rstudio:4.5.1
# FROM docker.io/rocker/rstudio:4.3.3

RUN sudo apt-get update && apt-get install -y libglpk-dev libgdal-dev gdal-bin libproj-dev \
                      libgeos-dev libudunits2-dev

# Install R libraries
RUN R -e "install.packages(c('tidyverse', 'tidyr', 'readxl', \
                             'ggplot2', 'cowplot', \
                             'qs', 'viridis', \
                             'rstudioapi', \
                             'Seurat', 'SeuratObject', \
                             'glue', 'patchwork', 'magrittr', 'dplyr', \
                             'reshape2', 'pheatmap', 'purrr', 'Matrix', 'tidyverse', \
                             'remotes',  \
                             'ggrepel', 'BiocManager', \
                             repos='http://cloud.r-project.org'), \
                             Ncpus=8L)"

RUN R -e "BiocManager::install(c('UCSC.utils', 'GenomeInfoDb', 'enrichplot', 'clusterProfiler', 'org.Hs.eg.db'), ask=FALSE)"

# podman build -f Dockerfile -t rstudio-cus1 .
# podman save -o /mnt/disks/common2/images/rstudio-cus1.tar rstudio-cus1:latest
# sudo chmod -R 777 /mnt/disks/common2

