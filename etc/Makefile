FILES=		opentools.conf
DESTDIR?=	${LOCALBASE}
FILESDIR=	/etc

opentools.conf: opentools.conf.in
	sed -E  -e 's,%%OPENTOOLSDIR%%,${LOCALBASE}/opentools,' \
		-e 's,%%OPENTOOLSBINDIR%%,${LOCALBASE}/bin,' ${.ALLSRC} > ${.TARGET}

install: installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
