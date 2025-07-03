# quick look up for routine use commands

- command to connect to VM
```
gcloud compute ssh --zone "us-central1-a" "highmem1" --project "velina-208320"
```

## using tmux 

These are base set of commands needed. For more functionality offered by tmux, pls see tmux docs.

- starting tmux for a persistent session
```
tmux
```

- detaching from a persistent without stopping the session
```
Control-d # press key combination
```

- reattaching to an existing tmux session 
```
tmux attach
```

- to start and stop rstudio

```
rstudio # to start rstudio
```

```
rstudio-stop # to stop rstudio
```

## path to workdir on highmem1 machine

place any files to be viewed within the rstudio workdir here on the highmem1 filesystem

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

- to log out of highmem1
```
logout
```
