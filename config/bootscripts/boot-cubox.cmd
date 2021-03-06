# DO NOT EDIT THIS FILE
#
# Please edit /boot/armbianEnv.txt to set supported parameters
#

# run board detection
run autodetectfdt

# default values
setenv rootdev "/dev/mmcblk0p1"
setenv verbosity "1"
setenv console "display"
setenv rootfstype "ext4"
setenv disp_mode "1920x1080m60"

# additional values
setenv load_addr "0x10800000"
setenv ramdisk_addr "0x14800000"

# next/dev kernels have another DT file name
#if ext2load mmc 0 0x00000000 /boot/.next || ext2load mmc 0 0x00000000 .next; then
#	setenv fdt_file "imx6q-cubox-i.dtb"
#fi

if ext2load mmc 0 ${load_addr} /boot/armbianEnv.txt || ext2load mmc 0 ${load_addr} armbianEnv.txt; then
	env import -t ${load_addr} ${filesize}
fi

if test "${console}" = "display" || test "${console}" = "both"; then setenv consoleargs "console=tty1"; fi
if test "${console}" = "serial" || test "${console}" = "both"; then setenv consoleargs "${consoleargs} console=ttymxc0,115200"; fi

setenv bootargs "root=${rootdev} rootfstype=${rootfstype} rootwait ${consoleargs} consoleblank=0 video=mxcfb0:dev=hdmi,${disp_mode},if=RGB24,bpp=32 rd.dm=0 rd.luks=0 rd.lvm=0 raid=noautodetect pci=nomsi vt.global_cursor_default=0 loglevel=${verbosity} ${extraargs}"
ext2load mmc 0 ${fdt_addr} /boot/dtb/${fdt_file} || fatload mmc 0 ${fdt_addr} /dtb/${fdt_file} || ext2load mmc 0 ${fdt_addr} /dtb/${fdt_file}
ext2load mmc 0 ${ramdisk_addr} /boot/uInitrd || fatload mmc 0 ${ramdisk_addr} uInitrd || ext2load mmc 0 ${ramdisk_addr} uInitrd
ext2load mmc 0 ${loadaddr} /boot/zImage || fatload mmc 0 ${loadaddr} zImage || ext2load mmc 0 ${loadaddr} zImage

bootz ${loadaddr} ${ramdisk_addr} ${fdt_addr}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
