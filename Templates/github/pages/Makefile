FILES=		LeapDay.html
PREFIX?=	${LOCALBASE}/opentools
FILESDIR=	${PREFIX}/Templates/github/pages

LOCALBASE?=	/usr/local

clean:

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
