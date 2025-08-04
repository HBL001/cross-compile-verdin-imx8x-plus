# Verdin iMX8MP Cross-Compilation Container with Qt5, GStreamer, SDL2
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install host-side build tools and helpers
RUN apt-get update && apt-get install -y \
    build-essential \
    bash \
    git \
    sudo \
    curl \
    wget \
    rsync \
    locales \
    xz-utils \
    unzip \
    file \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    libssl-dev \
    pkg-config \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libegl1-mesa-dev \
    libwayland-dev \
    libxkbcommon-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale (required for SDK compatibility)
RUN locale-gen en_US.UTF-8

# Define SDK installation paths
ENV SDK_INSTALL_DIR=/opt/sdk
ENV SDK_SETUP_SCRIPT=${SDK_INSTALL_DIR}/environment-setup-aarch64-tdx-linux

# Copy in the Yocto SDK for Verdin iMX8MP
COPY tdx-xwayland-glibc-x86_64-Reference-Multimedia-Image-armv8a-verdin-imx8mp-toolchain-7.3.0.sh /tmp/sdk.sh

# Install the SDK non-interactively
RUN chmod +x /tmp/sdk.sh && \
    /tmp/sdk.sh -d $SDK_INSTALL_DIR -y && \
    rm /tmp/sdk.sh

# Automatically source SDK toolchain in all interactive shells
RUN echo "source $SDK_SETUP_SCRIPT" >> /etc/profile.d/99-verdin-sdk.sh

# Export toolchain path explicitly for Docker-based builds (optional)
ENV PATH="${SDK_INSTALL_DIR}/sysroots/x86_64-tdxsdk-linux/usr/bin:$PATH"
ENV CROSS_COMPILE="aarch64-tdx-linux-"

# Optional: Predefine common environment used by cmake / pkg-config
ENV PKG_CONFIG_SYSROOT_DIR="${SDK_INSTALL_DIR}/sysroots/aarch64-tdx-linux"
ENV PKG_CONFIG_PATH="${SDK_INSTALL_DIR}/sysroots/aarch64-tdx-linux/usr/lib/pkgconfig:${SDK_INSTALL_DIR}/sysroots/aarch64-tdx-linux/usr/share/pkgconfig"

# Optional: Set qmake if Qt5 is included in your image
ENV QMAKE="${SDK_INSTALL_DIR}/sysroots/x86_64-tdxsdk-linux/usr/bin/qmake"

# Working directory for your projects
WORKDIR /workspace

# Default shell
CMD ["/bin/bash"]
