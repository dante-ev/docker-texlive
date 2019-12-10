# Docker image for texlive [![TexLive:2019](https://img.shields.io/badge/TeX%20Live-2019-blue.svg)](https://www.tug.org/texlive/acquire.html) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![download-size number-of-layers](https://images.microbadger.com/badges/image/danteev/texlive.svg)](https://microbadger.com/images/danteev/texlive)

This docker image supports full TeX Live 2019 with following additions:

- [latexmk](https://www.ctan.org/pkg/latexmk/)
- [Python 3](https://pythonclock.org/), pip, pyparsing, python-docx
- Java headless
- [pax](http://ctan.org/pkg/pax)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
- [Pandoc](http://pandoc.org/)
- [GraphViz](https://www.graphviz.org/)
- [Inkscape](https://inkscape.org/)
- [Ghostscript](https://www.ghostscript.com/)

## Usage

### Using docker

    docker run --rm -it -v $(pwd):/home danteev/texlive latexmk -pdf document.tex

### Usage in [GitHub Workflows](https://help.github.com/en/articles/about-github-actions)

Create a file `.github/workflows/build.yml` with following content:

```yaml
name: Build
on: [push]
jobs:
  build_latex:
    runs-on: ubuntu-latest
    steps:
      - name: Set up Git repository
        uses: actions/checkout@v1
      - name: Compile document.tex
        uses: dante-ev/latex-action@master
        with:
          root_file: document.tex
```

### Usage in [CircleCI 2.0](https://circleci.com/docs/2.0/):

Create file `.circle/config.yml` with following content:

```yaml
version: 2
jobs:
   build:
     docker:
       - image: danteev/texlive
     steps:
       - checkout
       - run: latexmk -pdf document.tex
```

### Usage in [Travis CI](https://travis-ci.org/):

Create file `.travis.yml` with following content:

```yaml
dist: bionic
language: generic
services: docker

script:
- docker run --rm -it -v $(pwd):/home danteev/texlive latexmk -pdf document.tex
```

## Usage in [GitLab CI](https://docs.gitlab.com/ce/ci/)

Create file `.gitlab-ci.yml` with following content:

```yaml
build:
  image: danteev/texlive
  stage: build
  script:
    - latexmk -pdf document.tex
  artifacts:
    paths:
      - document.pdf
```

## Latest stable version

You can run latest stable version by using the tag `TL2017`:

    docker run --rm -it -v $(pwd):/home danteev/texlive:TL2017 latexmk document.tex

## Background

We decided to offer latest TeX Live 2019 (as time of building), because this ensures recent packages.
We base on Ubuntu Cosmic as this is the latest Ubuntu version available during building.

## License

- [Google Inconsolata](https://fonts.google.com/specimen/Inconsolata) is licensed under [OFL-1.1](https://spdx.org/licenses/OFL-1.1.html).
- [IBM Plex™](https://github.com/IBM/plex/) is licensed under [OFL-1.1](https://spdx.org/licenses/OFL-1.1.html).
- [pkgcheck](https://ctan.org/pkg/pkgcheck) is licensed under Apache-2.0 or MIT.
- The files in this repository are licensed under [MIT](https://spdx.org/licenses/MIT.html).
- Each LaTeX package has its own license.
  Please check the respective package homepages at [CTAN](https://www.ctan.org/).
