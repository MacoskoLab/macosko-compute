FROM docker.io/rocker/rstudio

# RUN sudo apt-get update && apt-get install -y libglpk-dev
RUN apt-get update && apt-get install -y  \
    sudo zip unzip less tree expect       \
    wget curl rsync socat                 \
    gdebi-core build-essential cmake pkg-config alien \
    libssl-dev libcurl4-openssl-dev libzmq3-dev git \
    zlib1g-dev

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk -y


# Install R libraries
RUN R -e "install.packages(c('tidyverse', \
                             'ggplot2', 'cowplot', \
                             'qs', 'viridis', \
                             'rstudioapi', \
                             'Seurat', 'SeuratObject', \
                             'BiocManager', 'renv', 'tidyr', \
                             repos='http://cloud.r-project.org'), \
                             Ncpus=8L)"

# RUN -e "BiocManager::install(c('GenomicRanges', 'SummarizedExperiment'))"

RUN R -e "BiocManager::install(c('GenomicRanges', 'SummarizedExperiment', 'DESeq2', 'fgsea'), ask = FALSE)"

# podman build -f Dockerfile -t rstudio-std .
# podman save -o /mnt/disks/common/images/rstudio-std.tar rstudio-std:latest
# sudo chmod -R 777 /mnt/disks/common

