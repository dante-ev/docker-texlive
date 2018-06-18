# Docker image for texlive [![TexLive:2017](https://img.shields.io/badge/TeX%20Live-2017-blue.svg)](https://www.tug.org/texlive/acquire.html) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![download-size number-of-layers](https://images.microbadger.com/badges/image/danteev/texlive.svg)](https://microbadger.com/images/danteev/texlive)

This docker image supports full TeX live 2017 with following additions:

- [latexmk](https://www.ctan.org/pkg/latexmk/)
- [Python 2.7](https://pythonclock.org/), pip, pyparsing, python-docx
- Java headless
- [pax](http://ctan.org/pkg/pax)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
- [Pandoc](http://pandoc.org/)
- [GraphViz](https://www.graphviz.org/)
- [Inkscape](https://inkscape.org/)
- [Ghostscript](https://www.ghostscript.com/)

Usage:

    docker run --rm -it -v $(pwd):/home danteev/texlive latexmk document.tex

Usage in [CircleCI 2.0](https://circleci.com/docs/2.0/):

Create file `.circle/config.yml` with following content:

```yaml
version: 2
jobs:
   build:
     docker:
       - image: danteev/texlive
     steps:
       - checkout
       - run: latexmk document.tex
```
