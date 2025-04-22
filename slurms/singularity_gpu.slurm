#!/bin/bash
#SBATCH --job-name=singularity_flair      # nom du job
##SBATCH --partition=gpu_p2            # de-commente pour la partition gpu_p2
#SBATCH --ntasks=1                     # nombre total de taches (= nombre de GPU ici)
#SBATCH --gres=gpu:1                   # nombre de GPU per nœud (1/4 des GPU)
#SBATCH --cpus-per-task=10             # nombre de coeurs CPU par tache (1/4 du noeud 4-GPU)
#SBATCH --hint=nomultithread           # hyperthreading desactive
#SBATCH --time=00:30:00             # temps maximum d'execution demande (HH:MM:SS)
#SBATCH --qos=qos_gpu-dev
#SBATCH --output=/lustre/fswork/projects/rech/tel/uug84ql/logs/SingularityGPU%j.out  # Nom du fichier de sortie
#SBATCH --error=/lustre/fswork/projects/rech/tel/uug84ql/logs/SingularityGPU%j.out   # Nom du fichier d'erreur (ici commun avec la sortie)
#SBATCH --account=tel@v100

# on se place dans le répertoire de soumission
cd ${SLURM_SUBMIT_DIR}

# nettoyage des modules charges en interactif et herites par defaut
module purge

# chargement des modules
module load singularity

# echo des commandes lancées
set -x

srun singularity exec --nv \
	--no-mount $HOME \
	--bind /lustre/fsn1/projects/rech/tel/commun/dataset_ocs/FLAIR-INC/:/data \
	--bind /lustre/fsn1/worksf/projects/rech/tel/uug84ql/FLAIR_INC_BASELINES/:/output:rw \
	--bind /lustre/fsn1/worksf/projects/rech/tel/uug84ql/flair_debug:/app \
	--bind /lustre/fswork/projects/rech/tel/uug84ql/debug_csvs:/csvs \
	--bind /lustre/fsn1/worksf/projects/rech/tel/uug84ql/.cache/torch:/torch_home \
	--bind /lustre/fsn1/projects/rech/tel/uug84ql/torch_tmp:/tmpdir \
	--env TORCH_HOME="/torch_home" \
	--env TMPDIR="/tmpdir" \
	$SINGULARITY_ALLOWED_DIR/flairhub_v1.0.sif \
	mamba run -n flairhub python /app/src/flair_inc/main.py --conf_folder /app/configs/debug_1_gpu
