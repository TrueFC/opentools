FILES=		opentools.conf
DESTPREFIX?=	${LOCALBASE}
FILESDIR=	${DESTPREFIX}/etc

LOCALBASE?=	/usr/local

clean:
	rm -f opentools.conf

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

opentools.conf: opentools.conf.in
	sed -E  -e 's,%%OPENTOOLSDIR%%,${DESTPREFIX}/opentools,' \
		-e 's,%%OPENTOOLSBINDIR%%,${DESTPREFIX}/bin,' ${.ALLSRC} > ${.TARGET}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
