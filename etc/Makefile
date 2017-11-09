FILES=		opentools.conf
DESTDIR?=	${LOCALBASE}
FILESDIR=	/etc

LOCALBASE?=	/usr/local

clean:
	rm -f opentools.conf

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

opentools.conf: opentools.conf.in
	sed -E  -e 's,%%OPENTOOLSDIR%%,${DESTDIR}/opentools,' \
		-e 's,%%OPENTOOLSBINDIR%%,${DESTDIR}/bin,' ${.ALLSRC} > ${.TARGET}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
