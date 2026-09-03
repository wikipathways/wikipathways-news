all: news

separateArts:
	cd editorial; make
	cd article1; make

news: separateArts newsletter.pdf

newsletter.pdf: newsletter.tex
	pdflatex newsletter
	pdflatex newsletter

update: newsletter.pdf

distclean: clean
	cd editorial; make clean
	cd article1; make clean

clean:
	rm -f *.bbl *.aux *.pdf *.blg *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc *.bak
