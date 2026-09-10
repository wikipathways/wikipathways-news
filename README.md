# WikiPathways News

A LaTeX newsletter project for **WikiPathways News**, modeled on the *CDK News*
newsletter (see `../cdk-cdknews/`). One **issue** is assembled from a title
page, an editorial, and one or more articles, all typeset with a shared house
style defined in [`WPnews.sty`](WPnews.sty). Issues are grouped into
**volumes**; a volume typically has at least two issues.

This repository holds many issues over time: `vol1/issue1/`, `vol1/issue2/`,
`vol2/issue1/`, and so on, each an independent, standalone-buildable
newsletter. Everything an issue needs that doesn't change between issues -
the house style, the logo, the pandoc pipeline for Markdown-authored
articles - lives once at the repository root and is shared by every issue.

## Project layout

```
WPnews.sty          House style: title page, two-column article layout,
                     \address/\email/\orcidlink/ROR/affiliation macros, etc.
WPicon.png           WikiPathways icon (CC BY-SA 4.0, Alex Pico), used on
                     the title page.
resources/           Shared pandoc template and Lua filters used by
                      Markdown-authored articles (see TECHNOLOGY.md).
Makefile              Builds every issue found under vol*/issue*/.

template/              Starting point for a new issue - copy this to start
                        vol<N>/issue<M>/ (see "Starting a new issue" below).
                        Not itself a real issue, and not built by the root
                        Makefile.

vol1/issue1/            An issue. Its content is currently placeholder
                         lipsum (https://ctan.org/pkg/lipsum) text.
vol1/issue2/, ...        More issues, added the same way over time.
```

Inside every issue folder (`template/`, and every `vol<N>/issue<M>/`):

```
newsletter.tex        Top-level document for this issue: title page +
                       \input of each article + back-page colophon.
Makefile               Builds this issue (see "Building" below).

editorial/              The issue's editorial (LaTeX).
article1/                A LaTeX-authored article.
article2/                A Markdown-authored article (converted via
                          pandoc), with a citation and reference list.
article3/                A Markdown-authored article with no citations, to
                          demonstrate a references section is optional.
```

Each of `editorial/`, `article1/`, `article2/`, `article3/` is buildable
standalone (producing its own `wrapper.pdf`) and is also pulled into the
merged `newsletter.pdf` for that issue.

## Building

Build every issue in the repository:

```sh
make            # -> vol1/issue1/newsletter.pdf, vol1/issue2/newsletter.pdf, ...
make clean      # remove build artifacts from every issue
make distclean  # clean every issue's top-level folder and every article subfolder
```

Build a single issue:

```sh
cd vol1/issue1 && make            # -> vol1/issue1/newsletter.pdf
cd vol1/issue1 && make update     # rebuild newsletter.pdf only (assumes articles built)
cd vol1/issue1 && make clean
cd vol1/issue1 && make distclean  # also clean every article subfolder
```

To work on a single article without rebuilding the whole issue:

```sh
cd vol1/issue1/article1 && make      # -> vol1/issue1/article1/wrapper.pdf
cd vol1/issue1/article2 && make      # -> vol1/issue1/article2/wrapper.pdf
```

Requires a TeX Live installation (`lualatex`, `biblatex`, `biber`) and, for
Markdown-authored articles, [`pandoc`](https://pandoc.org/) (tested with
pandoc 3.1). Before the first build on a given machine, run `make
install-fonts` once (see the root `Makefile`) to install the vendored
Poppins font into TeX Live where lualatex can find it by name.

## Starting a new issue

```sh
cp -r template vol1/issue2   # or vol2/issue1, etc.
```

Then, in the new folder's `newsletter.tex`, fill in `\volume{}`, `\volnumber{}`
and `\date{}` (marked `VOLUME`/`ISSUE`/`MONTH YEAR` in the template - these
are independent of the `vol<N>/issue<M>` folder name, which is just this
repository's own bookkeeping), replace the placeholder editorial/articles
with real content (or delete an `articleN/` folder and its `\input` line in
`newsletter.tex` if the issue has fewer articles), and it's ready to build
like any other issue - `cd vol1/issue2 && make`.

The copied folder's paths already point at the shared root files two levels
up (`../../WPnews.sty`, `../../../resources/`, etc.) - this only works
correctly once the folder is at `vol<N>/issue<M>/` (two levels below the
repository root), which is why `template/` itself cannot be built in place;
see TECHNOLOGY.md.

## Writing an article

There are two ways to author an article for an issue. Both end up as an
`art.tex` fragment that gets `\input` into a `wrapper.tex` (for standalone
builds) and into that issue's `newsletter.tex` (for the merged issue), inside
WPnews.sty's `article` environment.

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

Add a `wrapper.tex` and `Makefile` copied from `article1/` in the same issue
(drop the `\addbibresource`/`\printbibliography` lines if the article has no
citations, as in `editorial/`), then add the new folder to that issue's
`Makefile`'s `separateArts`/`distclean` targets, add
`\addbibresource{<folder>/art.bib}` to that issue's `newsletter.tex`'s
preamble if it has one, and `\input` the article from `newsletter.tex`.

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

That article's `Makefile` runs `pandoc` with the shared template and filters
in [`resources/`](resources/) (at the repository root) to turn `art.md` into
an `art.tex` fragment in the same house style as hand-written articles —
including resolved ORCID/ROR badges — and native `\cite{}`/`\printbibliography`
calls that render through the same biblatex setup as LaTeX-authored articles
(see TECHNOLOGY.md). Copy `article2/` (in the same issue) as a starting point
for a new Markdown article (note that a bib entry's citation key must be
unique across every article *within that issue*, since all of an issue's
articles' `.bib` files are loaded together in its `newsletter.tex` - keys can
be reused across different issues, which never share a compilation), and wire
it into that issue's `Makefile`/`newsletter.tex` the same way as above.

See [`TECHNOLOGY.md`](TECHNOLOGY.md) for how both pipelines work under the
hood, and [`CONTRIBUTING.md`](CONTRIBUTING.md) for the tools used to develop
and test this project.
