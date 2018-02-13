# Docker image for texlive [![TexLive:2017](https://img.shields.io/badge/TeX%20Live-2017-blue.svg)](https://www.tug.org/texlive/acquire.html) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![download-size number-of-layers](https://images.microbadger.com/badges/image/koppor/texlive.svg)](https://microbadger.com/images/koppor/texlive)

This is based on [sumdoc/texlive-2017](https://hub.docker.com/r/sumdoc/texlive-2017/), with the addition of following programs:

- [latexmk](https://www.ctan.org/pkg/latexmk/)
- Python 2.7, pip, pyparsing, python-docx
- Java headless
- [pax](http://ctan.org/pkg/pax)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
- Ghostscript

Usage:

    docker run --rm -it -v $(pwd):/home koppor/texlive latexmk document.tex

Usage in [CircleCI 2.0](https://circleci.com/docs/2.0/):

Create file `.circle/config.yml` with following content:

```
version: 2
jobs:
   build:
     docker:
       - image: koppor/texlive
     steps:
       - checkout
       - run: latexmk document.tex
```
