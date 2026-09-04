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
cd vol1/issue1/article2 && make clean && make
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
non-interactively. This is also useful for catching *silent* breakage:
comparing `pdftotext` output before/after a change surfaced a case where
`\printbibliography[title=References]` rendered as a giant "R" followed by
"eferences" in body text on the next line — a latent missing-braces bug in
`WPnews.sty`'s `\@schapter` (`\section*#1` instead of `\section*{#1}`) that
plain-macro-token titles like `\bibname` had always accidentally avoided
triggering, until a literal multi-character string was passed through the
same code path for the first time.

## `biber`

Invoked by each `Makefile` (top-level and per-article), not usually run by
hand — every article uses biblatex with `backend=biber` (see
`TECHNOLOGY.md`). One `biber <jobname>` run resolves *every*
`\begin{article}`'s `refsection` in that document at once, regardless of how
many there are — unlike `bibtex`, which needs a separate run per
`refsection`, on a filename only known after the first `pdflatex` pass (see
below for why that was the fallback for a while). Full sequence when
debugging by hand:

```sh
pdflatex -interaction=nonstopmode wrapper
biber wrapper
pdflatex -interaction=nonstopmode wrapper
pdflatex -interaction=nonstopmode wrapper
```

Why: `biber`'s own log (`<jobname>.blg`) is where to look first when a
citation doesn't resolve or a `.bib` entry seems to be getting the wrong
data — it reports, per `refsection`, which `.bib` file(s) it searched and
what it found, which is more direct than working backwards from `pdflatex`'s
"undefined reference" warnings.

Biber wasn't available when biblatex was first added to this project (this
system had no `biber` installed, and no passwordless `sudo` to add it
non-interactively — checked with `apt-cache policy biber` and `sudo -n
true`), so `backend=bibtex` (the classic engine, already installed) was used
initially; migrating to `backend=biber` once it was installed only meant
changing one option in `WPnews.sty` and replacing each `Makefile`'s
discovery-loop-plus-bibtex step with a single `biber <jobname>` call — the
rest of the pipeline (biblatex itself, `\printbibliography`, `refsection`
scoping, the CiTO `\finentrypunct` hook) is backend-agnostic and needed no
changes.

## `pandoc`, run directly

Used standalone, outside the Makefile, to inspect intermediate output while
building the Markdown/pandoc pipeline — both the final LaTeX and pandoc's
internal AST.

```sh
# See the exact LaTeX a template produces, without writing files:
pandoc --from markdown+raw_tex -s --template=t.template --output=t-out.tex t.md
cat t-out.tex

# Inspect pandoc's internal document tree (Cite/Header/Meta nodes) instead
# of LaTeX text, standalone (-s) so the YAML metadata block is included, to
# see exactly what a Lua filter needs to match against (run from an
# articleN/ folder, hence ../../../resources/ - see TECHNOLOGY.md):
pandoc --from markdown+raw_tex -t native -s \
  --lua-filter=../../../resources/filters/extract-cito.lua art.md
```

Why: the first form was how the minimal `pandoc.template` fragment (title/
author/affiliation from YAML) was designed and checked before wiring it into
`article2/Makefile`, and later how `--biblatex`'s output (a plain
`\cite{key}`, versus `--citeproc`'s pre-rendered text) was confirmed before
switching the pipeline over. The second (`-t native -s`) was essential for
writing `resources/filters/cito-to-biblatex.lua` correctly — it showed
`extract-cito.lua` stores each citation's CiTO property as
`citation_properties: MetaMap {key: MetaList [MetaString "property"]}` in
the document metadata, i.e. the filter needed `pandoc.utils.stringify()` on
the list items but not the (plain Lua string) map keys — not obvious
without looking at the actual wire format.

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

Why: e.g. before adding ROR-badge support (which needs `tikz`) or migrating
citations to biblatex (which needs `biblatex.sty`, plus the specific style
package for whatever `style=` is chosen — `kpsewhich trad-unsrt.bbx`
confirmed the `biblatex-trad` style family, used to reproduce the old plain
`bibtex` `unsrt` look, was actually installed), confirming a package
resolves on this system avoids chasing a phantom "undefined control
sequence" that's really just a missing `texlive` package.

## `curl`

Used to fetch the WikiPathways logo image(s) used on the title page.

```sh
curl -sL -o WPicon.png "https://upload.wikimedia.org/wikipedia/commons/3/34/Wplogo_500.png"
```

Why: the direct image URL (as opposed to the Wikimedia Commons *file
description page*, which is an HTML page, not the image) was resolved first
via `WebFetch` reading the description page for the real upload URL and its
CC BY-SA 4.0 / Alex Pico attribution, then downloaded with `curl` for use in
the project — with the attribution added to `newsletter.tex`'s back-page
colophon per that license's requirements. The project initially used a
different Commons file, `Wplogo_with_text_500.png` (the icon plus a
"WikiPathways" wordmark baked into the same image), which worked fine at a
fixed height; once the title-page banner needed to size the logo to exactly
the title text's cap-height, that combined image made the icon glyph itself
shrink to near-invisibility (most of the image's height being the wordmark
below it) — `WebFetch` on the Commons search results page for "WikiPathways
logo" found the icon-only `Wplogo_500.png` instead, which was the actual
fix, not a code change.

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
the CSL style then in use, and the Lua filters from `article2/` into a
shared top-level `resources/` folder (the CSL style was later deleted
outright, once the CiTO/citation pipeline moved from pandoc's `--citeproc`
to native `--biblatex` and stopped needing one — deleting a file that has
become genuinely unused, rather than leaving it as clutter, is itself just
`rm`):

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

The same tools were used for a much larger restructuring: splitting the
original single-issue layout into `vol1/issue1/` (a real issue) and
`template/` (a copy source for future issues), keeping only the truly
shared files (`WPnews.sty`, `WPicon.png`, `resources/`) at the repository
root:

```sh
mkdir -p vol1/issue1 template
for f in newsletter.tex Makefile editorial article1 article2 article3; do
  cp -r "$f" vol1/issue1/
  cp -r "$f" template/
done
rm -rf newsletter.tex Makefile editorial article1 article2 article3
```

Why `cp` twice then `rm`, rather than `mv` once plus a second `cp`: at that
point it wasn't yet decided whether `template/` or `vol1/issue1/` should be
the "original" and the other a copy of it — doing both as copies from the
same source and only then deleting the source treats them symmetrically and
avoids ever having a moment where only one of the two exists.

Because `template/` sits one level below the repository root but its copied
paths assume the two-levels-down position a real `vol<N>/issue<M>/` has
(see `TECHNOLOGY.md`), it cannot be built in place — confirmed by trying,
which failed with `File '../../../WPnews.sty' not found`, exactly as
expected once the depth mismatch was worked out. To actually verify the
template is correct, it needs testing at the depth it will be used at:

```sh
mkdir -p /tmp/tpl-verify/volX/issueY
cp WPnews.sty WPicon.png /tmp/tpl-verify/
cp -r resources /tmp/tpl-verify/
cp -r template/* /tmp/tpl-verify/volX/issueY/
cd /tmp/tpl-verify/volX/issueY && make
```

Why: this is the only way to test what a *user* of the template will
actually experience (`cp -r template vol2/issue1 && cd vol2/issue1 && make`)
without touching the real repository — and it caught nothing, because the
paths had already been written for that depth from the start, but it's what
would have caught it if they hadn't.
