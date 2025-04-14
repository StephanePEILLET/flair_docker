#!/usr/bin/env
command_to_execute="$*"

# Vérifie qu'au moins un argument a été fourni
if [ -z "$command_to_execute" ]; then
    echo "Erreur : Veuillez fournir une commande à exécuter."
    echo "Usage : $0 [command]"
    exit 1
fi

# Exécute la commande avec Python
# eval "$(conda shell.bash hook)" && conda activate flairhub
eval "$command_to_execute"