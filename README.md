# WDDM2 on Windows 7 — ASUS ROG GL552VW guide kit

An install guide and preflight checker for running the community **WDDM2Win7 backport** on the **ASUS ROG GL552VW**. This repo contains only original documentation and scripts from VetTV Studios. It does **not** contain, mirror, or redistribute the backport, Windows files, or GPU drivers — those stay on the official W7Revived server linked below.

## Target laptop

| Part | Spec |
| --- | --- |
| CPU | Intel Core i7-6700HQ (Skylake) |
| Integrated GPU | Intel HD Graphics 530 |
| Discrete GPU | NVIDIA GeForce GTX 960M, 2GB GDDR5 (Optimus) |
| Display | 15.6" Full HD 1920×1080 IPS |
| Storage / RAM | 512GB SSD / 24GB DDR4 |
| I/O | 2× USB-A 3.2 Gen 1, 1× USB-A 2.0, 1× USB-C 3.2 Gen 1, HDMI, card reader, Gigabit Ethernet, Wi-Fi, Bluetooth 4.0, 3.5 mm audio jack |
| Extras | Fingerprint reader, webcam, backlit keyboard, microphone, speakers, optional optical drive, lock slot |

## What this is (and is not)

WDDM2Win7 is an unofficial community project by the W7Revived / ChefKiss team that backports Windows 10-era WDDM 2.x display components to Windows 7 SP1 so newer GPU drivers and DirectX 12 titles can run there. It is experimental, unsupported by Microsoft, Intel, or NVIDIA, and it replaces core graphics-stack files. Treat it like a lab project on a spare install, not a daily-driver upgrade.

There is no public source release to fork or build — the project ships as prebuilt packages. So instead of a fork, this kit gives GL552VW owners:

1. A preflight script that checks the machine before anything is installed.
2. A step-by-step install order written for this dual-GPU laptop.
3. Hardware-ID checks so you can confirm a driver package actually lists your GPUs before forcing it in.
4. Rollback notes for when (not if) something needs undoing.

## Read this before you start

- **Back up first.** Take a full disk image or at minimum a System Restore point plus copies of anything you care about. Keep Windows 7 install media and a second PC handy.
- **Windows 7 must be SP1 and fully updated** (build 7601). The upstream README calls for an updated install; update packs exist for offline updating.
- **Check the NVIDIA package against your hardware ID.** The current W7Revived NVIDIA package is built around driver 582.35, a branch aimed at much newer cards. The GTX 960M (Maxwell) may not be listed in its INFs at all. The GTX 960M already has native Windows 7 drivers from NVIDIA's older branches — if the 582 package does not list your hardware ID, do not force it; use the last native Windows 7 NVIDIA driver for the 960M instead and treat the backport's value on this laptop as the updated display stack / Intel side. The preflight script can search an extracted driver folder for your IDs.
- **Do not change display resolution after installing the NVIDIA backport driver.** Upstream warns it breaks DWM/Aero. Leave the internal panel at its native 1920×1080.
- Expect unsigned/patched-driver prompts. Only proceed if you understand what "Always trust" means for driver signing on your own machine.

## Quick start

1. Run the preflight check in an elevated PowerShell on the GL552VW:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\Invoke-Gl552vwPreflight.ps1
   ```

   Optionally verify a downloaded, extracted driver folder against your GPUs:

   ```powershell
   .\scripts\Invoke-Gl552vwPreflight.ps1 -DriverFolder "C:\Drivers\NVIDIA-extracted"
   ```

2. If Windows 7 is not installed yet, start with [docs/usb-installer.md](docs/usb-installer.md) (MBR vs GPT, BIOS settings, and the "No device drivers were found" USB 3.0 fix).
3. Download the packages from the official directory — see [docs/downloads.md](docs/downloads.md).
4. Follow [docs/install-guide.md](docs/install-guide.md) in order. Do not skip the reboot between the main package and GPU drivers.
5. Keep [docs/troubleshooting.md](docs/troubleshooting.md) open for rollback and common failure modes.

## Credits and links

- WDDM2 backport and drivers: W7Revived / ChefKiss team — official directory: https://w7revived.chefkiss.dev/WDDM2_Backport/Win7/
- This guide kit: VetTV Studios (https://www.vettvstudios.com) — news coverage at https://news.vettvstudios.com
- Documentation and scripts in this repo are MIT licensed (see `LICENSE`). That license covers only our text and code — not the upstream packages, which remain under their respective owners' terms.
