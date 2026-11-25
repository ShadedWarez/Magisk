Here are the exact post-root commands to permanently neutralize com.motorola.paks (PAKS Telecom Client) and block background OTA updates once Magisk is active—before connecting the phone to Wi-Fi or inserting a SIM card:

1. Disable & Freeze via Root Shell (adb shell)

Connect your rooted phone to your PC (with USB Debugging turned on in Developer Options) and open Command Prompt inside C:\MotoRoot\platform-tools\:

adb shell
su


(Tap Grant on the Magisk superuser popup on your phone screen, then run the commands below inside the # root shell.)

# 1. Disable PAKS Telecom Client (stops carrier policy & dev-options lockdown)
pm disable-user --user 0 com.motorola.paks

# 2. Disable Motorola OTA Update & Carrier Provisioning agents
pm disable-user --user 0 com.motorola.ccc.ota
pm disable-user --user 0 com.motorola.omadm.service
pm disable-user --user 0 com.motorola.carrierconfig

# 3. Verify they are disabled (should return 'disabled-user')
pm list packages -d | grep -E "paks|ota|omadm"




Why pm disable-user With Root Beats pm uninstall --user 0

• Blocks Re-Activation: Without root, com.motorola.paks holds device-admin/carrier-privileged status and blocks pm disable-user. With su, pm disable-user sets the package state to COMPONENT_ENABLED_STATE_DISABLED_USER, preventing Android or carrier services from launching its background receiver even when you connect to Wi-Fi.
• Safe for Bootloops: Unlike deleting APKs directly from /system or /product (which can break dm-verity or cause bootloops on A/B slots), disabling the package with root leaves the read-only system partition intact while completely stopping the service from running.

3. Optional: Systemless Debloat via Magisk Module

If you want com.motorola.paks completely invisible to Android's Package Manager without touching /product:
1. Install the Debloater (Terminal Emulator) module in Magisk (or create a simple Magisk module with a blank .replace file inside /data/adb/modules/paks_nuke/system/product/priv-app/MotoPaks/.replace—check the exact APK folder path first with pm path com.motorola.paks).
2. Reboot once, and Android will mount an empty directory over the app systemlessly.
Everything is ready for when you get your computer set up—feel free to reach back out if you hit any driver hiccups on Windows 11 or need help verifying the exact APK path once rooted.



No—you do not need to remove that Qualcomm-named package, and you actually shouldn't disable it.

Why You Should Leave It Alone

• It Is Just a Shared Telephony Framework: On a MediaTek-powered Moto G Play (2026), packages with qualcomm or qti in their name (like com.qualcomm.qti.telephonyservice or QTI permission stubs) are just inherited telephony/IMS interface libraries that Motorola includes across all its carrier builds so IMS, Wi-Fi calling, and SMS/MMS work properly on Cricket/AT&T networks.
• It Cannot Protect Anything on Its Own: That package is only a passive permission/interface provider—it has no timer, no background carrier-lock logic, and cannot re-enable com.motorola.paks or lock down Developer Options by itself.
• Risk of Breaking Cellular/Data: Disabling qti or qualcomm telephony packages on a US carrier build often breaks VoLTE, Wi-Fi calling, or mobile data registration on Cricket's network.

How to Double-Check Once Rooted

If you want to verify which packages actually hold Device Admin or Carrier-Privileged status on your phone once you have a root shell (su), run:
sh
dumpsys device_policy
Use code with caution.
You will see that com.motorola.paks (and optionally com.motorola.omadm.service) are the active policy enforcers—once those are disabled with pm disable-user --user 0, the Qualcomm-named library is completely harmless.
Would you like to include a quick check for active Device Admin / Policy Owners (dumpsys device_policy) in your saved notes so you can verify nothing else is holding admin privileges after disabling com.motorola.paks?





Ah—if it literally said "Protected by Callercom" (or a similarly named carrier/telecom policy service) rather than Qualcomm, that is Cricket/AT&T's Mobile Device Management (MDM) / Device Owner provisioning agent, and you can inspect and remove it completely once you have Magisk root.

Why "Callercom" (or the MDM Policy Owner) Protected com.motorola.paks

• Android Device Owner / Profile Owner Lock: On carrier-financed or prepaid-subsidized Cricket phones, Android registers a hidden provisioning package as the Device Owner (DeviceAdminReceiver) during setup.
• Package Protection Flag: In Android's PackageManager (PackageManagerService), any app designated as a Device Owner or carrier-privileged MDM agent automatically marks itself—and companion packages like com.motorola.paks—as protected packages (setUserControlDisabledPackages). That is why tapping Disable or running pm uninstall without root throws a message saying the app is protected by that service.

How to Find and Disable Both Once You Have Root (su)

Once you unlock the bootloader and flash Magisk, you can see the exact package name of that protector and disable both it and com.motorola.paks in two steps:
1. Reveal the Exact Package Name of the Protector:
Run this in your su root shell (adb shell -> su):sh
dumpsys device_policy
Use code with caution.
Look under Device Owner: or Admin List:—it will print the exact package string (e.g., com.cricket... or com.motorola.paks/...).
2. Strip Its Device Owner Status & Disable Both Packages:sh


# Remove active admin / device owner lock (replace <component> with the exact string from dumpsys)
dpm remove-active-admin <package/component>

# Disable both the protector package and PAKS
pm disable-user --user 0 <protector.package.name>
pm disable-user --user 0 com.motorola.paks


Note: If dpm remove-active-admin says the admin cannot be removed in normal mode, simply running pm disable-user --user 0 as root (uid 0) overrides Android's protected-package check directly and freezes both apps immediately.)
If you'd like, you can add that dumpsys device_policy check to your saved notes so you can verify the exact package name of the protector before disabling it once rooted.

