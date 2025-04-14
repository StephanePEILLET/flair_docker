include config.env

.PHONY: all docker_build docker_run docker_build_no_entrypoint docker_push docker_push docker_clean apptainer_build_from_docker apptainer_build apptainer_run apptainer_clean docker_free_space

all: 
	docker_build
	docker_run
	docker_clean

docker_build:
	docker build -t ${IMAGE_NAME}:${IMAGE_TAG} --rm .

docker_build_no_entrypoint:
	docker build -f flairhub_noentrypoint.dockerfile -t ${IMAGE_NAME}:${IMAGE_TAG}_no_entrypoint --rm .

docker_run:
	docker run --gpus all --ipc host --rm \
		-v ${PATH_DATA}:/data \
		-v ${OUTPUT_FOLDER}:/output \
		-v ${CODE_REPO}:/app \
		-v ${CSV_FOLDER}:/csvs \
		${IMAGE_NAME}:${IMAGE_TAG} --conf_folder "./configs/debug_docker"
    # si variable d'environnement
    # -e HF_HUB_CACHE=$WORK/HF-MODELS-PRETRAINED \
    # -e HF_DATASETS_OFFLINE=1 \  
    # -e TRANSFORMERS_OFFLINE=1 \

docker_push:
	docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
	docker push ${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}

docker_clean:
	docker image rmi ${IMAGE_NAME}:${IMAGE_TAG}

apptainer_build_from_docker:
	singularity build --fakeroot --disable-cache ${IMAGE_NAME}_${IMAGE_TAG}.sif docker-daemon://${IMAGE_NAME}:${IMAGE_TAG}

apptainer_build:
	singularity build --fakeroot --disable-cache ${IMAGE_NAME}_${IMAGE_TAG}.sif flairhub_singularity.def

apptainer_run:
	singularity exec --nv \
		--bind ${PATH_DATA}:/data \
		--bind ${OUTPUT_FOLDER}:/output \
		--bind ${CODE_REPO}:/app \
		--bind ${CSV_FOLDER}:/csvs \
		${IMAGE_NAME}_${IMAGE_TAG}.sif --conf_folder "./configs/debug_docker"

apptainer_clean:
	singularity cache clean
	rm -f ${IMAGE_NAME}_${IMAGE_TAG}.sif
	rm -f ${IMAGE_NAME}_${IMAGE_TAG}.sif.lock
	rm -f ${IMAGE_NAME}_${IMAGE_TAG}.sif.tmp
	rm -f ${IMAGE_NAME}_${IMAGE_TAG}.sif.lock.tmp

docker_free_space:
	docker rmi $(docker images -f "dangling=true" -q)
	docker image prune -a -f
	docker container prune -f
	docker volume prune -f
	docker network prune -f
	docker system prune -a --volumes -f