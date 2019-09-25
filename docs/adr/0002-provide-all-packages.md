# Provide all packages

## Context and Problem Statement

Should the Docker image include all packages or a subset of the packages?

## Considered Options

* Provide all packages
* Provide a subset of packages
* Provide a minimal set of packages and use [texliveonfly](https://ctan.org/pkg/texliveonfly)

## Decision Outcome

Chosen option: "Provide all packages", because 

* texliveonfly does not work on all packages
* speeds-up compilation time (because no additional download)

We accept that the final image is ~2GB of size.
