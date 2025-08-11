ARG base_image_name as base
FROM ${base_image_name}

# Copy custom entrypoint script into the image
# COPY --from=base /usr/local/bin/jstart /usr/local/bin/jstart

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


ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["jstart"]

