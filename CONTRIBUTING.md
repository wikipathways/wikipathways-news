# Contributing

This project was built and iterated on with a small set of command-line
tools. This document lists them, with an example of how each was actually
invoked during development and why — useful if you're changing `WPnews.sty`,
the pandoc pipeline, or adding a new article and want to verify the result
the same way.

## GNU Make

The primary way to build. Used both at the top level and inside individual
article folders, so a single article can be iterated on without rebuilding
the whole issue.

```sh
cd article2 && make clean && make
```

Why: `make clean && make` (rather than plain `make`) guarantees a fresh
build when a dependency changed in a way the Makefile's prerequisites don't
track precisely (e.g. `resources/pandoc.template` changing while
`article2/art.tex` was still newer on disk) — important when actively
editing the shared template/filters.

## `pdflatex`, run directly

Used outside of `make` when debugging a LaTeX error in isolation, so the
failure and its exact log line are visible without unrelated build output in
the way.

```sh
pdflatex -interaction=nonstopmode -halt-on-error art
```

Why `-interaction=nonstopmode -halt-on-error`: plain `pdflatex` drops into an
interactive `?` prompt on error and hangs; these flags make it fail fast and
non-interactively, which is what surfaced the "Lonely `\item`" error from
pandoc's `\bibitem` output not having a `CSLReferences` list environment to
live in (see `TECHNOLOGY.md`).

## `bibtex`

Invoked by each article `Makefile`, not run by hand — but worth knowing when
it fires: only for articles using the plain-LaTeX bibliography route
(`\bibliography{art}` + `art.bib`, as in `article1/`). Route B
(`article2/`, Markdown via pandoc) uses pandoc's `--citeproc` instead and
never calls `bibtex`.

## `pandoc`, run directly

Used standalone, outside the Makefile, to inspect intermediate output while
building the Markdown/pandoc pipeline — both the final LaTeX and pandoc's
internal AST.

```sh
# See the exact LaTeX a template produces, without writing files:
pandoc --from markdown+raw_tex -s --template=t.template --output=t-out.tex t.md
cat t-out.tex

# Inspect pandoc's internal document tree (Cite/Div/Header nodes) instead of
# LaTeX text, to see exactly what a Lua filter needs to match against:
pandoc --from markdown+raw_tex -t native --citeproc --csl=apa-new.csl art.md
```

Why: the first form was how the minimal `pandoc.template` fragment (title/
author/affiliation from YAML) was designed and checked before wiring it into
`article2/Makefile`. The second (`-t native`) was essential for writing
`resources/filters/move-refs-to-end.lua` correctly — it showed that
citeproc's bibliography is a `Div` with id `"refs"` following a
`Header` with id `"references"`, which the filter needed to match exactly.

## `pdftoppm` (poppler-utils) + visual inspection

Every non-trivial layout change was rendered to PNG and actually looked at,
not just compiled. A clean `pdflatex` exit code does not mean the ORCID badge
sits in the right place or that a table of contents entry links correctly.

```sh
pdftoppm -png -r 150 wrapper.pdf /path/to/scratch/preview
```

Why `-r 150`: high enough resolution to read body text and check small
elements (ORCID/ROR badges, hyperlink boxes) clearly when the PNG is
displayed, without generating unnecessarily large files for a quick check.
The resulting PNG was then opened directly to visually confirm, for example,
that the ROR badge appears only for the affiliation that has a `ror:` field,
or that the References section moved to the intended position on the page.

## `kpsewhich`

Used to check whether a LaTeX package this project depends on is actually
installed, before writing code that assumes it is (or debugging as if it
were a code bug when it's actually a missing package).

```sh
kpsewhich fontawesome5.sty tikz.sty lipsum.sty biblatex.sty
```

Why: e.g. before adding ROR-badge support (which needs `tikz`) or the
CiTO/citeproc pipeline (which needs `biblatex`, though ultimately unused
directly — see `TECHNOLOGY.md`), confirming the package resolves on this
system avoids chasing a phantom "undefined control sequence" that's really
just a missing `texlive` package.

## `curl`

Used once, to fetch the WikiPathways logo used on the title page.

```sh
curl -sL -o WPlogo.png "https://upload.wikimedia.org/wikipedia/commons/8/83/Wplogo_with_text_500.png"
```

Why: the direct image URL (as opposed to the Wikimedia Commons *file
description page*, which is an HTML page, not the image) was resolved first
via `WebFetch` reading the description page for the real upload URL and its
CC BY-SA 4.0 / Alex Pico attribution, then downloaded with `curl` for use in
the project — with the attribution added to `newsletter.tex`'s back-page
colophon per that license's requirements.

## `grep` / `find`

Used throughout to study the two reference projects this newsletter's
conventions are drawn from — `../cdk-cdknews/` (the CDK News LaTeX
Makefile/package layout) and `../bhxiv-gen-pdf/` (the BioHackrXiv
Markdown/pandoc pipeline) — before writing anything new, so new code mirrors
existing, working conventions rather than inventing incompatible ones.

```sh
grep -n "ROR support" -A 45 ../bhxiv-gen-pdf/resources/biohackrxiv/latex.template
```

Why: pulling the *exact* ROR-logo TikZ code (rather than retyping it from
memory) avoids transcription errors in a long, precise vector path — the kind
of thing worth copying verbatim and adapting (color model, variable names)
rather than reconstructing.

## Plain filesystem commands (`mkdir`, `mv`, `ls`)

Used for straightforward restructuring, e.g. moving `pandoc.template`,
`apa-new.csl`, and the Lua filters from `article2/` into a shared top-level
`resources/` folder:

```sh
mkdir -p resources/filters
mv article2/pandoc.template resources/pandoc.template
mv article2/apa-new.csl resources/apa-new.csl
mv article2/filters/*.lua resources/filters/
```

Why: after the move, every build (`article2/wrapper.pdf` standalone and the
full `newsletter.pdf`) was rebuilt from a clean state (`make clean && make`)
to confirm the updated `../resources/...` paths in `article2/Makefile` were
correct — a rename/move is only "done" once the build proves the new paths
resolve, not when the files are in the new location.
