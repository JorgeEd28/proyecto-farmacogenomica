Docker for Shiny Server
=======================

This is a Dockerfile for Shiny Server on Debian "testing". It is based on the r-base image, rocker/shiny and flaviobarros/shiny-wordcloud.

## Usage:

### Build

```sh
docker docker build -t shiny-filtpeds .
```

You should have an image named `shiny-filtpeds` now. You can verify with:

```sh
docker images
```

### Run docker

To run a temporary container with Shiny Server:

```sh
docker run --rm -p 80:80 shiny-filtpeds
```

and it will avaliable at http://127.0.0.1/ or http://localhost/

You can run the container at other ports, if some service is running at PORT 80. To run the app at PORT 3838 for example, you can use:

```sh
docker run --rm -p 3838:80 shiny-filtpeds
```

It will avaliable at http://127.0.0.1:3838/ or http://localhost:3838/

In a real deployment scenario, you will probably want to run the container in detached mode (`-d`):

```sh
docker run -d -p 80:80 shiny-filtpeds
```
