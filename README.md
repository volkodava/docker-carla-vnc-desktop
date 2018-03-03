# docker-carla-vnc-desktop

VNC/SSH Carla server inside a docker container. 

### Getting up and running

1. Install docker on OS of your choice by following instructions at [Run Docker anywhere](https://docs.docker.com/#run-docker-anywhere)

2. Register in `EpicGames` organisation `Unreal Engine` by following instructions at [Signup](https://github.com/EpicGames/Signup)

3. Checkout source code of `Unreal Engine` into the directory with `Dockerfile` using next command:
```bash
git clone --depth=1 -b 4.18 git@github.com:EpicGames/UnrealEngine.git UnrealEngine_4.18
```

4. Build docker image using next command:
```bash
make build
```

5. Run docker image using next command:
```bash
make start
```

6. Connect to docker image can be done:
    - via `VNC` using next address: `localhost:5900`
    - via `SSH` using next command (password: `root`): 
```bash
ssh root@localhost -p 2222
```

7. Stop docker image using next command:
```bash
make stop
```

# Issues

For troubleshooting check `/var/log` inside a container.
