FROM registry.gitlab.com/islandoftex/images/texlive:latest
# FROM registry.gitlab.com/islandoftex/images/texlive:TL2026-2026-06-26-full

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

# Required at least for PlantUML below
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
    # Panflute - https://scorreia.com/software/panflute/index.html
    apt-get install -qqy -o=Dpkg::Use-Pty=0 python3-panflute && \
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

# get PlantUML in place (the released .jar is already runnable; do not unzip it)
RUN curl -o /home/plantuml.jar -sSL https://github.com/plantuml/plantuml/releases/download/v1.2026.6/plantuml-asl-1.2026.6.jar
ENV PLANTUML_JAR=/home/plantuml.jar

# Pre-generate luaotfload's font caches so that latexmk does not rerun lualatex
# in every fresh container (https://github.com/dante-ev/docker-texlive/issues/51).
# The lookup cache cannot be pre-generated; /etc/latexmkrc takes care of it.
# Several small worker runs: each lualatex process keeps the fonts it loaded in
# memory (roughly 7 MB per font), so this bounds memory while using all cores.
COPY font-cache/latexmkrc /etc/latexmkrc
COPY font-cache/warm-font-cache.lua font-cache/warm-font-cache.tex /tmp/font-cache/
RUN luaotfload-tool --update && \
    cd /tmp/font-cache && \
    WORKERS=32 && \
    seq 0 $((WORKERS - 1)) | xargs -P "$(nproc)" -I{} env WORKER={} WORKERS="$WORKERS" \
      lualatex -interaction=batchmode --jobname=warm-{} warm-font-cache.tex > /dev/null; \
    grep -h WARM warm-*.log && \
    [ "$(grep -l WARMDONE warm-*.log | wc -l)" -eq "$WORKERS" ] && \
    # luaotfload reads the compiled .luc files; the .lua twins only cost space
    rm /usr/local/texlive/*/texmf-var/luatex-cache/generic/fonts/otl/*.lua && \
    cd / && rm -rf /tmp/font-cache

WORKDIR /workdir
