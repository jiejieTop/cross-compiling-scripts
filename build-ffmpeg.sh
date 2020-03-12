#!/bin/sh

# set -v 

PLATFORM=arm-linux-gnueabihf
SCRIPT_PATH=$(pwd)

# 依赖libffi
LIBFFI_PKG_CONFIG_PATH="/opt/libffi-3.3/lib/pkgconfig"
# 依赖libxml2
XML2_PKG_CONFIG_PATH="/opt/libxml2-2.9.4/lib/pkgconfig"
# 依赖glib
GLIB_PKG_CONFIG_PATH="/opt/glib-2.45.3/lib/pkgconfig"
# 依赖zlib
ZLIB_PKG_CONFIG_PATH="/opt/zlib-1.2.11/lib/pkgconfig"


#修改源码包解压后的名称
MAJOR_NAME=ffmpeg

#修改需要下载的源码前缀和后缀
OPENSRC_VER_PREFIX=4.2
OPENSRC_VER_SUFFIX=.1

PACKAGE_NAME=${MAJOR_NAME}-${OPENSRC_VER_PREFIX}${OPENSRC_VER_SUFFIX}

#定义压缩包名称
COMPRESS_PACKAGE=${PACKAGE_NAME}.tar.xz

#定义编译后安装--生成的文件,文件夹位置路径
INSTALL_PATH=/opt/${PACKAGE_NAME}

#添加交叉编译工具链路径
CROSS_CHAIN_PREFIX=/opt/arm-gcc/bin/arm-linux-gnueabihf

#无需修改--下载地址
DOWNLOAD_LINK=http://ffmpeg.org/releases/${COMPRESS_PACKAGE}

#下载源码包
do_download_src () {
   echo "\033[1;33mstart download ${PACKAGE_NAME}...\033[0m"
   if [ ! -d "${PACKAGE_NAME}" ];then
      wget -c ${DOWNLOAD_LINK}
   fi
   echo "\033[1;33mdone...\033[0m"
}

#解压源码包
do_tar_package () {
   #if exist file then
   echo "\033[1;33mstart unpacking the ${PACKAGE_NAME} package ...\033[0m"
   if [ ! -d "${PACKAGE_NAME}" ];then
      tar -xf ${COMPRESS_PACKAGE}
   fi
   echo "\033[1;33mdone...\033[0m"
   cd ${PACKAGE_NAME}
}

#配置选项
do_configure () {
   echo "\033[1;33mstart configure qt...\033[0m"

   ./configure \
   --cc=${CROSS_CHAIN_PREFIX}-gcc \
   --prefix=${INSTALL_PATH} \
   --enable-cross-compile \
   --target-os=linux \
   --arch=arm \
   --enable-shared \
   --disable-static \
   --enable-gpl \
   --enable-nonfree \
   --enable-ffmpeg \
   --disable-ffplay \
   --enable-swscale \
   --enable-pthreads \
   --disable-armv5te \
   --disable-armv6 \
   --disable-armv6t2 \
   --disable-yasm \
   --disable-stripping \
   --extra-cflags=-I/usr/local/include \
   --extra-ldflags=-L/usr/local/lib \
   --extra-libs=-ldl

   echo "\033[1;33mdone...\033[0m"
}


#编译并且安装
do_make_install () {
   echo "\033[1;33mstart make and install...\033[0m"
   make && make install
   echo "\033[1;33mdone...\033[0m"
}

#删除下载的文件
do_delete_file () {
   cd ${SCRIPT_PATH}
   if [ -f "${PACKAGE_NAME}" ];then
      sudo rm -f ${PACKAGE_NAME}
   fi
}

do_download_src
do_tar_package
do_configure
do_make_install
# do_delete_file

exit $?

