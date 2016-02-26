	# make -s clean >/dev/null 2>&1
	# rm -f sunxi-fexc sunxi-nand-part meminfo sunxi-fel sunxi-pio 2>/dev/null
	# make $CTHREADS 'sunxi-nand-part' CC=arm-linux-gnueabihf-gcc >> $DEST/debug/install.log 2>&1
	# make $CTHREADS 'sunxi-fexc' CC=arm-linux-gnueabihf-gcc >> $DEST/debug/install.log 2>&1
	# make $CTHREADS 'meminfo' CC=arm-linux-gnueabihf-gcc >> $DEST/debug/install.log 2>&1

# MISC5 = sunxi display control
if [[ -n "$MISC5_DIR" && $BRANCH != "next" && $LINUXSOURCEDIR == *sunxi* -o $LINUXSOURCEDIR == *sun8i* ]]; then
	if [ -f "$SOURCES/$LINUXSOURCEDIR/include/video/sunxi_disp_ioctl.h" ]; then
		cp "$SOURCES/$LINUXSOURCEDIR/include/video/sunxi_disp_ioctl.h" .
	else
		wget -q "https://raw.githubusercontent.com/linux-sunxi/linux-sunxi/sunxi-3.4/include/video/sunxi_disp_ioctl.h"
	fi
# MT7601U
if [[ -n "$MISC6_DIR" && $BRANCH != "next" ]]; then
	display_alert "Installing external applications" "MT7601U - driver" "info"
	cd $SOURCES/$MISC6_DIR
	cat >> fix_build.patch << _EOF_
diff --git a/src/dkms.conf b/src/dkms.conf
new file mode 100644
index 0000000..7563b5a
--- /dev/null
+++ b/src/dkms.conf
@@ -0,0 +1,8 @@
+PACKAGE_NAME="mt7601-sta-dkms"
+PACKAGE_VERSION="3.0.0.4"
+CLEAN="make clean"
+BUILT_MODULE_NAME[0]="mt7601Usta"
+BUILT_MODULE_LOCATION[0]="./os/linux/"
+DEST_MODULE_LOCATION[0]="/kernel/drivers/net/wireless"
+AUTOINSTALL=yes
+MAKE[0]="make -j4 KERNELVER=\$kernelver"
diff --git a/src/include/os/rt_linux.h b/src/include/os/rt_linux.h
index 3726b9e..b8be886 100755
--- a/src/include/os/rt_linux.h
+++ b/src/include/os/rt_linux.h
@@ -279,7 +279,7 @@ typedef struct file* RTMP_OS_FD;
 
 typedef struct _OS_FS_INFO_
 {
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,12,0)
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,4,0)
 	uid_t				fsuid;
 	gid_t				fsgid;
 #else
diff --git a/src/os/linux/rt_linux.c b/src/os/linux/rt_linux.c
index 1b6a631..c336611 100755
--- a/src/os/linux/rt_linux.c
+++ b/src/os/linux/rt_linux.c
@@ -51,7 +51,7 @@
 #define RT_CONFIG_IF_OPMODE_ON_STA(__OpMode)
 #endif
 
-ULONG RTDebugLevel = RT_DEBUG_TRACE;
+ULONG RTDebugLevel = 0;
 ULONG RTDebugFunc = 0;
 
 #ifdef OS_ABL_FUNC_SUPPORT
_EOF_
	patch -f -s -p1 -r - <fix_build.patch >/dev/null
	cd src
	make -s ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- clean >/dev/null 2>&1
	(make -s -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- LINUX_SRC=$SOURCES/$LINUXSOURCEDIR/ >/dev/null 2>&1)
	cp os/linux/*.ko $DEST/cache/sdcard/lib/modules/$VER-$LINUXFAMILY/kernel/net/wireless/
	mkdir -p $DEST/cache/sdcard/etc/Wireless/RT2870STA
	cp RT2870STA.dat $DEST/cache/sdcard/etc/Wireless/RT2870STA/
	depmod -b $DEST/cache/sdcard/ $VER-$LINUXFAMILY
	make -s clean 1>&2 2>/dev/null
	cd ..
	mkdir -p $DEST/cache/sdcard/usr/src/
	cp -R src $DEST/cache/sdcard/usr/src/mt7601-3.0.0.4
	# TODO: Set the module to build automatically via dkms in the future here
# h3disp for sun8i/3.4.x
if [ "$BOARD" = "orangepiplus" -o "$BOARD" = "orangepih3" ]; then
	install -m 755 "$SRC/lib/scripts/h3disp" "$DEST/cache/sdcard/usr/local/bin"