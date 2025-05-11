FROM registry.gitlab.com/islandoftex/images/texlive:latest
# FROM registry.gitlab.com/islandoftex/images/texlive:TL2024-2025-02-09-full

ARG TARGETARCH

LABEL \
  org.opencontainers.image.title="Full TeX Live with additions" \
  org.opencontainers.image.authors="Oliver Kopp <kopp.dev@gmail.com>" \
  org.opencontainers.image.source="https://github.com/dante-ev/docker-texlive" \
  org.opencontainers.image.licenses="MIT"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=dumb

ARG BUILD_DATE
ARG GITLATEXDIFF_VERSION=1.6.0

WORKDIR /home

# Fix for update-alternatives: error: error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir -p /usr/share/man/man1

RUN apt-get update -q && \
    # Install tools less annd wget
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends less wget && \
    # Install Ruby's bundler
    apt-get install -qqy -o=Dpkg::Use-Pty=0 ruby poppler-utils && gem install bundler && \
    # libfile-copy-recursive-perl is required by ctanify
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends libfile-copy-recursive-perl openssh-client  && \
    # for plantuml, we need graphviz and inkscape. For inkscape, there is no non-X11 version, so 200 MB more
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends graphviz inkscape && \
    # LateXML - https://github.com/brucemiller/LaTeXML
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends latexml && \
    # fig2dev - tool for xfig to translate the figure to other formats
    apt-get install -qqy -o=Dpkg::Use-Pty=0 fig2dev && \
    # add Google's Inconsolata font (https://fonts.google.com/specimen/Inconsolata)
    apt-get install -qqy -o=Dpkg::Use-Pty=0 fonts-inconsolata && \
    # install bibtool
    apt-get install -qqy -o=Dpkg::Use-Pty=0 bibtool && \
    # install Python's pip3
    apt-get install -qqy -o=Dpkg::Use-Pty=0 python3-pip && \
    # install gnuplot
    apt-get install -qqy -o=Dpkg::Use-Pty=0 gnuplot && \
    # Removing documentation packages *after* installing them is kind of hacky,
    # but it only adds some overhead while building the image.
    # Source: https://github.com/aergus/dockerfiles/blob/master/latex/Dockerfile
    apt-get --purge remove -qqy .\*-doc$ && \
    # save some space
    rm -rf /var/lib/apt/lists/* && apt-get clean

RUN cd /tmp && \
    git clone --depth=1 https://gitlab.com/islandoftex/texmf/depp.git && \
    cd depp && \
    l3build install && \
    cd .. && \
    rm -rf /tmp/depp

# pandoc in the repositories is older - we just overwrite it with a more recent version
RUN curl -o /home/pandoc.deb -sSL https://github.com/jgm/pandoc/releases/download/3.6.4/pandoc-3.6.4-1-$TARGETARCH.deb && dpkg -i pandoc.deb && rm pandoc.deb

# get PlantUML in place
RUN curl -o /home/plantuml.zip -sSL https://github.com/plantuml/plantuml/releases/download/v1.2025.2/plantuml-asl-1.2025.2.jar && \
  unzip -q plantuml.zip && \
  rm plantuml.zip
ENV PLANTUML_JAR=/home/plantuml.jar

# update font index
RUN luaotfload-tool --update

WORKDIR /workdir
