# Technology behind the build

## Repository structure: one root, many issues

This repository holds many issues (`vol1/issue1/`, `vol1/issue2/`,
`vol2/issue1/`, ...), each two levels below the repository root, plus
`template/` (a copy source for a new issue - not a real issue itself, and
not built in place; see README.md). Everything an issue needs that's
*shared* across every issue - `WPnews.sty`, `WPicon.png`, `resources/` (the
pandoc pipeline for route B below) - lives once at the repository root.

Every path inside an issue that reaches those shared files is therefore
written relative to that fixed two-levels-down position: `../../WPnews.sty`
and `\graphicspath{{../../}}` in `newsletter.tex`, `../../../WPnews.sty` in
each `articleN/wrapper.tex` and `editorial/wrapper.tex` (one level deeper
than `newsletter.tex`), and `../../../resources/` in `article2/Makefile` /
`article3/Makefile`'s pandoc invocation. This is exactly why `template/`
only builds once copied to an actual `vol<N>/issue<M>/` location: its paths
already assume that depth, so it's checked by copying it there (see
`CONTRIBUTING.md`), not by building it where it sits.

The root `Makefile` builds every issue it finds
(`$(wildcard vol*/issue*)`); each issue also has its own `Makefile` (see
below) to build just that issue standalone.

## Building one issue

Within one issue folder, a PDF is produced two ways: a per-article
`wrapper.pdf` (built inside `editorial/`, `article1/`, `article2/`,
`article3/`) and the merged `newsletter.pdf` (built at that issue's own
root). Both are plain LaTeX documents in the end — the article folders just
get there by different routes.

```
article1/art.tex  ──────────────┐
editorial/art.tex ───────────── ┼─▶ lualatex/biblatex ──▶ wrapper.pdf (each)
article2/art.md ──▶ pandoc ─────┤         │
article3/art.md ──▶ pandoc ─────┘         ▼
                    newsletter.tex ──▶ lualatex/biblatex ──▶ newsletter.pdf
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
- **biblatex**, loaded with `backend=biber` (biblatex's default, more
  capable backend) and `style=trad-unsrt` (a style from the `biblatex-trad`
  family that reproduces the look of the plain `bibtex` `unsrt` style this
  project used before). `\cite`/`\printbibliography` are biblatex's, not
  plain LaTeX's/`natbib`'s.
- Every `\begin{article}...\end{article}` opens/closes a biblatex
  `refsection`, so each article's citations and `\printbibliography` are
  scoped to that article alone: numbering restarts at `[1]` per article, and
  (critically, for a document assembling several independently-authored
  articles) one article's citations can never resolve against another
  article's `.bib` file even though `newsletter.tex` loads every article's
  resource at once (see "Assembling the issue" below).
- `\wpcitoannotate{key}{property}` / a redefined `\finentrypunct` — biblatex's
  per-entry hook, fired just before each bibliography entry's closing
  punctuation — print a bold `[cito:property]` annotation after entries that
  have one (see CiTO, under Route B below). This works for both routes,
  since both ultimately go through the same `\printbibliography`.

Fonts are URW Palatino/`mathpple`+`ae` (`T1` encoding); ISSN/branding text and
the WikiPathways icon (`WPicon.png`) are on the title page and back-page
colophon. The title-page banner ("WikiPathways News") sizes the icon to
exactly the cap-height of the title's "W" (`\settoheight`, a core LaTeX
command — measure a glyph's height into a length register), then scales the
whole icon+title line to fill `\textwidth` with `graphicx`'s `\resizebox`,
which is what keeps it on one line and shrinks the title font to fit
regardless of exactly how long the title text is.

## Route A — articles written directly in LaTeX

`editorial/` and `article1/` are plain `art.tex` files using the macros
above, with an `\addbibresource{art.bib}` (in the surrounding `wrapper.tex`'s
preamble) and `\printbibliography` for citations where needed.

## Route B — articles written in Markdown, converted with pandoc

`article2/` is authored as `art.md`: a Markdown body with a YAML metadata
header for the title, subtitle, DOI, authors (name/email/ORCID/affiliation
index), and an affiliations list (name/index/ROR). Its `Makefile` runs:

```
pandoc --from markdown+raw_tex -s --template=../../../resources/pandoc.template \
  --biblatex \
  --lua-filter=../../../resources/filters/extract-cito.lua \
  --lua-filter=../../../resources/filters/cito-to-biblatex.lua \
  --output=art.tex art.md
