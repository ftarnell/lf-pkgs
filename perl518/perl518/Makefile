NAME		= perl518
VERSION		= 5.18.2
DISTFILE	= perl-${VERSION}.${ARCHIVE}
SRCDIR		= perl-${VERSION}
DISTURL		= http://www.cpan.org/src/5.0/perl-${VERSION}.tar.gz

_PREFIX	= ${_BASEDIR}/perl/5.18

_CONFIGURE_ARGS	= 	-des							\
			-Dprefix=${_PREFIX}					\
			-Dinstallstyle=lib					\
			-Dprivlib=${_LIBDIR}/5.18				\
			-Dsitelib=${_LIBDIR}/site_perl/5.18			\
			-Dsitearch=${_LIBDIR}/site_perl/5.18			\
			-Dvendorlib=${_LIBDIR}/vendor_perl/5.18			\
			-Darchlib=${_LIBDIR}/5.18				\
			-Dd_vendorarch						\
			-Dd_archlib						\
			-Dusethreads						\
			-Dcf_email="${MAINTAINER}"				\
			-Uusevendorprefix
_CONFIGURE	= ./Configure ${_CONFIGURE_ARGS}

.include "../../mk/base.mk"
