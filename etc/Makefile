FILES=		opentools.conf
PREFIX?=	${LOCALBASE}
FILESDIR=	${PREFIX}/etc

LOCALBASE?=	/usr/local

clean:
	rm -f opentools.conf

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

opentools.conf: opentools.conf.in
	sed -E  -e 's,%%OPENTOOLSDIR%%,${PREFIX}/opentools,' \
		-e 's,%%OPENTOOLSBINDIR%%,${PREFIX}/bin,' ${.ALLSRC} > ${.TARGET}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
