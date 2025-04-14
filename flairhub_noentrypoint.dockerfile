########################################################################
## Image environnement FLAIR
########################################################################
FROM condaforge/mambaforge

ARG http_proxy=""
ARG https_proxy=""
ARG no_proxy=""

ENV http_proxy="http://proxy.ign.fr:3128"
ENV https_proxy="http://proxy.ign.fr:3128"
ENV no_proxy="localhost,127.0.0.1"

# Nécessaire pour éviter les messages d'erreur issue de l'installation de libgl1
ARG DEBIAN_FRONTEND=noninteractive

# Mise à jour image
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && apt-get install -fy fish ranger zip libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN mamba update -n base -c conda-forge conda

# Création de l'environnement
COPY env/flairhub.yml /home/flairhub.yml
RUN mamba env update --name base --file=/home/flairhub.yml

#Definition du bash qui sera utilisé
SHELL ["mamba", "run", "-n", "base", "/bin/bash", "-c"]

# Nettoyage
RUN mamba clean --all --yes
RUN apt-get clean && \
    apt-get autoremove

WORKDIR /app
RUN conda init fish
ENV MAMBA_ROOT_PREFIX='/opt/conda'
CMD fish