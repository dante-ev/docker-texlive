FROM sumdoc/texlive-2017

LABEL maintainer "Oliver Kopp <kopp.dev@gmail.com>"

# we additionally need latexmk, python, java (because of pax), perl (because of pax), pdftk, ghostscript, and unzip (because of pax)
RUN apt-get update -qq && apt-get upgrade -qq && \
    apt-get install -y --no-install-recommends latexmk python2.7 openjdk-8-jre-headless libfile-which-perl pdftk ghostscript unzip && \
    apt-get install -y python-pip && \
    apt-get install -y ruby poppler-utils && \
    rm -rf /var/lib/apt/lists/*

# install Ruby's bundler
RUN gem install bundler

# update texlive
RUN tlmgr update --self --all --reinstall-forcibly-removed

# Prepare usage of pax
RUN mkdir /root/.texlive2017 && perl `kpsewhich -var-value TEXMFDIST`/scripts/pax/pdfannotextractor.pl --install

# Enable using the scripts of https://github.com/gi-ev/LNI-proceedings
# Install pygments to enable minted
RUN pip install pyparsing && pip install python-docx && pip install pygments

WORKDIR /home
