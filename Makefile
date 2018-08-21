target := $(basename $(shell ls -b *paper.tex | head -1 \
	| sed -e "/_paper.tex/s///"))

paper_target = $(target)_paper

documentation = README.md

paper_source = $(paper_target).tex
latex_cmd = pdflatex
editor = vi

dvi_options = --output-format dvi

paper_counter_file = paper_build_counter.txt

paper_pdf_file = $(paper_target).pdf
paper_dvi_file = $(paper_target).dvi

paper_sources = $(paper_source) $(bibtex_file)

temporary_files = *.log *.aux *.out *.idx *.ilg *.bbl *.blg .pdf *.nav *.snm *.toc

all:: $(paper_pdf_file)

Makefile: common.mk

touch:
	touch $(paper_source)

common.mk:
	ln -s ../Makefiles/common.mk

graphics_for_paper = deep_pipeline.png \
	photodiode_pullup_and_GPIO_protection.png

$(paper_pdf_file): $(paper_sources) $(graphics_for_paper) Makefile
	@echo $$(($$(cat $(paper_counter_file)) + 1)) > $(paper_counter_file)
	make $(bibtex_file)
	$(latex_cmd) $(paper_source)
	bibtex $(paper_target)
	if (grep "Warning" $(paper_target).blg > /dev/null ) then false; fi
	@while grep "Rerun to get" $(paper_target).log ; do \
		$(latex_cmd) $(paper_target) ; \
	done
	chmod a-x,a+r $(paper_pdf_file)
	@echo "Build `cat $(paper_counter_file)`"

vi: paper

paper:
	$(editor) $(paper_source)

spell::
	aspell --lang=en_GB check $(paper_source)

wc:
	detex < $(paper_source) | wc -w

clean::
	rm -vf $(temporary_files)

allclean: clean
	rm -vf $(paper_pdf_file) $(paper_dvi_file)

include common.mk

