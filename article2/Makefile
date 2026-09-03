# CSL style and CiTO-aware citation lua filters, copied from
# ../../bhxiv-gen-pdf/resources/biohackrxiv/ (see bin/gen-pdf there for
# the pandoc invocation this is modeled on): extract-cito.lua strips the
# "cito-property:" prefix (e.g. usesMethodIn:) from citation keys before
# citeproc resolves them against art.bib, and insert-cito-in-ref.lua
# annotates the matching bibliography entry with "[cito:property]".
CSL           = apa-new.csl
EXTRACT_CITO  = filters/extract-cito.lua
INSERT_CITO   = filters/insert-cito-in-ref.lua

all: wrapper.pdf

art.tex: art.md pandoc.template art.bib
	pandoc --from markdown+raw_tex -s --template=pandoc.template \
	  --csl='$(CSL)' \
	  --lua-filter='$(EXTRACT_CITO)' \
	  --citeproc \
	  --lua-filter='$(INSERT_CITO)' \
	  --output=art.tex art.md

wrapper.pdf: art.tex wrapper.tex
	pdflatex wrapper
	pdflatex wrapper

update: wrapper.pdf

clean:
	rm -f art.tex *.aux wrapper.pdf *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc *.bak
