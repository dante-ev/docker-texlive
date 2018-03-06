# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v1.4.1] - 2018-06-03

### Changed
- Rebuilt due to freeze of TeXLive 2017.

## [v1.4.0] - 2018-02-13

### Added
- Added [pygments](http://pygments.org/) package to enable [minted](https://github.com/gpoore/minted).
- Added [bundler](http://bundler.io/) to enable testing via [RSpec](http://rspec.info/).

## [v1.3.0] - 2018-01-10

### Added
- Added [MADR ADRs](https://adr.github.io/madr/).

### Changed
- New base image [sumdoc/texlive-2017](https://hub.docker.com/r/sumdoc/texlive-2017/).
- `WORKDIR` is now `/home` instead of `/var/texlive`.

## [v1.2.0] - 2017-09-02

### Added

- Ghostscript

## [v1.1.0] - 2017-09-02

### Added

- packages `python2.7`, `python-pip`, `pyparsing`, and `python-docx` to enable execution of helper scripts
- packages `openjdk-8-jre-headless` and `libfile-which-perl` to enable execution of [pax](http://ctan.org/pkg/pax)
- package [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)

## v1.0.0 - 2017-08-03

Initial release

[Unreleased]: https://github.com/koppor/docker-texlive/compare/v1.4.1...HEAD
[v1.4.1]: https://github.com/koppor/docker-texlive/compare/v1.4.0...v1.4.1
[v1.4.0]: https://github.com/koppor/docker-texlive/compare/v1.3.0...v1.4.0
[v1.3.0]: https://github.com/koppor/docker-texlive/compare/v1.2.0...v1.3.0
[v1.2.0]: https://github.com/koppor/docker-texlive/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/koppor/docker-texlive/compare/v1.0.0...v1.1.0
