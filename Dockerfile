# Dockerfile to deploy a llama-cpp container with conda-ready environments

# docker pull continuumio/miniconda3:latest

ARG TAG=latest
FROM continuumio/miniconda3:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        uvicorn \
        libportaudio2 \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        wget \
        openssh-server \
        ca-certificates \
        netbase\
        tzdata \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        ncdu \
        ffmpeg \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4  \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Create user:
RUN groupadd --gid 1020 vosk-group
RUN useradd -rm -d /home/vosk-user -s /bin/bash -G users,sudo,vosk-group -u 1000 vosk-user

RUN python3 -m pip install torch torchvision torchaudio

# Устанавливаем модуль для распознавания текста:
RUN python3 -m pip install vosk

# FastApi
RUN python3 -m pip install pydantic uvicorn[standard] fastapi

RUN python3 -m pip install torch torchvision torchaudio

# Update user password:
RUN echo 'vosk-user:admin' | chpasswd

RUN mkdir /home/vosk-user/vosk

RUN mkdir /home/vosk-user/vosk/src

RUN mkdir /home/vosk-user/vosk/model

RUN cd /home/vosk-user/vosk

# Тут переместить app.py в корень (для fastapi, все переезжает в папку до src)
ADD src/fast.py /home/vosk-user/vosk/src

ADD src/stt.py /home/vosk-user/vosk/

COPY model/vosk/complete/small4/model /home/vosk-user/vosk/model

# ----------------------------- Сборка Rest-api:

# Preparing for login
RUN chmod 777 /home/vosk-user/vosk
ENV HOME /home/vosk-user/vosk/
WORKDIR ${HOME}
USER vosk-user

CMD uvicorn src.fast:app --host 0.0.0.0 --port 8085 --reload

# Docker:
# docker build -t vosk .
# docker run -it -dit --name vosk -p 8085:8085  --gpus all --restart unless-stopped vosk:latest

# Debug:
# docker container attach vosk