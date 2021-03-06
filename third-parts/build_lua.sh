#!/bin/bash
#set -x

LUA_VERSION=5.2.4
TOLUA_VERSION=5.2.4
TARGET_ROOT=../lib

if [ ! ${TARGET_ROOT:0:1}x = "/"x ]; then
    TARGET_ROOT=`pwd`/${TARGET_ROOT}
fi

function Usage()
{
    echo "Usage: ${0##*/} OS ARCH"
    echo "    OS: linux macosx ios mingw android"
    echo "    ARCH: x86 x86_64 armv5 armv7 armv7s armv64"
}

function ModiyLuaLock()
{
    ../modify_lua_lock.sh
    return $?
    #return 0
}

function build_lua_linux()
{
    local lua_top=
    local tolua_top=
    case ${ARCH} in
        x86_64)
            lua_top=${TARGET_ROOT}/lua/linux-x86_64
            rm -rf ${lua_top}
            mkdir -p ${lua_top}
            rm -rf lua-${LUA_VERSION}/
            tar zxf lua-${LUA_VERSION}.tar.gz
            pushd .
            cd lua-${LUA_VERSION}/
            ModiyLuaLock
            if [ $? -ne 0 ]; then echo "\033[31mBuild lua Failed !!\033[0m"; exit 1; fi
            make linux && make install INSTALL_TOP=${lua_top}
            if [ $? -ne 0 ]; then echo "\033[31mBuild lua Failed !!\033[0m"; exit 1; fi
            popd

            tolua_top=${TARGET_ROOT}/tolua/linux-x86_64
            rm -rf ${tolua_top}
            mkdir -p ${tolua_top}
            rm -rf tolua-${TOLUA_VERSION}/
            tar zxf tolua-${TOLUA_VERSION}.tar.gz
            pushd .
            cd tolua-${TOLUA_VERSION}/
            sed -i "s/^LIB= /LIB= -ldl /g" config
            make tolua LUA=${lua_top}
            if [ $? -ne 0 ]; then echo -e "\033[31mBuild tolua Failed !!\033[0m"; exit 1; fi
            cp -R -a include lib bin ${tolua_top} 
            popd
            ;;
        *)
            echo -e "\033[31mBuild For ${OS}, Unsupportted ARCH: ${ARCH} !!\033[0m"; Usage; exit 1;
            ;;
    esac
}

function build_lua_macosx()
{
    local lua_top=
    local tolua_top=
    case ${ARCH} in
        x86_64)
            lua_top=${TARGET_ROOT}/lua/macosx-x86_64
            rm -rf ${lua_top}
            mkdir -p ${lua_top}
            rm -rf lua-${LUA_VERSION}/
            tar zxf lua-${LUA_VERSION}.tar.gz
            pushd .
            cd lua-${LUA_VERSION}/
            ModiyLuaLock
            if [ $? -ne 0 ]; then echo "\033[31mBuild lua Failed !!\033[0m"; exit 1; fi
            make macosx && make install INSTALL_TOP=${lua_top}
            if [ $? -ne 0 ]; then echo "\033[31mBuild lua Failed !!\033[0m"; exit 1; fi
            popd

            tolua_top=${TARGET_ROOT}/tolua/macosx-x86_64
            rm -rf ${tolua_top}
            mkdir -p ${tolua_top}
            rm -rf tolua-${TOLUA_VERSION}/
            tar zxf tolua-${TOLUA_VERSION}.tar.gz
            pushd .
            cd tolua-${TOLUA_VERSION}/
            make tolua LUA=${lua_top}
            if [ $? -ne 0 ]; then echo -e "\033[31mBuild tolua Failed !!\033[0m"; exit 1; fi
            cp -R -a include lib bin ${tolua_top} 
            popd
            ;;
        *)
            echo -e "\033[31mBuild for ${OS}, Unsupportted ARCH: ${ARCH} !!\033[0m"; Usage; exit 1;
            ;;
    esac
}

function build_lua_ios()
{
    echo 1
}

function build_lua_mingw()
{
    local lua_top=${TARGET_ROOT}/lua/mingw-${ARCH}
    rm -rf ${lua_top}
    mkdir -p ${lua_top}
    rm -rf lua-${LUA_VERSION}/
    tar zxf lua-${LUA_VERSION}.tar.gz
    pushd .
    cd lua-${LUA_VERSION}/
    ModiyLuaLock
    if [ $? -ne 0 ]; then echo "\033[31mBuild lua Failed !!\033[0m"; exit 1; fi
    make mingw && make install INSTALL_TOP=${lua_top}
    if [ $? -ne 0 ]; then echo "\033[31mBuild lua Failed !!\033[0m"; exit 1; fi
    popd

    local tolua_top=${TARGET_ROOT}/tolua/mingw-${ARCH}
    rm -rf ${tolua_top}
    mkdir -p ${tolua_top}
    rm -rf tolua-${TOLUA_VERSION}/
    tar zxf tolua-${TOLUA_VERSION}.tar.gz
    pushd .
    cd tolua-${TOLUA_VERSION}/
    make tolua LUA=${lua_top}
    if [ $? -ne 0 ]; then echo -e "\033[31mBuild tolua Failed !!\033[0m"; exit 1; fi
    cp -R -a include lib bin ${tolua_top} 
    popd
}

function build_lua_android()
{
    echo 1
}

OS=${1}
ARCH=${2}
if [ ${OS}x = x ]; then echo -e "\033[31mEmpty OS !!\033[0m"; Usage; exit 1; fi
case ${OS} in
    linux)
        if [ ${ARCH}x = x ]; then echo -e "\033[31mEmpty ARCH !!\033[0m"; Usage; exit 1; fi
        build_lua_linux
        ;;
    macosx)
        ARCH=${ARCH:-x86_64}
        build_lua_macosx
        ;;
    ios)
        if [ ${ARCH}x = x ]; then echo -e "\033[31mEmpty ARCH !!\033[0m"; Usage; exit 1; fi
        build_lua_ios
        ;;
    mingw)
        if [ ${ARCH}x = x ]; then echo -e "\033[31mEmpty ARCH !!\033[0m"; Usage; exit 1; fi
        build_lua_mingw
        ;;
    android)
        if [ ${ARCH}x = x ]; then echo -e "\033[31mEmpty ARCH !!\033[0m"; Usage; exit 1; fi
        build_lua_android
        ;;
    *)
        echo -e "\033[31mUnsupportted OS: ${OS} !!\033[0m"; Usage; exit 1;
        ;;
esac
