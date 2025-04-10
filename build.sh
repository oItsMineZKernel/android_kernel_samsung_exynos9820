#!/bin/bash

abort()
{
    cd -
    echo "---------------------------------------------------------"
    echo "-- Kernel compilation failed! Exiting..."
    echo "---------------------------------------------------------"
    if [[ "$LOCAL" == "y" ]]; then
        FUNC_CLEANUP
    fi
    exit -1
}

unset_flags()
{
    cat << EOF
Usage: $(basename "$0") [options]
Options:
    -m, --model [value]    Specify the model code of the phone
    -k, --ksu [y/N]        Include KernelSU Next with SuSFS (default: y)
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --model|-m)
            MODEL="$2"
            shift 2
            ;;
        --ksu|-k)
            KSU_OPTION="$2"
            shift 2
            ;;
        --ver|-v)
            KERNEL_VERSION="$2"
            shift 2
            ;;
        --rel|-r)
            RELEASE="$2"
            shift 2
            ;;
        *)\
            unset_flags
            exit 1
            ;;
    esac
done

FUNC_CHECKENV()
{
    DATE=`date +"%Y%m%d"`
    export KBUILD_BUILD_USER="oItsMineZ"

    if [ -n $RELEASE ]; then
        echo "---------------------------------------------------------"
        echo "-- Running on GitHub Actions..."
        export KBUILD_BUILD_HOST="GitHub-Actions"
    else
        echo "---------------------------------------------------------"
        echo "-- Running on Local Machine..."
        export KBUILD_BUILD_HOST="Linux-Stable"
        LOCAL=y
    fi
}

RDIR=$(pwd)
CPU=`grep -c ^processor /proc/cpuinfo`
CLANG=$RDIR/toolchain/clang-r416183b1/bin/
GCC=$RDIR/toolchain/aarch64-linux-android-4.9/bin/
ARGS="
    ARCH=arm64 O=out \
    CC=${CLANG}clang \
    CROSS_COMPILE=${GCC}aarch64-linux-androidkernel- \
    CLANG_TRIPLE=${CLANG}aarch64-linux-gnu- \
"

# Define specific variables
KERNEL_DEFCONFIG=oitsminez-"$MODEL"_defconfig
case $MODEL in
beyond0lte)
    SOC=9820
    BOARD=SRPRI28A014KU
;;
beyond1lte)
    SOC=9820
    BOARD=SRPRI28B014KU
;;
beyond2lte)
    SOC=9820
    BOARD=SRPRI17C014KU
;;
beyondx)
    SOC=9820
    BOARD=SRPSC04B011KU
;;
d1)
    SOC=9825
    BOARD=SRPSD26B007KU
;;
d1x)
    SOC=9825
    BOARD=SRPSD23A002KU
;;
d2s)
    SOC=9825
    BOARD=SRPSC14B007KU
;;
d2x)
    SOC=9825
    BOARD=SRPSC14C007KU
;;
*)
    unset_flags
    exit
esac

if [ -z $KSU_OPTION ]; then
    KSU_OPTION=y
fi

if [[ "$KSU_OPTION" == "y" ]]; then
    FUNC_CHECKENV
    KSU_NEXT=ksu_next.config

    if test -d "$DIR/drivers/kernelsu" && grep -rnw 'fs/Makefile' -e 'CONFIG_KSU_SUSFS'; then
        echo "---------------------------------------------------------"
        echo "-- KernelSU-Next Directory Found!..."
        echo "---------------------------------------------------------"
    else
        echo "---------------------------------------------------------"
        echo "-- Checkout oItsMineZ's KernelSU-Next Repo..."
        echo "---------------------------------------------------------"

        git submodule add --force https://github.com/oItsMineZ/KernelSU-Next
        curl -LSs "https://raw.githubusercontent.com/oItsMineZ/KernelSU-Next/susfs-v1.5.5/kernel/setup.sh" | bash -

        if ! grep -rnw 'fs/Makefile' -e 'CONFIG_KSU_SUSFS'; then

            echo "---------------------------------------------------------"
            echo "-- Patch KernelSU-Next with SuSFS..."
            echo "---------------------------------------------------------"

            curl -LOSs "https://raw.githubusercontent.com/oItsMineZKernel/Kernel-Patch/main/SuSFS.patch"
            patch -p1 < SuSFS.patch
            rm -rf *.patch
        fi
    fi
fi

if [ -z $KERNEL_VERSION ]; then
    KERNEL_VERSION="Unofficial"
fi

FUNC_TOOLCHAIN()
{
    echo "---------------------------------------------------------"
    echo "-- Checkout Toolchain Repo..."
    echo "---------------------------------------------------------"

    git submodule add --branch aarch64-linux-android-4.9 --force https://github.com/oItsMineZKernel/toolchain toolchain/aarch64-linux-android-4.9
    git submodule add --branch clang-r416183b1 --force https://github.com/oItsMineZKernel/toolchain toolchain/clang-r416183b1
}

