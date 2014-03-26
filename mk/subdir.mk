clean:
	@for d in ${SUBDIRS}; do			\
		echo "$@ ==> ${_DIR}$$d";		\
		${MAKE} _DIR=${_DIR}$$d/ -C $$d $@;	\
		echo "$@ <== ${_DIR}$$d";		\
	done
