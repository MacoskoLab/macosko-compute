FROM debian:bookworm

# RUN apt-get update && apt-get install -y  \
#     sudo zip unzip less tree expect       \
#     wget curl rsync socat                 \
#     gdebi-core build-essential cmake pkg-config alien \
#     libssl-dev libcurl4-openssl-dev libglpk-dev libpng-dev

# Install system libraries
RUN apt-get update && apt-get install -y  \
    sudo zip unzip less tree expect       \
    wget curl rsync socat                 \
    vim nano tmux screen htop ncdu dstat  \
    procps moreutils gnupg ssh git-all    \
    iproute2 net-tools lsof               \
    libudunits2-dev libgdal-dev           \
    libncurses5-dev libncursesw5-dev      \
    zlib1g-dev liblzma-dev libbz2-dev     \
    gdebi-core build-essential cmake pkg-config alien \
    libhdf5-dev hdf5-tools libpng-dev libtiff5-dev libjpeg-dev \
    apt-transport-https ca-certificates libssl-dev libxml2-dev \
    libfreetype6-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libcairo2-dev \
    libcurl4-openssl-dev libglpk-dev libpng-dev


# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk -y

# Install R
RUN export R_VERSION=4.5.1 && \
    curl -O https://cdn.rstudio.com/r/debian-12/pkgs/r-${R_VERSION}_1_amd64.deb && \
    echo y | gdebi r-${R_VERSION}_1_amd64.deb && \
    rm r-${R_VERSION}_1_amd64.deb && \
    sudo ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R && \
    sudo ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# Install R libraries
RUN R -e "install.packages(c('tidyverse', \
                             'dplyr', 'tidyr', 'purrr', 'magrittr', \
                             'future', 'furrr', 'parallelly', \
                             'data.table', 'rlist', 'stringr', 'stringi', 'glue', \
                             'ggplot2', 'ggrastr', 'cowplot', 'gridExtra', \
                             'viridis', \
                             'Seurat', 'SeuratObject', \
                             'jsonlite', 'hdf5r', 'qpdf', 'qs', 'qs2', \
                             'devtools', 'remotes', 'R.utils', 'optparse', \
                             'IRkernel', 'BiocManager', 'doParallel', 'doRNG'), \
                             repos='http://cloud.r-project.org', \
                             Ncpus=$(($(nproc)/2))L)"


# Install micromamba
RUN curl -L micro.mamba.pm/install.sh | /bin/bash
RUN /bin/bash -lc "micromamba clean --locks"

# Install python packages
RUN /bin/bash -lc "micromamba install -c conda-forge -c bioconda python=3.11.2 jupyterlab \
                  scanpy anndata \
                  numpy pandas scipy scikit-learn \
                  matplotlib seaborn plotly pypdf \
                  networkx rustworkx igraph graph-tool \
                  umap-learn pynndescent leidenalg \
                  openpyxl pytables gseapy biomart"

RUN R -e "BiocManager::install(c('rhdf5'), ask = FALSE)"

RUN git clone https://github.com/google-deepmind/alphagenome.git /packages 

# Install IRkernel
RUN /bin/bash -lc "micromamba run R -e 'IRkernel::installspec(user = FALSE)'"

RUN git clone https://github.com/google-deepmind/alphagenome.git /workdir/alphagenome && \
	/root/micromamba/bin/python -m pip install ./workdir/alphagenome

# podman build -f Dockerfile -t jupyter-ext2 .
# podman save -o /mnt/disks/common2/images/jupyter-ext2.tar jupyter-ext2:latest
# sudo chmod -R 777 /mnt/disks/common2

