FILES=		common.inc	\
		common.inc.rb	\
		html.inc.rb	\
		latex.inc.rb	\
		mail.inc	\
		misc.inc	\
		ports.inc	\
		sdoc.inc.rb	\
		sys.inc
DESTPREFIX?=	${LOCALBASE}/opentools
FILESDIR=	${DESTPREFIX}/include

LOCALBASE?=	/usr/local

clean:

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
