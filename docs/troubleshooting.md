# Troubleshooting and rollback

## Roll back a GPU driver

Device Manager → Display adapters → (adapter) → Properties → Driver → **Roll Back Driver**. If the desktop will not load, boot **Safe Mode** (F8 at start-up, or via recovery options) and roll back or uninstall the adapter there, ticking "Delete the driver software" only if you have the replacement driver ready offline.

## Undo the whole experiment

In order of preference:

1. Restore the System Restore point you made before installing.
2. Restore the full disk image you made before installing.
3. Reinstall Windows 7 SP1 clean. On an experimental graphics stack this is sometimes the fastest honest fix.

## Common symptoms

**Setup says "No device drivers were found" before disks appear**
That is the Windows 7 USB 3.0 problem during installation, covered step by step in [usb-installer.md](usb-installer.md) — start by moving the stick to the USB 2.0 port.

**Code 12 on one adapter ("This device cannot find enough free resources")**
Known dual-GPU/UEFI issue that upstream addressed in the Nov 19 main package. Confirm you installed `wddm2_nov19_final.7z` (not the Nov 17 build) and rebooted between the main package and the GPU drivers. If it persists, roll back and re-approach with Intel only, verify, then add NVIDIA.

**Aero/DWM broken after changing resolution (NVIDIA)**
Known upstream limitation of the backported NVIDIA driver. Return to 1920×1080. If DWM does not recover, roll back the NVIDIA driver in Safe Mode and reinstall, then leave resolution alone; use borderless windowed modes in games.

**"Best driver already installed" when pointing Device Manager at the package**
Use **Let me pick from a list** → **Have Disk** and select the INF directly. Before forcing anything, confirm your hardware ID is actually in that INF (preflight script, `-DriverFolder`).

**Driver installs but games pick the Intel GPU**
Optimus routing. Set the per-app or global preferred GPU in NVIDIA Control Panel, and confirm with the in-game overlay or GPU activity icon. Test the HDMI port separately and note which GPU drives external output on your unit.

**Black screen after reboot**
Wait a full two minutes on first boot after a driver swap. Still black? Safe Mode → roll back the last adapter you changed. Change one GPU at a time on the next attempt so you know which step breaks.

**Games stutter in borderless / exclusive fullscreen feels off**
The Nov 19 upstream notes already include fixes in this area, so make sure you are on that build. After that, treat per-game issues as experimental-stack behavior: try the other fullscreen mode, cap the frame rate, and record the title + mode in your notes before tweaking globally.

## Reporting problems upstream

This kit cannot fix bugs in the backport itself. Search the W7Revived channels first, and report with: laptop model (GL552VW SKU), both GPU hardware IDs (the preflight script prints them), package filenames installed, install order, and the exact Device Manager code or crash point.
