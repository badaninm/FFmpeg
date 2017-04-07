#!/bin/bash
######################################################
# Usage:
# put this script in top of FFmpeg source tree
# ./build_android
#
# It generates binary for following architectures:
# ARMv6 
# ARMv6+VFP 
# ARMv7+VFPv3-d16 (Tegra2)
# ARMv7+Neon (Cortex-A8)
#
# Customizing:
# 1. Feel free to change ./configure parameters for more features
# 2. To adapt other ARM variants
# set $CPU and $OPTIMIZE_CFLAGS 
# call build_now
######################################################
# change these three lines to adjust those to your local folders configuration

#NDK=/YOUR_ANDROID_NDK_PATH
PLATFORM=$NDK/platforms/android-9/arch-arm
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64

: ${NDK?"Need to set NDK to android-ndk path"}

function build_now
{
./configure \
    --disable-shared \
    --enable-static \
    --enable-gpl \
    --enable-version3 \
    --enable-nonfree \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-postproc \
    --enable-small \
    --cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
    --enable-cross-compile \
    --target-os=linux \
    --extra-cflags="-I$PLATFORM/usr/include -Wno-traditional" \
    --extra-ldflags="-L$PLATFORM/usr/lib -nostdlib -Wl,-rpath-link=$PLATFORM/usr/lib" \
    --prefix="$PREFIX" \
    --arch=arm \
    --disable-symver \
    --disable-debug \
    --disable-stripping \
    $ADDITIONAL_CONFIGURE_FLAG

sed -i '.bak' 's/HAVE_CBRT 0/HAVE_CBRT 1/g' config.h
sed -i '.bak' 's/HAVE_ISINF 0/HAVE_ISINF 1/g' config.h
sed -i '.bak' 's/HAVE_ISNAN 0/HAVE_ISNAN 1/g' config.h
sed -i '.bak' 's/HAVE_RINT 0/HAVE_RINT 1/g' config.h
sed -i '.bak' 's/HAVE_LRINT 0/HAVE_LRINT 1/g' config.h
sed -i '.bak' 's/HAVE_LRINTF 0/HAVE_LRINTF 1/g' config.h
sed -i '.bak' 's/HAVE_ROUND 0/HAVE_ROUND 1/g' config.h
sed -i '.bak' 's/HAVE_ROUNDF 0/HAVE_ROUNDF 1/g' config.h
sed -i '.bak' 's/HAVE_TRUNC 0/HAVE_TRUNC 1/g' config.h
sed -i '.bak' 's/HAVE_TRUNCF 0/HAVE_TRUNCF 1/g' config.h
sed -i '.bak' 's/HAVE_HYPOT 0/HAVE_HYPOT 1/g' config.h
sed -i '.bak' 's/HAVE_COPYSIGN 0/HAVE_COPYSIGN 1/g' config.h
sed -i '.bak' 's/HAVE_ERF 0/HAVE_ERF 1/g' config.h
sed -i '.bak' 's/#define getenv(x) NULL/;/g' config.h
sed -i '.bak' 's/HAVE_GMTIME_R 0/HAVE_GMTIME_R 1/g' config.h
sed -i '.bak' 's/HAVE_LOCALTIME_R 0/HAVE_LOCALTIME_R 1/g' config.h



make clean
make -j4 install

$PREBUILT/bin/arm-linux-androideabi-ar d libavcodec/libavcodec.a inverse.o
$PREBUILT/bin/arm-linux-androideabi-ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -soname libffmpeg.so -shared -nostdlib  -z,noexecstack -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so libavcodec/libavcodec.a libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a -lc -lm -lz -ldl -llog  --warn-once  --dynamic-linker=/system/bin/linker $PREBUILT/lib/gcc/arm-linux-androideabi/4.4.3/libgcc.a
}

#arm v6
#CPU=armv6
#OPTIMIZE_CFLAGS="-marm -march=$CPU"
#PREFIX=./android/$CPU 
#ADDITIONAL_CONFIGURE_FLAG=
#build_now

###################################
#arm v7vfpv3
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
PREFIX=./android/$CPU
ADDITIONAL_CONFIGURE_FLAG=
build_now

###################################
#arm v7vfp
#CPU=armv7-a
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
#PREFIX=./android/$CPU-vfp
#ADDITIONAL_CONFIGURE_FLAG=
#build_now

###################################
#arm v7n
#CPU=armv7-a
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
#PREFIX=./android/$CPU 
#ADDITIONAL_CONFIGURE_FLAG=--enable-neon
#build_now

###################################
#arm v6+vfp
#CPU=armv6
#OPTIMIZE_CFLAGS="-DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"
#PREFIX=./android/${CPU}_vfp 
#ADDITIONAL_CONFIGURE_FLAG=
#build_now
