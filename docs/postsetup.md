# quick look up for routine use commands

## commands to connect to VM and logout

- connect to highmem1
    ```
    gcloud compute ssh --zone "us-central1-a" "highmem1" --project "velina-208320"
    ```

- to log out of highmem1
    ```
    logout
    ```

## using tmux 

These are base set of commands needed. For more functionality offered by tmux, pls see tmux docs.

- starting tmux for a persistent session
    ```
    tmux
    ```

- detaching from a persistent without stopping the session
    ```
    Control+b then d # press key combination
    ```

- reattaching to an existing tmux session 
    ```
    tmux attach
    ```

## using rstudio

    ```
    rstudio # to start rstudio
    ```

    ```
    rstudio-stop # to stop rstudio
    ```
## using custom jupyter lab

    ```
    custom2 # to start custom jupyter lab 
    ```

    ```
    custom-stop # to stop custom jupyter lab
    ```
- managing enviromemnts and installing R and Python packages in custom jupyter lab's environments

    - use `custom2 -e <envname>` to start jupyter lab with a specified micromamba environment name for package isolation between projects
    - see [here](/docs/custom.md) for steps to install R and python packages within custom environments

## path to workdir on highmem1 machine

place any files/data to be accessed within the rstudio or jupyter working directory here on the highmem1 filesystem

```
/mnt/disks/$USER/workdir
```

## sample commands to copy a file to and from google cloud storage bucket


- to copy from bucket (modify file paths as needed)
    ```
    gcloud storage cp gs://<path-to-file-on-bucket> .
    ```

- to copy to bucket (modify file paths as needed)
    ```
    gcloud storage cp <path-to-local-file> <path-to-file-on-bucket>
    ```

