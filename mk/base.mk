REVISION	?= 1
DESC		?= No description
SRCDIR		?= ${NAME}-${VERSION}
PKGNAME		?= LF${NAME}
ARCHIVE		?= tar.gz
DISTFILE	?= ${NAME}-${VERSION}.${ARCHIVE}
DISTURL		?= ${SOURCE}/${DISTFILE}
PKGURL		?= http://www.le-fay.org.uk/

MAINTAINER	?= Felicity Tarnell <felicity@le-fay.org.uk>
_PKGDIR		?= ../../packages
_POSTVERSION	?= -lf${REVISION}
_PKGVERSION	?= ${VERSION}${_POSTVERSION}

_BASEDIR	?= /usr/lf
_SUBDIR		?=
_PREFIX		?= ${_BASEDIR}${_SUBDIR}

_BINDIR		?= ${_PREFIX}/bin
_SBINDIR	?= ${_PREFIX}/sbin
_DATADIR	?= ${_PREFIX}/share
_SYSCONFDIR	?= ${_PREFIX}/etc
_LIBDIR		?= ${_PREFIX}/lib
_LIBEXECDIR	?= ${_PREFIX}/lib
_MANDIR		?= ${_PREFIX}/man
_INCLUDEDIR	?= ${_PREFIX}/include

PKGABI		!= pkg -vv|awk '$$1 == "ABI" { print $$3 }'

_MAKE		?= ${MAKE}
_CC		?= cc
_CFLAGS		?= -O2
_LDFLAGS	?= -L${_LIBDIR} -Wl,-R${_LIBDIR}
_CPPFLAGS	?= -I${_INCLUDEDIR}

_CONFIGURE_ARGS	?= --prefix=${_PREFIX} --bindir=${_BINDIR} --sbindir=${_SBINDIR} 	\
		   --datadir=${_DATADIR} --sysconfdir=${_SYSCONFDIR}			\
		   --libdir=${_LIBDIR} --libexecdir=${_LIBEXECDIR} --mandir=${_MANDIR}	\
		   --includedir=${_INCLUDEDIR} ${EXTRA_CONFIGURE_ARGS}

_ENV		?= CC="${_CC}" CFLAGS="${_CFLAGS}" CPPFLAGS="${_CPPFLAGS}" LDFLAGS="${_LDFLAGS}"
_CONFIGURE	?= env ${_ENV} ${EXTRA_ENV} ./configure ${_CONFIGURE_ARGS}
_WORKDIR	?= work
_DISTDIR	?= ../../distfiles
_STAGEDIR	?= ${_WORKDIR}/stage

VPATH		?= ${_WORKDIR}

default: package

${_WORKDIR}/fetch-stamp: 
	@${MAKE} do-fetch
	@mkdir -p ${_WORKDIR}
	@touch ${_WORKDIR}/fetch-stamp
.if !target(do-fetch)
do-fetch:
	@if [ -f "${_DISTDIR}/${DISTFILE}" ]; then			\
		echo ">>> Distfile ${DISTFILE} already present";	\
	else								\
		echo ">>> Fetching ${DISTURL}";			\
		fetch -o ${_DISTDIR}/${DISTFILE} ${DISTURL};		\
	fi
.endif
fetch: ${_WORKDIR}/fetch-stamp

${_WORKDIR}/extract-stamp: ${_WORKDIR}/fetch-stamp
	@${MAKE} do-extract
	@touch ${_WORKDIR}/extract-stamp
.if !target(do-extract)
do-extract:
	@mkdir -p ${_WORKDIR}
	@echo ">>> Extracting ${DISTFILE}"
	@rm -rf ${_WORKDIR}/${SRCDIR}
	@tar xf ${_DISTDIR}/${DISTFILE} -C ${_WORKDIR}
.endif
extract: ${_WORKDIR}/extract-stamp

${_WORKDIR}/patch-stamp: ${_WORKDIR}/extract-stamp
	@${MAKE} do-patch
	@touch ${_WORKDIR}/patch-stamp
.if !target(do-patch)
do-patch:
	@mkdir -p ${_WORKDIR}
	@for p in ${PATCHES}; do					\
		echo ">>> Applying $$p";				\
		patch -p0 -d ${_WORKDIR}/${SRCDIR} < ${PWD}/files/$$p;	\
	done
.endif
patch: ${_WORKDIR}/patch-stamp

${_WORKDIR}/configure-stamp: ${_WORKDIR}/patch-stamp
	@echo ">>> Configuring ${NAME}-${VERSION}"
	@${MAKE} do-configure
	@touch ${_WORKDIR}/configure-stamp
.if !target(do-configure)
do-configure:
	cd ${_WORKDIR}/${SRCDIR} && ${_CONFIGURE}
.endif
configure: ${_WORKDIR}/configure-stamp

${_WORKDIR}/build-stamp: ${_WORKDIR}/configure-stamp
	@echo ">>> Building ${NAME}-${VERSION}"
	@${MAKE} do-build
	@touch ${_WORKDIR}/build-stamp
.if !target(do-build)
do-build:
	${_MAKE} -C ${_WORKDIR}/${SRCDIR}
.endif
build: ${_WORKDIR}/build-stamp

clean:
	@echo ">>> Cleaning ${NAME}-${VERSION}"
	@rm -rf ${_WORKDIR}

