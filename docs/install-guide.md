# Install guide — GL552VW (i7-6700HQ + HD 530 + GTX 960M Optimus)

Written for a clean or spare Windows 7 SP1 x64 install on the ASUS ROG GL552VW. Budget an afternoon, stay on AC power, and do not rush the reboots.

## 0. Prepare

1. **Image the disk** or at least create a System Restore point and copy personal files off the machine.
2. **Fully update Windows 7 SP1** (build 7601). The upstream requirement is an updated SP1 install; an offline update pack is the practical way to get there today.
3. Install the laptop's **chipset and platform drivers first** (from ASUS's GL552VW support page archives): chipset, Management Engine, USB, LAN/WLAN, audio, card reader, touchpad/ATK. The graphics stack goes on last.
4. Download and extract the packages per [downloads.md](downloads.md). Read the README inside the main archive.
5. Run `scripts\Invoke-Gl552vwPreflight.ps1`. Fix anything it flags. Run it again with `-DriverFolder` against each extracted GPU driver and confirm your hardware IDs are listed:
   - Intel HD Graphics 530 devices are `PCI\VEN_8086&DEV_191B` (subsystem suffix varies by ASUS SKU — the script prints your exact IDs; match on `VEN_8086&DEV_191B`).
   - GeForce GTX 960M devices are `PCI\VEN_10DE&DEV_139B` on most GL552VW units (again, trust the IDs the script prints from your machine).

## 1. Install the main backport package

1. Run the main package installer (`wddm2_nov19_final.7z` contents) as administrator.
2. When Windows shows driver-trust prompts during setup, upstream instructs ticking **"Always trust"** so every component installs without interruption. Only do this because you downloaded from the official directory and accept patched drivers on this machine.
3. **Reboot when it finishes.** Do not install GPU drivers before this reboot.

## 2. Install the Intel HD 530 driver

On Optimus laptops the Intel GPU drives the internal display, so it goes first.

1. Open **Device Manager**, expand **Display adapters**, right-click the Intel adapter → **Update Driver Software** → **Browse my computer** → point it at the extracted Skylake package folder (let it search subfolders).
2. If Windows claims the best driver is already installed, use **Let me pick** → **Have Disk** and select the package INF directly.
3. Reboot and confirm Aero/DWM comes up cleanly at 1920×1080 before continuing.

## 3. Install the NVIDIA driver — read this twice

- If the preflight INF check found `VEN_10DE&DEV_139B` (your exact ID) in the 582.35 package, install it the same Device Manager way, then reboot.
- If it did **not** find your ID, stop. Forcing an INF-mismatched kernel driver is how machines end up unbootable. Install NVIDIA's last native Windows 7 driver for the GTX 960M instead; the 960M is new enough to have proper Win7 support without any backport.
- After the NVIDIA backport driver is in: **do not change the display resolution** (upstream warns it breaks DWM/Aero). Stay at native 1920×1080, and be careful with games that try to switch resolutions — prefer borderless/native-res modes.

## 4. First-boot checks

- Device Manager shows both adapters without warning icons. A **Code 12** ("not enough free resources") on dual-GPU machines was a known issue upstream fixed in the Nov 19 build — if you still see it, note which adapter reports it before changing anything. See troubleshooting.
- Run `dxdiag` and confirm the display tabs report sensibly.
- Test in order: Aero desktop → video playback → one DirectX 11 game → only then anything DirectX 12.
- Optimus sanity: launch a game and confirm it picks the GTX 960M (NVIDIA Control Panel → Manage 3D Settings, or per-app preference). HDMI output on the GL552VW is worth testing separately — note which GPU drives it on your unit.

## 5. Optional: VxKex extra

Skip on the first pass. Add the `extras` VxKex build later only when a specific app needs newer API shims, so you change one variable at a time.
