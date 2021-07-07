# FROM debian:latest
# https://hub.docker.com/r/continuumio/miniconda/dockerfile
# FROM nvidia/cuda:9.0-base
# FROM nvidia/cuda:11.0-base-ubuntu20.04  # --gpu error
FROM nvidia/cuda:11.0-cudnn8-runtime-ubuntu18.04
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV TZ Asia/Seoul
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN conda install jupyter notebook
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN mkdir /docroot
WORKDIR /docroot

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "jupyter","notebook","--notebook-dir=/docroot","--ip","0.0.0.0", "--port", "7777" ,"--no-browser","--allow-root","--debug"]