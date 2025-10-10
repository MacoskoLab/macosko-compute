ARG base_image_name as base
FROM ${base_image_name}

ARG USER=REQUIRED
RUN [ "$USER" != "REQUIRED" ]

ARG ENVNAME=jupyterlab

# set env variable USER for container
ENV USER=${USER}
ENV ENVNAME=${ENVNAME}
ENV JUPYTER_CONFIG_DIR=/jupyter/.jupyter
ENV GIT_CONFIG_GLOBAL=/.git/.gitconfig

RUN echo 'export JUPYTER_CONFIG_DIR="/jupyter/.jupyter"' >> /root/.bashrc

# Copy init environment script
COPY init_mmenv.sh /usr/local/bin/init_mmenv.sh
RUN chmod +x /usr/local/bin/init_mmenv.sh

# Copy custom entrypoint script into the image
# COPY --from=base /usr/local/bin/jstart /usr/local/bin/jstart

# Create jstart script that sources init script and drops to bash shell
RUN echo '#!/bin/bash --login' > /usr/local/bin/jstart && \
    echo '# Save env vars to file on first run if not already saved' >> /usr/local/bin/jstart && \
    echo 'if [ ! -f /tmp/.container_env ]; then' >> /usr/local/bin/jstart && \
    echo '  if [ -n "$HOST_IP" ] || [ -n "$HOST_PORT" ]; then' >> /usr/local/bin/jstart && \
    echo '    echo "export HOST_IP=\"$HOST_IP\"" > /tmp/.container_env' >> /usr/local/bin/jstart && \
    echo '    echo "export HOST_PORT=\"$HOST_PORT\"" >> /tmp/.container_env' >> /usr/local/bin/jstart && \
    echo '  fi' >> /usr/local/bin/jstart && \
    echo 'fi' >> /usr/local/bin/jstart && \
    echo '# Load env vars from file if it exists' >> /usr/local/bin/jstart && \
    echo 'if [ -f /tmp/.container_env ]; then' >> /usr/local/bin/jstart && \
    echo '  source /tmp/.container_env' >> /usr/local/bin/jstart && \
    echo 'fi' >> /usr/local/bin/jstart && \
    echo 'source /usr/local/bin/init_mmenv.sh' >> /usr/local/bin/jstart && \
    echo 'init_mmenv "${1:-${ENVNAME:-jupyterlab}}" "${WORKDIR_PATH:-/workdir}"' >> /usr/local/bin/jstart && \
    chmod +x /usr/local/bin/jstart
    # echo 'exec /bin/bash --login' >> /usr/local/bin/jstart && \

RUN echo "wd <- Sys.getenv('WORKDIR_PATH', '/workdir')\nenvname <- Sys.getenv('CONDA_DEFAULT_ENV', unset = Sys.getenv('ENVNAME'))\npd <- file.path(wd, 'R-packages', envname)\nif (!dir.exists(pd)) {dir.create(pd, recursive = TRUE)}\n.libPaths(c(pd, .libPaths()))\nif (.libPaths()[1] != pd) {print('WARNING: Could not set user package directory')}\nif (dir.exists(wd)) {setwd(wd)}\nsuppressWarnings(rm(wd,pd,envname))" > /root/.Rprofile

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["jstart", "jupyterlab"]

