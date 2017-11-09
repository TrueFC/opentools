FILES=		LeapDay.html
DESTDIR?=	${LOCALBASE}/opentools
FILESDIR=	/Templates/github/pages

LOCALBASE?=	/usr/local

clean:

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