FUNC_BUILD_KERNEL()
{
    # Build kernel image
    echo "---------------------------------------------------------"
    echo "-- Device: "$MODEL""
    echo "-- SOC: Exynos$SOC"
    echo "-- Defconfig: "$KERNEL_DEFCONFIG""
    echo "-- Kernel Version: $KERNEL_VERSION"

    if [ -z $KSU_NEXT ]; then
        echo "-- KernelSU Next with SuSFS: Not Include"
    else
        echo "-- KernelSU Next with SuSFS: $KSU_NEXT"
    fi

    echo -e "CONFIG_LOCALVERSION_AUTO=n" > $RDIR/arch/arm64/configs/version.config
    
    if [[ "$SOC" == "9825" ]]; then
        DEVICE=Note10
    else
        DEVICE=S10
    fi

    if [ -n $RELEASE ]; then
        echo BUILD_DEVICE=$DEVICE >> $GITHUB_ENV
    fi

    echo -e "CONFIG_LOCALVERSION=\"-oItsMineZKernel-"$KERNEL_VERSION"-"$DEVICE"\"" >> $RDIR/arch/arm64/configs/version.config
    DEFCONFIG="$KERNEL_DEFCONFIG oitsminez.config version.config $KSU_NEXT"

    echo "---------------------------------------------------------"
    echo "-- Building Kernel Using "$KERNEL_DEFCONFIG""
    echo "-- Generating Configuration Files..."
    echo "---------------------------------------------------------"

    make -j$CPU $ARGS $DEFCONFIG || abort

    echo "---------------------------------------------------------"
    echo "-- Building Kernel..."
    echo "---------------------------------------------------------"

    make -j$CPU $ARGS || abort

    echo "---------------------------------------------------------"
    echo "-- Finished Kernel Build!"
    echo "---------------------------------------------------------"

    rm -rf $RDIR/build/out/$MODEL
    mkdir -p $RDIR/build/out/$MODEL
}

FUNC_BUILD_DTBO()
{
    # Build dtb
    echo "-- Building common exynos$SOC Device Tree Blob Image..."
    echo "---------------------------------------------------------"

    $RDIR/build/mkdtimg cfg_create $RDIR/build/out/$MODEL/dtb_exynos$SOC.img \
        $RDIR/build/dtconfigs/exynos$SOC.cfg \
        -d $RDIR/out/arch/arm64/boot/dts/exynos

    # Build dtbo
    echo "---------------------------------------------------------"
    echo "-- Building Device Tree Blob Output Image for "$MODEL"..."
    echo "---------------------------------------------------------"

    $RDIR/build/mkdtimg cfg_create $RDIR/build/out/$MODEL/dtbo_$MODEL.img \
        $RDIR/build/dtconfigs/$MODEL.cfg \
        -d $RDIR/out/arch/arm64/boot/dts/samsung
}

FUNC_BUILD_RAMDISK()
{
    # Build ramdisk
    echo "---------------------------------------------------------"
    echo "-- Building Ramdisk..."
    echo "---------------------------------------------------------"

    rm -f $RDIR/build/AIK/split_img/boot.img-kernel
    cp $RDIR/out/arch/arm64/boot/Image $RDIR/build/AIK/split_img/boot.img-kernel
    echo $BOARD > build/AIK/split_img/boot.img-board

    # Create boot image
    echo "-- Creating Boot Image..."
    echo "---------------------------------------------------------"

    # This is kinda ugly hack, we could as well touch .placeholder to all of those
    mkdir -p $RDIR/build/AIK/ramdisk/debug_ramdisk
    mkdir -p $RDIR/build/AIK/ramdisk/dev
    mkdir -p $RDIR/build/AIK/ramdisk/mnt
    mkdir -p $RDIR/build/AIK/ramdisk/proc
    mkdir -p $RDIR/build/AIK/ramdisk/sys

    rm -rf $RDIR/build/AIK/ramdisk/fstab.exynos*

    cp $RDIR/build/AIK/fstab.exynos$SOC $RDIR/build/AIK/ramdisk/

    cd $RDIR/build/AIK/
    ./repackimg.sh --nosudo
}

