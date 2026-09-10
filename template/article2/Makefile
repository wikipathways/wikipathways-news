# pandoc.template and the CiTO-aware citation lua filters live in
# ../../../resources/ (this project's root, shared across every issue).
# extract-cito.lua is copied from the sibling repo ../bhxiv-gen-pdf/, next
# to this project's own root (resources/biohackrxiv/filters/; see
# bin/gen-pdf there for the pandoc invocation this is modeled on): it
# strips the "cito-property:" prefix (e.g. usesMethodIn:) from citation keys before
# pandoc emits \cite{key} for biblatex to resolve against art.bib.
# cito-to-biblatex.lua (not from bhxiv-gen-pdf, which annotates citeproc's
# pre-rendered output instead) turns the CiTO property extract-cito.lua
# recorded into a \wpcitoannotate{key}{property} call, which WPnews.sty's
# biblatex \finentrypunct hook looks up when printing that entry.
# mark-has-citations.lua (not from bhxiv-gen-pdf) sets the haswpcitations
# metadata flag pandoc.template checks before emitting \printbibliography,
# so an article with no citations gets no References section (see article3/).
RESOURCES     = ../../../resources
TEMPLATE      = $(RESOURCES)/pandoc.template
EXTRACT_CITO  = $(RESOURCES)/filters/extract-cito.lua
CITO_TO_BIBLATEX = $(RESOURCES)/filters/cito-to-biblatex.lua
MARK_HAS_CITATIONS = $(RESOURCES)/filters/mark-has-citations.lua

all: wrapper.pdf

art.tex: art.md $(TEMPLATE) art.bib
	pandoc --from markdown+raw_tex -s --template='$(TEMPLATE)' \
	  --biblatex \
	  --lua-filter='$(MARK_HAS_CITATIONS)' \
	  --lua-filter='$(EXTRACT_CITO)' \
	  --lua-filter='$(CITO_TO_BIBLATEX)' \
	  --output=art.tex art.md

# biblatex (backend=biber, see WPnews.sty): one biber run resolves every
# \begin{article}'s refsection in this document, regardless of how many.
wrapper.pdf: art.tex wrapper.tex art.bib
	lualatex -interaction=nonstopmode wrapper
	biber wrapper
	lualatex -interaction=nonstopmode wrapper
	lualatex -interaction=nonstopmode wrapper

update: wrapper.pdf

clean:
	rm -f art.tex *.bbl *.aux wrapper.pdf *.blg *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc *.bak *.bcf *.run.xml
