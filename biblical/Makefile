all: 
	if [ ! -e build-scripts/bible.com/xml ]; then \
		cd build-scripts/bible.com; \
		make xml;\
	fi;
	if [ ! -e build-scripts/bibles.org/xml ]; then \
		cd build-scripts/bibles.org;\
		bash -e ./build.sh; \
	fi;
	if [ ! -e build-scripts/christos-c/data ]; then \
		cd build-scripts/christos-c; \
		bash -e ./sync.sh;\
	fi;
	


