.POSIX:
EMACS = emacs

compile: document-sections.elc # document-sections-test.elc

*-test.elc: *-files.elc

# test: document-sections-test.elc
# 	$(EMACS) -Q --batch -L . -l document-sections-test.elc -f ert-run-tests-batch

clean:
	rm -f *.elc

.SUFFIXES: .el .elc
.el.elc:
	$(EMACS) -Q --batch -L . -f batch-byte-compile $<
