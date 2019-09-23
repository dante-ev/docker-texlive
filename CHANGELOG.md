# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added

- Added support for [pkgcheck](https://ctan.org/pkg/pkgcheck)
- Added support for [fig2dev](https://linux.die.net/man/1/fig2dev)
- Added support for [pandoc](https://pandoc.org/)
- Remove more space after installing debian packages

### Changed

- Update to TeX Live 2019
- Update to Debian unstable
- Update to Python 3 variant of pygments, python-docx, and pyparsing
- Update IBM's OpenType plex from 1.2.3 to 2.0.0
- Update pandoc to 2.7.3
- Always load latest plantuml.jar when building the docker image

### Removed

- Remove all -doc packages (and thus saving nearly 1,7TB of space)

## [v1.6.0] – 2018-06-19

> When using this version, you have to run `texindy` with the parameter `-C utf8`.
> See <https://bugs.launchpad.net/ubuntu/+source/xindy/+bug/1735439> for details.

### Added

- Support for [Google's Inconsolata font](https://fonts.google.com/specimen/Inconsolata)
- Support for [IBM Plex™](https://github.com/IBM/plex/)
- Tag version 1.6.0 as `TL2017` as TeX Live 2017 is frozen

### Changed

- Use [Ubuntu Bionics's texlive-all](https://packages.ubuntu.com/bionic/texlive-full) instead of self-installed texlive.
  We cannot use Debian/sid or a later ubuntu, because of <https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=901761>.
- Ensure that git and ssh are installed
- Install [LaTeXML](https://dlmf.nist.gov/LaTeXML/) as Debian package and not directly from source
- New home at [DANTE e.V.](https://www.dante.de/): <https://github.com/dante-ev/docker-texlive>

## [v1.5.0] – 2018-03-20

### Added

- Added `plantuml.jar` and environemnt variable `PLANTUML_JAR` to enable usage of the [plantuml package](https://www.ctan.org/plantuml).
- Added `graphviz` and `inkscape` for the plantuml package.
- Added `pandoc` to be able to convert `md` to `pdf`.

### Fixed

- `latexmk` is not installed using `apt-get` anymore, because it is already by the parent image.

## [v1.4.1] – 2018-06-03

### Changed

- Rebuilt due to freeze of TeXLive 2017.

## [v1.4.0] – 2018-02-13

### Added

- Added [pygments](http://pygments.org/) package to enable [minted](https://github.com/gpoore/minted).
- Added [bundler](http://bundler.io/) to enable testing via [RSpec](http://rspec.info/).

## [v1.3.0] – 2018-01-10

### Added

- Added [MADR ADRs](https://adr.github.io/madr/).

### Changed

- New base image [sumdoc/texlive-2017](https://hub.docker.com/r/sumdoc/texlive-2017/).
- `WORKDIR` is now `/home` instead of `/var/texlive`.

## [v1.2.0] – 2017-09-02

### Added

- Ghostscript

## [v1.1.0] – 2017-09-02

### Added

- packages `python2.7`, `python-pip`, `pyparsing`, and `python-docx` to enable execution of helper scripts
- packages `openjdk-8-jre-headless` and `libfile-which-perl` to enable execution of [pax](http://ctan.org/pkg/pax)
- package [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)

## v1.0.0 – 2017-08-03

Initial release

[Unreleased]: https://github.com/koppor/docker-texlive/compare/v1.6.0...HEAD
[v1.6.0]: https://github.com/koppor/docker-texlive/compare/v1.5.1...v1.6.0
[v1.5.0]: https://github.com/koppor/docker-texlive/compare/v1.4.1...v1.5.0
[v1.4.1]: https://github.com/koppor/docker-texlive/compare/v1.4.0...v1.4.1
[v1.4.0]: https://github.com/koppor/docker-texlive/compare/v1.3.0...v1.4.0
[v1.3.0]: https://github.com/koppor/docker-texlive/compare/v1.2.0...v1.3.0
[v1.2.0]: https://github.com/koppor/docker-texlive/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/koppor/docker-texlive/compare/v1.0.0...v1.1.0
