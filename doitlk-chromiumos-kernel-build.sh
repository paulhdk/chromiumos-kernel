#!/bin/sh

ENABLE_DEP_CHEKER="-fsanitize=lkmm-dep-checker"
CROSS="ARCH=arm64 CROSS_COMPILE=aarch64-unknown-linux-gnu-"
MAKEFLAGS="CC=clang $CROSS KCFLAGS=\"$ENABLE_DEP_CHEKER\""

case $1 in
	"mrproper")
		make mrproper 
		;;
	"clean")
		make clean
		;;
	"defconfig")
		make $MAKEFLAGS defconfig
		;;
	"fast")	
		make $MAKEFLAGS -j$(nproc) $2 2> build_output.ll
		;;
	"precise")
		make $MAKEFLAGS -j1 $2 2> build_output.ll
		;;
	*)
		echo "Invalid command line argument"
		exit -1
		;;
esac

./scripts/gen_compile_commands.py

