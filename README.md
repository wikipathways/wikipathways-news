# WikiPathways News

A LaTeX newsletter project for **WikiPathways News**, modeled on the *CDK News*
newsletter (see `../cdk-cdknews/`). One issue is assembled from a title page,
an editorial, and one or more articles, all typeset with a shared house style
defined in [`WPnews.sty`](WPnews.sty).

The current issue's content is placeholder [lipsum](https://ctan.org/pkg/lipsum)
text — this project is a template/skeleton to build real issues from.

## Project layout

```
WPnews.sty          House style: title page, two-column article layout,
                     \address/\email/\orcidlink/ROR/affiliation macros, etc.
WPicon.png           WikiPathways icon (CC BY-SA 4.0, Alex Pico), used on
                     the title page.
newsletter.tex        Top-level document: title page + \input of each
                       article + back-page colophon.
Makefile              Builds the whole issue (see "Building" below).

editorial/             The issue's editorial (LaTeX).
article1/               A LaTeX-authored article.
article2/               A Markdown-authored article (converted via pandoc),
                         with a citation and reference list.
article3/               A Markdown-authored article with no citations, to
                         demonstrate a references section is optional.
resources/              Shared pandoc template and Lua filters used by
                         Markdown-authored articles.
```

Each of `editorial/`, `article1/`, `article2/`, `article3/` is buildable standalone
(producing its own `wrapper.pdf`) and is also pulled into the merged
`newsletter.pdf`.

## Building

```sh
make            # build every article, then newsletter.pdf
make update     # rebuild newsletter.pdf only (assumes articles built)
make clean      # remove build artifacts in the top-level folder
make distclean  # clean the top-level folder and every article subfolder
```

To work on a single article without rebuilding everything:

```sh
cd article1 && make      # -> article1/wrapper.pdf
cd article2 && make      # -> article2/wrapper.pdf
```

Requires a TeX Live installation (`pdflatex`, `biblatex`, `biber`) and, for
Markdown-authored articles, [`pandoc`](https://pandoc.org/) (tested with
pandoc 3.1).

## Writing an article

There are two ways to author an article for this newsletter. Both end up as
an `art.tex` fragment that gets `\input` into a `wrapper.tex` (for standalone
builds) and into `newsletter.tex` (for the merged issue), inside WPnews.sty's
`article` environment.

### 1. Directly in LaTeX (see `article1/`, `editorial/`)

Write `art.tex` using the macros WPnews.sty provides:

```latex
\title{Article Title}
\subtitle{One or two sentences describing the article.}
\author{by Jane Doe\orcidlink{0000-0003-4567-8901}}

\maketitle

\section*{Introduction}
... article text ...

\address{Jane Doe\orcidlink{0000-0003-4567-8901}\\
Some University, Some Country\\
\email{jane.doe@example.org}}

\printbibliography   % optional, needs \addbibresource{art.bib} in
                      % wrapper.tex's preamble and a matching art.bib
```

Add a `wrapper.tex` and `Makefile` copied from `article1/` (drop the
`\addbibresource`/`\printbibliography` lines if the article has no
citations, as in `editorial/`), then add the new folder to the top-level
`Makefile`'s `separateArts`/`distclean` targets, add
`\addbibresource{<folder>/art.bib}` to `newsletter.tex`'s preamble if it has
one, and `\input` the article from `newsletter.tex`.

### 2. In Markdown, converted with pandoc (see `article2/`)

Write `art.md` with a YAML header carrying the title, subtitle, authors
(with optional `orcid` and an `affiliation` index), an `affiliations` list
(with optional `ror` identifiers), and an optional `doi`:

```markdown
---
title: Article Title
doi: 10.xxxx/xxxxx
authors:
  - name: Jane Doe
    email: jane.doe@example.org
    orcid: 0000-0003-4567-8901
    affiliation: 1
affiliations:
  - name: Some University, Some Country
    index: 1
    ror: 00hx57361
---

# Introduction

Article text, with pandoc-style citations, e.g. [@usesMethodIn:LoremVis2026]
(a CiTO-annotated citation key — see TECHNOLOGY.md), resolved against a
matching `art.bib`.
```

`article2/Makefile` runs `pandoc` with the shared template and filters in
[`resources/`](resources/) to turn `art.md` into an `art.tex` fragment in the
same house style as hand-written articles — including resolved ORCID/ROR
badges — and native `\cite{}`/`\printbibliography` calls that render through
the same biblatex setup as LaTeX-authored articles (see TECHNOLOGY.md). Copy
`article2/` as a starting point for a new Markdown article (note that a
bib entry's citation key must be unique across every article that will ever
share a `newsletter.tex`, since all articles' `.bib` files are loaded
together), and wire it into the top-level `Makefile`/`newsletter.tex` the
same way as above.

See [`TECHNOLOGY.md`](TECHNOLOGY.md) for how both pipelines work under the
hood, and [`CONTRIBUTING.md`](CONTRIBUTING.md) for the tools used to develop
and test this project.
