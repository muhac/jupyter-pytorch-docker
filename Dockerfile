FROM python:3.11
SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN pip install transformers datasets accelerate openai sentencepiece huggingface_hub[cli] && \
    pip cache purge

# Run JupyterLab on start
WORKDIR /root/projects
CMD ["/bin/bash", "-i", "echo 0"]
