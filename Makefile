include config.env

.PHONY: all docker_build docker_run docker_build_no_entrypoint docker_push docker_push docker_clean singularity_build_from_docker singularity_build singularity_run singularity_clean docker_free_space

all:
	docker_build
	docker_run
	docker_clean

docker_build:
	docker build \
		--build-arg http_proxy=${HTTP_PROXY} \
		--build-arg https_proxy=${HTTPS_PROXY} \
		--build-arg no_proxy=${NO_PROXY} \
		-t ${IMAGE_NAME}:${IMAGE_TAG} --rm .

docker_build_no_entrypoint:
	docker build \
	--build-arg http_proxy=${HTTP_PROXY} \
	--build-arg https_proxy=${HTTPS_PROXY} \
	--build-arg no_proxy=${NO_PROXY} \
	-f flairhub_noentrypoint.dockerfile -t ${IMAGE_NAME}:${IMAGE_TAG}_no_entrypoint --rm .

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

singularity_build_from_docker:
	singularity build --fakeroot ${IMAGE_NAME}_${IMAGE_TAG}.sif flairhub.def  
#singularity build --fakeroot --disable-cache ${IMAGE_NAME}_${IMAGE_TAG}.sif docker-daemon://${IMAGE_NAME}:${IMAGE_TAG} # cas sans rééciture de l'entrypoint

singularity_build_from_dockerhub:
	singularity build --fakeroot --no-https --no-cleanup ${IMAGE_NAME}_${IMAGE_TAG}.sif docker://${USER_NAME}/${IMAGE_NAME}:${IMAGE_TAG}

singularity_build:
	singularity build --fakeroot ${IMAGE_NAME}_${IMAGE_TAG}.sif flairhub_singularity.def

singularity_run:
	singularity exec --nv --fakeroot\
		--bind ${PATH_DATA}:/data \
		--bind ${OUTPUT_FOLDER}:/output:rw \
		--bind ${CODE_REPO}:/app \
		--bind ${CSV_FOLDER}:/csvs \
		${IMAGE_NAME}_${IMAGE_TAG}.sif \
		mamba run -n flairhub python /app/src/flair_inc/main.py --conf_folder /app/configs/debug_docker

singularity_shell:
	singularity exec --nv --fakeroot\
		--bind ${PATH_DATA}:/data \
		--bind ${OUTPUT_FOLDER}:/output:rw \
		--bind ${CODE_REPO}:/app \
		--bind ${CSV_FOLDER}:/csvs \
		${IMAGE_NAME}_${IMAGE_TAG}.sif \
		mamba run -n flairhub fish

singularity_clean:
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