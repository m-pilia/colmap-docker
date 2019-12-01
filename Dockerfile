FROM nvidia/cuda:10.2-devel-ubuntu18.04

LABEL maintainer="Martino Pilia <martino.pilia@gmail.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND non-interactive
ENV DEBCONF_NOWARNINGS yes

# Install depencencies

# hadolint ignore=DL3008
RUN set -xeuo pipefail \
&&  apt-get update -y -qq \
&&  apt-get install -y -qq --no-install-recommends \
    build-essential \
    cmake \
    git \
    libatlas-base-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-program-options-dev \
    libboost-regex-dev \
    libboost-system-dev \
    libboost-test-dev \
    libcgal-dev \
    libcgal-qt5-dev \
    libeigen3-dev \
    libfreeimage-dev \
    libgflags-dev \
    libglew-dev \
    libgoogle-glog-dev \
    libqt5opengl5-dev \
    libsuitesparse-dev \
    libsuitesparse-dev \
    qtbase5-dev \
    vim \
&&  apt-get autoremove -y -qq \
&&  rm -rf /var/lib/apt/lists/*

ARG SOURCE_DIR=/sources
ARG CERES_SOURCE_DIR=${SOURCE_DIR}/ceres-solver
ARG COLMAP_SOURCE_DIR=${SOURCE_DIR}/colmap
ARG CMAKE_INSTALL_PREFIX=/usr

# Get sources

RUN mkdir "${SOURCE_DIR}"

RUN git clone https://ceres-solver.googlesource.com/ceres-solver "${CERES_SOURCE_DIR}" \
&&  git clone https://github.com/colmap/colmap.git "${COLMAP_SOURCE_DIR}"

# Build and install ceres-solver

ARG CERES_SOLVER_COMMIT=facb199f3e

RUN mkdir -p "${CERES_SOURCE_DIR}/build"
WORKDIR ${CERES_SOURCE_DIR}/build

RUN set -xeuo pipefail \
&&  git checkout "${CERES_SOLVER_COMMIT}" \
&&  git rev-parse HEAD > /ceres-solver-version \
&&  cmake .. \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DCMAKE_INSTALL_PREFIX:PATH="${CMAKE_INSTALL_PREFIX}" \
        -DBUILD_TESTING:BOOL=OFF \
        -DBUILD_EXAMPLES:BOOL=OFF \
&&  make -j4 \
&&  make install

# Build and install colmap

ARG COLMAP_COMMIT=f3d7aae3fd

RUN mkdir -p "${COLMAP_SOURCE_DIR}/build"
WORKDIR ${COLMAP_SOURCE_DIR}/build

RUN set -xeuo pipefail \
&&  git checkout "${COLMAP_COMMIT}" \
&&  git rev-parse HEAD > /colmap-version \
&&  cmake .. \
&&  make -j4 \
&&  make install

# Cleanup

WORKDIR /

RUN rm -rf "${SOURCE_DIR}"

CMD ["/bin/bash"]
