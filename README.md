# Docker image for texlive [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![download-size number-of-layers](https://images.microbadger.com/badges/image/danteev/texlive.svg)](https://microbadger.com/images/danteev/texlive)

This docker image supports full TeX Live with following additions:

- [Gnuplot](http://www.gnuplot.info/)
- [GraphViz](https://www.graphviz.org/)
- [Inkscape](https://inkscape.org/)
- [latexmk](https://www.ctan.org/pkg/latexmk/) - an automator for latex building
- [Pandoc](http://pandoc.org/) - to convert from and to `.tex`
- [git-latexdiff](https://gitlab.com/git-latexdiff/git-latexdiff) - to enable diffs of LaTeX documents
- Java headless - required for Pandoc

## Usage

### Using docker

```terminal
docker run --rm -it -v $(pwd):/workdir danteev/texlive latexmk -pdf document.tex
```

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
        uses: actions/checkout@v2
      - name: Compile document.tex
        uses: dante-ev/latex-action@master
        with:
          root_file: document.tex
```

You can also use it with multiple files as outlined here:

```sh
❯ tree
.
├── motivation_letter.pdf
├── master_degree.pdf
├── README.md
├── master_degree
│   ├── master_degree.sty
│   └── master_degree.tex
└── motivation_letter
    ├── motivation_letter.bib
    └── motivation_letter.tex
```

Following custom compilation script compiles all PDFs:

```yaml
name: Build
on:
  push:
    paths-ignore:
      - '*.pdf'
jobs:
  build_latex:
    runs-on: ubuntu-latest
    container:
      image: danteev/texlive:latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Build LaTeX
      run: |
        for project in $(ls); do
          if [ -d "$project" ]; then
            cd ${project}
            latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf -outdir=$PWD/../ $PWD/${project}
            cd ..
          fi
        done
```

One can push the results using following example:

```yaml
    - name: Publish LaTeX
      run : |
        git config --global user.email "bot@example.org"
        git config --global user.name "BOT_WORKFLOW"
        git add -f $PWD/*.pdf
        git commit -m "WORKFLOW_COMMIT - Update PDFs [skip ci]"
        git push
```

Alternatively, you can use the [GitHub push action](https://github.com/ad-m/github-push-action) to push something.

### Usage in [CircleCI 2.0](https://circleci.com/docs/2.0/)

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

### Usage in [Travis CI](https://travis-ci.org/)

Create file `.travis.yml` with following content:

```yaml
dist: bionic
language: generic
services: docker

script:
- docker run --rm -it -v $(pwd):/workdir danteev/texlive latexmk -pdf document.tex
```

### Usage in [GitLab CI](https://docs.gitlab.com/ce/ci/)

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

## Available Tags

- `edge` - the edge build
- `latest` - the latest released version
- `YYYY-MM-DD` - a build of that date. Usually created on the first and fifteenth of a month

Browse all available tags at <https://hub.docker.com/repository/docker/danteev/texlive/tags?page=1&ordering=last_updated>.

### Other versions

- `2021-A` - first image release in year 2021
- `2020` - latest TeXLive 2020 build
- `TL2017` - TeXLive 2017 build
- For all other versions see [CHANGELOG.md](https://github.com/dante-ev/docker-texlive/blob/master/CHANGELOG.md#changelog).

### Usage example

```terminal
docker run --rm -it -v $(pwd):/workdir danteev/texlive latexmk document.tex
```

In case you want to use an explcit tag, you can do it as follows:

You can run the build of 2021-05-15 by using the tag `2021-05-15`:

```terminal
docker run --rm -it -v $(pwd):/workdir danteev/texlive:2021-05-15 latexmk document.tex
```

## Background

We decided to base on the official texlive image, because this ensures recent texlive packages and a working basic build.
We extended the image with tools required for our use cases.

## Alternatives

In case this all-in-one image is too large for you, you might be interested in following images:

- [Official texlive image](https://hub.docker.com/r/texlive/texlive) - contains plain full texlive without additional tooling
- [docker-texlive-thin](https://github.com/thomasWeise/docker-texlive-thin) - other packages and tools
- [texlive-docker by @reitzig](https://github.com/reitzig/texlive-docker) - profile-based texlive image

## License

- [Google Inconsolata](https://fonts.google.com/specimen/Inconsolata) is licensed under [OFL-1.1](https://spdx.org/licenses/OFL-1.1.html).
- [IBM Plex™](https://github.com/IBM/plex/) is licensed under [OFL-1.1](https://spdx.org/licenses/OFL-1.1.html).
- [pkgcheck](https://ctan.org/pkg/pkgcheck) is licensed under Apache-2.0 or MIT.
- The files in this repository are licensed under [MIT](https://spdx.org/licenses/MIT.html).
- Each LaTeX package has its own license.
  Please check the respective package homepages at [CTAN](https://www.ctan.org/).
