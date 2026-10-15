FROM registry.gitlab.com/islandoftex/images/texlive:latest
# FROM registry.gitlab.com/islandoftex/images/texlive:TL2026-2026-10-11-full

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
    # Panflute - https://scorreia.com/software/panflute/index.html
    apt-get install -qqy -o=Dpkg::Use-Pty=0 python3-panflute && \
    # install gnuplot
    apt-get install -qqy -o=Dpkg::Use-Pty=0 gnuplot && \
    # Mermaid CLI (used by ltmermaid/mermaid.sty) runs on Node.js and renders via a headless Chromium.
    # Debian's chromium is used, because puppeteer ships no Chrome build for arm64.
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends nodejs npm chromium && \
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
RUN curl -o /home/pandoc.deb -sSL https://github.com/jgm/pandoc/releases/download/3.12.1/pandoc-3.12.1-1-$TARGETARCH.deb && dpkg -i pandoc.deb && rm pandoc.deb

# get PlantUML in place (the released .jar is already runnable; do not unzip it)
RUN curl -o /home/plantuml.jar -sSL https://github.com/plantuml/plantuml/releases/download/v1.2026.8/plantuml-asl-1.2026.8.jar && \
    printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar "$PLANTUML_JAR" "$@"\n' > /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml
ENV PLANTUML_JAR=/home/plantuml.jar

# Mermaid CLI. ltmermaid calls plain `mmdc`, so a wrapper adapts the call:
# - Chromium needs --no-sandbox when running as root inside a container, set via the puppeteer config.
# - ltmermaid always passes -f (--pdfFit), which mermaid-cli 12 removed because fitting is now the default.
ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
RUN npm install --global --omit=dev @mermaid-js/mermaid-cli@12.0.0 && \
    npm cache clean --force && \
    mv /usr/local/bin/mmdc /usr/local/bin/mmdc-real
COPY <<'EOF_CONFIG' /etc/mermaid/puppeteer-config.json
{"executablePath": "/usr/bin/chromium", "args": ["--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage"]}
EOF_CONFIG
COPY --chmod=755 <<'EOF_MMDC' /usr/local/bin/mmdc
#!/bin/sh
for arg do
  shift
  case "$arg" in
    -f|--pdfFit) ;;
    *) set -- "$@" "$arg" ;;
  esac
done
exec /usr/local/bin/mmdc-real -p /etc/mermaid/puppeteer-config.json "$@"
EOF_MMDC

# TikZ-UML is not on CTAN, so it is not part of TeX Live
RUN mkdir -p /usr/local/texlive/texmf-local/tex/latex/tikz-uml && \
    curl -o /tmp/tikzuml.tbz -sSL https://perso.ensta.fr/~kielbasi/tikzuml/var/files/src/tikzuml-v1.0-2016-03-29.tbz && \
    echo "0cbc4a20c8ed40162b3b9ab1400b174293ec1ad7508e640ca879e78c45a105d0  /tmp/tikzuml.tbz" | sha256sum -c - && \
    tar xjf /tmp/tikzuml.tbz -C /usr/local/texlive/texmf-local/tex/latex/tikz-uml --strip-components=1 tikzuml-v1.0-2016-03-29/tikz-uml.sty && \
    rm /tmp/tikzuml.tbz && \
    mktexlsr /usr/local/texlive/texmf-local

# update font index
RUN luaotfload-tool --update

WORKDIR /workdir
