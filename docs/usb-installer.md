# Windows 7 USB installer for the GL552VW — MBR or GPT?

## Short answer

**Use MBR** for a dedicated Windows 7 install on this laptop. Choose GPT only if the same SSD must also dual-boot an existing UEFI Windows 10/11 install.

Why: Windows 7 does not support Secure Boot and its UEFI loader still expects a legacy VGA handoff, so pure-UEFI boots hang. The GL552VW firmware has full CSM/Legacy support, and a 512GB SSD is far below MBR's 2TB limit, so MBR costs nothing here.

## BIOS settings (do these first)

Hold `F2` at power-on:

1. **Security → Secure Boot Control → Disabled** (CSM stays greyed out until this is off).
2. **Boot → Launch CSM → Enabled**
3. **Boot → Fast Boot → Disabled**
4. Confirm **SATA mode is AHCI** (not RAID / Intel RST Premium) under Advanced → SATA Configuration.

Boot the stick from the one-time menu with `ESC` at power-on.

## Rufus settings

| Setting | MBR (recommended) | GPT (dual-boot only) |
| --- | --- | --- |
| Partition scheme | MBR | GPT |
| Target system | BIOS (or UEFI-CSM) | UEFI (non-CSM) |
| File system | NTFS | FAT32; use NTFS (UEFI:NTFS) only if `install.wim` exceeds 4 GB |
| Boot entry (`ESC` menu) | Plain USB name | `UEFI: <usb name>` |

The target disk style must match how you booted: Legacy/CSM installs only to MBR disks, UEFI only to GPT. If setup refuses the disk, wipe-convert it from setup (`Shift+F10`, then `diskpart` → `select disk 0` → `clean` → `convert mbr` or `convert gpt`). That erases the disk — backups first.

## "No device drivers were found" during setup

Full text: *"No device drivers were found. Make sure that the installation media contains the correct drivers, and then click OK."* (Older wording mentions a missing CD/DVD driver.)

On Skylake laptops this almost always means **setup lost the USB stick**: the firmware handed boot to Windows PE, which then could not talk to the USB 3.0 (xHCI) controller because stock Windows 7 SP1 media has no xHCI driver. The installer is really saying it cannot read its own install files. Work through these in order:

### 1. Move the stick to the USB 2.0 port (fixes most cases)

Cancel back to the "Install now" screen, move the stick to the GL552VW's **USB 2.0 port** (black tongue; the blue USB-A ports and USB-C are 3.x), then click **Install now** again. Changing ports mid-setup makes PE re-enumerate the stick on a controller it understands.

### 2. Re-check firmware settings

Secure Boot **Disabled**, Launch CSM **Enabled**, Fast Boot **Disabled**, SATA **AHCI**. A RAID/RST setting produces the same dead end later (no disks listed).

### 3. Recreate the stick

A corrupted ISO download or a bad write gives the identical error. Verify the ISO hash if you have one, rewrite with Rufus using the MBR table above, try a different stick, and never use a USB hub.

### 4. Load the Intel USB 3.0 driver at the prompt

Download Intel's USB 3.0 eXtensible Host Controller driver for Windows 7 (Skylake-era, 5.0.x series) on another PC, extract it to a folder on the install stick (for example `\drivers\usb3\`), then at the error click **Browse** and point setup at the folder containing `iusb3xhc.inf` / `iusb3hub.inf`. Load the host controller first, then the hub; the stick and disks should appear.

### 5. Permanent fix: inject drivers into the ISO (DISM)

On a Windows PC with the ADK/deployment tools or any Windows 10/11 install (DISM is built in), inject the USB 3.0 drivers into both images so every future install just works. Run from an elevated prompt with the ISO extracted to `C:\win7usb` and drivers extracted to `C:\usb3`:

```cmd
mkdir C:\mount
dism /mount-wim /wimfile:C:\win7usb\sources\boot.wim /index:2 /mountdir:C:\mount
dism /image:C:\mount /add-driver /driver:C:\usb3 /recurse
dism /unmount-wim /mountdir:C:\mount /commit

dism /mount-wim /wimfile:C:\win7usb\sources\install.wim /index:1 /mountdir:C:\mount
dism /image:C:\mount /add-driver /driver:C:\usb3 /recurse
dism /unmount-wim /mountdir:C:\mount /commit
```

Check your `install.wim` indexes first (`dism /get-wiminfo`) and inject into the edition you will install. Then write the patched folder/ISO to USB with Rufus as above. The same method can add the chipset/IRST storage drivers if a particular unit still hides its SSD.

### Still no disks listed (different problem)

If setup runs but the disk list is empty, that is storage, not USB: confirm AHCI mode, try loading the Intel RST/AHCI driver via **Load driver** on the disk-selection screen, and check the SSD appears in BIOS. The GL552VW's SATA SSD needs no NVMe hotfixes; an aftermarket NVMe M.2 drive would (Windows 7 needs KB2990941/KB3087873 injected the same DISM way).
