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
    # Install git (Required for git-latexdiff)
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends git wget && \
    # Install Ruby's bundler
    apt-get install -qqy -o=Dpkg::Use-Pty=0 ruby poppler-utils && gem install bundler && \
    # plantuml requires a recent java version
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends openjdk-21-jre-headless && \
    # proposal by https://github.com/sumandoc/TeXLive-2017
    apt-get install -qqy -o=Dpkg::Use-Pty=0 curl libgetopt-long-descriptive-perl libdigest-perl-md5-perl fontconfig && \
    # libfile-copy-recursive-perl is required by ctanify
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends libfile-which-perl libfile-copy-recursive-perl openssh-client  && \
    # latexindent modules
    apt-get install -qqy -o=Dpkg::Use-Pty=0 libyaml-tiny-perl libfile-homedir-perl libunicode-linebreak-perl liblog-log4perl-perl libtest-log-dispatch-perl && \
    # for plantuml, we need graphviz and inkscape. For inkscape, there is no non-X11 version, so 200 MB more
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends graphviz inkscape && \
    # some more packages
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends fonts-texgyre latexml && \
    # fig2dev - tool for xfig to translate the figure to other formats
    apt-get install -qqy -o=Dpkg::Use-Pty=0 fig2dev && \
    # add Google's Inconsolata font (https://fonts.google.com/specimen/Inconsolata)
    apt-get install -qqy -o=Dpkg::Use-Pty=0 fonts-inconsolata && \
    # required by tlmgr init-usertree
    apt-get install -qqy -o=Dpkg::Use-Pty=0 xzdec && \
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

# pandoc in the repositories is older - we just overwrite it with a more recent version
RUN wget https://github.com/jgm/pandoc/releases/download/3.6.3/pandoc-3.6.3-1-$TARGETARCH.deb -q --output-document=/home/pandoc.deb && dpkg -i pandoc.deb && rm pandoc.deb

# get PlantUML in place
RUN wget https://github.com/plantuml/plantuml/releases/download/v1.2025.0/plantuml-asl-1.2025.0.jar -q --output-document=/home/plantuml.zip && \
  unzip -q plantuml.zip && \
  rm plantuml.zip
ENV PLANTUML_JAR=/home/plantuml.jar

# Create font cache
COPY load-fonts.tex /tmp/
RUN luaotfload-tool --update --force --no-compress
RUN texhash
RUN cd /tmp && yes "" | lualatex load-fonts
# Needs to run twice according to https://tex.stackexchange.com/a/737059/9075
RUN cd /tmp && yes "" | lualatex load-fonts
RUN rm /tmp/load-fonts.*

WORKDIR /workdir
