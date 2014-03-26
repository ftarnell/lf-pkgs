NAME		= mutt
VERSION		= 1.5.23
DISTURL		= ftp://ftp.fu-berlin.de/pub/unix/mail/mutt/${DISTFILE}

EXTRA_CONFIGURE_ARGS = 			\
	--enable-pop			\
	--enable-imap			\
	--enable-smtp			\
	--enable-hcache			\
	--with-ssl

CONFFILES	= ${_SYSCONFDIR}/Muttrc		\
		  ${_SYSCONFDIR}/mime.types
PATCHES		= patch-dotlock

.include "../../mk/base.mk"

MODE.${_BINDIR}/mutt_dotlock = 2755
