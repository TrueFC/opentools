FILES=		osc	\
		portsc	\
		subc	\
		subc.rb	\
		sysrc	\
		xc	\
		xepkgsc
PREFIX?=	${LOCALBASE}/opentools
FILESDIR=	${PREFIX}/lib

LOCALBASE?=	/usr/local

clean:

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

install: beforeinstall installfiles

.include <bsd.init.mk>
.include <bsd.files.mk>