FUNC_BUILD_ZIP()
{
    # Build zip
    echo "---------------------------------------------------------"
    echo "-- Building Zip..."
    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        echo "---------------------------------------------------------"
    fi

    rm -rf $RDIR/build/out/$MODEL/zip
    mkdir -p $RDIR/build/export
    mkdir -p $RDIR/build/out/$MODEL/zip
    mkdir -p $RDIR/build/out/$MODEL/zip/module
    mkdir -p $RDIR/build/out/$MODEL/zip/module/common/
    mkdir -p $RDIR/build/out/$MODEL/zip/module/META-INF/com/google/android
    mkdir -p $RDIR/build/out/$MODEL/zip/META-INF/com/google/android
    mv $RDIR/build/AIK/image-new.img $RDIR/build/out/$MODEL/boot-patched.img

    # Make recovery flashable package
    cp $RDIR/build/out/$MODEL/boot-patched.img $RDIR/build/out/$MODEL/zip/boot.img
    cp $RDIR/build/out/$MODEL/dtb_exynos$SOC.img $RDIR/build/out/$MODEL/zip/dtb.img
    cp $RDIR/build/out/$MODEL/dtbo_$MODEL.img $RDIR/build/out/$MODEL/zip/dtbo.img
    cp $RDIR/build/update-binary $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/
    cp $RDIR/build/updater-script $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/

    cp $RDIR/build/module.prop $RDIR/build/out/$MODEL/zip/module/
    cp $RDIR/build/system.prop $RDIR/build/out/$MODEL/zip/module/common/
    cp $RDIR/build/module-binary $RDIR/build/out/$MODEL/zip/module/META-INF/com/google/android/update-binary
    cp $RDIR/build/module-script $RDIR/build/out/$MODEL/zip/module/META-INF/com/google/android/updater-script

    sed -i "s|name=oItsMineZKernel Addons for Exynos9820/9825|name=oItsMineZKernel $KERNEL_VERSION Addons for Exynos9820/9825|" $RDIR/build/out/$MODEL/zip/module/module.prop
    sed -i "s|package_extract_file(\"module.zip\", \"/sdcard/oItsMineZKernel-Addons-.zip\");|package_extract_file(\"module.zip\", \"/sdcard/oItsMineZKernel-Addons-$KERNEL_VERSION.zip\");|" $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s|ui_print(\"   /sdcard/oItsMineZKernel-Addons-.zip\");|ui_print(\"   /sdcard/oItsMineZKernel-Addons-$KERNEL_VERSION.zip\");|" $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script

    cd $RDIR/build/out/$MODEL/zip/module
    zip -r ../module.zip .
    rm -rf $RDIR/build/out/$MODEL/zip/module

    sed -i "s/ui_print(\" Kernel Version: \");/ui_print(\" Kernel Version: $KERNEL_VERSION\");/" $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/ui_print(\" Kernel Device: \");/ui_print(\" Kernel Device: $DEVICE ($MODEL)\");/" $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/CONFIG_LOCALVERSION=\"-oItsMineZKernel-"$KERNEL_VERSION"-"$DEVICE"\"/CONFIG_LOCALVERSION=\"-oItsMineZKernel-"$KERNEL_VERSION"-"$DATE"-"$DEVICE"\"/" $RDIR/arch/arm64/configs/version.config

    version=$(grep -o 'CONFIG_LOCALVERSION="[^"]*"' $RDIR/arch/arm64/configs/version.config | cut -d '"' -f 2)
    version=${version:1}
    NAME="$version"-"$MODEL".zip

    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        cd $RDIR/build/out/$MODEL/zip
        zip -r ../"$NAME" .
        rm -rf $RDIR/build/out/$MODEL/zip
        mv $RDIR/build/out/$MODEL/"$NAME" $RDIR/build/export/"$NAME"
        cd $RDIR/build/export
    fi
}

FUNC_CLEANUP()
{
    echo "---------------------------------------------------------"
    echo "-- Cleanup build files..."
    echo "---------------------------------------------------------"

    cd $RDIR && rm -rf out
    rm -rf .wireguard-fetch-lock
    rm -rf arch/arm64/configs/version.config
    rm -rf build/AIK/ramdisk/fstab.exynos*
    rm -rf build/AIK/split_img/boot.img-kernel

    git rm -rf KernelSU-Next
    git rm -rf toolchain

    git reset --hard HEAD && git clean -df
}

# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=`date +%s`

    echo "---------------------------------------------------------"
    echo "-- Preparing the Build Environment..."

    if test -d "$DIR/toolchain"; then
        echo "---------------------------------------------------------"
        echo "-- Toolchain Directory Found!"
        echo "---------------------------------------------------------"
    else
        FUNC_TOOLCHAIN
    fi

    FUNC_BUILD_KERNEL
    FUNC_BUILD_DTBO
    FUNC_BUILD_RAMDISK
    FUNC_BUILD_ZIP

    if [[ "$LOCAL" == "y" ]]; then
        FUNC_CLEANUP
    fi

    END_TIME=`date +%s`

    let "ELAPSED_TIME=$END_TIME-$START_TIME"

    echo "---------------------------------------------------------"
    echo "-- Total compile time was $(($ELAPSED_TIME / 60)) minutes and $(($ELAPSED_TIME % 60)) seconds"
    echo "---------------------------------------------------------"
) 2>&1	| tee -a ./build.log