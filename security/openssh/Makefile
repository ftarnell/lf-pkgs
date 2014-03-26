NAME		= openssh
VERSION		= 6.6p1
DISTURL		= ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${VERSION}.${ARCHIVE}

_SYSCONFDIR	:= ${_PREFIX}/etc/ssh

PATCHES		= openssh-hpn14v2
EXTRA_CONFIGURE_ARGS =				\
	--with-libedit				\
	--with-default-path=${_BINDIR}:${_SBINDIR}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

CONFFILES	=				\
		${_SYSCONFDIR}/moduli		\
		${_SYSCONFDIR}/ssh_config	\
		${_SYSCONFDIR}/sshd_config

.include "../../mk/base.mk"

MODE.${_LIBDIR}/ssh-keysign = 4711
