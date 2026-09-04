# Technology behind the build

This project produces a PDF two ways: a per-article `wrapper.pdf` (built
inside `editorial/`, `article1/`, `article2/`) and the merged `newsletter.pdf`
(built at the project root). Both are plain LaTeX documents in the end — the
two article folders just get there by different routes.

```
article1/art.tex  ──────────────┐
editorial/art.tex ───────────── ┼─▶ pdflatex/bibtex ──▶ wrapper.pdf (each)
article2/art.md ──▶ pandoc ─────┘         │
                                           ▼
                    newsletter.tex ──▶ pdflatex ──▶ newsletter.pdf
```

## The shared LaTeX layer: WPnews.sty

Every article — however it was authored — ends up as a LaTeX fragment
(`art.tex`) that is `\input` inside WPnews.sty's `article` environment, either
from a per-article `wrapper.tex` (`\documentclass{report}` +
`\usepackage{WPnews}`) or from the top-level `newsletter.tex`. WPnews.sty
(adapted from `CDKnews.sty`, the style used by *CDK News*) defines:

- The two-column article layout (`multicol`), title page, header/footer
  (`fancyhdr`), and table of contents styling.
- `\title`, `\subtitle`, `\author`, `\maketitle`, `\address`, `\email`.
- `\orcidlink{orcid}` — an ORCID badge (`fontawesome5`'s `\faOrcid` glyph)
  hyperlinked to `https://orcid.org/<orcid>`.
- `\rorlink{ror}` — a ROR (Research Organization Registry) badge, drawn with
  `tikz` from vector path data, hyperlinked to `https://ror.org/<ror>`.
- `\wpdefineaffiliation[ror]{index}{name}` / `\wpaffiliations{1,2}` — an
  indexed affiliation registry (`etoolbox`'s `\forcsvlist` plus
  `\csname...\endcsname`-based storage) so multiple authors can share, and
  print, affiliation text (with an optional ROR badge) by numeric index
  instead of repeating it.
- The `CSLReferences` environment, `\citeproc`/`\citeproctext`, and related
  `\@biblabel`/`\@cite` tweaks — copied from pandoc's own default LaTeX
  template (`pandoc -D latex`). These make `\bibitem` commands emitted by
  pandoc's `--citeproc` (see below) work correctly; without them the
  reference list has nowhere to live and LaTeX errors with "Lonely \item".

Fonts are URW Palatino/`mathpple`+`ae` (`T1` encoding); ISSN/branding text and
the WikiPathways logo (`WPlogo.png`) are on the title page and back-page
colophon.

## Route A — articles written directly in LaTeX

`editorial/` and `article1/` are plain `art.tex` files using the macros
above, with an `art.bib`/`\bibliography{art}` for citations where needed.
Each folder's `Makefile` runs `pdflatex`, and `bibtex` when a `.bib` file is
present, to produce `wrapper.pdf` — the standard, decades-old LaTeX
bibliography toolchain (`.aux` → `bibtex` → `.bbl` → re-run `pdflatex`).

## Route B — articles written in Markdown, converted with pandoc

`article2/` is authored as `art.md`: a Markdown body with a YAML metadata
header for the title, subtitle, DOI, authors (name/email/ORCID/affiliation
index), and an affiliations list (name/index/ROR). Its `Makefile` runs:

```
pandoc --from markdown+raw_tex -s --template=resources/pandoc.template \
  --csl=resources/apa-new.csl \
  --lua-filter=resources/filters/extract-cito.lua \
  --citeproc \
  --lua-filter=resources/filters/insert-cito-in-ref.lua \
  --lua-filter=resources/filters/move-refs-to-end.lua \
  --output=art.tex art.md
```

This pipeline, and the two `extract-cito`/`insert-cito-in-ref` filters and
the `apa-new.csl` style, are taken from the
[BioHackrXiv](https://biohackrxiv.org/) paper-generation project
(`../bhxiv-gen-pdf/`, see its `bin/gen-pdf` and
`resources/biohackrxiv/latex.template`) — the same mechanism BioHackrXiv uses
to turn a Markdown paper into a PDF, reused here for a WPnews.sty-styled
article fragment instead of a full standalone BioHackrXiv paper:

- **[`resources/pandoc.template`](resources/pandoc.template)** — a minimal
  pandoc LaTeX template (no `\documentclass`/preamble) that reads the YAML
  metadata and emits `\title`/`\subtitle`/`\author` (with `\orcidlink` per
  author) and `\wpdefineaffiliation` calls (with `\rorlink` when a `ror` is
  given), i.e. it drives WPnews.sty's macros instead of the `authblk`-based
  ones in BioHackrXiv's own template.
- **`--citeproc` + `resources/apa-new.csl`** — pandoc's built-in
  [citeproc](https://github.com/jgm/pandoc/blob/main/MANUAL.txt#citations)
  engine resolves `[@key]` citations against the article's `art.bib` and
  renders a formatted, numbered/author-date reference list per the CSL
  style — no separate `bibtex` step is needed for this route.
- **`resources/filters/extract-cito.lua`** — runs *before* citeproc. It lets
  a citation key carry a [CiTO](https://sparontologies.github.io/cito/current/cito.html)
  citation-intention prefix, e.g. `[@usesMethodIn:Lorem2026]`, strips the
  prefix so citeproc sees the plain BibTeX key `Lorem2026`, and records the
  CiTO property for the next filter.
- **`resources/filters/insert-cito-in-ref.lua`** — runs *after* citeproc. It
  finds the matching bibliography entry (a `Div` with id `ref-Lorem2026`) and
  appends a bold `[cito:usesMethodIn]` annotation to it.
- **`resources/filters/move-refs-to-end.lua`** — not from BioHackrXiv; a
  small filter written for this project. Pandoc/citeproc normally inserts the
  formatted bibliography right where the `# References` heading sits in the
  Markdown body. This filter extracts that heading and the citeproc `refs`
  `Div` out of the body and stores them in the document's metadata (as
  `wpreferences`) instead, so `resources/pandoc.template` can place the
  reference list after the DOI and author/affiliation block, matching the
  layout used elsewhere in the newsletter.

The resulting `art.tex` is a WPnews.sty-flavoured fragment exactly like the
hand-written ones, so from that point on it's built the same way as route A:
`pdflatex` via `article2/wrapper.tex`.

## Assembling the issue

`newsletter.tex` is the top-level document: it sets the volume/date, calls
`\titlepage`, then wraps each article's `art.tex` (plus its `.bbl`, for
articles using the plain LaTeX bibliography route) in a WPnews.sty `article`
environment, and finishes with a back-page colophon. The top-level
`Makefile`'s `separateArts` target builds every article subfolder first (so
their `art.tex`/`.bbl` exist), then runs `pdflatex` twice on `newsletter.tex`
(twice, so cross-references and the table of contents settle).
