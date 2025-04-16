########################################################################
## Image environnement FLAIR
########################################################################
FROM condaforge/mambaforge

ARG http_proxy=""
ARG https_proxy=""
ARG no_proxy=""

ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV no_proxy=${no_proxy}

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
RUN mamba env create --file=/home/flairhub.yml

# Definition du bash qui sera utilisé
SHELL ["mamba", "run", "-n", "flairhub", "/bin/bash", "-c"]

# Nettoyage
RUN mamba clean --all --yes
RUN apt-get clean && \
    apt-get autoremove

WORKDIR /app

# Si utilisation du container en interactif avec fish
ENV MAMBA_ROOT_PREFIX='/opt/conda'
ENTRYPOINT ["mamba", "run", "-n", "flairhub", "python", "/app/src/flair_inc/main.py"]
