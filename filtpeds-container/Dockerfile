FROM r-base:latest

MAINTAINER Sergio Villicana "sergio.artsc@gmail.com"
## Based on rocker/shiny and flaviobarros/shiny-wordcloud

## Install dependencies and Download and install shiny server

## See https://www.rstudio.com/products/shiny/download-server/ for the
## instructions followed here.

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libxt-dev \
    libssl-dev \
    libxml2 \
    libxml2-dev

RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

RUN R -e "install.packages(c('Rcpp', 'shiny', 'DT', 'rmarkdown', 'dplyr', 'shinythemes'), repos='https://cran.rstudio.com/')"

COPY shiny-server.sh /usr/bin/shiny-server.sh
## Include a custom configuration file. You can download the default file at
## https://raw.githubusercontent.com/rstudio/shiny-server/master/config/default.config
## Documentation on configuration options is available at
## http://docs.rstudio.com/shiny-server/
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
## Copy app to docker
COPY /filtpeds_tool /srv/shiny-server/

EXPOSE 80

CMD ["/usr/bin/shiny-server.sh"]
