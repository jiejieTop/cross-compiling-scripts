#!/bin/sh

# set -v 

PLATFORM=my-linux-arm-qt
SCRIPT_PATH="/home/jie"

#修改需要下载的源码前缀和后缀
OPENSRC_VER_PREFIX=5.11
OPENSRC_VER_SUFFIX=.1

#添加tslib交叉编译的动态库文件和头文件路径
TSLIB_LIB=/home/jie/arm_tslib/lib/
TSLIB_INC=/home/jie/arm_tslib/include/

#修改源码包解压后的名称
PACKAGE_NAME=qt-everywhere-src-${OPENSRC_VER_PREFIX}${OPENSRC_VER_SUFFIX}

#定义编译后安装--生成的文件,文件夹位置路径
INSTALL_PATH=/opt/arm-qt-${OPENSRC_VER_PREFIX}${OPENSRC_VER_SUFFIX}

#添加交叉编译工具链路径 example:/home/aron566/opt/arm-2014.05/bin/arm-none-linux-gnueabihf
CROSS_CHAIN_PREFIX=/opt/arm-gcc/bin/arm-linux-gnueabihf

#定义压缩包名称
COMPRESS_PACKAGE=${PACKAGE_NAME}.tar.xz

#无需修改--自动组合下载地址
OPENSRC_VER=${OPENSRC_VER_PREFIX}${OPENSRC_VER_SUFFIX}
DOWNLOAD_LINK=http://download.qt.io/new_archive/qt/${OPENSRC_VER_PREFIX}/${OPENSRC_VER}/single/${COMPRESS_PACKAGE}

#无需修改--自动组合平台路径
CONFIG_PATH=${SCRIPT_PATH}/${PACKAGE_NAME}/qtbase/mkspecs/${PLATFORM}

#无需修改--自动组合配置平台路径文件
CONFIG_FILE=${CONFIG_PATH}/qmake.conf

#下载源码包
do_download_qt_every_src () {
   if [ ! -f "${COMPRESS_PACKAGE}" ];then
      if [ ! -d "${PACKAGE_NAME}" ];then
      wget -c ${DOWNLOAD_LINK}
      fi
   fi
}

#解压源码包
do_tar_package () {
   #if exist file then
   echo "\033[1;33m start unpacking the ${PACKAGE_NAME} package ...\033[0m"
   if [ ! -d "${PACKAGE_NAME}" ];then
      tar -xf ${COMPRESS_PACKAGE}
   fi
   echo "\033[1;33m done...\033[0m"
   cd ${PACKAGE_NAME}
}

#安装依赖项
do_install_config_dependent () {
   sudo apt install qt3d5-dev-tools -y
   sudo apt install qml-module-qtquick-xmllistmodel -y
   sudo apt install qml-module-qtquick-virtualkeyboard qml-module-qtquick-shapes qml-module-qtquick-privatewidgets qml-module-qtquick-dialogs qml-module- qt-labs-calendar qml -y
   sudo apt install libqt53dquickscene2d5 libqt53dquickrender5 libqt53dquickinput5 libqt53dquickextras5 libqt53dquickanimation5 libqt53dquick5 -y
   sudo apt install qtdeclarative5-dev qml-module-qtwebengine qml-module-qtwebchannel qml-module-qtmultimedia qml-module-qtaudioengine -y
}

#修改配置平台
do_config_before () {
if [ ! -d "${CONFIG_PATH}" ];then
   cp -a ${SCRIPT_PATH}/${PACKAGE_NAME}/qtbase/mkspecs/linux-arm-gnueabi-g++ ${CONFIG_PATH}
fi

   echo "#" > ${CONFIG_FILE}
   echo "# qmake configuration for building with arm-linux-gnueabi-g++" >> ${CONFIG_FILE}
   echo "#" >> ${CONFIG_FILE}
   echo "" >> ${CONFIG_FILE}
   echo "MAKEFILE_GENERATOR      = UNIX" >> ${CONFIG_FILE}
   echo "CONFIG                 += incremental" >> ${CONFIG_FILE}
   echo "QMAKE_INCREMENTAL_STYLE = sublib" >> ${CONFIG_FILE}
   echo "" >> ${CONFIG_FILE}
   echo "include(../common/linux.conf)" >> ${CONFIG_FILE}
   echo "include(../common/gcc-base-unix.conf)" >> ${CONFIG_FILE}
   echo "include(../common/g++-unix.conf)" >> ${CONFIG_FILE}
   echo "" >> ${CONFIG_FILE}
   echo "# modifications to g++.conf" >> ${CONFIG_FILE}
   echo "QMAKE_CC                = ${CROSS_CHAIN_PREFIX}-gcc -lts" >> ${CONFIG_FILE}
   echo "QMAKE_CXX               = ${CROSS_CHAIN_PREFIX}-g++ -lts" >> ${CONFIG_FILE}
   echo "QMAKE_LINK              = ${CROSS_CHAIN_PREFIX}-g++ -lts" >> ${CONFIG_FILE}
   echo "QMAKE_LINK_SHLIB        = ${CROSS_CHAIN_PREFIX}-g++ -lts" >> ${CONFIG_FILE}
   echo "" >> ${CONFIG_FILE}
   echo "# modifications to linux.conf" >> ${CONFIG_FILE}
   echo "QMAKE_AR                = ${CROSS_CHAIN_PREFIX}-ar cqs" >> ${CONFIG_FILE}
   echo "QMAKE_OBJCOPY           = ${CROSS_CHAIN_PREFIX}-objcopy" >> ${CONFIG_FILE}
   echo "QMAKE_NM                = ${CROSS_CHAIN_PREFIX}-nm -P" >> ${CONFIG_FILE}
   echo "QMAKE_STRIP             = ${CROSS_CHAIN_PREFIX}-strip" >> ${CONFIG_FILE}
   echo "load(qt_config)" >> ${CONFIG_FILE}
   echo "" >> ${CONFIG_FILE}
   echo "QMAKE_INCDIR=${TSLIB_INC}" >> ${CONFIG_FILE}
   echo "QMAKE_LIBDIR=${TSLIB_LIB}" >> ${CONFIG_FILE}
}

#配置选项
do_configure () {
   ./configure -v \
   -prefix ${INSTALL_PATH} \
   -xplatform ${PLATFORM} \
   -release \
   -opensource \
   -confirm-license \
   -no-openssl \
   -no-opengl \
   -no-xcb \
   -no-eglfs \
   -no-compile-examples \
   -no-pkg-config \
   -skip qtquickcontrols \
   -skip qtquickcontrols2 \
   -skip qtsensors \
   -skip qtdoc \
   -skip qtwayland \
   -skip qt3d \
   -skip qtcanvas3d \
   -skip qtpurchasing \
   -skip qtcharts \
   -skip qtdeclarative \
   -no-glib \
   -no-iconv \
   -alsa \
   -silent \
   -qt-zlib \
   -make tools \
   -libinput \
   -tslib \
   -I${TSLIB_INC} \
   -L${TSLIB_LIB}
}


#编译并且安装
do_make_install () {
   make && make install
}

#删除下载的文件
do_delete_file () {
   cd ${SCRIPT_PATH}
   if [ -f "${COMPRESS_PACKAGE}" ];then
      sudo rm -f ${COMPRESS_PACKAGE}
   fi
}

do_download_qt_every_src
do_tar_package
do_config_before
do_configure
# do_install_config_dependent
# do_make_install
# do_delete_file

exit $?

