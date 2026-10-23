# Jupyter Workspace: Preconfigured JupyterLab in Docker

A preconfigured JupyterLab workspace in Docker! `conda` installed. The `main` branch ships CUDA + PyTorch: by default, the JupyterLab server runs on an Anaconda environment with PyTorch and some other commonly used libraries installed. The `env/*` branches provide other environment variants.

This docker configuration is Ubuntu 22.04 LTS, CUDA version 12.4, cuDNN 9. You may change the base system and the CUDA version listed here: [nvidia/cuda | DockerHub](https://hub.docker.com/r/nvidia/cuda/tags?page=1).

CUDA Docker environment is supported by [Ubuntu nvidia cuda toolkit](https://packages.ubuntu.com/jammy/amd64/nvidia-cuda-toolkit). Instruction: [CUDA and cuDNN Install | Pop!_OS](https://support.system76.com/articles/cuda/). It should work on Windows as well, with WSL.

## Available Tags

- `latest`: Most recent build directly from the latest `main` branch.
- `v2.x.x`: JupyterLab installed with PyTorch GPU version `2.x.x`.
- Branch names: Snapshots of the project environment; refer to the branch README for more information.

Full list are available on [ghcr.io/muhac/jupyter-workspace | GitHub Container Registry](https://github.com/muhac/jupyter-pytorch-docker/pkgs/container/jupyter-workspace).

> **Note:** Images are now published to GitHub Container Registry as `ghcr.io/muhac/jupyter-workspace`. Older images remain available on Docker Hub as `muhac/jupyter-pytorch`; new builds are published only to `ghcr.io/muhac/jupyter-workspace`.

## Install & Usage

The image automatically runs a JupyterLab server on port `80`. Working directory in the container: `/root/projects`.

```bash
SERVER_PORT=${SERVER_PORT:-80}
PROJECT_DIR=${PROJECT_DIR:-$(pwd)}
TIME_ZONE=${TIME_ZONE:-America/Toronto}

docker run -d                      \
    --name jupyter-workspace       \
    --restart unless-stopped       \
    --ipc=host                     \
    --gpus all                     \
    --env TZ=$TIME_ZONE            \
    -p $SERVER_PORT:80             \
    -v $PROJECT_DIR:/root/projects \
    ghcr.io/muhac/jupyter-workspace:latest
```

You can use [this notebook](JupyterLabConfig/notebooks/PyTorchGPU.ipynb) to check your PyTorch GPU environment.

It is also possible to create your own conda environment and change `/root/.bashrc` to use a different one when starting JupyterLab. If you want to do this, make sure you keep all related files synced in the host system to prevent loss after pulling a new image.
