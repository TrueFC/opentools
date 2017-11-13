OPENTOOLSBINS?=	autocol.rb		\
		bwsr.sh			\
		clone-xepkgs.sh		\
		create-portstree.sh	\
		emcs.sh			\
		get-xepkgdata.sh	\
		latex2latex.rb		\
		mailprc.sh		\
		newest.sh		\
		sbackup.sh		\
		sct.sh			\
		sdoc2page.rb		\
		sdoc2sdoc.rb		\
		slgn.sh			\
		w3.sh			\
		wl.sh			\
		xtrm.sh
SCRIPTS=	${OPENTOOLSBINS:R}
PREFIX?=	${LOCALBASE}
SCRIPTSDIR=	${PREFIX}/bin

LOCALBASE?=	/usr/local
RUBY_SCRIPTS=	${OPENTOOLSBINS:M*.rb}
RUBY_ARGS?=	-Ku
SH_SCRIPTS=	${OPENTOOLSBINS:M*.sh}

clean:
	rm -f ${SCRIPTS}

beforeinstall:
	mkdir -p ${DESTDIR}${SCRIPTSDIR}

.for __src in ${RUBY_SCRIPTS}
${__src:R}: ${__src}
	sed -E  -e 's,%%OPENTOOLSDIR%%,${PREFIX}/opentools,g' \
		-e 's,%%RUBY_ARGS%%,${RUBY_ARGS},g' ${.ALLSRC} > ${.TARGET}
.endfor
.for __src in ${SH_SCRIPTS}
${__src:R}: ${__src}
	sed -E  -e 's@^(\.[[:space:]]+).*(/common.inc)$$@\1\$${OPENTOOLSDIR:=${PREFIX}/opentools}/include\2@' \
		${.ALLSRC} > ${.TARGET}
.endfor

.include <bsd.prog.mk>
