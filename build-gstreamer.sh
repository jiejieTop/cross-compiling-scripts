#!/bin/sh

# set -v 

PLATFORM=arm-linux-gnueabihf
SCRIPT_PATH=$(pwd)

# 依赖libffi
LIBFFI_INC=/opt/libffi-3.3/include
LIBFFI_LIB=/opt/libffi-3.3/lib
LIBFFI_PKG_CONFIG_PATH=/opt/libffi-3.3/lib/pkgconfig
# 依赖libxml2
XML2_INC=/opt/libxml2-2.9.4/include
XML2_LIB=/opt/libxml2-2.9.4/lib
XML2_PKG_CONFIG_PATH=/opt/libxml2-2.9.4/lib/pkgconfig
# 依赖glib
GLIB_INC1=/opt/glib-2.45.3/include/
GLIB_INC2=/opt/glib-2.45.3/include/glib-2.0/
GLIB_INC3=/opt/glib-2.45.3/include/glib-2.0/glib/
GIO_INC=/opt/glib-2.45.3/include/glib-2.0/gio/
GLIB_LIB=/opt/glib-2.45.3/lib
GLIB_PKG_CONFIG_PATH=/opt/glib-2.45.3/lib/pkgconfig
# 依赖zlib
ZLIB_INC=/opt/zlib-1.2.11/include
ZLIB_LIB=/opt/zlib-1.2.11/lib
ZLIB_PKG_CONFIG_PATH=/opt/zlib-1.2.11/lib/pkgconfig

GSTERAMER_PKG_CONFIG_PATH="${INSTALL_PATH}/lib/pkgconfig"

#修改源码包解压后的名称
MAJOR_NAME=gstreamer

#修改需要下载的源码前缀和后缀
OPENSRC_VER_PREFIX=1.16
OPENSRC_VER_SUFFIX=.2

PACKAGE_NAME=${MAJOR_NAME}-${OPENSRC_VER_PREFIX}${OPENSRC_VER_SUFFIX}

#定义压缩包名称
COMPRESS_PACKAGE=${PACKAGE_NAME}.tar.xz

#定义编译后安装--生成的文件,文件夹位置路径
INSTALL_PATH=/opt/${PACKAGE_NAME}
GSTERAMER_PKG_CONFIG_PATH="${INSTALL_PATH}/lib/pkgconfig"

#添加交叉编译工具链路径 
# CROSS_CHAIN_PREFIX=/opt/arm-gcc/bin/arm-linux-gnueabihf
CROSS_CHAIN_PREFIX=/opt/gcc-arm-linux-gnueabihf-8.3.0/bin/arm-linux-gnueabihf

#无需修改--下载地址
DOWNLOAD_LINK=https://gstreamer.freedesktop.org/src/${MAJOR_NAME}/${COMPRESS_PACKAGE}

#下载源码包
do_download_src () {
   echo "\033[1;33mstart download ${PACKAGE_NAME}...\033[0m"

   if [ ! -f "${COMPRESS_PACKAGE}" ];then
      if [ ! -d "${PACKAGE_NAME}" ];then
         wget -c ${DOWNLOAD_LINK}
      fi
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

#安装依赖项
do_install_config_dependent () {
   sudo apt install bison flex libffi-dev -y
}

#配置选项
do_configure () {
   echo "\033[1;33mstart configure qt...\033[0m"

   export PKG_CONFIG_PATH=${GSTERAMER_PKG_CONFIG_PATH}:${GLIB_PKG_CONFIG_PATH}:${LIBFFI_PKG_CONFIG_PATH}:${XML2_PKG_CONFIG_PATH}:${ZLIB_PKG_CONFIG_PATH}:$PKG_CONFIG_PATH

   export LIBS="-lg -L${GLIB_LIB} -lffi -L${LIBFFI_LIB} -lxml2 -L${XML2_LIB} -lz -L${ZLIB_LIB}" \
   export CFLAGS="-I${GLIB_INC1} -I${GLIB_INC2} -I${GLIB_INC3} -I${GIO_INC} -I${XML2_INC} -I${LIBFFI_LIB} -I${ZLIB_LIB}"

   export CC="${CROSS_CHAIN_PREFIX}-gcc $CFLAGS $LIBS"
   export CXX="${CROSS_CHAIN_PREFIX}-g++ $CFLAGS $LIBS" 

   ./configure \
   --prefix=${INSTALL_PATH} \
   --host=${PLATFORM} \
   --disable-examples
   # --cflags=-I${GLIB_INC} ${LIBFFI_INC} ${ZLIB_INC} ${XML2_INC} \
   # --lib=-L${GLIB_LIB} ${LIBFFI_LIB} ${ZLIB_LIB} ${XML2_LIB} \
   # GLIB_CFLAGS="-I${GLIB_INC}" \
   # GLIB_LIBS="-lg -L${GLIB_LIB}" \
   # LIBFFI_CFLAGS="-I${LIBFFI_INC}" \
   # LIBFFI_LIBS="-lffi -L${LIBFFI_LIB}" \
   # ZLIB_CFLAGS="-I${ZLIB_INC}" \
   # ZLIB_LIBS="-lz -L${ZLIB_LIB}" \
   # XML2_CFLAGS="-I${XML2_INC}" \
   # XML2_LIBS="-lxml2 -L${XML2_LIB}" \
   # ac_cv_func_register_printf_function=no
   # --disable-loadsave \
   # --disable-gtk-doc \
   # --disable-tests \
   # --disable-valgrind \
   # --disable-debug \
   # --disable-x \
   # --disable-xshm \
   # --disable-cairo \
   # --disable-xvideo \
   # --disable-esd \
   # --disable-shout2 \
   # --disable-gconf \
   # --disable-gdk_pixbuf \
   # --disable-hal \
   # --disable-oss \
   # --disable-oss4 \
   # --disable-gnome_vfs \
   # --disable-ogg \
   # --disable-pango \
   # --disable-theora \
   # --disable-vorbis \
   # --disable-examples \
   # --disable-libpng 
   
   echo "\033[1;33mdone...\033[0m"
}

#编译并且安装
do_make_install () {
   echo "\033[1;33mstart make and install ${PACKAGE_NAME} ...\033[0m"
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
do_install_config_dependent
do_configure
do_make_install
# do_delete_file

exit $?
