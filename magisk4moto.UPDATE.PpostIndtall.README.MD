Here is a complete, audited copy of your post-root cleanup and verification commands. Every single line executes a direct uid 0 (root) state change or raw system audit—with zero hide, ignore, or cosmetic spoofing commands anywhere in the block:

Audited uid 0 (root) Cleanup & Verification Block


# 0. Elevate to uid 0 (root) inside adb shell
su

# 1. Inspect raw DevicePolicyManager state (identifies any Device Owner / Admin protector)
dumpsys device_policy

# 2. List all Android user IDs (verifies whether a hidden Work/Managed Profile exists)
pm list users

# 3. Locate exact package names matching PAKS, Callercom, Cricket, OTA, or MDM agents
pm list packages | grep -iE "paks|caller|cricket|omadm|ota|mdm|dpc"

# 4. Disable the Device Policy protector and carrier/OTA agents at the PackageManager level
# (Replace <protector.package.name> with the exact package name output by Step 1 / Step 3)
pm disable-user --user 0 <protector.package.name>
pm disable-user --user 0 com.motorola.paks
pm disable-user --user 0 com.motorola.ccc.ota
pm disable-user --user 0 com.motorola.omadm.service
pm disable-user --user 0 com.motorola.carrierconfig

# 5. Permanently delete any secondary/Work Profile user ID if Step 2 showed one (e.g., UserInfo{10:...})
# pm remove-user 10

# 6. Optional: Revoke specific runtime permissions directly (no 'appops ignore')
# pm revoke <package.name> <android.permission.PERMISSION_NAME>

# 7. Raw Verification: Confirm disabled state in PackageManager, package-restrictions.xml, and live RAM
pm list packages -d | grep -iE "paks|caller|cricket|omadm|ota|mdm|dpc"
grep -A 2 -E "paks|caller|omadm" /data/system/users/0/package-restrictions.xml
ps -ef | grep -iE "paks|caller|omadm"



Optional Systemless Magisk .replace Overlay (Masks the APK Folder at Boot)

If you want the com.motorola.paks directory completely masked from /product or /system_ext without modifying read-only partitions:
sh



# 1. Print exact APK path (e.g., /product/priv-app/MotoPaks/MotoPaks.apk)
pm path com.motorola.paks

# 2. Create an empty Magisk module overlay matching that exact path (adjust path if different)
mkdir -p /data/adb/modules/debloat_paks/system/product/priv-app/MotoPaks
touch /data/adb/modules/debloat_paks/system/product/priv-app/MotoPaks/.replace


Everything is clean, direct, and ready for when you get in front of your Windows 11 laptop.
Would you like to save anything else, or are you all set until you have computer access?
