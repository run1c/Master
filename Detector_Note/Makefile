CC=pdflatex
TAR=FEelectronics

all: $(TAR).pdf

%.pdf: %.tex
	$(CC) $^

clean:
	rm -rf $(TAR).pdf
	rm -rf $(TAR).aux
	rm -rf $(TAR).log
