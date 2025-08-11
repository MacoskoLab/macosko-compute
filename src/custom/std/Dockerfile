FROM debian:bookworm

# Install system libraries
RUN apt-get update && apt-get install -y  \
    sudo zip unzip less tree expect       \
    wget curl rsync socat                 \
    gdebi-core build-essential cmake pkg-config alien \
    libssl-dev libcurl4-openssl-dev


# Install R
RUN export R_VERSION=4.3.3 && \
    curl -O https://cdn.rstudio.com/r/debian-12/pkgs/r-${R_VERSION}_1_amd64.deb && \
    echo y | gdebi r-${R_VERSION}_1_amd64.deb && \
    rm r-${R_VERSION}_1_amd64.deb && \
    sudo ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R && \
    sudo ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# Install R libraries
RUN R -e "install.packages(c('tidyverse', \
                             'IRkernel'), \
                             repos='http://cloud.r-project.org', \
                             Ncpus=$(nproc)L)"


# Install micromamba
RUN curl -L micro.mamba.pm/install.sh | /bin/bash
RUN /bin/bash -lc "micromamba clean --locks"

# Ensure MAMBA_ROOT_PREFIX is set in shell initialization
RUN echo 'export MAMBA_ROOT_PREFIX="/jupyter/micromamba"' >> /root/.bashrc

# Create a smart jstart script that checks for "jupyterlab" environment
# if present, activates it, starts jupyter lab as bg process
# if "jupyterlab" env doesn't exit, drop user into a bash prompt
# add jstart function to /usr/local/bin
RUN echo '#!/bin/bash --login' > /usr/local/bin/jstart && \
    echo 'if micromamba env list | grep -q "jupyterlab"; then' >> /usr/local/bin/jstart && \
    echo '  micromamba activate jupyterlab' >> /usr/local/bin/jstart && \
    echo '  jupyter lab --allow-root --ip "*" --port "8787" --NotebookApp.token="" --NotebookApp.notebook_dir="/workdir" --no-browser &' >> /usr/local/bin/jstart && \
    echo '  exec /bin/bash --login' >> /usr/local/bin/jstart && \
    echo 'else' >> /usr/local/bin/jstart && \
    echo '  echo "jupyterlab environment not found. Dropping to shell..."' >> /usr/local/bin/jstart && \
    echo '  exec /bin/bash --login' >> /usr/local/bin/jstart && \
    echo 'fi' >> /usr/local/bin/jstart && \
    chmod +x /usr/local/bin/jstart

# ENTRYPOINT is /bin/bash
ENTRYPOINT ["/bin/bash", "-lc"]

CMD ["jstart"]

# podman build -f Dockerfile -t custom-std .
# podman save -o /mnt/disks/common/images/custom-std.tar custom-std:latest
# sudo chmod -R 777 /mnt/disks/common
