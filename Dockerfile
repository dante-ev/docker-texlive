FROM registry.gitlab.com/islandoftex/images/texlive:latest
LABEL maintainer "Oliver Kopp <kopp.dev@gmail.com>"
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=dumb

ARG BUILD_DATE
ARG GITLATEXDIFF_VERSION=1.6.0

WORKDIR /home

# Fix for update-alternatives: error: error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir -p /usr/share/man/man1

# pandoc in the repositories is older - we just overwrite it with a more recent version
RUN wget https://github.com/jgm/pandoc/releases/download/2.12/pandoc-2.12-1-amd64.deb -q --output-document=/home/pandoc.deb && dpkg -i pandoc.deb && rm pandoc.deb

# get PlantUML in place
RUN wget https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar -q --output-document=/home/plantuml.jar
ENV PLANTUML_JAR=/home/plantuml.jar

# install pkgcheck
RUN wget https://gitlab.com/Lotz/pkgcheck/raw/master/bin/pkgcheck -q --output-document=/usr/local/bin/pkgcheck && chmod a+x /usr/local/bin/pkgcheck

# Install IBM Plex fonts
RUN mkdir -p /tmp/fonts && \
    cd /tmp/fonts && \
    wget "https://github.com/IBM/plex/releases/download/v5.1.3/OpenType.zip" -q && \
    unzip -q OpenType.zip && \
    cp -r OpenType/* /usr/local/share/fonts && \
    fc-cache -f -v && \
    cd .. && \
    rm -rf fonts

RUN apt-get update -q && \
    # Install git (Required for git-latexdiff)
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends git && \
    # Install Ruby's bundler
    apt-get install -qqy -o=Dpkg::Use-Pty=0 ruby poppler-utils && gem install bundler && \
    # openjdk-8-jre-headless is currently not available in testing
    # solution by https://stackoverflow.com/a/61902164/873282
    apt-get install -qqy -o=Dpkg::Use-Pty=0 software-properties-common && \
    apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && \
    apt-get update && \
    # plantuml requires java8
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends openjdk-8-jre-headless && \
    # proposal by https://github.com/sumandoc/TeXLive-2017
    apt-get install -qqy -o=Dpkg::Use-Pty=0 curl libgetopt-long-descriptive-perl libdigest-perl-md5-perl fontconfig && \
    # libfile-copy-recursive-perl is required by ctanify
    apt-get install -qqy -o=Dpkg::Use-Pty=0 --no-install-recommends libfile-which-perl libfile-copy-recursive-perl openssh-client && \
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
    # install gnuplot
    apt-get install -qqy -o=Dpkg::Use-Pty=0 gnuplot && \
    # Removing documentation packages *after* installing them is kind of hacky,
    # but it only adds some overhead while building the image.
    # Source: https://github.com/aergus/dockerfiles/blob/master/latex/Dockerfile
    apt-get --purge remove -qy .\*-doc$ && \
    # save some space
    rm -rf /var/lib/apt/lists/* && apt-get clean

# Install git-latexdiff v1.6.0 https://gitlab.com/git-latexdiff/git-latexdiff
RUN git config --global advice.detachedHead false && \
    git clone --branch "$GITLATEXDIFF_VERSION" --depth=1 https://gitlab.com/git-latexdiff/git-latexdiff.git /tmp/git-latexdiff && \
    make -C /tmp/git-latexdiff install-bin && \
    rm -rf /tmp/git-latexdiff

# install luximono
# RUN cd /tmp && wget https://www.tug.org/fonts/getnonfreefonts/install-getnonfreefonts && texlua install-getnonfreefonts && getnonfreefonts --sys luximono

# update font index
RUN luaotfload-tool --update

WORKDIR /workdir
