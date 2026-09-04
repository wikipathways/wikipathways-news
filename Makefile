all: news

separateArts:
	cd editorial; make
	cd article1; make
	cd article2; make
	cd article3; make

news: separateArts newsletter.pdf

# biblatex (backend=biber, see WPnews.sty): one biber run resolves every
# \begin{article}'s refsection in this document, regardless of how many.
newsletter.pdf: newsletter.tex
	pdflatex -interaction=nonstopmode newsletter
	biber newsletter
	pdflatex -interaction=nonstopmode newsletter
	pdflatex -interaction=nonstopmode newsletter

update: newsletter.pdf

distclean: clean
	cd editorial; make clean
	cd article1; make clean
	cd article2; make clean
	cd article3; make clean

clean:
	rm -f *.bbl *.aux *.pdf *.blg *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc *.bak *.bcf *.run.xml
