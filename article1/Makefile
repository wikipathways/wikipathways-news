all: wrapper.pdf

# biblatex (backend=biber, see WPnews.sty): one biber run resolves every
# \begin{article}'s refsection in this document, regardless of how many.
wrapper.pdf: *.tex art.bib
	pdflatex -interaction=nonstopmode wrapper
	biber wrapper
	pdflatex -interaction=nonstopmode wrapper
	pdflatex -interaction=nonstopmode wrapper

update: wrapper.pdf

clean:
	rm -f *.bbl *.aux wrapper.pdf *.blg *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc *.bak *.bcf *.run.xml
