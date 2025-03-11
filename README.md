# oItsMineZKernel for OneUI 3/4 Exynos 9820/9825 Devices (S10/Note10)

<img src="https://github.com/KernelSU-Next/KernelSU-Next/blob/next/assets/kernelsu_next.png" style="width: 96px;" alt="logo">

Stock Kernel with KernelSU Next & SuSFS based on [Kernel Source](https://github.com/ivanmeler/android_kernel_samsung_beyondlte) by [`ivanmeler`](https://github.com/ivanmeler)

## Features

- Kernel Based on HVD3 OneUI 4.1 (Binary 7)
- OneUI 3/4 and Binaries 7, 8 and 9 Support (It may have some issues depending on ROM binary or OneUI version)
- Implement Ramdisk (No more root loss after reboot)
- Nuke all Samsung's Security Feature, Logs & Debug in the Kernel
- MoroSound
- WireGuard
- CPU Input Boost
- Voltage Control
- Fingerprint Boost
- Mali GPU Drivers r36p0 ValHall
- OC for Little, Mid and Big CPU
- HZ Tick Set at 25Hz
- Boeffla Wakelock Blocker
- Backported Game Misc Control from Samsung S20
- Bypass Charging (Use power directly from charger)
- ThunderTweaks Support (You can get ThunderTweaks [here](https://github.com/oItsMineZKernel/Kernel-Patch/raw/refs/heads/main/ThunderTweaks_v1.1.1.5.apk) to customize kernel features)
- KernelSU Next
- SuSFS

## Tested On

- [Dr.Ketan ROM](https://xdaforums.com/t/31-07-24-i-n975f-i-n976b-i-n976n-i-n970f-i-dr-ketan-rom-i-oneui-4-1-i-oneui-3-1.3962839)
- [HyperROM](https://xdaforums.com/t/rom-n10-n10plus-n105g-14-jan-23-v1-1s-hyper-rom-be-unique.4268123)
- [VN-ROM](https://t.me/vnromchannel/394)
- And more... (It should work if your ROM is based on stock ROM)

## How to Install
- Flash Zip file via `TWRP`
- Install `KernelSU Next` from [Here](https://github.com/rifsxd/KernelSU-Next/releases)
- Install `susfs4ksu module` from [Here](https://github.com/sidex15/susfs4ksu-module/releases)

## Supported Devices:

`- All dual sim devices are also supported`


|        Name       |  Codename  |    Model   |
:------------------:|:----------:|:----------:|
|    Galaxy S10e    | beyond0lte | SM-G970F/N |
|     Galaxy S10    | beyond1lte | SM-G973F/N |
|    Galaxy S10+    | beyond2lte | SM-G975F/N |
|   Galaxy S10 5G   |   beyondx  | SM-G977B/N |
|   Galaxy Note10   |     d1     | SM-N970F/N |
|  Galaxy Note10 5G |     d1x    |  SM-N971N  |
|   Galaxy Note10+  |     d2s    | SM-N975F/N |
| Galaxy Note10+ 5G |     d2x    | SM-N976B/N |

## Build Instructions:

1. Set up build environment as per Google documentation

   <a href="https://source.android.com/docs/setup/start/requirements" target="_blank">https://source.android.com/docs/setup/start/requirements</a>

2. Clone repository

```
git clone https://github.com/oItsMineZKernel/android_kernel_samsung_exynos9820
```

3. Build for your device

```
./build.sh -m d2s
```

4. Fetch the flashable zip of the kernel that was just compiled

```
build/export/oItsMineZKernel-Unofficial...zip
```

5. Flash it using a supported recovery like TWRP

6. Enjoy!

## Credits

- [`rifsxd`](https://github.com/rifsxd) for [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next)
- [`simonpunk`](https://github.com/simonpunk) for [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)
- [`ivanmeler`](https://github.com/ivanmeler) for [Kernel Source](https://github.com/ivanmeler/android_kernel_samsung_beyondlte)
- [`Ocin4ever`](https://github.com/Ocin4ever) & [`ExtremeXT`](https://github.com/ExtremeXT) for [ExtremeKernel](https://github.com/Ocin4ever/ExtremeKernel)
- [`ThunderStorms21th`](https://github.com/ThunderStorms21th) for [ThunderStormS Kernel](https://github.com/ThunderStorms21th/S10-source)
- [`evdenis`](https://github.com/evdenis) for [CruelKernel](https://github.com/CruelKernel/samsung-exynos9820)