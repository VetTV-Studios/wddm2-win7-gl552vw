# Downloads (official W7Revived directory)

Get everything from the official server. Never use re-uploads from file-sharing sites — patched display drivers are exactly the kind of download that gets bundled with junk.

Base directory: https://w7revived.chefkiss.dev/WDDM2_Backport/Win7/

Observed there on November 22, 2026 (check the directory for newer files before you download):

| What you need | File / folder | Notes |
| --- | --- | --- |
| Main backport package | `wddm2_nov19_final.7z` (~24 MB, Nov 19) | Install first. The older `wddm2_nov17_final.7z` is superseded. Read the README inside the archive. |
| Intel driver (HD Graphics 530) | `Intel/Intel_HD_Skylake_Win7_WDDM2_Nov19PB1.7z` (~203 MB) | This is the Skylake package for the i7-6700HQ's HD 530. The UHD and Iris Xe packages are for newer Intel GPUs — not this laptop. |
| NVIDIA driver | `NVIDIA/NVIDIA_582_35_Win7_WDDM2_B2.7z` (~575 MB, Beta 2) | **Verify first:** confirm the GTX 960M hardware ID appears in its INFs (see the preflight script's `-DriverFolder` check). If it is absent, use NVIDIA's last native Windows 7 driver for the GTX 960M instead. |
| VxKex (optional extra) | `extras/KexSetup_Release_1_2_3_2328.exe` | Upstream describes this as a temporary WDDM2-compatible VxKex release. Optional; skip it for a first install and add it later only if an app needs it. |

## After downloading

1. Keep the `.7z` files untouched as your known-good copies, and extract working copies to a folder such as `C:\Drivers\WDDM2\`.
2. Read every README that extracts with them before running anything. Upstream notes override this guide if they disagree.
3. Record file hashes for your own notes:

   ```powershell
   Get-FileHash *.7z -Algorithm SHA256
   ```

   (Hashing proves your copy did not change later; it cannot prove a first download was authentic, which is why the official directory matters.)
4. Run the preflight script, including the `-DriverFolder` check against each extracted GPU driver.
