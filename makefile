#SHELL := /bin/bash
BUILD_DIR=build

VER_BRANCH=build-release
VER_FILE=VERSION

ORG_MODE_DIR=~/emacs/lisp
LITERATE_TOOLS="https://github.com/vlead/literate-tools.git"
LITERATE_DIR=literate-tools
ELISP_DIR=elisp
ORG_DIR=org-templates
STYLE_DIR=style
CODE_DIR=build/code
DOC_DIR=build/docs
SRC_DIR=src
PWD=$(shell pwd)
STATUS=0

all:  check-elisp build

clean-literate:
	rm -rf ${ELISP_DIR}
	rm -rf src/${ORG_DIR}
	rm -rf src/${STYLE_DIR}

pull-literate-tools:
	@echo "pulling literate support code"
	echo ${PWD}n
ifeq ($(wildcard elisp),)
	@echo "proxy is..."
	echo $$http_proxy
	git clone ${LITERATE_TOOLS}
	mv ${LITERATE_DIR}/${ELISP_DIR} .
	mv ${LITERATE_DIR}/${ORG_DIR} ${SRC_DIR}
	mv ${LITERATE_DIR}/${STYLE_DIR} ${SRC_DIR}
	rm -rf ${LITERATE_DIR}
else
	@echo "Literate support code already present"
endif

check-elisp:
ifneq ($(wildcard ${ORG_MODE_DIR}/org-8.2.10/*),)
	@echo "Found elip build."
else
	mkdir -p ${ORG_MODE_DIR}
	wget http://orgmode.org/org-9.0.2.tar.gz
	tar zxvf org-9.0.2.tar.gz
	rm -rf org-9.0.2.tar.gz
	mv org-9.0.2 ${ORG_MODE_DIR}
	ln -s ${ORG_MODE_DIR}/org-9.0.2/ ${ORG_MODE_DIR}/org-8.2.10
endif

init: pull-literate-tools
	rm -rf ${BUILD_DIR}
	mkdir -p ${BUILD_DIR} ${CODE_DIR}

build: init write-version
	emacs  --script elisp/publish.el

ign:
	rsync -a ${SRC_DIR}/${ORG_DIR} ${BUILD_DIR}/docs
	rsync -a ${SRC_DIR}/${STYLE_DIR} ${BUILD_DIR}/docs
	rm -f ${BUILD_DIR}/docs/*.html~

# get the latest commit hash and its subject line
# and write that to the VERSION file
write-version:
	echo -n "Built from commit: " > ${CODE_DIR}/${VER_FILE}
	echo `git rev-parse HEAD` >> ${CODE_DIR}/${VER_FILE}
	echo `git log --pretty=format:'%s' -n 1` >> ${CODE_DIR}/${VER_FILE}

clean:	clean-literate
	rm -rf ${BUILD_DIR}