${_WORKDIR}/stage-stamp: ${_WORKDIR}/build-stamp
	@${MAKE} do-stage
	@${MAKE} post-stage
	@for f in ${CONFFILES}; do				\
		mv ${_STAGEDIR}$$f ${_STAGEDIR}$$f.dist;	\
	done
	@touch ${_WORKDIR}/stage-stamp
.if !target(do-stage)
do-stage:
	${_MAKE} -C ${_WORKDIR}/${SRCDIR} install DESTDIR=${PWD}/${_STAGEDIR}
.endif
.if !target(post-stage)
post-stage:
.endif
stage: ${_WORKDIR}/stage-stamp

${_WORKDIR}/package-stamp: ${_WORKDIR}/stage-stamp
	@${MAKE} do-package
	@touch ${_WORKDIR}/package-stamp
.if !target(do-package)
do-package:
	@rm -f ${_STAGEDIR}/+MANIFEST
	@echo ">>> Building manifest"
	@echo >>${_STAGEDIR}/+MANIFEST "name: LF${NAME}"
	@echo >>${_STAGEDIR}/+MANIFEST "version: ${_PKGVERSION}"
	@echo >>${_STAGEDIR}/+MANIFEST "origin: lf-pkgs/${NAME}"
	@echo >>${_STAGEDIR}/+MANIFEST "comment: ${DESC}"
	@echo >>${_STAGEDIR}/+MANIFEST "www: ${PKGURL}"
	@echo >>${_STAGEDIR}/+MANIFEST "desc: ${DESC}"
	@echo >>${_STAGEDIR}/+MANIFEST "arch: ${PKGABI}"
	@echo >>${_STAGEDIR}/+MANIFEST "maintainer: ${MAINTAINER}"
	@echo >>${_STAGEDIR}/+MANIFEST "prefix: ${_BASEDIR}"
	@echo >>${_STAGEDIR}/+MANIFEST "dirs:"
	@find ${_STAGEDIR} -type d | while read dir; do				\
		mode=`stat -f%p "$$dir" | cut -c 3-`;				\
		dir="$${dir#${_STAGEDIR}}";					\
		[ "$$dir" = "" ] && continue;					\
		echo >>${_STAGEDIR}/+MANIFEST "  $$dir: { uname: root, gname: wheel, perm: $$mode }";	\
	done
	@echo >>${_STAGEDIR}/+MANIFEST "files:"
	@find ${_STAGEDIR} -type f -o -type l | while read file; do		\
		[ "$$file" = "${_STAGEDIR}/+MANIFEST" ] && continue;		\
		mode=`stat -f%p "$$file" | cut -c 3-`;				\
		file="$${file#${_STAGEDIR}}";					\
		perm=$$(${MAKE} -V MODE."`echo $$file | tr : _`");		\
		[ -z "$$perm" ] && perm=$$mode;					\
		uname="root"; gname="wheel";					\
		echo >>${_STAGEDIR}/+MANIFEST 					\
		  "  $$file: { uname: root, gname: wheel, perm: $$perm }";	\
	done
	@echo >>${_STAGEDIR}/+MANIFEST "scripts:"
	@if [ -f "pre-install" ]; then						\
		echo >>${_STAGEDIR}/+MANIFEST "  pre-install: |-";		\
		cat pre-install | sed 's/^/    /g' >>${_STAGEDIR}/+MANIFEST;	\
	fi
	@rm -f ${_WORKDIR}/post-install
	@touch ${_WORKDIR}/post-install
	@for c in ${CONFFILES}; do						\
		echo >> ${_WORKDIR}/post-install "if ! test -f \"$$c\"; then cp $$c.dist $$c; fi"; \
	done
	@if [ -f "post-install" ]; then						\
		cat post-install >> ${_WORKDIR}/post-install;			\
	fi
	@echo >>${_STAGEDIR}/+MANIFEST "  post-install: |-";
	@echo >>${_STAGEDIR}/+MANIFEST "    #! /bin/sh";
	@cat ${_WORKDIR}/post-install | sed 's/^/    /g' >>${_STAGEDIR}/+MANIFEST;
	@if [ -f "pre-deinstall" ]; then					\
		echo >>${_STAGEDIR}/+MANIFEST "  pre-deinstall: |-";		\
		cat pre-deinstall | sed 's/^/    /g' >>${_STAGEDIR}/+MANIFEST;	\
	fi
	@if [ -f "post-deinstall" ]; then					\
		echo >>${_STAGEDIR}/+MANIFEST "  post-deinstall: |-";		\
		cat post-deinstall | sed 's/^/    /g' >>${_STAGEDIR}/+MANIFEST;	\
	fi
	@echo ">>> Building package"
	@pkg create -r ${_STAGEDIR} -m ${_STAGEDIR} -o ${_PKGDIR}
.endif
package: ${_WORKDIR}/package-stamp

${_WORKDIR}/install-stamp: ${_WORKDIR}/package-stamp
	@echo ">>> Installing ${NAME}-${_PKGVERSION}"
	@${MAKE} do-install
	@touch ${_WORKDIR}/install-stamp
.if !target(do-install)
do-install:
	pkg add ${_PKGDIR}/LF${NAME}-${_PKGVERSION}.txz
.endif
install: ${_WORKDIR}/install-stamp

uninstall:
	pkg remove -y LF${NAME}

reinstall:
	${MAKE} uninstall
	${MAKE} install
.PHONY: fetch do-fetch extract do-extract configure do-configure build do-build stage do-stage package do-package
