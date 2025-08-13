ARG base_image_name as base
FROM ${base_image_name}

ARG USER=REQUIRED
RUN [ "$USER" != "REQUIRED" ]

# set env variable USER for container
ENV USER=${USER}

# Copy init environment script
COPY init_jupyterlab.sh /usr/local/bin/init_jupyterlab.sh
RUN chmod +x /usr/local/bin/init_jupyterlab.sh

# Copy custom entrypoint script into the image
# COPY --from=base /usr/local/bin/jstart /usr/local/bin/jstart

# Create jstart script that sources init script and drops to bash shell
RUN echo '#!/bin/bash --login' > /usr/local/bin/jstart && \
    echo 'source /usr/local/bin/init_jupyterlab.sh' >> /usr/local/bin/jstart && \
    echo 'init_jupyterlab' >> /usr/local/bin/jstart && \
    chmod +x /usr/local/bin/jstart
    # echo 'exec /bin/bash --login' >> /usr/local/bin/jstart && \

RUN echo "wd <- '/workdir'\nif (dir.exists(wd)) {\n  setwd(wd)\n  pd <- file.path(wd, 'R-packages')\n  if (!dir.exists(pd)) {dir.create(pd)}\n  .libPaths(c(pd, .libPaths()))\n  if (.libPaths()[1] != pd) {print('WARNING: Could not set user package directory')}\n} else {\n  print('WARNING: /workdir directory not found')\n}\nsuppressWarnings(rm(wd,pd))" > /root/.Rprofile

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["jstart"]

