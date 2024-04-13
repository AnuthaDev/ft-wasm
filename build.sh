CFLAGS=("--target=wasm32-unknown-wasi" "--sysroot=/tmp/wasi-libc" "-O3" "-Ifreetype/include" "-DFT2_BUILD_LIBRARY" "-flto" "-mllvm" "-wasm-enable-sjlj")

mkdir -p objs

clang ${CFLAGS[@]} -c  freetype/src/autofit/autofit.c -o objs/autofit.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftbase.c -o objs/ftbase.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftbbox.c -o objs/ftbbox.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftbdf.c -o objs/ftbdf.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftbitmap.c -o objs/ftbitmap.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftcid.c -o objs/ftcid.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftfstype.c -o objs/ftfstype.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftgasp.c -o objs/ftgasp.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftglyph.c -o objs/ftglyph.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftgxval.c -o objs/ftgxval.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftinit.c -o objs/ftinit.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftmm.c -o objs/ftmm.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftotval.c -o objs/ftotval.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftpatent.c -o objs/ftpatent.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftpfr.c -o objs/ftpfr.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftstroke.c -o objs/ftstroke.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftsynth.c -o objs/ftsynth.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftsystem.c -o objs/ftsystem.o
clang ${CFLAGS[@]} -c  freetype/src/base/fttype1.c -o objs/fttype1.o
clang ${CFLAGS[@]} -c  freetype/src/base/ftwinfnt.c -o objs/ftwinfnt.o
clang ${CFLAGS[@]} -c  freetype/src/bdf/bdf.c -o objs/bdf.o
clang ${CFLAGS[@]} -c  freetype/src/bzip2/ftbzip2.c -o objs/ftbzip2.o
clang ${CFLAGS[@]} -c  freetype/src/cache/ftcache.c -o objs/ftcache.o
clang ${CFLAGS[@]} -c  freetype/src/cff/cff.c -o objs/cff.o
clang ${CFLAGS[@]} -c  freetype/src/cid/type1cid.c -o objs/type1cid.o
clang ${CFLAGS[@]} -c  freetype/src/gzip/ftgzip.c -o objs/ftgzip.o
clang ${CFLAGS[@]} -c  freetype/src/lzw/ftlzw.c -o objs/ftlzw.o
clang ${CFLAGS[@]} -c  freetype/src/pcf/pcf.c -o objs/pcf.o
clang ${CFLAGS[@]} -c  freetype/src/pfr/pfr.c -o objs/pfr.o
clang ${CFLAGS[@]} -c  freetype/src/psaux/psaux.c -o objs/psaux.o
clang ${CFLAGS[@]} -c  freetype/src/pshinter/pshinter.c -o objs/pshinter.o
clang ${CFLAGS[@]} -c  freetype/src/psnames/psnames.c -o objs/psnames.o
clang ${CFLAGS[@]} -c  freetype/src/raster/raster.c -o objs/raster.o
clang ${CFLAGS[@]} -c  freetype/src/sdf/sdf.c -o objs/sdf.o
clang ${CFLAGS[@]} -c  freetype/src/sfnt/sfnt.c -o objs/sfnt.o
clang ${CFLAGS[@]} -c  freetype/src/smooth/smooth.c -o objs/smooth.o
clang ${CFLAGS[@]} -c  freetype/src/svg/svg.c -o objs/svg.o
clang ${CFLAGS[@]} -c  freetype/src/truetype/truetype.c -o objs/truetype.o
clang ${CFLAGS[@]} -c  freetype/src/type1/type1.c -o objs/type1.o
clang ${CFLAGS[@]} -c  freetype/src/type42/type42.c -o objs/type42.o
clang ${CFLAGS[@]} -c  freetype/src/winfonts/winfnt.c -o objs/winfnt.o

cd objs

llvm-ar -crs libfreetype.a autofit.o  ftbbox.o    ftcache.o   ftglyph.o  ftlzw.o     ftpfr.o     ftwinfnt.o  pshinter.o  sfnt.o      type1cid.o bdf.o      ftbdf.o     ftcid.o     ftgxval.o  ftmm.o      ftstroke.o ftsystem.o pcf.o       psnames.o   smooth.o    type1.o cff.o      ftbitmap.o  ftfstype.o  ftgzip.o   ftotval.o   ftsynth.o   pfr.o       raster.o    svg.o       type42.o ftbase.o   ftbzip2.o   ftgasp.o    ftinit.o   ftpatent.o  fttype1.o   psaux.o     sdf.o       truetype.o  winfnt.o

cd ..

clang --target=wasm32-wasi -flto -Wl,--lto-O3 -Wl,--allow-undefined -O2 --sysroot=/tmp/wasi-libc/ -nostartfiles -I freetype/include/ -Wl,--no-entry -Wl,--export=malloc -Wl,--export=free -mllvm -wasm-enable-sjlj -Wl,--initial-memory=655360 -o inspect.wasm inspect.c objs/libfreetype.a

