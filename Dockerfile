#FROM nvidia/cuda:10.1-cudnn8-devel-ubuntu18.04
#FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu18.04 
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

ARG PYTHON_VERSION=3.7
ARG WITH_TORCHVISION=1


RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         ca-certificates \
	 apt-utils apt-transport-https pkg-config \
	 software-properties-common \
         libjpeg-dev \
	 libopencv-dev \
         libpng-dev \
	 libopenexr-dev \
	 # Blender and openSCAD are soft dependencies used in Trimesh for boolean operations with subprocess
	 vim \
     tmux && \
     rm -rf /var/lib/apt/lists/*


# Install the third-party packages.
RUN apt-get update --fix-missing -y
RUN apt-get install -y wget git curl vim
RUN apt-get install -y blender 

# install conda
RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \

    /opt/conda/bin/conda config --add channels conda-forge && \
     /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy jupyter ipython mkl mkl-include ninja cython typing && \
     /opt/conda/bin/conda install -y -c conda-forge scikit-image shapely rtree pyembree && \
     /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH


#RUN find /opt/conda -type d -exec chmod 777 \{\} \;
#RUN find /opt/conda -type f -exec chmod o+rw \{\} \;


# Install the base PIP packages.
SHELL ["/opt/conda/bin/conda", "run", "-n", "base", "/bin/bash", "-c"]
RUN pip install --upgrade pip

RUN /bin/bash -c "source activate base" && \
    pip install --upgrade pip &&\
    pip install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu113

RUN /bin/bash -c "source activate base" && \
    pip install opencv-python setuptools numpy PyYAML Cython &&\
    pip install black==19.3.b0 flake8-comprehensions==3.3.0 flake8-bugbear==20.1.4 &&\
    pip install flake8==3.8.4 isort==4.3.21 m2r2 mccabe==0.6.1 mock sphinx &&\
    pip install sphinx_markdown_tables sphinx_rtd_theme argparse tqdm tensorboard &&\
    pip install ipdb

# install meshlabserver
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#     xvfb libglu1-mesa libglib2.0-0 libgomp1 \
#         libglvnd0 \
#     libgl1 \
#     libglx0 \
#     libegl1 \
#     libgles2 \
#     libglvnd-dev \
#     libgl1-mesa-dev \
#     libegl1-mesa-dev \
#     libgles2-mesa-dev \
#     &&\
#     apt-get clean && rm -rf /var/lib/apt/lists/*


COPY ./requirements.txt /tmp/requirements.txt

RUN cd /tmp && \
    /bin/bash -c "source activate base" && \
    pip install -r requirements.txt

ENV CUDA_VERSION=11.3
ENV CUDA_HOME=/usr/local/cuda-11.3

#SHELL ["/bin/bash", "-c"]
# CMD ["/bin/bash", "-l", "-c", "source activate base && CUDA_HOME=/usr/local/cuda-11.3"]

# Create a new user.
# RUN useradd -ms /bin/bash cai
# Copy the contents of the local directory to the working directory.

#USER root
#COPY DALLE2-pytorch /tmp


#RUN chmod -R  0777 /home/cai/*
#RUN chown cai /home/cai

#RUN find /home/cai -type d -exec chmod 777 \{\} \;
#RUN find /home/cai -type f -exec chmod o+rw \{\} \;

#USER cai

#WORKDIR /home/cai
#ENV HOME=/home/cai
#ENTRYPOINT ["/home/cai/AvatarCLIP"]
