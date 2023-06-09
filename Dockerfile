FROM ubuntu:18.04

WORKDIR /app

COPY . .

EXPOSE 8000

RUN apt-get update -y \
&& apt-get install libdb-dev libncurses-dev libgmp-dev libxml2-dev libjson-c-dev -y \
&& apt-get install wget gcc gettext make -y \
&& rm -rf /var/lib/apt/lists/*

RUN wget 'https://ci.appveyor.com/api/projects/GitMensch/gnucobol-3-x/artifacts/gnucobol-3.2-dev.tar.gz?job=Image:%20Ubuntu2004' -O gnucobol-3.2-dev.tar.gz \
&& tar zxf gnucobol-3.2-dev.tar.gz \
&& rm gnucobol-3.2-dev.tar.gz \
&& mkdir obj \
&& (cd gnucobol-3.2-dev && ./configure && make -j12 && make install) \
&& rm -rf gnucobol-3.2-dev \
&& ldconfig \
&& make default example
