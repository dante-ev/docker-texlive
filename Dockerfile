FROM ubuntu:cosmic
LABEL maintainer "Oliver Kopp <kopp.dev@gmail.com>"
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=dumb

# avoid debconf and initrd
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

ARG BUILD_DATE

# we additionally need python, java (because of pax), perl (because of pax), pdftk, ghostscript, and unzip (because of pax)
RUN apt-get update -qq && apt-get upgrade -qq && \
    # proposal by https://github.com/sumandoc/TeXLive-2017
    apt-get install -y wget curl libgetopt-long-descriptive-perl libdigest-perl-md5-perl fontconfig && \
    # libfile-copy-recursive-perl is required by ctanify
    apt-get install -y --no-install-recommends openjdk-8-jre-headless libfile-which-perl libfile-copy-recursive-perl pdftk ghostscript unzip openssh-client git && \
    apt-get install -y ruby poppler-utils && \
    # for plantuml, we need graphviz and inkscape. For inkscape, there is no non-X11 version, so 200 MB more
    apt-get install -y --no-install-recommends graphviz inkscape && \
    # install texlive-full. The documentation ( texlive-latex-base-doc- texlive-latex-extra-doc- texlive-latex-recommended-doc-	texlive-metapost-doc- texlive-pictures-doc- texlive-pstricks-doc- texlive-publishers-doc- texlive-science-doc- texlive-fonts-extra-doc- texlive-fonts-recommended-doc- texlive-humanities-doc-) is also required
    apt-get install -y --no-install-recommends texlive-full fonts-texgyre latexml xindy && \
    # texlive-full depends on pyhton3. These packages curently depend on python2.7.
    # install pygments to enable minted
    apt-get install -y python-pygments python-pip && \
    # add Google's Inconsolata font (https://fonts.google.com/specimen/Inconsolata)
    apt-get install -y fonts-inconsolata && \
    # required to install IBMPlexMono font
    apt-get install -y fontconfig && \
    # required by tlmgr init-usertree
    apt-get install -y xzdec && \
    # save some space
    rm -rf /var/lib/apt/lists/* && apt-get clean

# update texlive
# works if no new major release of texlive was done
#
# source: https://askubuntu.com/a/485945
RUN tlmgr init-usertree
RUN tlmgr update --self --all --reinstall-forcibly-removed

# install IBM Plex fonts
RUN mkdir -p /tmp/fonts && \
    cd /tmp/fonts && \
    wget https://github.com/IBM/plex/releases/download/v1.2.3/OpenType.zip && \
    unzip OpenType.zip -x */LICENSE.txt */license.txt */CHANGELOG */.DS_Store && \
    cp -r OpenType/* /usr/local/share/fonts && \
    fc-cache -f -v

# update font index
RUN luaotfload-tool --update

WORKDIR /home

# pandoc is installed because of CTAN package releasing, where .md is converted to .pdf
# pandoc in the repositories is 1.x, but there is 2.x released, which changed command line parameters.
# To enable release.sh working also in CircleCI, we use a recent pandoc version there, too.
RUN wget https://github.com/jgm/pandoc/releases/download/2.6/pandoc-2.6-1-amd64.deb -q --output-document=/home/pandoc.deb && dpkg -i pandoc.deb && rm pandoc.deb

# get PlantUML in place
RUN wget https://netix.dl.sourceforge.net/project/plantuml/1.2019.0/plantuml.1.2019.0.jar -q --output-document=/home/plantuml.jar
ENV PLANTUML_JAR=/home/plantuml.jar

# install Ruby's bundler
RUN gem install bundler

# enable using the scripts of https://github.com/gi-ev/LNI-proceedings
RUN pip install pyparsing && pip install python-docx

# prepare usage of pax
RUN mkdir /root/.texlive2018 && perl `kpsewhich -var-value TEXMFDIST`/scripts/pax/pdfannotextractor.pl --install

# install pkgcheck
RUN wget https://gitlab.com/Lotz/pkgcheck/raw/master/bin/pkgcheck -q --output-document=/usr/local/bin/pkgcheck && chmod a+x /usr/local/bin/pkgcheck