```

(`../../../resources/` because `article2/` sits three levels below the
repository root, where `resources/` actually lives — see "Repository
structure" above.)

This is modeled on the pandoc invocation in the
[BioHackrXiv](https://biohackrxiv.org/) paper-generation project
(`../bhxiv-gen-pdf/`, see its `bin/gen-pdf`) — reused here for a
WPnews.sty-styled article fragment instead of a full standalone BioHackrXiv
paper, and with `--biblatex` instead of BioHackrXiv's own `--citeproc`, so
that both authoring routes ultimately share the exact same biblatex
rendering (numbering, style, per-article `refsection` scoping) rather than
two different citation engines producing two different-looking reference
lists:

- **[`resources/pandoc.template`](resources/pandoc.template)** — a minimal
  pandoc LaTeX template (no `\documentclass`/preamble) that reads the YAML
  metadata and emits `\title`/`\subtitle`/`\author` (with `\orcidlink` per
  author), `\wpdefineaffiliation` calls (with `\rorlink` when a `ror` is
  given), and a `\printbibliography[title=References]` after the
  DOI/author/affiliation block — driving WPnews.sty's macros instead of the
  `authblk`-based ones in BioHackrXiv's own template.
- **`--biblatex`** — pandoc's native biblatex output mode: `[@key]`
  citations become plain `\cite{key}` commands, with *no* bibliography text
  generated by pandoc itself (unlike `--citeproc`) — biblatex/`biber`
  render the actual reference list later, at `lualatex` time, from
  `article2/art.bib` (loaded via `\addbibresource` in `article2/wrapper.tex`,
  or in `newsletter.tex` for the merged build). Because of this, a bare
  `# References` heading (which `--citeproc` needed as an insertion point)
  is no longer used in `art.md` — pandoc silently drops it, and
  `\printbibliography` in the template supplies the heading instead.
- **`resources/filters/extract-cito.lua`** (from `bhxiv-gen-pdf`) — lets a
  citation key carry a
  [CiTO](https://sparontologies.github.io/cito/current/cito.html)
  citation-intention prefix, e.g. `[@usesMethodIn:LoremVis2026]`, strips the
  prefix so `\cite{LoremVis2026}` gets the plain BibTeX key, and records the
  CiTO property (as pandoc metadata) for the next filter.
- **`resources/filters/cito-to-biblatex.lua`** — not from BioHackrXiv (whose
  own `insert-cito-in-ref.lua` annotates citeproc's pre-rendered bibliography
  text, which doesn't exist under `--biblatex`). Reads the CiTO property
  metadata `extract-cito.lua` recorded and emits a
  `\wpcitoannotate{key}{property}` call at the top of the document, for
  WPnews.sty's `\finentrypunct` hook to pick up when biblatex prints that
  entry.

The resulting `art.tex` is a WPnews.sty-flavoured fragment exactly like the
hand-written ones, so from that point on it's built the same way as route A:
`lualatex`/biblatex via `article2/wrapper.tex`.

## Assembling the issue

`newsletter.tex` is the top-level document: it sets the volume/date, calls
`\titlepage`, declares `\addbibresource` for every article's `.bib` file,
then `\input`s each article's `art.tex` inside a WPnews.sty `article`
environment (which, as above, opens its own `refsection` — so each article's
citations resolve only against its own `.bib`, and its `\printbibliography`
call renders only its own references, independently of the other articles
sharing the document), and finishes with a back-page colophon.

Every `Makefile` (top-level and per-article) runs `lualatex`, then a single
`biber <jobname>` call — with `backend=biber`, one `biber` run resolves
*every* `refsection` in the document at once, regardless of how many there
are, unlike the `backend=bibtex` fallback this project used before biber was
installed (which needed a separate `bibtex` run per `refsection`, on
filenames only discoverable after the first `lualatex` pass) — then two more
`lualatex` passes. Because each article's `art.tex` runs through the
identical `\begin{article}...\printbibliography...\end{article}` sequence
whether it's compiled standalone (via its own `wrapper.tex`) or merged (via
`newsletter.tex`), the two contexts render that article's reference list
identically.

Two articles' `.bib` files *within the same issue* should not reuse the same
citation key, even if they never cite each other's entries: that issue's
`newsletter.tex` loads every one of its articles' `.bib` resources at once
(each `refsection` only *uses* its own article's keys, but all resources are
visible to all of them), so a key repeated across two `.bib` files is a real
ambiguity once they're merged into one document — `article1/art.bib` and
`article2/art.bib` collided this way during development (both had copied the
same placeholder entry under the key `Lorem2026`) and were fixed by renaming
one; keep citation keys unique within an issue to avoid it recurring. Keys
*can* be reused across different issues (`vol1/issue1/article1/art.bib`'s
keys and `vol1/issue2/article1/art.bib`'s keys, say) since different issues
never share a `newsletter.tex`/compilation.
