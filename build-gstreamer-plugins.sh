#!/bin/sh
#交叉编译通用脚本cross_compile.sh

#/home/wmx/odm_yb
AW_LICHEE_ROOT=/home/wmx/odm_yb

#当前目录作为构建目录
export DEST_BUILD_ROOT=$PWD/

#配置sysroot (按照 linux 的标准目录结构查找头文件目录和库文件目录)
export SYSROOT=$AW_LICHEE_ROOT/out/sun8iw11p1/linux/common/buildroot/host/usr/arm-buildroot-linux-gnueabi/sysroot

#编译后  安装目录
export DEST_INSTALL_DIR=$SYSROOT/usr
#export DEST_INSTALL_DIR=$DEST_BUILD_ROOT/../gstreamer-arm

#配置交叉编译工具链
export CROSS_COMPILE_DIR=$AW_LICHEE_ROOT/out/sun8iw11p1/linux/common/buildroot/host/opt/ext-toolchain

#$PATH:$DEST_INSTALL_DIR/bin:
export PATH=$CROSS_COMPILE_DIR:$AW_LICHEE_ROOT/out/sun8iw11p1/linux/common/buildroot/host/usr/bin:$PATH


#requires 
export LD_LIBRARY_PATH=$DEST_INSTALL_DIR/lib
export PKG_CONFIG_PATH=$DEST_INSTALL_DIR/lib/pkgconfig
export LD_RUN_PATH=$LD_LIBRARY_PATH


#配置
function makeconfig
{

	#mkdir -p $DEST_INSTALL_DIR

	$DEST_BUILD_ROOT/configure  \
	--prefix=$DEST_INSTALL_DIR  \
	--build=x86_64-pc-linux-gnu \
	--host=arm-linux-gnueabi \
	--target=arm-linux-gnueabi \
	CC=arm-linux-gnueabi-gcc \
	--with-sysroot=$SYSROOT

				
}


##构建
function makeall
{
	make -j32  -C $DEST_BUILD_ROOT
}


##安装
function makeinstall
{
	make -C $DEST_BUILD_ROOT install

	#进入pkgconfig目录，修改所有 pc 文件  prefix=/usr ，即是安装目录SYSROOT 下的 /usr
	#这样才能正确搜索到库
	cd $DEST_INSTALL_DIR/lib/pkgconfig
	sed -i '1c prefix=/usr' *pc
	cd $DEST_BUILD_ROOT
}











