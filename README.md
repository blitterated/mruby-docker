# mruby-docker

An experiment it building and running `mruby` with extra mrbgems. Maybe it can even be used during the container build itself...

### Build the image

```sh
./build_image
```

### View the last build log

```sh
less $(ls -td1 logs/* | head -n1)
```

### Run a container

```sh
docker run -it --rm mruby
```
