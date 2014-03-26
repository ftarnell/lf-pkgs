NAME		= git
VERSION		= 1.9.0
DISTURL		= http://git-core.googlecode.com/files/${DISTFILE}

_MAKE			= gmake

BDEPENDS		= gmake:devel/gmake
DEPENDS			= perl518:perl518/perl518
EXTRA_CONFIGURE_ARGS	= --with-perl=${_BASEDIR}/perl/5.18/bin/perl --enable-pthreads=-pthread ac_cv_header_libcharset_h=no
EXTRA_ENV		= "LIBS=-lpthread"

post-stage:
	rm  ${_STAGEDIR}${_LIBDIR}/5.18/perllocal.pod
	rmdir ${_STAGEDIR}${_LIBDIR}/5.18

.include "../../mk/base.mk"
