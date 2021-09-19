# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

This project cannot adhere to [Semantic Versioning](http://semver.org/), because it builds on TeXLive, which introcuces breaking changes now and then.
Thus, each new version would lead to a new major version.
Instead, we version `YYYY-R`, where `YYYY` is TeXLive version this image is based on and `R` is numbering different releases in that cycle using characters.
E.g., `2021-A`, `2021-B`, ...
We use letters instead of numbers to avoid confusion with the automatic builds such as `2021-05-15`.

## [edge]

Note that this version is continuosly built based on [texlive/texlive](https://gitlab.com/islandoftex/images/texlive).

### Changed

- Switch back to `latest` of the [upstream texlive image](https://gitlab.com/islandoftex/images/texlive)

## [2021-D] &ndash; 2021-09-19

### Changed

- Uses tag `TL2021-2021-08-01-04-07` of the [upstream texlive image](https://gitlab.com/islandoftex/images/texlive)

## [2020-A] &ndash; 2021-09-18

### Changed

- Uses tag `TL2020-historic` of the [upstream texlive image](https://gitlab.com/islandoftex/images/texlive)

## [2019-A] &ndash; 2021-09-15

### Changed

- Uses tag `TL2019-historic` of the [upstream texlive image](https://gitlab.com/islandoftex/images/texlive)

## [2021-C] &ndash; 2021-08-03

### Changed

- Uses tag `TL2021-2021-08-01-04-07` of the [upstream texlive image](https://gitlab.com/islandoftex/images/texlive)

## [2021-B] &ndash; 2021-06-11

### Added

- Added support for luximono
- `pip3` [#37](https://github.com/dante-ev/docker-texlive/issues/37)

## [2021-A] &ndash; 2021-05-17

### Fixed

- Fixed support of [`latexindent`](https://ctan.org/pkg/latexindent)
- Fixed support of `xindy`

### Changed

- Switch upstream image to [Island of TeX's texlive image](https://gitlab.com/islandoftex/images/texlive)
- Switch to TeX Live 2021
- Update pandoc to 2.12.1
- The working directory for latex compilation is now `/workdir` instead of `/home`. `/home` is kept for plantuml.jar and other local packages.

### Removed

- Remove support of [pax](https://ctan.org/pkg/pax), because there is [newpax](https://ctan.org/pkg/newpax)
- Remove pdftk and ghostscript. Seems to be used only in rare cases.

## [2020] &ndash; 2020-06-23

### Added

- Added support for [pkgcheck](https://ctan.org/pkg/pkgcheck)
- Added support for [fig2dev](https://linux.die.net/man/1/fig2dev)
- Added support for [pandoc](https://pandoc.org/)
- Remove more space after installing debian packages
- Added support for [git-latexdiff](https://gitlab.com/git-latexdiff/git-latexdiff)

### Changed

- Update to TeX Live 2020
- Update to Debian testing
- Update to Python 3 variant of pygments, python-docx, and pyparsing
- Update IBM's OpenType plex from 1.2.3 to 5.0.0
- Update pandoc to 2.9.2
- Always load latest plantuml.jar when building the docker image
- Change versioning theme to `YYYY-RR`, where `YYYY` is the TeXLive version this image is based on and `RR` is numbering different releases in that cycle.

### Removed

- Remove all -doc packages (and thus saving nearly 1,7TB of space)

## [v1.6.0] &ndash; 2018-06-19

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

## [v1.5.0] &ndash; 2018-03-20

### Added

- Added `plantuml.jar` and environemnt variable `PLANTUML_JAR` to enable usage of the [plantuml package](https://www.ctan.org/plantuml).
- Added `graphviz` and `inkscape` for the plantuml package.
- Added `pandoc` to be able to convert `md` to `pdf`.

### Fixed

- `latexmk` is not installed using `apt-get` anymore, because it is already by the parent image.

## [v1.4.1] &ndash; 2018-06-03

### Changed

- Rebuilt due to freeze of TeXLive 2017.

## [v1.4.0] &ndash; 2018-02-13

### Added

- Added [pygments](http://pygments.org/) package to enable [minted](https://github.com/gpoore/minted).
- Added [bundler](http://bundler.io/) to enable testing via [RSpec](http://rspec.info/).

## [v1.3.0] &ndash; 2018-01-10

### Added

- Added [MADR ADRs](https://adr.github.io/madr/).

### Changed

- New base image [sumdoc/texlive-2017](https://hub.docker.com/r/sumdoc/texlive-2017/).
- `WORKDIR` is now `/home` instead of `/var/texlive`.

## [v1.2.0] &ndash; 2017-09-02

### Added

- Ghostscript

## [v1.1.0] &ndash; 2017-09-02

### Added

- packages `python2.7`, `python-pip`, `pyparsing`, and `python-docx` to enable execution of helper scripts
- packages `openjdk-8-jre-headless` and `libfile-which-perl` to enable execution of [pax](http://ctan.org/pkg/pax)
- package [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)

## v1.0.0 &ndash; 2017-08-03

Initial release

[edge]: https://github.com/koppor/docker-texlive/compare/2021-B...HEAD
[2021-D]: https://github.com/koppor/docker-texlive/compare/2021-C...2021-D
[2021-C]: https://github.com/koppor/docker-texlive/compare/2021-B...2021-C
[2021-B]: https://github.com/koppor/docker-texlive/compare/2021-A...2021-B
[2021-A]: https://github.com/koppor/docker-texlive/compare/2020...2021-A
[2020]: https://github.com/koppor/docker-texlive/compare/v1.6.0...2020
[2020-A]: https://github.com/koppor/docker-texlive/compare/2019-A...2020-A
[2019-A]: https://github.com/koppor/docker-texlive/compare/2021-B...2019-A
[v1.6.0]: https://github.com/koppor/docker-texlive/compare/v1.5.1...v1.6.0
[v1.5.0]: https://github.com/koppor/docker-texlive/compare/v1.4.1...v1.5.0
[v1.4.1]: https://github.com/koppor/docker-texlive/compare/v1.4.0...v1.4.1
[v1.4.0]: https://github.com/koppor/docker-texlive/compare/v1.3.0...v1.4.0
[v1.3.0]: https://github.com/koppor/docker-texlive/compare/v1.2.0...v1.3.0
[v1.2.0]: https://github.com/koppor/docker-texlive/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/koppor/docker-texlive/compare/v1.0.0...v1.1.0

<!-- markdownlint-disable-file MD024 -->
