ARG OSXCROSS_VERSION=13.1
ARG CLANG_VERSION=17
FROM ghcr.io/qno/windows-sdk as winsdk
FROM --platform=$BUILDPLATFORM crazymax/osxcross:${OSXCROSS_VERSION}-ubuntu as osxcross
FROM ubuntu:latest
ARG CLANG_VERSION
ENV LANG C.UTF-8

# Create unprivileged user
RUN groupadd -g 1000 build
RUN useradd --create-home --uid 1000 --gid 1000 --shell /bin/bash build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends wget build-essential python3-pip ninja-build g++ gcc git lsb-release software-properties-common gnupg
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" -- $CLANG_VERSION
RUN apt-get install -y --no-install-recommends clang-tools-$CLANG_VERSION clang-format-$CLANG_VERSION clang-tidy-$CLANG_VERSION
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang-apply-replacements clang-apply-replacements /usr/bin/clang-apply-replacements-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang-check clang-check /usr/bin/clang-check-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang-query clang-query /usr/bin/clang-query-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang-format-diff clang-format-diff /usr/bin/clang-format-diff-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-$CLANG_VERSION 100 && \
    update-alternatives --install /usr/bin/clang-tidy-diff clang-tidy-diff /usr/bin/clang-tidy-diff-$CLANG_VERSION.py 100 && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER build
WORKDIR /home/build/
CMD ["/bin/bash"]
RUN --mount=type=bind,from=osxcross,source=/osxcross,target=/osxcross cp -rf /osxcross .
RUN --mount=type=bind,from=winsdk,source=/WindowsSDK,target=/WindowsSDK cp -rf /WindowsSDK .
ENV PATH=".local/bin:${PATH}"
RUN pip3 install conan cmake gcovr --user
RUN conan profile detect
RUN pip3 cache purge
