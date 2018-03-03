IMAGE_NAME := anatoliiv/docker-carla-vnc-desktop:latest
CONTAINER_NAME := carla_image_default
SSH_ADDRESS := "ssh root@localhost -p 2222"
SSH_PASSWORD := root
VNC_ADDRESS := localhost:5900

# -----------------------------------------------------------------------------
# DOCKER
# -----------------------------------------------------------------------------
.PHONY: docker
docker: login network build start

.PHONY: login
login:
	@grep -q "index.docker.io" ${HOME}/.docker/config.json > /dev/null 2>&1 || docker login

.PHONY: network
network:
	@docker network create $(CONTAINER_NAME) || true

.PHONY: build
build:
	@docker-compose build

.PHONY: start
start:
	@docker-compose up -d && \
	        echo && \
	        echo "Your SSH (password: $(SSH_PASSWORD)): $(SSH_ADDRESS)" && \
	        echo "Your VNC address: localhost:5900" && \
	        echo

.PHONY: stop
stop:
	@docker-compose down
