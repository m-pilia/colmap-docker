FROM nvidia/cuda:10.2-devel-ubuntu18.04 as builder

SHELL ["/bin/bash", "-xeu", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND non-interactive
ENV DEBCONF_NOWARNINGS yes

# Install depencencies

RUN apt-get update -y -qq \
&&  apt-get install -y -qq --no-install-recommends \
    build-essential \
    ca-certificates \
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
    qtbase5-dev \
&&  apt-get autoremove -y -qq \
&&  rm -rf /var/lib/apt/lists/*

ARG SOURCE_DIR=/sources
ARG CERES_SOURCE_DIR=${SOURCE_DIR}/ceres-solver
ARG COLMAP_SOURCE_DIR=${SOURCE_DIR}/colmap
ARG CMAKE_INSTALL_PREFIX=/usr/local

# Get sources

RUN mkdir "${SOURCE_DIR}"

RUN git clone https://ceres-solver.googlesource.com/ceres-solver "${CERES_SOURCE_DIR}" \
&&  git clone https://github.com/colmap/colmap.git "${COLMAP_SOURCE_DIR}"

# Build and install ceres-solver

ARG CERES_SOLVER_COMMIT=facb199f3e

RUN mkdir -p "${CERES_SOURCE_DIR}/build"
WORKDIR ${CERES_SOURCE_DIR}/build

RUN git checkout "${CERES_SOLVER_COMMIT}" \
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

RUN git checkout "${COLMAP_COMMIT}" \
&&  git rev-parse HEAD > /colmap-version \
&&  cmake .. \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DCMAKE_INSTALL_PREFIX:PATH="${CMAKE_INSTALL_PREFIX}" \
        -DBUILD_TESTING:BOOL=OFF \
        -DBUILD_EXAMPLES:BOOL=OFF \
&&  make -j4 \
&&  make install

# Create final image

FROM nvidia/cuda:10.2-devel-ubuntu18.04

LABEL maintainer="Martino Pilia <martino.pilia@gmail.com>"

# Install runtime dependencies
RUN apt-get update -y -qq \
&&  apt-get install -y -qq --no-install-recommends \
    libatlas3-base \
    libboost-filesystem1.65.1 \
    libboost-graph1.65.1 \
    libboost-program-options1.65.1 \
    libboost-regex1.65.1 \
    libboost-system1.65.1 \
    libboost-test1.65.1 \
    libcgal13 \
    libcgal-qt5-13 \
    libfreeimage3 \
    libgflags2.2 \
    libglew2.0 \
    libgoogle-glog0v5 \
    libqt5opengl5 \
    libamd2 \
    libbtf1 \
    libcamd2 \
    libccolamd2 \
    libcholmod3 \
    libcolamd2 \
    libcxsparse3 \
    libgraphblas1 \
    libklu1 \
    libldl2 \
    librbio2 \
    libspqr2 \
    libsuitesparseconfig5 \
    libumfpack5 \
&&  apt-get autoremove -y -qq \
&&  rm -rf /var/lib/apt/lists/*

# Copy build artifacts
COPY --from=builder /usr/local /usr/local
COPY --from=builder /*-version /

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

CMD ["/bin/bash"]
