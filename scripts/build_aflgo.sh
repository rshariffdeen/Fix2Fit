#!/bin/bash

export INITIAL_CC=$CC
export INITIAL_CXX=$CXX
export INITIAL_CFLAGS=$CFLAGS
export INITIAL_CXXFLAGS=$CXXFLAGS

# Build LLVM 4.0.0 for building f1x
export CC=gcc
export CXX=g++
export CFLAGS=
export CXXFLAGS=

LLVM_DEP_PACKAGES="build-essential make cmake ninja-build git subversion python2.7 binutils-gold binutils-dev gawk"
apt-get install -y $LLVM_DEP_PACKAGES

if [ -x "llvm-4.0.0/install/bin/clang" ] ; then
    echo LLVM 4.0.0 built
    exit 1
fi

mkdir -p llvm-4.0.0
pushd llvm-4.0.0 > /dev/null
if [ ! -e llvm-4.0.0.src.tar.xz ] ; then
        wget http://releases.llvm.org/4.0.0/llvm-4.0.0.src.tar.xz
        tar xf llvm-4.0.0.src.tar.xz
        mv llvm-4.0.0.src src
        rm -f llvm-4.0.0.src.tar.xz
fi
if [ ! -e cfe-4.0.0.src.tar.xz ] ; then
        wget http://releases.llvm.org/4.0.0/cfe-4.0.0.src.tar.xz
        tar xf cfe-4.0.0.src.tar.xz
        mv cfe-4.0.0.src src/tools/clang
        rm -f cfe-4.0.0.src.tar.xz
fi
if [ ! -e compiler-rt-4.0.0.src.tar.xz ] ; then
        wget http://releases.llvm.org/4.0.0/compiler-rt-4.0.0.src.tar.xz
        tar xf compiler-rt-4.0.0.src.tar.xz
        mv compiler-rt-4.0.0.src src/projects/compiler-rt
        rm -f compiler-rt-4.0.0.src.tar.xz
fi
mkdir -p install
LLVM_INSTALL_DIR=$PWD/install
mkdir -p build
LLVM_BUILD_DIR=$PWD/build
LLVM_SRC_DIR=$PWD/src
pushd build > /dev/null
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$LLVM_INSTALL_DIR -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=Off -DLLVM_BINUTILS_INCDIR=/usr/include ../src
make -j$(nproc) install
popd > /dev/null
rm -rf $PWD/src
popd > /dev/null


cp $LLVM_BUILD_DIR/lib/libLTO.so /usr/local/lib/libLTO.so
cp $LLVM_BUILD_DIR/lib/LLVMgold.so /usr/local/lib/LLVMgold.so
mkdir /usr/lib/bfd-plugins
cp /usr/local/lib/libLTO.so /usr/lib/bfd-plugins
cp /usr/local/lib/LLVMgold.so /usr/lib/bfd-plugins

rm -rf $LLVM_BUILD_DIR
rm -rf $LLVM_SRC_DIR
export PATH=$LLVM_INSTALL_DIR/bin:$PATH

#build aflgo
export CC=clang
export CXX=clang++

AFLGO_DEP_PACKAGES="python3 python3-dev python-dev python3-pip"
apt-get update
apt-get install -y $AFLGO_DEP_PACKAGES

pip3 install networkx
pip3 install pydot
pip3 install pydotplus

#git clone https://github.com/aflgo/aflgo.git
export AFLGO=$PWD/aflgo

# Compile source code
F1X_FLAGS="-L/libboost/boost_1_58_0/stage/lib -lF1X -lf1xRepair -lrt -lboost_regex -lboost_program_options -lboost_log -lboost_log_setup -lboost_date_time -lboost_system -lboost_filesystem -lboost_thread -lboost_chrono -lboost_atomic -lpthread"
pushd $AFLGO
CFLAGS=$F1X_FLAGS CXXFLAGS=$F1X_FLAGS make clean all
cd llvm_mode
CFLAGS=$F1X_FLAGS CXXFLAGS=$F1X_FLAGS make clean all
popd

export CC=$INITIAL_CC
export CXX=$INITIAL_CXX
export CFLAGS=$INITIAL_CFLAGS
export CXXFLAGS=$INITIAL_CXXFLAGS
