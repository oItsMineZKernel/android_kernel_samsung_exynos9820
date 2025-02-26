# oItsMineZKernel for OneUI3/4 Exynos 9820/9825 Devices (S10/Note10)

<img src="https://github.com/rifsxd/KernelSU-Next/blob/next/assets/kernelsu_next.png" style="width: 96px;" alt="logo">

Stock Kernel with KernelSU Next & SuSFS based on [Kernel Source](https://github.com/ivanmeler/android_kernel_samsung_beyondlte) by [`ivanmeler`](https://github.com/ivanmeler)

## Features

- OneUI3/4 Support
- Works on binaries 7, 8 and 9
- Implement Ramdisk (No more root loss after reboot)
- Nuke all Samsung's security feature in the kernel
- Some patches from ExtremeKernel & ThunderStormS Kernel
- KernelSU Next
- SuSFS

## Tested On

- [Dr.Ketan ROM](https://xdaforums.com/t/31-07-24-i-n975f-i-n976b-i-n976n-i-n970f-i-dr-ketan-rom-i-oneui-4-1-i-oneui-3-1.3962839)
- [HyperROM](https://xdaforums.com/t/rom-n10-n10plus-n105g-14-jan-23-v1-1s-hyper-rom-be-unique.4268123)
- [VN-ROM](https://t.me/vnromchannel/394)
- And more... (It should work if your ROM is based on stock ROM)

## How to Install
Warning: `Please backup your modules before flashing this kernel (if you have used Magisk or APatch/Next before), as all installed modules may be lost.`
- Flash Zip file via `TWRP`
- Install `KernelSU Next` from [Here](https://github.com/rifsxd/KernelSU-Next/releases)
- Install `susfs4ksu module` from [Here](https://github.com/sidex15/susfs4ksu-module/releases)

## Supported Devices:

`- All dual sim devices are also supported`

> ✅ Working \
> ❔ Need Test \
> ❌ Not Working

| Status |        Name       |  Codename  |    Model   |    Tester   |
|:------:|:-----------------:|:----------:|:----------:|:-----------:|
|   ❔   |    Galaxy S10e    | beyond0lte | SM-G970F/N |      -      |
|   ❔   |     Galaxy S10    | beyond1lte | SM-G973F/N |      -      |
|   ❔   |    Galaxy S10+    | beyond2lte | SM-G975F/N |      -      |
|   ❔   |   Galaxy S10 5G   |   beyondx  | SM-G977B/N |      -      |
|   ✅   |   Galaxy Note10   |     d1     | SM-N970F/N |  [`papal3xa`](https://github.com/ebeth03) |
|   ❔   |  Galaxy Note10 5G |     d1x    |  SM-N971N  |      -      |
|   ✅   |   Galaxy Note10+  |     d2s    | SM-N975F/N |  [`oItsMineZ`](https://github.com/oItsMineZ) |
|   ❔   | Galaxy Note10+ 5G |     d2x    | SM-N976B/N |      -      |

## Build Instructions:

1. Set up build environment as per Google documentation

   <a href="https://source.android.com/docs/setup/start/requirements" target="_blank">https://source.android.com/docs/setup/start/requirements</a>

2. Clone repository

```html
git clone https://github.com/oItsMineZKernel/android_kernel_samsung_exynos9820
```

3. Build for your device

```html
./build.sh -m d2s -k y
```

4. Fetch the flashable zip of the kernel that was just compiled

```html
build/export/oItsMineZKernel-v...zip
```

5. Flash it using a supported recovery like TWRP

6. Enjoy!

## Special Thanks

- [`papal3xa`](https://github.com/ebeth03) for testing my kernel on his d1 many times and trying to flash on OneUI 3, as well as binaries 7, 8, and 9!

## Credits

- [`rifsxd`](https://github.com/rifsxd) for [KernelSU Next](https://github.com/rifsxd/KernelSU-Next)
- [`simonpunk`](https://github.com/simonpunk) for [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)
- [`ivanmeler`](https://github.com/ivanmeler) for [Kernel Source](https://github.com/ivanmeler/android_kernel_samsung_beyondlte)
- [`Ocin4ever`](https://github.com/Ocin4ever) & [`ExtremeXT`](https://github.com/ExtremeXT) for [ExtremeKernel](https://github.com/Ocin4ever/ExtremeKernel)
- [`ThunderStorms21th`](https://github.com/ThunderStorms21th) for [ThunderStormS Kernel](https://github.com/ThunderStorms21th/S10-source)
