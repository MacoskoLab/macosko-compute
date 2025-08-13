init_jupyterlab() {
    # Check if the 'jupyterlab' environment exists
    if micromamba env list | grep -q "jupyterlab"; then
        echo "JupyterLab environment found. Activating and starting JupyterLab..."
        micromamba activate jupyterlab
        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir='/workdir' --no-browser  &
    else
        echo "JupyterLab environment not found. Creating and starting JupyterLab..."
        # Create the environment

       # set password 
       expect -c 'spawn bash -lc "micromamba run jupyter lab password"; expect "Enter password:"; send "$env(USER)\r"; expect "Verify password:"; send "$env(USER)\r"; expect eof'

       micromamba create -n jupyterlab -y python=3.11.2 jupyterlab pandas -c conda-forge

        # Install the R kernel for JupyterLab
        micromamba run -n jupyterlab R -e 'IRkernel::installspec(user = FALSE)'

        # Activate the new environment
        micromamba activate jupyterlab


        # Start JupyterLab
        jupyter lab --allow-root --ip '0.0.0.0' --port '8787' --NotebookApp.token='' --NotebookApp.notebook_dir='/workdir' --no-browser &
    fi
}
