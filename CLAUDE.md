# docker-texlive

Full TeX Live Docker image published as `danteev/texlive` (Docker Hub) and
`ghcr.io/dante-ev/texlive`. It builds on the
[Island of TeX TeX Live image](https://gitlab.com/islandoftex/images/texlive) and
adds tooling: pandoc, PlantUML, Mermaid CLI (with Node.js and Chromium), TikZ-UML, TeXtidote,
inkscape, graphviz, latexml, bibtool, gnuplot, fig2dev, DEPP, fonts, etc. See `Dockerfile`.

## Build & smoke test

```bash
docker build -t ghcr.io/dante-ev/texlive:edge .

docker run --rm ghcr.io/dante-ev/texlive:edge bash -c '
  tex --version | head -1
  pandoc --version | head -1
  plantuml -version | head -1
  mmdc --version
  textidote --version | head -1
  kpsewhich tikz-uml.sty'
```

`.github/workflows/check-build.yml` compiles the samples in `test/` on push/PR.
`.github/workflows/publish.yml` builds multi-arch (amd64+arm64) and pushes on
schedule (1st & 15th), on tag push, and on push to `main`.

## Versioning

Versions are **`YYYY-R`** where `YYYY` is the TeX Live year and `R` is a letter
(`2026-A`, `2026-B`, …). Letters avoid confusion with the dated auto-builds
(`2026-05-17`). The scheme is non-semver on purpose — see `CHANGELOG.md`.

## Upstream base image & reproducibility

- **`main` tracks `:latest`** so the scheduled `edge` builds pick up new upstream
  TeX Live automatically.
- **A tagged release pins the base** to a specific dated upstream tag for
  reproducibility, e.g. `…/texlive:TL2026-2026-06-26-full`. The `Dockerfile`
  keeps both lines, with the inactive one commented as a toggle.

Find the newest pinnable upstream tag (the `full` variant) — the registry tag
list is paginated via a `last=` cursor:

```bash
REPO=islandoftex/images/texlive
TOKEN=$(curl -s "https://gitlab.com/jwt/auth?service=container_registry&scope=repository:$REPO:pull" \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
last=""; while :; do
  url="https://registry.gitlab.com/v2/$REPO/tags/list?n=200"; [ -n "$last" ] && url="$url&last=$last"
  curl -s -D h.txt -H "Authorization: Bearer $TOKEN" "$url" | grep -o '"[^"]*"' | tr -d '"' >> tags.txt
  last=$(grep -i '^link:' h.txt | sed -n 's/.*last=\([^&>]*\).*/\1/p'); [ -z "$last" ] && break
done
grep -E "^TL$(date +%Y)-.*-full$" tags.txt | sort | tail -1
```

## Cutting a release (e.g. `2026-A`)

1. `CHANGELOG.md`: promote the `## [edge]` entries into a new
   `## TeXLive <year>` / `### [<year>-R] – <date>` section, add the `[<year>-R]`
   compare link, and add the `## TeXLive <year>` anchor to the Versions list.
2. `Dockerfile`: **pin** `FROM` to the chosen `TL…-full` tag (comment out
   `:latest`).
3. Commit `Release <year>-R` and tag it `<year>-R`. **Pushing the tag triggers
   `publish.yml`** to build & push `danteev/texlive:<year>-R` and
   `ghcr.io/dante-ev/texlive:<year>-R`.
4. Commit `Switch back to :latest` so `main`/`edge` keeps tracking upstream.

`dante-ev/latex-action`'s matching release must be cut **after** the
`ghcr.io/dante-ev/texlive:<year>-R` image is published, because it builds `FROM`
it.

## CHANGELOG checks

`CHANGELOG.md` is validated in CI by `.github/workflows/check-changelog.yml`
([heylogs](https://github.com/nbbrd/heylogs), Keep a Changelog). Because this
changelog uses a custom layout, `heylogs.properties` disables the rules that
clash with it; keep the changelog passing `heylogs check` (run locally via
`jbang com.github.nbbrd.heylogs:heylogs-cli:0.18.1:bin check CHANGELOG.md`).

## Markdown checks

`.github/workflows/check-markdown.yml` runs markdownlint (rules in `.markdownlint.yml`) and
textlint (rules in `.textlintrc.json`) on all Markdown files. Run locally:

```bash
npx -y markdownlint-cli2 "**/*.md"
npx --yes --package textlint@15.8.0 --package textlint-rule-terminology@5.2.16 \
  --package textlint-rule-common-misspellings@1.0.1 textlint $(git ls-files '*.md')
```
