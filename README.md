# Docker image for texlive

This is based on [adnrv/texlive](https://hub.docker.com/r/adnrv/texlive/), with the addition of following programs:

- [latexmk](https://www.ctan.org/pkg/latexmk/)
- Python 2.7, pip, pyparsing, python-docx
- Java headless
- [pax](http://ctan.org/pkg/pax)
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
- Ghostscript

Usage:

    docker run --rm -it -v $(pwd):/var/texlive koppor/texlive latexmk document.tex

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
