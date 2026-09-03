all: wrapper.pdf

wrapper.pdf: *.tex wrapper.bbl
	pdflatex wrapper || true
	pdflatex wrapper

update: wrapper.pdf

wrapper.bbl: art.bib
	pdflatex wrapper
	bibtex wrapper || true

clean:
	rm -f *.bbl *.aux wrapper.pdf *.blg *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc *.bak
