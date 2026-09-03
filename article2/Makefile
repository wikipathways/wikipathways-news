all: wrapper.pdf

art.tex: art.md pandoc.template
	pandoc --from markdown+raw_tex -s --template=pandoc.template --output=art.tex art.md

wrapper.pdf: art.tex wrapper.tex
	pdflatex wrapper
	pdflatex wrapper

update: wrapper.pdf

clean:
	rm -f art.tex *.aux wrapper.pdf *.log *.fff *.lof *.lot *.ttt *.dvi *~ *.out *.toc *.bak
