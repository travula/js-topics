DEST=build/proj

all:  publish

publish: init
	emacs --script elisp/src.el


conf: init
	emacs --script elisp/confidential.el

init:
	mkdir -p ${DEST}

export-choppell:
	rsync -avz ${DEST} pascal.iiit.ac.in:/home/choppell/public_html

export-test:
	rsync -rlto --no-p --no-g --chmod=ugo=rwX --exclude '*.flv' ${DEST}/ pascal.iiit.ac.in:/home/choppell/public_html/test

export:
	rsync -avz --progress -e ssh -h ${DEST}/* popl@pascal.iiit.ac.in:/home/popl/public_html/

clean:
	rm -rf ${DEST}

touch:
	find . -path '*/.svn' -prune -o -type f -exec touch "{}" \;
