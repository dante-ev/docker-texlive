# Docker image for TeX Live

This Docker image supports full TeX Live with following additions:

- [bibtool](https://github.com/ge-ne/bibtool)
- [DEPP](https://gitlab.com/islandoftex/texmf/depp) - Dependency Printer for TeX Live
- [fig2dev](https://sourceforge.net/projects/mcj/) - to convert xfig figures
- [Gnuplot](http://www.gnuplot.info/)
- [GraphViz](https://www.graphviz.org/)
- [Inkscape](https://inkscape.org/)
- [LaTeXML](https://github.com/brucemiller/LaTeXML)
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli) (`mmdc`) with Node.js and Chromium - enables the [ltmermaid](https://ctan.org/pkg/ltmermaid) package
- [Pandoc](https://pandoc.org/) - to convert from and to `.tex` (more recent than the Debian package)
- [PlantUML](https://plantuml.com/) - available as `plantuml` command and at `$PLANTUML_JAR`; enables the [plantuml](https://ctan.org/pkg/plantuml) package
- [pip](https://pypi.org/project/pip/). This enables manual Python package installation.
- [TeXtidote](https://github.com/sylvainhalle/textidote) - spelling, grammar and style checker for LaTeX documents
- [TikZ-UML](https://perso.ensta.fr/~kielbasi/tikzuml/) - not part of TeX Live

The base image already provides, among others,
[latexmk](https://www.ctan.org/pkg/latexmk/),
Python 3 with [pygments](https://pygments.org/) (for [minted](https://ctan.org/pkg/minted)),
Java,
and Git.

It builds on the [full TeX Live image by "Island of TeX"](https://gitlab.com/islandoftex/images/texlive) with additions considered important.

We decided to base on the IoT's TeX Live image, because this ensures recent TeX Live packages and a working basic build.
We extended the image with tools required for our use cases.

## Available tags

- `edge` - the edge build. Usually created on the first and fifteenth of a month.
- `latest` - the latest released version.
- `YYYY-MM-DD` - a build of that date. Usually created on the first and fifteenth of a month.

Browse all available tags at <https://hub.docker.com/r/danteev/texlive/tags>.

### Other versions

- `2026-B` - latest TeX Live 2026 build
- `2025-A` - latest TeX Live 2025 build
- `2024-B` - latest TeX Live 2024 build
- `2023-A` - latest TeX Live 2023 build
- `2021-D` - latest TeX Live 2021 build
- `2020-A` - latest TeX Live 2020 build
- `2019-A` - latest TeX Live 2019 build
- `TL2017` - latest TeX Live 2017 build
- There are no releases based on TeX Live 2018 or 2022.
- For all other versions see [CHANGELOG.md](https://github.com/dante-ev/docker-texlive/blob/main/CHANGELOG.md#changelog).

## Usage

### Using Docker

```terminal
docker run --rm -it -v $(pwd):/workdir danteev/texlive latexmk -pdf document.tex
```

In case you want to use an explicit tag, you can do it as follows:

You can run the build of 2021-05-15 by using the tag `2021-05-15`:

```terminal
docker run --rm -it -v $(pwd):/workdir danteev/texlive:2021-05-15 latexmk document.tex
```

### Usage in [GitHub Workflows](https://docs.github.com/en/actions)

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
        uses: dante-ev/latex-action@edge
        with:
          root_file: document.tex
```

See [dante-ev/latex-action](https://github.com/dante-ev/latex-action#readme) for documentation on the different `with` options available.

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

### Usage in [GitLab CI](https://docs.gitlab.com/ci/)

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

### Usage in [Forgejo Actions](https://forgejo.org/docs/latest/user/actions/)

Create file `.forgejo/workflows/build.yml` with following content:

```yaml
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-22.04
    container:
      image: danteev/texlive
    steps:
      - uses: actions/checkout@v4
      - run: latexmk -pdf document.tex
      - uses: https://code.forgejo.org/forgejo/upload-artifact@v4
        with:
          name: document
          path: document.pdf
```

The image includes Node.js, which Forgejo needs to run JavaScript actions such as `actions/checkout`.
For a fuller example that also publishes the PDF to a branch, see [TeXhackse/forgejo-actions-latex](https://codeberg.org/TeXhackse/forgejo-actions-latex/src/branch/main/.forgejo/workflows/main.yaml).

### Usage in [CircleCI 2.0](https://circleci.com/docs/)

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

### Usage in [Travis CI](https://www.travis-ci.com/)

Create file `.travis.yml` with following content:

```yaml
dist: bionic
language: generic
services: docker

script:
- docker run --rm -it -v $(pwd):/workdir danteev/texlive latexmk -pdf document.tex
```

### Further reading

M. Peischl, M. Krüger & O. Kopp. [Creation of LaTeX documents using a cloud-based pipeline](https://doi.org/10.47397/tb/45-2/tb140peischl-pipeline). TUGboat 45(2), 227–233 (2024) - background on building LaTeX documents in CI pipelines, with detailed instructions on how to set up and use Forgejo Actions workflows.

## Development hints

### Find the latest build tag

At a release, we point to a specific tag of the "upstream" Docker image.
To find out the latest tag, navigate to <https://gitlab.com/islandoftex/images/texlive/-/jobs>.
Then look for `build:latest` and then `[no, no, full]`.
`no, no` means: no documentation and no source files.
Open the build log, scroll down to the end, there you will find something like `registry.gitlab.com/islandoftex/images/texlive:TL2024-2024-08-11-full`.
More background information is given at <https://gitlab.com/islandoftex/images/texlive/-/issues/9>.

- `sed -i 's/^    \(.*\) && \\$/ RUN \1/' Dockerfile`
- `sed -i 's/^ RUN \(.*\)/    \1 \&\& \\/' Dockerfile`

### Other hints

- To see all progress during the build, use `docker build --progress=plain .`. [[Source](https://stackoverflow.com/a/67682576/873282)]
- The TOC in the `CHANGELOG.md` file is generated by using <https://luciopaiva.com/markdown-toc/>.

## Alternatives

In case this all-in-one image is too large for you, you might be interested in following images:

- [VS.Code DevContainer](https://github.com/a-nau/latex-devcontainer) - contains a ready-to-start Visual Studio Code environment.
- [Official texlive image](https://hub.docker.com/r/texlive/texlive) - contains plain full TeXLive without additional tooling
- [docker-texlive-thin](https://github.com/thomasWeise/docker-texlive-thin) - other packages and tools
- [texlive-docker by @reitzig](https://github.com/reitzig/texlive-docker) - profile-based TeXLive image

## License

- [Google Inconsolata](https://fonts.google.com/specimen/Inconsolata) is licensed under [OFL-1.1](https://spdx.org/licenses/OFL-1.1.html).
- The files in this repository are licensed under [MIT](https://spdx.org/licenses/MIT.html).
- Each LaTeX package has its own license.
  Please check the respective package homepages at [CTAN](https://www.ctan.org/).
