# FROM docker.io/rocker/rstudio
ARG base_image_name
FROM ${base_image_name}

RUN printf 'dir.create(c(paste0("/rstudio/",R.Version()$platform, "/packages")), recursive=TRUE, showWarnings = FALSE)\n.libPaths(c(paste0("/rstudio/",R.Version()$platform, "/packages"), .libPaths()))\nworkdir_path <- Sys.getenv("WORKDIR_PATH", "/workdir")\ndir.create(workdir_path, recursive=TRUE, showWarnings = FALSE)\nsetwd(workdir_path)\n' > /root/.Rprofile \
    && printf '{\n  "sync_files_pane_working_dir": true\n}\n' > /etc/rstudio/rstudio-prefs.json

