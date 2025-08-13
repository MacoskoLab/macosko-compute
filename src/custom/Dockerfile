ARG base_image_name as base
FROM ${base_image_name}

# Copy init environment script
COPY init_jupyterlab.sh /usr/local/bin/init_jupyterlab.sh
RUN chmod +x /usr/local/bin/init_jupyterlab.sh

# Copy custom entrypoint script into the image
# COPY --from=base /usr/local/bin/jstart /usr/local/bin/jstart

# Create jstart script that sources init script and drops to bash shell
RUN echo '#!/bin/bash --login' > /usr/local/bin/jstart && \
    echo 'source /usr/local/bin/init_jupyterlab.sh' >> /usr/local/bin/jstart && \
    echo 'init_jupyterlab' >> /usr/local/bin/jstart && \
    echo 'exec /bin/bash --login' >> /usr/local/bin/jstart && \
    chmod +x /usr/local/bin/jstart

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["jstart"]

