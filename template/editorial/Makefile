all: wrapper.pdf

wrapper.pdf: *.tex
	pdflatex wrapper
	pdflatex wrapper

update: wrapper.pdf

clean:
	rm -f *.bbl *.aux wrapper.pdf *.blg *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc
