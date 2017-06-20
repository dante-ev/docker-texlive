FROM adnrv/texlive

# we additionally need latexmk
RUN apt-get update -qq && apt-get install -y --no-install-recommends latexmk && \
    rm -rf /var/lib/apt/lists/*
