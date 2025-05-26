# Use CUDA 12.4
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive

# Export paths for CUDA and cuDNN
RUN echo $'\n\
    export CUDA_HOME=/usr/local/cuda \n\
    export PATH=/usr/local/cuda/bin:$PATH \n\
    export CPATH=/usr/local/cuda/include:/usr/include:$CPATH \n\
    export LIBRARY_PATH=/usr/local/cuda/lib64:$LIBRARY_PATH \n\
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH \n\
    eval "$(starship init bash)" \n\
' >> /root/.bashrc

# Install basic packages
RUN apt-get update --fix-missing && \
    apt-get install bzip2 ca-certificates curl wget git vim nano tree -y && \
    apt-get install pandoc texlive-xetex texlive-fonts-recommended texlive-plain-generic -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Conda Environment
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/anaconda.sh && \
    bash ~/anaconda.sh -b -p $HOME/anaconda && rm ~/anaconda.sh && \
    eval "$('/root/anaconda/bin/conda' 'shell.bash' 'hook')" && conda init && \
    conda config --set channel_priority strict

# Install Anaconda and JupyterLab
RUN eval "$('/root/anaconda/bin/conda' 'shell.bash' 'hook')" && \
    conda create -n lab python=3.12 anaconda nodejs -y && \
    echo "conda activate lab" >> /root/.bashrc && \
    conda clean -a && pip cache purge

# Setup JupyterLab plugins
RUN eval "$('/root/anaconda/bin/conda' 'shell.bash' 'hook')" && conda activate lab && \
    conda install -c conda-forge starship \
        jupyterlab-lsp python-lsp-server r-languageserver \
        jupyterlab_code_formatter jupyterlab-spellchecker \
        jupyter-resource-usage jupyterlab_execute_time \
        jupyterlab-latex texlab chktex jupyterlab-git && \
    pip install "ipywidgets>=8.0" jupyterlab_wakatime \
        lckr_jupyterlab_variableinspector && \
    npm set prefix /root && npm install -g --save-dev remark-language-server \
        remark-preset-lint-consistent remark-preset-lint-recommended && \
    conda clean -a && pip cache purge && npm cache clean --force && \
    jupyter labextension disable "@jupyterlab/apputils-extension:announcements" && \
    echo "jupyter lab" > /root/run_jupyter.sh

COPY JupyterLabConfig/jupyter_lab_config.py /root/.jupyter/jupyter_lab_config.py
COPY JupyterLabConfig/extensions/ /root/.jupyter/lab/user-settings/\@jupyterlab/
COPY JupyterLabConfig/jupyterlab-lsp/ /root/.jupyter/lab/user-settings/\@jupyter-lsp/jupyterlab-lsp/
COPY JupyterLabConfig/jupyterlab-lsp/unified_language_server.py /root/anaconda/envs/lab/lib/python3.12/site-packages/jupyter_lsp/specs/unified_language_server.py
COPY JupyterLabConfig/jupyterlab-lsp/remarkrc.yml /root/.remarkrc.yml
COPY JupyterLabConfig/notebooks/ /root/projects/demo_notebooks/
COPY JupyterLabConfig/channels.condarc /root/.condarc
COPY JupyterLabConfig/starship.toml /root/.config/starship.toml

# Install PyTorch and AI libs
RUN eval "$('/root/anaconda/bin/conda' 'shell.bash' 'hook')" && conda activate lab && \
    conda install -c pytorch -c nvidia -c conda-forge --strict-channel-priority \
        pytorch torchvision torchaudio pytorch-cuda=12.4 \
        transformers datasets spacy xgboost beautifulsoup4 && \
    pip install accelerate>=0.26.0 optuna requests arxiv rapidfuzz openai && \
    pip install -U pymilvus && \
    conda clean -a && pip cache purge

# Run JupyterLab on start
WORKDIR /root/projects
CMD ["/bin/bash", "-i", "/root/run_jupyter.sh"]
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
CMD curl -f -s http://localhost:80/lab || exit 1
