FILES=		LeapDay.html
DESTPREFIX?=	${LOCALBASE}/opentools
FILESDIR=	${DESTPREFIX}/Templates/github/pages

LOCALBASE?=	/usr/local

clean:

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
