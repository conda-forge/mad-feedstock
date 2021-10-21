#!/bin/bash

export CFLAGS="-I$PREFIX/include $CFLAGS"

if [[ $(uname) == Darwin ]]; then
    export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -headerpad_max_install_names $LDFLAGS"
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    export MACOSX_DEPLOYMENT_TARGET="10.9"
elif [ $(uname) == Linux ] ; then
    export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
fi

# remove libtool files
find $PREFIX -name '*.la' -delete

touch AUTHORS ChangeLog NEWS
mkdir ./config
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config
libtoolize
aclocal
autoheader
automake --add-missing
autoreconf -fiv
./configure --disable-debugging \
	    --enable-fpm=64bit \
	    --prefix=$PREFIX
sed -i~ -e '/-fforce-mem/d;/-fthread-jumps/d;/-fcse-follow-jumps/d;/-fcse-skip-blocks/d;/-fregmove/d' configure

make -j$CPU_COUNT
make install -j$CPU_COUNT

# remove libtool files
find $PREFIX -name '*.la' -delete
