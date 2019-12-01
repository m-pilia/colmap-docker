![](https://github.com/m-pilia/colmap-docker/workflows/Hadolint/badge.svg)
![](https://img.shields.io/docker/build/martinopilia/colmap)

# Colmap docker

Docker image to run [Colmap](https://colmap.github.io/)
([GitHub](https://github.com/colmap/colmap)), an open source
[structure-from-motion](https://en.wikipedia.org/wiki/Structure_from_motion)
toolbox.

```
docker run \
    -it \
    --rm \
    --user $(id -u):$(id -g) \
    --userns=host \
    --net=host \
    --ipc=host \
    --gpus all \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix/:/tmp/.X11-unix:ro \
    -v ${HOME}/.Xauthority:/home/$(whoami)/.Xauthority:ro \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    martinopilia/colmap:latest
```

# License

MIT
