ARG OSXCROSS_VERSION=13.1
FROM ghcr.io/qno/windows-sdk as winsdk
FROM --platform=$BUILDPLATFORM crazymax/osxcross:${OSXCROSS_VERSION}-ubuntu AS osxcross
FROM ubuntu:latest
ENV LANG C.UTF-8

# Create unprivileged user
RUN groupadd -g 1000 build
RUN useradd --create-home --uid 1000 --gid 1000 --shell /bin/bash build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends wget build-essential python3-pip ninja-build g++ gcc git lsb-release software-properties-common gnupg
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -- 17
RUN apt-get install -y --no-install-recommends clang-tools-17 && \
    rm -rf /var/lib/apt/lists/*

USER build
WORKDIR /home/build/
CMD ["/bin/bash"]
RUN --mount=type=bind,from=osxcross,source=/osxcross,target=/osxcross cp -rf /osxcross .
RUN --mount=type=bind,from=winsdk,source=/WindowsSDK,target=/WindowsSDK cp -rf /WindowsSDK .
ENV PATH=".local/bin:${PATH}"
RUN pip3 install conan cmake gcovr --user
RUN conan profile detect
RUN pip3 cache purge
