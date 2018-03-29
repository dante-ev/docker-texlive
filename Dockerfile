FROM sumdoc/texlive-2017

LABEL maintainer "Oliver Kopp <kopp.dev@gmail.com>"
WORKDIR /home
ENV TERM=dumb

# we additionally need python, java (because of pax), perl (because of pax), pdftk, ghostscript, and unzip (because of pax)
RUN apt-get update -qq && apt-get upgrade -qq && \
    # libfile-copy-recursive-perl is required by ctanify
    apt-get install -y --no-install-recommends python2.7 openjdk-8-jre-headless libfile-which-perl libfile-copy-recursive-perl pdftk ghostscript unzip openssh-client git && \
    apt-get install -y python-pip && \
    apt-get install -y ruby poppler-utils && \
    # For plantuml, we need graphviz and inkscape. For inkscape, there is no non-X11 version, so 200 MB more
    apt-get install -y --no-install-recommends graphviz inkscape && \
    rm -rf /var/lib/apt/lists/*

# pandoc is because of CTAN package releasing, where .md is converted to .pdf
# pandoc in the repositories is 1.x, but there is 2.x released, which changed command line parameters.
# To enable release.sh working also in CircleCI, we use a recent pandoc version there, too.
RUN wget https://github.com/jgm/pandoc/releases/download/2.1.3/pandoc-2.1.3-1-amd64.deb -q --output-document=/home/pandoc.deb && dpkg -i pandoc.deb

# get PlantUML in place
RUN wget https://netix.dl.sourceforge.net/project/plantuml/1.2018.2/plantuml.1.2018.2.jar -q --output-document=/home/plantuml.jar
ENV PLANTUML_JAR=/home/plantuml.jar

# install Ruby's bundler
RUN gem install bundler

# Enable using the scripts of https://github.com/gi-ev/LNI-proceedings
# Install pygments to enable minted
RUN pip install pyparsing && pip install python-docx && pip install pygments

# update texlive
RUN tlmgr update --self --all --reinstall-forcibly-removed

# Update font index
RUN luaotfload-tool --update

# Prepare usage of pax
RUN mkdir /root/.texlive2017 && perl `kpsewhich -var-value TEXMFDIST`/scripts/pax/pdfannotextractor.pl --install
